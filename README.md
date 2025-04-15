# Will Swindells


## Overview
DuckDb used as project Database so it is selfcontained and not limited to the cloud

curl https://install.duckdb.org | sh
Or
https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=linux&download_method=direct&architecture=x86_64


Open the Db
duckdb fresha.duckdb

Start the UI locally on http://localhost:4213/
CALL start_ui();

The question mentioned that just SQL was enough, so decided against full dbt build.

.sql files saved in the repo - plus presentation tool of [gsheet](https://docs.google.com/spreadsheets/d/1PYuhoje-3BIHPolrnVY_BDtfDgBfFS0vK_XeCOwJxrg/edit?usp=sharing)



## Data Exploring

Periods are not full months and can run over or under
Timestamps are not timezone linked (not ideal) - i will ignore for this excercise.


### instances
Pk ADD_ON_INSTANCE_ID  

### partners
Pk PROVIDER_ID  

### periods
Pk ADD_ON_PERIOD_PK 
Seconds of Active to and from are strange, I will assume its cost per day or part thereof - no cutoff logic - exact in definition
Data Quality needs improving - period end times seconds into new day count as a full day, unsure how pricing is done, another chat for another time 
Free periods inside paid periods make runlenghs and daily costs error if not done carefully
Can have created timestamps after the active datetime - missed active hours or incorrect backend processing / locks? provider_id = 311730 for example
Fine if active was always backdated to 00:00 no idea how the system works but its slightly messy data

## Model add_on_periods

Accrual Accounting - The model attributes the revenue when it is earned not when it is recieved. 

Period Cohort Analysis - The model groups by Date revenue is recieved - An easier calculation

Reading the full doc:
> due to accounting principles we should spread revenues evenly over the duration of the subscription periods

Indicates you require Accrual Accounting for this model. Splitting the few (326 or 25 non 0 rev) periods that run accross multiple periods. 

### Add on periods

PK moved to month and add on period
active_days_of_month
period_length_days dim added

As cash is in the original model i am going to assume there is no conflict in keeping that data in the Add on model. 
Adding derived columns to this model and will only remove and agg for later model.


