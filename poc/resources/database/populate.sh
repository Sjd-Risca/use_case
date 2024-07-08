#!/usr/bin/env bash
HOST="backend.localhost:80"

curl -X 'POST' \
  "http://${HOST}/flights/" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "destination": "Pluto",
  "capacity": 0.1,
  "ETD": "next month"
}'

curl -X 'POST' \
  "http://${HOST}/flights/" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "destination": "Moon",
  "capacity": 400,
  "ETD": "tomorrow"
}'

curl -X 'POST' \
  "http://${HOST}/flights/" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "destination": "Moon",
  "capacity": 200.2,
  "ETD": "tomorrow"
}'

curl -X 'POST' \
  "http://${HOST}/flights/" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "destination": "Mars",
  "capacity": 10.8,
  "ETD": "Thursday"
}'


