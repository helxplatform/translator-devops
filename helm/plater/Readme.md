Plater Helm Chart
---
> [Source code for plater](https://github.com/TranslatorSRI/Plater)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/plater)


### Introduction 

Plater is a tool to interface a [Neo4j](https://neo4j.com) store via [TRAPI 1.0](https://github.com/NCATSTranslator/ReasonerAPI/tree/v1.0.0-beta).

This helm chart comes with a [neo4j](https://hub.docker.com/repository/docker/renciorg/neo4jkp) and [PLATER](https://hub.docker.com/repository/docker/renciorg/plater) images.



### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
<.../helm/plater>$ helm install  myrelease . 
```

### Parameters

Installation can be configured with the following parameters.

#### Basic parameters

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `replicaCount` |  Web server replica count | `1`
| `image.plater.repository` |  Web server image | `renciorg/plater-clustered`
| `image.plater.tag` |  Web server image tag | `latest`
| `image.plater.imagePullPolicy` |  Image pull policy | `Always`
| `image.neo4j.repository` | Neo4j image repository  | `renciorg/neo4jkp`
| `image.neo4j.tag` | Neo4j image tag  | `latest`
| `image.neo4j.imagePullPolicy` | Neoj4j image pull policy  | `IfNotPresent`
| `nameOverride` | Release name override  | `nil`
| `fullnameOverride` | Release full name override  | `nil`
| `service.type` | Kubernetes service type for web server.  | `ClusterIP`
| `app.port` | Web app port | `8080`
| `app.automatAddress` | This instance is to be used bind this plater instance to an automat server. | `http://automat`
| `app.neo4j.httpPort` |  Neo4j server http port | `7474`
| `app.neo4j.boltPort` | Neo4j server bolt port   | `7687`
| `app.neo4j.password` | Neo4j Password  | `neo4jkp`
| `app.neo4j.username` |  Neo4j user name | `neo4j`
| `app.neo4j.heapSize` |  Neo4j [heap size configuration](https://neo4j.com/developer/guide-performance-tuning/#_heap_sizing) | `nil`
| `app.neo4j.pageCacheSize` | Neo4j [page cache configuration](https://neo4j.com/developer/guide-performance-tuning/#_page_cache_sizing)  | `nil`
| `app.neo4j.totalMemory` | This will be used to make requests to k8s, please compute as (app.neo4j.heapSize +  app.neo4j.pageCacheSize + 1G # for os)  | `nil`
| `app.neo4j.storage.size` | Storage request size  | `20Mi`
| `app.neo4j.service.type` |  Neo4j server kubernetes of service type | `ClusterIP`

#### Data loading 

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `dataUrl` | Remote location a neo4j dump file to grab and initialize neo4j. If null neo4j will stand empty  | `nil`

#### Open api config for translator 


| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `app.openapi_config.x-translator.component` | Open api x-translator component type. | `KP`
| `app.openapi_config.x-translator.team` |  Array of team names  | `nil`
| `app.openapi_config.contact.email` |  Primary contact email.  | `default@mail.com`
| `app.openapi_config.contact.name` |  Primary contact name.  | `name`
| `app.openapi_config.contact.x-id` | Primary contact web handle.  | `link`
| `app.openapi_config.contact.x-role` |  Primary contact role | `role`
| `app.openapi_config.termsOfService` |  Terms of service url | `http://linkmissing`
| `app.openapi_config.servers` | List of server. Use <automat-dns-name>/<release-name>  | `[{'description': 'Default server', 'url': None}]`

#### Meta data configuration

This are not required. But will show up in /about endpoint of the web server.
You can add or remove any of these.

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `datasetDesc.version` |   | `nil`
| `datasetDesc.description` |   | `nil`
| `datasetDesc.dataseturl` |   | `nil`
| `datasetDesc.generatorCode` |   | `nil`
 
 
### Uninstalling
```shell script
<.../helm/plater>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/plater>$ helm upgrade --set service.port=80 myrelease . 
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


 
