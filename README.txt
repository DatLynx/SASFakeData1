README

SAS SNIPPET: DatLynx Fake Data Generator
Created by: Jeremy Smith, Andrew Toler
Date: 20 JAN 2017
Copyright: None, but please copy this header as attribution 
	if you use/alter/copy/and/or include any of this code in your work.
Purpose: To dynamically generate fake data for testing code. 
	It can create categorical or continuous normally distributed data.
Parameters: 
	id= fake id, with some repeats
	vartype= specify "continuous" or "categorical"
	totobs= specify the cap on number of obs created (don't go too high or SAS will chew and chew)
	item= number of letters to use (maxes out at 26)
	unit= the unit label for the values, i.e. mg, kg, lbs, etc.
	rangemin= the minimum value
	rangemax=the maximum value
	div= the interval that the final numbers will increment by 
	
Sample calls:

%datlynx_makedata(
vartype="categorical"
,totobs=500
,item=5
,unit=mg
,rangemin=0
,rangemax=200
,div=5
)

%datlynx_makedata(
vartype="continuous"
,totobs=500
,item=26
,unit=mg
,rangemin=0
,rangemax=200
,div=5
)	

To use it, comment out the calls, and then use %include datamaker1.sas or copy the code to your program.