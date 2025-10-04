# Описание сущностей базы данных

## Основные таблицы

### University (Университеты)
**Назначение:** Хранение информации об учебных заведениях
```sql
university_id (PK) - уникальный идентификатор
name - название университета
city - город расположения
```

### Student (Студенты)
**Назначение**: Основная информация о студентах системы
```sql
student_id (PK) - уникальный идентификатор
university_id (FK) - ссылка на университет
name - ФИО студента
email - электронная почта
phone - контактный телефон
faculty - факультет/направление
graduation_year - год выпуска
resume_url - ссылка на резюме
```

### Employer (Работодатели)
**Назначение**: Информация о компаниях-партнерах
```sql
employer_id (PK) - уникальный идентификатор
company_name - название компании
industry - отрасль деятельности
city - город расположения
phone - контактный телефон
email - электронная почта
rating - рейтинг компании (1-5)
```

### Vacancy (Вакансии)
**Назначение**: Рабочие места и стажировки от работодателей
```sql
vacancy_id (PK) - уникальный идентификатор
employer_id (FK) - ссылка на работодателя
title - должность/название вакансии
description - описание вакансии
address - адрес места работы
employment_type - тип занятости (FULL_TIME/PART_TIME/INTERNSHIP/REMOTE)
posted_at - дата публикации
expires_at - срок действия вакансии
status - статус (ACTIVE/CLOSED/EXPIRED)
```

### Application (Заявки/Отклики)
**Назначение**: Отклики студентов на вакансии
``` sql
application_id (PK) - уникальный идентификатор
student_id (FK) - ссылка на студента
vacancy_id (FK) - ссылка на вакансию
applied_at - дата подачи отклика
status - статус рассмотрения (ACCEPTED/DECLINED/IN_PROGRESS)
```

### Interview (Собеседования)
**Назначение**: Информация о проведенных собеседованиях
```sql
interview_id (PK) - уникальный идентификатор
application_id (FK) - ссылка на заявку
scheduled_at - дата и время проведения
interview_type - тип собеседования
completed - флаг завершения (YES/NO)
completed_at - фактическое время завершения
result - результат (OFFER/REJECTED/IN_PROGRESS)
```

### CareerEvent (Карьерные мероприятия)
**Назначение**: Информация о карьерных событиях
```sql
event_id (PK) - уникальный идентификатор
title - название мероприятия
event_type - тип (CAREER_FAIR/LECTURE/NETWORKING)
start_at - дата и время начала
address - место проведения
capacity - максимальное количество участников
description - описание мероприятия
```

### EventRegistration (Регистрации на мероприятия)
**Назначение**: Учет регистраций студентов на мероприятия
```sql
registration_id (PK) - уникальный идентификатор
event_id (FK) - ссылка на мероприятие
student_id (FK) - ссылка на студента
registered_at - время регистрации
```

### Mentor (Наставники)
**Назначение**: Информация о наставниках от компаний
```sql
mentor_id (PK) - уникальный идентификатор
employer_id (FK) - ссылка на работодателя
name - ФИО наставника
email - электронная почта
phone - контактный телефон
```

### StudentMentor (Связи студент-наставник)
**Назначение**: Учет наставнических отношений
```sql
student_id (FK) - ссылка на студента
mentor_id (FK) - ссылка на наставника
assigned_at - дата назначения
status - статус (ACTIVE/COMPLETED/CANCELLED)
feedback - отзыв о наставничестве
```

## Связи и ограничения
### Внешние ключи
- `Student.university_id` → `University.university_id`
- `Vacancy.employer_id` → `Employer.employer_id`
- `Application.student_id` → `Student.student_id (ON DELETE CASCADE)`
- `Application.vacancy_id` → `Vacancy.vacancy_id (ON DELETE CASCADE)`
- `Interview.application_id` → `Application.application_id (ON DELETE CASCADE)`

### Бизнес-ограничения
- Уникальность комбинации студент-вакансия в Application
- Проверка дат (expires_at > posted_at)
- Ограничения на значения enum-полей
- Контроль вместимости мероприятий

### Нормализация
База данных соответствует третьей нормальной форме (3NF):
- Все неключевые атрибуты зависят только от первичного ключа
- Отсутствуют транзитивные зависимости
- Минимальная избыточность данных

### Индексы
Рекомендуемые индексы для оптимизации:
- `Student(university_id, faculty)`
- `Vacancy(employer_id, status)`
- `Application(student_id, applied_at)`
- `Application(vacancy_id, status)`
- `EventRegistration(event_id, student_id)`
