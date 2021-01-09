arguments <- commandArgs(trailingOnly = TRUE)
input_expressions_filename <- arguments[1]
sample_groups_filename <- arguments[2]
output_expressions_filename <- arguments[3]

expressions <- as.matrix(read.csv(input_expressions_filename, row.names = 1))
samples <- read.csv(sample_groups_filename)

# Order `expressions`' columns according to their order in `samples`, fuse
# columns by group and then convert the resulting `by` object back to a
# matrix. Finally, reorder its columns according to their names' first
# occurrence in `samples`.
result <- sapply(
  by(t(expressions[, samples$sample]), samples$group, colMeans),
  identity
)[, unique(samples$group)]

write.csv(
  data.frame(gene = rownames(result), result, check.names = FALSE),
  row.names = FALSE,
  quote = FALSE,
  file = output_expressions_filename
)
