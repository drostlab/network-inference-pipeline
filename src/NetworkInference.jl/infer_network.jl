using NetworkInference

algorithm_name, input_filename, output_filename = ARGS

algorithms = Dict(
  "PIDC" => PIDCNetworkInference,
  "PUC" => PUCNetworkInference,
  "MI" => MINetworkInference,
  "CLR" => CLRNetworkInference,
)

write_network_file(
  output_filename,
  InferredNetwork(
    algorithms[algorithm_name](),
    get_nodes(input_filename; delim=','),
  ),
)
