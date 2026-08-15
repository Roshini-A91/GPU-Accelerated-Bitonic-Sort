#!/bin/bash

set -e

echo "========================================"
echo "GPU-Accelerated Bitonic Sort"
echo "========================================"

echo "Building project..."
make

echo ""
echo "Running GPU sort..."
echo ""

DATASET_SIZE=${1:-1024}

./merge_sort "$DATASET_SIZE"

echo ""
echo "Execution completed successfully."
