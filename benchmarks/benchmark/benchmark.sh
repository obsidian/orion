#!/usr/bin/env bash
touch /tmp/results.txt
for host in "$@" ; do
  echo "Test results for $host:" >> /tmp/results.txt
  wrk -c 100 -d 40 http://$host${TEST_ROUTE} >> /tmp/results.txt
  echo "" >> /tmp/results.txt
done
