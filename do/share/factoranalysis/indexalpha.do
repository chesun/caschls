********************************************************************************
/* Cronbach's alpha for the 4 index categories */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/share/factoranalysis/indexalpha.smcl, replace

use $projdir/dta/allsvyfactor/categoryindex/compcasecategoryindex, clear

local climatevars parentqoi16mean_pooled parentqoi17mean_pooled parentqoi27mean_pooled secqoi22mean_pooled secqoi23mean_pooled secqoi24mean_pooled secqoi26mean_pooled secqoi27mean_pooled  secqoi29mean_pooled
local qualityvars parentqoi30mean_pooled parentqoi31mean_pooled parentqoi32mean_pooled parentqoi33mean_pooled parentqoi34mean_pooled secqoi28mean_pooled secqoi35mean_pooled secqoi36mean_pooled secqoi37mean_pooled secqoi38mean_pooled secqoi39mean_pooled secqoi40mean_pooled staffqoi20mean_pooled staffqoi24mean_pooled staffqoi87mean_pooled
local supportvars parentqoi15mean_pooled parentqoi64mean_pooled staffqoi10mean_pooled staffqoi128mean_pooled
/* local motivationvars secqoi31mean_pooled secqoi32mean_pooled secqoi33mean_pooled secqoi34mean_pooled */
/* Cronbach's alpha for the school climate index */
alpha `climatevars', std item

/* Cronbach's alpha for teacher and staff quality index */
alpha `qualityvars', std item

/* Cronbach's alpha for counseling support index */
alpha `supportvars', std item


log close
translate $projdir/log/share/factoranalysis/indexalpha.smcl $projdir/log/share/factoranalysis/indexalpha.log, replace 
