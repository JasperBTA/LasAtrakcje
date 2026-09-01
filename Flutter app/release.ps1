$ErrorActionPreference = "Stop"

$pubspecPath = "pubspec.yaml"
$content = Get-Content $pubspecPath

$versionLine = $content | Select-String -Pattern "^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)"
if (-not $versionLine) {
    Write-Host "Nie mozna znalezc wersji w pubspec.yaml!" -ForegroundColor Red
    exit 1
}

$major = [int]$versionLine.Matches.Groups[1].Value
$minor = [int]$versionLine.Matches.Groups[2].Value
$patch = [int]$versionLine.Matches.Groups[3].Value
$build = [int]$versionLine.Matches.Groups[4].Value

$newPatch = $patch + 1
$newBuild = $build + 1
$newVersion = "$major.$minor.$newPatch+$newBuild"

Write-Host "Obecna wersja: $($versionLine.Matches.Value)" -ForegroundColor Yellow
Write-Host "Podbijam wersje do: version: $newVersion" -ForegroundColor Green

$content = $content -replace "^version:.*", "version: $newVersion"
$content | Set-Content $pubspecPath

Write-Host "Wersja zapisana. Uruchamiam D:\Las\.shorebird\bin\shorebird.ps1 release android --flutter-version=3.47.1 --artifact=apk..." -ForegroundColor Cyan
& "D:\Las\.shorebird\bin\shorebird.ps1" release android --flutter-version=3.47.1 --artifact=apk
