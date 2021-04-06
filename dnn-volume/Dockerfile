# escape=`

FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-20H2
# was microsoft/dotnet-framework:4.7.1-windowsservercore-1709

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Add-WindowsFeature Web-Server; `
    Add-WindowsFeature NET-Framework-45-ASPNET; `
    Add-WindowsFeature Web-Asp-Net45; `   
    Invoke-WebRequest https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.1/ServiceMonitor.exe -OutFile C:\ServiceMonitor.exe
    #Remove-Item -Recurse C:\inetpub\wwwroot\*; ` 

# Download Roslyn nupkg and ngen the compiler binaries
RUN Invoke-WebRequest -Uri https://api.nuget.org/packages/microsoft.net.compilers.2.3.1.nupkg -OutFile C:\microsoft.net.compilers.2.3.1.zip ; `	
    Expand-Archive -Path c:\microsoft.net.compilers.2.3.1.zip -DestinationPath c:\RoslynCompilers ; `
    Remove-Item c:\microsoft.net.compilers.2.3.1.zip -Force ; `
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\csc.exe /ExeConfig:c:\RoslynCompilers\tools\csc.exe | `
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\vbc.exe /ExeConfig:c:\RoslynCompilers\tools\vbc.exe  | `
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\VBCSCompiler.exe /ExeConfig:c:\RoslynCompilers\tools\VBCSCompiler.exe | `
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\csc.exe /ExeConfig:c:\RoslynCompilers\tools\csc.exe | `
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\vbc.exe /ExeConfig:c:\RoslynCompilers\tools\vbc.exe | `
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\VBCSCompiler.exe  /ExeConfig:c:\RoslynCompilers\tools\VBCSCompiler.exe ;

ENV ROSLYN_COMPILER_LOCATION c:\\RoslynCompilers\\tools

# make install files accessible
ADD wwwroot /inetpub/wwwroot/
WORKDIR /inetpub/wwwroot
#VOLUME wwwroot:C:\inetpub\wwwroot\

EXPOSE 80

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]