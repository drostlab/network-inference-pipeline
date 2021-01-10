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

for (name in rownames(variants)) {
  input <- load_network(
    file.path(
      input_directory,
      sub("VARIANT", variants[name, "VARIANT"], input_filename_template)
    )
  )

  # Circumvent broken `make_symmetric` in `edgynode` by doing it ourselves for
  # now. Since this is idempotent, it won't hurt.
  input <- pmax(input, t(input))

  rescaled <- edgynode::network_rescale(input)

  assign(name, rescaled)
}

# @Hajk:
print("TODO - plot here for:")
print(paste("variant:", rownames(variants), "--", "label:", variants$label))
print(paste(
  "to:",
  paste0(
    output_directory,
    "/myplot_",
    output_filename_template,
    ".",
    output_extension
  )
))
