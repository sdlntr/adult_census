# Lien avec le fichier global
source("./global.R")









# EN-TETE
header <- dashboardHeader(
  title = "Projet R - 2021/2022"
)




# MENU LATERAL
sidebar <- dashboardSidebar(
  collapsed = FALSE,
  sidebarMenu(
    menuItem("Présentation", tabName = "presentation", icon = icon("info-circle")),
    menuItem("Analyse des données", tabName = "analyse", icon = icon("chart-area"), badgeLabel = NULL),
    menuItem("Préparation des données", tabName = "preparation", icon = icon("brain")),
    menuItem("Régression logistique", tabName = "logistique", icon = icon("wave-square"))
  )
)




# BLOC CENTRAL
body <- dashboardBody(
  shinyDashboardThemes(theme = "poor_mans_flatly"),
  tabItems(
    tabItem(
      
      "presentation",
      
      titlePanel(h1(HTML("<b>Projet de R - étude prédictive de classe salariale de la population américaine</b>"), align = "center")),
     
      div(style = "height:100px"),
      
      titlePanel(h2(HTML("<b>L'objectif</b>"))),
      
      p("Les disparités salariales au sein de la société américaine de ces dernières décennies peuvent nous amener à nous poser certaines questions. 
        Ces inégalités peuvent s'expliquer de plusieurs manières : années d'expérience, 
        sexe ou encore origine ethnique. C'est dans ce but précis que nous avions décidé d'étudier cette problématique de plus près."),
      
      p("Nous avons recueilli une base de données recueillant des informations sur de nombreux citoyens américains. La base fut extraite d'un recensement de la population américaine datant de 1994.
        Parmi ces données, il y a une variable décrivant si oui ou non la personne interrogée gagne plus ou moins de 50000 dollars par an. La problématique sera donc de créer un modèle prédictif 
        permettant de classifier les citoyens américains entre ces deux classes salariales, à partir des autres variables de la base."),
      
      p("Après avoir examiné la base de données de plus près, nous ferons le choix d'opter pour un modèle de classification supervisée par régression logistique que vous allons implémenter après avoir pris le soin de préparer les données comme il se doit."),
      
      div(style = "height:100px"),
      
      titlePanel(h2(HTML("<b>À propos</b>"))),
      
      p("Ce travail est réalisé en binôme dans le cadre de notre projet de R pour cette année universitaire. Le projet s'inscrit dans le parcours du M2 280 Ingénierie Statistique et Financière Apprentissage.
      Afin de présenter notre travail, nous avons décidé de développer un tableau de bord sous la forme d'une interface Shiny."), 
      
      p("C'est en effet l'occasion pour nous de nous initier à cet outil. Il sera aussi question de tirer profit de nombreux packages de R tels que dplyr ou caret ainsi que d'autres packages de modélisation et de visualisation."),
      
      p("Notre binôme se compose de Sid Ali Haddag (voie Finance) et de Mohamed Moudden (voie Data Science)."),
      
      div(style = "height:100px")
    
      ),
    
    tabItem(
      
      "analyse",
      
      titlePanel(h1(HTML("<b>Analyse des données</b>"), align = "center")),
      
      div(style = "height:100px"),
      
      strong("Avant de procéder à l'étape de modélisation, il est indispensable de s'assurer de la qualité des données et de dresser une première analyse descriptive des échantillons mis à notre disposition. Il s'agit d'une étape primordiale afin de mieux comprende le jeu de données et de commencer à en tirer de premières hypothèses."),
      
      div(style = "height:100px"),
      
      p("La base est d'abord recueillie sous forme de fichier .csv (Excel), puis est récupérée et stockée sous R."),
      
      p(HTML("Celle-ci est composée de 32651 observations pour 15 variables différentes, dont la variable cible <code>income</code>.
             En voici un extrait (scroller à droite pour avoir accès à toutes les variables) :")),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(style = "overflow-x: scroll;overflow-y: scroll;", width = "100%", solidHeader = TRUE, tableOutput("headTable") %>% withSpinner(color = colorSpinner))),
      
      div(style = "height:50px"),
      
      p("Parmi ces variables, nous pouvons distinguer les variables numériques des autres variables Nous pouvons en dresser un premier aperçu de ces variables 
        grâce au tableau et aux graphes de densité suivants :"),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(style = "overflow-x: scroll;overflow-y: scroll;", width = "100%", solidHeader = TRUE, tableOutput("summaryNumericTable") %>% withSpinner(color = colorSpinner))),
      
      fluidRow(style = "margin: 0px;", box(style = "overflow-x: scroll;overflow-y: scroll;", width = "100%", solidHeader = TRUE, plotOutput("numericDensityPlot") %>% withSpinner(color = colorSpinner))),
      
      div(style = "height:50px"),
      
      p(HTML("Comme son nom l'indique, la variable <code>age</code> représente l'âge des américains présents sur le questionnaire. La moyenne est située autour des 38 ans, ce qui est ni trop jeune ni trop vieux. 
        La distribution a l'air d'être elle aussi englober une tranche d'âge assez large : de 17 ans pour la personne la plus jeune à 90 ans pour les vieux vieux, distribuée autour de la moyenne de manière très régulière.")),
      
      p(HTML("La variable <code>fnlwgt</code> est assez intéressante. Il s'agit d'une variable continue symbolisant un poids, 
             qui est un nombre estimé d'individus dans la population cible que la personne en question peut représenter. Ainsi, les personnes qui partagent les mêmes caractéristiques démographiques devraient avoir des poids similaires. 
             Cette variable pourrait jouer un rôle important dans nos modèles de classification plus tard.")),
      
      p(HTML("Les variables <code>capital.gain</code> et <code>capital.loss</code>, représentant respectivement les gains et les pertes en terme de capital, sont très fortement biaisées vers des valeurs proches de zéro. À voir si 
             ces variables sont bel et bien cruciales pour la suite.")),
      
      p(HTML("<code>hours.per.week</code> représente le nombre d'heures travaillées par semaine. On remarque une très forte concentration autour des 40 heures par semaine, qui concerne la majeure partie des américains interrogés.")),
      
      p(HTML("Quant à la variable <code>education.num</code>, cette dernière mesure le niveau d'éducation de chaque individu selon une échelle prédeterminée.")),
      
      div(style = "height:50px"),
      
      p("Voici à présent deux grilles mesurant les corrélations de Pearson (lien linéaire) et de Spearman (lien monotone) entre ces différentes variables. Comme on peut le constater, les variables ne sont pas très corrélées entre elles dans les deux cas."),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(width = "100%", solidHeader = TRUE, plotOutput("correlationPearsonPlot") %>% withSpinner(color = colorSpinner), plotOutput("correlationSpearmanPlot") %>% withSpinner(color = colorSpinner))),
     
      div(style = "height:50px"),

      p(HTML("Concentrons-nous maintenant sur les autres variables. La variable <code>relationship</code> décrit la relation que l'individu partage avec le propriétaire de son lieu de vie. Les individus ayant moins de lien sont bien souvent plus jeunes que les autres.")),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(style = "overflow-x: scroll;overflow-y: scroll;", width = "100%", title = HTML("Répartition des âges, selon la relation (Householder)"), solidHeader = TRUE, plotOutput("ageRelationshipPlot") %>% withSpinner(color = colorSpinner))),
      
      div(style = "height:50px"),
      
      p(HTML("Voici l'une des observations principales à faire sur cette base. Il y a 7841 individus qui gagnent au-dessus de 50000 dollars par an, soit près du quart du nombre total des individus. On note cependant une légère tendance chez les plus riches à être plus âgés 
             en moyenne que les autres, ce qui est en soi assez compréhensible.")),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(width = "100%", title = HTML("Répartition par groupe d'âge, selon la classe salariale"), solidHeader = TRUE, plotOutput("distIncomePlot") %>% withSpinner(color = colorSpinner))),
      
      div(style = "height:50px"),
      
      p("Il y a 10771 femmes au total parmi les concernés, soit environ un tiers de la base de données. Les hommes interrogées ont aussi tendance à être un peu plus vieux que les femmes, ce qui pourrait conduire, si la richesse favorise les personnes les plus âgées, à une plus 
        grosse démarcation en terme de revenus."),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(width = "100%", title = HTML("Répartition par groupe d'âge, selon le sexe"), solidHeader = TRUE, plotOutput("distSexPlot") %>% withSpinner(color = colorSpinner))),
      
      div(style = "height:50px"),
    
      p("Enfin, il serait intéressant de voir si la différence en terme de charge de travail est si marquée que ça entre les deux classes salariales. On voit bien sur le graphique ci-dessous que les gens plus aisés travailleront en moyenne 4 à 5 heures de plus par semaine. 
        Cet écart tend même à légèrement s'élargir lorsque les travailleurs prennent de l'âge. Ainsi, les personnes qui gagnent plus que 50000 dollars par mois ont tendance à maintenir un volume hebdomadaire plus conséquent peu importe la classe d'âge."),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(width = "100%", title = HTML("Heures de travail hebdomadaires"), solidHeader = TRUE, plotOutput("hoursPerWeekPlot") %>% withSpinner(color = colorSpinner))),
      
      div(style = "height:50px"),
      
      p(HTML("Parmi les autres variables catégorielles, on peut citer <code>native.country</code> indiquant le pays d'origine de chaque individu, <code>workclass</code> décrivant la catégorie socioprofessionnelle, <code>race</code> indiquant l'origine ethnique 
             et montrant par ailleurs une large représentation des personnes blanches. <code>education</code> liste les différents grades du système éducatif américain, et <code>marital.status</code> la situation amoureuse.")),

      div(style = "height:100px"),
      
      strong("Maintenant que vous avons étudié les différentes observations, il faut passer à la phase de préparation des données."),
      
      div(style = "height:100px")
      
    ),
    tabItem(
      
      "preparation",
      
      titlePanel(h1(HTML("<b>Préparation des données</b>"), align = "center")),
      
      div(style = "height:100px"),
      
      strong(HTML("En début de page précédente, il est possible de voir que certaines valeurs de la base de donnés sont indéfinis (NA). Afin de pouvoir poursuivre à la phase de modélisation, 
             il est impératif de prendre une décision sur la manière dont ces données manquantes vont être traitées. De plus, on peut d'ores et déjà commencer à modifier certaines variables afin qu'elles soit mieux interprétés plus tard, notamment en transformant toutes les variables de type <code>character</code> en <code>factor</code>.")),
      
      div(style = "height:100px"),
      
      p(HTML("Parmi les variables du dataset, la variable <code>native.country</code> se démarque par un très grand nombre de facteurs. Ainsi, dans un contexte de régresson logistique, préserver cette variable pourrait mener rapidement à de l'overfitting.")),
      p(HTML("Afin de pallier à ce problème, cette variable est mise de côté et les différents pays sont groupés dans une nouvelle variable <code>native.region</code> par zone géographique : Europe de l'ouest, Europe de l'est, Asie centrale, Asie de l'est, États-Unis, Amérique centrale et Amérique du sud.")),
      
      div(style = "height:50px"),
      
      p("Parmi les valeurs NA de la base de données, voici les trois variables qui les contient à présent :"),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;overflow-x: scroll;overflow-y: scroll;", box(width = "100%", solidHeader = TRUE, tableOutput("naTable") %>% withSpinner(color = colorSpinner))),
      
      div(style = "height:50px"),
      
      p(HTML("Plus précisément, comme le montre le graphique suivant, les facteurs <code>workclass</code> et <code>occupation</code> partagent à peu de choses près les mêmes observations incomplètes.")),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(width = "100%", title = HTML("Répartition des valeurs manquantes"), solidHeader = TRUE, plotOutput("missingPlot") %>% withSpinner(color = colorSpinner))),
   
      div(style = "height:50px"),
      
      p(HTML("Il serait alors judicieux de penser que ce manque de données est en lui-même une source d'information potentielle. 
             Il serait possible de générér une nouvelle variable binaire indiquant pour chaque observation si oui ou non ces deux facteurs sont manquants. Ainsi, on pourrait mesurer l'impact de ce manque sur le résultat final.")),
      
      p(HTML("Néanmoins, pour des soucis de simplicité, nous décidons finalement de combler ces valeurs manquantes à l'aide du package <code>mice</code> par <i>appariement prédictif des moyennes</i>, ou en anglais par <i>predictive mean matching</i> (pmm). 
        D'autres méthodes plus élaborées peuvent être employées, mais celles-ci seront bien plus lentes à l'exécution.")),
      
      div(style = "height:50px"),
      
      p(HTML("La variable cible est quant à elle transformée en variable facteur, et le facteur <code>education</code> passe en facteur ordonné pour plus de lisibilité.")),
      
      div(style = "height:100px"),
      
      strong("Comme il s'agit d'un problème de classification supervisée, nous avons ainsi décidé d'appliquer un modèle de régression logistique."),
      
      div(style = "height:100px"),
      
      ),
    
    tabItem(
      
      "logistique",
      
      titlePanel(h1(HTML("<b>Régression logistique</b>"), align = "center")),
      
      div(style = "height:100px"),
      
      strong("La régression logistique est une méthode de classification supervisée visant à exprimer une variable cible qualitative à partir d'un ensemble de variables explicatives.
        Dans notre cas, nous avons décidé de passer par une méthode de validation croisée."),
      
      div(style = "height:100px"),
      
      p("L'avantage de la validation croisée est qu'elle permet de mesurer les performances de notre modèle avec les paramètres spécifiés dans un espace de données plus grand. 
        Autrement dit, la validation croisée utilise la totalité du jeu de données d'entraînement pour l'entraînement ET l'évaluation, au lieu d'une partie seulement."),
      
      p(HTML("Plus particulièrement, nous avons opté pour une validation croisée à k-blocs, ou k-folds en anglais, avec k = 10, et ce en passant par le package <code>caret</code>. ")),
      
      p("Comme choix d'échantillonage, nous sommes partis sur une partition de 80% en jeu de données d'entraînement et 20% de jeu de données de test."),
      
      div(style = "height:50px"),
      
      column(1, align = "left", actionButton("numb", label = "Lancer la modélisation")),
      
      div(style = "height:50px"),
      
      p("Comme la modélisation prend un certain temps, en raison notamment de la validation croisée, il faudra patienter quelques instants avant l'apparition des résultats."),
     
       div(style = "height:50px"),
      
      
      fluidRow(style = "margin: 0px;", box(
        title = "Matrice de confusion",
        status = "primary", solidHeader = F,
        width = 12,
        column(12, align = "center", plotOutput("confusionPlot") %>% withSpinner(color = colorSpinner))
      )),
      
      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(
        title = "Statistiques de prédiction",
        status = "primary", solidHeader = F,
        width = 12,
        column(12, align = "center", tableOutput("totalResults") %>% withSpinner(color = colorSpinner))
      )),
      strong("Accuracy : 0.8543"),
      
      div(style = "height:50px"),
      
      p("Sur la matrice de confusion (mesurant les proportions globales et relatives aux lignes et colonnes respectives) et sur les statistiques de prédiction sur la console, 
        on peut s'apercevoir d'une précision de 0,8543, ce qui est très correct."),

      div(style = "height:50px"),
      
      fluidRow(style = "margin: 0px;", box(
        title = "Importance des variables",
        status = "primary", solidHeader = F,
        width = 12,
        column(12, align = "center", plotOutput("varImportance") %>% withSpinner(color = colorSpinner))
      )),
      
      div(style = "height:50px"),
      
      p(HTML("L'histogramme ci-dessus répertorie les vingt classes les plus influentes sur les résultats. 
             Nous avons en premier les variables <code>capital.gain</code>, <code>hours.per.week</code> et <code>capital.loss</code>, suivi par <code>age</code>.")),
      
      p("Ainsi, les variables numériques ont une importance capitale dans les résultats de notre modèle prédictif."),
      
      div(style = "height:100px"),
      
      strong("Pour aller plus loin, il est possible de refaire une régression logistique en supprimant les facteurs les moins influents par exemple."),
      
      strong("D'autres modèles de classification peuvent aussi être étudiés, tels que les forêts aléatoires ou les méthodes de clustering comme les K-plus proches voisins."),

      div(style = "height:100px"),
      
      h2("Merci pour votre attention.", align = "center")
      
      
      
      
      # fluidRow(style = "margin: 0px;overflow-x: scroll;overflow-y: scroll;", box( width = "100%", solidHeader = TRUE, plotOutput("logisticRegression") %>% withSpinner(color = colorSpinner))),
    )
  )
)



# INTERFACE COMPLETE
shinyUI(dashboardPage(header, sidebar, body, tags$head(tags$style(HTML('* {font-family: "Arial"};')))))
