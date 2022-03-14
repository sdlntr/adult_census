library(rsconnect)

### PACKAGES SHINY ET INTERFACE
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(dashboardthemes)
library(thematic)

### PACKAGES DE PROCESSING DES DONNEES
library(tidyverse)
library(dplyr)
library(scales)
library(reshape2)
library(corrplot)
library(mice)
library(caret)
library(caTools)

### PACKAGES DE VISUALIATION DES DONNEES
library(treemapify)
library(ggplot2)
library(ggridges)
library(skimr)
library(yardstick)
library(cvms)
library(tibble)



### FONCTION  PERMETTANT DE FORMER UN DATA FRAME COHERENT A PARTIR DES DONNEES BRUTES ISSUES DE LA MODELISATION
dataFrameCleaner <- function(df, col1, col2) {
  df <- cbind(newColName = rownames(df), df)
  rownames(df) <- 1:nrow(df)
  colnames(df) <- c(col1, col2)
  return(df)
}


thematic_shiny()
set.seed(101)


### PARAMETRES DE COULEURS
colorSpinner <- "#2e4588"
colorPaletteSex <- c("Female" = "#ff597a", "Male" = "#366fff")


### REGIONS
East_Asia <- c("Cambodia", "China", "Hong", "Laos", "Thailand", "Japan", "Taiwan", "Vietnam")
Central_Asia <- c("India", "Iran")
Central_America <- c("Cuba", "Guatemala", "Jamaica", "Nicaragua", "Puerto-Rico", "Dominican-Republic", "El-Salvador", "Haiti", "Honduras", "Mexico", "Trinadad&Tobago")
South_America <- c("Ecuador", "Peru", "Columbia")
Western_Europe <- c("England", "Germany", "Holand-Netherlands", "Ireland", "France", "Greece", "Italy", "Portugal", "Scotland")
Eastern_Europe <- c("Poland", "Yugoslavia", "Hungary")


### MANIPULATION DES DONNEES


dataset_raw <- read_csv("https://github.com/sdlntr/adult_census/raw/main/adult.csv")
dataset_raw[dataset_raw == "?"] <- NA
# Passage des ? aux NA
dataset <- dataset_raw


# Passage des variables en chaîne de caractère à des variables à facteur
dataset <- dataset %>% mutate_if(is.character, as.factor)


# Variable target binaire
dataset$income <- as.factor(dataset$income)


# Passage de la variable 'education' à une variable ordinale (décrivant les niveaux graduels d'éducation)
dataset$education <- ordered(dataset$education, levels = c("Preschool", "1st-4th", "5th-6th", "7th-8th", "9th", "10th", "11th", "12th", "HS-grad", "Prof-school", "Assoc-acdm", "Assoc-voc", "Some-college", "Bachelors", "Masters", "Doctorate"))


# Classement par zone géographique
dataset <- mutate(dataset,
  native.region =
    ifelse(native.country %in% East_Asia, "East-Asia",
      ifelse(native.country %in% Central_Asia, "Central-Asia",
        ifelse(native.country %in% Central_America, "Central-America",
          ifelse(native.country %in% South_America, "South-America",
            ifelse(native.country %in% Western_Europe, "Europe-West",
              ifelse(native.country %in% Eastern_Europe, "Europe-East",
                ifelse(native.country == "United-States", "United-States",
                  "Outlying-US"
                )
              )
            )
          )
        )
      )
    )
)

#On met de côté l'ancienne variable
dataset <- dataset %>% select(-native.country)
dataset$native.region <- as.factor(dataset$native.region)


#REMPLISSAGE DES VALEURS NA
dataset_fin <- complete(mice(dataset, m = 1, method = "pmm"))

 