--churn
--
with add_on_periods_current_date as (
select *,
  case 
    when active_to < current_date() then 1 else 0 end as is_ended_period
  from add_on_periods
)
  
select
  revenue_month,
  add_on_name,
  count(*) as total_periods,
sum(case when is_rollover_period_instance = 0 then 1 else 0 end) as churn_periods,
sum(is_rollover_period_instance) as non_churn_periods, 

count(distinct add_on_period_pk) as total_add_on_periods,

--Should be the same as above - add test to confirm in dbt
count(distinct case when is_rollover_period_instance = 0 then add_on_period_pk else null end) as churn_add_on_periods,
count(distinct add_on_period_pk) -  
  count(distinct case when is_rollover_period_instance = 0 then add_on_period_pk else null end) as non_churn_add_on_periods,

from 
add_on_periods_current_date
where is_ended_period = 1
group by 1,2
