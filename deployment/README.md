# Onyx deployment — Docker Compose + Coolify

Full (**Standard**, with RAG) Onyx stack, deployed as prebuilt images behind a
reverse proxy. No Let's Encrypt / certbot: the platform proxy terminates TLS.

Upstream reference: <https://github.com/onyx-dot-app/onyx/tree/main/deployment/docker_compose>

## What is here

| Path                                                                            | Why it is needed                                                                                                                                                                                                                          |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `docker_compose/docker-compose.yml`                                             | The full stack: `nginx`, `api_server`, `web_server`, `background`, `relational_db` (Postgres), `opensearch` (RAG index), `cache` (Redis), `minio` (S3 file store), `inference_model_server`, `indexing_model_server`, `code-interpreter`. |
| `docker_compose/env.template`                                                   | Upstream environment reference. Copy the values you need into the platform's env settings (or into a local `.env`).                                                                                                                       |
| `data/nginx/app.conf.template`                                                  | nginx config mounted by the `nginx` service at `../data/nginx`. Routes `/api` → `api_server`, `/` → `web_server`, WebSockets, `/nginx-health`.                                                                                            |
| `data/nginx/run-nginx.sh`                                                       | Fills the template at container start (`envsubst`).                                                                                                                                                                                       |
| `data/nginx/mcp.conf.inc.template`, `data/nginx/mcp_upstream.conf.inc.template` | Required by `run-nginx.sh`; rendered only when `MCP_SERVER_ENABLED` is set.                                                                                                                                                               |
| `.gitignore`                                                                    | Keeps `.env*` and `secrets.yaml` out of git.                                                                                                                                                                                              |

Deliberately **not** included: `docker-compose.onyx-lite.yml` (Lite has no RAG),
`docker-compose.prod.yml` / `docker-compose.prod-no-letsencrypt.yml` and
`init-letsencrypt.sh` (certbot/LE), `docker-compose.craft.yml`, `docker-compose.dev.yml`,
the `*-test.yml` and `airgap-*` overlays, `docker-compose.resources.yml` (optional), and
`install.sh` / `install.ps1` (they only install the `onyx-cli` guided installer, which
downloads these same files itself).

### Intentional differences from upstream

1. **No `build:` sections.** This repo carries no backend/web source, so every service
   pulls its published image. If `build:` is left in, Coolify builds from `../../backend`
   and fails.
2. **`nginx` publishes no host ports.** The platform proxy owns 80/443 and reaches the
   container over the app network. For a plain `docker compose up`, add a port via an
   override (below).
3. **MinIO always starts** (no `s3-filestore` profile), so the S3 file store never depends
   on `COMPOSE_PROFILES` surviving the platform.
4. **`data/nginx/app.conf.template` honors `X-Forwarded-Proto`** from the proxy instead of
   hardcoding `$scheme`. Onyx's nginx is not the TLS entry point here; without this the
   back end sees `http` and drops the `Secure` flag from auth cookies.

## Sizing (Standard)

Minimum ~4 vCPU / 10 GB RAM / 32 GB disk; preferred 8+ vCPU / 16+ GB RAM. OpenSearch ships
pinned at `-Xms2g -Xmx2g`; if you give the box more RAM, raise it to ~50 % of available
memory and remember the extra is used for the OS file cache. Disk ≈ 1.45× indexed source
data. See <https://docs.onyx.app/deployment/getting_started/resourcing>.

## Coolify

1. **New Resource → Docker Compose** (from this Git repo, branch `main`).
2. **Base Directory:** `/deployment/docker_compose`
   **Docker Compose Location:** `/docker-compose.yml`
   The base directory matters: `.env` is read there and `../data/nginx` resolves to
   `deployment/data/nginx`.
