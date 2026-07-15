*-----------------------------------------------------------------------------
* Instrumental Variable Demo
* Long Hong
* Nov. 19, 2021
*-----------------------------------------------------------------------------

ssc install outreg2

* Set working directory 
cd "/Users/long/Dropbox/Teaching/Sections/IV" // change it to your own

* Data from Card (1993) NBER

* Importing cleaned data                            
use "data/card1993", clear 

* knowing key variables
describe lwage educ nearc4   // our Y, X, and Z	

* Plain OLS beta = 0.077
reg lwage educ exper expersq black married south66, robust 
	

*-----------------------------------------------------------------------------
* Instrumental variables (nearc4)
*-----------------------------------------------------------------------------	


* First stage (Relevance) - regress X on Z (significant)
reg educ nearc4 exper expersq black married south66, robust                            

testparm nearc4                         //  F-stat = 32 > 10 (not weak IV)
predict educ_hat                        //  predict X


* Second stage (incorrect s.e.)
reg lwage educ_hat exper expersq black married south66, robust 	
	*beta = .238
	*s.e. = .037


* First-second together (correct s.e.)
ivregress 2sls lwage exper expersq black married south66 (educ = nearc4), robust
	*beta = .238 (same)
	*s.e. = .045 (larger!)
	
* !Takeaway!: use ivregress instead of predict + second stage

* Again, you can export it to Latex/Word table
outreg2 using "results/tab_secondstage.tex", tex(frag) replace 
outreg2 using "results/tab_secondstage.doc", word replace 

* You can append new regression by changing replace to append
	ivregress 2sls lwage (educ = nearc4), robust
	outreg2 using "results/tab_secondstage.doc", word append 

	* Check more optionsa of outreg2 
	
	help outreg2 
		 * keep()
		 * addtext()
		 * label

*-----------------------------------------------------------------------------
* Exercise for you: 
* What if you have two IVs for education? 
*-----------------------------------------------------------------------------	

* First stage: both coefficients are significant
reg educ nearc2 nearc4 exper expersq black married south66, robust 

* F-stats for the first stage = 18 > 10 (noT weak Iv)
testparm nearc2 nearc4 

* Second stage 
ivregress 2sls lwage exper expersq black married south66 (educ = nearc2 nearc4), robust


