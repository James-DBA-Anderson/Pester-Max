cls

# Docker basics
<# 
docker run -d --rm -e SA_PASSWORD=P455word1 -e ACCEPT_EULA=Y microsoft/mssql-server-windows

docker ps

docker inspect 

$Path = 'C:\Projects\Pester Max\Tests\SQL-Server-Service.Tests.ps1'
$ContainerIP = ''

Invoke-Pester -Script @{ Path = $Path; Parameters = @{ Server = $ContainerIP; InstanceLabel = $ContainerIP; Username = 'sa'; Password = 'P455word1' };} -PassThru -Tag $ContainerIP

docker stop 
#>







#. "C:\Projects\Pester Max\Test-ReadyRollProject Level 3.ps1"

#Test-ReadyRollProject -ProjectPath 'C:\Projects\RR_Test' -TestPath 'C:\Projects\Pester Max\Tests' -SQLServerVersions 'latest', 'vnext-ctp2.0'

