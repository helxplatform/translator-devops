## Helm Chart
### Introduction 

This Chart can be used to install [ICEES-API](https://github.com/NCATS-Tangerine/icees-api) on a kubernetes cluster.

### Configuration

This chart has configurations for different instances of ICEES API, e.g., asthma, DILI, PCD, and covid instances, controlled and customized through `values.yaml`.

### Installing ICEES TRAPI instances

```shell script
$ helm -n <namespace> install  <release> . -f <values_file>
```

For example:

```
$ helm -n icees-dev install  icees-api-pcd-dev . -f renci-pcd-dev-values-populated.yaml 
$ helm -n icees-dev install  icees-api-dili-dev . -f renci-dili-dev-values-populated.yaml
$ helm -n icees-dev install  icees-api-asthma-dev . -f renci-asthma-dev-values-populated.yaml
$ helm -n icees-dev install  icees-api-covid-dev . -f renci-covid-dev-values-populated.yaml
$ helm -n icees-prod install  icees-api-pcd . -f renci-pcd-values-populated.yaml 
$ helm -n icees-prod install  icees-api-dili . -f renci-dili-values-populated.yaml
$ helm -n icees-prod install  icees-api-asthma . -f renci-asthma-values-populated.yaml
$ helm -n icees-prod install  icees-api-covid . -f renci-covid-values-populated.yaml
```



### Uninstalling

```shell script
$ helm -n <namespace> delete <release>
```

## Other deployment commands
To render your chart without deploying:

```shell script
$ helm template --debug -f <values_file> <my-release> .
```

To dry run your chart install: 
```shell script
$ helm install -f <values_file> --dry-run --debug <my-release> .
```
