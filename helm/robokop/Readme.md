Robokop Helm Chart
---

Helm chart to install ROBOKOP system on a kubernetes cluster.

### Repositories
* [ROBOKOP](https://github.com/ncats-gamma/robokop)
* [ROBOKOP-Interfaces](https://github.com/ncats-gamma/robokop-interfaces)
* [ROBOKOP-Rank](https://github.com/ncats-gamma/robokop-rank)
* [ROBOKOP-Messanger](https://github.com/ncats-gamma/messenger)


### Configuration

This chart has some most of ROBOKOP's configuration controlled through `Values.yaml`

** Below is configuration details for each aspects of ROBOKOP.

##### Chart Name
Deployment name and fullName can be overridden via the following values.

```
nameOverride: ""
fullnameOverride: ""
```


##### Mail Config
    
 Admin Email and mail server configuration.
``` 
adminEmail: *****
mail:
  server: #########
  userName: ##########
  robokopEmailAddr: ###########
```
    
##### Omnicorp 

Omnicorp service uses postgres container. By default we assume PV/PVC is administered by Cluster ADMIN, hence 
this chart will NOT create PV/PVC(s) for you. But it still requires PVC Name to be set. 

If Create PV/PVC is set to `true` , `storageSize` is required. 

```
omnicorpPostgres:
  image:
    repository: postgres
    tag: latest
  port: 5432
  serviceType: ClusterIP
  dbName: robokop
  dbUser: murphy
  pvcName: ####REQUIRED####
  createPVC: false
  createPV: false
  storageSize: ###REQUIRED_IF_CREATE_PVC_TRUE###
```

##### ROBOKOP-Ranker
Ranker pod contains only ranker container. It runs web service on specified `port` and Supervisord admin UI on port 
`supervisorPort`.

```
ranker:
  image:
    repository: renciorg/robokop_ranker
    tag: "2.0"
  serviceType: ClusterIP
  port: 6011
  supervisorPort: 9003
```

##### ROBOKOP-MANAGER

Manager Pod runs a few services:
 * UI web server on `manager.webPort`
 * Supervisor webUI on `manager.supervisorPort`
 * GraphQL on `manager.graphQLPort`
 * Redis service for Pubmed caching on `manager.pubmedCache.port`
 * Postgres for User data on `manager.postgres.port`

###### Memory configuration 
To avoid unexpected memory usages and crashes we recommend configuring services with resource limits.
`PubmedCache` container can be configured as shown below in `manager.pubmedCache.resources`.
GraphQL (postgraphile) service runs on a NodeJS server. By default NodeJS has 512Mb limit on processes. 
This limit can be configured via `manager.nodeJS.nodeMemory` (Value is in MBs). Please adjust 
`manager.nodeJS.resources` values relative to `nodeMemory` assigned with 1Gb padding to give room for other 
manager services running on that pod. 

###### Storage
Postgres expects PVC with `manager.postgres.pvcName` to exist in the cluster by default.
PV/PVC creation is disabled for Postgres container but can be controlled via `manager.postgres.createPV` 
and `manager.postgres.createPVC` values. 
If `manager.postgres.createPVC` is set to `true`, `manager.postgres.storageSize` is required. 

```
manager:
  image:
    repository: renciorg/robokop_manager
    tag: latest
  serviceType: ClusterIP
  webPort: 8080
  supervisorPort: 9001
  graphQLPort: 6498
  pubmedCache:
    image: redis:latest
    port: 6382
    resources:
      requests:
        memory: 200Mi
      limits:
        memory: 200Mi
  # Memory config for postgraphile
  nodeJS:
    # Node server accepts size in MB only (https://nodejs.org/api/cli.html#cli_max_old_space_size_size_in_megabytes)
    nodeMemory: ####REQUIRED(eg nodeMemory: 8192)####
    # adjust following values as appropriate give 1G for there process running in
    # manager container, to avoid swapping
    resources:
      requests:
        memory: ####REQUIRED####
      limits:
        memory: ####REQUIRED####
  postgres:
    image: postgres:latest
    port: 5432
    pvcName: ####REQUIRED####
    createPV: false
    createPVC: false
    storageSize: ####REQUIRED_IF_CREATE_PVC_IS_TRUE####
```

#### ROBOKOP-Messenger

This service is depended upon by Ranker, it runs a web service on `messenger.port`.
It depends on `KnowledgeGraph`(neo4j) pod.

```
messenger:
  image:
    repository: renciorg/robokop_messenger
    tag: "2.0"
  serviceType: ClusterIP
  port: 4868
```

#### Backend Services
This Pod provides some of backend servers that other services depend on. 
RabbitMQ service UI is accessible via `backendServices.broker.webPort`.
```
backendServices:
  serviceType: ClusterIP
  celeryRedis:
    image: redis:latest
    port: 6381
    resources:
      requests:
        memory: 1Gi
      limits:
        memory: 1Gi
  broker:
    image: patrickkwang/robokop-rabbitmq
    webPort: 15672
    amqpPort: 5672
    user: murphy
  nlp:
    image: patrickkwang/robokop-nlp
    port: 9475
```

#### ROBOKOP-Interfaces

Robokop interfaces container provides interface towards neo4j. Runs
webservice on `interfaces.port` and supervisord web UI is accessible via
`interfaces.supervisorPort`.

```
interfaces:
  image:
    repository: renciorg/robokop_interfaces
    tag: latest
  port: 6011
  supervisorPort: 9002
  buildCacheImage: redis:latest
  buildCachePort: 6380
  serviceType: NodePort
```

#### Knowledge-graph (Neo4j)

Neo4j database server configurations live here. 

###### Memory

Configure heapSize via `knowledgeGraph.heapMemorySize` and pageCache size via 
`knowledgeGraph.pageCacheMemorySize`. `knowledgeGraph.resources` Values should
be set relative to heap and page cache size. Recommended to set values as  
`knowledgeGraph.heapMemorySize` + `knowledgeGraph.pageCacheMemorySize` + `1G` padding.

###### Storage

Like other Pods this one also expects a PVC name to be set via `knowledgeGraph.pvcName`.
Creation of PV/PVC can be controlled via `knowledgeGraph.createPV` and `knowledgeGraph.createPVC` values.
To seedDB from a neo4j backup file  Copy  a neo4j backup file as `db.dump` on the directory
to be mounted via the PVC, and set `knowledgeGraph.seedDB` to `true` before `helm upgrade/install` command.

```
knowledgeGraph:
  image:
    repository: renciorg/neo4jkp
    tag: latest
  port: 7474
  boltPort: 7687
  pageCacheMemorySize: 17G
  heapMemorySize: 32G
  resources:
    limits:
      memory: 50G # pagecache + heap + 1G os
    requests:
      memory: 50G
  serviceType:  ClusterIP
  createPV: false
  createPVC: false
  pvcName: ####REQUIRED####
  storageSize: ####REQUIRED_IF_CREATE_PVC_TRUE####
  seedDB: false
```
#### Requests Cache (Redis)
This is the main cache pod for ROBOKOP.
###### Memory
Memory can be configured via `requestsCache.resources`.
###### Storage
Expects a PVC name to be set via `requestsCache.pvcName`.
Creation of PV/PVC can be controlled via `requestsCache.createPV` and `requestsCache.createPVC` values.
To seedDB from a redis backup file  Copy  a redis backup file as `db.rdb` on the directory
to be mounted via the PVC, and set `requestsCache.seedDB` to `true` before `helm upgrade/install` command.
```
requestsCache:
  image:
    repository: redis
    tag: latest
  port: 6380
  serviceType: ClusterIP
  pvcName: ####REQUIRED####
  seedDB: false
  createPV: false
  createPVC: false
  storageSize:
  resources:
    limits:
      memory: 27G
    requests:
      memory: 27G
```

#### Proxy and Ingress

This helm chart has two levels paths are mainly managed by an nginx Proxy server,
sitting behind an ingress.

```
nginxProxy:
  image:
    repository: nginx
    tag: latest
  port: 80
  serviceType: clusterIP

ingress:
  enabled: true
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  host: ####REQUIRED ALWAYS USED FOR CONSTRUCTING UI####
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local
```
####Logs

Logs are all located inside this pvc. Like the other pods `logs.pvcName` is required.
But creation is optional. If `createPVC` is set to `true` , `storageSize` becomes required.
```
logs:
  pvcName: ###REQUIRED###
  storageSize:
  createPVC: false
  createPV: false
```

#### Passwords

Passwords for accessing different apis and services.
```
secrets:
  adminPassword: #################
  celeryRedisPassword: #################
  brokerPassword: #################
  omnicorpPassword: #################
  postgresPassword: #################
  pubmedCachePassword: #################
  supervisorPassword: #################
  neo4jPassword: #################
  mailServerPassword: #################
  appSecretKey: #################
  appSecretSalt: #################
  requestsCachePassword: #################
```

### Deployment

After setting appropriate values chart can be managed via helm.
##### Installation
```bash
helm -n <namespace> upgrade --install <installation-name> .
```
##### Uninstallation
```bash
helm -n <namespace> uninstall <installation-name>
```


