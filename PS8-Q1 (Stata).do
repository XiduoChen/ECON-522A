clear
set obs 1000
set seed 1234

// data generating process
matrix C = (1., 0.5 \ 0.5, 1.)
matrix mu = (0., 0.)
drawnorm x_star z, n(1000) cov(C) mean(mu)

gen u = rnormal(0, 1)
gen v = rnormal(0, 1)
gen v2 = rnormal(0, 1)

gen x = x_star + v
gen x2 = x_star + v2

gen y = 1 + x_star + z + u

// OLS
reg y x z

// IV
ivreg y (x = x2) z

// 2SLS
// first stage
reg x x2 z
predict x_fitted, xb

// second stage
reg y x_fitted z

drop x_star z u v v2 x x2 y
// simulation
program sim, rclass
	drawnorm x_star z, n(1000) cov(C) mean(mu)

	gen u = rnormal(0, 1)
	gen v = rnormal(0, 1)
	gen v2 = rnormal(0, 1)

	gen x = x_star + v
	gen x2 = x_star + v2

	gen y = 1 + x_star + z + u
	

	ivreg y (x = x2) z
	
	drop x_star z u v v2 x x2 y
	
	return scalar alpha = _b[_cons]
	return scalar beta = _b[x]
	return scalar gamma = _b[z]
	
end

simulate alpha = r(alpha) beta = r(beta) gamma = r(gamma), reps(10000): sim

hist alpha
hist beta
hist gamma
