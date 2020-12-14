---
layout: post
title: Refacthon
author: Chloé Avoustin, Julien Hochgenug
banner: /vlad-hilitanu-1FI2QAYPa-Y-unsplash.jpg
categories: Développement
---
Savoir coder, c’est bien. Bien communiquer, transmettre de la connaissance et partager les mêmes valeurs que les autres
développeurs de son équipe : c’est mieux !

La réponse la plus évidente pour répondre à ce besoin est la revue de code. Les bénéfices de cette méthode sont
multiples : limiter les erreurs humaines, partager la responsabilité du code envoyé en production et monter en
compétences sur le projet… Mais, sur le terrain, est-ce vraiment suffisant ?

Force est de constater que cette méthode provoque néanmoins des dérives. Nous avons tous connu des discussions à coups
de commentaires interposés souvent concis, subjectifs et qui peuvent générer de la frustration. Nos interactions
humaines s’érodent dans le temps, une routine qui s’installe et la qualité du code produit n’est plus au centre de notre
préoccupation.

> Pour remédier à tout ça, avez-vous déjà pensé à instaurer des rituels dédiés uniquement aux développeurs ?

Voici une proposition avec un principe simple : un meeting hebdomadaire de 30 minutes, montre en main. Les sujets de
discussions doivent se concentrer uniquement sur de la conception de code et sur les pratiques communes à appliquer.

## 👉 Les 3 règles à suivre :
  - La conception doit rester inchangée.
  - Le code doit rester iso-fonctionnel. Les modifications du code ne doivent pas influer sur le comportement de la
fonctionnalité.
  - Le code doit rester
iso-bug. Si on rencontre des problèmes, on ne les corrige pas directement et on crée un ticket pour le résoudre plus
tard.
On peut rajouter une notation `/* FIXME */` dans le code.

## 👀 Comment cela se passe concrètement :
  - Un présentateur est désigné pour la séance, il faut que ça tourne chaque semaine.
  - Le présentateur projette aux autres développeurs le code sélectionné préalablement. Le mieux est d’avoir une petite
liste où l’on peut indiquer des parties de code à analyser afin de venir piocher les idées pendant la réunion.
  - Les développeurs doivent donner leurs avis sur le code présenté et se mettre d’accord sur les pratiques communes à
appliquer.


Lors de ces sessions, il est important de garder en tête que les décisions sont prises de façon démocratique.
L’expérience, la position hiérarchique, l’ancienneté ne peuvent pas influer sur la prise de décision. Seule la qualité,
la maintenabilité et la simplicité du code comptent. Si vous avez une idée, il est donc important de la partager,
gardons en tête que l’objectif est d’ouvrir les discussions et de s’améliorer ensemble.

#### Exemple de discussions possibles autour du code :
  - Doit-on mettre des commentaires dans ce cas-là ?
  - À partir de quand doit-on faire du refactoring ?
  - Parler des conventions de code et les faire évoluer au besoin.
  - La programmation défensive est-elle nécessaire dans tous les cas ?
  - Existe-t-il des bonnes pratiques sur ce sujet ?

> Les bienfaits de ce rituel est d’obtenir des pratiques communes approuvées par la majorité afin de standardiser au maximum
le code.

Nous allons éprouver cette méthode en interne et reviendrons dans un prochain article avec notre retour d’expérience sur
la mise en place de ce nouveau rituel.
