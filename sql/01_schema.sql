DROP DATABASE IF EXISTS salary_payroll_db;
CREATE DATABASE salary_payroll_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE salary_payroll_db;

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE positions (
    position_id INT PRIMARY KEY AUTO_INCREMENT,
    position_name VARCHAR(120) NOT NULL UNIQUE,
    base_salary DECIMAL(12,2) NOT NULL CHECK (base_salary >= 0)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    last_name VARCHAR(80) NOT NULL,
    first_name VARCHAR(80) NOT NULL,
    middle_name VARCHAR(80) NULL,
    birth_date DATE NOT NULL,
    hire_date DATE NOT NULL,
    department_id INT NOT NULL,
    position_id INT NOT NULL,
    salary_rate DECIMAL(5,2) NOT NULL DEFAULT 1.00 CHECK (salary_rate > 0),
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_employees_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_employees_position FOREIGN KEY (position_id) REFERENCES positions(position_id)
);

CREATE TABLE payroll_periods (
    period_id INT PRIMARY KEY AUTO_INCREMENT,
    period_month TINYINT NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    period_year SMALLINT NOT NULL CHECK (period_year >= 2020),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed TINYINT(1) NOT NULL DEFAULT 0,
    UNIQUE KEY uq_period (period_month, period_year)
);

CREATE TABLE bonus_types (
    bonus_type_id INT PRIMARY KEY AUTO_INCREMENT,
    bonus_name VARCHAR(120) NOT NULL UNIQUE,
    is_taxable TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE penalties (
    penalty_id INT PRIMARY KEY AUTO_INCREMENT,
    penalty_name VARCHAR(120) NOT NULL UNIQUE,
    is_tax_deductible TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE accruals (
    accrual_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    period_id INT NOT NULL,
    bonus_type_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    comment_text VARCHAR(255) NULL,
    CONSTRAINT fk_accruals_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_accruals_period FOREIGN KEY (period_id) REFERENCES payroll_periods(period_id),
    CONSTRAINT fk_accruals_bonus_type FOREIGN KEY (bonus_type_id) REFERENCES bonus_types(bonus_type_id)
);

CREATE TABLE deductions (
    deduction_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    period_id INT NOT NULL,
    penalty_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    comment_text VARCHAR(255) NULL,
    CONSTRAINT fk_deductions_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_deductions_period FOREIGN KEY (period_id) REFERENCES payroll_periods(period_id),
    CONSTRAINT fk_deductions_penalty FOREIGN KEY (penalty_id) REFERENCES penalties(penalty_id)
);

CREATE TABLE payroll_calculations (
    calculation_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    period_id INT NOT NULL,
    gross_salary DECIMAL(12,2) NOT NULL CHECK (gross_salary >= 0),
    ndfl_tax DECIMAL(12,2) NOT NULL CHECK (ndfl_tax >= 0),
    total_deductions DECIMAL(12,2) NOT NULL CHECK (total_deductions >= 0),
    net_salary DECIMAL(12,2) NOT NULL CHECK (net_salary >= 0),
    calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_employee_period_calc (employee_id, period_id),
    CONSTRAINT fk_calc_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_calc_period FOREIGN KEY (period_id) REFERENCES payroll_periods(period_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    calculation_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL CHECK (amount_paid >= 0),
    payment_method ENUM('card', 'cash', 'transfer') NOT NULL DEFAULT 'card',
    CONSTRAINT fk_payments_calculation FOREIGN KEY (calculation_id) REFERENCES payroll_calculations(calculation_id)
);

CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_accruals_employee_period ON accruals(employee_id, period_id);
CREATE INDEX idx_deductions_employee_period ON deductions(employee_id, period_id);
CREATE INDEX idx_payments_date ON payments(payment_date);
