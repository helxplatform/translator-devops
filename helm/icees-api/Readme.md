## Helm Chart
### Introduction 

This Chart can be used to install [ICEES-API](https://github.com/NCATS-Tangerine/icees-api) on a kubernetes cluster.

### Configuration

This chart has configurations for different instances of ICEES API, e.g., asthma, DILI, PCD, and covid instances, controlled and customized through `values.yaml`.

### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
$ helm install  <my-release> . 
```

### Uninstalling

```shell script
$ helm uninstall <my-release>
```

### Upgrading

```shell script
$ helm upgrade --set ingress.class=translator ingress.host=icees-asthma.renci.org <my-release> . 
```

###Other deployment commands
To render your chart without deploying:

```shell script
$ helm template --debug -f <values_file> <my-release> .
```

To dry run your chart install: 
```shell script
$ helm install -f <values_file> --dry-run --debug <my-release> .
```
