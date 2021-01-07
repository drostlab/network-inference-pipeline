arguments <- commandArgs(trailingOnly = TRUE)
input_adaptor <- arguments[1]
output_extension <- arguments[2]
input_filename <- arguments[3]
output_filename_template <- arguments[4]

output_directory <- dirname(output_filename_template)
output_name <- basename(output_filename_template)

load.network.inference.jl <- function(filename) {
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

input <- get(input_adaptor)(input_filename)
rescaled <- edgynode::network_rescale(input)

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

