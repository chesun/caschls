********************************************************************************
/* merging all years of staff cleaned qoi data and calculate pooled stats */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

clear all
set more off

/* first append all years to make a pnael dataset to calculate pooled stats */
use $projdir/dta/buildanalysisdata/qoiclean/staff/staffqoiclean1819, clear
append using $projdir/dta/buildanalysisdata/qoiclean/staff/staffqoiclean1718

append using $projdir/dta/buildanalysisdata/qoiclean/staff/staffqoiclean1617

append using $projdir/dta/buildanalysisdata/qoiclean/staff/staffqoiclean1516

append using $projdir/dta/buildanalysisdata/qoiclean/staff/staffqoiclean1415

drop if missing(cdscode) //there is one observation with missing cdscode


/* calculate the weighted average of qoi means pooled over years
ignore missing values */
/* Note: collapse doesn't work because the weight is different for each variable, would have to write everything out */
sort cdscode year

foreach i of numlist 10 20 24 41 44 64 87 98 103/105 109 111 112 128 {
  by cdscode: egen qoi`i'mean_pooled =  wtmean(qoi`i'mean), weight(nettotalresp`i')
}

/* generate the percentage agree/disagree for qoi 10 20 24 41 44 64 87 128 */
foreach i of numlist 10 20 24 41 44 64 87 128 {
  by cdscode: egen pctagree`i'_pooled = wtmean(pctagree`i'), weight(nettotalresp`i')
  by cdscode: egen pctdisagree`i'_pooled = wtmean(pctdisagree`i'), weight(nettotalresp`i')
}

/* generate pooled weighted average percentage small/big problem for qoi98 */
by cdscode: egen pctsmallprob98_pooled = wtmean(pctsmallprob98), weight(nettotalresp98)
by cdscode: egen pctbigprob98_pooled = wtmean(pctbigprob98), weight(nettotalresp98)

/* generate pooled weighted percentage yes/no for qoi 103/105 109 111 112 */
foreach i of numlist 103/105 109 111 112 {
  by cdscode: egen pctyes`i'_pooled = wtmean(pctyes`i'), weight(nettotalresp`i')
  by cdscode: egen pctno`i'_pooled = wtmean(pctno`i'), weight(nettotalresp`i')
}

collapse (mean) *pooled (sum) nettotalresp* missing*, by(cdscode)

/* label the pooled qoi means and nettotalresp and missing*/
foreach i of numlist 10 20 24 41 44 64 87 98 103/105 109 111 112 128 {
  label var qoi`i'mean_pooled "weighted mean of qoi`i' responses over years for a given school"
  label var nettotalresp`i' "net total responses for qoi`i' excluding missing pooled over years"
  label var missing`i' "number of missing responses for qoi`i' pooled over years"
}

********************** label all the weighted pooled vars **********************
/* label the pooled percent agree/disagree vars */
foreach i of numlist 10 20 24 41 44 64 87 128 {
  label var pctagree`i'_pooled "weighted average percent agree/strongly agree in qoi`i' pooled over years"
  label var pctdisagree`i'_pooled "weighted average percent disagree/strongly disagree in qoi`i' pooled over years"
}

/* label the pooled percent small/big problem  for qoi98 */
label var pctsmallprob98_pooled "weighted avg percent insignificant or mild problem in qoi98 pooled over years"
label var pctbigprob98_pooled "weighted avg percent moderate or severe problem in qoi98 pooled over years"

/* label the pooled percent yes/no for qoi 103/105 109 111 112 */
foreach i of numlist 103/105 109 111 112 {
  label var pctyes`i'_pooled "weighted avg percent yes in qoi `i' pooled over years"
  label var pctno`i'_pooled "weighted avg percent no in qoi`i' pooled over years"
}




/* there is no staff response rate so cannot merge with the response rate dataset */

label data "weighted average staff qoi statistics pooled over years"
compress
save $projdir/dta/buildanalysisdata/poolingdata/staffpooledstats, replace
