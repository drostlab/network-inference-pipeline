function(filename) {
  edges <- read.csv(filename)
  wide <- tidyr::spread(edges, key = "target", value = "importance", fill = 0)
  rownames(wide) <- wide$TF
  wide$TF <- NULL
  result <- as.matrix(wide)

  # Sort rows and columns by gene name to ensure they are ordered identically.
  # (They usually are, but we don't have that guaranteed.)
  result[order(rownames(result)), order(colnames(result))]
}
