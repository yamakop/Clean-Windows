@echo off
:: =====================================================================
:: Script de Nettoyage PC - Nettoyage_pc.bat
:: Description : Automatisation des tâches de maintenance et nettoyage.
:: Auteur      : YamaKosput
:: Date        : 2025-05-14
:: Version     : 1.0
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
) > "%LOGFILE%"

:: =====================================================================
:: Désactivation de la mise en veille
:: =====================================================================
echo Désactivation de la mise en veille de l'écran et du disque dur...
echo Désactivation de la mise en veille de l'écran et du disque dur... >> "%LOGFILE%"
powercfg -change monitor-timeout-ac 0
powercfg -change disk-timeout-ac 0
echo Mise en veille désactivée. >> "%LOGFILE%"

:: =====================================================================
:: Vérification de l'espace disque
:: =====================================================================
echo Vérification de l'espace disque disponible...
for /f "tokens=2 delims==" %%F in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value') do set FreeSpace=%%F
set /a FreeSpaceMB=%FreeSpace:~0,-6%
echo [INFO] Espace disque libre sur C: %FreeSpaceMB% Mo
echo [INFO] Espace disque libre sur C: %FreeSpaceMB% Mo >> "%LOGFILE%"
if %FreeSpaceMB% lss 500 (
    echo [AVERTISSEMENT] Espace disque inférieur à 500 Mo.
    echo [AVERTISSEMENT] Espace disque inférieur à 500 Mo. >> "%LOGFILE%"
)

:: =====================================================================
:: Nettoyage des fichiers temporaires
:: =====================================================================
echo Nettoyage des fichiers temporaires...
echo Nettoyage des fichiers temporaires... >> "%LOGFILE%"
del /f /s /q "%temp%\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Temp\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Prefetch\*" >> "%LOGFILE%" 2>&1
echo Nettoyage des fichiers temporaires terminé. >> "%LOGFILE%"

:: =====================================================================
:: Nettoyage de la corbeille
:: =====================================================================
echo Nettoyage de la corbeille...
echo Nettoyage de la corbeille... >> "%LOGFILE%"
powershell -Command "Clear-RecycleBin -Force" >> "%LOGFILE%" 2>&1
echo Nettoyage de la corbeille terminé. >> "%LOGFILE%"

:: =====================================================================
:: Nettoyage des fichiers de mise à jour
:: =====================================================================
echo Nettoyage des fichiers de mise à jour...
echo Nettoyage des fichiers de mise à jour... >> "%LOGFILE%"
net stop wuauserv >> "%LOGFILE%" 2>&1
net stop bits >> "%LOGFILE%" 2>&1
del /s /q "C:\Windows\SoftwareDistribution\Download\*" >> "%LOGFILE%" 2>&1
del /s /q "%windir%\Logs\CBS\*.log" >> "%LOGFILE%" 2>&1
net start wuauserv >> "%LOGFILE%" 2>&1
net start bits >> "%LOGFILE%" 2>&1
echo Nettoyage des fichiers de mise à jour terminé. >> "%LOGFILE%"

:: =====================================================================
:: Vidage du cache DNS
:: =====================================================================
echo Vidage du cache DNS...
echo Vidage du cache DNS... >> "%LOGFILE%"
ipconfig /flushdns >> "%LOGFILE%" 2>&1
echo Vidage du cache DNS terminé. >> "%LOGFILE%"

:: =====================================================================
:: Vérification et réparation des fichiers système
:: =====================================================================
echo Vérification de la connectivité Internet...
echo Vérification de la connectivité Internet... >> "%LOGFILE%"
ping -n 1 www.google.com >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Pas de connexion Internet.
    echo [ERREUR] Pas de connexion Internet. >> "%LOGFILE%"
) else (
    echo [INFO] Connexion Internet détectée.
    echo [INFO] Connexion Internet détectée. >> "%LOGFILE%"
    echo Vérification et réparation du système...
    echo Vérification et réparation du système... >> "%LOGFILE%"
    DISM /Online /Cleanup-Image /CheckHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /ScanHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /RestoreHealth >> "%LOGFILE%" 2>&1
    sfc /scannow >> "%LOGFILE%" 2>&1
    echo Vérification et réparation du système terminées. >> "%LOGFILE%"
)

:: =====================================================================
:: Nettoyage du disque dur
:: =====================================================================
echo Nettoyage du disque dur...
echo Nettoyage du disque dur... >> "%LOGFILE%"
cleanmgr /sagerun:1 >> "%LOGFILE%" 2>&1
echo Nettoyage du disque dur terminé. >> "%LOGFILE%"

:: =====================================================================
:: Défragmentation du disque dur
:: =====================================================================
echo Démarrage de la défragmentation...
echo Démarrage de la défragmentation... >> "%LOGFILE%"
defrag C: /O >> "%LOGFILE%" 2>&1
echo Défragmentation terminée. >> "%LOGFILE%"

:: =====================================================================
:: Finalisation et redémarrage
:: =====================================================================
(
    echo ---------------------------------------------------------------
    echo Script terminé avec succès.
    echo Date : %DATE%
    echo Heure : %TIME%
    echo ---------------------------------------------------------------
    echo ================================================================
) >> "%LOGFILE%"

echo Réinitialisation des schémas de gestion de l'alimentation...
echo Réinitialisation des schémas de gestion de l'alimentation... >> "%LOGFILE%"
powercfg -restoredefaultschemes
echo Réinitialisation terminée. >> "%LOGFILE%"

echo Le script a terminé son exécution. Consultez le fichier log pour plus de détails.
echo Redémarrage dans 30 secondes...
shutdown /r /f /t 30
echo Redémarrage de l'ordinateur dans 30 secondes. >> "%LOGFILE%"

:: Fin du script.
exit /b
