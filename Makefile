APP_NAME := ethan

.PHONY: build run clean

build:
	go build -o cmd/$(APP_NAME)

run: build
	./cmd/$(APP_NAME)

clean:
	rm -rf bin
