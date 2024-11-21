CREATE TABLE ST.GUEG_SALARY_HIST (
    gueg_person VARCHAR(50),
    gueg_class VARCHAR(50),
    gueg_salary INT,
    gueg_effective_from DATE,
    gueg_effective_to DATE
);

WITH RankedSalaries AS (
    SELECT 
        "person" AS gueg_person,
        "class" AS gueg_class,
        "salary" AS gueg_salary,
        "dt" AS gueg_effective_from,
        ROW_NUMBER() OVER (PARTITION BY "person" ORDER BY "dt") AS rn,
        LAG("salary") OVER (PARTITION BY "person" ORDER BY "dt") AS prev_salary
    FROM DE.HISTGROUP
)
INSERT INTO ST.GUEG_SALARY_HIST (gueg_person, gueg_class, gueg_salary, gueg_effective_from, gueg_effective_to)
SELECT 
    gueg_person,
    gueg_class,
    gueg_salary,
    gueg_effective_from,
    LEAD(gueg_effective_from, 1, '9999-12-31') OVER (PARTITION BY gueg_person ORDER BY gueg_effective_from) - INTERVAL '1 DAY' AS gueg_effective_to
FROM RankedSalaries
WHERE rn = 1 OR gueg_salary != prev_salary;
