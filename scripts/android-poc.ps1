param(
  [switch]$Run
)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

Write-Host 'Installing web dependencies...'
npm ci

Write-Host 'Building Drawnix web app...'
npm run build:web

Write-Host 'Installing temporary Capacitor tooling...'
npm install --no-save --package-lock=false @capacitor/core@8.2.0 @capacitor/android@8.2.0 @capacitor/cli@8.2.0

if (-not (Test-Path 'android')) {
  npx cap add android
}

npx cap sync android

Push-Location android
try {
  .\gradlew.bat assembleDebug
} finally {
  Pop-Location
}

$apk = Join-Path $PWD 'android\app\build\outputs\apk\debug\app-debug.apk'
Write-Host "APK: $apk"

if ($Run) {
  adb install -r $apk
}
