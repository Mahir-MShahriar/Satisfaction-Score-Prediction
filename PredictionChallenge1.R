setwd("C:/Users/ninja/Documents/Data 101/Prediction Challenge1")
train <- read.csv("JBTrain.csv")
test <- read.csv("JBTest-students.csv")
summary(train)

tapply(train$satisfactionScore, train$personality, mean)
train$is_extrovert <- as.integer(train$personality == "Extrovert")
test$is_extrovert <- as.integer(test$personality == "Extrovert")
cor(train$satisfactionScore, train$is_extrovert)
cor(train$satisfactionScore, train$testScore) #weak score
cor(train$satisfactionScore, train$age)#near 0

#Check weird things like month, day, year
train$month <- as.numeric(format(as.Date(train$testDate, format="%Y-%m-%d"), "%m"))
train$day <- as.numeric(format(as.Date(train$testDate, format="%Y-%m-%d"), "%d"))
train$year <- as.numeric(format(as.Date(train$testDate, format="%Y-%m-%d"), "%y"))
cor(train$satisfactionScore, train$month)
cor(train$satisfactionScore, train$day)
cor(train$satisfactionScore, train$year)
#All basically near 0

tapply(train$satisfactionScore[train$personality == "Introvert"], 
       cut(train$age[train$personality == "Introvert"], breaks=5), mean)
tapply(train$satisfactionScore[train$personality == "Extrovert"], 
       cut(train$age[train$personality == "Extrovert"], breaks=5), mean)
#Extroverts have an average of 9.59 satisfaction score vs introverts at 7.72


boxplot(satisfactionScore ~ personality, data = train,
        main = "Score by Personality",
        xlab = "Personality", ylab = "Satisfaction Score",
        col = c("lightblue", "lightgreen"))

plot(train$testScore, train$satisfactionScore,
     col = ifelse(train$personality == "Extrovert", "blue", "red"),
     main = "Test Score vs Satisfaction Score",
     xlab = "Test Score", ylab = "Satisfaction Score")
#At 10 they are all mainly extroverts as shown by the plot

table(round(train$satisfactionScore, 1))
table(train$personality[train$satisfactionScore == 10])
#1295 extroverts and 162 introverts at 10

#Low satisfaction outliers are all introverts on specific dates
train[train$satisfactionScore < 5, ]
low_intro <- train[train$satisfactionScore < 5 & train$personality == "Introvert", ]
table(low_intro$testDate)

#Check average satisfaction for introverts by date
intro <- train[train$personality == "Introvert", ]
tapply(intro$satisfactionScore, intro$testDate, mean)

#There are just some bad days where the mean score is less than 6

bad_days <- c("2024-07-05", "2024-09-16", "2024-04-07", 
               "2024-02-29", "2024-08-24", "2024-06-28", "2024-05-02")
ext <- train[train$personality == "Extrovert", ]
tapply(ext$satisfactionScore, ext$testDate, mean)

#Extroverts on those same bad dates are fine nothing lower than like 8

train$is_bad_day <- as.integer(train$personality == "Introvert" & train$testDate %in% bad_days)
test$is_bad_day <- as.integer(test$personality == "Introvert" & test$testDate %in% bad_days)
tapply(train$satisfactionScore, train$is_bad_day, mean)

#on a bad daym an introvert on a bad date average score goes from 8.55 to 4.52

set.seed(1)
index <- sample(1:nrow(train), 0.8 * nrow(train))
train_cv <- train[index, ]
valid_cv <- train[-index, ]
model_lm <- lm(satisfactionScore ~ is_extrovert + testScore, data = train_cv)
pred_lm <- predict(model_lm, valid_cv)
sqrt(mean((valid_cv$satisfactionScore - pred_lm)^2))

#RMSE: 1.118

#Ranom Forest RMSE: 1.111
library(randomForest)
set.seed(1)
rf_cv <- randomForest(satisfactionScore ~ is_extrovert + testScore + age, 
                      data = train_cv, ntree=100)
pred_rf <- predict(rf_cv, valid_cv)
sqrt(mean((valid_cv$satisfactionScore - pred_rf)^2))

#Linear but with bad day included RMSE: 1.002
model_lm2 <- lm(satisfactionScore ~ is_extrovert + testScore + is_bad_day, data = train_cv)
pred_lm2 <- predict(model_lm2, valid_cv)
sqrt(mean((valid_cv$satisfactionScore - pred_lm2)^2))
summary(model_lm2)

final_lm <- lm(satisfactionScore ~ is_extrovert + testScore + is_bad_day, data = train)
predictions <- predict(final_lm, test)
predictions <- pmin(predictions, 10)
predictions <- pmax(predictions, 0)
predictions <- round(predictions * 10) / 10

submission <- read.csv("submission.csv")
submission <- data.frame(testId = test$testId, satisfactionScore = predictions)
write.csv(submission, "submission.csv", row.names = FALSE)
checkfile <- read.csv("submission.csv")
head(checkfile)
nrow(checkfile)

