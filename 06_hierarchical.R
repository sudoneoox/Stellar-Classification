# =============================================================================
# SDSS17 Stellar Classification - Hierarchical Clustering
# =============================================================================

library(cluster)
library(factoextra)
library(dplyr)

# ---- 0. Load Cleaned Data ---------------------------------------------------
DATA_DIR  <- file.path("C:/Users/asibo/Downloads/Stellar-Classification-master", "data")
df_clean  <- readRDS(file.path(DATA_DIR, "df_clean.rds"))

cat("=== CLEAN DATA LOADED ===\n")

# ---- 1. Reproducible Sampling -----------------------------------------------
# Ensures reproducible random sampling
set.seed(123)

hc_data <- df_clean %>%
  select(-class)

hc_data_sample <- hc_data %>% sample_n(5000)

cat("Sample size:", nrow(hc_data_sample), "\n")

# ---- 2. Scaling --------------------------------------------------------------
# Standardizes features so all variables contribute equally to distance calculations.
hc_scaled <- scale(hc_data_sample)

cat("Data scaled\n")

# ---- 3. PCA -------------------------------------------
# Reduces dimensionality while preserving most of the data’s variability.
pca <- prcomp(hc_scaled)

var_explained <- cumsum(pca$sdev^2 / sum(pca$sdev^2))
k_components <- which(var_explained >= 0.90)[1]

hc_reduced <- pca$x[, 1:k_components]

cat("PCA components used:", k_components, "\n")

# ---- 4. Distance Matrix ------------------------------------------------------
# Computes pairwise Euclidean distances between observations for clustering.
dist_matrix <- dist(hc_reduced, method = "euclidean")

# ---- 5. Hierarchical Clustering ---------------------------------------------
# Builds hierarchical clustering trees using different linkage methods.
hc_complete <- hclust(dist_matrix, method = "complete")
hc_average  <- hclust(dist_matrix, method = "average")
hc_single   <- hclust(dist_matrix, method = "single")

# ---- 6. Choose optimal k using silhouette -----------------------------------
# Evaluates clustering quality across different k values using silhouette scores.
k_values <- 2:6

sil_results <- data.frame(
  k = k_values,
  complete = NA,
  average  = NA,
  single   = NA
)

for (i in seq_along(k_values)) {
  k <- k_values[i]
  
  sil_results$complete[i] <- mean(silhouette(cutree(hc_complete, k), dist_matrix)[, 3])
  sil_results$average[i]  <- mean(silhouette(cutree(hc_average, k), dist_matrix)[, 3])
  sil_results$single[i]   <- mean(silhouette(cutree(hc_single, k), dist_matrix)[, 3])
}

print(sil_results)

# ---- 7. Select best method and best k -----------------------------------------
# Selects the optimal linkage method and number of clusters based on highest silhouette score.
sil_matrix <- as.matrix(sil_results[, -1])

best_idx <- which(sil_matrix == max(sil_matrix, na.rm = TRUE), arr.ind = TRUE)[1, ]

best_method <- colnames(sil_matrix)[best_idx[2]]
best_k <- sil_results$k[best_idx[1]]

cat("\nBest method:", best_method, "\n")
cat("Best k:", best_k, "\n")

# ---- 8. Final Clustering -----------------------------------------------------
# Assigns final cluster labels using the best-performing model.
final_clusters <- cutree(
  switch(best_method,
         complete = hc_complete,
         average  = hc_average,
         single   = hc_single),
  best_k
)

# ---- 9. Dendrogram ----------------------------------------------------------
# Visualizes the hierarchical clustering structure and final cluster cuts
plot(hc_complete, labels = FALSE,
     main = "Hierarchical Clustering")
rect.hclust(hc_complete, k = best_k, border = "red")

# ---- 10. Compare with True Labels -------------------------------------------
# Compares clustering results with actual labels to assess alignment with real classes.
if ("class" %in% names(df_clean)) {
  print(table(True = df_clean$class[1:nrow(hc_data_sample)],
              Cluster = final_clusters))
}
