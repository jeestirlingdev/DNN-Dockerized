# SQL Server in Linux

Microsoft provides ready made images for running SQL Server on a Linux docker host. See [Quickstart: Run SQL Server Linux container images with Docker](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver16&pivots=cs1-bash).

A simple *docker-compose.yml* might look like:
```yml
version: '3.9'
services:
  sql-server-express:
    image: mcr.microsoft.com/mssql/server:latest
    container_name: sql-server-express
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=SqlP@ssw0rd1
      - MSSQL_PID=Express
    ports:
      - "1433:1433"
```

Notes
- The root password would normally be provided via a .env variable or some more secure means
- `MSSQL_PID` is optional. Where ommitted the licence is *Developer*. This example sets the licence to *Express*
- ***Any databases created using this container will be lost when the container is rebuilt***, see "Using docker volumes"

## Using docker volumes

A commong approach to persisting data from a docker container is to mount a volume which will remain intact when the container is updated/rebuilt. However **SQL Server does NOT run as root** so cannot write to volumes which are mounted as root.

Notes on the Microsoft image: 

- the image  defaults to using the internal file system path `/var/opt/mssql/data` to host the /data, /logs and /secrets folders
- the SQL Server process runs as `uid=10001(mssql) gid=10001(mssql) groups=10001(mssql)` 
  - this can be verified with `docker run --rm mcr.microsoft.com/mssql/server:latest id $whoami`)

### Create a writeable volume

Based on [Running SQL Server in Linux containers on Windows using Docker Compose](https://nothing2say.co.uk/running-sql-server-in-linux-containers-on-windows-using-docker-compose-d72c13e11bfb) *Medium*

The following is one method for creating a docker volume that can be written by SQL Server:
1. Run the revised *docker-compose* below
   1. this will create the *sqldata* docker volume
   2. the SQL Server container will *exit* because the permissions do not all the start up script to write to `/var/opt/mssql/data`
2. On the host, identify the new docker volume with `docker volume list`, note the name of the volume
3. Mount the volume with a compatible Linux image and change its permissions to match the user in the Microsoft SQL Server image

```bash
docker run --interactive --mount "type=volume,source=[nameofvolume],target=/var/opt/mssql" --rm --tty ubuntu:latest chown -R 10001 /var/opt/mssql
```

- this uses the *ubuntu:latest* image which will be downloaded if necessary
- `[nameofvolume]` must match the name from  `docker volume list`
- verify that SQL Server runs as 10001

Once the volume has been updated, re-launch the SQL-Server docker-compose. This time the container should load successfully with database files added to the persistent volume.

Note: while peristent, the docker volume is not accessible directly from the host file system.

### Loading data into the container

In order to make files available to SQL Server, i.e. to restore a database, the files need to be available on the container filesystem. There are several ways to load data into the container.

The simplest option is to bind mount a folder on the host system to an existing location that is readable by the SQL Server user (*mssql*). This approach is demonstrated in the revised docker-compose below. Note `/mnt` is readable by `mssql` but is NOT writeable, so it cannot be used to export database backups, etc.

## revised *docker-compose.yml*

This compose file includes a persistent volume which must be made writeable (see "Create a writeable volume"), and a bind mount to the host file system accessible within the container as `/mnt`

```yml
version: '3.9'
services:
  sql-server-express:
    image: mcr.microsoft.com/mssql/server:latest
    container_name: sql-server-express
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=SqlP@ssw0rd1
      - MSSQL_PID=Express
    volumes:
      - /mnt/sqldataonhost:/mnt
      - sqldata:/var/opt/mssql/data
    ports:
      - "1433:1433"

volumes:
  sqldata:
```
