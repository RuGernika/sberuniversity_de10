#!/usr/bin/python3

############################################################
#   Home Work 5. Tkachenko D.V
############################################################

import pandas as pd
import psycopg2

conn = psycopg2.connect(database = "edu",
                        host =     "de-edu-db.chronosavant.ru",
                        user =     "de10",
                        password = "bilbobaggins",
                        port =     "5432")


conn.autocommit = False
cursor = conn.cursor()
 

df = pd.read_excel( './medicine.xlsx', sheet_name='hard', header=0, index_col=None)
med_list = df.values.tolist()

cursor.execute( "DROP TABLE de10.tkch_med_results") 
cursor.execute( "CREATE TABLE de10.tkch_med_list (id integer, analiz varchar(45), val  varchar(45))" ) 



for i in range(0, len(med_list)) : 
	q_1 ="INSERT INTO de10.tkch_med_list( id, analiz, val ) VALUES( "+ str(med_list[i][0])+",\'"+ str(med_list[i][1])+"\', \'"+ str(med_list[i][2])+"\')"
	cursor.execute(q_1, conn)


q_1 = ''' 
CREATE OR REPLACE FUNCTION isnumeric(text) RETURNS BOOLEAN AS $$
DECLARE x NUMERIC;
BEGIN
    x = $1::NUMERIC;
    RETURN TRUE;
EXCEPTION WHEN others THEN
    RETURN FALSE;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;
''' 
cursor.execute( q_1) 

	
q_2 = ''' create table de10.tkch_med_results  as ( 
with t_r as (
select ph.name as n, ph.phone as phon, a.name, 
case
when (p.val in ('+', 'Положит.','Положительно')) then 'Положительно'
when ((isnumeric(p.val)) and ((p.val::numeric > a.max_value))) then 'Повышен' 
when ((isnumeric(p.val)) and (p.val::numeric < a.min_value)) then  'Понижен'
end case 
from de10.tkch_med_list p 
left join de.med_name ph on ph.id = p.id
left join de.med_an_name a on a.id = p.analiz
where  ( p.val in ('+', 'Положит.','Положительно') or (isnumeric(p.val)) and ((p.val::numeric > a.max_value) or (p.val::numeric < a.min_value))) 
)
select * from t_r where n = (
select n from t_r
group by n having count(n) >=2)
);
'''

cursor.execute(q_2, conn)

q_3 = ''' select * from  de10.tkch_med_results''' 
cursor.execute( q_3)
records = cursor.fetchall()
for row in records:
	print( row )


# Формирование DataFrame
names = [ x[0] for x in cursor.description ]
df = pd.DataFrame( records, columns = names )

# Запись в файл
df.to_excel( 'rezult_hard.xlsx', sheet_name='Результат', header=True, index=False )


cursor.execute( "DROP TABLE de10.tkch_med_list") 
conn.commit()
cursor.close()
conn.close()

	

