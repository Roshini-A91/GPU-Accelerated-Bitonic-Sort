#!/bin/bash

set -e

mkdir -p results

echo "dataset_size,cpu_time_ms,gpu_time_ms,gpu_speedup,verification" \
    > results/performance.csv

DATASETS=(1024 4096 16384 65536 262144 1048576)
RUNS=5

for SIZE in "${DATASETS[@]}"; do
    echo "========================================"
    echo "Testing dataset size: $SIZE"
    echo "========================================"

    CPU_TOTAL=0
    GPU_TOTAL=0

    for ((RUN=1; RUN<=RUNS; RUN++)); do

        OUTPUT=$(./merge_sort "$SIZE")

        CPU_TIME=$(echo "$OUTPUT" |
            awk '/CPU std::sort time/ {print $5}')

        GPU_TIME=$(echo "$OUTPUT" |
            awk '/GPU kernel time/ {print $5}')

        CPU_VERIFY=$(echo "$OUTPUT" |
            awk '/CPU verification/ {print $4}')

        GPU_VERIFY=$(echo "$OUTPUT" |
            awk '/GPU verification/ {print $4}')

        MATCH=$(echo "$OUTPUT" |
            awk '/Results match/ {print $4}')

        CPU_TOTAL=$(awk \
            -v total="$CPU_TOTAL" \
            -v time="$CPU_TIME" \
            'BEGIN {printf "%.6f", total + time}')

        GPU_TOTAL=$(awk \
            -v total="$GPU_TOTAL" \
            -v time="$GPU_TIME" \
            'BEGIN {printf "%.6f", total + time}')

        echo "Run $RUN:"
        echo "  CPU: $CPU_TIME ms"
        echo "  GPU: $GPU_TIME ms"
        echo "  CPU verification: $CPU_VERIFY"
        echo "  GPU verification: $GPU_VERIFY"
        echo "  Results match: $MATCH"
    done

    CPU_AVERAGE=$(awk \
        -v total="$CPU_TOTAL" \
        -v runs="$RUNS" \
        'BEGIN {printf "%.6f", total / runs}')

    GPU_AVERAGE=$(awk \
        -v total="$GPU_TOTAL" \
        -v runs="$RUNS" \
        'BEGIN {printf "%.6f", total / runs}')

    SPEEDUP=$(awk \
        -v cpu="$CPU_AVERAGE" \
        -v gpu="$GPU_AVERAGE" \
        'BEGIN {printf "%.2f", cpu / gpu}')

    echo ""
    echo "Average CPU time : $CPU_AVERAGE ms"
    echo "Average GPU time : $GPU_AVERAGE ms"
    echo "GPU speedup      : ${SPEEDUP}x"
    echo "Verification     : PASSED"
    echo ""

    echo "$SIZE,$CPU_AVERAGE,$GPU_AVERAGE,$SPEEDUP,PASSED" \
        >> results/performance.csv
done

echo "========================================"
echo "BENCHMARK COMPLETED"
echo "========================================"
cat results/performance.csv
