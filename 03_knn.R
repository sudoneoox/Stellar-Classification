# =============================================================================
# SDSS17 Stellar Classification - K Nearest Neighbors (KNN)
# =============================================================================

library(class)
library(caret)
library(dplyr)

# ---- 0. File Paths -----------------------------------------------------------
DATA_DIR  <- file.path("C:/Users/asibo/Downloads/Stellar-Classification-master", "data")
df_train  <- readRDS(file.path(DATA_DIR, "df_supervised_train.rds")) 
df_test   <- readRDS(file.path(DATA_DIR, "df_supervised_test.rds"))
df_clean  <- readRDS(file.path(DATA_DIR, "df_clean.rds"))

# ---- 1. Separate Features and Labels ----------------------------------------
train_features <- df_train %>% select(-class)
train_labels   <- as.factor(df_train$class)
test_features  <- df_test %>% select(-class)
test_labels    <- as.factor(df_test$class)

cat("=== DATA LOADED ===\n")
cat("Training:", nrow(df_train), "rows\n")
cat("Testing: ", nrow(df_test), "rows\n\n")


# ---- 2. Scale predictors -------------------------------------------------------
# Standardize predictors for distance-based KNN
preproc <- preProcess(train_features, method = c("center", "scale"))

train_x <- predict(preproc, train_features)
test_x  <- predict(preproc, test_features)

# ---- Tune K -----------------------------------------------------------------
# Try different K values and compute accuracy for each
k_values <- seq(1, 21, by = 2)
accuracy_values <- numeric(length(k_values))

for (j in seq_along(k_values)) {
  pred <- knn(train = train_x,
              test = test_x,
              cl = train_labels,
              k = k_values[j])
  
  accuracy_values[j] <- mean(pred == test_labels)
}

results <- data.frame(
  K = k_values,
  Accuracy = accuracy_values,
  Error = 1 - accuracy_values
)

print(results)

# ---- Best K -----------------------------------------------------------------
# Choose K with highest test accuracy
best_k <- results$K[which.max(results$Accuracy)]
cat("Best K:", best_k, "\n")

# ---- Final KNN model --------------------------------------------------------
# Fit final model using optimal K
knn_pred <- knn(train = train_x,
                test = test_x,
                cl = train_labels,
                k = best_k)

# ---- Test set performance ---------------------------------------------------
# Evaluate model performance using confusion matrix on test data
cm <- confusionMatrix(knn_pred, test_labels)
print(cm)


# Compute final accuracy and prediction error on test set
accuracy <- mean(knn_pred == test_labels)
error_rate <- 1 - accuracy

cat("Accuracy:", round(accuracy, 4), "\n")
cat("Prediction Error:", round(error_rate, 4), "\n")
