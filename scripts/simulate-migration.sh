#!/usr/bin/env bash
# ============================================================================
set -e
SOURCE="${1:?Usage: $0 SOURCE_BUCKET DEST_BUCKET}"
DEST="${2:?Usage: $0 SOURCE_BUCKET DEST_BUCKET}"
echo "Simulating migration: gs://${SOURCE}/ -> gs://${DEST}/"
echo "Creating a test file in source..."
echo "Migration test $(date)" | gsutil cp - "gs://${SOURCE}/test-data/migration-test.txt"
echo "Copying (this is what Storage Transfer Service does under the hood)..."
gsutil cp "gs://${SOURCE}/test-data/migration-test.txt" "gs://${DEST}/test-data/"
echo "Contents of destination bucket:"
gsutil ls "gs://${DEST}/"
echo "Done. Check destination bucket in console or: gsutil ls gs://${DEST}/"
