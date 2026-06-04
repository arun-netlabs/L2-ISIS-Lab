#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"
cd "$LAB_DIR" || exit 1
echo "Destroying ISIS lab..."
clab destroy --topo topo.yml --cleanup
