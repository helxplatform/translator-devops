## Node Normalization Redis

NodeNorm needs to be deployable in three (!) different ways:
1. Sometimes we need to set up a set of Redis instances, and then use
   the node-normalization-loader to load them with NodeNorm data. Once
   we've done that, we can copy the Redis backup files to https://stars.renci.org
2. Once we have Redis backups, we can load them up quickly setting up Redis
   nodes in the conventional way, but then use an initContainer to
   copy the Redis backup into the right place before the Redis node starts.
3. Finally, to load NodeNorm into ITRB, we need to create the initContainers as
   Jobs, which:
   1. Delete all the data in the configured database.
   2. Pipe the Redis backup into the configured database.
   3. Report the number of keys in the database.
   4. Complete with status "Succeeded".

#### Installation

1. 
    ```shell
    $ cd redis-r3-external
    $ helm dependency build 
    ```
2. Update 