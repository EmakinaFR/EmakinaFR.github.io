---
layout: post
title: Fonctionnement des DNS
author: Thibault Desmoulins
banner: banner-post-dns-basics.jpeg
categories: Réseaux
youtubeId: i1B81oMLv3s
---

Lors d'un entretien d'embauche à Emakina, nous demandons souvent ce qu'il se passe  lorsqu'un utilisateur entre un nom de domaine dans son navigateur web et appuie sur la touche *Entrée*. Les réponses à cette question sont souvent incomplètes car nombreux sont les développeurs qui pensent programmation mais qui ne cherchent pas à décortiquer ce qu'il se passe derrière nos outils que l'on utilise pourtant au quotidien. Trop compliqué ? Pas de notre domaine d'expertise ? La réponse à ces deux questions est non, car en mon sens un développeur maîtrise son domaine à partir du moment où il le comprend bien. Dans ce billet nous allons aborder le fonctionnement des DNS tout en entrant dans les détails, et vous verrez que ça n'est pas compliqué du tout ! En route.


## 💻 Utilité et fonctionnement des DNS

Comme vous le savez probablement, chaque machine sur un réseau est connue par son adresse IP, lui permettant de communiquer avec les autres. Chaque serveur web hébergeant un site web en a donc une, et ce sont les serveurs DNS qui nous permettent d'entrer un nom de domaine tel que "google.fr" et de tomber sur le serveur de Google. Sans ces serveurs DNS, nous devrions retenir toutes les adresses IP des sites que nous souhaitons visiter… Loin d'être pratique.

Lorsque l'on parle de DNS en réalité on parle de 2 choses :
* [du protocole de communication][1] (la structure des messages envoyés entre serveurs ainsi que les informations contenues) ;
* des serveurs qui communiquent avec ce protocole et qui nous retournent une IP pour un nom de domaine donné, c'est ce que nous allons voir ici.


### Les différents types de serveurs DNS

Ok, un serveur DNS permet de faire la correspondance entre un nom de domaine et son IP, mais savez vous qu'il existe plusieurs types de serveurs DNS ? Cela est dû au fait que les concepteurs du DNS souhaitaient rendre le système :
* **dynamique** : l'ajout d'enregistrements ne doit pas impliquer la modification de tous les serveurs du réseau, ils découvrent ces nouvelles données dès qu'ils en ont besoin ;
* **scalable** : il doit être possible de modifier la taille du réseau à volonté sans avoir à tout reconstruire ;
* **distribué** : un serveur DNS en panne ne doit pas perturber le réseau entier.


En résulte 4 types de serveurs DNS :

* Les serveurs racine (ou Root Server)

Il existe 13 serveurs racine dans le monde (la plupart aux USA). Comme leur nom l'indique, **aucun autre serveur n'est au-dessus d'eux**. Ce sont les piliers de l'architecture DNS. Pourquoi n'y en a-t-il que 13 ? Il s'agit d'une question de conception. Il faut savoir que l'architecture DNS a été pensée en 1983 ce qui commence à faire quand on parle d'informatique, et il n'est pas possible de dépasser cette limite. En revanche, des centaines de miroirs existent, ce qui permet d'avoir bien plus de serveurs qui peuvent répondre. Vous pouvez consulter la liste des serveurs à cette adresse : [http://www.iana.org/domains/root/servers][2]

* Serveur TLD (pour Top-Level Domain Server)

