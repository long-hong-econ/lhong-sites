******************************************************************************
******************************************************************************
******************************************************************************
***								Lecture 1								   ***
***								Long Hong								   ***
***							  April 11, 2016							   ***
******************************************************************************
******************************************************************************
******************************************************************************


******************************************************************************
******************************************************************************
***				    Introduction to Stata Programming				       ***
******************************************************************************
******************************************************************************

* Stata
	* Right way to write it. 
	* Good for variable operations like regressions etc.
	* Not very good for matrix operations - build-in matrix language: Mata

* Use Resources
	* Google
	* UCLA: http://www.ats.ucla.edu/stat/stata/
		* Instructions and Examples
	* Statalist: http://www.statalist.org/forums/ 
		* Personalized Questions
		* Answered by some famous Stata specialists and Economists

* Syllabus
	* Basic commands and Extensions
		* Skip very basic commands (Always question if it is not basic for you!)
	* Commonly used commands in empirical research
		* Microeconometrics course for details
	* Stata Programming & ado file
		* Basic Programming skills that can be applied anywhere
		* Write your own program and help file
		* Statistics - Max. Likelihood Estimation (if time allowed)

* House Keeping Issues
	* Week of April 25th: Wednesday 18:00?
	* Stata Installation
	
* Problem Set
	* Done in class (First or Last 10 mins of the class)

* Expectation
	* The depth of the course depends on your efforts!



******************************************************************************
******************************************************************************
***			 			Basic Commands and Extensions					   ***
******************************************************************************
******************************************************************************


******************************************************************************
******			          Before Getting Started 					    ******
******************************************************************************

*

*** Start a fresh page
clear           /// remove all data and labels

clear all		/// remove all data, value labels, matrices, scalars, programs
				/// Careful when using -all- 
				/// because matrix, scalars, programs are not visible

set more off     


*** Working Dictionary
cd "/Users/admin/Dropbox/Stata Minicourse/Stata Lecture 1" 
	* The path under the Command Window changes

	* Professional way to manage multiple locations
	cap global data    "/Users/admin/Dropbox/Stata Minicourse/Data"
	cap global results "/Users/admin/Dropbox/Stata Minicourse/Results"
	cap global working "/Users/admin/Dropbox/Stata Minicourse/Stata Lecture 1"
	cap global logfile "/Users/admin/Dropbox/Stata Minicourse/Logfiles"
		* -global- (?)

cd "$working"   /// Alternative and Effective way for -cd-
	

*** Log Files
capture log close  
	
	* Important Command -capture-: skip error message
		* Avoid: Stata stops because of error message
	* Advanced: capture sometimes goes with noisely 
	capture noisely log close  /// shows the error message, but not stop Stata
		
log using stata_lesson_one, replace
	
	* Extension: "smcl" is default format: Stata Markup and Control Language
		* Language similar but inferior to LaTex
		* Important if you write a help file for your own program (later)
	* Change it to text format
	capture log close
	log using stata_lesson_one.text, text replace

log close   /// Never, never, never forgot to add close at the END of the do file.

*



******************************************************************************
******			    Import and Create Data				    	        ******
******************************************************************************

*** Import Excel or CSV 
import delimited "$working/ccode.csv", clear 
import excel "$working/ccode.xlsx", sheet("Sheet 1") firstrow clear
	
	* My (lazy) way:
		* Use manual way: File -> Import -> Choose file
		* Copy the command from review bar
		* Modify the filename using global working
	* Why?
		* Fast, no type at all (so many options to add!)
		* Error free
		* Preview(!)

*** Import .dta format data - Simple!
use "$working/jtrain2.dta", clear
use "jtrain2.dta", clear /// If it is already in the current working dictionary

use jtrain2, clear


*** Use Data Provided by Stata (Good for Learning Purpose)
	* Study some advanced subject in Stata like Survival Analysis
	* Study unfamilar commands

* System data installed with Stata
sysuse lifeexp, clear  

* Use data from Stata website
webuse lifeexp, clear
use http://www.stata-press.com/data/r13/lifeexp, clear


