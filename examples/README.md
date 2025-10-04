# Примеры использования системы

## 1. Начальная настройка базы данных
```sql
-- Создание таблиц
\i database/tables/create_tables.sql

-- Добавление тестовых данных
\i examples/sample_data.sql

-- Создание триггеров
\i database/triggers/triggers.sql

-- Создание представлений
\i database/views/views.sql
```

## 2. Тестирование основных сценариев

### Примеры рабочих сценариев

#### Для студентов

- Поиск активных вакансий
```sql
-- Поиск вакансий в IT отрасли с удаленной работой
SELECT title, company_name, employment_type 
FROM Vacancy v
JOIN Employer e ON v.employer_id = e.employer_id
WHERE e.industry = 'IT' 
AND v.employment_type = 'REMOTE'
AND v.status = 'ACTIVE'
AND v.expires_at > GETDATE();
```
- Подача отклика на вакансию
```sql
-- Студент с ID 1 откликается на вакансию с ID 5
INSERT INTO Application (student_id, vacancy_id, status)
VALUES (1, 5, 'IN_PROGRESS');
```
- Просмотр своих откликов
```sql
-- Все отклики студента с ID 1
SELECT v.title, e.company_name, a.applied_at, a.status
FROM Application a
JOIN Vacancy v ON a.vacancy_id = v.vacancy_id
JOIN Employer e ON v.employer_id = e.employer_id
WHERE a.student_id = 1
ORDER BY a.applied_at DESC;
```

#### Для работодателей

- Публикация новой вакансии
```sql
-- Компания с ID 1 публикует вакансию
INSERT INTO Vacancy (employer_id, title, description, address, 
                    employment_type, expires_at, status)
VALUES (1, 'Junior Data Analyst', 'Описание вакансии...', 'Москва',
        'FULL_TIME', DATEADD(month, 1, GETDATE()), 'ACTIVE');
```
- Просмотр откликов на свои вакансии
```sql
-- Все отклики на вакансии компании с ID 1
SELECT s.name, s.faculty, v.title, a.applied_at, a.status
FROM Application a
JOIN Student s ON a.student_id = s.student_id
JOIN Vacancy v ON a.vacancy_id = v.vacancy_id
WHERE v.employer_id = 1
ORDER BY a.applied_at DESC;
```
- Назначение собеседования
```sql
-- Назначение собеседования для заявки с ID 10
INSERT INTO Interview (application_id, scheduled_at, interview_type)
VALUES (10, DATEADD(day, 3, GETDATE()), 'TECHNICAL');
```

#### Для администраторов центра карьеры

- Анализ активности университета
```sql
-- Использование готового представления
SELECT * FROM v_student_activity_report
WHERE university = 'HSE'
ORDER BY total_applications DESC;
```
- Мониторинг заполняемости мероприятий
```sql
-- Мероприятия с низкой заполняемостью (< 30%)
SELECT * FROM v_event_attendance
WHERE fill_percentage < 30
AND start_at > GETDATE();
```

## Тестовые сценарии
### Сценарий 1: Полный цикл трудоустройства
1. Студент регистрируется в системе
2. Ищет подходящие вакансии
3. Откликается на вакансию
4. Проходит собеседование
5. Получает оффер

### Сценарий 2: Организация карьерного мероприятия
1. Создание мероприятия
2. Регистрация студентов
3. Проведение мероприятия
4. Сбор обратной связи
5. Анализ эффективности

### Сценарий 3: Наставническая программа
1. Назначение наставника студенту
2. Регулярные встречи и консультации
3. Завершение программы с фидбеком
4. Анализ результатов

## Примеры аналитических запросов

### Анализ конверсии по факультетам
```sql
-- Конверсия откликов в офферы по факультетам
SELECT 
    faculty,
    COUNT(*) as total_students,
    SUM(CASE WHEN received_offers > 0 THEN 1 ELSE 0 END) as students_with_offers,
    ROUND(100.0 * SUM(CASE WHEN received_offers > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) as conversion_rate
FROM v_student_activity_report
GROUP BY faculty
ORDER BY conversion_rate DESC;
```
### Топ работодателей по количеству офферов
```sql
-- Компании с наибольшим количеством предложений о работе
SELECT 
    e.company_name,
    COUNT(i.interview_id) as total_interviews,
    COUNT(CASE WHEN i.result = 'OFFER' THEN 1 END) as offers_made,
    ROUND(100.0 * COUNT(CASE WHEN i.result = 'OFFER' THEN 1 END) / COUNT(i.interview_id), 1) as offer_rate
FROM Employer e
JOIN Vacancy v ON e.employer_id = v.employer_id
JOIN Application a ON v.vacancy_id = a.vacancy_id
JOIN Interview i ON a.application_id = i.application_id
GROUP BY e.company_name
HAVING COUNT(i.interview_id) >= 5
ORDER BY offers_made DESC;
```
## Устранение неполадок
### Частые проблемы и решения
**Проблема**: Ошибка при отклике на вакансию

```sql
-- Проверка статуса вакансии
SELECT status, expires_at FROM Vacancy WHERE vacancy_id = ?;
```
**Проблема**: Не работает регистрация на мероприятие
```sql
-- Проверка доступности мест
SELECT 
    capacity,
    (SELECT COUNT(*) FROM EventRegistration WHERE event_id = ?) as current_registrations
FROM CareerEvent 
WHERE event_id = ?;
```
**Проблема**: Данные в отчетах не совпадают
```sql
-- Проверка актуальности данных
SELECT MAX(applied_at) as last_application FROM Application;
SELECT MAX(registered_at) as last_registration FROM EventRegistration;
```
