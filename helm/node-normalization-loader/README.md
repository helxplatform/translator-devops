# Node Normalization Loader

The Node Normalization loader is capable of loading data into a Redis instance
in two ways:
1. By loading Babel compendium JSONL files
2. By loading an existing Redis database backup (RDB) file

## Loading Babel compendium JSONL files

These Helm charts can be used to load a Babel compendium into a Redis instance
for use in
[Node Normalization](https://github.com/TranslatorSRI/NodeNormalization) (NodeNorm).

1. Use the Helm chart in [../redis-r3-external](../redis-r3-external) to create a Redis
   deployment to use as a backend for a NodeNorm instance. We name the release based
   on the Babel version being used. So, when installing the 2022dec2 version of Babel to the RENCI translator-exp namespace,
   you might run:

   ```shell
   $ helm install -n translator-exp -f renci-exp-values-populated.yaml nn-redis-2022dec2 .
   ```

   (In some cases, installing this chart will fail with a
   `Operation cannot be fulfilled on resourcequotas` error. In this case, use
   `helm upgrade` instead of `helm install`.)

2. Prepare the Babel files for upload. They must be made publicly available on an HTTP
   server so that the Node Normalization loaders can download and load the files.
   For any file with more than 10 million lines, loaders work MUCH faster if the files
   are split to 10 million lines. This can be done using the split command, such as:

   ```shell
   $ split -d -l 10000000 Protein.txt Protein.txt.
   ```

3. Once the compendium and conflation files are in place, you will need to modify the
   `renci-exp-values-populated.yaml` and `values.yaml` file in this directory to:
   1. Update the URL for downloading the compendia and conflations.
   2. Update the list of files to the correct list of compendia and conflation files,
      including any splits you generated in the previous step.
   3. Update the hostnames for the Redis instances (see the values you used to create
      these instances in a previous step).
   4. Make sure that the `storageSize` is large enough to store each individual file.
   5. Make sure that the Redis instance passwords are still correct (see the values you
      used in a previous step).

4. You're ready to start loading! You should run something like:

   ```shell
   $ helm install -n translator-exp -f renci-exp-values-populated.yaml node-normalization-loader .
   ```

5. This should start multiple jobs, each loading an individual file. You can track
   all their statuses on Kubernetes by running the following command:

   ```shell
   $ for p in  $(kubectl -n translator-exp get pods | grep loader | awk '{print $1}' ) ; do kubectl -n translator-exp logs --tail=5 $p | head -n 1; done
   ```

6. Once loading is complete, you can delete the loading nodes by running:

   ```shell
   $ helm uninstall -n translator-exp node-normalization-loader
   ```

## By loading an existing Redis database backup (RDB) file

Once you have loaded the Redis databases, you can save their contents into an RDB file and use that to
start new Redis instances. The procedure for doing that is:

1. Create RDB files containing all the data in _all_ the Redis databases. The backup scripts in
   [../redis-r3-external/scripts](../redis-r3-external/scripts) should help you to do that.

2. Set up a new set of redis-r3-external databases to hold this data. (On ITRB, you will need to
   manually wipe the Redis cluster that is being used.)

3. Confirm that the NodeNormalization loader version in `./values.yaml` is updated to the latest version.

4. For the values file specific to your release (e.g. `renci-dev-values-populated.yaml`), set `mode` to
   `restore` and update the `restoreURL`s to the latest version.

5. VERY IMPORTANT: remember to update the `host_name` -- otherwise the jobs will overwrite your previous database!

6. Start the loader jobs
   (`helm install -n translator-dev -f values-populated.yaml -f renci-dev-values-populated.yaml nn-loader .`). This
   should create one job for every database.

## Updating the Redis database on ITRB

The Jenkinsfile included in this repository should have all the instructions necessary to wipe and reload the
Redis databases. Three important things to note:

1. The CLEAN\_REDIS flag can be used to clean all the Redis databases before a load. Please use this carefully!
2. The NodeNorm personnel at RENCI know how many keys to expect in every database -- please check with them to
   ensure that the database has loaded completely.
3. Once the Redis databases have been completely loaded, please create backups of the Redis databases so that
   they can restored if necessary.
