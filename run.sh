#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

PREFIX=golenev-09
docker rm -f "${PREFIX}-web" "${PREFIX}-db" 2>/dev/null || true
docker build --progress=plain --build-arg VERSION=2.0 -t "${PREFIX}/probe:2.0" .
docker volume create "${PREFIX}-data"
docker run -d --name "${PREFIX}-db" \
  -p 8029:5432 \
  -e POSTGRES_PASSWORD=lab -e POSTGRES_DB=lab \
  -v "${PREFIX}-data:/var/lib/postgresql/data" \
  postgres:16-alpine
docker run -d --name "${PREFIX}-web" \
  -p 8027:5009 \
  --add-host host.docker.internal:host-gateway \
  -e DATABASE_URL=postgresql://postgres:lab@host.docker.internal:8029/lab \
  "${PREFIX}/probe:2.0"

SECONDS=0
until curl -sf -m 3 localhost:8027/notes > /dev/null; do
  if [ "$SECONDS" -ge 60 ]; then
    echo 'База не готова за 60 секунд' >&2
    curl -s localhost:8027/notes >&2
    exit 1
  fi
  sleep 2
done
curl -sf localhost:8027/notes | python3 -m json.tool --no-ensure-ascii
