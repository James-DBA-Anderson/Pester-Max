Function Test-ReadyRollProject
{
    param(
        [parameter(Mandatory = $true)][string]$ProjectPath,        
        [parameter(Mandatory = $true)][string]$TestPath,
        [parameter(Mandatory = $true)][string]$Target
    )

    $TestFiles = Get-ChildItem $TestPath

    Write-Output("Deploying project to " + $Target)

    & "$ProjectPath\DeployPackageWrapper.ps1" "$Target" 'RR_Test' '\var\opt\mssql\data' '\var\opt\mssql\data' '\var\opt\mssql\backup' '140' $FALSE 

    Write-Output("Running tests in $TestPath")
    try {

        Invoke-Pester -Script @{ Path = $TestPath; Parameters = @{ Server = $Target; InstanceLabel = $Target; Username = 'sa'; Password = 'P455word1' };} -PassThru -Tag $Target -Show Summary -OutputFile "C:\Temp\Output\$TestFileName results for $Target.txt" -OutputFormat NUnitXML
    }
    catch {
        Write-Error ("Failed to invoke Pester on $Target. " + $_)
    }
}