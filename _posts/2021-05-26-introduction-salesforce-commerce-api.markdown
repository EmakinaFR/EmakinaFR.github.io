---
layout: post
title: Introduction à Salesforce Commerce API (Headless architecture)
author: Thibault Desmoulins
banner: salesforce/introduction-commerce-api/banner-post-introduction-salesforce-commerce-api.jpeg
categories: Salesforce
excerpt_separator: "<!--more-->"
---

Au cours de la deuxième moitié de 2020, Salesforce a mis à disposition une nouvelle API nommée Commerce API. Celle-ci
permet de faire du développement appelé **headless** car tout le back-end est découplé du front-end.

Cette toute nouvelle API n’est pas à confondre avec Open Commerce API (OCAPI). Cette dernière n’est pour l’instant pas
dépréciée et Salesforce continuera à la maintenir, mais probablement que les évolutions futures ne se feront que sur
Commerce API (affaire à suivre). Aussi, toutes les API OCAPI ne seront pas forcément reproduites en Commerce API, il
est donc conseillé de regarder ce que font les deux pour savoir laquelle utiliser et quand.

<!--more-->

Dans cet article nous allons uniquement parler de Commerce API : comment s’authentifier et faire quelques appels API.
Je partagerai enfin une collection Postman qui permettra d’avoir un support pour vos développements futurs.

C’est parti !<br/><br/>


**⚠️ Important ⚠️**

Pour pouvoir s’authentifier sur les API Salesforce, il faut au préalable avoir un accès administrateur
sur [Account Manager][account_manager] et disposer d’un accès back-office à une instance du PIG
(_Development_ / _Staging_ / _Production_). Si vous n’avez pas ces éléments, je vous invite à vous rapprocher de votre
administrateur ou de Salesforce.

## Création de l’API Client
Que ce soit pour OCAPI ou pour Commerce API, il faut se créer un utilisateur API. Pour se faire, rendez vous dans votre
espace [Account Manager][account_manager], section _API Client_ et cliquez sur _Add API Client_.

<figure>
  <img src="/assets/image/salesforce/introduction-commerce-api/Account_Manager_creation_user_API.png" alt="Création d'un client API sur Account Manager" />
  <figcaption>Création d'un client API sur Account Manager</figcaption>
</figure>

Donnez ensuite un nom clair à votre utilisateur API, je vous conseille de faire un utilisateur pour vos tests et un
utilisateur pour la production, et sélectionnez l’organisation voulue. Dans la section _Roles_, cliquez sur _Add_, et
ajoutez le rôle `Salesforce Commerce API`.

Une fois le rôle ajouté, il faut cliquer sur le symbole filtre, et sélectionner la sandbox/plateforme sur laquelle
l’utilisateur API fonctionnera. Dans notre cas, ce sera une sandbox de test.

<figure>
  <img src="/assets/image/salesforce/introduction-commerce-api/Account_Manager_Role_Commerce_API.png" alt="Assigner un rôle et une ou plusieurs instances à un utilisateur API" />
  <figcaption>Assigner un rôle et une ou plusieurs instances à un utilisateur API</figcaption>
</figure>

Il faut désormais donner les permissions voulues pour cet utilisateur API. Voici un exemple.

```
sfcc.catalogs.rw
sfcc.products.rw
```

Ces deux lignes offrent un accès en lecture et écriture aux API des catalogues et des produits. Vous trouverez la
liste exhaustive des permissions disponibles dans la [documentation officielle de Commerce API][documentation_permissions_commerce_api].

Enfin, sélectionnez `client_secret_post` comme méthode d’authentification, et JWT comme format de token. Vous pouvez
maintenant valider la création de votre utilisateur API.

## Paramètres Commerce API de l'infrastructure

À ce stade, vous avez un client ID et un client password. C’est bien, mais pas suffisant pour utiliser toutes les API de
Commerce API. Pour cela, il faut déjà savoir sur quelle instance vous allez faire vos appels : une sandbox,
_Development_, _Staging_, ou _Production_ ?

Une fois que vous avez déterminé l’instance, rendez vous dans le Business Manager à la page _Administration_ >
_Site Development_ > _Salesforce Commerce API Settings_. Vous devriez alors voir les informations nécessaires.