*** Input Data (I guess it is just for fun)
clear
input post_id like dislike
1 20 10
2 10 .
end


*** Random Generators <3
clear

set obs 5000      /// Set up the number of oberservations

	* Controversial Commond - Good for Replication
	set seed 1801133
	browse
	gen x1 = runiform()
	gen x2 = runiform()
	gen x3 = runiform()
	* The data does not change if you repeat the commands

gen y1 = rgamma(1, 2)
gen y2 = rpoisson(3)

	* For more details: Stata Blog: http://blog.stata.com/2012/07/18


* Advanced: Program your own random generator (Not required)
	* Simple Example: Exponential Function (Not found in Stata Random Generator)
	* Using Inverse Cumulative Distribution Function

gen p = runiform()
scalar lenda = 3
gen z = -ln(1-p)/(1/lenda)
	* Check the property of exponential function: Mean = S.D. = lenda
	sum z 


*** Save data
save data, replace

	* Extensions (save older version or erase data from do file)
	saveold data, replace
	capture erase data.dta

	
******************************************************************************
******			       Play with Variables		        		        ******
******************************************************************************

sysuse lifeexp, clear


* Data Type (Basic)
	* Black: Real values
	* Red:   String 
	* Blue:  String coded in real value (later) -> it is real value variable!


* Modify variables
label variable safewater "Water Quality Index" 

rename lexp life

replace life = 70 if life > 70  /// IF expressions: & (and); | (or); 
						       /// == (equal); != (not equal); >= (no lower); ...

	* Important Note: if there is missing value in "life", missing is larger 
	* than any real value. So if there is missing value, you should write:
	replace life = 70 if life > 70 & life != . 
	
	* Always, always, always check if there is missing value in a variable!


drop if country == "Italy"     /// " " for string values

drop in 1
keep in 1/60                   /// Keep selected lines

sort life  					   /// sort data from lowest to highest

order country region           /// order the sequence of the variable in browser
							   /// Useful when many variables

* Generate Variables
gen lnlife = ln(life)          /// Operations ^, sqrt(), *, / ...

gen id = _n                    /// Unique Identifier
	
	display _N 				   /// _N: total observation 
	
	count

egen mean_life = mean(life)    /// egen: operations within a var: mean, sum, ...

help egen				      /// Highly recommended to look at the help file!
							  /// One of the most important commands!

	* Important: egen is often used with bysorts
	* bysorts: sort a certain variable, and operate within each category
	bysort region: egen life_mean = mean(life)
		* Different means for Europe, N. America and S. America

gen high = 1
replace high = 0 if life < 65 

	* Better Way of creating a dummy!
	gen high1 = (life > 65)   


* Preserve and Restore 
	* To work with the data, but do not want to destroy the current data
	* Useful when generating matrix and scalars (later)
	* A basic sense here
preserve

keep if region == 1              /// Again, region is a numeric variable

restore       					 /// The deleted data comes back 



******************************************************************************
******			       		String Variables  		  	         		******
******************************************************************************

sysuse lifeexp, clear
browse

*** String and Numeric
tostring lexp, gen(life)  /// For some reason, numeric data is stored as string

destring life, replace    /// Transfer string to numeric 

destring country, gen(country_num) /// country contains nonnumeric characters

*** Generate String Variables
gen year = "2000"
gen countryyear = country + year        /// Operations between string variables 

gen country_year = country + " " + year   /// Nicer with a space
	
*** Play with String Variables
gen ccode = substr(country, 1, 3)  /// Extract letters: starting from 1st letter
								   /// extrat 3 letters from variable country

	replace ccode = upper(ccode)
	replace ccode = lower(ccode)

gen country2 = subinstr(country, "a", "XXX", 2) 
gen country3 = subinstr(country, "a", "XXX", .)   /// Case sensitive

*** Encode/decode: code string into numeric and vice versa
encode country, gen(country_id)  /// Generate Country ID (Blue!) - Numeric!

	* How to look at the numeric values
	tab country_id               /// same as "tab country"

	tab country_id, nolabel      /// "nolabel" option shows numeric values

decode region, gen(region_name)  /// numeric to string

