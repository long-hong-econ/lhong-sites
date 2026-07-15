*-----------------------------------------------------------------------------
* Clean raw data
*-----------------------------------------------------------------------------

cd "/Users/long/Dropbox/Teaching/Sections/Section2"

infile coll merit male black asian year state treat using "data/regm.raw", clear 

label var coll  "dummy = 1 if college attendance (for each individual)"
label var merit "dummy = 1 if a merit aid program in that year (for each state)"

gen state_year = state*10000 + year  // state x year indicator

order coll state year merit 
drop treat 
save "data/data_eventstudy", replace

