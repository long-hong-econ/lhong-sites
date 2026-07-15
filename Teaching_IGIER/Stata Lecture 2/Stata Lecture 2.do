******************************************************************************
******************************************************************************
******************************************************************************
***								Lecture 2								   ***
***								Long Hong								   ***
***							  April 18, 2016							   ***
******************************************************************************
******************************************************************************
******************************************************************************


******************************************************************************
***			 		      Initial Set Ups								   ***
******************************************************************************

global working "C:\Users\1801133\Desktop\Stata Lecture 2"
global data    "C:\Users\1801133\Desktop\Stata Lecture 2\Data"

cd "$working"

clear all
set more off

capture log close
log using lesson_two, replace


******************************************************************************
***			 		Common Problems	from Last Class						   ***
******************************************************************************

*** Write shorter - Speed up your coding and make do file more concise.

* Short command -> refer to the do file
help summarize      /// Check the underlines
					/// Same idea for options

* Short variable names
sysuse lifeexp, clear

sum l               /// Stata knows l refers to lexp
					/// because it is the only one starting with l

sum g

gen life = 60 
cap noi sum l 				/// error message: "l ambiguous abbreviation"
	
	*! Be careful in using short notion of the variable!
	** In real research, people tends to write the full names instead of short

* Extension: Use of "*"
	
	* Example: How to creat a set of dummies? - Country Fixed Effects
	tab country                    /// everyone knows this
	
	tab country, gen(country_)     /// Generate country dummies
	
	sum country*
	sum country_*				    /// "*" also includes null -> use "_"



*** Do Files - You have to be comfortable in writing your codes in do file!!!

* (1) open from main system
* (2) -doedit-
* (3) send from review

* Save the do file "trial"
do "trial.do"
run "trial.do"

	
*** Why global folder locations (other examples later)

sysuse lifeexp, clear

* Save it to the data folder
cd "$data"
saveold lifeexp, replace

* Go back to working folder
cd "$working"



******************************************************************************
****			       		Organize Data   		  	         		  ****
******************************************************************************

*** Reshape - Very useful for Panel Data Organization

help reshape                   /// Refer to the graph illustration

webuse reshape3, clear         /// Use the example from help file

drop inc*					   /// Drop inc for now, go back after

reshape long ue, i(id) j(year) 	
  * long: the type you want to change to 
  * inc: the variable you wan to make it long - you should have number attached
  * Think it as panel data - ind & year i(): ind | j() year

	* Extension: How about inc80r? (Not used often - just let you know)
	webuse reshape3, clear 
	drop ue*
	reshape long inc@r, i(id) j(year) 
	
reshape wide incr, i(id) j(year) 

	* !Note: the difference between long and wide is the variable in j()
	* is a new variable in "long" and an exisiting variable in "wide"


*** Duplicates

sysuse lifeexp, clear

* expand - duplicate observations
expand 3        				/// Data is duplicated twice (3 - 1)

expand 6 if country == "Italy"  /// Certain observation is duplicated 5 times



* How to detect if there is duplicates in data
sysuse lifeexp, clear
expand 6 in 1/2

duplicates list     /// !Always! check if there is duplicates in raw data

duplicates drop		/// It is not drop duplicates, but duplicates drop!
					/// help file: study "force" option, and duplicate report
					/// they are both simple, but very useful!
					

*** Merge

* Check the data to be merged
cd "$data"

use ccode, clear

	* Check duplicates!
	duplicates list
	duplicates drop
	saveold ccode_nodup, replace   /// Do not cover the original data!

* Merge data
sysuse lifeexp, clear
merge 1:1 country using ccode_nodup
	
	* Review: blue type variable - numeric 
	* _merge == 1: not match from master (lifeexp)
	* _mereg == 2: not match from using (ccode_nodup)
	* _merge == 3: matched
	* Think why it happened...
	browse if _merge == 1    /// (i) ccode dataset has different names
							 /// (ii) ccode does not have it as a country

keep if _merge == 3       /// Keep the matched ones

drop _merge               /// _merge is generated in every -merge- - drop

	* Alternative: Not recommended
	merge 1:1 country using ccode_nodup, keep(master match)
	drop _merge           /// In this way, you cannot notice that why one 
						  /// observation is dropped. 
						  /// Dangerous for research
						

sysuse lifeexp, clear
expand 6 if country == "Italy" 		

cap noi merge 1:1 country using ccode_nodup
	* Error Message: variable country does not uniquely identify 
	* observations in the master data
	
merge m:1 country using ccode_nodup
drop _merge


*** Append

use ccode_1_10, clear

append using ccode_11_20
append using ccode_21_30

	* Note: append can be powerful, see help file
	help append
	* But those variations are not often used


******************************************************************************
****			       		Graphs			 		  	         		  ****
******************************************************************************

*** First Comment: Stata language in graphs is the least interesting one!

sysuse lifeexp, clear

*** Commonly used command
hist lexp           /// check help hist to gain knowledge in changing bin(#)
					/// width(#) and start(#), as well as other options
					
scatter lexp safewater

twoway lfit lexp safewater

twoway (scatter lexp safewater) (lfit lexp safewater)


*** From programming point of view, graph language is not very standard
	*** Book: A Visual Guide to Stata Graphics
	
	

******************************************************************************
****			       Regressions and  Results			          		  ****
******************************************************************************

*** Regression life = constant + safewater + controls + regional controls

tab region, gen(region_)

local controls "popgrowth gnppc region_*"
global controls "popgrowth gnppc region_*"

regress lexp safewater `controls', robust 
regress lexp safewater $controls , robust

	* A note on "i."
	regress lexp safewater popgrowth gnppc region_*, robust 
	regress lexp safewater popgrowth gnppc i.region, robust 
		* "i." makes dummies automatically - often used by economists
		* not often used by Stata programmer, because it makes matrix 
		* hard to organized - e.g. Bruno never used it


*** Save Results: eststo and outreg2

	* detour: findit / ssc install
	findit eststo             
	ssc install outreg2 /// ssc (Boston College Statistical Software Components

** eststo 

eststo clear 

regress lexp safewater, robust
eststo
eststo: regress lexp safewater popgrowth, robust   /// save a line

eststo: regress lexp safewater $controls, robust

esttab using table1.csv, replace starlevels( * 0.10 ** 0.05 *** 0.01) nogap 
	* Make sure you set the significant level - default is not convential
	* Study help files to make your table personalized


** outreg2
regress lexp safewater, robust
outreg2 using table2.xls, replace
regress lexp safewater popgrowth, robust
outreg2 using table2.xls, append            /// append instead of replace

regress lexp safewater $controls, robust
outreg2 using table2.xls, append
	* Again, use help files to study how to make your own table personalized


*** eststo or outreg2
	* No preferences: both used by frontier researchers
	* Tradeoff:
		* outreg2 is more popular because it produces nicer table
		* eststo better for programming your code and save lines
	* What I do:
		* use eststo for initial results
		* save the final drafts using outreg2


******************************************************************************
****			       		Plan for Next Week 		  	         		  ****
******************************************************************************

*** Scalar Matrix

*** Loops

*** Simple Programming
viewsource regress.ado



log close
