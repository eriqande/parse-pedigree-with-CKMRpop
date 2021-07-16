

library(tidyverse)
library(CKMRpop)

infile <- snakemake@input[[1]]
outfile <- snakemake@output[[1]]

sweeps <- 20:22

source("R/functions.R")

result <- pw_posteriors(infile, sweeps, 6604)

write_rds(result, file = outfile, compress = "xz")
