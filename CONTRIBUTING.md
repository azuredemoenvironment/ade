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

## Using the Current Branch Deployment Scripts

When working in branch that isn't `main`, you'll need to specify a parameter
to allow the Virtual Machine deployment scripts to be found. Add the following
after your `deploy` command:

```ps
 -scriptsBaseUri 'https://raw.githubusercontent.com/azuredemoenvironment/ade/your/branch/name/scripts'
```

For example:

```ps
deploy `
  -alias 'abcdef' `
  -email 'abcdef@website.com' `
  -rootDomainName "website.com" `
  -resourceUserName 'abcdef' `
  -resourcePassword 'SampleP@ssword123!' `
  -certificatePassword 'SampleP@ssword123!' `
  -localNetworkRange '192.168.0.0/24' `
  -skipConfirmation `
  -overwriteParameterFiles `
  -scriptsBaseUri 'https://raw.githubusercontent.com/azuredemoenvironment/ade/dev/scripts'
```
