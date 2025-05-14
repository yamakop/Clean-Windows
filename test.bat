@echo off
:: Désactive l'affichage des commandes dans la console pour une exécution plus propre.

:: Vérifie si le script est exécuté avec des droits administratifs.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ce script nécessite des droits administratifs.
    pause
    exit /b
)

:: Définit le chemin du fichier log dans le dossier temporaire de l'utilisateur.
set "LOGFILE=%TEMP%\Script_nettoyage.log"
:: Récupère le nom de l'utilisateur courant.
set "utilisateur=%USERNAME%"

:: Initialise le fichier log avec des informations de base.
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

:: Désactive la mise en veille de l'écran et du disque dur pour éviter les interruptions pendant le nettoyage.
echo Désactivation de la mise en veille de l'écran et du disque dur... >> "%LOGFILE%"
powercfg -change monitor-timeout-ac 0
powercfg -change disk-timeout-ac 0
echo Mise en veille de l'écran et du disque dur désactivée. >> "%LOGFILE%"


:: Vérifie l'espace disque disponible sur le lecteur C:.
for /f "tokens=2 delims==" %%F in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value') do set FreeSpace=%%F
set /a FreeSpaceMB=%FreeSpace:~0,-6%
echo [INFO] Espace disque libre sur C: %FreeSpaceMB% Mo >> "%LOGFILE%"
if %FreeSpaceMB% lss 500 (
    echo [AVERTISSEMENT] L'espace disque est inférieur à 500 Mo. Certaines opérations pourraient échouer. >> "%LOGFILE%"
)

:: Nettoie les fichiers temporaires pour libérer de l'espace disque.
echo Nettoyage des fichiers temporaires... >> "%LOGFILE%"
del /f /s /q "%temp%\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Temp\*" >> "%LOGFILE%" 2>&1
del /f /s /q "C:\Windows\Prefetch\*" >> "%LOGFILE%" 2>&1
echo Nettoyage des fichiers temporaires terminé. >> "%LOGFILE%"

:: Vide la corbeille pour libérer de l'espace disque.
echo Nettoyage de la corbeille... >> "%LOGFILE%"
powershell -Command "Clear-RecycleBin -Force" >> "%LOGFILE%" 2>&1
echo Nettoyage de la corbeille terminé. >> "%LOGFILE%"

:: Supprime les fichiers de mise à jour Windows inutiles.
echo Nettoyage des fichiers de mise à jour... >> "%LOGFILE%"
net stop wuauserv >> "%LOGFILE%" 2>&1
net stop bits >> "%LOGFILE%" 2>&1
del /s /q "C:\Windows\SoftwareDistribution\Download\*" >> "%LOGFILE%" 2>&1
del /s /q "%windir%\Logs\CBS\*.log" >> "%LOGFILE%" 2>&1
net start wuauserv >> "%LOGFILE%" 2>&1
net start bits >> "%LOGFILE%" 2>&1
echo Nettoyage des fichiers de mise à jour terminé. >> "%LOGFILE%"

:: Vide le cache DNS pour résoudre d'éventuels problèmes réseau.
echo Vidage du cache DNS... >> "%LOGFILE%"
ipconfig /flushdns >> "%LOGFILE%" 2>&1
echo Vidage du cache DNS terminé. >> "%LOGFILE%"

:: Vérifie et répare les fichiers système pour garantir leur intégrité.
echo Vérification de la connectivité Internet... >> "%LOGFILE%"
ping -n 1 www.google.com >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Pas de connexion Internet. Les commandes suivantes pourraient échouer. >> "%LOGFILE%"
    echo %utilisateur%, veuillez vérifier votre connexion Internet avant de continuer. >> "%LOGFILE%"
) else (
    echo [INFO] Connexion Internet détectée. >> "%LOGFILE%"
    echo Vérification et réparation du système... >> "%LOGFILE%"
    DISM /Online /Cleanup-Image /CheckHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /ScanHealth >> "%LOGFILE%" 2>&1
    DISM /Online /Cleanup-Image /RestoreHealth >> "%LOGFILE%" 2>&1
    sfc /scannow >> "%LOGFILE%" 2>&1
    echo Vérification et réparation du système terminées. >> "%LOGFILE%"
)

:: Lance le nettoyage du disque dur pour supprimer les fichiers inutiles.
echo Nettoyage du disque dur... >> "%LOGFILE%"
cleanmgr /sagerun:1 >> "%LOGFILE%" 2>&1
echo Nettoyage du disque dur terminé. >> "%LOGFILE%"

:: Effectue une défragmentation du disque dur pour optimiser les performances.
echo Démarrage de la défragmentation... >> "%LOGFILE%"
defrag C: /O >> "%LOGFILE%" 2>&1
echo Défragmentation terminée. >> "%LOGFILE%"

:: Ajoute des informations de fin d'exécution dans le fichier log.
(
    echo ---------------------------------------------------------------
    echo Script terminé avec succès.
    echo %utilisateur% a effectué le nettoyage.
    echo Date : %DATE%
    echo Heure : %TIME%
    echo ---------------------------------------------------------------
    echo ================================================================
) >> "%LOGFILE%"

:: Réactive la mise en veille de l'écran et du disque dur.
echo Réinitialisation des schémas de gestion de l'alimentation... >> "%LOGFILE%"
powercfg -restoredefaultschemes
echo Réinitialisation des schémas de gestion de l'alimentation terminée. >> "%LOGFILE%"


:: Indique que le script a terminé son exécution.
echo Le script a terminé son exécution. Consultez le fichier log pour plus de détails.

::redémarre l'ordinateur après 30 secondes pour appliquer les modifications.
echo Redémarrage >> "%LOGFILE%"
shutdown /r /f /t 30
echo Redémarrage de l'ordinateur dans 30 secondes. >> "%LOGFILE%"

:: Fin du script.
exit /b
echo [INFO] Script terminé. >> "%LOGFILE%"
echo Merci d'avoir utilisé le script de nettoyage. >> "%LOGFILE%"

