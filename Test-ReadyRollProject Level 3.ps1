
Function Test-ReadyRollProject
{
    param(
        [parameter(Mandatory = $true)][string]$ProjectPath,        
        [parameter(Mandatory = $true)][string]$TestPath,
        [parameter(Mandatory = $false)][string[]]$SQLServerVersions = 'latest'
    )

    $TestFiles = Get-ChildItem $TestPath

    #Include the Invoke-Parallel function.
    . "$PSScriptRoot/Invoke-Parallel/Invoke-Parallel/Invoke-Parallel.ps1"

    $VersionCount = $SQLServerVersions.Count

    Write-Output("Spinning up container(s) for $VersionCount different version(s) of SQL Server.")

    $SQLServerVersions | Invoke-Parallel -ImportFunctions -ImportVariables -ImportModules -Quiet {

        $TaggedImage = "microsoft/mssql-server-windows:$_"

        Write-Output("Spinning up $TaggedImage container.")

        $ContainerID = docker run -d --rm -e SA_PASSWORD=P455word1 -e ACCEPT_EULA=Y $TaggedImage

        $ContainerIP = docker inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' $ContainerID

        #wait for SQL Server to come up
        $Started = $false
        do
        {
            $Logs = docker exec -it $ContainerID powershell "cd 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log'; cat ERRORLOG"   
            if ($Logs -like "*Recovery is complete*")
            {
                $Started = $true
            }
            else
            {
                Start-sleep 2
            }
        }
        until($Started -eq $true)

        Write-Output("Deploying project to " + $ContainerIP)

        & "$ProjectPath\DeployPackageWrapper.ps1" "$ContainerIP" 'RR_Test' '\var\opt\mssql\data' '\var\opt\mssql\data' '\var\opt\mssql\backup' '140' $FALSE | Out-Null

        Write-Output("Running tests in $TestPath")

        $TestFiles | Invoke-Parallel -ImportFunctions -ImportVariables -ImportModules -Quiet {
            $TestFileName = $_.Name
            $TestFile = $TestPath + "\" + $TestFileName

            Write-Output("Running test $TestFile against $ContainerIP")
            try {

                Invoke-Pester -Script @{ Path = $TestFile; Parameters = @{ Server = $ContainerIP; InstanceLabel = $ContainerIP; Username = 'sa'; Password = 'P455word1' };} -PassThru -Tag $ContainerIP -Show Summary -OutputFile "C:\Temp\Output\$TestFileName results for $ContainerIP.txt" -OutputFormat NUnitXML
            }
            catch {
                Write-Error ("Failed to invoke Pester on $ContainerIP. " + $_)
            }
            finally {
                $a = docker stop $ContainerID 
            }
        }

    } # Invoke-Parallel

} # Test-ReadyRollProject