@echo off
:: Forcer l'execution en tant qu'administrateur
openfiles >nul 2>&1 || (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"; exit /b
)

set "LOGFILE=%TEMP%\Script_nettoyage.log"
echo Démarrage du script >> "%LOGFILE%"
echo %DATE%_______%TIME%_______%COMPUTERNAME%_______%USERNAME% >> "%LOGFILE%"