********************************************************************************
/* running value added regressions for secondary, parent, and staff surveys questions of interest */
/* This file supercededs parentvareg.do and secvareg.do since this files does the VA regs for secondary, staff, and parent using a loop*/
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

clear all
set more off


/* create a local macro for secondary qoi numbers  */
local secqoinums 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40

/* create a local macro for parent qoi numbers  */
local parentqoinums 9 15 16 17 27 30 31 32 33 34 64

/* create a local macro for staff qoi numbers  */
local staffqoinums 10 20 24 41 44 64 87 98 103 104 105 109 111 112 128

/* create a local macro for va var names */
local vanames `" "va_ela" "va_math" "va_enr" "va_enrela" "va_enrmath" "va_enrdk" "va_2yr" "va_2yrela" "va_2yrmath" "va_2yrdk" "va_4yr" "va_4yrela" "va_4yrmath" "va_4yrdk" "'


local surveynames `" "sec" "parent" "staff" "'

foreach svyname of local surveynames {
  use $projdir/dta/buildanalysisdata/analysisready/`svyname'analysisready, clear

  /* standardize qoi mean vars into z scores */
  foreach i of local `svyname'qoinums {
    sum qoi`i'mean_pooled
    gen qoi`i'mean_z = (qoi`i'mean_pooled - r(mean))/r(sd)
  }

  /* standardize va vars into z scores */
  foreach va of local vanames {
    sum `va'
    gen `va'_z = (`va' - r(mean))/r(sd)
  }

  /* running unweighted regressions */
  foreach va of local vanames {
    local append replace //local macro to enable replace old file on first execution and append thereafter

    foreach i of local `svyname'qoinums {
      qui reg `va'_z qoi`i'mean_z
      regsave using $projdir/out/dta/varegs/`svyname'/`va'_nw, `append' table(`va', format(%7.2f) parentheses(stderr) asterisk())
      local append append
    }
  }

  /* running weighted regressions */
  foreach va of local vanames {
    local append replace

    foreach i of local `svyname'qoinums {
      qui reg `va'_z qoi`i'mean_z [aweight = gr11enr_mean]
      regsave using $projdir/out/dta/varegs/`svyname'/`va'_wt, `append' table(`va', format(%7.2f) parentheses(stderr) asterisk())
      local append append
    }
  }

  /* export regsave results to excel */
  foreach va of local vanames {
    use $projdir/out/dta/varegs/`svyname'/`va'_nw, clear
    export excel using $projdir/out/xls/varegs/unweighted/`svyname'/`va'_nw, replace
    use $projdir/out/dta/varegs/`svyname'/`va'_wt, clear
    export excel using $projdir/out/xls/varegs/weighted/`svyname'/`va'_wt, replace
  }

  /* merge datasets to produce big table */
  //first, merge unweighted
  use $projdir/out/dta/varegs/`svyname'/va_ela_nw, clear
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_math_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_enr_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_enrela_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_enrmath_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_enrdk_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_2yr_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_2yrela_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_2yrmath_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_2yrdk_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_4yr_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_4yrela_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_4yrmath_nw
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_4yrdk_nw
  drop _merge
  save $projdir/out/dta/varegs/`svyname'/`svyname'_va_all_nw, replace
  export excel using $projdir/out/xls/varegs/unweighted/`svyname'/`svyname'_va_all_nw, replace

  //next, merge weighted
  use $projdir/out/dta/varegs/`svyname'/va_ela_wt, clear
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_math_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_enr_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_enrela_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_enrmath_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_enrdk_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_2yr_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_2yrela_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_2yrmath_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_2yrdk_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_4yr_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_4yrela_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_4yrmath_wt
  drop _merge
  merge 1:1 var using $projdir/out/dta/varegs/`svyname'/va_4yrdk_wt
  drop _merge
  save $projdir/out/dta/varegs/`svyname'/`svyname'_va_all_wt, replace
  export excel using $projdir/out/xls/varegs/weighted/`svyname'/`svyname'_va_all_wt, replace

}






/* foreach svyname of local surveynames {
  use $projdir/dta/buildanalysisdata/analysisready/`svyname'analysisready, clear

  /* running unweighted regressions */
  foreach va of local vanames {
    local append replace //local macro to enable replace old file on first execution and append thereafter

    foreach i of local `svyname'qoinums {
      eststo: qui reg `va' qoi`i'mean_pooled
      estimates save $projdir/out/ster/varegs/noweights/`svyname'/`va'regs_nw, `append'
      local append append
    }

    esttab using $projdir/out/csv/varegs/noweights/`svyname'/`va'regs_nw.csv, replace
    eststo clear
  }

  /* running weighted regressions */
  foreach va of local vanames {
    local append replace

    foreach i of local `svyname'qoinums {
      eststo: qui reg `va' qoi`i'mean_pooled [aweight = gr11enr_mean]
      estimates save $projdir/out/ster/varegs/weighted/`svyname'/`va'regs_wt, `append'
      local append append
    }

    esttab using $projdir/out/csv/varegs/weighted/`svyname'/`va'regs_wt.csv, replace
    eststo clear
  }
} */
