/*     Home Work 7.    Tkachenko Daria (tkch)
       Incremental Load / Insert / Update / Delete for SCD2 
      ----------------------------------------------------------------- 
       Style  ISO 11179, ISO 8601,  ISO/IEC 9075 , Joe Celko’s SQL Programming Style       */


CREATE TABLE de10.tkch_source_scd2 ( 
    id          INT PRIMARY KEY,
    val         VARCHAR(50),
    update_dt   TIMESTAMP(0)
); 


CREATE TABLE de10.tkch_stg_scd2 ( 
    id          INT,
    val         VARCHAR(50),
    update_dt   TIMESTAMP(0)
);


CREATE TABLE de10.tkch_stg_del_scd2 ( 
    id    INT
);


CREATE TABLE de10.tkch_target_scd2(
    id                  INT,
    val                 VARCHAR(50),
    effective_from      TIMESTAMP(0),
    effective_to        TIMESTAMP(0),
    delete_flg          CHAR(1)
);


CREATE TABLE de10.tkch_meta_scd2 (
    schema_name      VARCHAR(50),
    table_name       VARCHAR(50),
    max_update_dt    TIMESTAMP(0)
);


-- Add meta data  
-- ---------------------------------------------------------

INSERT INTO  de10.tkch_meta_scd2  ( schema_name, table_name, max_update_dt )
VALUES ( 'de10','tkch_source_scd2', to_timestamp ( '1900-01-01', 'YYYY-MM-DD' ));
  


-- 1. Add data to sorce
-- ---------------------------------------------------------


INSERT INTO de10.tkch_source_scd2 ( id, val, update_dt ) VALUES ( 1, 'A', now() );
INSERT INTO de10.tkch_source_scd2 ( id, val, update_dt ) VALUES ( 2, 'B', now() );
INSERT INTO de10.tkch_source_scd2 ( id, val, update_dt ) VALUES ( 3, 'C', now() );
INSERT INTO de10.tkch_source_scd2 ( id, val, update_dt ) VALUES ( 4, 'D', now() );
INSERT INTO de10.tkch_source_scd2 ( id, val, update_dt ) VALUES ( 5, 'E', now() );
INSERT INTO de10.tkch_source_scd2 ( id, val, update_dt ) VALUES ( 6, 'F', now() );
INSERT INTO de10.tkch_source_scd2 ( id, val, update_dt ) VALUES ( 7, 'G', now() );

UPDATE de10.tkch_source_scd2 SET val = 'New A', update_dt = now() WHERE id = 1;
UPDATE de10.tkch_source_scd2 SET val = 'New B', update_dt = now() WHERE id = 2;
UPDATE de10.tkch_source_scd2 SET val = 'New C', update_dt = now() WHERE id = 3;

DELETE FROM de10.tkch_source_scd2 WHERE id = 4;
DELETE FROM de10.tkch_source_scd2 WHERE id = 5;
DELETE FROM de10.tkch_source_scd2 WHERE id = 6;



-- ---------------------------------------------------------
-- Incremental load to staging table 
-- ---------------------------------------------------------

DELETE FROM de10.tkch_stg_scd2;
DELETE FROM de10.tkch_stg_del_scd2;


-- 2. Capturing data from the source (changed since the last upload) in staging

INSERT INTO  de10.tkch_stg_scd2( 
    id, 
    val, 
    update_dt)
SELECT  
    id, 
    val, 
    update_dt 
FROM  de10.tkch_source_scd2
WHERE update_dt > ( 
    SELECT max_update_dt 
    FROM de10.tkch_meta_scd2 
    WHERE schema_name='de10' AND table_name='tkch_source_scd2');



-- 3. Capturing keys from the source in staging with a full slice to calculate deletions.

INSERT INTO  de10.tkch_stg_del_scd2 (id)
SELECT id FROM de10.tkch_source_scd2 ;


-- 4. Loading inserts on the source to the receiver (SCD2 format).

INSERT INTO  de10.tkch_target_scd2 ( 
    id, 
    val, 
    effective_from, 
    effective_to, 
    delete_flg) 
SELECT 
    stg.id, 
    stg.val, 
    stg.update_dt  as effective_from,
    (coalesce(lead(update_dt) over (partition by stg.id order by stg.update_dt) - interval '1 day',
    to_date('9999-12-31','YYYY-MM-DD'))) :: date  as end_dt, 
    'N'
FROM de10.tkch_stg_scd2 stg;


-- 5 Update in the receiver of updates on the source (SCD2 format).

UPDATE de10.tkch_target_scd2 
SET
   effective_from = tmp.effective_from,
   effective_to = tmp.effective_to
FROM (
SELECT 
   tgt.id AS id,
   tgt.val,
   tgt.effective_from AS effective_from,
   (stg.update_dt - interval '1 sec' ) AS effective_to
FROM de10.tkch_target_scd2 tgt
LEFT JOIN  de10.tkch_stg_scd2 stg ON stg.id = tgt.id 
WHERE tgt.effective_to  = '9999-12-31' AND stg.id = tgt.id  AND tgt.val <> stg.val 
) tmp
WHERE de10.tkch_target_scd2.id = tmp.id   AND  de10.tkch_target_scd2.val = tmp.val ;


-- 6 Deleting records deleted in the source in the receiver (SCD2 format).

INSERT INTO  de10.tkch_target_scd2 ( 
    id, 
    val, 
    effective_from, 
    effective_to, 
    delete_flg) 
SELECT 
    tgt.id, 
    tgt.val, 
    now(),
    to_date('9999-12-31','YYYY-MM-DD'),
    'Y' 
FROM de10.tkch_target_scd2  tgt
LEFT JOIN  de10.tkch_stg_del_scd2 stg ON stg.id = tgt.id
WHERE stg.id is null AND tgt.effective_to ='9999-12-31';


UPDATE de10.tkch_target_scd2 
SET
 effective_to = tmp.effective_to
FROM (
SELECT 
    tgt.id,
    (now() - interval  '1 day') AS effective_to
    FROM de10.tkch_target_scd2 tgt
    LEFT JOIN de10.tkch_stg_del_scd2 stg ON stg.id = tgt.id
    WHERE stg.id is null AND  tgt.effective_to =  '9999-12-31' AND tgt.delete_flg = 'N'
) tmp 
WHERE de10.tkch_target_scd2.id = tmp.id AND de10.tkch_target_scd2.effective_to =  '9999-12-31'
AND  de10.tkch_target_scd2.delete_flg = 'N' ;
  

-- 7. Updating metadata.

UPDATE de10.tkch_meta_scd2
   SET max_update_dt = COALESCE((SELECT MAX(update_dt) FROM de10.tkch_stg_scd2 ), 
                      (SELECT max_update_dt FROM de10.tkch_meta_scd2 
                       WHERE schema_name='de10' AND table_name = 'tkch_source_scd2'))
 WHERE schema_name='de10' AND table_name = 'tkch_source_scd2';

-- 8. Commit

COMMIT; 

-- 9.Test Data 

select * from de10.tkch_source_scd2;
select * from de10.tkch_stg_scd2;
select * from de10.tkch_target_scd2;
select * from de10.tkch_meta_scd2;
select * from de10.tkch_stg_del_scd2; 






