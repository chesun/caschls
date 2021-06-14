********************************************************************************
/* exploratory factor analysis for secondary, parent, and staff surveys questions of interest */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

clear all
set more off

/* use principal factoring method because data is not multinormal */
// estout with factor: http://repec.org/bocode/e/estout/advanced.html#advanced404

/* Uniqueness is the variance that is ‘unique’ to the variable and not shared with other
variables. It is equal to 1 – communality (variance that is shared with other variables)
Notice that the greater ‘uniqueness’ the lower the relevance of the variable in the
factor model. */

/* secondary */
use $projdir/dta/buildanalysisdata/analysisready/secanalysisready, clear

/* standardize qoi mean vars into z scores */
foreach i of numlist 22/40 {
  sum qoi`i'mean_pooled
  gen qoi`i'mean_z = (qoi`i'mean_pooled - r(mean))/r(sd)
}

factor *mean_z
esttab e(L) using $projdir/out/csv/factoranalysis/secfactorall.csv, nogap noobs nonumber nomtitle replace //export factor loadings table for all factors
screeplot, yline(1)
graph export $projdir/out/graph/factoranalysis/secscreeplot.png, replace
//set minimum eigenvalue to 1
factor *mean_z, mineigen(1) //2 factors with eigenvalue above 1
esttab using $projdir/out/csv/factoranalysis/secfactoreigen1.csv, cells("L[1](t label(Factor 1)) L[2](t label(Factor 2)) Psi[Uniqueness]") nogap noobs nonumber nomtitle replace


/* parent */
use $projdir/dta/buildanalysisdata/analysisready/parentanalysisready, clear

/* standardize qoi mean vars into z scores */
foreach i of numlist 9 15/17 27 30/34 64 {
  sum qoi`i'mean_pooled
  gen qoi`i'mean_z = (qoi`i'mean_pooled - r(mean))/r(sd)
}

factor *mean_z
esttab e(L) using $projdir/out/csv/factoranalysis/parentfactorall.csv, nogap noobs nonumber nomtitle replace
screeplot, yline(1)
graph export $projdir/out/graph/factoranalysis/parentscreeplot.png, replace
factor *mean_z, mineigen(1) //1 factor with eigenvalue above 1
esttab using $projdir/out/csv/factoranalysis/parentfactoreigen1.csv, cells("L[1](t label(Factor 1)) Psi[Uniqueness]") nogap noobs nonumber nomtitle replace



/* staff */
use $projdir/dta/buildanalysisdata/analysisready/staffanalysisready, clear

/* standardize qoi mean vars into z scores */
foreach i of numlist 10 20 24 41 44 64 87 98 103/105 109 111 112 128 {
  sum qoi`i'mean_pooled
  gen qoi`i'mean_z = (qoi`i'mean_pooled - r(mean))/r(sd)
}

factor *mean_z
esttab e(L) using $projdir/out/csv/factoranalysis/stafffactorall.csv, nogap noobs nonumber nomtitle replace
screeplot, yline(1)
graph export $projdir/out/graph/factoranalysis/staffscreeplot.png, replace
factor *mean_z, mineigen(1) //3 factors with eigenvalue above 1
esttab using $projdir/out/csv/factoranalysis/stafffactoreigen1.csv, cells("L[1](t label(Factor 1)) L[2](t label(Factor 2)) L[3](t label(Factor 3)) Psi[Uniqueness]") nogap noobs nonumber nomtitle replace


/* note: standardizing into z score is unnecessary. Doesn't change factor analysis results,
since factors are explaining the variance */
