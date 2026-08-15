# GPU-Accelerated Bitonic Sort

## 1. Project Overview

This project demonstrates GPU acceleration of a parallel sorting algorithm using NVIDIA CUDA. A Bitonic Sort implementation was developed to perform sorting operations on the GPU, and its performance was compared with the CPU `std::sort()` implementation.

The project evaluates how the benefit of GPU parallelism changes as the input dataset increases in size.

The implementation was developed and tested using an NVIDIA Tesla T4 GPU.

## 2. Objectives

The main objectives of this project are:

* Implement a parallel Bitonic Sort using CUDA.
* Execute the sorting algorithm on an NVIDIA GPU.
* Accept the dataset size through a command-line argument.
* Verify that the GPU output is correctly sorted.
* Compare GPU kernel execution time with CPU `std::sort()`.
* Evaluate performance across multiple dataset sizes.
* Provide reproducible build and benchmark scripts.

## 3. Technologies Used

* C++
* NVIDIA CUDA
* CUDA Runtime API
* `nvcc` CUDA compiler
* NVIDIA Tesla T4 GPU
* Bash scripting
* GNU Make

## 4. Algorithm

The project uses Bitonic Sort, a comparison-based sorting algorithm that is well suited to parallel execution.

The CUDA implementation uses a `compare_swap` kernel. CUDA threads compare pairs of elements and exchange them when necessary. The sorting process is organized using the `j` and `k` stages of the Bitonic Sorting Network.

The implementation requires the dataset size to be a power of two.

Examples of valid dataset sizes include:

```text
1024
4096
16384
65536
262144
1048576
```

## 5. CUDA Implementation

The main CUDA source file is:

```text
merge_sort.cu
```

The program:

1. Generates a reproducible input dataset.
2. Copies the data from host memory to GPU memory.
3. Executes the CUDA Bitonic Sort kernel.
4. Measures GPU kernel execution time using CUDA events.
5. Copies the sorted data back to host memory.
6. Verifies that the GPU output is sorted.
7. Compares the GPU result with the CPU `std::sort()` result.

CUDA error checking is included for CUDA runtime operations and kernel launches.

## 6. CPU Comparison

The CPU implementation uses the C++ standard library:

```cpp
std::sort()
```

CPU execution time is measured using C++ high-resolution timing.

GPU timing measures the Bitonic Sort kernel execution using CUDA events. It does not include host-to-device and device-to-host memory transfer time.

Therefore, the reported speedup represents:

```text
CPU std::sort time / GPU Bitonic Sort kernel time
```

and should not be interpreted as complete end-to-end application speedup.

## 7. Building the Project

The project includes a Makefile.

To build:

```bash
make
```

To remove the compiled executable and benchmark CSV:

```bash
make clean
```

The project can also be built directly with:

```bash
nvcc -O2 merge_sort.cu -o merge_sort
```

## 8. Running the Program

The dataset size can be supplied as a command-line argument.

Example:

```bash
./merge_sort 4096
```

If no argument is supplied, the default dataset size is 1024 elements:

```bash
./merge_sort
```

The dataset size must be a power of two.

The program reports:

* Dataset size
* CPU sorting time
* GPU kernel time
* CPU verification result
* GPU verification result
* Whether CPU and GPU results match

## 9. Run Script

The project includes:

```text
run.sh
```

The script builds the project and executes it.

Example:

```bash
./run.sh 4096
```

If no dataset size is supplied:

```bash
./run.sh
```

the default size is 1024 elements.

## 10. Benchmarking

The project includes:

```text
benchmark.sh
```

The benchmark executes five runs for each dataset size and calculates the average CPU time, average GPU kernel time, and GPU speedup.

Run:

```bash
./benchmark.sh
```

The benchmark results are saved to:

```text
results/performance.csv
```

## 11. Benchmark Results

Testing was performed on an NVIDIA Tesla T4 GPU.

The latest benchmark used five runs for each dataset size.

| Dataset Size | CPU Average (ms) | GPU Average (ms) | GPU Speedup | Verification |
| -----------: | ---------------: | ---------------: | ----------: | :----------: |
|        1,024 |         0.047145 |         0.316595 |       0.15x |    PASSED    |
|        4,096 |         0.237046 |         0.400403 |       0.59x |    PASSED    |
|       16,384 |         1.109192 |         0.504941 |       2.20x |    PASSED    |
|       65,536 |         5.519304 |         0.777216 |       7.10x |    PASSED    |
|      262,144 |        22.117020 |         0.891936 |      24.80x |    PASSED    |
|    1,048,576 |        84.933760 |         2.978010 |      28.52x |    PASSED    |

## 12. Results Analysis

The results show that GPU acceleration is not equally beneficial for every dataset size.

For small datasets such as 1,024 and 4,096 elements, CPU `std::sort()` was faster than the GPU kernel. This is expected because the GPU has overhead associated with launching and executing parallel work.

As the dataset size increases, the parallelism of the GPU becomes increasingly beneficial.

At 16,384 elements, the GPU achieved a 2.20x kernel-time speedup.

At 65,536 elements, the speedup increased to 7.10x.

At 262,144 elements, the speedup reached 24.80x.

For the largest tested dataset of 1,048,576 elements, the GPU achieved a measured 28.52x kernel-time speedup compared with CPU `std::sort()`.

All tested datasets passed CPU verification, GPU verification, and CPU/GPU result comparison.

## 13. Challenges and Lessons Learned

One important challenge was understanding that GPU performance depends strongly on workload size. A GPU does not automatically outperform a CPU for every problem size.

The project also demonstrated the importance of correctness verification when developing parallel GPU programs. The GPU result was compared against the CPU result to ensure that the parallel implementation produced the expected ordering.

Repeated benchmarking also showed that GPU execution times can vary between individual runs. Running multiple iterations and calculating an average provides a more reliable performance measurement.

Another lesson was the importance of separating GPU kernel timing from memory-transfer timing when interpreting performance results.

## 14. Limitations

The current implementation requires the input size to be a power of two.

The performance comparison reports GPU kernel time rather than complete end-to-end application time.

The benchmark was performed on a single NVIDIA Tesla T4 GPU, so results may differ on other GPU architectures.

## 15. Future Improvements

Possible future improvements include:

* Supporting arbitrary input sizes.
* Including host-to-device and device-to-host transfer times.
* Testing additional GPU architectures.
* Exploring optimized CUDA memory-access patterns.
* Comparing Bitonic Sort with other GPU sorting algorithms.
* Testing larger datasets.
* Investigating CUDA libraries designed specifically for high-performance sorting.

## 16. Project Structure

```text
GPU-Accelerated-Bitonic-Sort/
│
├── merge_sort.cu
├── benchmark.sh
├── Makefile
├── run.sh
├── README.md
└── results/
    └── performance.csv
```

## 17. Reproducibility

A CUDA-capable NVIDIA GPU and CUDA toolkit are required.

To build and run the project:

```bash
make
./run.sh 4096
```

To reproduce the performance benchmark:

```bash
./benchmark.sh
```

The benchmark results are written to:

```text
results/performance.csv
```

## 18. Conclusion

This project demonstrates how CUDA can be used to accelerate a parallel sorting workload. The experiments show that GPU acceleration becomes increasingly effective as the dataset grows.

While CPU sorting was faster for small inputs, the GPU achieved substantial kernel-time speedups for larger datasets, reaching 30.73x for the 1,048,576-element test on the NVIDIA Tesla T4.

The project provided practical experience with CUDA kernels, GPU memory management, synchronization, CUDA event timing, correctness verification, benchmarking, and reproducible GPU program execution.
