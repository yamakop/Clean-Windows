@echo off
:: Définit l'encodage UTF-8 pour afficher correctement les caractères spéciaux.
chcp 65001 >nul

:: Désactive l'affichage des commandes dans la console pour une exécution plus propre.

:: Vérifie si le script est exécuté avec des droits administratifs.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ce script nécessite des droits administratifs.
    pause
    exit /b
)

:: Définit le répertoire où se trouve le script batch.
set "BATDIR=%~dp0"

:: Définit le répertoire où seront stockés les fichiers log.
set "LOGDIR=%BATDIR%log_script"

:: Définit le chemin de la clé USB en utilisant la lettre du lecteur où se trouve le script.
set "USB_DRIVE=%~d0"

:: Redéfinit le répertoire des logs pour qu'il soit sur la clé USB.
set "LOGDIR=%USB_DRIVE%\log_script"

:: Vérifie si le répertoire des logs existe, sinon le crée.
if not exist "%LOGDIR%" (
    mkdir "%LOGDIR%"
)

:: Définit le chemin complet du fichier log avec un nom unique basé sur le nom de l'ordinateur, la date et l'heure.
set "LOGFILE=%LOGDIR%\%COMPUTERNAME%_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%_%TIME:~0,2%-%TIME:~3,2%_nettoyage_log.txt"

:: Initialise le fichier log avec des informations de base.
(
    echo ================================================================
    echo                       LOG DU SCRIPT NETTOYAGE
    echo ================================================================
    echo --- Informations systeme ---
    echo Date : %DATE%
    echo Heure : %TIME%
    echo Nom PC : %COMPUTERNAME%
    ver
    echo ---------------------------------------------------------------
    echo Debut du script de nettoyage
    echo ---------------------------------------------------------------
) > "%LOGFILE%"

:: Désactive la mise en veille de l'écran et du disque dur pour éviter les interruptions pendant le nettoyage.
echo Desactivation de la mise en veille de l'ecran et du disque dur...
echo Desactivation de la mise en veille de l'ecran et du disque dur... >> "%LOGFILE%"
powercfg -change monitor-timeout-ac 0
powercfg -change disk-timeout-ac 0
echo Mise en veille de l'ecran et du disque dur desactivee. >> "%LOGFILE%"

:: Vérifie l'espace disque disponible sur le lecteur C:.
echo Verification de l'espace disque disponible...
for /f "tokens=2 delims==" %%F in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value') do set FreeSpace=%%F
set /a FreeSpaceMB=%FreeSpace:~0,-6%
echo [INFO] Espace disque libre sur C: %FreeSpaceMB% Mo
echo [INFO] Espace disque libre sur C: %FreeSpaceMB% Mo >> "%LOGFILE%"
if %FreeSpaceMB% lss 500 (
    echo [AVERTISSEMENT] L'espace disque est inferieur a 500 Mo. Certaines operations pourraient echouer.
    echo [AVERTISSEMENT] L'espace disque est inferieur a 500 Mo. Certaines operations pourraient echouer. >> "%LOGFILE%"
)

:: Nettoie les fichiers temporaires pour libérer de l'espace disque.
echo Nettoyage des fichiers temporaires...
echo Nettoyage des fichiers temporaires... >> "%LOGFILE%"
del /f /s /q "%temp%\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Temp\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Prefetch\*" >> "%LOGFILE%" 2>&1
echo Nettoyage des fichiers temporaires termine.
echo Nettoyage des fichiers temporaires termine. >> "%LOGFILE%"

:: Vide la corbeille pour libérer de l'espace disque.
echo Nettoyage de la corbeille...
echo Nettoyage de la corbeille... >> "%LOGFILE%"
powershell -Command "Clear-RecycleBin -Force" >> "%LOGFILE%" 2>&1
echo Nettoyage de la corbeille termine.
echo Nettoyage de la corbeille termine. >> "%LOGFILE%"

