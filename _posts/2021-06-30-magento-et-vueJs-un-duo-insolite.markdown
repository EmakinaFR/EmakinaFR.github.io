---
layout: post
title: Magento et VueJs un duo insolite.
author: Chloé Avoustin
banner: magento/magento-vuejs.jpg
categories: Développement Magento
excerpt_separator: "<!--more-->"
---

Un projet est le compromis qui permet de répondre à un besoin dans une contrainte de temps et de budget. C'est la raison
pour laquelle Emakina a choisi de faire reposer nos projets sur des structures robustes et complètes, comme Magento.
L'avantage de ces plateformes est qu'elles permettent de mettre en place des approches classiques ou des PWA. Mais ces
solutions sont-elles toujours la bonne réponse ?

<!--more-->

## Qu'est-ce que le standard Magento ?

<figure>
  <img src="/assets/image/magento/magento.jpg" alt="Magento2" />
</figure>

Lors de nos phases d'estimations, nous essayons d'exploiter au maximum les éléments fournis par Magento. Nous gardons
toujours en tête de faciliter la compatibilité avec les nouvelles versions. L'objectif étant de pouvoir garantir
l'application des patchs de sécurité et des correctifs, mais également de permettre l'utilisation des dernières
fonctionnalités.

Notre objectif est de rapidement avoir une application viable puis d'itérer pour la faire évoluer. C'est pour cette
raison, que lors de l'initialisation d'un projet, nous utilisons systématiquement comme parent de notre thème l'un
de ceux proposé par Magento. L'avantage majeur est qu'il permet aux utilisateurs de bénéficier d'une expérience complète
que nous pouvons ensuite personnaliser et enrichir.

Les deux éléments qui permettent au standard Magento d'être si efficace sur la partie front-end sont :
- le système de layouts en XML qui permet de déplacer, créer ou retirer un block fonctionnel
- la gestion de styles via des variables LESS qui permet de mettre en place les premières lignes de la charte graphique
  de la marque

Lors de la réalisation d'un projet, il est alors possible d'obtenir une expérience unique en quelques sprints.
Cependant, cette méthode a aussi une contrainte, nous devons composer avec l'existant et les mécaniques de Magento.
Ce qui implique que lorsque nous souhaitons refondre totalement le standard, le temps de développement peut alors
rapidement s'allonger.

## Qu'en est-il de Magento et des PWA ?

<figure>
  <img src="/assets/image/magento/magento-pwa.jpg" alt="Magento2 et PWA" />
</figure>

Nativement, Magento expose de très nombreuses fonctionnalités via son API, un fonctionnement dit "headless" est alors
envisageable. En résumé, il est alors possible de dissocier l’administration du site de son rendu. C'est grâce à ce
procédé qu'il est possible de créer des PWA.

L’avantage majeur des PWA est de faire disparaître les freins liés à une utilisation "classique". La partie front se
transforme alors en un affichage de templates spécifiques à dynamiser par de la manipulation d’objets. Lors de projets
expérientiels, nous partons d'une page blanche, ce qui permet alors de laisser libre cours à l’expérience utilisateur.

En contre-partie, il est nécessaire de passer du temps sur l'architecture front, mais également sur l’intégralité des
éléments du site. Le temps de développement pour une application complète est en conséquence plus long sur la première
partie de la vie du projet. Autre élément à prendre en compte : l'hébergement. En effet, le fait d'avoir un front et un
back-office dissociés impose un environnement avec un certain nombre de spécificités à prendre en compte.

Pour pallier cela, il existe des solutions comme VueStorefront ou PWA Studio qui viendront tout de même avec
d'autres contraintes.

## Le meilleur des deux mondes...

<figure>
  <img src="/assets/image/magento/vue_banner.jpeg" alt="VueJS" />
</figure>

Lors du projet que nous appellerons Gaia, ce choix s'est imposé à nous. Rapidement, notre équipe a dû se rendre
à l'évidence : aucune de ces deux solutions ne correspondaient au besoin. Nous avions besoin d'être rapides, tout en
créant une expérience fluide et unique. L'objectif principal de cette application étant de mettre un atelier de
personnalisation de tenues au cœur d'un site e-commerce classique.

