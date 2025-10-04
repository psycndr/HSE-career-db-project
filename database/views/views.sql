-- Представление 1: Статистика активности студентов
CREATE VIEW v_student_activity_report AS
SELECT
    s.student_id,
    s.name AS student_name,
    s.faculty,
    u.name AS university,
    COUNT(DISTINCT a.application_id) AS total_applications,
    COUNT(DISTINCT i.interview_id) AS completed_interviews,
    COUNT(DISTINCT CASE WHEN i.result = 'OFFER' THEN i.interview_id END) AS received_offers,
    COUNT(DISTINCT er.event_id) AS event_participations
FROM Student s
JOIN University u ON s.university_id = u.university_id
LEFT JOIN Application a ON s.student_id = a.student_id
LEFT JOIN Interview i ON a.application_id = i.application_id AND i.result <> 'IN_PROGRESS'
LEFT JOIN EventRegistration er ON s.student_id = er.student_id
GROUP BY s.student_id, s.name, s.faculty, u.name;

-- Представление 2: Эффективность вакансий для HR
CREATE VIEW v_vacancy_performance_analytics AS
SELECT
    v.vacancy_id,
    v.title AS vacancy_title,
    e.company_name,
    v.employment_type,
    v.posted_at,
    COUNT(a.application_id) AS applications_count,
    COUNT(i.interview_id) AS interviews_held,
    ROUND(100.0 * COUNT(CASE WHEN i.result = 'OFFER' THEN 1 END) / NULLIF(COUNT(i.interview_id), 0), 1) AS conversion_rate,
    DATEDIFF(day, v.posted_at, COALESCE(MIN(i.completed_at), GETDATE())) AS avg_filling_time_days
FROM Vacancy v
JOIN Employer e ON v.employer_id = e.employer_id
LEFT JOIN Application a ON v.vacancy_id = a.vacancy_id
LEFT JOIN Interview i ON a.application_id = i.application_id
GROUP BY v.vacancy_id, v.title, e.company_name, v.employment_type, v.posted_at;
