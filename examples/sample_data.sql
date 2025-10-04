-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ СИСТЕМЫ КАРЬЕРНОГО СОПРОВОЖДЕНИЯ

-- Очистка таблиц
/*
DELETE FROM StudentMentor;
DELETE FROM Mentor;
DELETE FROM EventRegistration;
DELETE FROM CareerEvent;
DELETE FROM Interview;
DELETE FROM Application;
DELETE FROM Vacancy;
DELETE FROM Employer;
DELETE FROM Student;
DELETE FROM University;
*/

-- Добавление университетов
INSERT INTO University (name, city) VALUES
('HSE', 'Moscow'),
('MSU', 'Moscow'),
('MIPT', 'Moscow'),
('SPBSU', 'St. Petersburg'),
('KFU', 'Kazan'),
('RANHIGS', 'Moscow'),
('MIREA', 'Moscow'),
('NSU', 'Novosibirsk');

-- Добавление студентов
INSERT INTO Student (university_id, name, email, phone, faculty, graduation_year, resume_url) VALUES
(1, 'Иван Петров', 'ivan.petrov@edu.hse.ru', '+79161234567', 'Computer Science', 2025, 'https://resumes.ru/ivan_petrov'),
(1, 'Мария Сидорова', 'maria.sidorova@edu.hse.ru', '+79161234568', 'Economics', 2025, 'https://resumes.ru/maria_sidorova'),
(1, 'Алексей Козлов', 'alexey.kozlov@edu.hse.ru', '+79161234569', 'Mathematics', 2024, 'https://resumes.ru/alexey_kozlov'),
(2, 'Елена Волкова', 'elena.volkova@msu.ru', '+79161234570', 'Physics', 2025, 'https://resumes.ru/elena_volkova'),
(2, 'Дмитрий Орлов', 'dmitry.orlov@msu.ru', '+79161234571', 'Chemistry', 2024, 'https://resumes.ru/dmitry_orlov'),
(3, 'Анна Новикова', 'anna.novikova@phystech.ru', '+79161234572', 'Engineering', 2025, 'https://resumes.ru/anna_novikova');

-- Добавление работодателей
INSERT INTO Employer (company_name, industry, city, email, phone, rating) VALUES
('Yandex', 'IT', 'Moscow', 'hr@yandex.ru', '+74957397000', 4.8),
('SberTech', 'Finance', 'Moscow', 'career@sbertech.ru', '+74959577777', 4.6),
('Tinkoff', 'Finance', 'Moscow', 'hr@tinkoff.ru', '+74957047777', 4.7),
('2GIS', 'IT', 'Novosibirsk', 'job@2gis.ru', '+73832505050', 4.5),
('Ozon', 'E-commerce', 'Moscow', 'recruitment@ozon.ru', '+74957800310', 4.4);

-- Добавление вакансий
INSERT INTO Vacancy (employer_id, title, description, address, employment_type, posted_at, expires_at, status) VALUES
(1, 'Junior Python Developer', 'Ищем начинающего Python разработчика для работы над интересными проектами', 'Москва, ул. Льва Толстого, 16', 'FULL_TIME', DATEADD(day, -10, GETDATE()), DATEADD(month, 2, GETDATE()), 'ACTIVE'),
(1, 'Data Analyst', 'Анализ данных, построение отчетов, работа с большими данными', 'Москва, ул. Льва Толстого, 16', 'FULL_TIME', DATEADD(day, -5, GETDATE()), DATEADD(month, 1, GETDATE()), 'ACTIVE'),
(2, 'Backend Developer', 'Разработка высоконагруженных систем на Java', 'Москва, Кутузовский проспект, 32', 'FULL_TIME', DATEADD(day, -7, GETDATE()), DATEADD(month, 3, GETDATE()), 'ACTIVE'),
(3, 'Frontend Developer', 'Разработка пользовательских интерфейсов на React', 'Москва, 1-й Волоколамский проезд, 10', 'REMOTE', DATEADD(day, -3, GETDATE()), DATEADD(month, 2, GETDATE()), 'ACTIVE'),
(4, 'GIS Specialist', 'Работа с геоинформационными системами', 'Новосибирск, ул. Советская, 52', 'PART_TIME', DATEADD(day, -1, GETDATE()), DATEADD(month, 1, GETDATE()), 'ACTIVE');

