USE salary_payroll_db;

-- 1) Список сотрудников с отделом и должностью
SELECT e.employee_id, e.last_name, e.first_name, d.department_name, p.position_name, p.base_salary
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN positions p ON p.position_id = e.position_id
ORDER BY e.last_name, e.first_name;

-- 2) Начисления за период
SELECT a.accrual_id, e.last_name, e.first_name, bt.bonus_name, a.amount
FROM accruals a
JOIN employees e ON e.employee_id = a.employee_id
JOIN bonus_types bt ON bt.bonus_type_id = a.bonus_type_id
WHERE a.period_id = 1
ORDER BY e.last_name;

-- 3) Удержания за период
SELECT d.deduction_id, e.last_name, e.first_name, p.penalty_name, d.amount
FROM deductions d
JOIN employees e ON e.employee_id = d.employee_id
JOIN penalties p ON p.penalty_id = d.penalty_id
WHERE d.period_id = 1
ORDER BY e.last_name;

-- 4) Итоговая зарплатная ведомость
SELECT
    pp.period_month,
    pp.period_year,
    e.last_name,
    e.first_name,
    c.gross_salary,
    c.ndfl_tax,
    c.total_deductions,
    c.net_salary
FROM payroll_calculations c
JOIN employees e ON e.employee_id = c.employee_id
JOIN payroll_periods pp ON pp.period_id = c.period_id
WHERE c.period_id = 1
ORDER BY e.last_name;

-- 5) Отчет по фонду оплаты труда по отделам
SELECT
    d.department_name,
    COUNT(*) AS employees_count,
    ROUND(SUM(c.gross_salary), 2) AS gross_fot,
    ROUND(SUM(c.net_salary), 2) AS net_fot
FROM payroll_calculations c
JOIN employees e ON e.employee_id = c.employee_id
JOIN departments d ON d.department_id = e.department_id
WHERE c.period_id = 1
GROUP BY d.department_name
ORDER BY gross_fot DESC;

-- 6) Сложный запрос: сотрудники с выплатой выше средней
SELECT
    e.employee_id,
    e.last_name,
    e.first_name,
    c.net_salary
FROM payroll_calculations c
JOIN employees e ON e.employee_id = c.employee_id
WHERE c.period_id = 1
  AND c.net_salary > (
    SELECT AVG(net_salary)
    FROM payroll_calculations
    WHERE period_id = 1
  )
ORDER BY c.net_salary DESC;

-- 7) Представление для ведомости выплат
CREATE OR REPLACE VIEW vw_payment_sheet AS
SELECT
    pay.payment_id,
    pay.payment_date,
    pay.amount_paid,
    pay.payment_method,
    e.employee_id,
    CONCAT(e.last_name, ' ', e.first_name, ' ', IFNULL(e.middle_name, '')) AS employee_fio
FROM payments pay
JOIN payroll_calculations c ON c.calculation_id = pay.calculation_id
JOIN employees e ON e.employee_id = c.employee_id;

SELECT * FROM vw_payment_sheet ORDER BY payment_date DESC, employee_fio;

-- 8) Процедура расчета НДФЛ (13%)
DROP PROCEDURE IF EXISTS sp_calculate_ndfl;
DELIMITER //
CREATE PROCEDURE sp_calculate_ndfl(IN p_gross DECIMAL(12,2), OUT p_tax DECIMAL(12,2))
BEGIN
    SET p_tax = ROUND(p_gross * 0.13, 2);
END //
DELIMITER ;

-- Пример вызова процедуры
SET @tax = 0;
CALL sp_calculate_ndfl(67000.00, @tax);
SELECT @tax AS ndfl_value;
