USE salary_payroll_db;

INSERT INTO departments (department_name) VALUES
('Бухгалтерия'),
('Отдел продаж'),
('ИТ-отдел'),
('Отдел кадров');

INSERT INTO positions (position_name, base_salary) VALUES
('Бухгалтер', 62000.00),
('Менеджер по продажам', 58000.00),
('Системный администратор', 70000.00),
('HR-специалист', 56000.00);

INSERT INTO employees (
    last_name, first_name, middle_name, birth_date, hire_date, department_id, position_id, salary_rate, is_active
) VALUES
('Петров', 'Алексей', 'Игоревич', '1995-06-15', '2022-02-01', 1, 1, 1.00, 1),
('Сидорова', 'Марина', 'Сергеевна', '1998-03-09', '2023-05-10', 2, 2, 1.00, 1),
('Кузнецов', 'Дмитрий', 'Олегович', '1992-12-21', '2021-11-15', 3, 3, 1.20, 1),
('Иванова', 'Елена', 'Павловна', '1997-08-04', '2024-01-20', 4, 4, 0.75, 1);

INSERT INTO payroll_periods (period_month, period_year, start_date, end_date, is_closed) VALUES
(3, 2026, '2026-03-01', '2026-03-31', 1),
(4, 2026, '2026-04-01', '2026-04-30', 0);

INSERT INTO bonus_types (bonus_name, is_taxable) VALUES
('Премия ежемесячная', 1),
('Надбавка за стаж', 1),
('Компенсация питания', 0);

INSERT INTO penalties (penalty_name, is_tax_deductible) VALUES
('Штраф за опоздание', 0),
('Удержание по исполнительному листу', 1),
('Погашение подотчета', 1);

INSERT INTO accruals (employee_id, period_id, bonus_type_id, amount, comment_text) VALUES
(1, 1, 1, 5000.00, 'План выполнен'),
(2, 1, 1, 8000.00, 'Высокие продажи'),
(3, 1, 2, 4200.00, 'Стаж > 3 лет'),
(4, 1, 3, 2500.00, 'Компенсация питания');

INSERT INTO deductions (employee_id, period_id, penalty_id, amount, comment_text) VALUES
(1, 1, 1, 500.00, 'Опоздание 2 раза'),
(2, 1, 3, 1200.00, 'Закрытие подотчета'),
(3, 1, 2, 3000.00, 'Исполнительный лист');

INSERT INTO payroll_calculations (
    employee_id, period_id, gross_salary, ndfl_tax, total_deductions, net_salary
) VALUES
(1, 1, 67000.00, 8710.00, 500.00, 57790.00),
(2, 1, 66000.00, 8580.00, 1200.00, 56220.00),
(3, 1, 88200.00, 11466.00, 3000.00, 73734.00),
(4, 1, 44500.00, 5785.00, 0.00, 38715.00);

INSERT INTO payments (calculation_id, payment_date, amount_paid, payment_method) VALUES
(1, '2026-04-05', 57790.00, 'card'),
(2, '2026-04-05', 56220.00, 'transfer'),
(3, '2026-04-05', 73734.00, 'transfer'),
(4, '2026-04-05', 38715.00, 'card');
