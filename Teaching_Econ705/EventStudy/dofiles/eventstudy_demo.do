*-----------------------------------------------------------------------------
* Event Study Demo
* Long Hong
* Nov. 12, 2021
*-----------------------------------------------------------------------------


* Data from repeated cross-sectional CPS (1989-2000)
* collected from Chris's paper: https://www.ssc.wisc.edu/~ctaber/DD/diffdiff.html


* Set working directory 
cd "/Users/long/Dropbox/Teaching/Sections/Section2" // change it to your own

* Importing cleaned data                            
use "data/data_eventstudy", clear 

	* knowing the variables
	describe coll merit   


*-----------------------------------------------------------------------------
* Set up ingredients
*-----------------------------------------------------------------------------
	
* Define the treated states 
bysort state: egen treat = max(merit)        // if ever had a merid aid program

	* double-check: Georgia
	sort state year 
	browse state year merit treat if state == 58  // Georgia
	

* Determine the starting years for each treated state 
bysort state: egen    startyr = min(year)   if merit == 1
bysort state: replace startyr = startyr[_N] if startyr == . 


* Create startyear, lags and leads on T*I{t=k}
bys state: gen treat_startyr = treat*(year == startyr)                // k = 0
forvalues i = 8(-1)1 {
	bysort state: gen treat_lagyr`i'  = treat*(year == startyr - `i') // k = -i 
}             
forvalues i = 1/8 {
	bysort state: gen treat_leadyr`i' = treat*(year == startyr + `i') // k = i
}
bysort state: replace treat_lagyr8  = treat*(year <= startyr - 8) // grouping if over 8 yrs
bysort state: replace treat_leadyr8 = treat*(year >= startyr + 8) 


*-----------------------------------------------------------------------------
* Regression - simplest part
*-----------------------------------------------------------------------------

reg coll treat_lagyr8-treat_lagyr2        /// omitting treat_lagyear1 (normalization)
		 treat_startyr                    /// start year
		 treat_leadyr1-treat_leadyr8      /// all lead years
		 male black asian i.year i.state, /// control var and fixed effects
		 cluster(state_year) noconstant   /// cluster s.e. at state x year level

* Export it to Latex/Word table
outreg2 using "results/tab_eventstudy.tex", ctitle(OLS) label keep(treat_*) tex(frag) replace /// 
	title("Event Study Estimates for Merit Aid programs on College Attendence")
		
outreg2 using "results/tab_eventstudy.doc", ctitle(OLS) label keep(treat_*) word replace /// 
	title("Event Study Estimates for Merit Aid programs on College Attendence")

reg coll treat_lagyr8-treat_lagyr2        /// omitting treat_lagyear1 (normalization)
		 treat_startyr                    /// start year
		 treat_leadyr1-treat_leadyr8      /// all lead years
		 male black asian i.year i.state, /// control var and fixed effects
		 cluster(state_year) noconstant   /// cluster s.e. at state x year level
		 
		 
outreg2 using "results/tab_eventstudy.doc", ctitle(OLS) label keep(treat_*) word append /// 
	title("Event Study Estimates for Merit Aid programs on College Attendence")
	
*-----------------------------------------------------------------------------
* Graph 
*-----------------------------------------------------------------------------

* Save the coefficients and s.e. into a matrix of 17x2
matrix res = J(17,3,.)
matrix rownames res = lagyr8 lagyr7 lagyr6 lagyr5 lagyr4 lagyr3 lagyr2 lagyr1 ///
	                  startyear ///
					  leadyr1 leadyr2 leadyr3 leadyr4 leadyr5 leadyr6 leadyr7 leadyr8 
matrix colnames res = coef se k 

forvalues i = 1/7 {
	local j = 9-`i'
	matrix res[`i',1] = _b[treat_lagyr`j']      // save coefficients 
	matrix res[`i',2] = _se[treat_lagyr`j']     // save s.e.
	matrix res[`i',3] = -`j'
}
matrix res[8,1] = 0  // normalized lag1, coefficient = 0
matrix res[8,2] = 0  // normalized lag1, s.e. = 0
matrix res[8,3] = -1 // normalized lag1
matrix res[9,1] = _b[treat_startyr]   
matrix res[9,2] = _se[treat_startyr]
matrix res[9,3] = 0
forval i = 1/8 {
	matrix res[`i'+9,1] = _b[treat_leadyr`i']
	matrix res[`i'+9,2] = _se[treat_leadyr`i']
	matrix res[`i'+9,3] = `i'
}
matlist res


* Graph using the saved matrix
clear
svmat res, names(col)


* calculate confidence intervals
gen ci_upper = coef+1.96*se
gen ci_lower = coef-1.96*se


* Graph
twoway (connected coef k)                      ///  
	   (rcap ci_upper ci_lower k, lc(black))   ///  
	, xlabel(-8(1)8) xtitle("Time to event (years)") xline(-0.5, lp(dash))  ///
	  ytit("Event study coefficients") yline(0)  ///	  
	  legend(off) title("Treatment Effects Over Time") ///
	  graphregion(color(white)) 


* Save graph	
graph export "results/plot_eventstudy.pdf", replace 


*-----------------------------------------------------------------------------
* Ending words:
* Perfectly fine if you cannot follow in the class
* Extremely helpful if you can learn it after class
*-----------------------------------------------------------------------------


