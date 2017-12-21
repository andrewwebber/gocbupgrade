all: go

go:
	@go build -o ./bin/gocbupgrade github.com/andrewwebber/gocbupgrade
	@./couchbase4.sh
	@./couchbase5.sh

.PHONY: go
