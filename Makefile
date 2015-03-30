$CC ?= gcc
BUILD_DIR ?= build
SRC_DIR ?= src
TEST_DIR ?= test

default: all

all: setup test ${BUILD_DIR}/main run

setup:
	mkdir -p ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}/mocks

clean:
	rm -rf ${BUILD_DIR}

${BUILD_DIR}/main: ${SRC_DIR}/main.c
	${CC} $< -o $@

run:
	./build/main

.PHONY: test

test: setup
	SRC_DIR=${SRC_DIR}/ ruby ./scripts/create_mocks.rb
	@echo; echo Need to add test support!
