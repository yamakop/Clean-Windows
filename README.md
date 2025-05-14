
DOCUMENTATION SCRIPT
========================================================================================




🗂 NOM DU SCRIPT :
    nettoyage_windows.bat

🔧 OBJECTIF :
    Script automatisé de maintenance pour Windows 10/11. Il effectue un ensemble complet
    d’opérations de nettoyage, réparation système, optimisation disque et préparation
    post-nettoyage avec redémarrage automatique.

💡 UTILISATION TYPIQUE :
    - Remettre un PC lent en état de marche
    - Libérer de l’espace disque
    - Préparer une machine avant ou après intervention
    - Automatiser la maintenance régulière

----------------------------------------------------------------------------------------

🔐 PRÉREQUIS :
    - Doit être exécuté en tant qu’administrateur (clic droit > "Exécuter en tant qu’administrateur")
    - Windows 10 ou 11 uniquement (non compatible Windows 7/8)
    - Une connexion Internet est recommandée pour certaines réparations (DISM)

----------------------------------------------------------------------------------------

📍 EMPLACEMENT DU SCRIPT :
    Ce script **doit être placé sur une clé USB**. Il détecte automatiquement la lettre du
    lecteur sur lequel il se trouve pour créer un dossier `log_script` à la racine.
~~~
└── Clé_USB
    ├── nettoyage_windows.bat
    ├── README_Utilisation_du_Script.txt
    └── log_script
        └── [Nom_PC]_[AAAA-MM-JJ]_[HH-MM]_nettoyage_log.txt
~~~~

----------------------------------------------------------------------------------------

⚙️ ÉTAPES DÉTAILLÉES DU SCRIPT :

1. ✅ **Détection automatique de la clé USB**
   - Le script identifie la lettre de lecteur où il est lancé (ex: `E:`)
   - Utilise cette lettre pour créer un dossier `log_script`

2. 📁 **Création d’un fichier log**
   - Le script génère un fichier journal nommé automatiquement en fonction :
     → Du nom de l'ordinateur (`%COMPUTERNAME%`)
     → De la date et de l’heure
   - Tout est loggé en temps réel pour analyse ultérieure

3. 🧹 **Nettoyage de fichiers temporaires**
   - `C:\Windows\Temp`, `%TEMP%` : suppression complète
   - Nettoyage du cache Windows Update (`SoftwareDistribution`)
   - Suppression des anciens journaux de Windows

4. 🗑️ **Vider la corbeille**
   - Vider tous les fichiers supprimés pour libérer de l’espace disque

5. 🪟 **Nettoyage des fichiers système**
   - Nettoyage avancé via `cleanmgr /sagerun`
   - Suppression des mises à jour obsolètes et fichiers systèmes non utilisés

6. 💾 **Vérification de l’espace disque**
   - Si l’espace libre est inférieur à 500 Mo sur le disque système (C:), un Avertissement est loggé

7. 🌐 **Vidage du cache DNS**
   - `ipconfig /flushdns` pour réinitialiser les caches de résolution réseau

8. 🛠️ **Réparations système**
   - Vérification et réparation des composants avec :
     - `DISM /Online /Cleanup-Image /RestoreHealth`
     - `sfc /scannow`
   - Ces commandes peuvent prendre jusqu’à 15 minutes

9. 💽 **Défragmentation**
   - Défragmente les disques durs (pas exécuté sur SSD)
   - Utilise `defrag` avec log détaillé

10. ⚙️ **Réinitialisation des paramètres d'alimentation**
   - Restaure les valeurs par défaut du mode de veille/hibernation

11. 🔁 **Redémarrage automatique**
   - Une fois le script terminé, un compte à rebours de 30 secondes démarre
   - Possibilité d’annuler avec `CTRL+C` (non recommandé)

----------------------------------------------------------------------------------------

📂 DOSSIER DE LOGS : `log_script`
   → Tous les résultats de chaque étape sont enregistrés
   → Format : `[NOMPC]_YYYY-MM-DD_HH-MM_nettoyage_log.txt`
   → À lire avec Notepad ou tout éditeur de texte

----------------------------------------------------------------------------------------

❗ COMPORTEMENTS AUTOMATIQUES :
   - Tous les fichiers inutiles sont supprimés **sans confirmation**
   - Le script s’auto-oriente sur la bonne lettre de lecteur
   - Redémarrage automatique (non désactivable sauf modification manuelle du script)
   - Interrompt proprement en cas d’erreur critique (ex: disque C: non détecté)

----------------------------------------------------------------------------------------

📌 CONSEILS D’UTILISATION :
   - Fermez tous vos logiciels avant exécution (Word, navigateur, etc.)
   - Ne touchez à rien pendant le nettoyage (surtout pendant DISM/SFC)
   - Ne retirez pas la clé USB pendant l’exécution
   - À utiliser une fois par mois pour de meilleurs résultats

----------------------------------------------------------------------------------------

📎 AUTEUR :
   Pseudo         : Yamakosput
   Date        : 14/05/2025
   Version     : v1.0

========================================================================================