-- Добавление откликов
INSERT INTO Application (student_id, vacancy_id, applied_at, status) VALUES
(1, 1, DATEADD(day, -9, GETDATE()), 'IN_PROGRESS'),
(1, 2, DATEADD(day, -4, GETDATE()), 'ACCEPTED'),
(2, 1, DATEADD(day, -8, GETDATE()), 'DECLINED'),
(2, 3, DATEADD(day, -6, GETDATE()), 'IN_PROGRESS'),
(3, 4, DATEADD(day, -2, GETDATE()), 'ACCEPTED'),
(4, 2, DATEADD(day, -3, GETDATE()), 'IN_PROGRESS'),
(5, 5, DATEADD(day, -1, GETDATE()), 'ACCEPTED');

-- Добавление собеседований
INSERT INTO Interview (application_id, scheduled_at, interview_type, completed, completed_at, result) VALUES
(2, DATEADD(day, 2, GETDATE()), 'TECHNICAL', 'NO', NULL, NULL),
(5, DATEADD(hour, 24, GETDATE()), 'HR', 'NO', NULL, NULL),
(7, DATEADD(day, -1, GETDATE()), 'TECHNICAL', 'YES', GETDATE(), 'OFFER');

-- Добавление мероприятий
INSERT INTO CareerEvent (title, event_type, start_at, address, capacity, description) VALUES
('Карьерный форум HSE', 'CAREER_FAIR', DATEADD(day, 14, GETDATE()), 'Москва, Покровский бульвар, 11', 200, 'Ежегодный карьерный форум для студентов ВШЭ'),
('Техническое собеседование: как подготовиться', 'LECTURE', DATEADD(day, 7, GETDATE()), 'Москва, ул. Мясницкая, 20', 50, 'Лекция от HR специалистов Yandex'),
('Networking с выпускниками', 'NETWORKING', DATEADD(day, 21, GETDATE()), 'Москва, Кремлевская набережная, 1', 30, 'Неформальная встреча с успешными выпускниками');

-- Добавление регистраций на мероприятия
INSERT INTO EventRegistration (event_id, student_id, registered_at) VALUES
(1, 1, DATEADD(day, -5, GETDATE())),
(1, 2, DATEADD(day, -4, GETDATE())),
(1, 3, DATEADD(day, -3, GETDATE())),
(2, 1, DATEADD(day, -2, GETDATE())),
(2, 4, DATEADD(day, -1, GETDATE())),
(3, 2, GETDATE());

-- Добавление наставников
INSERT INTO Mentor (employer_id, name, email, phone) VALUES
(1, 'Сергей Иванов', 'sergey.ivanov@yandex.ru', '+79161234580'),
(2, 'Ольга Петрова', 'olga.petrova@sbertech.ru', '+79161234581'),
(3, 'Андрей Сидоров', 'andrey.sidorov@tinkoff.ru', '+79161234582');

-- Добавление связей студент-наставник
INSERT INTO StudentMentor (student_id, mentor_id, assigned_at, status, feedback) VALUES
(1, 1, DATEADD(month, -2, GETDATE()), 'ACTIVE', NULL),
(2, 2, DATEADD(month, -1, GETDATE()), 'ACTIVE', NULL),
(3, 3, DATEADD(month, -3, GETDATE()), 'COMPLETED', 'Отличный наставник, помог с подготовкой к собеседованию');

-- Проверка добавленных данных
SELECT 'Университеты: ' + CAST(COUNT(*) AS VARCHAR) FROM University;
SELECT 'Студенты: ' + CAST(COUNT(*) AS VARCHAR) FROM Student;
SELECT 'Работодатели: ' + CAST(COUNT(*) AS VARCHAR) FROM Employer;
SELECT 'Вакансии: ' + CAST(COUNT(*) AS VARCHAR) FROM Vacancy;
SELECT 'Отклики: ' + CAST(COUNT(*) AS VARCHAR) FROM Application;
SELECT 'Собеседования: ' + CAST(COUNT(*) AS VARCHAR) FROM Interview;
SELECT 'Мероприятия: ' + CAST(COUNT(*) AS VARCHAR) FROM CareerEvent;
SELECT 'Регистрации: ' + CAST(COUNT(*) AS VARCHAR) FROM EventRegistration;
SELECT 'Наставники: ' + CAST(COUNT(*) AS VARCHAR) FROM Mentor;
SELECT 'Связи наставников: ' + CAST(COUNT(*) AS VARCHAR) FROM StudentMentor;
