@echo off
:: Forcer l'exécution en tant qu'administrateur
openfiles >nul 2>&1 || (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: === Création du fichier log dans TEMP ===
set "logfile=%TEMP%\nettoyage_auto_%DATE:~-4%-%DATE:~3,2%-%DATE:~0,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%.log"
set "logfile=%logfile: =0%"  :: Supprime les espaces potentiels dans le nom

:: Fonction de log
:log
echo [%DATE% %TIME%] %* >> "%logfile%"
goto :eof

call :log "Démarrage du script"

:: Sauvegarde du plan d'alimentation actuel
for /f "tokens=3" %%a in ('powercfg /getactivescheme') do set "originalGUID=%%a"
call :log "Plan d'alimentation actuel : %originalGUID%"

:: Création du plan Performance_Maximale
call :log "Création du plan Performance_Maximale"
powercfg -duplicatescheme SCHEME_MIN >nul
powercfg -changename SCHEME_MIN "Performance_Maximale" >nul 2>&1
powercfg -setacvalueindex SCHEME_MIN SUB_VIDEO VIDEOIDLE 600 >nul 2>&1
powercfg -setacvalueindex SCHEME_MIN SUB_DISK DISKIDLE 1200 >nul 2>&1
powercfg -setacvalueindex SCHEME_MIN SUB_SLEEP STANDBYIDLE 1800 >nul 2>&1
powercfg -setacvalueindex SCHEME_MIN SUB_SLEEP HIBERNATEIDLE 0 >nul 2>&1
powercfg -setacvalueindex SCHEME_MIN SUB_SLEEP HYBRIDSLEEP 0 >nul 2>&1
powercfg -setactive SCHEME_MIN >nul 2>&1
call :log "Plan Performance_Maximale appliqué"

:: Nettoyage des fichiers temporaires
call :log "Nettoyage des fichiers temporaires"
del /f /s /q "%temp%\*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
del /f /s /q "C:\Windows\Prefetch\*" >nul 2>&1
powershell -Command "Clear-RecycleBin -Force" >nul 2>&1

:: Nettoyage update/logs
call :log "Nettoyage des dossiers de mise à jour"
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
del /s /q "%windir%\Logs\CBS\*.log" >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

:: Flush DNS
call :log "Flush DNS"
ipconfig /flushdns >nul

:: Réparation système
call :log "Lancement DISM et SFC"
DISM /Online /Cleanup-Image /CheckHealth >> "%logfile%" 2>&1
DISM /Online /Cleanup-Image /ScanHealth >> "%logfile%" 2>&1
DISM /Online /Cleanup-Image /RestoreHealth >> "%logfile%" 2>&1
sfc /scannow >> "%logfile%" 2>&1

:: Nettoyage disque
call :log "Nettoyage disque (cleanmgr /sagerun:1)"
cleanmgr /sagerun:1 >nul 2>&1

:: Défragmentation
call :log "Optimisation du disque (defrag C: /O)"
defrag C: /O >> "%logfile%" 2>&1

:: Mise à jour Windows
call :log "Détection de la version Windows"
ver | findstr /i "6.1" >nul && set "version=win7"
ver | findstr /i "10.0" >nul && set "version=win10"

if "%version%"=="win7" (
    call :log "Mise à jour (Windows 7)"
    wuauclt /detectnow >nul
    wuauclt /updatenow >nul
) else (
    call :log "Mise à jour (Windows 10+)"
    UsoClient StartScan >nul
    UsoClient StartDownload >nul
    UsoClient StartInstall >nul
)

:: Fin et retour au plan d’origine
powercfg -setactive %originalGUID% >nul 2>&1
call :log "Restauration du plan d'origine : %originalGUID%"

call :log "Fin du script"
echo.
echo Nettoyage terminé. Fichier log : "%logfile%"
pause
exit /b
