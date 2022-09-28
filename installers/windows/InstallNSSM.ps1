Function Install-NSSM {
    $env:PATH = "${env:PATH};" + [System.Environment]::GetEnvironmentVariable('PATH','user')
    $testNSSM = (Get-Command nssm -ErrorAction SilentlyContinue).Path
    if ($testNSSM -eq $null) {
        $testScoop = (Get-Command scoop -ErrorAction SilentlyContinue).Path
        if ($testScoop -eq $null) {
            Write-Host Installing scoop -foreground "red"
            iwr -useb get.scoop.sh | iex
            Write-Host installing nssm -foreground "green"
            scoop install nssm
        } else {
            Write-Host installing nssm -foreground "green"
            scoop install nssm
        }
    }
    $NSSMPath = (Get-Item (Get-Command nssm).Path).DirectoryName
    Write-Host nssm found at $NSSMPath -foreground "green"
}
Install-NSSM
