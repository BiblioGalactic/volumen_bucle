autoconversation.sh

Script de Conversation avec Mistral

Ce script permet d’interagir avec le modèle linguistique Mistral via llama-cli afin de générer des conversations empathiques et réalistes.
Il combine la créativité de l’intelligence artificielle avec un système de génération de phrases aléatoires intégrant des sujets, verbes, actions, compléments et émotions, produisant ainsi des dialogues plus humains et variés.
De plus, le script conserve un historique des interactions et gère automatiquement les fichiers temporaires, garantissant un flux de travail propre et sécurisé.

Fonctionnalité

Le script crée des phrases aléatoires à partir d’une combinaison d’éléments linguistiques soigneusement sélectionnés pour transmettre des émotions et un contexte.
Chaque exécution produit de nouvelles phrases enregistrées dans un fichier de mémoire (MEMORIA), permettant au modèle de se référer à l’historique afin de générer des réponses cohérentes et contextuellement enrichies.

Deux cycles d’interaction sont réalisés à chaque exécution :
le premier génère la phrase initiale et obtient la réponse du modèle,
tandis que le second utilise l’historique de la conversation pour créer une continuité et une profondeur dans le dialogue.

Tous les fichiers temporaires créés pendant l’exécution sont supprimés automatiquement à la fin, évitant toute accumulation de données et maintenant un environnement propre (TEMP_DIR).

Utilisation

Pour exécuter le script, rendez-le d’abord exécutable avec :
chmod +x autoconversation.sh
Puis lancez-le avec :
./autoconversation.sh depuis le terminal.

Pendant l’exécution, les chemins nécessaires seront demandés :
	•	l’emplacement du modèle (MODELO_PATH),
	•	le binaire d’exécution (MAIN_BINARY),
	•	le fichier où sera stockée la mémoire de la conversation (MEMORIA),
	•	et le répertoire temporaire (TEMP_DIR).

Une fois terminé, vous pourrez consulter la conversation générée directement dans le terminal et examiner l’historique complet dans le fichier mémoire.
Cela permet d’assurer la continuité des dialogues et de réutiliser les données lors de futures exécutions.

Prérequis

Le script est conçu pour fonctionner sur macOS avec Bash 5 ou version supérieure.
Il est nécessaire de disposer du modèle Mistral au format .gguf et du binaire llama-cli correctement compilé et opérationnel.
Il est recommandé de disposer de ressources CPU et mémoire suffisantes afin de permettre au modèle de traiter efficacement les prompts, en particulier lors de sessions prolongées.

Considérations supplémentaires

Ce script est particulièrement utile pour :
	•	les expériences de génération de texte,
	•	les simulations de conversations,
	•	les tests de modèles linguistiques,
	•	et la création de contenus interactifs.

Il est conseillé de vérifier régulièrement le fichier de mémoire afin d’évaluer la cohérence des échanges et d’ajuster les paramètres de génération de llama-cli si nécessaire.
Sa conception modulaire permet d’étendre les fonctions de génération de phrases, d’ajouter de nouveaux sujets, verbes ou émotions, et de personnaliser le comportement de l’interaction sans modifier la logique centrale.

⸻

Eto Demerzel (Gustavo Silva Da Costa)
https://etodemerzel.gumroad.com
https://github.com/BiblioGalactic