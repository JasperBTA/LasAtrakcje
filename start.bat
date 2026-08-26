@echo off
echo ==============================================
echo Uruchamianie srodowiska systemu Las (Backend + Web)
echo ==============================================

echo [1/2] Uruchamianie serwera Java (Spring Boot)...
start "Serwer Backend (Java)" cmd /c "cd backend && title Serwer Backend (Java) && .\mvnw.cmd spring-boot:run"

echo.
echo Czekam 5 sekund na wstepne zaladowanie Javy...
timeout /t 5 /nobreak > NUL

echo [2/2] Uruchamianie Panelu Web (Vite + React)...
start "Panel Admina Web (React)" cmd /c "cd admin-panel && title Panel Admina Web (React) && npm run dev -- --open"

echo.
echo Gotowe! Dwa dodatkowe okna terminali pracuja teraz w tle.
echo Panel uzytkownika za moment sam otworzy sie w Twojej przegladarce.
echo (Jesli chcesz wylaczyc serwery, po prostu zamknij te nowo otwarte okna).
echo ==============================================
pause
