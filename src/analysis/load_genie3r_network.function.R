function(filename) {
  result = as.matrix(read.csv(filename, row.names = 1))

  # Sort rows and columns by gene name to ensure they are ordered identically.
  # (They usually are, but we don't have that guaranteed.)
  result[order(rownames(result)), order(colnames(result))]
}
