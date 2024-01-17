#!/bin/sh

invoke() {
  sam local generate-event apigateway http-api-proxy | jq "$1" | sam local invoke -e -
}

invoke '.rawPath="/"|.requestContext.http.method="GET"'
