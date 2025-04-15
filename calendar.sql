create or replace table calendar as
(
SELECT 
CAST(RANGE AS DATE) AS date_key,
date_trunc('month', CAST(RANGE AS DATE)) AS start_of_month,
last_day(date_key) AS end_of_month,
datepart('day',last_day(date_key)) as month_days 
FROM 
  RANGE(DATE '2015-01-01', DATE '2027-12-31', INTERVAL 1 DAY) as base
)