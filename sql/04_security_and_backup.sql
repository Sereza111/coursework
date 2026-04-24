USE salary_payroll_db;

-- Роли и доступ (через отдельных пользователей MySQL)
DROP USER IF EXISTS 'payroll_admin'@'localhost';
DROP USER IF EXISTS 'payroll_accountant'@'localhost';
DROP USER IF EXISTS 'payroll_reader'@'localhost';

CREATE USER 'payroll_admin'@'localhost' IDENTIFIED BY 'Admin#2026';
CREATE USER 'payroll_accountant'@'localhost' IDENTIFIED BY 'Acc#2026';
CREATE USER 'payroll_reader'@'localhost' IDENTIFIED BY 'Read#2026';

GRANT ALL PRIVILEGES ON salary_payroll_db.* TO 'payroll_admin'@'localhost';

GRANT SELECT, INSERT, UPDATE ON salary_payroll_db.employees TO 'payroll_accountant'@'localhost';
GRANT SELECT, INSERT, UPDATE ON salary_payroll_db.accruals TO 'payroll_accountant'@'localhost';
GRANT SELECT, INSERT, UPDATE ON salary_payroll_db.deductions TO 'payroll_accountant'@'localhost';
GRANT SELECT, INSERT, UPDATE ON salary_payroll_db.payroll_calculations TO 'payroll_accountant'@'localhost';
GRANT SELECT, INSERT, UPDATE ON salary_payroll_db.payments TO 'payroll_accountant'@'localhost';
GRANT SELECT ON salary_payroll_db.* TO 'payroll_accountant'@'localhost';

GRANT SELECT ON salary_payroll_db.* TO 'payroll_reader'@'localhost';

FLUSH PRIVILEGES;

-- Пример команды резервного копирования (выполняется в консоли, не в SQL):
-- mysqldump -u payroll_admin -p salary_payroll_db > salary_payroll_backup.sql

-- Пример восстановления:
-- mysql -u payroll_admin -p salary_payroll_db < salary_payroll_backup.sql
