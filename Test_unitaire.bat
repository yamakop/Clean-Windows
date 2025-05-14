@echo off
title Script de Tests de Maintenance
setlocal enabledelayedexpansion

:: Définir le fichier log
set LOGFILE=%~dp0maintenance_log.txt

:: Vérification des droits administratifs
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Le script n'est pas exécuté avec des droits administratifs. >> "%LOGFILE%"
    echo Ce script nécessite des droits administratifs. >> "%LOGFILE%"
    pause
    exit /b
) else (
    echo [INFO] Droits administratifs vérifiés avec succès. >> "%LOGFILE%"
)

:: Affichage du menu
:menu
cls
echo =========================================
echo    MENU DE TEST DE MAINTENANCE
echo =========================================
echo 1. Test des droits administratifs
echo 2. Test de la création du fichier log
echo 3. Test de l'espace disque libre
echo 4. Test de suppression des fichiers temporaires
echo 5. Test de nettoyage de la corbeille
echo 6. Test de suppression des fichiers de mise à jour
echo 7. Test de connexion Internet
echo 8. Test de nettoyage du disque
echo 9. Test de défragmentation du disque
echo 10. Test du redémarrage automatique
echo 11. Quitter
echo =========================================
set /p choice="Choisissez une option: "

:: Exécution du test choisi
if "%choice%"=="1" goto test_admin
if "%choice%"=="2" goto test_log
if "%choice%"=="3" goto test_disque
if "%choice%"=="4" goto test_temp
if "%choice%"=="5" goto test_corbeille
if "%choice%"=="6" goto test_mise_a_jour
if "%choice%"=="7" goto test_connexion
if "%choice%"=="8" goto test_cleanmgr
if "%choice%"=="9" goto test_defrag
if "%choice%"=="10" goto test_redemarrage
if "%choice%"=="11" exit

:: Test des droits administratifs
:test_admin
echo [INFO] Vérification des droits administratifs... >> "%LOGFILE%"
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Le script n'est pas exécuté avec des droits administratifs. >> "%LOGFILE%"
) else (
    echo [INFO] Droits administratifs vérifiés avec succès. >> "%LOGFILE%"
)
pause
goto menu

:: Test de la création du fichier log
:test_log
echo [INFO] Vérification de la création du fichier log... >> "%LOGFILE%"
if exist "%LOGFILE%" (
    echo [INFO] Fichier log créé avec succès : %LOGFILE% >> "%LOGFILE%"
) else (
    echo [ERREUR] Impossible de créer le fichier log. >> "%LOGFILE%"
)
pause
goto menu

:: Test de l'espace disque libre
:test_disque
echo [INFO] Test de l'espace disque libre sur C:... >> "%LOGFILE%"
for /f "tokens=2 delims==" %%F in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value') do set FreeSpace=%%F
set /a FreeSpaceMB=%FreeSpace:~0,-6%
echo [INFO] Espace libre sur C: %FreeSpaceMB% Mo >> "%LOGFILE%"
if %FreeSpaceMB% lss 500 (
    echo [AVERTISSEMENT] L'espace libre sur C: est inférieur à 500 Mo. >> "%LOGFILE%"
) else (
    echo [INFO] Espace libre suffisant. >> "%LOGFILE%"
)
pause
goto menu

:: Test de suppression des fichiers temporaires
:test_temp
echo [INFO] Suppression des fichiers temporaires... >> "%LOGFILE%"
del /f /s /q "%temp%\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Temp\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Prefetch\*" >> "%LOGFILE%" 2>&1
echo [INFO] Suppression des fichiers temporaires terminée. >> "%LOGFILE%"
pause
goto menu

:: Test de nettoyage de la corbeille
:test_corbeille
echo [INFO] Nettoyage de la corbeille en cours... >> "%LOGFILE%"
powershell -Command "Clear-RecycleBin -Force" >> "%LOGFILE%" 2>&1
echo [INFO] Corbeille nettoyée. >> "%LOGFILE%"
pause
goto menu

:: Test de suppression des fichiers de mise à jour
:test_mise_a_jour
echo [INFO] Suppression des fichiers de mise à jour... >> "%LOGFILE%"
net stop wuauserv >> "%LOGFILE%" 2>&1
net stop bits >> "%LOGFILE%" 2>&1
del /s /q "C:\Windows\SoftwareDistribution\Download\*" >> "%LOGFILE%" 2>&1
del /s /q "%windir%\Logs\CBS\*.log" >> "%LOGFILE%" 2>&1
net start wuauserv >> "%LOGFILE%" 2>&1
net start bits >> "%LOGFILE%" 2>&1
echo [INFO] Fichiers de mise à jour supprimés. >> "%LOGFILE%"
pause
goto menu

:: Test de la connexion Internet
:test_connexion
echo [INFO] Test de la connexion Internet... >> "%LOGFILE%"
ping -n 1 www.google.com >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Pas de connexion Internet, DISM et SFC ne peuvent pas être exécutés. >> "%LOGFILE%"
) else (
    echo [INFO] Connexion Internet détectée. >> "%LOGFILE%"
    DISM /Online /Cleanup-Image /CheckHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /ScanHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /RestoreHealth >> "%LOGFILE%" 2>&1
    sfc /scannow >> "%LOGFILE%" 2>&1
)
pause
goto menu

:: Test du nettoyage du disque
:test_cleanmgr
echo [INFO] Nettoyage du disque en cours... >> "%LOGFILE%"
cleanmgr /sagerun:1 >> "%LOGFILE%" 2>&1
echo [INFO] Nettoyage du disque terminé. >> "%LOGFILE%"
pause
goto menu

:: Test de défragmentation du disque
:test_defrag
echo [INFO] Défragmentation du disque en cours... >> "%LOGFILE%"
defrag C: /O >> "%LOGFILE%" 2>&1
echo [INFO] Défragmentation terminée. >> "%LOGFILE%"
pause
goto menu

:: Test du redémarrage automatique
:test_redemarrage
echo [INFO] Redémarrage du système dans 30 secondes... >> "%LOGFILE%"
shutdown /r /f /t 30
echo [INFO] Redémarrage planifié dans 30 secondes. >> "%LOGFILE%"
pause
goto menu
