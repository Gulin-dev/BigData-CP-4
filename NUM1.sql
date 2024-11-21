CREATE TABLE ST.GUEG_SALARY_HIST (
    gueg_person VARCHAR(50),
    gueg_class VARCHAR(50),
    gueg_salary INT,
    gueg_effective_from DATE,
    gueg_effective_to DATE
);

INSERT INTO ST.GUEG_SALARY_HIST (gueg_person, gueg_class, gueg_salary, gueg_effective_from, gueg_effective_to)
SELECT 
    "person" AS gueg_person,
    "class" AS gueg_class,
    "salary" AS gueg_salary,
    "effective_from" AS gueg_effective_from,
    LEAD("effective_from", 1, '9999-12-31') OVER (PARTITION BY "person" ORDER BY "effective_from") - INTERVAL '1 DAY' AS gueg_effective_to
FROM (
    SELECT 
        "person",
        "class",
        "salary",
        "effective_from",
        ROW_NUMBER() OVER (PARTITION BY "person" ORDER BY "effective_from") AS rn
    FROM DE.HISTGROUP
) AS subquery
WHERE rn = 1 OR "salary" != LAG("salary") OVER (PARTITION BY "person" ORDER BY "effective_from");
