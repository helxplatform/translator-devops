#!/bin/ash
# This runs inside renciorg/artillery which is alpine-based (ash)

# Don't set -e since we need to catch the error ourselves
set -uo pipefail

# Take every line from job_config.txt, remove comments, shuffle to spread the load, and run up to 8 parallel shell scripts
cat job_config.txt | grep -v "#" | shuf | xargs -P 8 -n 1 -I '{}' ash -c './run_test.sh {}'
has_error=$?

echo "***** Tests complete! *****"

if [ $has_error -ne 0 ]; then
    echo "***** The following tests failed: *****"
    cat reports/reported_failures.txt
    exit $has_error
fi
