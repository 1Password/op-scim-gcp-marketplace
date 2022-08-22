#! /bin/sh

if ! command -v docker &> /dev/null; then
  echo "docker could not be found"
  exit 1
fi

if (! docker stats --no-stream &> /dev/null); then
  echo "docker daemon not running; ensure docker is running"
  exit 1
fi
