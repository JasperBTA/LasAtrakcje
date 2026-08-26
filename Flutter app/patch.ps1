$ErrorActionPreference = "Stop"

Write-Host "Rozpoczynam generowanie latki OTA (Patch)..." -ForegroundColor Cyan
Write-Host "Ta komenda wysle bezprzewodowa aktualizacje dla obecnej wersji aplikacji." -ForegroundColor Yellow
Write-Host ""

..\.shorebird\bin\shorebird patch android

Write-Host ""
Write-Host "Gotowe! Latka poleciala w chmure (jesli nie bylo bledow)." -ForegroundColor Green
