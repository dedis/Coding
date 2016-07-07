#Travis

How to install a travis-docker locally to find hidden bugs...

First install docker as to how it is described in

https://docs.docker.com/engine/installation/

Then fetch and run the docker-image, storing a local copy in `localtravis`

```bash
docker run -it --name localtravis quay.io/travisci/travis-go /bin/bash
su - travis
gimme 1.6 >> .bashrc
echo "export GOPATH=~/go" >> .bashrc
mkdir go
```

Now you can install whatever you wish into the go-directory and use `go get` or whatever.

Once you quit the docker, you can start the same docker-image using

```bash
docker start -ai localtravis
su - travis
```

For checking what docker-images are stored, use

```bash
docker ps -a
```