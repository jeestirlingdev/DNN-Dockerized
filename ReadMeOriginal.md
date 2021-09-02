Original ReadMe file

# DNN-Dockerized
In this repository you can find the docker recipes necessary to run the [DNN Platform](https://github.com/dnnsoftware/Dnn.Platform) on dockerized Windows containers. The approach makes the DNN instance assets available on the Windows host so that you can
* install whatever version of DNN you require (or indeed any .NET web application) 
* update the content of the DNN instance from the host and persist between restarts

This should make it a useful development environment. 

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

$ docker compose up
```
1. This will build both the SQL Server and Web Server containers
    1. if you are downloading the Windows Server images for the first time this will be a **slow** process
    1. The SQL Server Express install is also slow 
1. When the containers are running open your browser at http://localhost. This will show the static placeholder in /dnn-volume-mini/wwwroot
1. Connect to the SQL Server instance using SSMS or Azure data studio using the *sa* account and verify the existence of the empty DNNDEV database.


### Install DNN
1. Unzip the DNN install package into the /dnn-volume-mini/wwwroot folder
1. Open your browser at http://localhost and run the DNN installer
1. To connect to the database need to use its Container ID, *note this changes with each build* *might be able to use name if make it sensible*