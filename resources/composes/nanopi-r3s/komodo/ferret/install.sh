#!/usr/bin/env bash

docker compose -p komodo -f komodo/ferretdb.compose.yaml --env-file komodo/compose.env up -d
