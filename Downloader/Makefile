all: build run

build:
	docker build -t downloader .

run:
	docker run -d --name downloader downloader:latest
