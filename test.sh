#!/bin/sh

invoke() {
  sam local generate-event apigateway http-api-proxy \
    | jq "$1" \
    | sam local invoke -e -
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
