-- Создание cte, где генирируются все даты в исследуемом периоде
with date_table as (
	select 
	generate_series('2022-01-01'::date, '2022-01-01'::date + interval '150' day, '1 day') date_from_calendar
	),
-- Создание cte, где выводится количество уникальных пользователей, заходивших на платформу по каждому дню
daily_active_users as (
	select 
		dt.date_from_calendar,
		count(distinct u.user_id) daily_active_users_cnt
	from date_table dt
	left join userentry u 
		on  dt.date_from_calendar::date = u.entry_at::date
	group by dt.date_from_calendar
	)
-- Расчет искомых показателей
select 
	date_from_calendar, -- дата
	daily_active_users_cnt, -- количество уникальных пользователей за день (DAU)
	max(daily_active_users_cnt) over (order by date_from_calendar) max_dau_cnt, -- максимальное (DAU) за все время (с учетом актуального значения на текущую строку) 
	daily_active_users_cnt - max(daily_active_users_cnt) over (order by date_from_calendar) diff_dau -- разница между текущим DAU и максимальным значением DAU за все время
from daily_active_users
order by date_from_calendar
