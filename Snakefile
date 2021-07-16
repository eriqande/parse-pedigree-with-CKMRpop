

# Start by installing this branch of CKMRpop package:
#  remotes::install_github("eriqande/CKMRpop", ref = "make-it-work-for-pedfac-pedigrees")

IDXS = [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12]

rule all:
	input: 
		expand("outputs/posteriors_{idx}.rds", idx = IDXS)

rule get_posteriors:
	input: 
		#"/home/eanderson/Documents/git-others-repos/RunArea/Run_{idx}/out/ped.txt"
		"/tmp/RunArea/Run_{idx}/out/ped.txt"
	output:
		"outputs/posteriors_{idx}.rds"
	envmodules: "R"
	script:
		"script/get_posteriors.R"
