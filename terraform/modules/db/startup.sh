#!/bin/bash
set -e

apt-get update
apt-get install -y docker.io

systemctl start docker
systemctl enable docker

docker run \
  --name postgres \
  --restart always \
  -e POSTGRES_USER="${POSTGRES_USER}" \
  -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  -e POSTGRES_DB="${POSTGRES_DB}" \
  -p "${DB_PORT}:5432" \
  -d \
  "${DOCKER_IMAGE}"