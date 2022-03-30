
select user_id, current_timestamp as updated_at from {{ ref('my_large_table' )}}
