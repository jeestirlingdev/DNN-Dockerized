Import-Module "sqlps"

$smo = 'Microsoft.SqlServer.Management.Smo.'  
$wmi = new-object ($smo + 'Wmi.ManagedComputer').  

# List the object properties, including the instance names.  
$Wmi  

# Enable the TCP protocol on the default instance.  
$uri = "ManagedComputer[@Name='07929597B536']/ ServerInstance[@Name='SQLEXPRESS']/ServerProtocol[@Name='Tcp']"  
$Tcp = $wmi.GetSmoObject($uri)  
$Tcp.IsEnabled = $true  
$Tcp.Alter()  
$Tcp  

# Enable the named pipes protocol for the default instance.  
$uri = "ManagedComputer[@Name='07929597B536']/ ServerInstance[@Name='SQLEXPRESS']/ServerProtocol[@Name='Np']"  
$Np = $wmi.GetSmoObject($uri)  
$Np.IsEnabled = $true  
$Np.Alter()  
$Np  

# Get a reference to the ManagedComputer class.  
CD SQLSERVER:\SQL\07929597B536
$Wmi = (get-item .).ManagedComputer  
# Get a reference to the default instance of the Database Engine.  
$DfltInstance = $Wmi.Services['MSSQL$SQLEXPRESS']  
# Display the state of the service.  
$DfltInstance  
# Stop the service.  
$DfltInstance.Stop();  
# Wait until the service has time to stop.  
# Refresh the cache.  
$DfltInstance.Refresh();   
# Display the state of the service.  
$DfltInstance  
# Start the service again.  
$DfltInstance.Start();  
# Wait until the service has time to start.  
# Refresh the cache and display the state of the service.  
$DfltInstance.Refresh(); $DfltInstance  


Invoke-Sqlcmd -Query "SELECT GETDATE() AS TimeOfQuery;" -ServerInstance ".\SQLExpress"

