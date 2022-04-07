********************************************************************************
/* rename and clean parent 1819 and 1718 survey questions of interest. This file
supercedes parentqoiclean1718.do*/
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/build/buildanalysisdata/qoiclean/parent/parentqoiclean1819_1718.smcl, replace

/* the code for cleaning 1819 and 1718 is exactly the same, so use loop */
local years `" "1718" "1819" "'

foreach year of local years {
use $clndtadir/parent/parent`year', clear
//only keep questions of interest
keep cdscode p9 p15 p16 p17 p27 p30 p31 p32 p33 p34 p64
//rename questions of interest using question numbers in 1819 as standard
foreach i of numlist 9 15/17 27 30/34 64 {
  rename p`i' qoi`i'
}
//relabel the value labels to be consistent with var name
elabel rename (p*) (qoi*)
//delete all value labels not associated with variables
labdu , delete

/* count the total number of responses in each school */
sort cdscode
by cdscode: gen totalresp = _N
label var totalresp "total number of responses at each school including missing"


********************************************************************************
/* qoi 9, 15-17, 27, 30-34 have the same response options, so clean them in the
same batch */

/* value labels for qoi 9, 15-17, 27, 30-34:
1 strongly agree
2 agree
3 disagree
4 strongly disagree
5 don't know/NA

Recode:
-2 strongly disagree
-1 disagree
0 neutral
1 agree
2 strongly agree
*/

/* recode qoi 9, 15-17, 27, 30-34 */
foreach i of numlist 9 15/17 27 30/34 {
  gen qoi`i'temp = .
  replace qoi`i'temp = -2 if qoi`i' == 4
  replace qoi`i'temp = -1 if qoi`i' == 3
  replace qoi`i'temp =  0 if qoi`i' == 5
  replace qoi`i'temp =  1 if qoi`i' == 2
  replace qoi`i'temp =  2 if qoi`i' == 1

  drop qoi`i'
  rename qoi`i'temp qoi`i'
}

/* generate dummies for each response option and missing for qoi 9, 15-17, 27, 30-34 */
foreach i of numlist 9 15/17 27 30/34 {
  gen stragree`i' = 0
  replace stragree`i' = 1 if qoi`i' == 2

  gen agree`i' = 0
  replace agree`i' = 1 if qoi`i' == 1

  gen disagree`i' = 0
  replace disagree`i' = 1 if qoi`i' == -1

  gen strdisagree`i' = 0
  replace strdisagree`i' = 1 if qoi`i' == -2

  gen dontknow`i' = 0
  replace dontknow`i' = 1 if qoi`i' == 0

  gen missing`i' = 0
  replace missing`i' = 1 if missing(qoi`i')
}

********************************************************************************
/* clean qoi 64 as it has different resonse options */

/* value labels for qoi64:
1 very well
2 just okay
3 not very well
4 does not do it at all
5 don't know/NA

recode:
-2 does not do it at all
-1 not very well
0 dont know
1 just okay
2 very well
 */

/* recode qoi 64 */
 gen qoi64temp = .
 replace qoi64temp = -2 if qoi64 == 4
 replace qoi64temp = -1 if qoi64 == 3
 replace qoi64temp =  0 if qoi64 == 5
 replace qoi64temp =  1 if qoi64 == 2
 replace qoi64temp =  2 if qoi64 == 1

 drop qoi64
 rename qoi64temp qoi64

 gen verywell64 = 0
 replace verywell64 = 1 if qoi64 == 2

 gen justokay64 = 0
 replace justokay64 = 1 if qoi64 == 1

 gen notwell64 = 0
 replace notwell64 = 1 if qoi64 == -1

 gen doesnotdo64 = 0
 replace doesnotdo64 = 1 if qoi64 == -2

 gen dontknow64 = 0
 replace dontknow64 = 1 if qoi64 == 0

 gen missing64 = 0
 replace missing64 = 1 if missing(qoi64)


/* generate means for the qoi  */
foreach i of numlist 9 15/17 27 30/34 64 {
  egen qoi`i'mean = mean(qoi`i'), by(cdscode)
}


/* This is old code before the recoding of qoi values
 /* generate mean of vars, excluding don't know. */
 //generate temp vars for low and high bounds to use with rangestat
 gen lowbound = 1
 gen highbound = 4
foreach i of numlist 9 15/17 27 30/34 64 {
  rangestat (mean) qoi`i', interval(qoi`i' lowbound highbound) by(cdscode)
  rename qoi`i'_mean qoi`i'mean //rename the generated mean vars
}
/* Note: don't worry about missing values generated because it does not matter
after collapsing dataset */
drop lowbound highbound //drop the temp vars */



