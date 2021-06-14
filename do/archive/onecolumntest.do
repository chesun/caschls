clear all
set more off

use $projdir/dta/buildanalysisdata/analysisready/secanalysisready, clear

local qoinums 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40

local vanames `" "va_ela" "va_math" "va_enr" "va_enrela" "va_enrmath" "va_enrdk" "va_2yr" "va_2yrela" "va_2yrmath" "va_2yrdk" "va_4yr" "va_4yrela" "va_4yrmath" "va_4yrdk" "'

foreach va of local vanames {
  local append replace

  foreach i of local qoinums {
    qui reg `va' qoi`i'mean_pooled
    regsave using $projdir/out/dta/varegs/secondary/`va'_nw, `append' table(`va', format(%7.2f) parentheses(stderr) asterisk())
    local append append
  }
}

/* export the regsave results to excel */
foreach va of local vanames {
  use $projdir/out/dta/varegs/secondary/`va'_nw, clear
  export excel using $projdir/out/xls/varegs/secondary/`va'_nw, replace
}

/* note: impoossible to append into same column using outreg2
so far cannot figure out a way to use a different name for N for each regression when appending using regsave - it ovewrites the previous N */
