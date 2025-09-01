# SQL_Task1

## Расчет динамики метрики активности пользователей на платформе (Daily Active Users)
Задача решалась в рамках курса от Simulative

Ссылка на описание базы данных: [Simulative](https://docs.google.com/document/d/1qKDKq_d8Mhud5p3mADxWWxlIrPx-EfHzvuE0j02dKtA/edit?tab=t.0#heading=h.2jjs7kn5dns)

DAU - количество уникальных пользователей, которые взаимодействуют с платформой в течение одного дня, рассчитывается путем подсчета уникальных идентификаторов пользователей за определенный день. \
Анализ DAU позволяет выявить тренды пользовательской активности, определить пики и спады, а также лучше понять поведение аудитории. \
В дальнейшем эта метрика может быть использована для принятия более обоснованных решений по улучшению пользовательского опыта, увеличению вовлеченности и оптимизации маркетинговых стратегий.

### Задание

Необходимо взять период с 2022-01-01 и последующие 150 дней и рассчитать следующие показатели:
- date_from_calendar: дата, округленная до дня (без времени)
- daily_active_users_cnt: количество уникальных активных пользователей за день (DAU)
- max_dau_cnt: максимальный DAU за все время
- diff_dau: разница между текущим DAU и максимальным значением DAU за все время

### Примечания
- Заходы пользователя на платформу находятся в таблице userentry 
- Обязательно нужно учесть дни без захода на платформу
- Если в определенный день заходов на платформу не было, то есть нет и DAU, то выводится 0

### Решение
```postgresql
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
```
### Результат
<img width="701" height="611" alt="image" src="https://github.com/user-attachments/assets/13e8e08b-50a4-43ff-a699-585b231e6fba" />
