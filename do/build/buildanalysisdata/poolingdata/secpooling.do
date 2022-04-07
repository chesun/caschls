********************************************************************************
/* merging all years of secondary cleaned qoi data and calculate pooled stats */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/build/buildanalysisdata/poolingdata/secpooling.smcl, replace

/* ssc install _gwtmean, replace //package to allow use of weights in egen mean  */


/* first append all years to make a pnael dataset to calculate pooled stats */
use $projdir/dta/buildanalysisdata/qoiclean/secondary/secqoiclean1819, clear
append using $projdir/dta/buildanalysisdata/qoiclean/secondary/secqoiclean1718

append using $projdir/dta/buildanalysisdata/qoiclean/secondary/secqoiclean1617

append using $projdir/dta/buildanalysisdata/qoiclean/secondary/secqoiclean1516

append using $projdir/dta/buildanalysisdata/qoiclean/secondary/secqoiclean1415

drop if missing(cdscode) //there is one observation with missing cdscode


/* calculate the weighted average of qoi means pooled over years
ignore missing values */
/* Note: collapse doesn't work because the weight is different for each variable, would have to write everything out */
sort cdscode year

foreach i of numlist 22/40 {
  by cdscode: egen qoi`i'mean_pooled = wtmean(qoi`i'mean), weight(nettotalresp`i')
}


/* generate the percentages of agree/disagree etc for qoi 22-34 */
foreach i of numlist 22/34 {
  by cdscode: egen pctagree`i'_pooled = wtmean(pctagree`i'), weight(nettotalresp`i')
  by cdscode: egen pctdisagree`i'_pooled = wtmean(pctdisagree`i'), weight(nettotalresp`i')
  by cdscode: egen pctneither`i'_pooled = wtmean(pctneither`i'), weight(nettotalresp`i')
}

/* generate the percentages of true/not true etc for qoi 35-40 */
foreach i of numlist 35/40 {
  by cdscode: egen pcttrue`i'_pooled = wtmean(pcttrue`i'), weight(nettotalresp`i')
  by cdscode: egen pctnottrue`i'_pooled = wtmean(pctnottrue`i'), weight(nettotalresp`i')
}


collapse (mean) *pooled (sum) nettotalresp* missing* strdisagree* disagree* neither* agree* stragree* ///
nottrue* littletrue* prettytrue* verytrue*, by(cdscode)

/* label the pooled qoi means and nettotalresp and missing*/
foreach i of numlist 22/40 {
  label var qoi`i'mean_pooled "weighted mean of qoi`i' responses over years for a given school"
  label var nettotalresp`i' "net total responses for qoi`i' excluding missing pooled over years"
  label var missing`i' "number of missing responses for qoi`i' pooled over years"
}

/* label the pooled percent agree/disagree vars */
foreach i of numlist 22/34 {
  label var pctagree`i'_pooled "weighted average percent agree/strongly agree in qoi`i' pooled over years"
  label var pctdisagree`i'_pooled "weighted average percent disagree/strongly disagree in qoi`i' pooled over years"
  label var pctneither`i'_pooled "weighted average percent neither agree nor disagree in qoi`i' pooled over years"

  label var strdisagree`i' "total number of strongly disagree for qoi`i' pooled over years"
  label var disagree`i' "total number of disagree for qoi`i' pooled over years"
  label var neither`i' "total number of neither disagree nor agree for qoi`i' pooled over years"
  label var agree`i' "total number of agree for qoi`i' pooled over years"
  label var stragree`i' "total number of strongly agree for qoi`i' pooled over years"
}

foreach i of numlist 35/40 {
  label var pcttrue`i'_pooled "weighted average percent little true, pretty much true, and very much true in qoi`i' pooled over years"
  label var pctnottrue`i'_pooled "weighted average percent not true in qoi`i' pooled over years"

  label var nottrue`i' "total number of not true for qoi`i' pooled over years"
  label var littletrue`i' "total number of a little true for qoi`i' pooled over years"
  label var prettytrue`i' "total number of pretty much true for qoi`i' pooled over years"
  label var verytrue`i' "total number of very true for qoi`i' pooled over years"
}


label data "weighted average secondary qoi statistics pooled over years"
compress
save $projdir/dta/buildanalysisdata/poolingdata/secpooledstats, replace


/* merge with the response rate dataset */

merge 1:1 cdscode using $projdir/dta/buildanalysisdata/responserate/secresponserate
drop _merge


drop if missing(cdscode) //there is one observation with missing cdscode

label data "secondary pooled dataset ready for analysis with stats and response rate"
compress
save $projdir/dta/buildanalysisdata/analysisready/secanalysisready, replace


log close
translate $projdir/log/build/buildanalysisdata/poolingdata/secpooling.smcl $projdir/log/build/buildanalysisdata/poolingdata/secpooling.log, replace 
