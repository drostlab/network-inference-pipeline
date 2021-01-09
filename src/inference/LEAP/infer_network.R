arguments <- commandArgs(trailingOnly = TRUE)
input_filename <- arguments[1]
output_filename <- arguments[2]

input <- as.matrix(read.csv(input_filename, row.names = 1))
edges <- LEAP::MAC_counter(input, symmetric = TRUE)

# Map gene indices back to their names when writing.
write.csv(
  data.frame(
    "gene1" = plyr::mapvalues(
      edges[, "Column gene index"],  # `edges` has class `matrix`
      1:nrow(input),
      rownames(input)
    ),
    "gene2" = plyr::mapvalues(
      edges[, "Row gene index"],
      1:nrow(input),
      rownames(input)
    ),
    "correlation" = edges[, "Correlation"]
  ),
  file = output_filename,
  row.names = FALSE
)
