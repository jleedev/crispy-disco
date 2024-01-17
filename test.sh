#!/bin/bash
set -e

event=$(sam local generate-event apigateway http-api-proxy)

invoke() {
  (aws lambda invoke \
    --function-name MyFunction \
    --payload "$(echo "$event" | jq "$1")" \
    --cli-binary-format raw-in-base64-out \
    >(cat >&2) >/dev/null) 2>&1
}

fail() {
  printf '%s\n' "$@"
  result=1
}

result=0

jq_check() {
  response=$1
  query=$2
  expected=$3
  actual=$(echo "$response" | jq "$query")
  if [ "$actual" = "$expected" ]
  then
    printf '%s\n' "[ok]   testing $query ... $expected"
  else
    fail "[fail] expected $query to equal $expected, not $actual"
  fi
}

(
  response="$(invoke '.rawPath="/"|.requestContext.http.method="POST"')"
  jq_check "$response" .statusCode 404
  jq_check "$response" '.body|@base64d' '""'
)

(
  response="$(invoke '.rawPath="/"|.requestContext.http.method="GET"')"
  jq_check "$response" .statusCode 200
  jq_check "$response" '.body|@base64d' '"hello, world!\n"'
)

exit $result
