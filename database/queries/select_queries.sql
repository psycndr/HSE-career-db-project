-- SQL ЗАПРОСЫ ДЛЯ СИСТЕМЫ КАРЬЕРНОГО СОПРОВОЖДЕНИЯ

-- ЗАПРОС 1: Активные вакансии работодателя с оставшимся сроком
-- Назначение: Для HR-менеджеров компаний для мониторинга активных вакансий
-- Выводит: список вакансий с количеством дней до истечения срока
SELECT
    v.vacancy_id,
    v.title,
    v.employment_type,
    v.posted_at,
    v.expires_at,
    DATEDIFF(DAY, GETDATE(), v.expires_at) AS days_remaining
FROM
    Vacancy v
    JOIN Employer e ON v.employer_id = e.employer_id
WHERE
    v.status = 'ACTIVE'
    AND e.company_name = 'Yandex' -- Можно заменить на любую компанию
    AND v.expires_at > GETDATE()
ORDER BY
    days_remaining ASC;

-- ЗАПРОС 2: Рейтинг университетов по активности студентов
-- Назначение: Для руководства вузов для сравнения эффективности карьерной работы
-- Выводит: университеты с метриками активности и конверсии
WITH UniversityStats AS (
    SELECT
        u.university_id,
        u.name AS university_name,
        u.city,
        COUNT(DISTINCT s.student_id) AS total_students,
        COUNT(DISTINCT a.application_id) AS total_applications,
        COUNT(DISTINCT CASE WHEN i.result = 'OFFER' THEN s.student_id END) AS students_with_offers
    FROM
        University u
        JOIN Student s ON u.university_id = s.university_id
        LEFT JOIN Application a ON s.student_id = a.student_id
        LEFT JOIN Interview i ON a.application_id = i.application_id
    GROUP BY
        u.university_id, u.name, u.city
)
SELECT TOP 10
    university_id,
    university_name,
    city,
    total_students,
    total_applications,
    students_with_offers,
    CASE
        WHEN total_students = 0 THEN 0
        ELSE CAST(total_applications AS FLOAT) / total_students
    END AS applications_per_student,
    CASE
        WHEN total_applications = 0 THEN 0
        ELSE CAST(students_with_offers AS FLOAT) / total_applications
    END AS offer_conversion_rate,
    DENSE_RANK() OVER (ORDER BY total_applications DESC) AS activity_rank
FROM
    UniversityStats
ORDER BY
    total_applications DESC;

-- ЗАПРОС 3: Вакансии с малым количеством откликов (<5)
-- Назначение: Для HR-аналитиков для выявления слабо продвигаемых вакансий
-- Выводит: вакансии с количеством откликов менее 5
SELECT
    v.vacancy_id,
    v.title,
    e.company_name,
    v.employment_type,
    v.posted_at,
    v.expires_at,
    COUNT(a.application_id) AS application_count,
    DATEDIFF(DAY, GETDATE(), v.expires_at) AS days_remaining
FROM
    Vacancy v
    JOIN Employer e ON v.employer_id = e.employer_id
    LEFT JOIN Application a ON v.vacancy_id = a.vacancy_id
WHERE
    v.status = 'ACTIVE'
    AND v.expires_at > GETDATE()
GROUP BY
    v.vacancy_id, v.title, e.company_name, v.employment_type, v.posted_at, v.expires_at
HAVING
    COUNT(a.application_id) < 5
ORDER BY
    application_count ASC,
    days_remaining ASC;

-- ЗАПРОС 4: Количество откликов по вакансиям
-- Назначение: Общая статистика популярности вакансий
-- Выводит: вакансии с количеством полученных откликов
SELECT
    v.title AS "Вакансия",
    stats.application_count AS "Откликов"
FROM Vacancy v
JOIN (
    SELECT vacancy_id, COUNT(*) AS application_count
    FROM Application
    GROUP BY vacancy_id
) stats ON v.vacancy_id = stats.vacancy_id;

-- ЗАПРОС 5: Топ-5 факультетов по коэффициенту офферов
-- Назначение: Для руководства университета для выявления успешных факультетов
-- Выводит: факультеты с соотношением офферов к количеству студентов
WITH FacultyStats AS (
    SELECT
        s.faculty,
        COUNT(DISTINCT s.student_id) AS total_students,
        SUM(CASE WHEN i.result = 'OFFER' THEN 1 ELSE 0 END) AS accepted_offers
    FROM
        Student s
        LEFT JOIN Application a ON s.student_id = a.student_id
        LEFT JOIN Interview i ON a.application_id = i.application_id
    GROUP BY
        s.faculty
)
SELECT TOP 5
    faculty,
    total_students,
    accepted_offers,
    CASE
        WHEN total_students = 0 THEN 0
        ELSE CAST(accepted_offers AS FLOAT) / total_students
    END AS offer_ratio
