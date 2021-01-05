arguments <- commandArgs(trailingOnly = TRUE)
input_filename <- arguments[1]
output_filename <- arguments[2]

write.csv(
  GENIE3::GENIE3(
    as.matrix(
      read.csv(input_filename, row.names = 1)
    )
  ),
  file = output_filename
)
