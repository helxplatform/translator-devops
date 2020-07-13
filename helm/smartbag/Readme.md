Smartbag Helm Chart
---
> [Source code for SmartBag](https://github.com/ncats-tangerine/smartBag)
> [Docker image](https://hub.docker.com/repository/docker/renciorg/smartbag_ctd)
Smartbag is a tool to expose tablular data in restful api. More information can be found [here](https://github.com/ncats-tangerine/smartBag).

#### Installing on kubernetes

Following instructions on the repo's [readme](https://github.com/ncats-tangerine/smartBag) we generate a folder with the output set of files. 

Then we mount this to a volume by adjusting `storage.path` in `values.yaml`.

Run 
```shell script
$ helm -n <your-namespace> install smartbag-x .
```