C'est cette dernière particularité qui a permis de sortir des options classiques. Résignés à ne pas pouvoir choisir,
nous nous sommes lancé dans une version hybride : rester sur un développement classique, mais y inclure une brique VueJS
liée au site via l'API de Magento.

### Les avantages
👍 Un MVP rapide avec un focus sur le configurateur.  
👍 De la fluidité et de la liberté en partant d'une page blanche.  
👍 VueJS en inclusion directe pour un hébergement unique.  
👍 L'exploitation de GraphQL et des API existantes.

### Les points de vigilances
👎 Cette méthode, est incompatible avec Internet Explorer.  
👎 Les API évoluent rapidement, les montées de version peuvent être considérablement impactées.  
👉 Ne pas abuser des appels, chaque appel API compte lorsque la charge serveur est importante.

## La réalité du terrain

Une fois cette idée partagée avec l'ensemble de l'équipe, nous savions quoi faire et il ne restait plus qu'à valider la
faisabilité. Au vu, de la quantité de travail devant nous, le découpage en petites tâches "simples" et avancer pas à pas
a semblé être l'option la plus efficace et sécurisée.

### 1. Initialisation de l'application

Une fois notre module et la nouvelle route créés, il a suffi d'ajouter un bloc et un template pour initialiser
l'application.

```xml
<!-- app/code/Gaia/Configurator/view/frontend/layout/configurator_index_index.xml -->

<?xml version="1.0"?>
<page layout="1column" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:noNamespaceSchemaLocation="urn:magento:framework:View/Layout/etc/page_configuration.xsd">
  <body>
    <referenceContainer name="content">
      <block name="configurator" template="Gaia_Configurator::configurator.phtml"/>
    </referenceContainer>
  </body>
</page>
```

```html
<!-- app/code/Gaia/Configurator/view/frontend/templates/configurator.phtml -->

<div id="configurator" data-mage-init='{"initialize": {}}'></div>
```
Les choses sérieuses ont ensuite commencé. Notre premier sujet de rendre VueJs utilisable dans Magento. La solution la
plus simple et rapide a été de l'inclure via un CDN. Cette première étape étant derrière nous, il fallait maintenant
permettre l'interprétation des fichiers `.vue`.

Néanmoins, la partie JavaScript de Magento est orchestrée par requireJS or celui-ci interprète uniquement des fichiers
en `.js`. Après quelques recherches et tests, c'est l'ajout de `requireVue` est apparue comme une évidence.

```js
// app/code/Gaia/Configurator/view/frontend/requirejs-config.js

const config = {
  map: {
    '*': {
      'initialize': 'Gaia_Configurator/js/initialize',
      'Query': 'Gaia_Configurator/js/Query',
      'requireVue': 'https://unpkg.com/requirejs-vue@1.1.5/requirejs-vue',
      'Vue': 'https://unpkg.com/vue@2.5.11/dist/vue.min',
    },
  },
};
```
Une fois tous ces éléments installés, l'application pouvait se lancer via une fonction appelée avec
l'attribut `data-mage-init` dans le template `phtml` précédent. En quelques lignes, et beaucoup de recherches, le tour
était joué.

```js
// app/code/Gaia/Configurator/view/frontend/web/js/initialize.js

define(['Vue', 'jquery'],
  function (Vue, $) {
    const src = './Gaia_Configurator/template/App';

    return function () {
      require(['requireVue!' + src ], function (file) {
        file.$mount('#configurator');
      });
    }
  }
);
```
La dernière étape était la plus simple : créer le template VueJS, ici `App.vue` dont le chemin est indiqué par la
variable `src` du fichier précédent.
```html
<!-- app/code/Gaia/Configurator/view/frontend/web/template/App.vue -->

<template><div>Hello World !</div></template>

<script>
  define(['jquery','Vue'], function($,Vue) {
    return new Vue({
        template: template,
        components: {},
        data() {
            return {};
        },
        methods: {}
    });
});
</script>
```

### 2. Connexion avec les API

