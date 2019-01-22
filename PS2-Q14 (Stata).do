set obs 1000
set seed 1234

//(a)
// data generating process
gen x1 = rnormal()
gen x2 = rnormal()
gen epsilon = rnormal()

gen y = 1 + x1 + x2 + epsilon
// OLS regression
reg y x1 x2

// (b)
predict epsilon_hat, res

// orthogonal with constant vector
sum epsilon_hat
display r(sum)

// with x1
gen x1eps = x1 * epsilon_hat
sum x1eps
display r(sum)

// with x2
gen x2eps = x2 * epsilon_hat
sum x2eps
display r(sum)

// (c)
// not orthogonal with constant vector
sum epsilon
display r(sum)

// not with x1
replace x1eps = x1 * epsilon
sum x1eps
display r(sum)

// not with x2
replace x2eps = x2 * epsilon
sum x2eps
display r(sum)

// (d)
reg x1 x2
predict nu_hat, res
// OLS regression of y on residuals nu_hat
// use option `nocon` (no constant term)
reg y nu_hat, nocon
