﻿cls

. "C:\Projects\Pester Max\Test-ReadyRollProject Level 4.ps1"

Test-ReadyRollProject -ProjectPath 'C:\Projects\RR_Test' -TestPath 'C:\Projects\Pester Max\Tests' -SQLServerVersions 'latest', 'vnext-ctp2.0' -DegreeOfParallelisim 3

