CC = gcc
FLAGS = -Wall -funroll-all-loops -march=native -lm -I./mosfhet/include/ -I./include/
DEBUG_FLAGS = -g $(FLAGS)
OPT_FLAGS = -O3 -fwhole-program -flto -DNDEBUG $(FLAGS)
LIBS = -L./mosfhet/lib/ -lmosfhet
LD_LIBS = LD_LIBRARY_PATH=./mosfhet/lib/
BUILD_LIBS = 
TEST_FLAGS = $(OPT_FLAGS)

SRC = ufhe.c integer.c lut.c io.c ml.c

all: ufhe

test: mosfhet test/test 
	$(LD_LIBS) ./test/test

bench: test/benchmark
	$(LD_LIBS) ./test/benchmark

ufhe: mosfhet lib lib/ufhe

mosfhet: lib/libmosfhet.so

lib:
	mkdir -p lib

lib/libmosfhet.so:
	make -C mosfhet

lib/ufhe: $(addprefix src/, $(SRC))
	$(CC) -g -fPIC -shared -o lib/libufhe.so $^ $(OPT_FLAGS) $(LIBS)

test_debug: override TEST_FLAGS = $(DEBUG_FLAGS) 
test_debug: test/test
	$(LD_LIBS) gdb ./test/test

test/test: $(addprefix src/, $(SRC)) test/unity_test/unity.c test/tests.c 
	$(CC) -g -o test/test $^ $(TEST_FLAGS) $(LIBS)

test/benchmark: $(addprefix src/, $(SRC)) test/benchmark.c
	$(CC) -g -o test/benchmark $^ $(OPT_FLAGS) $(LIBS)

clean: 
	rm --f test/test test/benchmark test/test_fft lib/libufhe.so
