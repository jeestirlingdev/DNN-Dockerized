# DNN-Dockerized
In this repository you can find the docker recipes necessary to run the DNN version community on dockerized Windows containers.

## Instructions
### Prepare the Docker host

1. Install Docker containers in your Windows OS
    1. if you have WSL installed and Docker is using Linux containers you must change the Docker daemon to use Windows containers
    1. Linux and Windows containers can co-exist but run in separate contexts
1. Clone this repository.

### Create the containers
1. Navigate to the root of the repository
 ```
$ cd DNN-Dockerized
```
2. Build the SQL Server and Web Server containers
    1. if you are downloading the Windows Server images for the first time this will be a **slow** process
 ```
$ docker-compose up
```
1. When the containers are running open your browser at http://localhost. This will show the static placeholder in /dnn-volume-mini/wwwroot

### Install DNN
4. Unzip the DNN install package into the /dnn-volume-mini/wwwroot folder
1. Open your browser at http://localhost and run the DNN installer
1. To connect to the database need to use its IP address, *note this changes with each build* *might be able to use name if make it sensible*

```
docker ps -a
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' CONTAINERID
```
Where *CONTAINERID* is the container ID of your SQL Server container

## Notes on this fork
This fork of DNN-Dockerized accommodates several changes in Microsoft's approach to Docker on Windows

### New SQL Server container: mssql-server-windows-express
Microsoft now promotes a Linux container for SQL Server, however there is a SqQL Server 2017 repo that uses severcore at https://github.com/microsoft/mssql-docker/tree/master/windows. This repo uses the Dockerfile and start.ps1 for the SQL Server Express option found there with the following changes:
* update the base image to the current MS repository, mcr.microsoft.com/windows/servercore:*TAG*
   * When deploying your own version choose the TAG that matches the OS of the [Windows OS](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility) hosting the containers
   * update the sql_express_download_url as necessary to get the SQL Server installer
* update ACCPET_EULA variable to Y
* hard code the sa password into the Dockerfile rather than refering to a host machine file, *this is clearly not suitable in an environment where the containers will be accessible over your network*.

### IIS server: dnn-volume-mini
The revised container is just an IIS server with .NET enabled. Again, ensure the image used is compatible with your host OS.

The \wwwroot folder is mounted as \inetpub\wwwroot in the IIS Server container. This allows you to interact with it via the host OS. **Note: grant access to the shared folder to EVERYONE** within the host system.

### Notes on running IIS on windows containers
* https://mcpmag.com/articles/2019/11/20/iis-on-windows-server-containers.aspx
* https://blog.56k.cloud/how-to-get-started-with-iis-on-docker/

Microsoft's .NET Framework containers (assume these have IIS)
* https://github.com/microsoft/dotnet-framework-docker/blob/main/samples/README.md
* [ASP.NET Docker Sample](https://github.com/microsoft/dotnet-framework-docker/blob/main/samples/aspnetapp/README.md)