FROM
    FacultyStats
ORDER BY
    offer_ratio DESC;

-- ЗАПРОС 6: Заполняемость карьерных мероприятий по типам
-- Назначение: Для команды ивентов для анализа популярности типов мероприятий
-- Выводит: типы мероприятий с показателями заполняемости
SELECT
    ce.event_type,
    COUNT(er.registration_id) AS registrations_count,
    AVG(ce.capacity) AS avg_capacity,
    CASE
        WHEN AVG(ce.capacity) = 0 THEN 0
        ELSE CAST(COUNT(er.registration_id) AS FLOAT) / AVG(ce.capacity)
    END AS fill_rate,
    CONCAT(
        CAST(
            CASE
                WHEN AVG(ce.capacity) = 0 THEN 0
                ELSE (CAST(COUNT(er.registration_id) AS FLOAT) / AVG(ce.capacity)) * 100
            END AS DECIMAL(5,2)
        ), '%'
    ) AS fill_percentage
FROM
    CareerEvent ce
    LEFT JOIN EventRegistration er ON ce.event_id = er.event_id
GROUP BY
    ce.event_type
ORDER BY
    fill_rate DESC;

-- ЗАПРОС 7: Студенты с активностью выше средней по их университету
-- Назначение: Для кураторов для выявления наиболее активных студентов
-- Выводит: студентов, подавших больше заявок чем среднее по их вузу
SELECT 
    s.name, 
    s.university_id, 
    COUNT(a.application_id) AS apps
FROM Student s
    JOIN Application a ON s.student_id = a.student_id
GROUP BY s.student_id, s.name, s.university_id
HAVING COUNT(a.application_id) > (
    SELECT AVG(app_count)
    FROM (
        SELECT COUNT(*) AS app_count
        FROM Application a2
            JOIN Student s2 ON a2.student_id = s2.student_id
        WHERE s2.university_id = s.university_id
        GROUP BY s2.student_id
    ) uni_stats
);

-- ЗАПРОС 8: Вакансии без откликов от студентов конкретного университета
-- Назначение: Для кураторов для выявления непопулярных вакансий у своих студентов
-- Выводит: вакансии, на которые не откликались студенты указанного университета
SELECT v.title
FROM Vacancy v
WHERE NOT EXISTS (
    SELECT 1
    FROM Application a
        JOIN Student s ON a.student_id = s.student_id
    WHERE a.vacancy_id = v.vacancy_id
        AND s.university_id = 1 -- ID конкретного университета
);

-- ЗАПРОС 9: Acceptance Rate (офферы/отклики) по вакансиям
-- Назначение: Для HR-менеджеров для анализа эффективности вакансий
-- Выводит: вакансии с показателями конверсии откликов в офферы
WITH VacancyStats AS (
    SELECT
        v.vacancy_id,
        v.title,
        e.company_name,
        COUNT(DISTINCT a.application_id) AS total_applications,
        COUNT(DISTINCT CASE WHEN i.result = 'OFFER' THEN a.application_id END) AS offer_count
    FROM
        Vacancy v
        JOIN Employer e ON v.employer_id = e.employer_id
        LEFT JOIN Application a ON v.vacancy_id = a.vacancy_id
        LEFT JOIN Interview i ON a.application_id = i.application_id
    GROUP BY
        v.vacancy_id, v.title, e.company_name
)
SELECT
    vacancy_id,
    company_name,
    title,
    total_applications,
    offer_count,
    CASE
        WHEN total_applications = 0 THEN 0
        ELSE CAST(offer_count AS FLOAT) / total_applications
    END AS acceptance_rate,
    CONCAT(
        CAST(
            CASE
                WHEN total_applications = 0 THEN 0
                ELSE (CAST(offer_count AS FLOAT) / total_applications) * 100
            END AS DECIMAL(5,1)
        ), '%'
    ) AS acceptance_percentage
FROM
    VacancyStats
ORDER BY
    total_applications DESC, acceptance_rate DESC;

