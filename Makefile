$CC ?= gcc
BUILD_DIR ?= build
SRC_DIR ?= src
TEST_DIR ?= test
MOCKS_DIR ?= ${BUILD_DIR}/test/mocks
RUNNERS_DIR ?= ${BUILD_DIR}/test/runners
TESTS_MAKEFILE = ${BUILD_DIR}/MakefileTestSupport
OBJ ?= ${BUILD_DIR}/obj
OBJ_DIR = ${OBJ}
TEST_BIN_DIR = ${BUILD_DIR}/test/bin

default: all

all: setup test ${BUILD_DIR}/main run

setup:
	mkdir -p ${BUILD_DIR}
	mkdir -p ${OBJ}
	mkdir -p ${MOCKS_DIR}
	mkdir -p ${RUNNERS_DIR}
	mkdir -p ${TEST_BIN_DIR}
	ruby scripts/create_makefile.rb

clean:
	rm -rf ${BUILD_DIR}

${BUILD_DIR}/main: ${SRC_DIR}/main.c
	${CC} $< -o $@

run:
	./build/main

-include ${TESTS_MAKEFILE}

test: setup

.PHONY: test
