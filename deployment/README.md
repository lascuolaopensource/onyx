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
   container over the app network. Local runs publish ports through the separate
   `docker-compose.local.yml` (below).
3. **MinIO always starts** (no `s3-filestore` profile), so the S3 file store never depends
   on `COMPOSE_PROFILES` surviving the platform.
4. **`data/nginx/app.conf.template` honors `X-Forwarded-Proto`** from the proxy instead of
   hardcoding `$scheme`. Onyx's nginx is not the TLS entry point here; without this the
   back end sees `http` and drops the `Secure` flag from auth cookies.
5. **OpenSearch memory locking is opt-in.** Upstream sets `bootstrap.memory_lock=true` with
   a `memlock: -1` ulimit; runc cannot raise `RLIMIT_MEMLOCK` to unlimited on every host
   (restricted or nested Docker daemons fail the container with
   `error setting rlimit type 8: operation not permitted`, type 8 = `RLIMIT_MEMLOCK`).
   Here it defaults to `false` so the stack boots anywhere. See "Host prerequisites".
6. **OpenSearch readiness gating + retry budget.** Onyx's `setup_onyx()` raises
   `RuntimeError("Could not connect to a document index within the specified timeout.")`
   after `NUM_RETRIES_ON_STARTUP` attempts (upstream default: 10 ≈ 50 s), crash-looping
   `api_server` on cold boots while OpenSearch is still starting. Here `api_server` waits
   for an OpenSearch healthcheck (`_cluster/health?wait_for_status=yellow`) before starting
   and the retry budget defaults to 60 (~5 min).

## Sizing (Standard)

Minimum ~4 vCPU / 10 GB RAM / 32 GB disk; preferred 8+ vCPU / 16+ GB RAM. OpenSearch ships
pinned at `-Xms2g -Xmx2g`; if you give the box more RAM, raise it to ~50 % of available
memory and remember the extra is used for the OS file cache. Disk ≈ 1.45× indexed source
data. See <https://docs.onyx.app/deployment/getting_started/resourcing>.

## Host prerequisites (OpenSearch)

Two host-level kernel/runtime settings decide whether OpenSearch starts:

1. **`vm.max_map_count` ≥ 262144 — mandatory.** Without it OpenSearch crashes at boot with
   `max virtual memory areas vm.max_map_count [65530] is too low`. It is not namespaced, so
   it must be set on the host, not in the compose file:

   ```sh
   sudo sysctl -w vm.max_map_count=262144
   echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-onyx-opensearch.conf
   ```

2. **Memory locking — optional.** Upstream's `bootstrap.memory_lock=true` + unlimited
   `memlock` ulimit needs a Docker daemon allowed to raise `RLIMIT_MEMLOCK`; on hosts
   where it cannot, OpenSearch never starts (`error setting rlimit type 8`). This repo
   defaults it to `false` — the node boots and simply may page the JVM heap to swap. To
   enable it: give the daemon the limit and opt in,

   ```sh
   # /etc/systemd/system/docker.service.d/memlock.conf
   [Service]
   LimitMEMLOCK=infinity
   ```

   ```sh
   sudo systemctl daemon-reload && sudo systemctl restart docker
   ```

   then set `OPENSEARCH_MEMORY_LOCK=true` in the environment and add the ulimit via an
   extra compose file (`-f` after the base ones):

   ```yaml
   # docker-compose.memlock.yml
   services:
     opensearch:
       ulimits:
         memlock:
           soft: -1
           hard: -1
   ```

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

`mise run local` brings up the full stack. On the first run it creates `.env` from
`env.template` and fills `USER_AUTH_SECRET` and `ENCRYPTION_KEY_SECRET` with generated
secrets; later runs keep your edits.

```sh
mise run local        # up; creates .env + generated secrets on first run
mise run local:logs   # follow container logs
mise run local:down   # stop, remove containers, keep data volumes
mise run local:reset  # stop and delete all data volumes — destructive
```

Open <http://localhost:3000> (or <http://localhost> on port 80). The first user to sign up
becomes admin. The first boot pulls several GB of images, runs Alembic migrations and
downloads the HuggingFace embedding/rerank models — allow 10+ minutes and network access.
`local:reset` deletes the Postgres, OpenSearch and MinIO volumes, so only use it to start
over from an empty deployment.

The local ports live in `docker-compose.local.yml`, committed next to the base file. It is
separate from `docker-compose.yml` — the only file Coolify is pointed at — so local runs
never collide with the platform proxy. Raw Docker Compose equivalent:

```sh
cd deployment/docker_compose
cp env.template .env   # then set USER_AUTH_SECRET (required) and the secrets above
docker compose -f docker-compose.yml -f docker-compose.local.yml up -d
```

Set `WEB_DOMAIN` to the URL you browse, or leave it unset on localhost.

Local sizing is the same as the host sizing above (~4 vCPU / 10 GB RAM, ~40 GB disk). On
Docker Desktop raise the VM memory limit; on Linux Docker uses host memory directly.

## Notes

- **Code interpreter**: the `code-interpreter` service mounts `/var/run/docker.sock`
  (root-equivalent on the host). Remove that service and unset `CODE_INTERPRETER_BASE_URL`
  if you do not want code execution.
- **Rootless Docker**: `code-interpreter` mounts the daemon socket. On rootless setups set
  `DOCKER_SOCK_PATH=${XDG_RUNTIME_DIR}/docker.sock`; on Docker Desktop confirm the socket
  is available to the container.
- **First boot ordering**: `api_server` starts only after OpenSearch reports yellow, and
  `nginx` starts only after `api_server` is healthy. First boot therefore takes several
  minutes by design (model downloads are not gated, they keep downloading in the
  background). Raise `NUM_RETRIES_ON_STARTUP` if your host is slower.
- **PR previews**: every Coolify preview deployment of a pull request runs the entire
  12-container stack with fresh volumes. Disable preview deployments for this resource
  unless you actually need them.
- **Upgrades**: change `IMAGE_TAG` to a release tag and redeploy; with `latest`, pull first.
- These files are derived from upstream `main`; re-fetch them when you want a newer
  compose revision, then re-apply the divergences listed above.
- Never commit `.env` or real secrets.
