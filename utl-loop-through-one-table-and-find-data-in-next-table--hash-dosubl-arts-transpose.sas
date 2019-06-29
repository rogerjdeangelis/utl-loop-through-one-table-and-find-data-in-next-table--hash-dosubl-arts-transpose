Loop through one table and find data in next table  hash dosubl arts transpose                                               
                                                                                                                             
    Three Solutions                                                                                                          
                                                                                                                             
      1. Art's transpose (fast)  (note the SAS transpose cannot handle the duplicate ids properly)                           
                                                                                                                             
      2, DOSUBL (slow)                                                                                                       
                                                                                                                             
      3. HASH (fastest)                                                                                                      
          Paul Dorfman                                                                                                       
          sashole@bellsouth.net                                                                                              
                                                                                                                             
Great question Thanks!!                                                                                                      
                                                                                                                             
SAS  Forum                                                                                                                   
https://tinyurl.com/y3of9nc3                                                                                                 
https://communities.sas.com/t5/SAS-Programming/Loop-through-one-dataset-and-find-data-in-next-data-set/m-p/569965            
                                                                                                                             
                                                                                                                             
                                                                                                                             
Paul on HASH                                                                                                                 
Procedurally speaking, you need to:                                                                                          
                                                                                                                             
determine the size N of the longest group by ID in data set TWO                                                              
based on it, create a variable list startDate1 endDate1 ... startdateN endDateN, in this order                               
read data set ONE and loop through the records for the matching IDs in data set TWO to populate the variable list            
There many ways to execute this plan. Here's one, based purely on using the DATA step:                                       
                                                                                                                             
                                                                                                                             
                                                                                                                             
data active_customers ;                                                                                                      
  input customer ;                                                                                                           
cards4 ;                                                                                                                     
4                                                                                                                            
3                                                                                                                            
1                                                                                                                            
0                                                                                                                            
2                                                                                                                            
;;;;                                                                                                                         
run ;                                                                                                                        
                                                                                                                             
data campaign_periods ;                                                                                                      
  input customer startDate endDate ;                                                                                         
cards4 ;                                                                                                                     
3 31 32                                                                                                                      
2 21 22                                                                                                                      
3 33 34                                                                                                                      
2 23 24                                                                                                                      
1 11 12                                                                                                                      
3 35 36                                                                                                                      
;;;;                                                                                                                         
run ;                                                                                                                        
                                                                                                                             
                                                                                                                             
WORK.ACTIVE_CUSTOMERS total obs=5                                                                                            
                                                                                                                             
 CUSTOMER                                                                                                                    
                                                                                                                             
     4                                                                                                                       
     3                                                                                                                       
     1                                                                                                                       
     0                                                                                                                       
     2                                                                                                                       
                                                                                                                             
                                                                                                                             
WORK.CAMPAIGN_PERIODS total obs=6                                                                                            
                                                                                                                             
CUSTOMER STARTDATE    ENDDATE                                                                                                
                                                                                                                             
   3        31          32                                                                                                   
   2        21          22                                                                                                   
   3        33          34                                                                                                   
   2        23          24                                                                                                   
   1        11          12                                                                                                   
   3        35          36                                                                                                   
                                                                                                                             
                                                                                                                             
*            _               _                                                                                               
  ___  _   _| |_ _ __  _   _| |_                                                                                             
 / _ \| | | | __| '_ \| | | | __|                                                                                            
| (_) | |_| | |_| |_) | |_| | |_                                                                                             
 \___/ \__,_|\__| .__/ \__,_|\__|                                                                                            
                |_|                                                                                                          
;                                                                                                                            
                                                                                                                             
                                                                                                                             
WORK.WANT total obs=3                                                               | RULES                                  
                                                                                    |                                        
CUSTOMER STARTDATE1    ENDDATE1    STARTDATE2    ENDDATE2    STARTDATE3    ENDDATE3 |                                        
                                                                                    |                                        
   1         11           12            .            .            .            .    | Customer 1 made a purchase             
                                                                                      only in days 11-12                     
   2         21           22           23           24            .            .    |                                        
   3         31           32           33           34           35           36    |                                        
                                                                                                                             
                                                                                                                             
*          _       _   _                                                                                                     
 ___  ___ | |_   _| |_(_) ___  _ __  ___                                                                                     
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|                                                                                    
\__ \ (_) | | |_| | |_| | (_) | | | \__ \                                                                                    
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/                                                                                    
                                                                                                                             
;                                                                                                                            
                                                                                                                             
*_         _         _                                                                                                       
/ |       / \   _ __| |_ ___                                                                                                 
| |      / _ \ | '__| __/ __|                                                                                                
| |_    / ___ \| |  | |_\__ \                                                                                                
|_(_)  /_/   \_\_|   \__|___/                                                                                                
                                                                                                                             
;                                                                                                                            
                                                                                                                             
* don't think it is a good idea to program like this. I am curious and like to experiment;                                   
                                                                                                                             