Comme évoqué précédemment, Magento met à disposition des API, dont une partie avec GraphQL. L'option retenue a été de
les exploiter et de les enrichir. Après quelques recherches et péripéties, c'est
[Apollo Boost Amd](https://github.com/mage2tv/module-apollo-boost-amd) qui a permis de faciliter la communication
en reliant de manière transparente le client de l'application à GraphQL.

Attention: la particularité d'Apollo Bosst Amd est qu'il s'installe via Composer.
```
composer require mage2tv/module-apollo-boost-amd
```

Nous avons ensuite pris un moment pour réfléchir à la structure de nos fichiers. Nous voulions :
- une structure évolutive
- facilement utilisable et réutilisable
- quelque chose d'intelligible qui limite la duplication

Une fois ces besoins exprimés, la mise en place d'une architecture JavaScript qui s'approche d'un modèle MVC est apparue
comme la solution la plus robuste.

<figure>
  <img src="/assets/image/magento/api.jpg" alt="Architecture: Récupération de données via GraphQL" />
  <figcaption>Architecture: Récupération de données via GraphQL</figcaption>
</figure>


Le fichier `graphql.js` est une sorte de modèle qui permet de lancer des requêtes `get` ou `update`.
```js
// app/code/Gaia/Configurator/view/frontend/web/js/graphql.js

define(['utils', 'apollo-boost'], function(utils, ApolloAmd) {
    const {ApolloClient, gql} = ApolloAmd;
    const client = new ApolloClient({url: '/graphql'});

    /** Object use in feedback for graphGL wishlist **/
    const defaultObject = `{ items { product { sku, name } } } }`;

    return {
        get(filters, object) {
            let objectReturn = (object) ? object : defaultObject;
            const query = (objectReturn) ? '{' + filters + ',' + objectReturn + ' }' : '{' + filters + ' }';
            return client.query({
              query: gql(query),
              fetchPolicy: 'no-cache',
            }).then(
                (data) => { return data; }
            );
        },
    };
});
```
Le fichier `query.js` va lui être utilisé comme un contrôleur : il va récupérer un objet, le formater puis de le
renvoyer au template.
```js
//app/code/Gaia/Configurator/view/frontend/web/js/Query.js

define(['jquery', 'graphql'],
  function($, graphQL) {
  return {
    getCMS(id) {
      const filters = 'cmsBlocks(identifiers: "' + id + '")';
      const object = `{items {content}}`;
      return graphQL.get(filters, object).then(
        (result) => { return result; }
      );
    },
  }
});
```
Dans le template, nous souhaitions afficher un contenu précédemment défini dans un block statique en back-office. Pour
remplacer la valeur initialement vide, nous sommes passés par une promesse via la fonction `Query.getCMS`. Une fois la
nouvelle valeur récupérée, il a suffi de l'injecter avec le fonctionnement classique de VueJS.
```html
<!-- app/code/Gaia/Configurator/view/frontend/web/template/App.vue -->

<template><div v-html="content"></div></template>

<script>
define(['jquery','Vue',Query], function($,Vue,Query) {
    return new Vue({
        template: template,
        components: {},
        data() {
            return {
                content: '';
            };
        },
        created() {
            Query.getCMS('monBlockCMS').then(
              (result) => {
                this.content = result.data.cmsBlocks.items[0].content;
              }
            ).catch((err) => {
                throw err;
            });
        },
    });
});
</script>
```

Attention, il ne faut pas oublier de mettre à jour le fichier `requirejs-config.js`.
```js
// app/code/Gaia/Configurator/view/frontend/requirejs-config.js

const config = {
  map: {
    '*': {
      // ...
      'graphql': 'Gaia_Configurator/js/graphql',
      'Query': 'Gaia_Configurator/js/Query',
    },
  },
};
```

### 3. Composants

<figure>
  <img src="/assets/image/magento/wirframe.png" alt="Wireframes" />
  <figcaption>Wireframe: Personalisation d'un élément d'une tenue</figcaption>
</figure>

Le configurateur fonctionne avec plusieurs niveaux de profondeur, mais il utilise toujours le même type de structure.
Pour faciliter le développement, limiter la duplication, et anticiper l'ajout d'éléments, formater les données GraphQL
pour pouvoir naviguer dans un objet était la meilleure option. Une fois ce "meta-objet" structuré, il était
incontournable de découper notre fichier `App.vue` en plusieurs composants. Jusqu'ici, tout semblait s'éclaircir,
puisque nous entrions dans le fonctionnement VueJS classique, mais nous avions oublié le fameux RequireJS de Magento.

