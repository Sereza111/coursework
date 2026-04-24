using System;
using System.Drawing;
using System.Windows.Forms;

namespace PayrollWinFormsPrototype;

public class MainForm : Form
{
    private readonly DataGridView _grid;
    private readonly Button _loadEmployeesButton;
    private readonly Button _loadPayrollButton;
    private readonly Label _statusLabel;

    public MainForm()
    {
        Text = "Начисление и выплата зарплаты (прототип)";
        Width = 1000;
        Height = 650;
        StartPosition = FormStartPosition.CenterScreen;

        var topPanel = new Panel { Dock = DockStyle.Top, Height = 56, Padding = new Padding(8) };
        _loadEmployeesButton = new Button
        {
            Text = "Сотрудники",
            Width = 160,
            Height = 32,
            Left = 8,
            Top = 10
        };
        _loadEmployeesButton.Click += (_, _) => LoadEmployees();

        _loadPayrollButton = new Button
        {
            Text = "Ведомость выплат",
            Width = 180,
            Height = 32,
            Left = 180,
            Top = 10
        };
        _loadPayrollButton.Click += (_, _) => LoadPayrollSheet();

        _statusLabel = new Label
        {
            Left = 380,
            Top = 16,
            Width = 560,
            ForeColor = Color.DimGray,
            Text = "Готово к работе"
        };

        topPanel.Controls.Add(_loadEmployeesButton);
        topPanel.Controls.Add(_loadPayrollButton);
        topPanel.Controls.Add(_statusLabel);

        _grid = new DataGridView
        {
            Dock = DockStyle.Fill,
            ReadOnly = true,
            AllowUserToAddRows = false,
            AllowUserToDeleteRows = false,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
        };

        Controls.Add(_grid);
        Controls.Add(topPanel);
    }

    private void LoadEmployees()
    {
        try
        {
            const string sql = @"
                SELECT
                    e.employee_id AS 'ID',
                    CONCAT(e.last_name, ' ', e.first_name, ' ', IFNULL(e.middle_name, '')) AS 'ФИО',
                    d.department_name AS 'Отдел',
                    p.position_name AS 'Должность',
                    p.base_salary AS 'Оклад'
                FROM employees e
                JOIN departments d ON d.department_id = e.department_id
                JOIN positions p ON p.position_id = e.position_id
                ORDER BY e.last_name, e.first_name;";

            _grid.DataSource = Database.Query(sql);
            _statusLabel.Text = $"Загружено сотрудников: {_grid.Rows.Count}";
        }
        catch (Exception ex)
        {
            _statusLabel.Text = "Ошибка загрузки сотрудников";
            MessageBox.Show(ex.Message, "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void LoadPayrollSheet()
    {
        try
        {
            const string sql = @"
                SELECT
                    e.employee_id AS 'ID',
                    CONCAT(e.last_name, ' ', e.first_name) AS 'Сотрудник',
                    pp.period_month AS 'Месяц',
                    pp.period_year AS 'Год',
                    c.gross_salary AS 'Начислено',
                    c.ndfl_tax AS 'НДФЛ',
                    c.total_deductions AS 'Удержано',
                    c.net_salary AS 'К выплате'
                FROM payroll_calculations c
                JOIN employees e ON e.employee_id = c.employee_id
                JOIN payroll_periods pp ON pp.period_id = c.period_id
                ORDER BY pp.period_year DESC, pp.period_month DESC, e.last_name;";

            _grid.DataSource = Database.Query(sql);
            _statusLabel.Text = $"Загружено строк ведомости: {_grid.Rows.Count}";
        }
        catch (Exception ex)
        {
            _statusLabel.Text = "Ошибка загрузки ведомости";
            MessageBox.Show(ex.Message, "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
