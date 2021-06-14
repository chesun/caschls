********************************************************************************
/* Cronbach's alpha test for survey qois */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************


/* secondary */
use $projdir/dta/buildanalysisdata/analysisready/secanalysisready, clear

/* std: standardize items in the scale to mean 0, variance 1
item: display item-test and item-rest correlations*/
alpha *mean_pooled, std item

//copy and paste results table and text to column in excel


/* parent */
use $projdir/dta/buildanalysisdata/analysisready/parentanalysisready, clear
alpha *mean_pooled, std item


/* staff */
use $projdir/dta/buildanalysisdata/analysisready/staffanalysisready, clear
alpha *mean_pooled, std item





/* Alpha for question classifications  */
use $projdir/dta/allsvyfactor/allsvyqoimeans, clear 
//School Climate
alpha parentqoi9mean_pooled parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi25mean_pooled secqoi26mean_pooled secqoi27mean_pooled secqoi28mean_pooled secqoi29mean_pooled secqoi30mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi41mean_pooled staffqoi44mean_pooled staffqoi64mean_pooled staffqoi87mean_pooled staffqoi98mean_pooled, std item


//Teacher and Staff Quality
alpha parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled staffqoi103mean_pooled staffqoi104mean_pooled staffqoi105mean_pooled staffqoi109mean_pooled staffqoi111mean_pooled staffqoi112mean_pooled, std item

//Support for Students
alpha parentqoi15mean_pooled parentqoi64mean_pooled staffqoi10mean_pooled staffqoi128mean_pooled, std item

//Student Motivation
alpha secqoi31mean_pooled secqoi32mean_pooled secqoi33mean_pooled secqoi34mean_pooled, std item
