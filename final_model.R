#library read in
library(readr)
library(readxl)
library(dplyr)
library(tidyverse)
library(caret)
library(ranger)

#reading in the csv 
data <- read_csv("./data/diabetes_data.csv")

#selecting the wanted variables and chnaging them to factor as the csv lost the factor setting
model_data <- data |>
  select(Diabetes_binary, AnyHealthcare, NoDocbcCost, MentHlth) |>
  mutate(across(where(is_character), as_factor))

#setting seed for reproducibility
set.seed(1234)

#setting up to split the data into two for later use as training and testing 
train <- sample(1:nrow(model_data), size = nrow(model_data)*0.7)
test <- setdiff(1:nrow(model_data), train)

#subsetting the data set
model_train <- model_data[train, ]
model_test <- model_data[test, ]

#building mtry
final_mtry <- expand.grid(splitrule="extratrees",
                     min.node.size=100,
                     mtry = seq(1:3))

#copying in the winning model
trainctrl <- trainControl(method = "cv", 
                          number = 5, 
                          summaryFunction = mnLogLoss, 
                          classProbs = TRUE)

final_model <- train(Diabetes_binary ~ AnyHealthcare + NoDocbcCost + MentHlth, 
                   data = model_train, 
                   method = "ranger",
                   preProcess = c("center", "scale"),
                   tuneGrid = final_mtry,
                   ntree = 100,
                   trControl = trainctrl)

#run the model once
predict(final_model,model_test)

library(plumber)

#* @apiTitle Final Project Diabetes Data API
#* @apiDescription This is the API accompanying the rest of my final project.

#* @param AnyHealthcare Health care status of the subject (default: Yes)
#* @param NoDocbcCost Did not go to the doctor due cost (default: No)
#* @param MentHlth number of days of bad mental health (default: variable mean of 3.185)
#* @get /pred
get_diabetes_predict <- function(AnyHealthcare = "Yes", NoDocbcCost = "No", MentHlth = 3.185){
  # convert the inputs to factor
  AnyHealthcare <- factor(AnyHealthcare,levels = c("No","Yes"))
  NoDocbcCost <- factor(NoDocbcCost,levels = c("No","Yes"))
  #convert the numeric input to numeric
  MentHlth <- as.numeric(MentHlth)
  # create the prediction data frame
  input <- data.frame(AnyHealthcare, NoDocbcCost, MentHlth = as.numeric(MentHlth))
  # create the prediction
  predict(final_model,input)
}

example_1 <- '/pred?AnyHealthcare=No&NoDocbcCost=No&MentHlth=0'
example_2 <- '/pred?AnyHealthcare=Yes&NoDocbcCost=Yes&MentHlth=14'
example_3 <- '/pred?AnyHealthcare=Yes&NoDocbcCost=Yes&MentHlth=30'

#* Information for the API
#* @post /info
info <- function(){
  name <- "Laraib Azmat"
  url <- "https://laraazm.github.io/FinalProject/"
  infor <- c(name, url)
  print(infor)
}