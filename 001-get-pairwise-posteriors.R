
# install a version of CKMRpop that deals with the NA in the
# ancestry vectors OK:
# remotes::install_github("eriqande/CKMRpop", ref = "ac5e4a167e2d4a8d2d64761c73f558e968379930")


library(tidyverse)
library(CKMRpop)

source("R/functions.R")

for(i in 1:12) {

  infile <- paste0("data/Run_", i, "/out/ped.txt.gz")
  outfile = paste0("outputs/posteriors_", i, ".rds")
  sweeps <- 5:24

  result <- pw_posteriors(infile, sweeps, 6604)

  dir.create("outputs", showWarnings = FALSE)

  write_rds(result, file = outfile, compress = "xz")
  rm(result)
  message("Done with ", i)
}

# to be honest, sometimes things would fail on one of the cores
# in which case not all 20 sweeps would be recorded and the posteriors
# would never reach 1.

# Such cases can be found like this:
lapply(1:12, function(x) max(read_rds(paste0("outputs/posteriors_", x, ".rds"))$posterior))

# I ended up re-running ones that didn't yield a 1 in the above code.  It took
# me a few iterations to get everything done.




ggplot(result, aes(x = posterior, fill = factor(max_hit))) +
  geom_histogram(binwidth = 0.05) +
  facet_wrap(~ dom_relat)
