arguments <- commandArgs(trailingOnly=TRUE)
input_filename <- arguments[1]
output_filename <- arguments[2]

counts <- read.csv(input_filename)
rownames(counts) <- counts[, 1]
colnames(counts) <- counts[1, ]

write.csv(
  GENIE3::GENIE3(as.matrix(counts)[2:nrow(counts), 2:ncol(counts)]),
  file = output_filename
)
