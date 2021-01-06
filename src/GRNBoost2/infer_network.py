import sys
import pandas
import arboreto.algo

if __name__ == '__main__':
    input_filename, output_filename = sys.argv[1:3]

    arboreto.algo.grnboost2(
        pandas.read_csv(input_filename, index_col="gene").T,
        seed=123
    ).to_csv(
        output_filename,
        index=False
    )
