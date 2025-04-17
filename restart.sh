#!/bin/bash

set -e
docker compose -p ai-mirror-allinone down
docker compose pull
docker compose -p ai-mirror-allinone up -d --remove-orphans