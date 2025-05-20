#!/bin/bash
echo "hello"
set -e
echo "hello"

APP_NAME="eip55check"
OUTPUT_DIR="./bin"

mkdir -p "$OUTPUT_DIR"

platforms=("darwin/amd64" "darwin/arm64" "linux/amd64" "windows/amd64")

for platform in "${platforms[@]}"; do
  IFS="/" read -r GOOS GOARCH <<< "$platform"
  output_name="${APP_NAME}-${GOOS}-${GOARCH}"
  [[ "$GOOS" == "windows" ]] && output_name="${output_name}.exe"

  echo "Building for $GOOS/$GOARCH..."
  GOOS=$GOOS GOARCH=$GOARCH go build -o "${OUTPUT_DIR}/${output_name}"
done

echo "✅ Done. Binaries in $OUTPUT_DIR"
