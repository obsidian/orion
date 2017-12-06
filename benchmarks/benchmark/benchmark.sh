#!/bin/bash
set -e
echo "Running benchmarks"
rm $OUT_FILE
touch $OUT_FILE
for host in "$@" ; do
  echo "Test results for 'http://$host:${PORT}${TEST_ROUTE}':" | tee -a $OUT_FILE
  wrk -c 100 -d 40 http://$host:${PORT}${TEST_ROUTE} | tee -a $OUT_FILE
  echo "" | tee -a $OUT_FILE
done
