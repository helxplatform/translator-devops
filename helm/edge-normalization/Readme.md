Edge normalization Helm Chart
---
> [Source code for Edge normalization](https://github.com/TranslatorIIPrototypes/EdgeNormalization)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/edgenormalization)

To deploy Edge normalization service:
```shell script
$ helm -n <your-namespace> install edge-normalization .  
```

Service type and port can be configure through `values.yaml` or `--set` parameters.

  
