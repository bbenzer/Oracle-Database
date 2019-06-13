set linesize 1000
SELECT G.NAME,
       sum(b.total_mb)                                     total_mb,
       sum((b.total_mb - b.free_mb))                        used_mb,
       sum(B.FREE_MB)   free_mb,
       decode(sum(b.total_mb),0,0,(ROUND((1- (sum(b.free_mb) / sum(b.total_mb)))*100, 2)))      pct_used,
       decode(sum(b.total_mb),0,0,(ROUND(((sum(b.free_mb) / sum(b.total_mb)))*100, 2)))      pct_free
FROM
     v$asm_disk b,v$asm_diskgroup g
where b.group_number = g.group_number (+)
group by g.name;
