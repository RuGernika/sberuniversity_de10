/* =================================================================================================  */
/*                    DARIA TKACHENKO //  HOMEWORK 3                                                  */
/* =================================================================================================  */
 
-- CREATE TABLE DE10.TKCH_LOG

CREATE TABLE DE10.TKCH_LOG AS (
with data_log_parsed as (select string_to_array("1", '	') parsed_log from de.log as t("1"))
 select left 
        (parsed_log[4],8)::date  DT,
        (parsed_log[5])::varchar(50) LINK,
        (parsed_log[8])::varchar(200) USER_AGENT,
        (parsed_ip[2])::varchar(30) REGION       
from data_log_parsed
left join (select string_to_array(ip_region.data, '	') parsed_ip from de.ip as ip_region) as ip_region on 
(substring(ip_region.parsed_ip[1] from  '^\d+.\d+.\d+.\d+'))=(substring(data_log_parsed.parsed_log[1] from '^\d+.\d+.\d+.\d+'))
);

/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


                                   Таблица "de10.tkch_log"
  Столбец   |          Тип           | Правило сортировки | Допустимость NULL | По умолчанию 
------------+------------------------+--------------------+-------------------+--------------
 dt         | date                   |                    |                   | 
 link       | character varying(50)  |                    |                   | 
 user_agent | character varying(200) |                    |                   | 
 region     | character varying(30)  |                    |                   | 



     dt     |              link              |                                                           user_agent                                                            |      region      
------------+--------------------------------+---------------------------------------------------------------------------------------------------------------------------------+------------------
 2014-01-07 | http://news.rambler.ru/6389411 | Safari/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; chromeframe/12.0.742.112)n                                | Adygea
 2014-03-13 | http://news.rambler.ru/2351538 | Firefox/5.0 (compatible; MSIE 9.0; Windows NT 8.0; WOW64; Trident/5.0; .NET CLR 2.7.40781; .NET4.0E; en-SG)n                    | Chuvash
 2014-03-03 | http://lenta.ru/9509967        | Safari/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0)n                                                     | Chuvash
 2014-04-07 | http://lenta.ru/7209568        | Safari/5.0 (Windows; U; MSIE 9.0; Windows NT 8.1; Trident/5.0; .NET4.0E; en-AU)n                                                | Komi
 2014-04-23 | http://lenta.ru/5240875        | Opera/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0; .NET CLR 2.0.50727; SLCC2; .NET CLR 3.5.30729)n       | Komi
 2014-01-10 | http://news.yandex.ru/2635045  | Opera/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; .NET CLR 3.5.30729; .NET CLR 3.0.30729; n                  | Komi
 2014-03-29 | http://news.rambler.ru/1991645 | Safari/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0; .NET CLR 2.0.50727; SLCC2; .NET CLR 3.5.30729)n      | Buryatia
 2014-01-15 | http://news.rambler.ru/6339472 | Opera/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; chromeframe/12.0.742.112)n                                 | Dagestan
 2014-03-08 | http://news.mail.ru/7520891    | Opera/5.0 compatible; MSIE 9.0; Windows NT 7.0; Trident/5.0; .NET CLR 2.2.50767;)n                                              | Moscow Oblast
 2014-03-18 | http://news.yandex.ru/6512525  | Firefox/5.0 (Windows; U; MSIE 9.0; Windows NT 6.0; Win64; x64; Trident/5.0; .NET CLR 3.8.50799; Media Center PC 6.0; .NET4.0E)n | Ulyanovsk Oblast



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- CREATE TABLE DE10.TKCH_LOG_REPORT




CREATE TABLE DE10.TKCH_LOG_REPORT AS ( 
with browser_t as (             
select  REGION, substring(user_agent from 0 for position('/' in user_agent))::varchar(10) BROWSER  from DE10.TKCH_LOG
)  
   select  region, browser  
   from browser_t r  group by browser,region  having count(browser) = (
   select  count(browser) from browser_t where region = r.region
   group by browser, region order by count(browser) desc fetch first 1 rows only
 ));


/*--------------------------------------------------------------------------------------------------------------------------------------------------------   
Отчет.
DE10.XXXX_LOG_REPORT ( REGION VARCHAR( 30 ), BROWSER VARCHAR( 10 ) ) – в каких
областях какой браузер является наиболее используемым.




                             Таблица "de10.tkch_log_report"
 Столбец |          Тип          | Правило сортировки | Допустимость NULL | По умолчанию 
---------+-----------------------+--------------------+-------------------+--------------
 region  | character varying(30) |                    |                   | 
 browser | character varying(10) |                    |                   | 

         region          | browser 
-------------------------+---------
 Karachay–Cherkessia     | Firefox
 Tambov Oblast           | Opera
 Perm Krai               | Opera
 North Ossetia–Alania    | Firefox
 Kabardino-Balkaria      | Safari
 Primorsky Krai          | Safari
 Buryatia                | Chrome
 Karelia                 | Opera
 Leningrad Oblast        | Firefox
 Magadan Oblast          | Chrome
 Kirov Oblast            | Firefox
 Oryol Oblast            | Firefox
 Ivanovo Oblast          | Firefox
 Sakha                   | Chrome
 Kamchatka Krai          | Firefox
 Tatarstan               | Firefox
 Penza Oblast            | Opera
 Khabarovsk Krai         | Chrome

(92 строки)

*/

 
	