-- ЗАПРОС 10: Количество активных вакансий по работодателям
-- Назначение: Для sales-менеджеров платформы для анализа активности партнеров
-- Выводит: компании с количеством активных вакансий
SELECT
    e.employer_id,
    e.company_name,
    e.industry,
    COUNT(v.vacancy_id) AS active_vacancies_count
FROM
    Employer e
    LEFT JOIN Vacancy v ON e.employer_id = v.employer_id
WHERE
    v.status = 'ACTIVE'
    AND v.expires_at > GETDATE()
GROUP BY
    e.employer_id, e.company_name, e.industry
ORDER BY
    active_vacancies_count DESC;

-- ЗАПРОС 11: Средняя длительность наставничества в днях
-- Назначение: Для координаторов менторской программы для анализа эффективности
-- Выводит: статистику по длительности наставнических отношений
WITH MentorshipDuration AS (
    SELECT
        sm.student_id,
        sm.mentor_id,
        sm.assigned_at,
        sm.status,
        DATEDIFF(DAY, sm.assigned_at,
            CASE
                WHEN sm.status = 'ACTIVE' THEN GETDATE()
                ELSE COALESCE(
                    (SELECT MAX(completed_at)
                     FROM Interview i
                         JOIN Application a ON i.application_id = a.application_id
                     WHERE a.student_id = sm.student_id),
                    sm.assigned_at
                )
            END
        ) AS duration_days
    FROM
        StudentMentor sm
    WHERE
        sm.assigned_at IS NOT NULL
)
SELECT
    status,
    COUNT(*) AS mentorship_count,
    AVG(duration_days) AS avg_duration_days,
    MIN(duration_days) AS min_duration_days,
    MAX(duration_days) AS max_duration_days
FROM
    MentorshipDuration
GROUP BY
    status;

-- ЗАПРОС 12: Студенты с отклоненными откликами и без принятых офферов
-- Назначение: Для карьерных консультантов для выявления нуждающихся в помощи
-- Выводит: студентов с отказами и без успешных собеседований
SELECT DISTINCT
    s.student_id,
    s.name,
    s.email,
    s.phone,
    s.faculty,
    s.graduation_year,
    u.name AS university_name
FROM
    Student s
    JOIN University u ON s.university_id = u.university_id
WHERE
    EXISTS (
        SELECT 1
        FROM Application
        WHERE student_id = s.student_id AND status = 'DECLINED'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM Application a
            JOIN Interview i ON a.application_id = i.application_id
        WHERE a.student_id = s.student_id
            AND i.result = 'OFFER'
    )
ORDER BY
    s.graduation_year ASC,
    s.faculty ASC;

-- ЗАПРОС 13: Студенты, посещавшие мероприятия но не подававшие отклики
-- Назначение: Для email-маркетинга для целевой рассылки мотивационных писем
-- Выводит: активных на мероприятиях, но пассивных в поиске работы студентов
SELECT
    s.student_id,
    s.name,
    s.email,
    s.faculty,
    s.graduation_year,
    COUNT(er.event_id) AS events_attended,
    STRING_AGG(ce.title, ', ') AS attended_events
FROM
    Student s
    JOIN EventRegistration er ON s.student_id = er.student_id
    JOIN CareerEvent ce ON er.event_id = ce.event_id
    LEFT JOIN Application a ON s.student_id = a.student_id
WHERE
    a.application_id IS NULL
GROUP BY
    s.student_id, s.name, s.email, s.faculty, s.graduation_year
HAVING
    COUNT(er.event_id) > 0
ORDER BY
    events_attended DESC;

-- ЗАПРОС 14: Студенты без назначенного наставника
-- Назначение: Для координаторов менторской программы для выявления незакрытых потребностей
-- Выводит: студентов без активного наставника
SELECT
    s.student_id,
    s.name,
    s.email,
    s.phone,
    s.faculty,
    s.graduation_year,
    u.name AS university_name
FROM
    Student s
    JOIN University u ON s.university_id = u.university_id
WHERE
    NOT EXISTS (
        SELECT 1
        FROM StudentMentor sm
        WHERE sm.student_id = s.student_id
            AND sm.status = 'ACTIVE' -- Только активные наставничества
    )
ORDER BY
    s.graduation_year ASC,
    s.faculty ASC;

-- ЗАПРОС 15: Полная информация об интервью
-- Назначение: Для руководства карьерного центра для полного обзора процесса собеседований
-- Выводит: детальную информацию по всем проведенным интервью
SELECT
    s.name AS student,
    e.company_name,
    v.title AS vacancy,
    i.scheduled_at,
    i.result
