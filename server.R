# Lien avec le fichier global
source("./global.R")




### PARTIE SERVEUR
shinyServer(function(input, output) {




  # Tableau descriptif des variables numériques
  output$summaryNumericTable <- renderTable(
    {
      summary <- skim(select_if(dataset_raw, is.numeric)) %>% select(-skim_type, -n_missing, -complete_rate)
      names(summary) <- c("Variable", "Mean", "S.d.", "Min", "25%", "Median", "75%", "Max", "Histogram")
      return(summary)
    },
    striped = TRUE,
    bordered = TRUE,
    align = "c"
  )
  
  

  # Tableau descriptif des premières lignes de la base de données
  output$headTable <- renderTable(
    {
      head(dataset_raw)
    },
    striped = TRUE,
    bordered = TRUE,
    align = "c"
  )

  
  # Graphique en vagues entre relation et age
  output$ageRelationshipPlot <- renderPlot({
    ggplot(dataset_raw, aes(x = age, y = relationship)) +
      geom_density_ridges(fill = "#b02920", color = "#631813", alpha = 0.7)
  })


  # Histogramme de la distribution de l'âge regroupée par classe salariale, avec courbe de densité
  output$distIncomePlot <- renderPlot({
    ggplot(dataset_raw, aes(x = age, group = income, fill = income)) +
      geom_histogram(binwidth = 1, color = "white", position = "identity", alpha = 1) +
      geom_density(aes(y = ..count..), alpha = 0.2, lwd = 1) +
      xlim(range(density(dataset_raw$age)$x))
  })


  # Histogramme en pyramide de la répartition par âge selon le sexe, avec courbe de densité
  output$distSexPlot <- renderPlot({
    # generate bins based on input$bins from ui.R
    ggplot(dataset_raw) +
      aes(x = age, fill = sex) +
      geom_bar(data = subset(dataset_raw, sex == "Female"), colour = "white", position = "identity", mapping = aes(y = ..count..), alpha = 1) +
      geom_density(data = subset(dataset_raw, sex == "Female"), aes(y = ..count..), alpha = 0.2, lwd = 1, fill = "#ff597a", colour = "#ff597a") +
      xlim(range(density(dataset_raw$age)$x)) +
      geom_bar(
        data = subset(dataset_raw, sex == "Male"),
        mapping = aes(y = -..count..),
        position = "identity", alpha = 1, colour = "white"
      ) +
      geom_density(data = subset(dataset_raw, sex == "Male"), aes(y = -..count..), alpha = 0.2, lwd = 1, fill = "#366fff", colour = "#366fff") +
      scale_fill_manual(values = colorPaletteSex) +
      xlim(range(density(dataset_raw$age)$x)) +
      scale_y_continuous(labels = abs) +
      coord_flip()
  })


  # Volume horaire de travail hebdomadaire en fonction de l'âge, regroupé par classe salariale
  output$hoursPerWeekPlot <- renderPlot({
    ggplot(dataset_raw, aes(x = age, y = hours.per.week, color = income)) +
      geom_point(size = 1, shape = 3) +
      geom_smooth() +
      ylab("hours per week") +
      xlab("age")
  })

  
  # Régression logistique
  logReg <- eventReactive(input$numb, {
    sample <- sample.split(dataset_fin$income, SplitRatio = 0.8)

    x_train <- subset(dataset_fin, sample == TRUE)
    x_test <- subset(dataset_fin, sample == FALSE)
    y_train <- x_train$income
    y_test <- x_test$income
    x_train$income <- NULL
    x_test$income <- NULL

    crossVal <- createMultiFolds(y_train, k = 10, times = 2)
    ctrlParam <- trainControl(method = "repeatedcv", number = 10, repeats = 2, index = crossVal)

    logistic <- train(x = x_train, y = y_train, method = "glm", family = "binomial", trControl = ctrlParam)

    y_predicted <- predict(logistic, x_test)

    confusionTable <- tibble(data.frame(Orig = y_test, Pred = y_predicted))

    confusionMatrix(table(Orig = y_test, Pred = y_predicted), positive = ">50K")
    
    Criteria <- confusionMatrix(table(Orig = y_test, Pred = y_predicted), positive = ">50K")$byClass

    confusionPlot <- plot_confusion_matrix(as_tibble(table(tibble(Orig = y_test, Pred = y_predicted))),
      target_col = "Orig",
      prediction_col = "Pred",
      counts_col = "n"
    )
    variableImportance <- dataFrameCleaner(data.frame(as.matrix(varImp(logistic)$importance)), "Variable", "Importance")


    list(confusionTable = confusionTable, Criteria = Criteria, confusionPlot = confusionPlot, variableImportance = variableImportance)
  })

  # Matrice de confusion
  output$confusionPlot <- renderPlot({
    logReg()$confusionPlot
  })

  # Résultats globaux de la régression 
  output$totalResults <- renderTable({
    dataFrameCleaner(data.frame(logReg()$Criteria), "Measure", "Value")
  })

  # Importance des variables
  output$varImportance <- renderPlot({
    importanceTable <- logReg()$variableImportance
    importanceTable$Variable <- as.factor(importanceTable$Variable)
    importanceTable <- arrange(importanceTable, desc(Importance))
    importanceTable <- importanceTable[1:20, ]
    ggplot(importanceTable, aes(x = fct_reorder(Variable, Importance), y = Importance)) +
      geom_col(fill = "salmon") +
      coord_flip() +
      xlab("Variable")
  })


  # NON-UTILISE --- Histogramme du nombre de personnes interrogées par groupe ethnique ("race" selon la classificaiton américaine), regroupé par sexe
  output$racePlot <- renderPlot({
    dataset_raw$race <- reorder(dataset_raw$race, dataset_raw$race, length)

    ggplot(dataset_raw, aes(x = race, group = sex, fill = sex)) +
      geom_bar(position = "dodge") +
      geom_text(stat = "count", aes(label = ..count..), face = "bold", size = 4, position = position_dodge(.9), hjust = -0.3) +
      scale_fill_manual(values = colorPaletteSex) +
      ggtitle(" ") +
      coord_flip() +
      ylim(0, 22000)
  })


  # Tableau des valeurs NA
  output$naTable <- renderTable(
    {
      tbl <- data.frame(colSums(is.na(dataset)))
      return(t(tbl %>% filter(tbl != 0)))
    },
    striped = TRUE,
    bordered = TRUE,
    align = "c"
  )


  # Graphes de densité groupés pour les variables numériques
  output$numericDensityPlot <- renderPlot({
    dataset %>%
      select(-income) %>%
      keep(is.numeric) %>% # Keep only numeric columns
      gather() %>% # Convert to key-value pairs
      ggplot(aes(value, color = "orange")) + # Plot the values
      facet_wrap(~key, scales = "free") + # In separate panels
      geom_density() +
      theme(legend.position = "none")
  })

 
  # Tableau de corrélation de Pearson
  output$correlationPearsonPlot <- renderPlot({
    corrplot(cor(dataset %>% select_if(is.numeric), method = c("pearson")), method = "color", addCoef.col = "black", diag = FALSE, tl.col = rep("black", 7)) +
      theme(text = element_text(color = "black"))
  }) 
  
  
  # Tableau de corrélation de Spearman
  output$correlationSpearmanPlot <- renderPlot({
    corrplot(cor(dataset %>% select_if(is.numeric), method = c("spearman")), method = "color", addCoef.col = "black", diag = FALSE, tl.col = rep("black", 7)) +
      theme(text = element_text(color = "black"))
  })

  
  # Graphe des valeurs manquantes
  output$missingPlot <- renderPlot({
    visdat::vis_miss(dataset %>% select(workclass, occupation, native.region)) +
      scale_fill_manual(values = c("#292929", "#ff0000"), name = "", labels = c("Factor", "NA")) +
      theme(
        text = element_text(color = "black"), legend.key.size = unit(1, "cm"),
        legend.key.height = unit(1, "cm"),
        legend.key.width = unit(1, "cm"),
        legend.text = element_text(size = 12),
        axis.title = element_text(size = 12),
        axis.text.y = element_text(margin = margin(-15, 0, 0, 0), color = "black", size = 12)
      ) +
      coord_flip()
  })

  
  # Paramètres favorisant le chargement des tableaux en arrière-plan
  outputOptions(output, "headTable", suspendWhenHidden = FALSE)
  outputOptions(output, "naTable", suspendWhenHidden = FALSE)
  outputOptions(output, "summaryNumericTable", suspendWhenHidden = FALSE)
  
  
  
  
  
})