<figure>
  <img src="/assets/image/salesforce/introduction-commerce-api/salesforce_commerce_api_settings.png" alt="Récupération du Short Code et de l'Organization ID" />
  <figcaption>Récupération du Short Code et de l'Organization ID</figcaption>
</figure>

Dans cette page, s’affichent le `Short Code` et l’`Organization ID`.

Par la suite, je vais découper l’`Organization ID` en plusieurs morceaux : il commence toujours par _f_ecom_, suivi de
l’ID de votre realm, puis de l’instance (`dev` pour _Development_ / `stg` pour _Staging_ / `prd` pour _Production_).

Nous avons donc tout ce qu’il nous faut :
- `api_client_id` : identifiant du client créé dans l'Account Manager.
- `api_client_secret` : mot de passe du client créé dans l'Account Manager.
- `short_code` : ce que nous venons d’obtenir dans le Business Manager, il est commun à tout votre PIG.
- `realm_id` : sous-partie de l’Organization ID (sous la forme _f_ecom_REALM_INSTANCE_).
- `instance_id` : sous-partie de l’Organization ID (sous la forme _f_ecom_REALM_INSTANCE_).
- `site_id` : identifiant du site sur lequel vous voulez faire les appels (récupéré dans _Administration_ > _Sites_ > _Manage Sites_).

## Récupération du jeton (token)

### Les différents types d’API
Maintenant que nous avons un utilisateur API, nous pouvons nous authentifier sur Commerce API et ainsi récupérer un jeton, ou token, qu’il faudra par la suite transmettre à chaque appel.

Une chose à savoir avant de se lancer, il existe deux types d’authentification possibles.
- **JWT token** pour utiliser les API de type **Shopper APIs**.
- **OAuth access-token** pour utiliser les API de type **Management APIs**.

Les _Shopper APIs_ sont globalement celles qu’il faut utiliser pour le storefront (passer des commandes, s’authentifier,
etc). Vous pouvez les retrouver en allant sur la [documentation officielle][documentation_commerce_api] et en filtrant
avec le mot clef _Shopper_.

<figure>
  <img src="/assets/image/salesforce/introduction-commerce-api/shopper_api.png" alt="Liste des API Shopper" />
  <figcaption>Liste des API Shopper</figcaption>
</figure>

Toutes les autres API sont considérées comme des _Management APIs_. Elles permettent de gérer les groupes d’utilisateurs
par exemple, ou encore les coupons, etc. Je ne vais pas lister ici toutes les possibilités, je vous laisse consulter la
documentation qui en plus aura le mérite d’évoluer au fur et à mesure des mises à jour.

### Obtenir le token pour les API Shopper

Pour les API de type _Shopper_, il faut se mettre à la place d’un utilisateur. Celui-ci peut être soit connecté, soit
déconnecté. Il y a donc un appel API pour chacun de ces deux cas.

#### Demande d’un token guest

Un utilisateur déconnecté est un _guest_. Si vous n’avez pas la possibilité de le connecter, car vous n’avez pas ses
identifiants par exemple, alors c’est celui-ci qu’il vous faut. Pour l’obtenir, il est nécessaire d’effectuer l’appel
suivant.

<table>
  <tr>
    <td>Type</td>
    <td>POST</td>
  </tr>
  <tr>
    <td>URL</td>
    <td>
      https://{short_code}.api.commercecloud.salesforce.com/customer/shopper-customers/v1/organizations/f_ecom_{realm_id}_{instance_id}/customers/actions/login?siteId={site_id}&clientId={api_client_id}
    </td>
  </tr>
  <tr>
    <td>Données postées</td>
    <td>aucune</td>
  </tr>
  <tr>
    <td>Contenu de l’appel</td>
    <td>
  <code>
  {
    "type": "guest"
  }
  </code>
    </td>
  </tr>
</table>

**En-tête de la réponse**
```
Allow: DELETE,OPTIONS,POST
Authorization: Bearer LeSuperTokenIci
```

**Contenu de la réponse**
```
{
   "authType": "guest",
   "customerId": "ac7oo5FaCFGW9vZBPXyyqbbT8T",
   "preferredLocale": "fr_FR"
}
```

Voilà, vous venez d’obtenir le token (dans l’en-tête du retour) ainsi que le customerID qui sera utile pour les appels
futurs. La locale, quant à elle, vous aide à construire votre application dans la bonne langue.

