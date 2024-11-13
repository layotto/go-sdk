#!/usr/bin/env bash

set -e
echo "" > cover.out
echo "test go-sdk"
go test -count=1 -failfast -timeout 120s $(go list ./... | grep -v runtime) -coverprofile cover.out -covermode=atomic
cat cover.out >> ../../cover.out
cd ../..
