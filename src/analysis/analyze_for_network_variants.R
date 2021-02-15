arguments <- commandArgs(trailingOnly = TRUE)
input_variants <- arguments[1]
input_adaptor <- arguments[2]
output_extension <- arguments[3]
input_path_template <- arguments[4]
output_path_template <- arguments[5]

variants <- read.csv(input_variants, row.names = 1)
load_network <- eval(parse(input_adaptor))
input_directory <- dirname(input_path_template)
input_filename_template <- basename(input_path_template)
output_directory <- dirname(output_path_template)
output_filename_template <- basename(output_path_template)

save_plot <- function(name, plot, width = 10, height = 10) {
  ggplot2::ggsave(
    plot = plot,
    width = width,
    height = height,
    limitsize = FALSE,
    file = paste0(
      output_directory,
      "/",
      name,
      "_",
      output_filename_template,
      ".",
      output_extension
    )
  )
}

handle_single_network <- function(variant, network) {
  gene_order <- rownames(network)[order(apply(network, 1, median))]
  if(length(gene_order) > 500) {
    gene_order <- gene_order[1:min(length(gene_order), 500)]
    warning("Dropped genes in excess of 500 to restrict plot size.")
  }
  network <- network[gene_order, gene_order]

  degrees <- edgynode::network_statistics_degree_distribution_naive(
    edgynode::network_make_binary(network, threshold = "median")
  )
  write.csv(
    degrees[order(degrees$node_degree, decreasing = TRUE), ],
    row.names = FALSE,
    quote = FALSE,
    file = paste0(
      output_directory,
      "/",
      output_filename_template,
      ".degrees.csv"
    )
  )
  save_plot(
    name = paste0("degree_distribution_naive_", variant),
    plot = edgynode::plot_network_degree_distribution_naive(
      degrees,
      y_ticks = 20
    ),
    height = 16,
    width = length(gene_order) / 10
  )

  save_plot(
    name = paste0("weight_distribution_boxplot_", variant),
    plot = edgynode::plot_network_weight_distribution_boxplot(
      network,
      threshold = "median"
    ),
    height = length(gene_order) / 5
  )

  save_plot(
    name = paste0("weight_distribution_violin_", variant),
    plot = edgynode::plot_network_weight_distribution_violin(
      network,
      threshold = "median"
    ),
    height = length(gene_order) / 5
  )
}

compare_long_side_by_side <- function(old, new) {
  gene_order <- rownames(new)[order(apply(new, 1, median))]
  if(length(gene_order) > 500) {
    gene_order <- gene_order[1:min(length(gene_order), 500)]
    warning("Dropped genes in excess of 500 to restrict plot size.")
  }
  old_long <- tidyr::pivot_longer(
    data.frame(source = gene_order, old[gene_order, gene_order]),
    all_of(gene_order),
    names_to = "target",
    values_to = "old_value"
  )
  new_long <- tidyr::pivot_longer(
    data.frame(source = gene_order, new[gene_order, gene_order]),
    all_of(gene_order),
    names_to = "target",
    values_to = "new_value"
  )
  long <- data.frame(old_long, new_value = new_long$new_value)
}

plot_link_weight_move_by_gene <- function(comparison) {
  jitter_position <- ggplot2::position_jitter(
    width = 0.28,
    height = 0,
    seed = 42
  )

  ggplot2::ggplot(
    comparison,
    ggplot2::aes(
      x = target,
      ymin = old_value,
      ymax = new_value,
      y = new_value,
      colour = pmax(-10, pmin(new_value - old_value, 10))
    )
  ) +
    ggplot2::geom_boxplot(
      outlier.shape = NA,
      size = 0.3,
      colour = "darkgray",
      fill = NA
    ) +
    ggplot2::geom_point(
      size = 0.1,
      position = jitter_position,
      alpha = 0.4,
      colour = "black"
    ) +
    ggplot2::geom_linerange(
      size = 0.15,
      position = jitter_position,
      alpha = 0.4
    ) +
    ggplot2::scale_colour_gradient2(
      low = "blue",
      mid = "white",
      high = "red",
      midpoint = 0,
      limit = c(-10, 10),
      space = "Lab"
    ) +
    ggplot2::scale_x_discrete(limits = unique(comparison$source)) +
    ggplot2::xlab("Gene") +
    ggplot2::ylim(0, 100) +
    ggplot2::ylab("Weight") +
    ggplot2::guides(colour = FALSE) +
    ggplot2::coord_flip() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = NA),
      text = ggplot2::element_text(size = 6)
    )
}

plot_link_weight_move_matrix <- function(comparison) {
  gene_order <- unique(comparison$source)
  ggplot2::ggplot(
    comparison,
    ggplot2::aes(
      x = source,
      y = target,
      fill = new_value - old_value
    )
  ) +
    ggplot2::geom_tile() +
    ggplot2::scale_x_discrete(limits = gene_order) +
    ggplot2::xlab("Source gene") +
    ggplot2::scale_y_discrete(limits = gene_order) +
    ggplot2::ylab("Target gene") +
    ggplot2::scale_fill_gradient2(
      low = "blue",
      mid = "white",
      high = "red",
      midpoint = 0,
      limit = c(-100, 100),
      space = "Lab"
    ) +
    ggplot2::theme(
      text = ggplot2::element_text(size = 4),
      axis.text.x = ggplot2::element_text(angle = 60, hjust = 1),
      legend.key.width = ggplot2::unit(0.1, 'in'),
      legend.title = ggplot2::element_blank()
    )
}

for (name in rownames(variants)) {
  variant <- variants[name, "VARIANT"]
  input <- load_network(
    file.path(
      input_directory,
      sub("VARIANT", variant, input_filename_template)
    )
  )

  rescaled <- edgynode::network_rescale(
    edgynode::network_make_symmetric(input)
  )

  handle_single_network(variant, rescaled)
  assign(name, rescaled)
}

comparison <- compare_long_side_by_side(
  normalized_network,
  filtered_normalized_network
)
gene_count <- length(unique(comparison$target))

save_plot(
  "link_weight_move_by_gene",
  plot_link_weight_move_by_gene(comparison),
  height = gene_count / 5
)

save_plot(
  "link_weight_move_matrix",
  plot_link_weight_move_matrix(comparison),
  height = gene_count / 10,
  width = gene_count / 10
)


benchmark <- edgynode::network_benchmark_noise_filtering(
  adj_mat_not_filtered_not_normalized = raw_network,
  adj_mat_filtered_and_not_normalized = filtered_network,
  adj_mat_not_filtered_but_normalized = normalized_network,
  adj_mat_filtered_and_normalized = filtered_normalized_network,
  threshold = "median",
  dist_type = "hamming",
  print_message = TRUE
)

write(
  edgynode::network_benchmark_noise_filtering_kruskal_test(benchmark)$p.val,
  file = paste0(
    output_directory,
    "/",
    output_filename_template,
    ".pvalue"
  )
)
save_plot(
  "benchmark",
  edgynode::plot_network_benchmark_noise_filtering(
    benchmark,
    dist_type = "hamming",
    title = ""
  ),
  height = 8,
  width = 10
)

save_plot(
  "node_degree_comparison",
  edgynode::plot_network_degree_distribution_naive_comparison(
    adj_mat_not_filtered_not_normalized = raw_network,
    adj_mat_filtered_and_not_normalized = filtered_network,
    adj_mat_not_filtered_but_normalized = normalized_network,
    adj_mat_filtered_and_normalized = filtered_normalized_network,
    threshold = "median",
    print_message = TRUE
  ),
  height = 8,
  width = gene_count / 5
)