/* collapse the dataset, resulting dataset has mean for each qoi, total number
of responses, and number of responses for each option in each question */
collapse (mean) qoi*mean totalresp (sum) stragree* agree* disagree* strdisagree* dontknow* missing* verywell64 justokay64 notwell64 doesnotdo64, by(cdscode)
//some schools have missing means because they have very low number of responses and with either don't know or missing


**************************** relabel the vars **********************************
/* label mean vars */
label var qoi9mean "Mean (excluding don't know) of Q: promotes academic success for all students"
label var qoi15mean "Mean (excluding don't know) of Q: provides quality counseling or other ways..."
label var qoi16mean "Mean (excluding don't know) of Q: is a supportive and inviting place..."
label var qoi17mean "Mean (excluding don't know) of Q: allows input and welcomes parents'..."
label var qoi27mean "Mean (excluding don't know) of Q: encourages me to be an active partner..."
label var qoi30mean "Mean (excluding don't know) of Q: provides high quality instruction..."
label var qoi31mean "Mean (excluding don't know) of Q: motivates students to learn"
label var qoi32mean "Mean (excluding don't know) of Q: has teachers who go out of their way..."
label var qoi33mean "Mean (excluding don't know) of Q: has adults who really care about students"
label var qoi34mean "Mean (excluding don't know) of Q: has high expectations for all students"
label var qoi64mean "Mean (excluding don't know) of Q: provoding information on how to help..."

label var totalresp "total number of responses in the school including missing"

/* label vars for the number of response for each option */
foreach i of numlist 9 15/17 27 30/34 {
  label var stragree`i' "number of people choosing strongly agree for qoi`i'"
  label var agree`i' "number of people choosing agree for qoi`i'"
  label var disagree`i' "number of people choosing disagree for qoi`i'"
  label var strdisagree`i' "number of people choosing strongly disagree for qoi`i'"
  label var dontknow`i' "number of people choosing don't know for qoi`i'"
  label var missing`i' "number of missing responses for qoi`i'"
}

label var verywell64 "number of people choosing very well for qoi64"
label var justokay64 "number of people choosing just okay for qoi64"
label var notwell64 "number of people choosing not very well for qoi64"
label var doesnotdo64 "number of people choosing does not do it at all for qoi64"
label var dontknow64 "number of people choosing don't know for qoi64"
label var missing64 "number of missing responses for qoi64"

********************* generate percentage agree/disagree etc *******************
/* first, generate the net total responses for each question excluding missing */
foreach i of numlist 9 15/17 27 30/34 64 {
  gen nettotalresp`i' = totalresp - missing`i'
  label var nettotalresp`i' "net total responses for qoi`i' excluding missing "
}

/* generate percent disagree/agree for qoi 9 15/17 27 30/34 */
foreach i of numlist 9 15/17 27 30/34 {
  gen pctdisagree`i' = (strdisagree`i' + disagree`i')/nettotalresp`i'
  label var pctdisagree`i' "percent strongly disagree or disagree in qoi`i'"
  gen pctagree`i' = (stragree`i' + agree`i')/nettotalresp`i'
  label var pctagree`i' "percent strongly agree or agree in qoi`i'"
  gen pctdontknow`i' = dontknow`i'/nettotalresp`i'
  label var pctdontknow`i' "percent don't know in qoi`i'"
}

/* generate percent well/not well for qoi64 */
gen pctwell64 = verywell64/nettotalresp64
label var pctwell64 "percent very well in qoi64"
gen pctokay64 = justokay64/nettotalresp64
label var pctokay64 "percent just okay in qoi64"
gen pctnotwell64 = (notwell64 + doesnotdo64)/nettotalresp64
label var pctnotwell64 "percent not well or does not do at all in qoi64"
gen pctdontknow64 = dontknow64/nettotalresp64
label var pctdontknow64 "percent don't know in qoi64"

/* generate a year var to prepare for constructing a panel */
gen year = `year'


label data "cleaned parent `year' survey questions of interest with percent disagree/agree etc."
compress
save $projdir/dta/buildanalysisdata/qoiclean/parent/parentqoiclean`year', replace
}


log close
translate $projdir/log/build/buildanalysisdata/qoiclean/parent/parentqoiclean1819_1718.smcl $projdir/log/build/buildanalysisdata/qoiclean/parent/parentqoiclean1819_1718.log, replace