Ces serveurs stockent les informations de tous les noms de domaine partageant **la même extension**. Vous pouvez consulter la liste des extensions à cette adresse : [https://data.iana.org/TLD/tlds-alpha-by-domain.txt][3]. Il existe par exemple des serveurs TLD répondant quand on les interroge sur des sites en ".FR", d'autres pour ".COM"

* Serveur de nom (Domain-Level Name Server)

On dit que les serveurs de nom ont **autorité** sur leur zone. Ce sont les serveurs qui connaissent réellement l'IP finale du nom de domaine que vous souhaitez obtenir. Lorsque l'on développe un site web on configure le serveur de nom pour faire connaître son site au grand public.

* Les serveurs récursifs (Resolving Name Server)

Il s'agit de la **première étape d'une requête DNS**. Grâce à ces serveurs nous n'avons pas à savoir qu'il y a derrière une requête DNS des serveurs de nom, des serveurs TLD et des serveurs racine. Tout se résume par demander l'IP d'un nom de domaine à un serveur récursif et ce dernier effectue tout le traitement pour vous retourner l'IP résultante. Ils s'appellent "récursifs" car ils effectuent plusieurs requêtes pour trouver cette IP finale.


Chaque serveur n'a la connaissance que de son périmètre. Un serveur root ne connaît pas l'IP qui se cache derrière "google.com". En revanche, il sait qui peut être interrogé au sujet des noms de domaine se terminant par ".com". Grâce à ces 4 types de serveurs DNS, n'importe quel ordinateur dans le monde peut chercher l'IP d'un nom de domaine donné, et n'importe quel développeur peut acheter un nom de domaine qui sera connu de tous dans un délai court.



### Le parcours d'une requête DNS

Maintenant que vous connaissez les différents serveurs DNS, nous allons pouvoir détailler le parcours d'une requête DNS. Voici donc ce qu'il se passe lorsque vous entrez un nom de domaine et appuyez sur la touche *Entrée* :
1. une requête est envoyée au serveur DNS récursif avec la demande "quelle est l'IP du site *www.emakina.fr* ?"
2. le serveur DNS récursif qui reçoit cette demande va interroger un serveur Root pour connaître l'IP d'un serveur DNS gérant les noms de domaines ".fr"
3. une fois que le serveur Root a répondu avec une IP, le serveur récursif va interroger ce dernier (un serveur TLD donc) pour lui demander l'IP du serveur DNS gérant "emakina.fr"
4. lorsque le serveur TLD renvoie l'IP du serveur de nom (celui ayant autorité), le serveur récursif interroge ce dernier et obtient enfin l'IP finale !
5. enfin, le serveur récursif renvoie à l'utilisateur (ou plutôt au logiciel qui le demande) l'IP du site.

Je vous ai fait une animation du processus pour simplifier l’explication :

{% include youtubePlayer.html id=page.youtubeId %}


Voilà, si vous avez compris ce schéma vous maîtrisez le sujet des DNS ! Vraiment ? Ok il reste encore quelques concepts importants à savoir !



## 📚 Quelques éléments à prendre en compte

Le schéma précédent montre bien comment est résolue une requête DNS, mais il n’est pas possible d’y afficher certaines subtilités que nous allons voir maintenant.


### Cache DNS... mais pas que ça

Si vous avez compté, il y a en tout 8 appels pour pouvoir obtenir une seule adresse IP ! Pourtant, si vous naviguez tous les jours sur internet vous avez dû voir que c’est plutôt rapide. En tout, la résolution ne doit prendre que quelques millisecondes. Comment est-ce possible ? Vous l’avez dans le mille, grâce au cache DNS.

Un serveur DNS ne va pas demander toutes les 10 secondes l’IP de Google qui sera probablement demandée très souvent. Le serveur va donc stocker le résultat dans sa base de données. Il en fera de même pour les réponses des serveurs Root / TLD.

Le cache fonctionne grâce à un paramètre qui est retourné par les serveurs donnant la réponse. Ce paramètre s’appelle le TTL (Time To Live). Pour simplifier, le **TTL** correspond à répondre à la question suivante : “Je suis en train de répondre à un serveur DNS, combien de temps je souhaite que ce dernier enregistre ma réponse avant de me le redemander ?”

Voici un conseil pour configurer ce champ :
* si votre site internet est fait pour durer et qu’il est préférable de privilégier la rapidité, alors configurer un TTL élevé ;
* si vous êtes proches d’une mise en production ou que vous souhaitez effectuer des changements dans votre configuration, alors réduisez le TTL quelques temps avant de faire ces modifications

Un TTL élevé entraînera donc des réponses plus rapides aux utilisateurs et fera que votre serveur DNS sera moins sollicité, en revanche si vous souhaitez effectuer un changement celui-ci mettra du temps à se répercuter. À l’inverse un TTL faible sera pratique pour effectuer des modifications mais votre serveur DNS sera plus souvent sollicité et vos utilisateurs mettront plus de temps à connaître l’adresse IP voulue. Tout est une affaire de dosage.

Rajoutons un peu de complexité à cette histoire de cache :
* rien ne nous assure qu’un serveur va mettre en cache le résultat par rapport au TTL configuré. Un des serveurs DNS peut ne pas vouloir mettre en cache du tout, ou à l’inverse mettre en cache plus longtemps. Ce ne serait pas respecter le protocole mais pourquoi pas ?
* votre ordinateur a lui-même un cache et peut vouloir sauvegarder les IPs des noms de domaines que vous visitez fréquemment.



### Toute une histoire d’IP

Une résolution DNS permet de découvrir l’IP d’un nom de domaine donné, mais il est possible dans certains cas de vouloir l’inverse : demander le nom de domaine associé à une IP que l’on aurait récupéré. On appelle ceci une résolution inverse (reverse DNS en anglais). C’est comme avoir un annuaire inversé des numéros de téléphone. Cela peut s’avérer utile dans certains cas comme par exemple pour vérifier la provenance d’un email pour un logiciel de messagerie afin de se prémunir du spam.

Dans d’autres cas, vous pouvez vouloir enregistrer un nom de domaine pour une IP qui n’est pas fixe (exemple sur un réseau domestique). Dans ce cas on parle de DNS dynamique (ou Dynamic DNS en anglais). Il n’y a rien de magique dans cette histoire : un outil se situant du côté du réseau pouvant voir son IP changer se charge de détecter ce changement. S’il a lieu, alors il communique au serveur DNS la nouvelle adresse IP.


## Pour conclure
Les DNS sont au cœur de notre vie quotidienne. Sans eux, nous ne pourrions pas naviguer sur le net avec autant de facilité. Il est donc très important de savoir comment ça fonctionne, d’autant plus si vous travaillez dans le numérique. Avec ce post vous avez acquis les bases du fonctionnement DNS, cependant il est nécessaire d’approfondir le sujet si vous souhaitez configurer un jour votre propre serveur, notamment sur le concept [d'enregistrement DNS][4].



[1]: https://www.frameip.com/dns/
[2]: http://www.iana.org/domains/root/servers
[3]: https://data.iana.org/TLD/tlds-alpha-by-domain.txt
[4]: https://www.cloudflare.com/fr-fr/learning/dns/dns-records/
