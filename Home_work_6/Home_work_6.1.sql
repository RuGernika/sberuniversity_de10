
create table  de10.tkch_salary_hist as (
select
	person,
	class,
	salary,
	dt as startd_dt,
	( coalesce( lead(dt) over (partition by person order by dt) - interval '1 day',
	to_date('9999-12-31','YYYY-MM-DD'))) :: date as end_dt,
from de.histgroup t );


create table  de10.tkch_salary_log as (    
with scd2_t as (
  select 
	 s.person as person,
	 s.salary as salary, 
	 s.startd_dt as startd_dt, 
	 coalesce (lead (s.startd_dt) over (partition by person order by s.startd_dt) - interval '1' day,
                date'9999-12-31') as end_dt 
  from de10.tkch_salary_hist s)
select
  fact_t.dt,
  fact_t.person,
  fact_t.payment, 
   sum(fact_t.payment) over(partition by fact_t.person, date_trunc('month',fact_t.dt) order by fact_t.person,  fact_t.dt ) as  month_paid, 
   salary - sum(fact_t.payment) over(partition by fact_t.person, date_trunc('month',fact_t.dt) order by fact_t.person,  fact_t.dt) as month_rest    
from de.salary_payments  fact_t
join   scd2_t on  fact_t.person =  scd2_t.person and  fact_t.dt between  scd2_t.startd_dt and scd2_t.end_dt) ; 
    
    

