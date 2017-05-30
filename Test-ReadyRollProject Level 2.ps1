Function Test-ReadyRollProject
{
    param(
        [parameter(Mandatory = $true)][string]$ProjectPath,        
        [parameter(Mandatory = $true)][string]$TestPath,
        [parameter(Mandatory = $true)][string]$Target
    )

    $TestFiles = Get-ChildItem $TestPath

    #Include the Invoke-Parallel function.
    . "$PSScriptRoot/Invoke-Parallel/Invoke-Parallel/Invoke-Parallel.ps1"

    Write-Output("Deploying project to " + $Target)

    & "$ProjectPath\DeployPackageWrapper.ps1" "$Target" 'RR_Test' '\var\opt\mssql\data' '\var\opt\mssql\data' '\var\opt\mssql\backup' '140' $FALSE | Out-Null

    Write-Output("Running tests in $TestPath")

    $TestFiles | Invoke-Parallel -ImportFunctions -ImportVariables -ImportModules -Quiet {
        $TestFileName = $_.Name
        $TestFile = $TestPath + "\" + $TestFileName

        Write-Output("Running test $TestFile against $Target")
        try {

            Invoke-Pester -Script @{ Path = $TestFile; Parameters = @{ Server = $Target; InstanceLabel = $Target; Username = 'sa'; Password = 'P455word1' };} -PassThru -Tag $Target -Show Summary -OutputFile "C:\Temp\Output\$TestFileName results for $Target.txt" -OutputFormat NUnitXML
        }
        catch {
            Write-Error ("Failed to invoke Pester on $Target. " + $_)
        }
    }
}