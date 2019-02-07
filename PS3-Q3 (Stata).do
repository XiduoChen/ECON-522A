clear
set obs 1000
set seed 1234

// data generating process
gen x1 = rnormal()
gen x2 = rnormal()
gen epsilon = rnormal()

gen y = 1 + x1 + x2 + epsilon
// OLS regression
reg y x1 x2

// (a) t test
test x1 == 0

// (b) F test
test x1 == 0, notest
test x2 == 0, accum
