********************************************************************************
/* running value added regressions for secondary survey questions of interest */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

clear all
set more off

use $projdir/dta/buildanalysisdata/analysisready/secanalysisready, clear

/* create a local macro for qoi numbers  */
local qoinums 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
/* create a local macro for va var names */
local vanames `" "va_ela" "va_math" "va_enr" "va_enrela" "va_enrmath" "va_enrdk" "va_2yr" "va_2yrela" "va_2yrmath" "va_2yrdk" "va_4yr" "va_4yrela" "va_4yrmath" "va_4yrdk" "'

/* running unweighted regressions */
foreach va of local vanames {
  local append replace //local macro to enable replace old file on first execution and append thereafter

  foreach i of local qoinums {
    eststo: qui reg `va' qoi`i'mean_pooled
    estimates save $projdir/out/ster/varegs/noweights/secondary/`va'regs_nw, `append'
    local append append
  }

  esttab using $projdir/out/csv/varegs/noweights/secondary/`va'regs_nw.csv, replace
  eststo clear
}

/* running weighted regressions */
foreach va of local vanames {
  local append replace

  foreach i of local qoinums {
    eststo: qui reg `va' qoi`i'mean_pooled [aweight = gr11enr_mean]
    estimates save $projdir/out/ster/varegs/weighted/secondary/`va'regs_wt, `append'
    local append append
  }

  esttab using $projdir/out/csv/varegs/weighted/secondary/`va'regs_wt.csv, replace
  eststo clear
}
