/* Formatted on 5/30/2019 11:34:30 AM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW SYS.GV_LOCK_DET
(
   SESS,
   "USER",
   STATUS,
   INST_ID,
   SID,
   SERIAL#,
   EVENT,
   MINUTES_IN_WAIT,
   KILL_OS,
   KILL_SID,
   START_TRACE,
   STOP_TRACE,
   OSUSER,
   MACHINE,
   LAST_CALL_ET,
   SQL_ID
)
   BEQUEATH DEFINER
AS
   SELECT l.sess,
             s.inst_id
          || '_'
          || TRIM (
                   NVL (s.CLIENT_INFO, s.USERNAME)
                || '_'
                || s.ACTION
                || '_'
                || s.MODULE
                || '_'
                || s.USERNAME)
             "USER",
          --o.object_name,
          s.status,
          s.inst_id,
          s.sid,
          s.serial#,
          w.event,
          ROUND (w.seconds_in_wait / 60, 2) minutes_in_wait,
          CASE
             WHEN l.block > 0 AND w.event NOT IN ('enqueue')
             THEN
                'kill -9 ' || p.spid
             ELSE
                NULL
          END
             kill_os,
          CASE
             WHEN l.block > 0 AND w.event NOT IN ('enqueue')
             THEN
                   'ALTER SYSTEM KILL SESSION '''
                || s.sid
                || ','
                || s.serial#
                || ',@'
                || s.inst_id
                || '''immediate;'
             ELSE
                NULL
          END
             kill_sid,
             'begin sys.dbms_system.set_sql_trace_in_session('
          || s.sid
          || ','
          || s.serial#
          || ',TRUE); end;'
             start_trace,
             'begin sys.dbms_system.set_sql_trace_in_session('
          || s.sid
          || ','
          || s.serial#
          || ',FALSE); end;'
             stop_trace,
          s.osuser,
          s.machine,
          s.last_call_et,
          S.SQL_ID
     FROM (  SELECT DECODE (l.request, 0, 'Holder: ', '      Waiter: ') sess,
                    l.*
               FROM GV$LOCK l
              WHERE (l.id1, l.id2, l.TYPE) IN (SELECT id1, id2, TYPE
                                                 FROM gV$LOCK
                                                WHERE request > 0)
           ORDER BY l.id1, l.request) l
          JOIN gv$session s ON l.sid = s.sid AND s.inst_id = l.inst_id
          --  left outer join dba_objects o on o.object_id=l.id1
          LEFT OUTER JOIN gv$session_wait w
             ON w.sid = s.sid AND w.INST_ID = s.INST_ID
          LEFT OUTER JOIN gv$process p
             ON p.addr = s.paddr AND p.inst_id = s.inst_id;
