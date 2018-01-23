/* SAS SNIPPET: DatLynx Datamaker1.sas Fake Data Generator
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
*/

%macro datlynx_makedata(vartype, totobs, item, unit, rangemin, rangemax, div);
option obs=&totobs;
	%if &item= %then %let item=5;
	%let nval=%sysfunc(ceil(&totobs/&item));
	%let prefix=;
	%if %sysfunc(anyalpha(&item))=0 and %index("&item"," ")=0 %then %do;
		%if &item>26 %then %let item=26;
		%let itemc=%substr(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z, 1, %eval(&item+&item-1));
		%let prefix=item_; 
	%end;
	%let len=6;
	%do i=1 %to %sysfunc(countW(&itemc));
		%let len=%sysfunc(max(&len,%length(%scan(&itemc,&i))));
	%end;
	%let len_full=%eval(&len+10);
	%if &vartype="categorical" %then %do;	
		data itemlist;
		length id 5 full_name $&len_full item $&len val 5 unit $10;
		do p=1 to &item;
			do d=1 to countW("&itemc");
				id = ceil(rand("Integer", 1, &totobs)); 
				%if 0<d<27 %then %do;
					dr=scan("&itemc",d);
				%end;	
				%else %do;
					ddd=rand("Integer", 1, 26);
					dr=scan("&itemc",ddd);
				%end;
				ns=int(ranuni(0)*&nval)+1;
				array vallist {%eval(&nval+1)} _temporary_;
				do s=1 to ns;
					tries=0;
					do while (tries<&totobs);
						tries+1;
						i=ceil((&rangemin + floor((1+&rangemax-&rangemin)*rand("uniform")))/&div)*&div;
						if i not in vallist then do;
							vallist[s]=i;
							leave;
						end;
					end;
				end;
				s=1;
				do while (vallist[s]);
					id = ceil(rand("Integer", 1, &totobs)); 	
					item=compress("&prefix" || dr);
					full_name=compbl(item || " " || vallist[s] || " &unit");
					val=vallist[s];
					unit="&unit";
					OUTPUT;
					s+1;
				end;
			end;
		end;	
		keep id full_name item val unit;
	%end;
	%if &vartype="continuous" %then %do;
		data itemlist(keep=id full_name item val unit);
		call streaminit(123);
		length id ddd 5 full_name $&len_full item $&len val 5 unit $10 u x k n m 8;
		a = &rangemin; b = &rangemax;
		Min = 5; Max = 10;		
			do d=1 to &item*4;
				%if 0<d<=&item %then %do;
					dr=scan("&itemc",d);
				%end;	
				%if d>&item %then %do;
					ddd=rand("Integer", 1, &item);
					dr=scan("&itemc",ddd);
				%end;				
				dose=&div*floor(rand("Integer", 1, &rangemax/(2*&div)));				
				ns=int(ranuni(0)*&nval)+1;
				array vallist {%eval(&nval+1)} _temporary_;
				do s=1 to ns;
					tries=0;
					do while (tries<&totobs);
						tries+1;
						i=ceil((int(ranuni(0)*&rangemax)+1)/5)*5;
						if i not in vallist then do;						
							vallist[s]=i;
							leave;
						end;
					end;
				end;
				s=1;
				do while (vallist[s]);
					id = ceil(rand("Integer", 1, &totobs)); 	
					item=compress("&prefix" || dr);
					full_name=compbl(item || " " || dose || " &unit");
					val=vallist[s];
					unit="&unit";
					u = rand("Uniform");            /* decimal values in (0,1)    */
			   		x = a + (b-a)*u;                /* decimal values (a,b)       */
			   		k = ceil( Max*u );              /* integer values in 1..Max   */
			   		n = floor( (1+Max)*u );         /* integer values in 0..Max   */
			   		m = min + floor((1+Max-Min)*u); /* integer values in Min..Max */
			   		val=x;
					OUTPUT;
					s+1;
				end;
			end;				
		run;
	%end;
proc sort data=itemlist; by id 	item val; run;
title "Item LIST";
proc print data=itemlist; run;		
run;	
%mend;

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
