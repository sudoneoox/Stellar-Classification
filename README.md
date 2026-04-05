# SDSS17 Stellar Classification - MATH 4323 Project

## Directory Structure

```
Stellar-Classificaton/
├── data/                          <- All data files go here
│   ├── star_classification.csv    <- Raw dataset from Kaggle (do not modify)
│   ├── df_clean.rds               <- Cleaned, unscaled, with class labels
│   ├── df_supervised_train.rds    <- Scaled, with class, 80% train split
│   ├── df_supervised_test.rds     <- Scaled, with class, 20% test split
│   ├── df_unsupervised.rds        <- Scaled, no class labels
│   └── class_labels.rds           <- Class labels for post-hoc cluster comparison
├── report/                        <- Final report files (docx, images, etc.)
├── 00_eda.R
├── 01_preprocessing.R
├── 02_pca.R
├── 03_knn.R
├── 04_svm.R
├── 05_kmeans.R
├── 06_hierarchical.R
├── 07_comparison.R
└── README.md
```

## Scripts (run in order)

| Script | Owner | Purpose |
|---|---|---|
| `00_eda.R` | Diego| Exploratory data analysis on raw data |
| `01_preprocessing.R` | Diego | Cleans data, scales, splits, saves all .rds files |
| `02_pca.R` | Anthony | PCA for dimensionality reduction and visualization |
| `03_knn.R` | Asibong | KNN tuning and evaluation |
| `04_svm.R` | Diego | SVM kernel selection, tuning, and evaluation |
| `05_kmeans.R` | Anthony | K-Means clustering and silhouette analysis |
| `06_hierarchical.R` | Asibong | Hierarchical clustering, linkage selection, dendrogram |
| `07_comparison.R` | Shared | Compares test errors (supervised) and silhouette scores (unsupervised) |

## Data Files

**You only need to run `01_preprocessing.R` once.** It generates all the .rds files below.

| File | Used by | Description |
|---|---|---|
| `df_clean.rds` | Anyone | 99,999 rows, 7 cols (u, g, r, i, z, redshift, class). Unscaled. Good for reference or re-scaling. |
| `df_supervised_train.rds` | KNN, SVM | 79,999 rows, scaled features + class column. |
| `df_supervised_test.rds` | KNN, SVM | 20,000 rows, scaled features + class column. |
| `df_unsupervised.rds` | PCA, K-Means, Hierarchical | 99,999 rows, 6 scaled features, no class labels. |
| `class_labels.rds` | K-Means, Hierarchical | Vector of 99,999 class labels for checking if clusters match known categories. |

## How to Load Data

At the top of your script, set the data directory and load what you need:

```r
DATA_DIR <- file.path("C:/Users/diego/Downloads/Stellar-Classificaton", "data")

# Supervised scripts (KNN, SVM)
df_train <- readRDS(file.path(DATA_DIR, "df_supervised_train.rds"))
df_test  <- readRDS(file.path(DATA_DIR, "df_supervised_test.rds"))

# Unsupervised scripts (PCA, K-Means, Hierarchical)
df_unsupervised <- readRDS(file.path(DATA_DIR, "df_unsupervised.rds"))
class_labels    <- readRDS(file.path(DATA_DIR, "class_labels.rds"))
```

## Important Notes

- **Always use `set.seed(42)`** before any randomized operation so results are reproducible and KNN/SVM use the same train/test split.
- **Do not re-scale the .rds data.** It is already standardized (mean=0, sd=1). Scaling again will distort values.
- **Do not re-run preprocessing** unless the pipeline changes. The .rds files are the single source of truth.
- Dropped columns from raw data: `obj_ID`, `run_ID`, `rerun_ID`, `cam_col`, `field_ID`, `spec_obj_ID`, `plate`, `MJD`, `fiber_ID` (metadata), `alpha`, `delta` (sky coordinates with no predictive value).
- One sentinel row with -9999 values in u, g, z was removed.

## Required Libraries

```r
install.packages(c(
  "tidyverse",    # data manipulation and plotting
  "e1071",        # SVM (tune, svm)
  "class",        # KNN (knn)
  "caret",        # confusion matrices, model utilities
  "factoextra",   # eclust(), fviz_cluster(), fviz_dend()
  "cluster",      # silhouette()
  "corrplot",     # correlation heatmaps
  "GGally",       # ggpairs scatterplot matrix
  "gridExtra"     # arranging multiple plots
))
```
