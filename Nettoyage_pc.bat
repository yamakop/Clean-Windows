@echo off
:: =====================================================================
:: Script de Nettoyage PC - Nettoyage_pc.bat
:: Description : Automatisation des tâches de maintenance et nettoyage.
:: Auteur      : YamaKosput
:: Date        : 2025-05-14
:: Version     : 1.1
:: =====================================================================

:: Définir l'encodage UTF-8 pour afficher correctement les caractères spéciaux.
chcp 65001 >nul

:: Vérification des droits administratifs.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ce script nécessite des droits administratifs.
    pause
    exit /b
)

:: =====================================================================
:: Initialisation des variables et répertoires
:: =====================================================================
set "BATDIR=%~dp0"
set "USB_DRIVE=%~d0"
set "LOGDIR=%USB_DRIVE%\log_script"

:: Création du répertoire des logs si inexistant.
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

:: Définir le fichier log avec un nom unique.
set "LOGFILE=%LOGDIR%\%COMPUTERNAME%_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%_%TIME:~0,2%-%TIME:~3,2%_nettoyage_log.txt"

:: Fonction pour écrire dans le fichier log
:Log
echo %~1 >> "%LOGFILE%"
exit /b

:: Initialisation du fichier log.
(
    echo ================================================================
    echo                       LOG DU SCRIPT NETTOYAGE
    echo ================================================================
    echo --- Informations système ---
    echo Date : %DATE%
    echo Heure : %TIME%
    echo Nom PC : %COMPUTERNAME%
    ver
    echo ---------------------------------------------------------------
    echo Début du script de nettoyage
    echo ---------------------------------------------------------------
    echo.
) > "%LOGFILE%"

:: =====================================================================
:: Suppression des fichiers de log plus vieux que 4 jours.
call :Log "Suppression des fichiers de log plus vieux que 4 jours..."
forfiles /p "%LOGDIR%" /m *.log /d -4 /c "cmd /c del /q @path" >> "%LOGFILE%" 2>&1
call :Log "Suppression des fichiers de log terminée."

:: =====================================================================
:: Désactivation de la mise en veille
call :Log "Désactivation de la mise en veille de l'écran et du disque dur..."
powercfg -change monitor-timeout-ac 0
powercfg -change disk-timeout-ac 0
call :Log "Mise en veille désactivée."

:: =====================================================================
:: Vérification de l'espace disque
call :Log "Vérification de l'espace disque disponible..."
for /f "tokens=2 delims==" %%F in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value') do set FreeSpace=%%F
set /a FreeSpaceMB=%FreeSpace:~0,-6%
call :Log "[INFO] Espace disque libre sur C: %FreeSpaceMB% Mo"
if %FreeSpaceMB% lss 500 (
    call :Log "[AVERTISSEMENT] Espace disque inférieur à 500 Mo."
)

:: =====================================================================
:: Nettoyage des fichiers temporaires
call :Log "Nettoyage des fichiers temporaires..."
del /f /s /q "%temp%\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Temp\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Prefetch\*" >> "%LOGFILE%" 2>&1
call :Log "Nettoyage des fichiers temporaires terminé."

:: =====================================================================
:: Nettoyage de la corbeille
call :Log "Nettoyage de la corbeille..."
powershell -Command "Clear-RecycleBin -Force" >> "%LOGFILE%" 2>&1
call :Log "Nettoyage de la corbeille terminé."

:: =====================================================================
:: Nettoyage des fichiers de mise à jour
call :Log "Nettoyage des fichiers de mise à jour..."
net stop wuauserv >> "%LOGFILE%" 2>&1
net stop bits >> "%LOGFILE%" 2>&1
del /s /q "C:\Windows\SoftwareDistribution\Download\*" >> "%LOGFILE%" 2>&1
del /s /q "%windir%\Logs\CBS\*.log" >> "%LOGFILE%" 2>&1
net start wuauserv >> "%LOGFILE%" 2>&1
net start bits >> "%LOGFILE%" 2>&1
call :Log "Nettoyage des fichiers de mise à jour terminé."

:: =====================================================================
:: Vidage du cache DNS
call :Log "Vidage du cache DNS..."
ipconfig /flushdns >> "%LOGFILE%" 2>&1
call :Log "Vidage du cache DNS terminé."

:: =====================================================================
:: Vérification et réparation des fichiers système
call :Log "Vérification de la connectivité Internet..."
ping -n 1 www.google.com >nul 2>&1
if %errorlevel% neq 0 (
    call :Log "[ERREUR] Pas de connexion Internet."
) else (
    call :Log "[INFO] Connexion Internet détectée."
    call :Log "Vérification et réparation du système..."
    DISM /Online /Cleanup-Image /CheckHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /ScanHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /RestoreHealth >> "%LOGFILE%" 2>&1
    sfc /scannow >> "%LOGFILE%" 2>&1
    call :Log "Vérification et réparation du système terminées."
)

:: =====================================================================
:: Nettoyage du disque dur
call :Log "Nettoyage du disque dur..."
cleanmgr /sagerun:1 >> "%LOGFILE%" 2>&1
call :Log "Nettoyage du disque dur terminé."

:: =====================================================================
:: Défragmentation du disque dur
call :Log "Démarrage de la défragmentation..."
defrag C: /O >> "%LOGFILE%" 2>&1
call :Log "Défragmentation terminée."

:: =====================================================================
:: Finalisation et redémarrage
(
    echo ---------------------------------------------------------------
    echo Script terminé avec succès.
    echo Date : %DATE%
    echo Heure : %TIME%
    echo ---------------------------------------------------------------
    echo ================================================================
) >> "%LOGFILE%"

call :Log "Réinitialisation des schémas de gestion de l'alimentation..."
powercfg -restoredefaultschemes
call :Log "Réinitialisation terminée."

call :Log "Le script a terminé son exécution. Consultez le fichier log pour plus de détails."
call :Log "Redémarrage dans 30 secondes..."
shutdown /r /f /t 30
call :Log "Redémarrage de l'ordinateur dans 30 secondes."

:: Fin du script.
exit /b
