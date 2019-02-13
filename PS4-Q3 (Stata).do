clear
set obs 1000
set seed 1234

// data generating process
gen x1 = rnormal(0, 1)
gen x2 = rnormal(0, 5)
gen epsilon = rnormal(0, 1)

gen y = 1 + x1 + x2 + epsilon


// OLS regression
reg y x1 x2
global beta1 = _b[x1]
global beta2 = _b[x2]
predict uhat, res

// store the impact on xb
predict xb1, xb
gen xb2=0
// store the impact on beta1 and beta2
gen beta_diff = 0
// store the impact on beta1
gen beta1_diff = 0

// run 1000 times of subsample regression
gen flag=0
forval i = 1/1000 {
	quietly {
		replace flag=1 if _n == `i'
		reg y x1 x2 if flag == 0
		local beta1i = _b[x1]
		local beta2i = _b[x2]
		predict xb3, xb
		replace xb2 = xb3 if _n == `i'
		
		local beta1_diff_sca = abs(`beta1i' - $beta1) 
		replace beta1_diff = `beta1_diff_sca' if _n == `i'
		local beta_diff_sca = sqrt((`beta1i' - $beta1)^2 + (`beta2i' - $beta2)^2)
		replace beta_diff = `beta_diff_sca' if _n == `i'
		
		// clean
		drop xb3
		replace flag=0 if _n == `i'
	}
}

// fint the 5 most influential points for xb
gen diff = abs(xb1 - xb2)
sort diff
gen influ1 = 0
replace influ1 = 1 if _n > 995

// fint the 5 most influential points for beta1 and beta2
sort beta_diff
gen influ2 = 0
replace influ2 = 1 if _n > 995

// fint the 5 most influential points for beta1
sort beta1_diff
gen influ3 = 0
replace influ3 = 1 if _n > 995

twoway (scatter x1 x2, mcolor(gs10)) ///
(scatter x1 x2 if influ1 == 1, mcolor(black)) ///
(scatter x1 x2 if influ2 == 1, mcolor(red)) ///
(scatter x1 x2 if influ3 == 1, mcolor(green))

count if (influ1==1) & (influ2==1) // xb and beta
count if (influ1==1) & (influ3==1) // xb and beta1
count if (influ2==1) & (influ3==1) // beta and beta1

// use matrix calculation
// calculate the influence on beta1 as an example
// this is total influence, including the impact of x an u
set matsize 1000

gen cons = 1
mkmat cons x1 x2, matrix(X)
mkmat uhat, matrix(uhat)

mat XX_inv = inv(X' * X)
mat numerator_part = XX_inv * X'
mat denominator_part = X * inv(X' * X) * X'

gen beta1_diff2 = 0
forval i = 1/1000 {
	local ratio = abs(numerator_part[2, `i'] * uhat[`i'] / ///
	(1 - denominator_part[`i', `i']))
	quietly replace beta1_diff2 = `ratio' if _n == `i'
}

// the results are the same with using multiple regressions
count if abs(beta1_diff - beta1_diff2) < 1e-8
