library(dplyr)

arguments <- commandArgs(trailingOnly = TRUE)
input_filename <- arguments[1]
output_directory <- arguments[2]

counts <- data.matrix(read.csv(input_filename, row.names = 1))

window_size <- round(nrow(counts) / 10)
distance_information <- noisyr::calculate_distance_matrices_counts(
  counts,
  window_size
)
distances <- distance_information$dist
abundances <- distance_information$abn

seq(0.2, 0.3, by = 0.01) %>%
  lapply(
    function(threshold) noisyr::calculate_threshold_noise(
      expression.matrix = counts,
      dist.matrix = distances,
      abn.matrix = abundances,
      # min.pts.in.box = 0,  # unpublished interface
      dist.thresh = threshold
    )
  ) %>%
  dplyr::bind_rows() %>%
  dplyr::filter(abn.thresh.coef.var > 0) ->
  threshold_information

thresholds <- as.double(
  strsplit(
    threshold_information$abn.thresh.all[
      which.min(threshold_information$abn.thresh.coef.var)
    ],
    ","
  )[[1]]
)

filtered_counts <- noisyr::remove_noise_matrix(
  counts,
  abn.thresh = thresholds
)

normalize <- function(m) {
  result <- preprocessCore::normalize.quantiles(m)
  rownames(result) <- rownames(m)
  colnames(result) <- colnames(m)

  result
}

save_counts <- function(m, name) write.csv(
  data.frame(gene = rownames(m), m),
  row.names = FALSE,
  quote = FALSE,
  file = paste0(output_directory, "/", name, ".csv")
)

save_counts(counts, "counts_raw")
save_counts(filtered_counts, "counts_filtered")
save_counts(normalize(counts), "counts_normalized")
save_counts(normalize(filtered_counts), "counts_filtered_normalized")
