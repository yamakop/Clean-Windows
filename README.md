# Documentation du Script de Nettoyage Windows

---

## 🗂 Nom du Script
**nettoyage_windows.bat**

---

## 🔧 Objectif
Script automatisé de maintenance pour Windows 10/11. Il effectue un ensemble complet d’opérations de nettoyage, réparation système, optimisation disque et préparation post-nettoyage avec redémarrage automatique.

---

## 💡 Utilisation Typique
- Remettre un PC lent en état de marche.
- Libérer de l’espace disque.
- Préparer une machine avant ou après intervention.
- Automatiser la maintenance régulière.

---

## 🔐 Prérequis
- **Exécution en tant qu’administrateur** (clic droit > "Exécuter en tant qu’administrateur").
- Compatible uniquement avec **Windows 10/11** (non compatible Windows 7/8).
- Une **connexion Internet** est recommandée pour certaines réparations (DISM).

---

## 📍 Emplacement du Script
Ce script **doit être placé sur une clé USB**. Il détecte automatiquement la lettre du lecteur sur lequel il se trouve pour créer un dossier `log_script` à la racine.

```
└── Clé_USB
   ├── nettoyage_windows.bat
   ├── README_Utilisation_du_Script.txt
   └── log_script
      └── [Nom_PC]_[AAAA-MM-JJ]_[HH-MM]_nettoyage_log.txt
```

---

## ⚙️ Étapes Détaillées du Script

1. **Détection automatique de la clé USB**  
   - Identification de la lettre de lecteur (ex: `E:`).  
   - Création d’un dossier `log_script`.

2. **Création d’un fichier log**  
   - Génération d’un fichier journal nommé automatiquement :  
    - Nom de l'ordinateur (`%COMPUTERNAME%`).  
    - Date et heure.  
   - Journalisation en temps réel.

3. **Nettoyage de fichiers temporaires**  
   - Suppression complète des fichiers dans `C:\Windows\Temp` et `%TEMP%`.  
   - Nettoyage du cache Windows Update (`SoftwareDistribution`).  
   - Suppression des anciens journaux de Windows.

4. **Vider la corbeille**  
   - Libération de l’espace disque en vidant la corbeille.

5. **Nettoyage des fichiers système**  
   - Nettoyage avancé via `cleanmgr /sagerun`.  
   - Suppression des mises à jour obsolètes et fichiers inutilisés.

6. **Vérification de l’espace disque**  
   - Avertissement loggé si l’espace libre est inférieur à 500 Mo sur le disque système (C:).

7. **Vidage du cache DNS**  
   - Réinitialisation des caches réseau avec `ipconfig /flushdns`.

8. **Réparations système**  
   - Vérification et réparation des composants avec :  
    - `DISM /Online /Cleanup-Image /RestoreHealth`.  
    - `sfc /scannow`.  
   - Durée estimée : jusqu’à 15 minutes.

9. **Défragmentation**  
   - Défragmentation des disques durs (non exécutée sur SSD).  
   - Utilisation de `defrag` avec log détaillé.

10. **Réinitialisation des paramètres d'alimentation**  
   - Restauration des valeurs par défaut du mode de veille/hibernation.

11. **Redémarrage automatique**  
   - Compte à rebours de 30 secondes après exécution.  
   - Annulation possible avec `CTRL+C` (non recommandé).

---

## 📂 Dossier de Logs
- Tous les résultats de chaque étape sont enregistrés.  
- Format : `[NOMPC]_YYYY-MM-DD_HH-MM_nettoyage_log.txt`.  
- À lire avec Notepad ou tout éditeur de texte.

---

## ❗ Comportements Automatiques
- Suppression des fichiers inutiles **sans confirmation**.  
- Détection automatique de la lettre de lecteur.  
- Redémarrage automatique (non désactivable sauf modification manuelle du script).  
- Interruption propre en cas d’erreur critique (ex: disque C: non détecté).

---

## 📌 Conseils d’Utilisation
- Fermez tous vos logiciels avant exécution (Word, navigateur, etc.).  
- Ne touchez à rien pendant le nettoyage (surtout pendant DISM/SFC).  
- Ne retirez pas la clé USB pendant l’exécution.  
- À utiliser une fois par mois pour de meilleurs résultats.

---

## 📎 Informations
- **Pseudo** : Yamakosput  
- **Date** : 14/05/2025  
- **Version** : v1.0  
- **SHA-256** : `50158B11F9AA85D53B1C77FB76041924B9388C4D519EA4FA9CE8B1B9D77C3AEC`

---

## 🔑 Vérification d’Intégrité
Pour vérifier l’intégrité du script, utilisez la commande suivante :  
```bash
certutil -hashfile nettoyage_pc.bat SHA256
```