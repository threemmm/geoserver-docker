# geoserver-docker
GeoServer-dockerfile ( GDAL plug-in + native library + Cross-Origin Resource Sharing (CORS) enabled + unlimited cryptography )

[GeoServer](http://geoserver.org) is an open source server for sharing geospatial data.
This is a docker image that eases setting up GeoServer running with a separated data directory.

The image is based on the official java:8-jre image

## Installation

This image is available as a [trusted build on the docker hub](https://registry.hub.docker.com/u/thklein/geoserver/), and is the recommended method of installation.
Simple pull the image from the docker hub.

```bash
$ docker pull thklein/geoserver
```

Alternatively you can build the image locally

```bash
$ git clone https://github.com/threeem/docker-geoserver.git
$ cd docker-geoserver
$ docker build -t "threeem/geoserver-docker" .
```

## Quick start

You can quick start the image using the command line

```bash
$ docker run --name "geoserver" -d -p 8080:8080 threeem/geoserver-docker
```

Point your browser to `http://localhost:8080/geoserver` and login using GeoServer's default username and password:

* Username: admin
* Password: geoserver

## Configuration

### Data volume

This GeoServer container keeps its configuration data at `/geoserver_data` which is exposed as volume in the dockerfile.
The volume allows for stopping and starting new containers from the same image without losing all the data and custom configuration.

You may want to map this volume to a directory on the host. It will also ease the upgrade process in the future. Volumes can be mounted by passing the `-v` flag to the docker run command:

```bash
-v /your/host/data/path:/geoserver_data
```

### Database

GeoServer recommends the usage of a spatial database

#### PostGIS container (PostgreSQL + GIS Extension)

If you want to use a [PostGIS](http://postgis.org/) container, you can link it to this image. You're free to use any PostGIS container.
An example with [kartooza/postgis](https://registry.hub.docker.com/u/kartoza/postgis/) image:

```bash
$ docker run -d --name="postgis" kartoza/postgis
```

For further information see [kartooza/postgis](https://registry.hub.docker.com/u/kartoza/postgis/).

Now start the GeoServer instance by adding the `--link` option to the docker run command:

```bash
--link postgis:postgis
```

### Using docker-compose

Instead of manually launching both containers(GeoServer & PostGIS) like described above, you can use [docker-compose](https://docs.docker.com/compose/).

```bash
$ wget https://raw.githubusercontent.com/thklein/docker-geoserver/master/docker-compose.yml
```
 
Start GeoServer using:

```bash
docker-compose up
```

And you're done.
