create or replace table instances as (
SELECT
  PROVIDER_ID as provider_id,
  ADD_ON_INSTANCE_ID as add_on_instance_id,
  CREATED_AT as created_at,
  ADD_ON_NAME as addon_name,
  FROM 'instances.csv'
  )