FROM Interview i
    JOIN Application a ON i.application_id = a.application_id
    JOIN Student s ON a.student_id = s.student_id
    JOIN Vacancy v ON a.vacancy_id = v.vacancy_id
    JOIN Employer e ON v.employer_id = e.employer_id;

-- ЗАПРОС 16: Статистика по статусам заявок
-- Назначение: Для службы поддержки работодателей для анализа workflow
-- Выводит: распределение заявок по статусам в процентах
SELECT
    CASE
        WHEN status = 'IN_PROGRESS' THEN N'На рассмотрении'
        WHEN status = 'ACCEPTED' THEN N'Просмотрено'
        WHEN status = 'DECLINED' THEN N'Отклонено'
        ELSE N'Другое'
    END AS status_group,
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Application), 1) AS percentage
FROM Application
GROUP BY 
    CASE
        WHEN status = 'IN_PROGRESS' THEN N'На рассмотрении'
        WHEN status = 'ACCEPTED' THEN N'Просмотрено'
        WHEN status = 'DECLINED' THEN N'Отклонено'
        ELSE N'Другое'
    END;

-- ЗАПРОС 17: Мероприятия с заполняемостью менее 50%
-- Назначение: Для команды ивентов для выявления мероприятий требующих дополнительного промо
-- Выводит: события с низкой регистрацией для усиления продвижения
SELECT
    ce.event_id,
    ce.title,
    ce.event_type,
    ce.start_at,
    ce.address,
    ce.capacity,
    COUNT(er.registration_id) AS current_registrations,
    CONCAT(CAST(COUNT(er.registration_id) * 100.0 / NULLIF(ce.capacity, 0) AS DECIMAL(5,1)), '%') AS fill_percentage,
    DATEDIFF(DAY, GETDATE(), ce.start_at) AS days_until_event
FROM
    CareerEvent ce
    LEFT JOIN EventRegistration er ON ce.event_id = er.event_id
WHERE
    ce.start_at > GETDATE()
    AND ce.capacity > 0
GROUP BY
    ce.event_id, ce.title, ce.event_type, ce.start_at, ce.address, ce.capacity
HAVING
    COUNT(er.registration_id) * 100.0 / NULLIF(ce.capacity, 0) < 50
ORDER BY
    days_until_event ASC,
    fill_percentage ASC;

-- ЗАПРОС 18: Динамика откликов по месяцам с нарастающим итогом
-- Назначение: Для data-аналитиков для анализа трендов и сезонности
-- Выводит: помесячную статистику с кумулятивными показателями
WITH MonthlyApplications AS (
    SELECT
        YEAR(a.applied_at) AS year,
        MONTH(a.applied_at) AS month,
        COUNT(a.application_id) AS applications_count,
        COUNT(DISTINCT a.student_id) AS unique_students
    FROM
        Application a
    GROUP BY
        YEAR(a.applied_at), MONTH(a.applied_at)
)
SELECT
    CAST(year AS VARCHAR) + '-' + RIGHT('0' + CAST(month AS VARCHAR), 2) AS month,
    applications_count,
    SUM(applications_count) OVER (ORDER BY year, month) AS cumulative_applications,
    unique_students,
    SUM(unique_students) OVER (ORDER BY year, month) AS cumulative_unique_students,
    CAST(applications_count AS FLOAT) / NULLIF(unique_students, 0) AS apps_per_student,
    CAST(SUM(applications_count) OVER (ORDER BY year, month) AS FLOAT) /
    NULLIF(SUM(unique_students) OVER (ORDER BY year, month), 0) AS cumulative_apps_per_student
FROM
    MonthlyApplications
ORDER BY
    year, month;

-- ЗАПРОС 19: Сравнение активности студентов по месяцам
-- Назначение: Для success-менеджеров по работодателям для анализа динамики
-- Выводит: помесячную статистику с показателями роста/падения
SELECT
    month_year,
    application_count,
    LAG(application_count, 1) OVER (ORDER BY month_year) AS prev_month,
    ROUND(100.0 * (application_count - LAG(application_count, 1) OVER (ORDER BY month_year)) /
    LAG(application_count, 1) OVER (ORDER BY month_year), 1) AS growth_percent
FROM (
    SELECT
        FORMAT(applied_at, 'yyyy-MM') AS month_year,
        COUNT(*) AS application_count
    FROM Application
    GROUP BY FORMAT(applied_at, 'yyyy-MM')
) monthly_stats;
