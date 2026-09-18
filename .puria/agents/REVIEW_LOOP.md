# REVIEW_LOOP.md

Substantial agent work must have a human verification boundary.

For new projects and substantial implementation tasks, agents must plan the work, create tracked tasks, implement one phase at a time, validate the result, and prepare a reviewable pull request for each phase.

The phase pull request must say what changed, why it matters, how to run it, how to check it, what validation ran, what the tester found, what could regress, and what remains unfinished.

The human must be able to review the phase from the pull request without guessing.

This file does not replace `PURIA.md`.
