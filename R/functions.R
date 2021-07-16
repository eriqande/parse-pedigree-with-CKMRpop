
#' read the entire pedigree file in
#'
read_ped <- function(P) {
  ped <- read_table2(P, col_names = c("iter", "kid", "pa", "ma"))
}

#' @param ped the pedfac ped.txt file read by read_ped
#' @param rep the sweep number to use
#' @example
#' rep <- 20
#' max_idx <- 6604
prepare_pedfac_output <- function(ped, rep) {

  # filter to iteration and get the last updated instance of each kid only
  ped2 <- ped %>%
    filter(iter == rep) %>%
    select(-iter) %>%
    group_by(kid) %>%
    slice(n()) %>%
    ungroup()

  # change names to be characters
  ped3 <- lapply(ped2, function(x) paste0("s", x)) %>%
    as_tibble()

  # find all the founders and make rows for them:
  founders <- tibble(
    kid = setdiff(c(ped3$pa, ped3$ma), ped3$kid),
    pa = "0",
    ma = "0"
  )

  ped4 <- bind_rows(
    founders,
    ped3
  )
  ped4
}


#' get the pairwise relationships for one rep/sweep
one_rep_pw <- function(ped, rep, max_idx) {

  P <- prepare_pedfac_output(ped, rep)

  ARS <- find_ancestors_and_relatives_of_samples(P = P, S = paste0("s", 0:max_idx), 2) %>%
    rename(ID = sample_id) %>%
    filter(!is.na(ID))


  compile_related_pairs(ARS) %>%
    select(id_1:max_hit) %>%
    mutate(iter = rep) %>%
    select(iter, everything())

}


#' now, for a range of sweeps (like 6:25) we want to
#' compute the posterior prob of each pairwise relationship
#' (fraction of sweeps of it occurred in).  We will want to
#' do this for each run, so we call it with the path to the
#' pedfile.
pw_posteriors <-  function(path, sweeps = 6:25, max_idx = 6604) {
  ped <- read_ped(path)

  big_tib <- lapply(sweeps, function(s) one_rep_pw(ped, s, max_idx)) %>%
    bind_rows()

  num_reps <- length(sweeps)

  ret <- big_tib %>%
    group_by(id_1, id_2, dom_relat, max_hit) %>%
    summarise(posterior = n() / length(sweeps)) %>%
    ungroup()

  ret

}
