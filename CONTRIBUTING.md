# Contributing

## Mounting ADE to the Docker Container

You can run the following command to mount your locally checked-out source to
the Docker container:

```sh
docker run \
  -it --rm --name ade \
  -v /var/run/docker.sock:/var/run/docker.sock:rw \
  -v /path/to/local/ade:/opt/ade \
  azuredemoenvironment/ade
```