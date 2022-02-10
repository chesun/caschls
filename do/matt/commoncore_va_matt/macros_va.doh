#delimit ;

**** Dates ;
local test_score_min_year
	2015
	;

local test_score_max_year
	2019
	;

local star_min_year
	2003
	;

local star_max_year
	2013
	;

local caaspp_min_year
	2015
	;

local caaspp_max_year
	2019
	;

local outcome_min_year
	2015
	;

local outcome_max_year
	2018
	;




**** Outcome Strings ;
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




**** Value Added ;
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
	i.year#(c.prior_ela_z_score##c.prior_ela_z_score##c.prior_ela_z_score)
	;

local peer_ela_score_controls
	i.year#(c.peer_prior_ela_z_score##c.peer_prior_ela_z_score##c.peer_prior_ela_z_score)
	;

local math_score_controls
	i.year#(c.prior_math_z_score##c.prior_math_z_score##c.prior_math_z_score)
	;

local peer_math_score_controls
	i.year#(c.peer_prior_math_z_score##c.peer_prior_math_z_score##c.peer_prior_math_z_score)
	;

local va_control_vars "`school_controls' `demographic_controls'" ;
local va_control_vars : subinstr local va_control_vars "i." "", all ;
local va_control_vars : list uniq va_control_vars ;

local census_grade
	6
	;

local census_controls
	/*eth_white_pct*/ eth_asian_pct eth_hispanic_pct eth_black_pct /*eth_other_pct*/
	educ_hs_dropout_prop /*educ_deg_2year_prop*/ educ_deg_4year_plus_prop
	pov_fam_child_lt18_pct
	inc_median_hh
	;




**** School Characteristics ;
local sch_chars
	fte_teach_pc fte_pupil_pc /*fte_admin_pc*/
	/*eng_learner_staff_pc*/
	new_teacher_prop
	/*educ_grad_sch_prop educ_associate_prop*/
	/*status_tenured_prop*/
	credential_full_prop
	/*authorization_stem_prop authorization_ela_prop*/
	c.male_prop##c.enr_male_prop
	c.eth_minority_prop##c.enr_minority_prop
	enr_total
	;

local sch_char_vars "`sch_chars'" ;
local sch_char_vars : subinstr local sch_char_vars "i." "", all ;
local sch_char_vars : subinstr local sch_char_vars "c." "", all ;
local sch_char_vars : subinstr local sch_char_vars "##" " ", all ;
local sch_char_vars : subinstr local sch_char_vars "#" " ", all ;
local sch_char_vars : list uniq sch_char_vars ;

local dem_chars
	enr_male_prop
	enr_minority_prop
	frpm_prop el_prop
	enr_total
	;

local dem_char_vars "`dem_chars'" ;
local dem_char_vars : list uniq dem_char_vars ;

local expenditures
	expenditures_instr_pc
	expenditures3000_pc
	expenditures4000_pc
	expenditures_other_pc
	expenditures7000_pc
	;

local expenditure_vars "`expenditures'" ;
local expenditure_vars : list uniq expenditure_vars ;

local sch_char_control_vars : list sch_char_vars | dem_char_vars ;
local sch_char_control_vars : list sch_char_control_vars | expenditure_vars ;


#delimit cr
