#!/bin/ash
# This runs inside renciorg/artillery which is alpine-based (ash).
# It's called by run_tests.sh in parallel over every arg in job_config.txt

# Don't set -e since we need to catch errors ourselves
set -o pipefail

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
  export ARTILLERY_PLUGIN_PATH=${PWD}/test-specs/plugins
  # https://wiki.renci.org/index.php/Kubernetes_Cloud/Sterling#Pods_can't_access_Ingress_hostnames
  if [ "${DISABLE_PROXY}" == "" ]; then
    export HTTPS_PROXY=http://proxy.renci.org:8080
    export HTTP_PROXY=http://proxy.renci.org:8080
  fi
  export ARTILLERY_DISABLE_TELEMETRY=true

  mkdir -p reports
  # Write failures to a file so they can all be printed at the end
  reported_failures="reports/reported_failures.txt"
  touch $reported_failures
  report_json=$(mktemp)
  # Remove colons and slashes from file name
  report_name_slug=$(echo "${server_url}_${test_file}" | sed 's/[^a-z\.A-Z]/_/g')
  report_html="./reports/${report_name_slug}.html"

  # Run the actual test
  artillery run --output $report_json "${PWD}/test-specs/${test_file}"
  has_error=$?

  # Artillery's exit code is still zero for timeouts/errnotfound
  if grep -i "errors.enotfound" $report_json; then
    has_error=1
  fi
  if grep -i "errors.etimedout" $report_json; then
    has_error=1
  fi

  if [ $has_error -ne 0 ]; then
    echo "${server_url} ${test_file}: ERROR"
    printf "ERROR: Server ${server_url} failed on test ${test_file}:\n \
    $(grep -i 'errors.' $report_json)\n" >> $reported_failures
    # Only generate reports on error
    artillery report --output "$report_html" $report_json
    exit 1
  else
    echo "${server_url} ${test_file}: SUCCESS"
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
