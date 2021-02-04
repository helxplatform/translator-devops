Smartbag Helm Chart
---
> [Source code for SmartBag](https://github.com/ncats-tangerine/smartBag)
> [Docker image](https://hub.docker.com/repository/docker/renciorg/smartbag_ctd)
Smartbag is a tool to expose tablular data in restful api. More information can be found [here](https://github.com/ncats-tangerine/smartBag).

#### Installing on kubernetes

Following instructions on the repo's [readme](https://github.com/ncats-tangerine/smartBag) we generate a folder with the output set of files. 

Then we mount this to a volume by adjusting `storage.path` in `values.yaml`.

#### Parameters

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `replicaCount` | Web server replica count   | `1`
| `image.repository` |  The following are other versions of this image: `renciorg/smartbag_bicluster_maseqdb` `renciorg/smartbag_ctd` `renciorg/smartbag_gtex` `renciorg/smartbag_gtex` `renciorg/smartbag_foodb` | `renciorg/smartbag_bicluster`
| `image.tag` | Web server image tag  | `latest`
| `nameOverride` | Release name override  | `nil`
| `fullnameOverride` |  Release fullname override  | `nil`
| `service.type` | Web server kubernetes service type | `ClusterIP`
| `service.port` | Web server kubernetes service port  | `80`
| `storage.size` | Storage size  | `1Gi`
| `createPV` | Boolean to specify to create pv.  | `nil`
| `createPVC` | Boolean to specify to create pvc.  | `nil`
| `pvcName` | PVC name  | `nil`
| `ingress.host` | Ingress DNS host  | `nil`
| `ingress.class` |  Ingress class | `nil`


### Installing 

Run 
```shell script
$ helm -n <your-namespace> install smartbag-x .
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
