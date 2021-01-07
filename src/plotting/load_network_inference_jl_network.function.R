function(filename) {
  edges <- read.csv(
    filename,
    sep = "\t",
    header = FALSE,
    col.names = c("gene1", "gene2", "link")
  )
  wide <- tidyr::spread(edges, key = "gene2", value = "link", fill = 0)
  rownames(wide) <- wide$gene1
  wide$gene1 <- NULL
  result <- as.matrix(wide)

  # Sort rows and columns by gene name to ensure they are ordered identically.
  # (They usually are, but we don't have that guaranteed.)
  result[order(rownames(result)), order(colnames(result))]
}
