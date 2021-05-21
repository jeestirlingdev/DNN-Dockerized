# Running DNN and SQL Server Express in the same Windows Container

This model uses a single container for all the services. This has advantages and challenges

## Advantages
The principal advantage is that the path to the SQL Server instance is always ".". 

In the 2 container model it has proven difficult to consistently gain access the SQL Server instance from the web server instance. The most reliable connection string uses the IP address of the SQL Server container, but this changes on each restart.

## Challenges
The default resource allocation for a Windows container is on 1GB RAM and 1 CPU core. This is inadequate for running both services on one container.

There are [3 options](https://www.baeldung.com/ops/docker-memory-limit) for increasing the resources available to a Windows container
1. changing the docker-compose to version 2 and adding a memory statement
1. using a version 3 docker-compose file and specifing the resources in the *deploy* statement, however this container can then only be used with *docker swarm*
1. specifying the memory in the *docker run* command, but this ignores the docker-compose file so all the parameters need to be added to the command
    1. move the environment variables into the dockerfile
    1. include the volume and port mappings in the command

```
$ cd C:\Projects\docker\branch\DNN-Dockerized
$ docker build -m 4096m .
$ docker run -m 4096m -v 'C:\Projects\docker\branch\DNN-Dockerized\wwwroot:c:\inetpub\wwwroot' -v 'C:\Projects\docker\branch\DNN-Dockerized\db:c:\sqldata' -p 80:80 -p 1443:1443 dnn-dockerized_dnn-server
```
Note:
* *docker build* is run in the same directory as the dockerfile. Alternatively specify the full path
* even though the *docker run* command is executed in the directory the volume parameters require the full path of the host machine directory