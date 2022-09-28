Function Install-Service {
     param(
        [Parameter(Mandatory=$true)][string]$serviceName ,
        [Parameter(Mandatory=$true)][string]$serviceExecutable ,
        [Parameter(Mandatory=$false)][string]$serviceExecutableArgs ,
        [Parameter(Mandatory=$false)][string]$serviceAppDirectory,
        [Parameter(Mandatory=$false)][string]$serviceDescription,
        [Parameter(Mandatory=$false)][string[]]$serviceAppEnvironmentExtra,
        [Parameter(Mandatory=$false)][string]$serviceAppStdout,
        [Parameter(Mandatory=$false)][string]$serviceAppStderr
    )

    $env:PATH = "${env:PATH};" + [System.Environment]::GetEnvironmentVariable('PATH','user')
    $testNSSM = (Get-Command nssm -ErrorAction SilentlyContinue).Path
    if ($testNSSM -eq $null) {
        Write-Host Error nssm not found -foreground "red"
        exit 1
    }
    $NSSMPath = (Get-Item (Get-Command nssm).Path).DirectoryName

    Write-Host Installing service $serviceName -foreground "green"
    Write-Host "NSSM path:" $NSSMPath
    Write-Host "Servicename:" $serviceName
    Write-Host "Service executable:" $serviceExecutable
    Write-Host "Service executable args:" $serviceExecutableArgs
    Write-Host "Service app directory:" $serviceAppDirectory
    Write-Host "Service description:" $serviceDescription
    Write-Host "Service environment:" $serviceAppEnvironmentExtra
    Write-Host "Service sdtout:" $serviceAppStdout
    Write-Host "Service stderr:" $serviceAppStderr

    push-location
    Set-Location $NSSMPath

    $service = Get-Service $serviceName -ErrorAction SilentlyContinue

    if($service)
    {
        Write-host service $service.Name is $service.Status
        Write-Host Removing $serviceName service
        &.\nssm.exe stop $serviceName
        &.\nssm.exe remove $serviceName confirm
    }

    Write-Host Installing $serviceName as a service
    &.\nssm.exe install $serviceName $serviceExecutable $serviceExecutableArgs

    # setting app directory
    if($serviceAppDirectory)
    {
        Write-host setting app directory to $serviceAppDirectory -foreground "green"
        &.\nssm.exe set $serviceName AppDirectory $serviceAppDirectory
    }

    # setting app description
    if($serviceDescription)
    {
        Write-host setting app directory to $serviceDescription -foreground "green"
        &.\nssm.exe set $serviceName DESCRIPTION $serviceDescription
    }

    # setting app env
    if($serviceAppEnvironmentExtra)
    {
        Write-host setting app env to $serviceAppEnvironmentExtra -foreground "green"
        &.\nssm.exe set $serviceName AppEnvironmentExtra $serviceAppEnvironmentExtra
    }

    # setting app logs
    if($serviceAppStdout)
    {
        Write-host setting app logs to $serviceAppStdout -foreground "green"
        &.\nssm.exe set $serviceName AppStdout $serviceAppStdout
    }

    # setting app logs
    if($serviceAppStderr)
    {
        Write-host setting app logs to $serviceAppStderr -foreground "green"
        &.\nssm.exe set $serviceName AppStderr $serviceAppStderr
    }

    #start service right away
    &.\nssm.exe start $serviceName
    pop-location
}

$prevPwd = $PWD
Set-Location -ErrorAction Stop -LiteralPath $PSScriptRoot

try {
    $Servicename = "PyrsiaService"
    $ServiceDisplayName = "PyrsiaService"
    $Description = "Pyrsia Service"
    $BinaryPath = "${PWD}\pyrsia_node.exe"
    $StartupType = "auto"
    $serviceAppDirectory = $PWD
    $serviceAppEnvironmentExtra = "RUST_LOG=pyrsia=debug", "DEV_MODE=on"
    $serviceAppStdout = "${PWD}\pyrsia_logs.txt"
    $serviceAppStderr = "${PWD}\pyrsia_logs.txt"

    Install-Service -serviceName $Servicename -serviceExecutable $BinaryPath -serviceAppDirectory $serviceAppDirectory -serviceDescription $Description -serviceAppEnvironmentExtra $serviceAppEnvironmentExtra -serviceAppStdout $serviceAppStdout -serviceAppStderr $serviceAppStderr
} finally {
    $prevPwd | Set-Location
}