#### Demande d’un token pour utilisateur authentifié

Lorsque votre application a accès aux identifiants, ou les obtient suite à un formulaire d’authentification, vous
pouvez demander un token pour que vos appels à Commerce API persistent les modifications dans le compte de
l’utilisateur.

La demande de token est similaire à la méthode précédente à l’exception du contenu de l’appel, et du fait qu’il faille
envoyer l’identifiant et mot de passe. Il s’agit d’une [authentification Basic][authentification_basic]. Il faut donc
envoyer le base64 de l’identifiant et du mot de passe séparés par `:`.

Ce qui pourrait donner `base64(“myuser:MyGr3atPwd!”)`, par exemple.

<table>
  <tr>
    <td>Type</td>
    <td>POST</td>
  </tr>
  <tr>
    <td>URL</td>
    <td>
      https://{short_code}.api.commercecloud.salesforce.com/customer/shopper-customers/v1/organizations/f_ecom_{realm_id}_{instance_id}/customers/actions/login?siteId={site_id}&clientId={api_client_id}
    </td>
  </tr>
  <tr>
    <td>Données postées</td>
    <td>Authorization: Basic bXl1c2VyOk15R3IzYXRQd2Qh</td>
  </tr>
  <tr>
    <td>Contenu de l’appel</td>
    <td>
  <code>
  {
    "type": "credentials"
  }
  </code>
    </td>
  </tr>
</table>

**En-tête de la réponse**
```
Allow: DELETE,OPTIONS,POST
Authorization: Bearer LeSuperTokenIci
```

**Contenu de la réponse**
```
{
   "authType": "registered",
   "birthday": "1901-01-01",
   "creationDate": "2017-12-21T17:34:50.000Z",
   "customerId": "abf532er5axNquq3Btrtbl3oXv",
   "customerNo": "00000001",
   "email": "monemail@mail.com",
   "enabled": true,
   "firstName": "Thibault",
   "gender": 0,
   "lastLoginTime": "2021-05-20T11:57:29.770Z",
   "lastModified": "2021-05-20T11:57:29.770Z",
   "lastName": "Test",
   "lastVisitTime": "2021-05-20T11:57:29.770Z",
   "login": "monemail@mail.com",
   "phoneMobile": "0612345678",
   "previousLoginTime": "2021-05-18T15:38:10.000Z",
   "previousVisitTime": "2021-05-18T15:38:10.000Z"
}
```

### Obtenir le token pour les API Management

Tout comme la demande d’un token pour un utilisateur authentifié, il est nécessaire d’envoyer une authentification de
type Basic, avec l’identifiant et le mot de passe de l’utilisateur API créés précédemment. Voici les données à poster.

- `grant_type`: il faudra mettre `client_credentials`.
- `scope`: permissions que vous souhaitez obtenir pour les appels API futurs. Il est important de préfixer les
  autorisations par `SALESFORCE_COMMERCE_API:{realm_id}_{instance_id}`.

<figure>
  <img src="/assets/image/salesforce/introduction-commerce-api/permissions_token_oauth.png" alt="Demande de token pour API Management" />
  <figcaption>Demande de token pour API Management</figcaption>
</figure>

**Contenu de la réponse**
```
{
   "access_token": "LeSuperTokenIci",
   "scope": "sfcc.catalogs sfcc.orders.rw mail sfcc.products.rw sfcc.promotions.rw sfcc.products sfcc.catalogs.rw SALESFORCE_COMMERCE_API:abcd_dev",
   "token_type": "Bearer",
   "expires_in": 1799
}
```

Nous avons désormais récupéré des tokens pour tous les cas possibles (API Shopper guest ou authentifié, API Management).
Nous pouvons maintenant développer notre application et effectuer les vraies requêtes.

### Important
Vous ne pouvez pas demander des autorisations pour les API Shopper lors d’une demande de token d’API Management.

## Quelques appels

Nous voici dans la partie intéressante : nous avons les informations de connexion et nous pouvons nous amuser avec les
API classiques. Je ne vais pas présenter ici toutes les API, mais une ou deux afin de se faire la main. Pour le reste,
je vous laisse consulter la documentation officielle.

