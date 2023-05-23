# scripts

## backup-nn-redis.sh

backup-nn-redis.sh is a Bash script for checking and downloading NodeNorm Redis
instances as an encrypted Bash script. Note that the one thing this script
doesn't do is start a backup -- you should run
[BGSAVE](https://redis.io/commands/bgsave/) to start a backup and then
[LASTSAVE](https://redis.io/commands/lastsave/) to check whether the new backup
has finished before you run this script.