Par contre, la méthode utilisée pour gérer le fichier `App.vue` n'a pas pu être réutilisée pour créer les autres
composants. L'avantage de VueJs est qu'il peut être fonctionnel via du JavaScript. Nos composants ont donc été écrits
dans des fichiers en `.js`. Attention, il est indispensable de déclarer tous les composants dans le fichier
`require-config.js` puis de les utiliser de façon classique avec VueJS.

```js
define(['jquery', 'Vue'],
    function($, Vue) {
        const template = `<div v-html="content"></div>`;
        return Vue.component('Help', {
            template: template,
            data() {
                return {
                    content: null,
                };
            },
            created() {
                Query.getCMS('monBlockCMS').then(
                    (result) => {
                        this.content = result.data.cmsBlocks.items[0].content;
                    }
                ).catch((err) => {
                    throw err;
                });
            },
        });
    }
);
```

### 4. Traductions
Pour les traductions, notre première idée a été d'utiliser le système standard de Magento. Toutefois, il ne fonctionne
pas avec des données dynamiques. Nous nous sommes rabattus sur le fonctionnement standard de VueJS en ajoutant
`vue-i18n` à l'application.

Pour ce faire, il faut charger `vue-i18n` et les fichiers de traductions via le fichier `require-config.js`.
```js
// app/code/Gaia/Configurator/view/frontend/requirejs-config.js

const config = {
  map: {
    '*': {
      // ...
      'VueI18n': 'https://unpkg.com/vue-i18n@8',
      'FRi18n': 'Gaia_Configurator/i18n/fr',
    },
  },
};
```

Ensuite, il restait à ajouter `vue-i18n` dans l'application.
```js
'use strict';

define(['Vue', 'VueI18n', 'jquery'],
    function(Vue, VueI18n, $) {
        const src = './Gaia_Configurator/template/App';

        Vue.use(VueI18n);

        return function () {
            require(['requireVue!' + src ], function(file) {
                file.$mount('#configurator');
            });
        }
    }
);
```

Puis, dans chaque composant, il nous fallait instancier le système de traductions. La fonction `i18n()` a alors été
créée dans notre fichier `utils.js` pour la réutiliser facilement sans avoir à la dupliquer.

```js
// app/code/Gaia/Configurator/view/frontend/web/js/utils.js

define(['jquery', 'VueI18n', 'FRi18n'], function($, VueI18n, FRi18n) {
    return {
        i18n() {
            return new VueI18n({
                'locale': $('html').attr('lang'),
                'fallbackLocale': 'fr',
                'messages': {
                  'fr': FRi18n,
                },
            });
        }
    }
})
```
Une fois `vue-i18n` installé, il a suffi de suivre son fonctionnement classique. Premièrement, il faut l'ajouter
dans le composant avec `i18n: utils.i18n()` puis d'appeler la traduction avec `$t('maClé')`.

Pour ce qui est du fichier avec les clés de traductions, voici le format retenu.
```js
define(function() {
  return {
    'maClé': 'maValeur',
  }
});
```

### 5. Et après ?
Une fois toutes ces mécaniques mises en place, le développement des fonctionnalités a continué pas à pas. Les nouvelles
demandes ont finalement été simples à traiter puisque nous étions dans un environnement VueJS (presque) classique. En
cas de problème, nous pouvions utiliser la [documentation officielle](https://vuejs.org/v2/guide/). Nous avons également
pu sans difficulté enrichir cet environnement avec un système interne de routeur puisque nous l'avions déjà fait avec
`vue-i18n`.

## En résumé, et si c'était à refaire ?
Cette nouvelle option nous offre de très nombreuses possibilités. L'avantage est que la phase d'expérimentation est
terminée, il est maintenant possible pour nous de monter une brique hybride en quelques heures. C'est d'ailleurs ce que
nous avons fait sur un autre projet avec une brique plus petite. Cette deuxième expérience a confirmé que cette
option est un compromis idéal si le besoin expérientiel est limité à une partie du site.
