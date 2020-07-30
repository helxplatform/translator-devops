Plater Helm Chart
---
> [Source code for plater](https://github.com/TranslatorIIPrototypes/KITCHEN/tree/master/KITCHEN/PLATER)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/plater)

Plater is a tool to interface a [Neo4j](https://neo4j.com) store via REST api.

#### Installing on kubernetes

This helm chart comes with a [neo4j](https://hub.docker.com/repository/docker/renciorg/neo4jkp) and [PLATER](https://hub.docker.com/repository/docker/renciorg/plater) images.

By default, the neo4j data store is configured to use `1G` of heap and `200MB` of heap size.

To adjust this set values in the `values.yaml` file.

Volume for neo4j is of type `Host` but can it supports `nfs` by setting the value in `values.yaml`.

It is also possible to avoid creation of PV by setting `createPV` in `Values.yaml` to `false`, or this can also be done
by `--set createPV=false` in the helm install command. 
To run chart use :

```shell script
$ helm -n <namespace> install --set app.neo4j.storage.path=/var/neo4j  --set app.neo4j.storage.pvName=plater-pv --set createPV=true <plater>  ./
```

By default this chart will expect a `db.dump` present to seed neo4j with some data. To disable this behaviour set `app.neo4j.seedDB` to false.
This can be helpful to install db file directly. Run the install with `app.neo4j.seedDB` and follow the notes after the helm command executes. 
