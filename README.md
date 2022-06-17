# Translator-devops
Repository for deployment artifacts for several translator tools.

Please browse into each directory for instructions to install the
services using helm.


## Prerequisites
- Kubernetes 1.12+
- Helm 3.5.1


### Decrypting the repo 

This repo contains values files that are setup to decrypt transparently through 
[git-crypt](https://github.com/AGWA/git-crypt).

###### Steps 
**NOTE**: Insure "git config --global core.autocrlf true" is in effect. 
1. Install [git-crypt](https://github.com/AGWA/git-crypt)
2. Get ncats-git-crypy.key.asc and corresponding passphrase from repo maintainers securely 
3. ```shell
   cd ~/helm/
   gpg --decrypt ncats-git-crypt.key.asc | git-crypt unlock -
   ```
After the above steps repo shall encrypt/decrypt transparently on pull/push.

##### ITRB Docs

Please refer to [ITRB-Pattern.md](./ITRB-Pattern.md) for deployment strategy.