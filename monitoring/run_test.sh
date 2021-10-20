#!/usr/bin/env bash


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

  docker run \
         -v ${PWD}/test-specs:/scripts  \
         --env SERVER_URL=$server_url \
         artillery-expect \
         run  /scripts/$test_file > test_output.yaml


  if grep "expect.failed" test_output.yaml; then
    echo "error found check test_output.yaml"
    exit 1
  else
    echo "SUCCESS"
    exit 0
  fi

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