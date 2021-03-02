# NOTE: This code is currently unused.

arguments <- commandArgs(trailingOnly = TRUE)
input_filename <- arguments[1]
output_filename <- arguments[2]

BTR::outgraph_model(
  BTR::model_train(
    cdata = BTR::initialise_raw_data(
      t(
        as.matrix(
          read.csv(input_filename, row.names = 1)
        )
      ),
      max_expr = "low"
    ),
    max_varperrule = 3,
    verbose = T
  ),
  path = dirname(output_filename),
  file = basename(output_filename)
)
