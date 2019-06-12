select
    operation,
    status,
    object_type,
    to_char(start_time,'mm/dd/yyyy:hh:mi:ss') as start_time,
    to_char(end_time,'mm/dd/yyyy:hh:mi:ss') as end_time
from
    v$rman_status
where 1=1
and start_time > SYSDATE -1
and operation = 'BACKUP'
and object_type = 'DB FULL'
order by start_time desc;
