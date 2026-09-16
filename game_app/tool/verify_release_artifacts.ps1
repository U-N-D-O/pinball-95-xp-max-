$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

function Require-File([string]$relativePath) {
  $path = Join-Path $projectRoot $relativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    $failures.Add("Missing file: $relativePath")
    return $null
  }
  $file = Get-Item -LiteralPath $path
  if ($file.Length -le 0) {
    $failures.Add("Empty file: $relativePath")
  }
  return $file
}

$apk = Require-File 'build\app\outputs\flutter-apk\app-release.apk'
$appBundle = Require-File 'build\app\outputs\bundle\release\app-release.aab'
$windowsExe = Require-File 'build\windows\x64\runner\Release\pinball_neo_95.exe'
Require-File 'android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png' | Out-Null
Require-File 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png' | Out-Null
Require-File 'windows\runner\resources\app_icon.ico' | Out-Null

$pubspecPath = Join-Path $projectRoot 'pubspec.yaml'
$pubspecText = Get-Content -LiteralPath $pubspecPath -Raw
$versionMatch = [regex]::Match($pubspecText, '(?m)^version:\s+([^\s]+)')
if (-not $versionMatch.Success -or $versionMatch.Groups[1].Value -ne '0.1.0+1') {
  $failures.Add('pubspec version is not 0.1.0+1')
}

$localPropertiesPath = Join-Path $projectRoot 'android\local.properties'
if (Test-Path -LiteralPath $localPropertiesPath) {
  $localProperties = Get-Content -LiteralPath $localPropertiesPath -Raw
  if ($localProperties -notmatch '(?m)^flutter\.versionName=0\.1\.0$' -or $localProperties -notmatch '(?m)^flutter\.versionCode=1$') {
    $failures.Add('Android generated version metadata does not match 0.1.0+1')
  }
}

$androidGradlePath = Join-Path $projectRoot 'android\app\build.gradle.kts'
$androidGradleText = Get-Content -LiteralPath $androidGradlePath -Raw
if ($androidGradleText -notmatch 'namespace\s*=\s*"com\.pinballneo95\.pinball_neo_95"' -or
    $androidGradleText -notmatch 'applicationId\s*=\s*"com\.pinballneo95\.pinball_neo_95"') {
  $failures.Add('Android namespace or application ID is incorrect')
}

$iosProjectPath = Join-Path $projectRoot 'ios\Runner.xcodeproj\project.pbxproj'
$iosProjectText = Get-Content -LiteralPath $iosProjectPath -Raw
if ($iosProjectText -notmatch 'PRODUCT_BUNDLE_IDENTIFIER = com\.pinballneo95\.pinballNeo95;') {
  $failures.Add('iOS production bundle identifier is incorrect')
}

$manifestPath = Join-Path $projectRoot 'android\app\src\main\AndroidManifest.xml'
if (Test-Path -LiteralPath $manifestPath) {
  [xml]$manifest = Get-Content -LiteralPath $manifestPath
  $application = $manifest.manifest.application
  if ($application.GetAttribute('android:label') -ne 'Pinball Neo 95') {
    $failures.Add('Android display label is not Pinball Neo 95')
  }
  $activity = $application.SelectSingleNode('activity')
  if ($null -eq $activity -or $activity.GetAttribute('android:screenOrientation') -ne 'portrait') {
    $failures.Add('Android activity is not locked to portrait')
  }
}

$runnerRc = Join-Path $projectRoot 'windows\runner\Runner.rc'
$runnerRcText = Get-Content -LiteralPath $runnerRc -Raw
if ($runnerRcText -notmatch 'VALUE "ProductName", "Pinball Neo 95"') {
  $failures.Add('Windows ProductName metadata is incorrect')
}
if ($runnerRcText -notmatch '#define VERSION_AS_NUMBER 0,1,0,1' -or $runnerRcText -notmatch '#define VERSION_AS_STRING "0.1.0\+1"') {
  $failures.Add('Windows fallback version metadata does not match 0.1.0+1')
}

