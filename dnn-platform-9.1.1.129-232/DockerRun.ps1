# Run a DNN-Platform container 
docker run -d -p 80:80 --name Hotelequia-Bot-Backend dnn-platform:9.1.1.129-232 

# Run a MSSQL-Server-Developer container
docker run -d -p 1433:1433 -e sa_password=P@ssw0rd -e ACCEPT_EULA=Y microsoft/mssql-server-windows-developer