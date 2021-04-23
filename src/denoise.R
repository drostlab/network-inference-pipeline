library(dplyr)

arguments <- commandArgs(trailingOnly = TRUE)
input_filename <- arguments[1]
output_directory <- arguments[2]

counts <- data.matrix(read.csv(input_filename, row.names = 1))
denoised <- noisyr::noisyr_counts(
  expression.matrix = counts,
  similarity.threshold = seq(0.2, 0.3, by = 0.01),
  method.chosen = noisyr::get_methods_calculate_noise_threshold()
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
save_counts(denoised, "counts_filtered")
save_counts(normalize(counts), "counts_normalized")
save_counts(normalize(denoised), "counts_filtered_normalized")