Le but sera de rechercher un produit et de l’ajouter au panier. En affichant les API de type _Shopper_ dans la
documentation officielle, on voit 10 résultats. Dans ces résultats, on trouve ce qui nous intéresse : _Shopper Search_
et _Shopper Basket_. On ne va pas aller jusqu’au passage de commande, mais si vous voulez aller jusque-là vous avez
aussi _Shopper Orders_.

Avec _Shopper Search_, nous allons rechercher un produit dans le catalogue, puis nous allons créer un panier, et
ajouter un des produits dans ce panier avec _Shopper Basket_.

### Shopper Search

Tout commence par l’onglet [API Specification de la documentation][shopper_search_documentation]. Celui-ci donne l’URL
de base de l’API, toutes les API ont une URL spécifique, ici :
`https://{shortCode}.api.commercecloud.salesforce.com/search/shopper-search/{version}`.

Si vous sélectionnez les endpoints disponibles dans le menu, vous trouverez `GET productSearch` donnant les détails de
ce qu’il faut envoyer et à quelle URL.

- Type : `GET`
- URL : `/organizations/{organizationId}/product-search`
- Header requis : le token Bearer
- Paramètres :
  - `siteId` : requis (l’identifiant du site Salesforce à requêter)
  - `q` : optionnel, mais on va le fournir (il s’agit de la recherche à faire)

Il suffit donc tout simplement de s’authentifier (guest ou non), puis d’exécuter cette requête avec le token reçu et
la recherche que vous souhaitez faire (paramètre `q`). L’API vous retournera un JSON avec le résultat de la recherche !
Pour ma part, je vais prendre le premier produit retourné et l’ajouter au panier.

### Shopper Basket

La création d'un panier (basket en anglais) peut se faire en une ou plusieurs fois.

1. Vous avez toutes les informations à mettre dans le panier (produits, modes de livraison, etc) et vous pouvez tout envoyer en un appel.
1. Vous créez un panier vide et le modifiez au fur et à mesure.

Dans notre cas, nous allons choisir l'option 2 et faire un premier appel pour créer le panier.

Comme dans la partie précédente, tout commence par la [documentation Shopper Basket][documentation_shopper_basket].
Dans l'onglet _Developer Guide_, vous trouverez beaucoup d'informations intéressantes sur comment procéder, je vous
conseille de le lire si vous n'êtes pas au point sur cette notion de panier, et de tout ce qu'il est censé contenir.
Pour les autres, rendez-vous sur l'onglet _API Specification_ pour trouver l'URL de base des API _Basket_:
`https://{shortCode}.api.commercecloud.salesforce.com/checkout/shopper-baskets/{version}`.

Allez ensuite dans le menu dans _Endpoints_ > _/organizations/{organizationID}_ > _/baskets_ > _createBasket_.

<figure>
  <img src="/assets/image/salesforce/introduction-commerce-api/create-basket-api-documentation.png" alt="Aperçu de la documentation de l'API createBasket" />
  <figcaption>Documentation sur l'API createBasket</figcaption>
</figure>

Nous allons créer un panier vide, nous n'avons donc qu'à fournir le paramètre `siteId` sans body.

- Type : `POST`
- URL : `/baskets?siteId={site_id}`
- Header requis : le token Bearer
- Contenu de l'appel :  <code>{}</code>

Le retour de l'API peut impressionner, car d'un JSON vide, Salesforce renvoie beaucoup d'informations. C'est normal,
comme je l'ai évoqué plus haut un panier contient de nombreuses choses. Un panier vide a quand même un objet
`shipment`, des informations de taxe, etc.

Nous allons surtout avoir besoin du `basketId` qui est retourné, car pour mettre à jour ce panier, il nous faudra
envoyer son identifiant ! Nous n'avons plus qu'à ajouter notre produit au panier. Pas besoin de changer de page de
documentation, il faut aller via le menu dans _Endpoints_ > _/organizations/{organizationID}_ > _/baskets_ >
_/{basketID}_ > _/items_ > _addItemToBasket_.

<figure>
  <img src="/assets/image/salesforce/introduction-commerce-api/add-item-to-basket-api-documentation.png" alt="Aperçu de la documentation de l'API addItemToBasket" />
  <figcaption>Documentation sur l'API addItemToBasket</figcaption>
</figure>

Nous avons récupéré le basketID dans l'appel précédent, et le product ID dans la partie précédente. Nous avons donc
toutes les informations pour ajouter ce produit au panier.

