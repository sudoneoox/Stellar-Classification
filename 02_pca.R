library(tidyverse)
library(cluster)
library(factoextra)
#head(df_unsupervised) # from preprocesing
saveRDS(df_unsupervised, "~/Documents/Semester 12/MATH 4323/Project/df_unsupervised.rds")
df_unsupervised <- readRDS("~/Documents/Semester 12/MATH 4323/Project/df_unsupervised.rds")
#head(class_labels) # from preprocesing
saveRDS(df_unsupervised, "~/Documents/Semester 12/MATH 4323/Project/class_labels.rds")
class_labels <- readRDS("~/Documents/Semester 12/MATH 4323/Project/class_labels.rds")
# df_unsupervised has u, g, r, i, z, redshift. alpha and delta give position so we exclude them since we are trying to clasify by type not location
df_unsupervised <- df_unsupervised[, - (ncol(df_unsupervised) - 1)]

## PCA
set.seed(1)
pca_model=prcomp(df_unsupervised, center=TRUE, scale.=TRUE)
summary(pca_model)
fviz_eig(pca_model)
fviz_pca_ind(pca_model,
             geom="point",
             col.ind="cos2",
             gradient.cols=c("blue", "yellow", "red"),
             repel=TRUE)