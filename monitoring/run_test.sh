#!/bin/ash
# This runs inside renciorg/artillery which is alpine-based (ash)

# stop test if any of the steps fail -x
set -ax

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

  export SERVER_URL=$server_url
  export DEBUG='http*,plugin:expect'
  export ARTILLERY_PLUGIN_PATH=${PWD}/test-specs/plugins
  # https://wiki.renci.org/index.php/Kubernetes_Cloud/Sterling#Pods_can't_access_Ingress_hostnames
  export HTTPS_PROXY=http://proxy.renci.org:8080
  export HTTP_PROXY=http://proxy.renci.org:8080

  artillery run --output report.json "${PWD}/test-specs/${test_file}" > test_output.yaml
  has_error=$?
  artillery report --output report.html report.json

  if grep -i "errors.enotfound" test_output.yaml; then
    echo "server address ${server_url} not found"
    exit 1
  fi
  if grep -i "errors.etimedout" test_output.yaml; then
    echo "server address ${server_url} timed out in a test"
    exit 1
  fi


  if [ $has_error -eq 1 ]; then
    echo "error found check reports"
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
