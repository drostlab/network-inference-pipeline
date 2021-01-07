arguments <- commandArgs(trailingOnly = TRUE)
input_adaptor <- arguments[1]
output_extension <- arguments[2]
input_filename <- arguments[3]
output_filename_template <- arguments[4]

input <- eval(parse(input_adaptor))(input_filename)

# Circumvent broken `make_symmetric` in `edgynode` by doing it ourselves for
# now. Since this is idempotent, it won't hurt.
input <- pmax(input, t(input))

rescaled <- edgynode::network_rescale(input)

output_directory <- dirname(output_filename_template)
output_name <- basename(output_filename_template)

ggplot2::ggsave(
  file = paste0(
    output_directory,
    "/weight_distribution_",
    output_name,
    ".",
    output_extension
  ),
  plot = edgynode::plot_network_weight_distribution(
    rescaled,
    threshold = "median"
  )
)

ggplot2::ggsave(
  file=paste0(
    output_directory,
    "/weight_distribution_boxplot_",
    output_name,
    ".",
    output_extension
  ),
  plot=edgynode::plot_network_weight_distribution_boxplot(
    rescaled,
    threshold = "median"
  )
)

ggplot2::ggsave(
  file=paste0(
    output_directory,
    "/weight_distribution_violin_",
    output_name,
    ".",
    output_extension
  ),
  plot=edgynode::plot_network_weight_distribution_boxplot(
    rescaled,
    threshold = "median"
  )
)

ggplot2::ggsave(
  file=paste0(
    output_directory,
    "/degree_distribution_naive_",
    output_name,
    ".",
    output_extension
  ),
  plot=edgynode::plot_network_degree_distribution_naive(
    edgynode::network_statistics_degree_distribution_naive(rescaled)
  )
)

