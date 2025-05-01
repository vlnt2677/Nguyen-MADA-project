# analysis-code

This folder contains  a QMD file containing the main analysis of this project. In this file, data is engineered and fit into various models (LASSO, RF, XGBoost). The file also plots and creates a table with some diagnostic information relating to model performance.

The analysis code is large so the following line breaks down some of the structure of it in order:

1) Loading of data and libraries
2) Creation of lagged predictors
3) Implementation of rolling window CV
4) Recipe Setting
5) LASSO Model Fitting (Base, Mobility, Lagged Mobility)
6) Graphing predicted vs actual results
7) RF Model Fitting and Tuning (Base, Mobility, Lagged Mobility)
8) Graphing predicted vs actual results
9) XGBoost Model Fitting and Tuning (Base, Mobility, Lagged Mobility)
10) Graphing predicted vs actual results
11) Condensing results into final data frame
12) Creation of final model results table

Any model fitting requires 1, 2, 3, and 4 to be run prior. Additionally, 11 and 12 are dependent on all code being run previously. Parts 7-9 take hours to complete.

Note: The model fitting is very computationally expensive and can take hours to run. In some instances, the file may freeze your computer.