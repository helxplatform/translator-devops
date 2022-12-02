# Node Normalization Loader

## Deploying to RENCI

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
   $ helm install -n translator-dev -f renci-exp-values-populated.yaml node-normalization-loader .
   ```

5. This should start multiple jobs, each loading an individual file. You can track
   all their statuses on Kubernetes by running the following command:

   ```shell
   $ for p in  $(kubectl -n translator-dev get pods | grep loader | awk '{print $1}' ) ; do kubectl -n translator-dev logs --tail=5 $p | head -n 1; done
   ```

6. Once loading is complete, you can delete the loading nodes by running:

   ```shell
   $ helm uninstall -n translator-dev node-normalization-loader .
   ```

## Deploying to NCATS ITRB

- Before you deploy any of the node-normalization-loader helms to ITRB, you need to request
  that the NCATS ITRB team reinstall the redis-r3-external helm.
- For the NCATS ITRB CI instance, simply updating the values in values.yaml and publishing
  to the `develop` branch for Jenkins should automatically load these changes into ITRB's
  Redis instances.
- For the NCATS ITRB Test and Prod instance, you need to push the changes to `test` and
  `master` and then ask NCATS ITRB to (1) reinstall the redis-r3-external helm and
  (2) re-run the NodeNorm loader from this repo. Since we use the same server information
  for these loads, the existing NodeNorm instance will stop returning results when the
  redis-r3-external helm is reinstalled and then will slowly start returning correct results
  as the load continues.
