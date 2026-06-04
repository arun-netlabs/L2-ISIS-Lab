#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"
cd "$LAB_DIR" || exit 1
echo "Deploying ISIS lab..."
clab deploy --topo topo.yml
