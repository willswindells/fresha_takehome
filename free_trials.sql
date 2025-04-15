--Free trial Success

select
add_on_name,
partner_key_country,
partner_busness_type,
sum(is_trial_period) as sum_free_trials,
sum(case when is_trial_period and is_rollover_period_instance = 1 then 1 else 0 end) as sum_successful_trials,
from 
add_on_periods
group by 1,2,3