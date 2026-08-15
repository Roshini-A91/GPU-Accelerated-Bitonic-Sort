NVCC = nvcc
NVCC_FLAGS = -O2

TARGET = merge_sort
SOURCE = merge_sort.cu

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(NVCC) $(NVCC_FLAGS) $(SOURCE) -o $(TARGET)

benchmark: $(TARGET)
	./benchmark.sh

clean:
	rm -f $(TARGET)
	rm -rf results/*.csv

.PHONY: all benchmark clean
