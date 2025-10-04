CREATE TRIGGER tr_ValidateVacancyStatus
ON Application        -- Таблице заявок
AFTER INSERT, UPDATE  -- Срабатывает после вставки или обновления записей
AS
BEGIN
   SET NOCOUNT ON;
  
   -- 1. Обновляем статус просроченных вакансий на EXPIRED
   UPDATE Vacancy
   SET status = 'EXPIRED'
   WHERE expires_at < GETDATE()   -- Вакансия просрочена
     AND status != 'CLOSED';      -- И не помечена как CLOSED
  
   -- 2. Проверяем статусы вакансий для новых заявок
   DECLARE @VacancyID INT;       -- ID вакансии
   DECLARE @Status VARCHAR(20);  -- Статус вакансии
   DECLARE @ExpiresAt DATETIME;  -- Срок действия вакансии
  
   -- Получаем данные о вакансии из первой записи
   SELECT TOP 1
       @VacancyID = i.vacancy_id,
       @Status = v.status,
       @ExpiresAt = v.expires_at
   FROM inserted i
   JOIN Vacancy v ON i.vacancy_id = v.vacancy_id;
  
   -- Проверяем статус вакансии
   IF @Status IN ('CLOSED', 'EXPIRED') OR @ExpiresAt < GETDATE()
   BEGIN
       -- Сообщение об ошибке
       DECLARE @ErrorMessage VARCHAR(100);
       SET @ErrorMessage = CASE
           WHEN @Status = 'CLOSED' THEN 'Нельзя подать заявку на закрытую вакансию'
           WHEN @Status = 'EXPIRED' OR @ExpiresAt < GETDATE()
               THEN 'Нельзя подать заявку на вакансию с истекшим сроком'
           ELSE 'Нельзя подать заявку на эту вакансию'
       END;
       RAISERROR(@ErrorMessage, 16, 1);
       ROLLBACK TRANSACTION;  -- Отменяем текущую транзакцию
       RETURN;
   END
END;


CREATE TRIGGER tr_ValidateEventRegistration
ON EventRegistration  -- Триггер привязан к таблице регистраций на мероприятия
AFTER INSERT, UPDATE  -- Срабатывает после вставки или обновления записей
AS
BEGIN
   SET NOCOUNT ON;  -- Отключаем вывод количества затронутых строк для оптимизации
  
   -- Объявляем переменные для хранения данных
   DECLARE @EventID INT;               -- ID мероприятия
   DECLARE @StartAt DATETIME;          -- Время начала мероприятия
   DECLARE @CurrentRegistrations INT;  -- Текущее количество регистраций
   DECLARE @Capacity INT;              -- Максимальная вместимость мероприятия
  
   -- Получаем данные о мероприятии из первой вставленной/обновленной записи
   -- (для простоты примера берем первую запись, в реальной системе нужно обрабатывать все)
   SELECT TOP 1
       @EventID = i.event_id,
       @StartAt = ce.start_at,
       @Capacity = ce.capacity
   FROM inserted i
   JOIN CareerEvent ce ON i.event_id = ce.event_id;
  
   -- 1. Проверяем, не началось ли уже мероприятие
   IF @StartAt < GETDATE()
   BEGIN
       RAISERROR('Нельзя зарегистрироваться на мероприятие, которое уже началось', 16, 1);
       ROLLBACK TRANSACTION;  -- Отменяем текущую транзакцию
       RETURN;                -- Выходим из триггера
   END
   -- 2. Считаем текущее количество регистраций на мероприятие
   SELECT
       @CurrentRegistrations = COUNT(er.registration_id)  -- Считаем все регистрации
   FROM EventRegistration er
   WHERE er.event_id = @EventID;                          -- Только для текущего мероприятия
  
   -- Проверяем, не превышена ли вместимость
   IF @CurrentRegistrations > @Capacity
   BEGIN
       -- Если превышена - вызываем ошибку с сообщением
       RAISERROR('Превышено максимальное количество участников для этого мероприятия (Capacity: %d)', 16, 1, @Capacity);
       ROLLBACK TRANSACTION;  -- Отменяем текущую транзакцию
       RETURN;                -- Выходим из триггера
   END
END;


CREATE TRIGGER tr_CheckApplicationStatusForInterview
ON Interview
AFTER INSERT, UPDATE
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @InvalidCount INT;
  
   -- Считаем количество проблемных записей
   SELECT @InvalidCount = COUNT(*)
   FROM inserted i
   JOIN Application a ON i.application_id = a.application_id
   WHERE a.status <> 'ACCEPTED';
  
   -- Если есть такие записи - отменяем операцию
   IF @InvalidCount > 0
   BEGIN
       RAISERROR('Не могу создать/обновить запись на интервью: все записи должны ссылаться на заявку со статусом "ACCEPTED"', 16, 1);
       ROLLBACK TRANSACTION;
       RETURN;
   END
END;



CREATE TRIGGER tr_UpdateInterviewCompletionTime
ON Interview
AFTER UPDATE
AS
BEGIN
   SET NOCOUNT ON;
  
   -- Обновляем записи, где result изменился
   UPDATE i
   SET
       completed_at = GETDATE()
   FROM
       Interview i
       INNER JOIN inserted ins ON i.interview_id = ins.interview_id
       INNER JOIN deleted del ON i.interview_id = del.interview_id
   WHERE
       -- Условия срабатывания:
       (ins.result != 'IN_PROGRESS') AND           
       (
           (del.result <> ins.result)  -- Результат изменился
       )
       AND i.completed_at IS NULL;     -- Время еще не было установлено
END;


CREATE TRIGGER tr_CheckMentorStudentLimit
ON StudentMentor                         -- Триггер привязан к таблице связей студент-ментор
AFTER INSERT, UPDATE                     -- Срабатывает после вставки или обновления записей
AS
BEGIN
   SET NOCOUNT ON;                      -- Отключаем вывод количества затронутых строк
   -- Объявляем переменные
   DECLARE @MentorID INT;               -- ID ментора
   DECLARE @CurrentStudents INT;        -- Текущее количество студентов у ментора
   DECLARE @MaxStudents INT = 5;        -- Максимальное допустимое количество студентов
  
   -- Получаем ID ментора из вставленной/обновленной записи
   SELECT @MentorID = i.mentor_id FROM inserted i;
  
   -- Считаем количество активных студентов у этого ментора
   SELECT @CurrentStudents = COUNT(student_id)
   FROM StudentMentor
   WHERE mentor_id = @MentorID          -- Только для текущего ментора
     AND status = 'ACTIVE';             -- Только активные связи (не завершенные/отмененные)
   -- Проверяем, не превышен ли лимит
   IF @CurrentStudents > @MaxStudents
   BEGIN
       -- Если превышен - вызываем ошибку
       RAISERROR('У этого ментора уже максимальное количество студентов (%d)', 16, 1, @MaxStudents);
       ROLLBACK TRANSACTION;  -- Отменяем текущую транзакцию
       RETURN;                -- Выходим из триггера
   END
END;

