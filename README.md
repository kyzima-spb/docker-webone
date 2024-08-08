# WebOne HTTP 1.x proxy in container

Container with [WebOne](https://github.com/atauenis/webone) -
HTTP 1.x proxy that makes old web browsers usable again in the Web 2.0 world by [Alexander Tauenis](https://github.com/atauenis).

- [How to start a container?](#how-to-start-a-container)
  - [How to run a container as another user?](#how-to-run-a-container-as-another-user)
  - [How to limit resource usage?](#how-to-limit-resource-usage)
- [How to create a custom image?](#how-to-create-a-custom-image)
  - [How to change WebOne version?](#how-to-change-webone-version)
  - [How to change .NET version?](#how-to-change-net-version)

## How to start a container?

The value of the `DefaultHostName` option is automatically calculated
as the IP address of the container in the Docker network or as the IP address of the host machine:

```shell
# Using the host machine's network
docker run -d --name webone_1 \
    --network host \
    --restart unless-stopped \
    kyzimaspb/webone

# Or in a custom bridge network with port forwarding:
docker network create webone
docker run -d --name webone_1 \
    --network webone \
    -p "8080:8080" \
    --restart unless-stopped \
    kyzimaspb/webone
```

To view the WebOne log, use the command:

```shell
docker logs -f webone_1
```

To use custom settings, mount the directory or file to the mount point `/opt/webone/webone.conf.d`.
A numeric prefix in the file name can be used to set the priority of configurations:

```shell
docker run -d --name webone_1 \
    --restart unless-stopped \
    --network host \
    -v "./custom.conf:/opt/webone/webone.conf.d/100_custom.conf:ro" \
    kyzimaspb/webone

docker run -d --name webone_1 \
    --restart unless-stopped \
    --network host \
    -v "./webone.conf.d:/opt/webone/webone.conf.d:ro" \
    kyzimaspb/webone
```

### How to run a container as another user?

The image is not user-specific.
If you want to run as a different user, use the `-u` argument of the docker run command
or other built-in capabilities:

```shell
docker run -d --name webone_1 \
    --network host \
    --restart unless-stopped \
    -u 1001:1001 \
    kyzimaspb/webone
```

### How to limit resource usage?

You can use all resource limits available for the docker run command. For example, limit the amount of RAM:

```shell
docker run -d --name webone_1 \
    --network host \
    --restart unless-stopped \
    -m 512M \
    kyzimaspb/webone
```

## How to create a custom image?

### How to change WebOne version?

The `WEBONE_VERSION` build argument allows you to specify the version of WebOne:

```shell
git clone https://github.com/kyzima-spb/webone.git
docker build \
    --build-arg WEBONE_VERSION=0.16.0 \
    -t webone \
    -f ./docker/Dockerfile \
    ./docker/root
```

### How to change .NET version?

The `DOTNET_VERSION` build argument allows you to specify the version of .NET SDK.
The value is part of the `${DOTNET_VERSION}-alpine${ALPINE_VERSION}` tag.
Available tags can be viewed on the [official Microsoft website](https://mcr.microsoft.com/product/dotnet/sdk/tags):

```shell
git clone https://github.com/kyzima-spb/webone.git
docker build \
    --build-arg DOTNET_VERSION=7.0 \
    -t webone \
    -f ./docker/Dockerfile \
    ./docker/root
```
