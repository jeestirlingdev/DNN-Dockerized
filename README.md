# DNN-Dockerized
This repository is a fork of the orginal DNN-Dockerized repo. You can find the original [ReadMe here](ReadMeOriginal.me)

# Notes on this fork
This fork of DNN-Dockerized accommodates several changes in Microsoft's approach to Docker on Windows and SQL Server in particular. 

## SQL Server container: mssql-server-windows-express
Microsoft now only actively supports using a Linux container for SQL Server, however there is a SQL Server 2017 repo that uses severcore at https://github.com/microsoft/mssql-docker/tree/master/windows. This fork uses the Dockerfile and start.ps1 for the SQL Server Express option found there with the following changes:
* update the base image to the current MS repository, mcr.microsoft.com/windows/servercore:*TAG*
   * When deploying your own version choose the TAG that matches the OS of the [Windows OS](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility) hosting the containers
   * update the sql_express_download_url as necessary to get the SQL Server installer
* update ACCPET_EULA variable to Y
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

## IIS server: dnn-volume-mini
The revised container is just an IIS server with .NET enabled. Again, ensure the image used is compatible with your host OS.

The \wwwroot folder is mounted as \inetpub\wwwroot in the IIS Server container. This allows you to interact with it via the host OS. **Note: grant access to the shared folder to EVERYONE** within the host system. *again this is not appropriate for systems exposed on the network*

### Notes on running IIS on windows containers
* https://mcpmag.com/articles/2019/11/20/iis-on-windows-server-containers.aspx
* https://blog.56k.cloud/how-to-get-started-with-iis-on-docker/

Microsoft's .NET Framework containers 
* https://github.com/microsoft/dotnet-framework-docker/blob/main/samples/README.md
* [ASP.NET Docker Sample](https://github.com/microsoft/dotnet-framework-docker/blob/main/samples/aspnetapp/README.md)

