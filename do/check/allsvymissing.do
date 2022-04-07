********************************************************************************
/* check the distrubution of missing for merged allsvyqoimeans.dta */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off


log using "$projdir/log/check/allsvymissing.smcl", replace name(allsvymissing) //log file to make mvpatterns results easier to copy

use $projdir/dta/allsvyfactor/allsvyqoimeans, clear

/* generate a var that tallies the number of missing qoimean vars in each observation */
egen nmissall = rmiss(*mean_pooled)
tab nmissall

local climatevars parentqoi9mean_pooled parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi25mean_pooled secqoi26mean_pooled secqoi27mean_pooled secqoi28mean_pooled secqoi29mean_pooled secqoi30mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi41mean_pooled staffqoi44mean_pooled staffqoi64mean_pooled staffqoi87mean_pooled staffqoi98mean_pooled
local qualityvars parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled staffqoi103mean_pooled staffqoi104mean_pooled staffqoi105mean_pooled staffqoi109mean_pooled staffqoi111mean_pooled staffqoi112mean_pooled
local supportvars parentqoi15mean_pooled parentqoi64mean_pooled staffqoi10mean_pooled staffqoi128mean_pooled
local motivationvars secqoi31mean_pooled secqoi32mean_pooled secqoi33mean_pooled secqoi34mean_pooled

egen nmissclimate = rmiss(`climatevars')
tab nmissclimate

egen nmissquality = rmiss(`qualityvars')
tab nmissquality

egen nmisssupport = rmiss(`supportvars')
tab nmisssupport

egen nmissmotivation = rmiss(`motivationvars')
tab nmissmotivation

/* missing value patterns for schol climate questions */
mvpatterns `climatevars'
/* missing value patterns for schol teacher and staff quality questions*/
mvpatterns `qualityvars'
/* missing value patterns for student support questions*/
mvpatterns `supportvars'
/* missing value patterns for student motivation questions */
mvpatterns `motivationvars'



log close allsvymissing
translate $projdir/log/check/allsvymissing.smcl $projdir/log/check/allsvymissing.log, replace 
