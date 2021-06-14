********************************************************************************
/* Bivariate VA regressions on each category index with school demographics as controls */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
clear all
set more off

////////////////////////////////////////////////////////////////////////////////
/* both complete case analysis and imputed data  */

local datatype compcase imputed

foreach type of local datatype {
  use $projdir/dta/allsvyfactor/categoryindex/`type'categoryindex, clear

  //merge with pooled average enrollment characteristics over 1415-1819
  merge 1:1 cdscode using $projdir/dta/enrollment/pooledavgenr
  //keep only merged observations
  keep if _merge == 3
  drop _merge


  //creating a local macro for va variables
  local vavars va_ela va_math va_enr va_enrela va_enrmath va_enrdk va_2yr va_2yrela va_2yrmath va_2yrdk va_4yr va_4yrela va_4yrmath va_4yrdk

  // local macro for index vars
  local indexvars climateindex qualityindex supportindex motivationindex

  //local macro for demographics vars
  local demovars femaleenrpct blackenrpct whiteenrpct hispanicenrpct

  // bivariate regressions va vars on index vars and demographics controls
  //regsave with append overwrites the same variables
  foreach i of local vavars {

    foreach j of local indexvars {
      reg z_`i' z_`j' `demovars'
      regsave using $projdir/out/dta/factor/indexregwcontrols/`type'/`i'_`j'_indexwcontrols_`type'regs, replace table(`i', format(%7.2f) parentheses(stderr) asterisk())

    }
  }


  //save dataset
  compress
  save $projdir/dta/allsvyfactor/categoryindex/`type'categoryindex, replace


  //merge the va index reg datasets to produce combined table
  // local macro for all va vars except the first one (va_ela) for merging loop
  local vaminusfirst va_math va_enr va_enrela va_enrmath va_enrdk va_2yr va_2yrela va_2yrmath va_2yrdk va_4yr va_4yrela va_4yrmath va_4yrdk

  //merge the regsave results dta files for each index var
  foreach i of local indexvars {
    use $projdir/out/dta/factor/indexregwcontrols/`type'/va_ela_`i'_indexwcontrols_`type'regs, clear
    foreach j of local vaminusfirst {
      merge 1:1 var using $projdir/out/dta/factor/indexregwcontrols/`type'/`j'_`i'_indexwcontrols_`type'regs
      drop _merge
    }

    save $projdir/out/dta/factor/indexregwcontrols/`type'/vaindexwcontrols_`type'regs_`i', replace

    export excel using $projdir/out/xls/factor/indexregwcontrols/`type'/vaindexwcontrols_`type'regs_`i', replace
  }
}
