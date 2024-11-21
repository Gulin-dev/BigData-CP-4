CREATE TABLE ST.GUEG_SALARY_LOG (
    gueg_payment_dt DATE,
    gueg_person VARCHAR(50),
    gueg_payment DECIMAL(10, 2),
    gueg_month_paid DECIMAL(10, 2),
    gueg_month_rest DECIMAL(10, 2)
);

INSERT INTO ST.GUEG_SALARY_LOG (gueg_payment_dt, gueg_person, gueg_payment, gueg_month_paid, gueg_month_rest)
SELECT 
    sp.dt AS gueg_payment_dt,
    sp.person AS gueg_person,
    sp.payment AS gueg_payment,
    SUM(sp.payment) OVER (PARTITION BY sp.person, DATE_TRUNC('month', sp.dt)) AS gueg_month_paid,
    sh.gueg_salary - SUM(sp.payment) OVER (PARTITION BY sp.person, DATE_TRUNC('month', sp.dt)) AS gueg_month_rest
FROM DE.SALARY_PAYMENTS sp
JOIN ST.GUEG_SALARY_HIST sh ON sp.person = sh.gueg_person 
                             AND sp.dt BETWEEN sh.gueg_effective_from AND sh.gueg_effective_to;
