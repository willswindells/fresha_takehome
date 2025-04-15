--churn reactivation
--
with add_on_periods_current_date as (
select provider_id,
  add_on_name,
  active_from,
  active_to,
  is_rollover_period_instance,
  period_payment_status,
  case 
    when active_to < current_date() then 1 else 0 end as is_ended_period
  from add_on_periods
),

  --each partners first churn
first_churn_partners as 
  (
select
provider_id,
  add_on_name,
min(active_from) as first_churn_at,
from 
add_on_periods_current_date
where is_ended_period = 1
  and is_rollover_period_instance = 0
and period_payment_status = 'paid'
group by 1
  ,2
)

  --basic reactivation - dupe lines if happens more than once
  --provider by add on name is a strange metric
select 
  base.add_on_name,
  count(distinct base.provider_id) as total_providers,
  count(distinct first_churn.provider_id) as total_ever_churn_providers,
  count(distinct churn_reactivation.provider_id) as total_ever_reactivated_providers,
from 
    add_on_periods_current_date base
  
left join first_churn_partners as first_churn 
    on base.provider_id = first_churn.provider_id
  and base.add_on_name = first_churn.add_on_name
  
left join add_on_periods_current_date as churn_reactivation 
    on base.provider_id = churn_reactivation.provider_id
  and base.add_on_name = churn_reactivation.add_on_name
  and churn_reactivation.active_from > first_churn.first_churn_at
  and churn_reactivation.period_payment_status = 'paid'
where 
  base.period_payment_status = 'paid'
group by 1