3. **Environment variables** — set at least these (generate the secrets with
   `openssl rand -hex 32`):

   ```dotenv
   IMAGE_TAG=latest
   WEB_DOMAIN=https://onyx.example.com
   USER_AUTH_SECRET=<openssl rand -hex 32>
   ENCRYPTION_KEY_SECRET=<openssl rand -hex 32>
   POSTGRES_USER=onyx
   POSTGRES_PASSWORD=<strong password>
   OPENSEARCH_ADMIN_PASSWORD=<strong password>
   MINIO_ROOT_USER=onyx
   MINIO_ROOT_PASSWORD=<strong password>
   S3_AWS_ACCESS_KEY_ID=onyx
   S3_AWS_SECRET_ACCESS_KEY=<same value as MINIO_ROOT_PASSWORD>
   FILE_STORE_BACKEND=s3
   S3_FILE_STORE_BUCKET_NAME=onyx-file-store-bucket
   LOG_LEVEL=info
   ```

   `USER_AUTH_SECRET` is not optional — the API server refuses to start with it empty.
   Keep `S3_AWS_ACCESS_KEY_ID`/`S3_AWS_SECRET_ACCESS_KEY` identical to
   `MINIO_ROOT_USER`/`MINIO_ROOT_PASSWORD`. Do **not** set `COMPOSE_PROFILES`.
   Auth defaults to email/password (`AUTH_TYPE=basic`); SSO is configured later in the
   admin panel. The first user to sign up becomes admin.

4. **Domain:** set it on the **`nginx`** service, container port `80`, e.g.
   `https://onyx.example.com`. Coolify's proxy terminates TLS and forwards; no certs are
   handled inside the stack.
5. **Deploy.** First boot pulls several GB of images, runs Alembic migrations
   (`api_server` has a 600 s health start period) and downloads embedding models in the
   model servers. Expect 10+ minutes before the UI responds; use a generous deployment /
   health-check timeout.

## Run locally (Docker Compose)

Same file, no Coolify. The base file intentionally publishes no host ports, so add a small
override to reach it from the host.

1. Create `deployment/docker_compose/docker-compose.override.yml`:

   ```yaml
   services:
     nginx:
       ports:
         - "${HOST_PORT:-3000}:80" # http://localhost:3000
         - "${HOST_PORT_80:-80}:80" # http://localhost
   ```

   Do not commit it: Coolify runs Compose from this same directory, and published host
   ports would collide with its proxy.

2. Create `.env` and fill in the required values — the same list as the Coolify step,
   with throwaway secrets locally:

   ```sh
   cd deployment/docker_compose
   cp env.template .env
   openssl rand -hex 32   # USER_AUTH_SECRET
   openssl rand -hex 32   # ENCRYPTION_KEY_SECRET
   ```

   Set `WEB_DOMAIN` to the URL you browse, or leave it unset on localhost.

3. Start it, watch the first boot, then stop it:

   ```sh
   docker compose up -d
   docker compose ps
   docker compose logs -f api_server web_server
   ```

   Open <http://localhost:3000> (or <http://localhost> on port 80). The first user to
   sign up becomes admin. The first boot pulls several GB, runs Alembic migrations and
   downloads the HuggingFace embedding/rerank models — allow 10+ minutes and network
   access.

   ```sh
   docker compose stop      # stop containers, keep data
   docker compose down      # remove containers, keep named volumes
   docker compose down -v   # remove containers and all data volumes
   ```

Local sizing is the same as the host sizing above (~4 vCPU / 10 GB RAM, ~40 GB disk). On
Docker Desktop raise the VM memory limit; on Linux Docker uses host memory directly.

## Notes

- **Code interpreter**: the `code-interpreter` service mounts `/var/run/docker.sock`
  (root-equivalent on the host). Remove that service and unset `CODE_INTERPRETER_BASE_URL`
  if you do not want code execution.
- **Rootless Docker**: `code-interpreter` mounts the daemon socket. On rootless setups set
  `DOCKER_SOCK_PATH=${XDG_RUNTIME_DIR}/docker.sock`; on Docker Desktop confirm the socket
  is available to the container.
- **Upgrades**: change `IMAGE_TAG` to a release tag and redeploy; with `latest`, pull first.
- These files are derived from upstream `main`; re-fetch them when you want a newer
  compose revision, then re-apply the four differences listed above.
- Never commit `.env` or real secrets.
