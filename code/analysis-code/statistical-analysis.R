###############################
# analysis script
#
#this script loads the processed, cleaned data, does a simple analysis
#and saves the results to the results folder

#load needed packages. make sure they are installed.
library(ggplot2) #for plotting
library(broom) #for cleaning up output from lm()
library(here) #for data loading/saving
library(glmnet)
library(MASS)

#path to data
#note the use of the here() package and not absolute paths
data_location <- here::here("data","processed-data","processeddata.rds")

#load data. 
data <- readRDS(data_location)

# NOTES TO SELF
# - change to QMD file (personally prefer)
# - work on other analysis (lag-time & quarantine fatigue? more research)
# - work on inclusion of county health ranking data or possibly not include at all? lots of mismatch counties between datasets



######################################
#Data fitting/statistical analysis
######################################

############################
#### Initial model fitting

# Some quick data fixing before analysis as some models cannot handle negatives (contextually ok, more interested in NEW cases)
data_clean <- data
data_clean$new_cases[data_clean$new_cases < 0] <- 0


# first Negative Binomial Model
nb_model_1 <- glm.nb(new_cases ~ population_count + transit_stations_percent_change_from_baseline + 
                     parks_percent_change_from_baseline + 
                     retail_and_recreation_percent_change_from_baseline + 
                     grocery_and_pharmacy_percent_change_from_baseline +
                     workplaces_percent_change_from_baseline + 
                     residential_percent_change_from_baseline +
                     population_count, 
                   data = data_clean)

# View summary
summary(nb_model_1)

# Poisson regression model based on the same formula
poisson_model_1 <- glm(new_cases ~ transit_stations_percent_change_from_baseline + 
                       parks_percent_change_from_baseline + 
                       retail_and_recreation_percent_change_from_baseline + 
                       grocery_and_pharmacy_percent_change_from_baseline +
                       workplaces_percent_change_from_baseline + 
                       residential_percent_change_from_baseline +
                       population_count, 
                     data = data_clean, family = poisson(link = "log"))

# View the summary of the Poisson model
summary(poisson_model_1)

# Linear regression model based on the same formula
linear_model_1 <- lm(new_cases ~ transit_stations_percent_change_from_baseline + 
                     parks_percent_change_from_baseline + 
                     retail_and_recreation_percent_change_from_baseline + 
                     grocery_and_pharmacy_percent_change_from_baseline +
                     workplaces_percent_change_from_baseline + 
                     residential_percent_change_from_baseline +
                     population count, 
                   data = data_clean)

# View the summary of the Linear model
summary(linear_model_1)
aic_linear <- AIC(linear_model_1)
print(aic_linear)



# Lasso for Poisson Model
# Cannot seem to find a way (even ChatGPT could not) to apply lasso  to Negative Binomial
# Now create the model matrix and response variable
x <- model.matrix(new_cases ~ transit_stations_percent_change_from_baseline +
                    parks_percent_change_from_baseline +
                    retail_and_recreation_percent_change_from_baseline +
                    grocery_and_pharmacy_percent_change_from_baseline +
                    workplaces_percent_change_from_baseline +
                    residential_percent_change_from_baseline +
                    population_count, data = data_clean)[, -1]
y <- data_clean$new_cases

# 
lasso_model <- cv.glmnet(x, y, alpha = 1, family = "poisson")
best_lambda <- lasso_model$lambda.min
print(best_lambda)


final_lasso_model <- glmnet(x, y, alpha = 1, family = "poisson", lambda = best_lambda)

# View the coefficients
coef(final_lasso_model)


# Calculate AIC for Lasso model (using the final model with best lambda)
n <- length(y)  # number of observations
log_likelihood <- -lasso_model$cvm[which.min(lasso_model$cvm)]  # log-likelihood
p <- sum(coef(final_lasso_model) != 0)  # number of non-zero coefficients (features selected)

aic <- 2 * p - 2 * log_likelihood
print(aic)

# Predictions
y_pred <- predict(final_lasso_model, newx = x, type = "response")

# Compute RMSE
rmse <- sqrt(mean((y_pred - y)^2))
print(rmse)


# -----------------------------------------------------------------------------------------------
# With the help of ChatGPT, performed a time-series cross validation on a negative bionmial model

# Number of folds
k <- 10
set.seed(123)  # For reproducibility

# Define the time window for cross-validation (rolling or expanding)
fold_size <- floor(nrow(data_clean) / k)

# Initialize vector to store RMSE (or another metric) for each fold
rmse_values <- numeric(k)

# Rolling time-series cross-validation
for (i in 1:k) {
  # Define the training and test periods based on fold
  train_start <- 1
  train_end <- i * fold_size  # Expanding window
  
  # Use a rolling window (train_end <- (i-1) * fold_size + fold_size)
  test_start <- train_end + 1
  test_end <- min((i + 1) * fold_size, nrow(data_clean))  # Ensure last fold doesn't go out of bounds
  
  # Create training and testing sets
  train_data <- data_clean[train_start:train_end, ]
  test_data <- data_clean[test_start:test_end, ]
  
  # Fit model on the training set
  nb_model <- glm.nb(new_cases ~ transit_stations_percent_change_from_baseline +
                       parks_percent_change_from_baseline +
                       retail_and_recreation_percent_change_from_baseline +
                       grocery_and_pharmacy_percent_change_from_baseline +
                       workplaces_percent_change_from_baseline +
                       residential_percent_change_from_baseline +
                       population_count +
                       uninsured_rate,
                     data = train_data)
  
  # Make predictions on the test set
  predictions <- predict(nb_model, newdata = test_data, type = "response")
  
  # Calculate RMSE (root mean squared error) for this fold
  rmse_values[i] <- sqrt(mean((predictions - test_data$new_cases)^2))
}

# Average RMSE over all folds
# Line below used to return NA, so added the na.rm = TRUE
mean_rmse <- mean(rmse_values, na.rm = TRUE)
print(mean_rmse)

# Returns as 11884 because we are missing population count for that many days. 
# I think its better to have a more complete dataset rather than more observations
sum(is.na(data_clean$population_count))