%symdel rc / nowarn;                                                                                                         
proc sql;                                                                                                                    
                                                                                                                             
  create                                                                                                                     
     table want as                                                                                                           
  select                                                                                                                     
     r.*                                                                                                                     
  from                                                                                                                       
     active_customers as l, cmpXpo( where= ( 0 = %let rc=%sysfunc(dosubl('                                                   
                                                                                                                             
             %utl_trans(data=campaign_periods, out=cmpXpo, by=customer, var=startDate endDate,sort=YES);                     
                                                                                                                             
            ')); &rc )) as r                                                                                                 
  where                                                                                                                      
    l.customer = r.customer                                                                                                  
                                                                                                                             
;quit;                                                                                                                       
                                                                                                                             
*____           _                 _     _                                                                                    
|___ \       __| | ___  ___ _   _| |__ | |                                                                                   
  __) |     / _` |/ _ \/ __| | | | '_ \| |                                                                                   
 / __/ _   | (_| | (_) \__ \ |_| | |_) | |                                                                                   
|_____(_)   \__,_|\___/|___/\__,_|_.__/|_|                                                                                   
                                                                                                                             
;                                                                                                                            
                                                                                                                             
proc datasets ;                                                                                                              
  delete want want1;                                                                                                         
run;quit;                                                                                                                    
                                                                                                                             
%symdel id apn customer / nowarn;                                                                                            
                                                                                                                             
data _null_;                                                                                                                 
                                                                                                                             
  * for appending;                                                                                                           
  if _n_=0 then do; %let rc=%sysfunc(dosubl('data want;')); end;                                                             
                                                                                                                             
                                                                                                                             
  set active_customers;                                                                                                      
                                                                                                                             
  call symputx('customer',customer);                                                                                         
                                                                                                                             
  rc=dosubl('                                                                                                                
                                                                                                                             
      %let apn=%str(customer=.;); * do not append if -1;                                                                     
                                                                                                                             
      * gen code;                                                                                                            
      data _null_;                                                                                                           
                                                                                                                             
        length apn $200;                                                                                                     
        retain apn ;                                                                                                         
                                                                                                                             
        set CAMPAIGN_PERIODS(where=(customer=&customer)) end=dne;                                                            
                                                                                                                             
        start=cats("startdate",_n_,"=",startdate,";");                                                                       
        end=cats("enddate",_n_,"=",enddate,";");                                                                             
                                                                                                                             
        apn=catx(" ",apn,start,end);                                                                                         
                                                                                                                             
        if dne then call symputx("apn",apn);                                                                                 
                                                                                                                             
      run;quit;                                                                                                              
                                                                                                                             
      data want1;                                                                                                            
        customer=&customer;                                                                                                  
        %str(&apn);                                                                                                          
      run;quit;                                                                                                              
                                                                                                                             
      * append;                                                                                                              
      data want(where=(customer ne .));                                                                                      
        set want want1;                                                                                                      
      run;quit;                                                                                                              
                                                                                                                             
      ');                                                                                                                    
                                                                                                                             
                                                                                                                             
run;quit;                                                                                                                    
                                                                                                                             
*_____    _               _                                                                                                  
|___ /   | |__   __ _ ___| |__                                                                                               
  |_ \   | '_ \ / _` / __| '_ \                                                                                              
 ___) |  | | | | (_| \__ \ | | |                                                                                             
|____(_) |_| |_|\__,_|___/_| |_|                                                                                             
                                                                                                                             
;                                                                                                                            
                                                                                                                             
data one ;                                                                                                                   
  input id ;                                                                                                                 
  cards ;                                                                                                                    
4                                                                                                                            
3                                                                                                                            
1                                                                                                                            
0                                                                                                                            
2                                                                                                                            
run ;                                                                                                                        
data two ;                                                                                                                   
  input id startDate endDate ;                                                                                               
  cards ;                                                                                                                    
3 31 32                                                                                                                      
2 21 22                                                                                                                      
3 33 34                                                                                                                      
2 23 24                                                                                                                      
1 11 12                                                                                                                      
3 35 36                                                                                                                      
run ;                                                                                                                        
                                                                                                                             
data _null_ ;                                                                                                                
  dcl hash h () ;                                                                                                            
  h.definekey ("id") ;                                                                                                       
  h.definedata ("q") ;                                                                                                       
  h.definedone () ;                                                                                                          
  dcl hiter hi ("h") ;                                                                                                       
  do until (z) ;                                                                                                             
    set two end = z ;                                                                                                        
    if h.find() ne 0 then q = 1 ;                                                                                            
    else                  q + 1 ;                                                                                            
    h.replace() ;                                                                                                            
  end ;                                                                                                                      
  do while (hi.next() = 0) ;                                                                                                 
    qmax = qmax max q ;                                                                                                      
  end ;                                                                                                                      
  length s $ 32767 ;                                                                                                         
  do q = 1 to qmax ;                                                                                                         
    s = catx (" ", s, cats ("startDate", q), cats ("endDate", q)) ;                                                          
  end ;                                                                                                                      
  call symputx ("s", s) ;                                                                                                    
run ;                                                                                                                        
                                                                                                                             
data want (drop = startDate endDate q) ;                                                                                     
  if _n_ = 1 then do ;                                                                                                       
    if 0 then set two ;                                                                                                      
    dcl hash h (dataset:"two", multidata:"y") ;                                                                              
    h.definekey ("id") ;                                                                                                     
    h.definedata ("startDate", "endDate") ;                                                                                  
    h.definedone () ;                                                                                                        
  end ;                                                                                                                      
  set one ;                                                                                                                  
  array dd [*] &s ;                                                                                                          
  do q = 0 by 2 while (h.do_over() = 0) ;                                                                                    
    dd [q + 1] = startDate ;                                                                                                 
    dd [q + 2] = endDate ;                                                                                                   
  end ;                                                                                                                      
  if q ;                                                                                                                     
run ;                                                                                                                        
                                                                                                                             
                                                                                                                             
