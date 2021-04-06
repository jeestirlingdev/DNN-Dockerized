# DNN-Dockerized
In this repository you can find the docker recipes necessary to run the DNN version community on dockerized Windows containers.

## Instructions
You must follow the following steps:
1. Install Docker containers in your Windows SO (Windows Server 2016 or Windows 10 Fall Creators Update) (follow official steps https://docs.docker.com/docker-for-windows/install/)
2. Clone this repository.
3. Change to folder of the DNN version you want to run.
 ```
$ cd DNN-Dockerized/dnn-platform-version
```
4. Compile compose file (docker-compose.yml) with Docker Compose in Powershell or Bash (WSL) console:
 ```
$ docker-compose up
```
6. Open your browser at http://localhost and enjoy!

## Notes
### Update MS SQL container
Microsoft now promote a Linux container for SQL Server, however there is a SqQL Server 2017 repo that uses severcore at https://github.com/microsoft/mssql-docker/tree/master/windows. The SQL Server container uses the Dockerfile and start.ps1 for the SQL Server Express option using these instructions with the following changes:
* update the base image to the current MS repository, mcr.microsoft.com/windows/servercore:20H2
* update ACCPET_EULA variable to Y
* hard code the sa password into the Dockerfile rather than refering to a host machine file

To connect to the database need to use its IP address, but changes with each build *might be able to use name if make it sensible*

```
docker ps -a
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' CONTAINERID
```

### IIS server
Need the wwwroot folder mounted as a Volume so can interact with it. The revised container is just an IIS server with .NET enabled.

Notes on running IIS on windows containers
* https://mcpmag.com/articles/2019/11/20/iis-on-windows-server-containers.aspx
* https://blog.56k.cloud/how-to-get-started-with-iis-on-docker/

Microsoft's .NET Framework containers (assume these have IIS)
* https://github.com/microsoft/dotnet-framework-docker/blob/main/samples/README.md
* [ASP.NET Docker Sample](https://github.com/microsoft/dotnet-framework-docker/blob/main/samples/aspnetapp/README.md)

Working containers
* dnn-volume uses original build of container **not used**
* dnn-volume-mini uses the MS aspnet container which has everything set up

#### dnn-volume-mini
Mounts \dnnroot folder as \inetpub\wwwroot. **Need to grant access to the shared folder to EVERYONRE** on the host system.