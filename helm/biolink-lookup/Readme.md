Biolink Lookup Helm Chart
---
> [Source code for Biolink lookup](https://github.com/TranslatorIIPrototypes/bl_lookup)
>
> [Biolink lookup Docker image](https://hub.docker.com/repository/docker/renciorg/bl_lookup)


The following chart deploys [Biolink lookup](https://github.com/TranslatorIIPrototypes/bl_lookup). There are 
two apps in that this deployment is capable deploying. 

To deploy Bionames : 
```shell script
$ helm -n <your-namespace> install bl-lookup . 
```

Service type and port can be configure through `values.yaml` or `--set` parameters.