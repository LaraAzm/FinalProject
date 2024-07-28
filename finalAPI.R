#library read in
library(readr)
library(readxl)
library(caret)
library(ranger)

#reading in the csv 
model_data <- read_csv("./data/diabetes_data.csv")

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
                     mtry = seq(1:6))

#copying in the winning model
trainctrl <- trainControl(method = "cv", 
                          number = 5, 
                          summaryFunction = mnLogLoss, 
                          classProbs = TRUE)

final_model <- train(Diabetes_binary ~ AnyHealthcare + NoDocbcCost + Education + Income + MentHlth + PhysHlth, 
                   data = model_train, 
                   method = "ranger",
                   preProcess = c("center", "scale"),
                   tuneGrid = final_mtry,
                   num.tree = 50,
                   trControl = trainctrl)

#run the model once
predict(final_model,model_test)

library(plumber)

#* @apiTitle Final Project Diabetes Data API
#* @apiDescription This is the API accompanying the rest of my final project.

#* @param AnyHealthcare Health care status of the subject (select from: No, Yes)
#* @param NoDocbcCost Did not go to the doctor due cost (select from: No, Yes)
#* @param Education Subject's education level (select from: None, Elementary, Middle.School, High.School, Some.or.Technnical.College, College.Graduate)
#* @param Income Subject's annual income (select from: 10000, 15000, 20000, 25000, 35000, 50000, 75000, 75000.plus)
#* @param MentHlth Number of days of bad mental health (default: variable mean of 3.185)
#* @param PhysHlth Number of days of bad physical health (default: variable mean of 4.242)
#* @get /pred
get_diabetes_predict <- function(AnyHealthcare = "Yes", NoDocbcCost = "No", Education = "College.Graduate", Income = "75000.plus", MentHlth = 3.185, PhysHlth = 4.242){
  # convert the inputs to factor
  HC <- factor(AnyHealthcare,levels = c("No","Yes"))
  Docost <- factor(NoDocbcCost,levels = c("No","Yes"))
  Edu <- factor(Education,levels = c("None", "Elementary", "Middle.School", "High.School", "Some.or.Technnical.College", "College.Graduate"))
  Inc <- factor(Income,levels = c("10000", "15000", "20000", "25000", "35000", "50000", "75000", "75000.plus"))
  #convert the numeric input to numeric
  MH <- as.numeric(MentHlth)
  PH <- as.numeric(PhysHlth)
  # create the prediction data frame
  input <- data.frame(AnyHealthcare = HC, NoDocbcCost = Docost, Education = Edu, Income = Inc, MentHlth = as.numeric(MH), PhysHlth = as.numeric(PH))
  # create the prediction
  predict(final_model,input)
}

#http://localhost:PORT/pred?AnyHealthcare=No&NoDocbcCost=No&Education=None&Income=75000&MentHlth=0&PhysHlth=30

#http://localhost:PORT/pred?AnyHealthcare=No&NoDocbcCost=Yes&Education=High.School&Income=20000&MentHlth=0&PhysHlth=15

#http://localhost:PORT/pred?AnyHealthcare=No&NoDocbcCost=No&Education=High.School&Income=15000&MentHlth=30&PhysHlth=30

#* Information for the API
#* @get /info
info <- function(){
  name <- "Laraib Azmat"
  url <- "https://laraazm.github.io/FinalProject/"
  infor <- c(name, url)
  print(infor)
}

#http://localhost:PORT/info
