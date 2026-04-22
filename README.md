# Satisfaction Score Prediction

Predicting student satisfaction scores (0-10) using linear regression and random forest, with EDA uncovering a hidden pattern that beat both baseline models.

## Dataset
Private course dataset containing student personality type, test scores, age, and test date.

## Overview
The goal was to predict a student's satisfaction score given a handful of features. The interesting part was not the modeling itself but finding a pattern in the data that no obvious feature captured directly, then engineering a variable around it.

## Key Finding
Introverts on specific dates had dramatically lower satisfaction scores, averaging **4.52 vs. 8.55** on normal days. Extroverts on those same dates were completely unaffected. Engineering an `is_bad_day` feature to capture this interaction was the biggest driver of model improvement.

## Results
| Model | RMSE |
|---|---|
| Linear Regression (base) | 1.118 |
| Random Forest | 1.111 |
| Linear Regression + `is_bad_day` | **1.002** |

> The engineered feature beat random forest despite being a simpler model.

## Features
- `is_extrovert` - binary encoding of personality type
- `testScore` - raw test score
- `is_bad_day` - 1 if the student is an Introvert on one of 7 identified low-scoring dates, 0 otherwise
- Tested month, day, year, and age, all had near-zero correlation with satisfaction score

## Methods
- EDA with correlation checks and `tapply` aggregations
- 80/20 cross-validation split
- Linear regression vs. random forest comparison
- Predictions clipped to [0, 10] and rounded to 1 decimal

## Tech Stack
**Language:** R  
**Libraries:** `randomForest`

## Files
- `PredictionChallenge1.R` - full code with comments
