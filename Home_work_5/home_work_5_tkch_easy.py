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
 

df = pd.read_excel( './medicine.xlsx', sheet_name='easy', header=0, index_col=None)
med_list = df.values.tolist()

df_phone = pd.DataFrame() 
#df_phone = pd.DataFrame(columns=['id', 'name', 'phone', 'name','case']) 

for i in range(0, len(med_list)) :  

	q_2 = " WITH phone_number AS (SELECT \'" + str(med_list[i][0]) + "\' as id, ph.name as name, ph.phone as phone,  \'" + str(med_list[i][1]) + "\' as analis_name ,   \'" + str(med_list[i][2]) + "\' as value FROM  de.med_name ph  where ph.id ="  + str(med_list[i][0])  +")  SELECT phone_number.name as Name_pation, phone_number.phone as Phone , v.name as Analise , (CASE  WHEN  " + str(med_list[i][2]) +  " > v.max_value  THEN  \'Повышен\'   WHEN   " + str(med_list[i][2])  + " < v.min_value THEN \'Понижен\'  END) as Result   FROM de.med_an_name v, phone_number  WHERE \'" + str(med_list[i][1]) + "\' = v.id  AND (CASE  WHEN  " + str(med_list[i][2]) +  " > v.max_value  THEN  \'Повышен\'   WHEN   " + str(med_list[i][2])  + " < v.min_value THEN \'Понижен\'  END) IS NOT NULL "
	df = pd.read_sql(q_2, conn)
	df_phone = df_phone.append( df, ignore_index = True )
	

df_phone.to_excel( 'rezult.xlsx', sheet_name='Результаты', header=True, index=True )

cursor.close()
conn.close()

	
	
