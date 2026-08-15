#include <cuda_runtime.h>

#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <iostream>
#include <random>
#include <vector>

#define CUDA_CHECK(call)                                                   \
    do {                                                                   \
        cudaError_t error = call;                                          \
        if (error != cudaSuccess) {                                        \
            std::cerr << "CUDA error: " << cudaGetErrorString(error)       \
                      << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
            return 1;                                                      \
        }                                                                  \
    } while (0)

__global__ void compare_swap(int* data, int j, int k, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i >= n) {
        return;
    }

    int ixj = i ^ j;

    if (ixj > i && ixj < n) {
        if ((i & k) == 0) {
            if (data[i] > data[ixj]) {
                int temp = data[i];
                data[i] = data[ixj];
                data[ixj] = temp;
            }
        } else {
            if (data[i] < data[ixj]) {
                int temp = data[i];
                data[i] = data[ixj];
                data[ixj] = temp;
            }
        }
    }
}

bool is_sorted(const std::vector<int>& data) {
    return std::is_sorted(data.begin(), data.end());
}

int main(int argc, char* argv[]) {
    int n = 1024;

    if (argc > 1) {
        n = std::atoi(argv[1]);
    }

    if (n < 2 || (n & (n - 1)) != 0) {
        std::cerr << "Error: dataset size must be a power of two."
                  << std::endl;
        std::cerr << "Example: ./merge_sort 4096" << std::endl;
        return 1;
    }

    std::vector<int> original_data(n);

    std::mt19937 generator(42);
    std::uniform_int_distribution<int> distribution(0, 100000);

    for (int& value : original_data) {
        value = distribution(generator);
    }

    // ---------------- CPU SORT ----------------

    std::vector<int> cpu_data = original_data;

    auto cpu_start = std::chrono::high_resolution_clock::now();

    std::sort(cpu_data.begin(), cpu_data.end());

    auto cpu_stop = std::chrono::high_resolution_clock::now();

    double cpu_time_ms =
        std::chrono::duration<double, std::milli>(
            cpu_stop - cpu_start
        ).count();

    // ---------------- GPU SORT ----------------

    std::vector<int> gpu_data = original_data;

    int* d_data = nullptr;

    CUDA_CHECK(cudaMalloc(&d_data, n * sizeof(int)));

    CUDA_CHECK(cudaMemcpy(
        d_data,
        gpu_data.data(),
        n * sizeof(int),
        cudaMemcpyHostToDevice
    ));

    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;

    cudaEvent_t start;
    cudaEvent_t stop;

    CUDA_CHECK(cudaEventCreate(&start));
    CUDA_CHECK(cudaEventCreate(&stop));

    CUDA_CHECK(cudaEventRecord(start));

    for (int k = 2; k <= n; k *= 2) {
        for (int j = k / 2; j > 0; j /= 2) {
            compare_swap<<<blocks, threads>>>(d_data, j, k, n);

            CUDA_CHECK(cudaGetLastError());
        }
    }

    CUDA_CHECK(cudaEventRecord(stop));
    CUDA_CHECK(cudaEventSynchronize(stop));

    float gpu_time_ms = 0.0f;

    CUDA_CHECK(cudaEventElapsedTime(
        &gpu_time_ms,
        start,
        stop
    ));

    CUDA_CHECK(cudaMemcpy(
        gpu_data.data(),
        d_data,
        n * sizeof(int),
        cudaMemcpyDeviceToHost
    ));

    CUDA_CHECK(cudaEventDestroy(start));
    CUDA_CHECK(cudaEventDestroy(stop));
    CUDA_CHECK(cudaFree(d_data));

    // ---------------- VERIFICATION ----------------

    bool cpu_sorted = is_sorted(cpu_data);
    bool gpu_sorted = is_sorted(gpu_data);

    bool results_match = (cpu_data == gpu_data);

    // ---------------- RESULTS ----------------

    std::cout << "========================================" << std::endl;
    std::cout << "GPU-Accelerated Bitonic Sort" << std::endl;
    std::cout << "========================================" << std::endl;

    std::cout << "Dataset size       : "
              << n << " elements" << std::endl;

    std::cout << "CPU std::sort time : "
              << cpu_time_ms << " ms" << std::endl;

    std::cout << "GPU kernel time    : "
              << gpu_time_ms << " ms" << std::endl;

    std::cout << "CPU verification   : "
              << (cpu_sorted ? "PASSED" : "FAILED")
              << std::endl;

    std::cout << "GPU verification   : "
              << (gpu_sorted ? "PASSED" : "FAILED")
              << std::endl;

    std::cout << "Results match      : "
              << (results_match ? "YES" : "NO")
              << std::endl;

    std::cout << "========================================"
              << std::endl;

    return (cpu_sorted && gpu_sorted && results_match) ? 0 : 1;
}
