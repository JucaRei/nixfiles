#!/usr/bin/env bash

docker compose -p komodo -f komodo/mongo.compose.yaml --env-file komodo/compose.env up -d
