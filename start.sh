#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[start]${NC} $*"; }
warn() { echo -e "${YELLOW}[start]${NC} $*"; }
die()  { echo -e "${RED}[start]${NC} $*" >&2; exit 1; }

# ── prerequisites ────────────────────────────────────────────────────────────
command -v docker  >/dev/null 2>&1 || die "docker is not installed or not on PATH"
command -v mvn     >/dev/null 2>&1 || die "mvn is not installed or not on PATH"

# ── datastore containers ─────────────────────────────────────────────────────
log "Starting MySQL and Redis containers..."
docker compose up -d

log "Waiting for MySQL to be healthy..."
until docker compose exec -T mysql mysqladmin ping -h localhost --silent 2>/dev/null; do
  printf '.'
  sleep 2
done
echo ""
log "MySQL is ready."

log "Waiting for Redis to be healthy..."
until docker compose exec -T redis redis-cli ping 2>/dev/null | grep -q PONG; do
  printf '.'
  sleep 1
done
echo ""
log "Redis is ready."

# ── build & run ───────────────────────────────────────────────────────────────
log "Building application (skipping tests)..."
mvn clean package -q -DskipTests

log "Starting Spring Boot application on http://localhost:8080 ..."
echo ""
mvn spring-boot:run