$plistPath = Join-Path $projectRoot 'ios\Runner\Info.plist'
if (Test-Path -LiteralPath $plistPath) {
  [xml]$plist = Get-Content -LiteralPath $plistPath
  $bundleName = $plist.SelectSingleNode("//key[.='CFBundleName']/following-sibling::*[1]").InnerText
  if ($bundleName -ne 'Pinball Neo 95') {
    $failures.Add('iOS bundle name is not Pinball Neo 95')
  }
  $shortVersion = $plist.SelectSingleNode("//key[.='CFBundleShortVersionString']/following-sibling::*[1]").InnerText
  $bundleVersion = $plist.SelectSingleNode("//key[.='CFBundleVersion']/following-sibling::*[1]").InnerText
  if ($shortVersion -ne '$(FLUTTER_BUILD_NAME)' -or $bundleVersion -ne '$(FLUTTER_BUILD_NUMBER)') {
    $failures.Add('iOS version metadata is not wired to Flutter build values')
  }

  $iphoneOrientations = @($plist.SelectNodes("//key[.='UISupportedInterfaceOrientations']/following-sibling::*[1]/string") | ForEach-Object { $_.InnerText })
  if ($iphoneOrientations.Count -ne 1 -or $iphoneOrientations[0] -ne 'UIInterfaceOrientationPortrait') {
    $failures.Add('iPhone orientations are not portrait-only')
  }

  $ipadOrientations = @($plist.SelectNodes("//key[.='UISupportedInterfaceOrientations~ipad']/following-sibling::*[1]/string") | ForEach-Object { $_.InnerText })
  if ($ipadOrientations -notcontains 'UIInterfaceOrientationPortrait') {
    $failures.Add('iPad portrait orientation is missing')
  }
}

$iconContentsPath = Join-Path $projectRoot 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Contents.json'
if (Test-Path -LiteralPath $iconContentsPath) {
  $iconContents = Get-Content -LiteralPath $iconContentsPath -Raw | ConvertFrom-Json
  foreach ($icon in $iconContents.images) {
    if ($icon.filename -and -not (Test-Path -LiteralPath (Join-Path (Split-Path $iconContentsPath) $icon.filename))) {
      $failures.Add("Missing iOS icon file: $($icon.filename)")
    }
  }
}

$legalRoot = Split-Path -Parent $projectRoot
$noticesArchive = Join-Path $legalRoot 'release_legal\THIRD_PARTY_NOTICES.txt'
$noticesManifest = Join-Path $legalRoot 'release_legal\DEPENDENCY_LICENSE_MANIFEST.txt'
if (-not (Test-Path -LiteralPath $noticesArchive)) {
  $failures.Add('Dependency license notice archive is missing')
} elseif ((Get-Item -LiteralPath $noticesArchive).Length -lt 1000) {
  $failures.Add('Dependency license notice archive is unexpectedly small')
}
if (-not (Test-Path -LiteralPath $noticesManifest)) {
  $failures.Add('Dependency license archive manifest is missing')
}

$checksumsPath = Join-Path $legalRoot 'release_legal\RELEASE_SHA256SUMS.txt'
if (-not (Test-Path -LiteralPath $checksumsPath)) {
  $failures.Add('Release checksum manifest is missing')
} else {
  $checksumEntries = @{}
  foreach ($line in (Get-Content -LiteralPath $checksumsPath)) {
    if ($line -match '^([0-9a-fA-F]{64})\s{2}(.+)$') {
      $checksumEntries[$matches[2]] = $matches[1].ToLowerInvariant()
    }
  }

  $artifactPaths = @{
    'build/app/outputs/flutter-apk/app-release.apk' = $apk
    'build/app/outputs/bundle/release/app-release.aab' = $appBundle
    'build/windows/x64/runner/Release/pinball_neo_95.exe' = $windowsExe
  }
  foreach ($artifactPath in $artifactPaths.Keys) {
    if (-not $checksumEntries.ContainsKey($artifactPath)) {
      $failures.Add("Release checksum is missing for $artifactPath")
      continue
    }
    if ($null -eq $artifactPaths[$artifactPath]) {
      continue
    }

    $actualHash = (Get-FileHash -LiteralPath $artifactPaths[$artifactPath].FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($checksumEntries[$artifactPath] -ne $actualHash) {
      $failures.Add("Release checksum does not match $artifactPath")
    }
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Output ('Release artifact audit passed: APK {0} MB; AAB {1} MB; Windows EXE {2} MB.' -f `
  [math]::Round($apk.Length / 1MB, 1),
  [math]::Round($appBundle.Length / 1MB, 1),
  [math]::Round($windowsExe.Length / 1MB, 1))
