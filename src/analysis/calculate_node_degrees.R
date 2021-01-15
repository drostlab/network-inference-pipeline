arguments <- commandArgs(trailingOnly = TRUE)
threshold <- type.convert(arguments[1], as.is = TRUE)
input_adaptor <- arguments[2]
input_path <- arguments[3]
output_path <- arguments[4]

degrees <- edgynode::network_statistics_degree_distribution_naive(
  edgynode::network_make_binary(
    edgynode::network_rescale(
      edgynode:::make_symmetric(
        eval(parse(input_adaptor))(input_path)
      )
    ),
    threshold = threshold
  )
)

write.csv(
  degrees[order(degrees$node_degree, decreasing = TRUE), ],
  row.names = FALSE,
  quote = FALSE,
  file = output_path
)
