$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$workspaceRoot = Split-Path -Parent $projectRoot
$releaseRoot = Join-Path $workspaceRoot 'release_legal'
$checksumsPath = Join-Path $releaseRoot 'RELEASE_SHA256SUMS.txt'

$artifacts = @(
  @{ RelativePath = 'build/app/outputs/flutter-apk/app-release.apk'; Label = 'Android release APK' },
  @{ RelativePath = 'build/app/outputs/bundle/release/app-release.aab'; Label = 'Android release App Bundle' },
  @{ RelativePath = 'build/windows/x64/runner/Release/pinball_neo_95.exe'; Label = 'Windows release executable' }
)

$lines = @(
  'Pinball Neo 95 release checksums',
  '',
  'Verify each artifact with SHA-256 before uploading or distributing it.',
  ''
)

foreach ($artifact in $artifacts) {
  $absolutePath = Join-Path $projectRoot ($artifact.RelativePath -replace '/', '\')
  if (-not (Test-Path -LiteralPath $absolutePath)) {
    throw "$($artifact.Label) was not found at $absolutePath. Run a release build first."
  }

  $hash = (Get-FileHash -LiteralPath $absolutePath -Algorithm SHA256).Hash.ToLowerInvariant()
  $lines += "{0}  {1}" -f $hash, $artifact.RelativePath
}

New-Item -ItemType Directory -Path $releaseRoot -Force | Out-Null
Set-Content -LiteralPath $checksumsPath -Value $lines -Encoding utf8
Write-Output "Generated release checksum manifest: $checksumsPath."