:: Supprime les fichiers de mise à jour Windows inutiles.
echo Nettoyage des fichiers de mise a jour...
echo Nettoyage des fichiers de mise a jour... >> "%LOGFILE%"
net stop wuauserv >> "%LOGFILE%" 2>&1
net stop bits >> "%LOGFILE%" 2>&1
del /s /q "C:\Windows\SoftwareDistribution\Download\*" >> "%LOGFILE%" 2>&1
del /s /q "%windir%\Logs\CBS\*.log" >> "%LOGFILE%" 2>&1
net start wuauserv >> "%LOGFILE%" 2>&1
net start bits >> "%LOGFILE%" 2>&1
echo Nettoyage des fichiers de mise a jour termine.
echo Nettoyage des fichiers de mise a jour termine. >> "%LOGFILE%"

:: Vide le cache DNS pour résoudre d'éventuels problèmes réseau.
echo Vidage du cache DNS...
echo Vidage du cache DNS... >> "%LOGFILE%"
ipconfig /flushdns >> "%LOGFILE%" 2>&1
echo Vidage du cache DNS termine.
echo Vidage du cache DNS termine. >> "%LOGFILE%"

:: Vérifie et répare les fichiers système pour garantir leur intégrité.
echo Verification de la connectivite Internet...
echo Verification de la connectivite Internet... >> "%LOGFILE%"
ping -n 1 www.google.com >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Pas de connexion Internet. Les commandes suivantes pourraient echouer.
    echo [ERREUR] Pas de connexion Internet. Les commandes suivantes pourraient echouer. >> "%LOGFILE%"
    echo veuillez verifier votre connexion Internet avant de continuer.
    echo veuillez verifier votre connexion Internet avant de continuer. >> "%LOGFILE%"
) else (
    echo [INFO] Connexion Internet detectee.
    echo [INFO] Connexion Internet detectee. >> "%LOGFILE%"
    echo Verification et reparation du systeme...
    echo Verification et reparation du systeme... >> "%LOGFILE%"
    DISM /Online /Cleanup-Image /CheckHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /ScanHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /RestoreHealth >> "%LOGFILE%" 2>&1
    sfc /scannow >> "%LOGFILE%" 2>&1
    echo Verification et reparation du systeme terminees.
    echo Verification et reparation du systeme terminees. >> "%LOGFILE%"
)

:: Lance le nettoyage du disque dur pour supprimer les fichiers inutiles.
echo Nettoyage du disque dur...
echo Nettoyage du disque dur... >> "%LOGFILE%"
cleanmgr /sagerun:1 >> "%LOGFILE%" 2>&1
echo Nettoyage du disque dur termine.
echo Nettoyage du disque dur termine. >> "%LOGFILE%"

:: Effectue une défragmentation du disque dur pour optimiser les performances.
echo Demarrage de la defragmentation...
echo Demarrage de la defragmentation... >> "%LOGFILE%"
defrag C: /O >> "%LOGFILE%" 2>&1
echo Defragmentation terminee.
echo Defragmentation terminee. >> "%LOGFILE%"

:: Ajoute des informations de fin d'exécution dans le fichier log.
(
    echo ---------------------------------------------------------------
    echo Script termine avec succes.
    echo Date : %DATE%
    echo Heure : %TIME%
    echo ---------------------------------------------------------------
    echo ================================================================
) >> "%LOGFILE%"

:: Réactive la mise en veille de l'écran et du disque dur.
echo Reinitialisation des schemas de gestion de l'alimentation...
echo Reinitialisation des schemas de gestion de l'alimentation... >> "%LOGFILE%"
powercfg -restoredefaultschemes
echo Reinitialisation des schemas de gestion de l'alimentation terminee.
echo Reinitialisation des schemas de gestion de l'alimentation terminee. >> "%LOGFILE%"

:: Indique que le script a terminé son exécution.
echo Le script a termine son execution. Consultez le fichier log pour plus de details.

:: Redémarre l'ordinateur après 30 secondes pour appliquer les modifications.
echo Redemarrage dans 30 secondes...
echo Redemarrage >> "%LOGFILE%"
shutdown /r /f /t 30
echo Redemarrage de l'ordinateur dans 30 secondes. >> "%LOGFILE%"

:: Fin du script.
exit /b
