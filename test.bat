@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ce script nécessite des droits administratifs.
    pause
    exit /b
)

set "LOGFILE=%TEMP%\Script_nettoyage.log"
set "utilisateur=%USERNAME%"

(
    echo ================================================================
    echo                       LOG DU SCRIPT NETTOYAGE
    echo ================================================================
    echo --- Informations système ---
    echo Date : %DATE%
    echo Heure : %TIME%
    echo Nom PC : %COMPUTERNAME%
    echo Utilisateur : %USERNAME%
    echo Version Windows : %OS%
    ver
    echo ---------------------------------------------------------------
    echo Début du script de nettoyage
    echo ---------------------------------------------------------------
) > "%LOGFILE%"

echo [INFO] Nettoyage des fichiers temporaires...
echo Nettoyage des fichiers temporaires en cours...
del /f /s /q "%temp%\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Temp\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Prefetch\*" >> "%LOGFILE%" 2>&1
echo [INFO] Nettoyage des fichiers temporaires terminé. >> "%LOGFILE%"
echo Nettoyage des fichiers temporaires terminé.
echo --------------------------------------------------------------- >> "%LOGFILE%"

echo [INFO] Nettoyage de la corbeille...
echo Nettoyage de la corbeille en cours...
powershell -Command "Clear-RecycleBin -Force" >> "%LOGFILE%" 2>&1
echo [INFO] Nettoyage de la corbeille terminé. >> "%LOGFILE%"
echo Nettoyage de la corbeille terminé.
echo --------------------------------------------------------------- >> "%LOGFILE%"

echo [INFO] Nettoyage des fichiers de mise à jour...
echo Nettoyage des fichiers de mise à jour en cours...
net stop wuauserv >> "%LOGFILE%" 2>&1
net stop bits >> "%LOGFILE%" 2>&1
del /s /q "C:\Windows\SoftwareDistribution\Download\*" >> "%LOGFILE%" 2>&1
del /s /q "%windir%\Logs\CBS\*.log" >> "%LOGFILE%" 2>&1
net start wuauserv >> "%LOGFILE%" 2>&1
net start bits >> "%LOGFILE%" 2>&1
echo [INFO] Nettoyage des fichiers de mise à jour terminé. >> "%LOGFILE%"
echo Nettoyage des fichiers de mise à jour terminé.
echo --------------------------------------------------------------- >> "%LOGFILE%"

echo [INFO] Vidage du cache DNS...
echo Vidage du cache DNS en cours...
ipconfig /flushdns >> "%LOGFILE%" 2>&1
echo [INFO] Vidage du cache DNS terminé. >> "%LOGFILE%"
echo Vidage du cache DNS terminé.
echo --------------------------------------------------------------- >> "%LOGFILE%"

echo [INFO] Vérification et réparation du système...
echo Vérification et réparation du système en cours...
DISM /Online /Cleanup-Image /CheckHealth >> "%LOGFILE%" 2>&1
DISM /Online /Cleanup-Image /ScanHealth >> "%LOGFILE%" 2>&1
DISM /Online /Cleanup-Image /RestoreHealth >> "%LOGFILE%" 2>&1
sfc /scannow >> "%LOGFILE%" 2>&1
echo [INFO] Vérification et réparation du système terminées. >> "%LOGFILE%"
echo Vérification et réparation du système terminées.
echo --------------------------------------------------------------- >> "%LOGFILE%"

echo [INFO] Nettoyage du disque dur...
echo Nettoyage du disque dur en cours...
cleanmgr /sagerun:1 >> "%LOGFILE%" 2>&1
echo [INFO] Nettoyage du disque dur terminé. >> "%LOGFILE%"
echo Nettoyage du disque dur terminé.
echo --------------------------------------------------------------- >> "%LOGFILE%"

echo [INFO] Démarrage de la défragmentation...
echo Défragmentation en cours...
defrag C: /O >> "%LOGFILE%" 2>&1
echo [INFO] Défragmentation terminée. >> "%LOGFILE%"
echo Défragmentation terminée.
echo --------------------------------------------------------------- >> "%LOGFILE%"

(
    echo ---------------------------------------------------------------
    echo Script terminé avec succès.
    echo %utilisateur% a effectué le nettoyage.
    echo Date : %DATE%
    echo Heure : %TIME%
    echo ---------------------------------------------------------------
    echo ================================================================
) >> "%LOGFILE%"

echo Le script a terminé son exécution. Consultez le fichier log pour plus de détails.
pause
