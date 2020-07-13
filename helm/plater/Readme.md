Plater Helm Chart
---
> [Source code for plater](https://github.com/TranslatorIIPrototypes/KITCHEN/tree/master/KITCHEN/PLATER)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/plater)

Plater is a tool to interface a [Neo4j](https://neo4j.com) store via REST api.

#### Installing on kubernetes

This helm chart comes with a [neo4j](https://hub.docker.com/repository/docker/renciorg/neo4jkp) and [PLATER](https://hub.docker.com/repository/docker/renciorg/plater) images.

By default, the neo4j data store is configured to use `1G` of heap and `200MB` of heap size.
It also requests resource from kubernetes cluster.

To adjust this set values in the `values.yaml` file.

Volume for neo4j is of type `Host` but can it supports `nfs` by setting the value in `values.yaml`.

It is also possible to avoid creation of PV by setting `createPV` in `Values.yaml` to `false`. But the volume claims 
would expect the persistent volume to be created before with the chart name.

To run chart use :

```shell script
$ helm -n <namespace> install plater ./
```

