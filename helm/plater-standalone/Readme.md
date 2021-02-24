Plater Helm Chart
---
> [Source code for plater](https://github.com/TranslatorIIPrototypes/KITCHEN/tree/master/KITCHEN/PLATER)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/plater)

This vesion of Plater can interface a [Neo4j](https://neo4j.com) or [redisGraph](https://redislabs.com/modules/redis-graph/) 
store via TRAPI interface.

### Parameters

@TODO - add values

#### Installing 
```shell script
$ helm -n <namespace> install --set app.neo4j.storage.path=/var/neo4j  --set app.neo4j.storage.pvName=plater-pv --set createPV=true <plater>  ./
```

### Uninstalling
```shell script
<.../helm/question-rewrite>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/question-rewrite>$ helm upgrade --set service.port=80 myrelease . 
```


###Other deployment commands
To render your chart without deploying:
 
```shell script
$ helm template --debug -f <values_file> myrelease .
```
​
To dry run your chart install: 
```console
$ helm install -f <values_file> --dry-run --debug myrelease .
```

 