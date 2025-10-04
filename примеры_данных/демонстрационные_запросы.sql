-- Учебный пример: анализ активности студентов
-- Запрос демонстрирует использование оконных функций
SELECT 
    student_id,
    name,
    faculty,
    COUNT(application_id) AS total_applications,
    AVG(COUNT(application_id)) OVER (PARTITION BY faculty) AS avg_faculty_applications,
    RANK() OVER (ORDER BY COUNT(application_id) DESC) AS activity_rank
FROM Student 
LEFT JOIN Application USING(student_id)
GROUP BY student_id, name, faculty;

-- Учебный пример: триггер бизнес-логики
-- Автоматическая проверка возможности отклика на вакансию
CREATE TRIGGER tr_validate_application
ON Application
AFTER INSERT
AS
BEGIN
    -- Проверка, что вакансия активна и не просрочена
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Vacancy v ON i.vacancy_id = v.vacancy_id
        WHERE v.status != 'ACTIVE' OR v.expires_at < GETDATE()
    )
    BEGIN
        RAISERROR('Нельзя подать заявку на неактивную вакансию', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
