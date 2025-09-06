DROP TABLE IF EXISTS Tasks;
DROP TABLE IF EXISTS Projects;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Model_Training;
DROP TABLE IF EXISTS Data_Sets;
CREATE TABLE Projects (
    project_id INT NOT NULL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    status VARCHAR(50)
) ENGINE=InnoDB;
INSERT INTO Projects (project_id, project_name, start_date, end_date, status)
VALUES
(1, 'Website Redesign', '2023-01-10', '2023-03-20', 'Completed'),
(2, 'Mobile App Development', '2023-02-15', '2023-06-30', 'In Progress'),
(3, 'Data Migration', '2023-03-01', '2023-04-15', 'Completed'),
(4, 'Digital Marketing Campaign', '2023-04-05', '2023-07-01', 'In Progress'),
(5, 'Cloud Infrastructure Setup', '2023-05-01', '2023-08-20', 'Not Started');
CREATE TABLE Tasks (
    task_id INT NOT NULL PRIMARY KEY,
    project_id INT NOT NULL,
    task_name VARCHAR(100) NOT NULL,
    assigned_to VARCHAR(100),
    status VARCHAR(50),
    CONSTRAINT fk_project
        FOREIGN KEY (project_id) REFERENCES Projects(project_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;
INSERT INTO Tasks (task_id, project_id, task_name, assigned_to, status)
VALUES
(1, 1, 'Frontend Design', 'Alice Johnson', 'Completed'),
(2, 1, 'Testing', 'Bob Smith', 'Completed'),
(3, 2, 'Backend API Development', 'Alice Johnson', 'In Progress'),
(4, 2, 'Project Planning', 'Charlie Brown', 'In Progress'),
(5, 3, 'Data Validation', 'Bob Smith', 'Completed');
CREATE TABLE Teams (
    team_id INT NOT NULL PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20)
) ENGINE=InnoDB;
INSERT INTO Teams (team_id, member_name, role, email, phone)
VALUES
(1, 'Alice Johnson', 'Developer', 'alice@example.com', '1234567890'),
(2, 'Bob Smith', 'Tester', 'bob@example.com', '1234567891'),
(3, 'Charlie Brown', 'Project Manager', 'charlie@example.com', '1234567892'),
(4, 'Diana Prince', 'UI/UX Designer', 'diana@example.com', '1234567893'),
(5, 'Ethan Hunt', 'DevOps Engineer', 'ethan@example.com', '1234567894');
CREATE TABLE Model_Training (
    training_id INT PRIMARY KEY,
    project_id INT,
    model_name VARCHAR(100),
    accuracy DECIMAL(5,2),
    training_date DATE,
    CONSTRAINT fk_project_model FOREIGN KEY (project_id) REFERENCES Projects(project_id)
) ENGINE=InnoDB;

INSERT INTO Model_Training (training_id, project_id, model_name, accuracy, training_date)
VALUES
(1, 1, 'Model A', 85.50, '2023-02-01'),
(2, 1, 'Model B', 88.00, '2023-02-15'),
(3, 2, 'Model C', 92.30, '2023-05-01'),
(4, 3, 'Model D', 90.00, '2023-03-20'),
(5, 4, 'Model E', 87.50, '2023-06-01');
CREATE TABLE Data_Sets (
    dataset_id INT PRIMARY KEY,
    project_id INT,
    dataset_name VARCHAR(100),
    size_gb DECIMAL(10,2),
    last_updated DATE,
    CONSTRAINT fk_project_dataset FOREIGN KEY (project_id) REFERENCES Projects(project_id)
) ENGINE=InnoDB;

INSERT INTO Data_Sets (dataset_id, project_id, dataset_name, size_gb, last_updated)
VALUES
(1, 1, 'Dataset Alpha', 12.5, '2023-08-01'),
(2, 2, 'Dataset Beta', 8.0, '2023-07-20'),
(3, 3, 'Dataset Gamma', 15.0, '2023-08-05'),
(4, 4, 'Dataset Delta', 9.0, '2023-07-25'),
(5, 5, 'Dataset Epsilon', 20.0, '2023-08-03');

WITH TaskCounts AS (
    SELECT 
        project_id,
        COUNT(*) AS total_tasks,
        SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed_tasks
    FROM Tasks
    GROUP BY project_id
)
SELECT 
    p.project_name,
    t.total_tasks,
    t.completed_tasks
FROM Projects p
LEFT JOIN TaskCounts t ON p.project_id = t.project_id;

SELECT *
FROM (
    SELECT 
        assigned_to,
        COUNT(*) AS task_count,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rn
    FROM Tasks
    GROUP BY assigned_to
) sub
WHERE rn <= 2;

SELECT t.*
FROM Tasks t
WHERE t.due_date < (
    SELECT AVG(due_date)
    FROM Tasks
    WHERE project_id = t.project_id
);

SELECT *
FROM Projects
WHERE budget = (
    SELECT MAX(budget)
    FROM Projects
);


SELECT 
    p.project_name,
    ROUND(100.0 * SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completed_percentage
FROM Projects p
LEFT JOIN Tasks t ON p.project_id = t.project_id
GROUP BY p.project_name;

SELECT 
    assigned_to,
    task_name,
    COUNT(*) OVER (PARTITION BY assigned_to) AS tasks_assigned
FROM Tasks
ORDER BY assigned_to;

SELECT t.*
FROM Tasks t
JOIN Teams tm ON t.assigned_to = tm.member_name
WHERE tm.role = 'Team Lead'
  AND t.status <> 'Completed'
  AND t.due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 15 DAY);

SELECT p.*
FROM Projects p
LEFT JOIN Tasks t ON p.project_id = t.project_id
WHERE t.task_id IS NULL;

-- Create Model_Training table

-- Query for best model per project
SELECT mt.project_id, mt.model_name, mt.accuracy
FROM Model_Training mt
JOIN (
    SELECT project_id, MAX(accuracy) AS max_accuracy
    FROM Model_Training
    GROUP BY project_id
) sub ON mt.project_id = sub.project_id AND mt.accuracy = sub.max_accuracy;

-- Create Data_Sets table
-- Query
SELECT DISTINCT p.project_name, d.dataset_name, d.size_gb, d.last_updated
FROM Projects p
JOIN Data_Sets d ON p.project_id = d.project_id
WHERE d.size_gb > 10
  AND d.last_updated >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

