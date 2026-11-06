#!/usr/bin/env bash
# scripts/clean-hm-apps.sh
# Wrapper de conveniência para invocar clean-orphaned-configs.

set -euo pipefail
exec clean-orphaned-configs "$@"

