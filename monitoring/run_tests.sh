#!/bin/ash
# This runs inside renciorg/artillery which is alpine-based (ash)

# Don't exit if run_test.sh fails, but do exit if there's a pipe failure
set -o pipefail

# Take every line from job_config.txt, remove comments, and run up to 8 parallel shell scripts
cat job_config.txt | grep -v "#" | xargs -P 8 -n 1 -I '{}' ash -c './run_test.sh {}'
