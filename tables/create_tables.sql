CREATE TABLE Student (
    student_id INT IDENTITY(1, 1) PRIMARY KEY,
    university_id INT NOT NULL REFERENCES University(university_id),
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    faculty VARCHAR(100) NOT NULL,
    graduation_year INT NOT NULL,
    resume_url TEXT,
);

CREATE TABLE University (
university_id INT IDENTITY(1, 1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE Employer (
    employer_id INT IDENTITY(1, 1) PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    rating NUMERIC(3, 1)
);

CREATE TABLE Vacancy (
    vacancy_id INT IDENTITY(1,1) PRIMARY KEY,
    employer_id INT NOT NULL FOREIGN KEY REFERENCES Employer(employer_id) ON DELETE NO ACTION,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    address VARCHAR(100) NOT NULL,
    employment_type VARCHAR(30) NOT NULL,
    posted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'CLOSED', 'EXPIRED')),
    CONSTRAINT valid_expiration CHECK (expires_at > posted_at),
    CHECK (employment_type IN ('FULL_TIME', 'PART_TIME', 'INTERNSHIP', 'REMOTE'))
);

CREATE TABLE Application (
    application_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT NOT NULL REFERENCES Student(student_id) ON DELETE CASCADE,
    vacancy_id INT NOT NULL REFERENCES Vacancy(vacancy_id) ON DELETE CASCADE,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    UNIQUE (student_id, vacancy_id),
);

CREATE TABLE Interview (
    interview_id INT IDENTITY(1,1) PRIMARY KEY,
    application_id INT NOT NULL FOREIGN KEY REFERENCES Application(application_id) ON DELETE CASCADE,
    scheduled_at DATETIME NOT NULL,
    interview_type VARCHAR(30) NOT NULL,
    completed VARCHAR(3) CHECK (completed IN ('YES', 'NO')) DEFAULT 'NO',
    completed_at DATETIME NULL,
    result VARCHAR(20) CHECK (result IN ('OFFER', 'REJECTED', NULL))
);

CREATE TABLE CareerEvent (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    start_at DATETIME NOT NULL,
    address VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    description TEXT
);

CREATE TABLE EventRegistration (
    registration_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL FOREIGN KEY REFERENCES CareerEvent(event_id) ON DELETE CASCADE,
    student_id INT NOT NULL FOREIGN KEY REFERENCES Student(student_id) ON DELETE CASCADE,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (event_id, student_id)
);

CREATE TABLE Mentor (
    mentor_id INT IDENTITY(1,1) PRIMARY KEY,
    employer_id INT NOT NULL FOREIGN KEY REFERENCES Employer(employer_id),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE StudentMentor (
    student_id INT NOT NULL FOREIGN KEY REFERENCES Student(student_id),
    mentor_id INT NOT NULL FOREIGN KEY REFERENCES Mentor(mentor_id),
    assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'CANCELLED')),
    feedback TEXT,
    PRIMARY KEY (student_id, mentor_id)
);
