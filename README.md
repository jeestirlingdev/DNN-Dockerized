# DNN-Dockerized
This repository is a fork of the orginal DNN-Dockerized repo. You can find the original [ReadMe here](ReadMeOriginal.me)

## Notes on this fork

This fork of DNN-Dockerized accommodates several changes in Microsoft's approach to Docker on Windows and SQL Server in particular.

This form uses a comnination of Dockerfiles and `docker-compose`. While `docker-compose` is a common way to script container deployment, Microsoft's documentation typically uses the `docker` command line for example code. Translating between these two methods is not always straightforward.

# Deployment options

Two options for deploying DNN are included

- `\remotedb` for use with an existing SQL Server instance
- `\localdb` to install SQL Server Express as well as the DNN front end

# \remotedb
This folder contains a single image for the IIS server. In order to run DNN a SQL Server database needs to be accessible elsewhere on the network. See [[SQL Server in Linux]].

## IIS server: dnn-volume-mini
The revised container is just an IIS server with .NET enabled. Ensure the image used is compatible with your host OS.

The \wwwroot folder is mounted as \inetpub\wwwroot in the IIS Server container. This allows you to interact with it via the host OS. **Note: grant access to the shared folder to EVERYONE** within the host system. *This is not appropriate for systems exposed on the network*

### Docker networking
The container requires access to the wider internet in order to build a DNN install, even though the site itself is only accessible via `localhost`. *This is because the requred `.dll`s are downloaded automatically*. This is achieved through a docker *bridge* network which may need to be set up within your Windows docker configuration. 

Networking for Windows containers is beyond the scope of the readme and will depend on what, if any, Hyper-V network configuration you have on your host machine. Microsoft's advice is to attach to the `nat` network that is created automatically which allows connection to the container via `http://localhost` and *should* allow access to the wider internet from the container. However I found I needed to explicitly connect to an existing Hyper-V virtual switch with an external network connection. The switch appears in `docker network ls` as a `transparent` network.

### Managing the IIS server
The Microsoft container image includes an IIS instance set up to server a *Default Web Site* from `c:\inetpub\wwwroot` on the container. The `docker-compose` file mounts `wwwroot` from the host allowing you to interact with the website root.

As the container has not GUI it is not possible to manage IIS through the usual IIS Manager interface, however you can use command line tools from the container command line (In Docker Desktop open the running container and choose *Exec*)
- **NOTE** `IISRESET /STOP` will terminate the container
- To *stop* the website `%systemroot%\system32\inetsrv\APPCMD STOP site "Default Web Site"`
- To *start* the website `%systemroot%\system32\inetsrv\APPCMD START site "Default Web Site"`
- To change the directory served by the website (e.g. from a subfolder in *wwwroot*)
  - stop the website
  - `%systemroot%\system32\inetsrv\APPCMD set site /site.name:"Default Web Site" /application[path='/'].virtualDirectory[path='/'].physicalPath:"C:\inetpub\wwwroot\subfolder"` (where `"C:\inetpub\wwwroot\subfolder"` is the new location on the container filesystem)
  - start the website

### Installing DNN
1. remove the `default.htm` placeholder file
2. unzip the installer package into the \wwwroot folder
3. open `http://localhost` and run the DNN installer as usual

### Notes on running IIS on windows containers

- [How To Set Up an IIS Web Site on Windows Server Containers](https://mcpmag.com/articles/2019/11/20/iis-on-windows-server-containers.aspx)
- [How to get started with IIS on Docker](https://blog.56k.cloud/how-to-get-started-with-iis-on-docker/)

Microsoft's .NET Framework containers

- [GitHub repo of samples](https://github.com/microsoft/dotnet-framework-docker/blob/main/samples/README.md)
- [ASP.NET Docker Sample](https://github.com/microsoft/dotnet-framework-docker/blob/main/samples/aspnetapp/README.md)

# \localdb

This folder contains a docker-compose definition that will launch two Windows containers
- an IIS server *dnn-volume-mini*
- a SQL Server container *mssql-server-windows-express*

Lauch with `docker-compose up [d]` which will create both containers with the SQL Server container accessible to the frontend container.

## IIS server: dnn-volume-mini
This is identical to the container in `\remotedb` above.

The networking requirements are simpler as the SQL server container should already be accessible as it will be added to the same default network as the IIS server container.

## SQL Server container: mssql-server-windows-express
Microsoft now only actively supports using a Linux container for SQL Server, however there is a SQL Server 2017 repo that uses severcore at https://github.com/microsoft/mssql-docker/tree/master/windows. This fork uses the Dockerfile and start.ps1 for the SQL Server Express option found there with the following changes:
* update the base image to the current MS repository, mcr.microsoft.com/windows/servercore:*TAG*
   * When deploying your own version choose the TAG that matches the OS of the [Windows OS](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility) hosting the containers
   * update the sql_express_download_url as necessary to get the SQL Server installer
* update ACCPET_EULA variable to `Y`
* hard code the sa password into the Dockerfile rather than refering to a host machine file, *this is clearly not suitable in an environment where the containers will be accessible over your network*.

The docker compose file adds a volume for the database files and passes an environment variable, *attach_dbs*, attach these to the SQL Server instance. This allows the database to persist after each reboot. The approach is taken from [Bob walker's blog post](https://octopus.com/blog/running-sql-server-developer-install-with-docker). 

### Connecting to the SQL Server 
On the Docker host machine you can connect to the SQL Server instance with SQLCMD, SSMS or Azure Data Studio using *localhost*.

From the IIS Server container (and the DNN instance hosted on it) you can use the *hostname* specified in the docker-compose file, i.e. **mssqldocker** *(I have found this unreliable)*

You can also use SQL Server container IP address. You can find the IP address by opening a command prompt within the container and using *ipconfig*. The Docker command for gettng the IP address of any container:

```
docker ps -a
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' CONTAINERID
```
Where *CONTAINERID* is the container ID of your SQL Server container. *(I have found this more reliable but inconvenient if the container IP address changtes)*

TODO: a more robust Docker network configuration should solve these problems