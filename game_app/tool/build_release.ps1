$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

function Invoke-ReleaseCommand([string]$label, [scriptblock]$command) {
  Write-Output "--- $label ---"
  & $command
  if ($LASTEXITCODE -ne 0) {
    throw "$label failed with exit code $LASTEXITCODE"
  }
}

Invoke-ReleaseCommand 'Flutter analyze' { flutter analyze }
Invoke-ReleaseCommand 'Flutter tests' { flutter test }
Invoke-ReleaseCommand 'Android release APK' { flutter build apk --release }
Invoke-ReleaseCommand 'Android Play Store App Bundle' { flutter build appbundle --release }
Invoke-ReleaseCommand 'Windows release build' { flutter build windows --release }
Invoke-ReleaseCommand 'Dependency license archive' { & .\tool\archive_dependency_notices.ps1 }
Invoke-ReleaseCommand 'Release checksum manifest' { & .\tool\generate_release_checksums.ps1 }
Invoke-ReleaseCommand 'Release artifact audit' { & .\tool\verify_release_artifacts.ps1 }

Write-Output 'Release pipeline passed.'
