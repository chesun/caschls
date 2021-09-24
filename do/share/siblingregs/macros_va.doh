#delimit ;

local test_score_min_year
	2015
	;

local test_score_max_year
	2019
	;

local outcome_min_year
	2015
	;

local outcome_max_year
	2018
	;

local ela_str
	"ELA"
	;
local math_str
	"Math"
	;

local enr_str
	"Enrolled On Time"
	;
local enr_2year_str
	"Enrolled On Time 2-Year"
	;
local enr_4year_str
	"Enrolled On Time 4-Year"
	;

local school_controls
	/*cohort_size*/
	;

local demographic_controls
	age
	i.male
	i.eth_asian i.eth_hispanic i.eth_black i.eth_other
	i.econ_disadvantage
	i.limited_eng_prof
	i.disabled
	;

local peer_demographic_controls
	peer_age
	peer_male
	peer_eth_asian peer_eth_hispanic peer_eth_black peer_eth_other
	peer_econ_disadvantage
	peer_limited_eng_prof
	peer_disabled
	;

local ela_score_controls
	c.prior_ela_z_score##c.prior_ela_z_score##c.prior_ela_z_score
	;

local math_mizero_controls
	c.prior_math_z_score_mizero##c.prior_math_z_score_mizero##c.prior_math_z_score_mizero
	i.mi_prior_math_z_score
	i.mi_prior_math_z_score#(
		c.prior_ela_z_score##c.prior_ela_z_score##c.prior_ela_z_score
	)
	;

local peer_ela_score_controls
	c.peer_prior_ela_z_score##c.peer_prior_ela_z_score##c.peer_prior_ela_z_score
	;

local math_score_controls
	c.prior_math_z_score##c.prior_math_z_score##c.prior_math_z_score
	;

local ela_mizero_controls
	c.prior_ela_z_score_mizero##c.prior_ela_z_score_mizero##c.prior_ela_z_score_mizero
	i.mi_prior_ela_z_score
	i.mi_prior_ela_z_score#(
		c.prior_math_z_score##c.prior_math_z_score##c.prior_math_z_score
	)
	;

local peer_math_score_controls
	c.peer_prior_math_z_score##c.peer_prior_math_z_score##c.peer_prior_math_z_score
	;

local va_control_vars "`school_controls' `demographic_controls'" ;
local va_control_vars : subinstr local va_control_vars "i." "", all ;
local va_control_vars : list uniq va_control_vars ;

local census_controls
	/*eth_white_pct*/ eth_asian_pct eth_hispanic_pct eth_black_pct /*eth_other_pct*/
	educ_hs_dropout_prop /*educ_deg_2year_prop*/ educ_deg_4year_plus_prop
	pov_fam_child_lt18_pct
	inc_median_hh
	;

#delimit cr
