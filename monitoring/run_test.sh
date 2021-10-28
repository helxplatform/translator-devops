#!/bin/bash

# stop test if any of the steps fail -x
set -axe

function help() {
    echo "
    Usage run_test.sh -t <path to test spec> -s <server url> [-h]
    "
}

function validate() {
    if [ -z $1 ] ; then
      help
      exit 1
    fi
    if [ -z $2 ]; then
      help
      exit 1
    fi
}


function run_artillery() {
  test_file=$1
  server_url=$2
  container_id=$( \
      docker run \
         -d -it \
         --env SERVER_URL=$server_url \
         --entrypoint "/bin/sh" \
         renciorg/artillery:2.0.2-2-expect-plugin
      )
  docker cp ${PWD}/test-specs/${test_file} $container_id:/test.yaml
  docker exec $container_id  artillery run /test.yaml > test_output.yaml

  if grep -i "errors.enotfound" test_output.yaml; then
    echo "server address ${server_url} not found"
    docker rm -f $container_id
    exit 1
  fi


  if grep "expect.failed" test_output.yaml; then
    echo "error found check test_output.yaml"
    docker rm -f $container_id
    exit 1
  else
    echo "SUCCESS"
    docker rm -f $container_id
    exit 0
  fi

  docker rm -f $container_id

  exit 0
}


test_spec=""
server=""

while getopts t:s:h option
do
    case "${option}"
        in
        t)test_spec=${OPTARG};;
        s)server=${OPTARG};;
        h)help
    esac
done

validate $test_spec $server

run_artillery $test_spec $server