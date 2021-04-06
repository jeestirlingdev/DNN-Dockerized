# escape=`

FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-20H2


SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN  Remove-Item -Recurse C:\inetpub\wwwroot\*; ` 
    Invoke-WebRequest https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.1/ServiceMonitor.exe -OutFile C:\ServiceMonitor.exe
    #Remove-Item -Recurse C:\inetpub\wwwroot\*; ` 

# make install files accessible
# ADD wwwroot /inetpub/wwwroot/
WORKDIR /inetpub/wwwroot
#VOLUME C:\inetpub\wwwroot

EXPOSE 80

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]