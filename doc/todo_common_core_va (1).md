# The Impact of School Quality on Postsecondary Success: Evidence in the Era of Common Core

## To Do List

1. [ ] Add 2018 and 2019 11th graders to VA analyses 2. [ ] Add NSC data for spring 2018 and spring 2019 high school graduates.
	1. [ ] Compare cohort counts between 2010-2017 NSC data and new data.
	2. [ ] Compare cohort summary statistics between 2010-2017 NSC data and new data.
3. [ ] Use siblings to estimate bias
	1. [ ] Sibling FE as an additional demographic control in our value added estimation.
		* $$ Y_{ist} = \phi_0 + \phi_1 X_{ist} + \text{Sibling FE}_{i} + \gamma_{t} + \underbrace{\lambda_{st} + \xi_{st} + \epsilon_{ist}}_{u_{ist}} $$
	2. [ ] Proportion of older siblings that attended college as an additional demographic control in our value added estimation.
		* $$ Y_{ist} = \phi_0 + \phi_1 X_{ist} + \text{Prop. Siblings College}_{i} + \gamma_{t} + \underbrace{\lambda_{st} + \xi_{st} + \epsilon_{ist}}_{u_{ist}} $$
	3. [ ] Specification test with sibling FE (use the VA estimates that were run without sibling FE, Score residuals on Sibling FE and VA estimates)
		* $$ Y_{ist} = \phi_0 + \phi_1 X_{ist} + \text{Sibling FE}_{i} + \gamma_{t} + \hat{\lambda}_{st} + \epsilon_{ist} $$
	4. [ ] Proportion of older siblings that attended college as a leave-out variable to use for a forecast bias test.
		* $$ \text{Prop. Siblings College}_{i} = \phi_0 + \phi_1 X_{ist} + \gamma_{t} + \hat{\lambda}_{st} + \epsilon_{ist} $$
	5. [ ] Sibling FE as an additional control for regressions of long-run outcomes on value added (lambda is test score VA, beta is long run outcome VA).
		* $$ Y_{ist} = \alpha_{0} + \alpha_{1} X_{ist} + \text{Sibling FE}_{i} + \gamma_{t} + \underbrace{\rho \lambda_{st} + \beta_{st} + \theta_{st} + e_{ist}}_{\nu_{ist}} $$
	6. [ ] Proportion of older siblings that attended college as an additional control for regressions of long-run outcomes on value added.
		* $$ Y_{ist} = \alpha_{0} + \alpha_{1} X_{ist} + \text{Prop. Siblings College}_{i} + \gamma_{t} + \underbrace{\rho \lambda_{st} + \beta_{st} + \theta_{st} + e_{ist}}_{\nu_{ist}} $$