<code>
- Type : POST`
- URL : `/baskets/{basket_id}/items?siteId={site_id}`
- Header requis : le token Bearer
- Contenu de l'appel :  <code>
[
    {
        "productId": "{product_id}",
        "quantity": 1
    }
]
</code>

Bravo ! Vous venez : de chercher un produit, de créer un panier et d'ajouter un produit dans ce panier. Désormais, vous
avez tout pour créer une application Headless en utilisant les API fournies par Salesforce. Dans la partie suivante, je
vais vous partager une collection Postman qui permet de rejouer tous les appels qu'on a vu dans ce tutoriel, mais nous
n'apprendrons rien de plus. Have fun!

## Collection Postman

Je pars du principe que vous connaissez Postman et comment le logiciel fonctionne dans ce chapitre. Voici une collection
Postman qui permet de faire les appels que nous avons vus dans ce tutoriel :
[https://github.com/EmakinaFR/salesforce-commerce-api-postman][salesforce-commerce-api-postman].

Vous pouvez cloner ou télécharger les fichiers JSON, et les importer dans votre logiciel. Ensuite, sélectionnez
l'environnement _Commerce API_ et modifiez les variables pour vos valeurs. L'arborescence de la collection ne devrait pas
vous surprendre : une partie _Shopper APIs_ et une partie _Management APIs_.

Pour s'authentifier sur la partie Shopper API, il faut utiliser les API nommées _Authenticate manually registered_ ou
_Authenticate manually guest_ en fonction de ce que vous souhaitez. Lorsque vous exécuterez ces appels, vous aurez en
retour un `customerId`. Pas besoin de le copier et de le coller dans les appels suivants, car dans l'onglet _Tests_ un
bout de code est mis en place pour sauvegarder ce customerID dans une variable d'environnement qui sera réutilisée par
la suite.

Pour les API de type _Management_, il faut demander le token en cliquant sur le répertoire _Management APIs_ et en
cliquant sur le bouton _Get new access token_ tout en bas. Le token qui sera donné sera utilisé dans toutes les API
sous ce répertoire (elles héritent du token). Il y a aussi un appel nommé _Authenticate manually_ pour les API
_Management_ mais il vaut mieux passer par le répertoire _Management APIs_, car il n'y a rien pour sauvegarder le token
dans celle-ci. Elle est là uniquement pour que vous sachiez comment l'appel API fonctionne pour s'authentifier, au cas
où vous voudriez le refaire dans votre langage de programmation favoris.

Tout le reste est dans le `README.md` du projet, n'hésitez pas à contribuer.

Merci !

## Liens utiles

- Account Manager : [https://account.demandware.com/][account_manager]
- Developer Center (documentation) Commerce API : [https://developer.commercecloud.com/s/commerce-api-apis][documentation_commerce_api]
- Code source de l’application de démo utilisant Commerce API : [https://github.com/SalesforceCommerceCloud/sfcc-sample-apps][sfcc-sample-apps]
- Télécharger Postman : [https://www.postman.com/downloads/][postman_downloads]
- Collection Postman mise à disposition : [https://github.com/EmakinaFR/salesforce-commerce-api-postman][salesforce-commerce-api-postman]

<!-- Resources -->
[account_manager]: https://account.demandware.com
[documentation_permissions_commerce_api]: https://developer.commercecloud.com/s/article/CommerceAPI-AuthZ-Scope-Catalog
[documentation_commerce_api]: https://developer.commercecloud.com/s/commerce-api-apis
[authentification_basic]: https://fr.wikipedia.org/wiki/Authentification_HTTP#M%C3%A9thode_%C2%AB_Basic_%C2%BB
[shopper_search_documentation]: https://developer.commercecloud.com/s/api-details/a003k00000UHwuFAAT/commerce-cloud-developer-centershoppersearch?tabset-888ee=2
[sfcc-sample-apps]: https://github.com/SalesforceCommerceCloud/sfcc-sample-apps
[postman_downloads]: https://www.postman.com/downloads/
[documentation_shopper_basket]: https://developer.commercecloud.com/s/api-details/a003k00000UHvpEAAT/commerce-cloud-developer-centershopperbaskets
[salesforce-commerce-api-postman]: https://github.com/EmakinaFR/salesforce-commerce-api-postman
