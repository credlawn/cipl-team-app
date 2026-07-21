#!/bin/bash

COMMAND=$1

if [ "$COMMAND" = "run" ]; then
    echo "🚀 Starting PocketBase dev server on http://0.0.0.0:8090..."
    go run main.go serve --http="0.0.0.0:8090"
elif [ "$COMMAND" = "build" ]; then
    echo "🔨 Building Linux Production Binary (customp)..."
    GOOS=linux GOARCH=amd64 go build -o customp
    echo "✅ Linux build done! Saved as: customp"
else
    echo "Usage: ./build.sh {run|build}"
    exit 1
fi
