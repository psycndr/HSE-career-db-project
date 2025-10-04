# Представления (Views) системы

## Обзор представлений

### v_student_activity_report
**Назначение:** Отчет по активности студентов для кураторов факультетов

**Ключевые метрики**:
- Количество поданных заявок
- Пройденные собеседования
- Полученные офферы
- Участие в карьерных мероприятиях

**Использование:**:
```sql
-- Для декана факультета
SELECT * FROM v_student_activity_report 
WHERE faculty = 'Computer Science'
ORDER BY received_offers DESC;

-- Для анализа активности по университетам
SELECT university, AVG(total_applications) as avg_applications
FROM v_student_activity_report 
GROUP BY university;
```

### v_vacancy_performance_analytics
**Назначение**: Аналитическая панель для HR-менеджеров

**Ключевые метрики**:
- Количество откликов на вакансию
- Проведенные собеседования
- Конверсия собеседований в офферы
- Среднее время закрытия вакансии

**Использование**:
```sql
-- Анализ эффективности по компаниям
SELECT company_name, AVG(conversion_rate) as avg_conversion
FROM v_vacancy_performance_analytics 
GROUP BY company_name;

-- Поиск наиболее успешных вакансий
SELECT * FROM v_vacancy_performance_analytics 
WHERE conversion_rate > 50 
ORDER BY conversion_rate DESC;
```

## Преимущества использования представлений
- Упрощение сложных запросов - скрывают сложность JOIN операций
- Безопасность данных - ограничивают доступ к определенным столбцам
- Переиспользование - единая точка для часто используемых запросов
- Согласованность - гарантируют единообразие расчетов метрик
