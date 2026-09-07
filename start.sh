#!/usr/bin/env bash

docker compose up -d \
    && docker compose exec helm bash
