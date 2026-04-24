using System.Data;
using System.Text;
using MySql.Data.MySqlClient;

namespace PayrollWinFormsPrototype;

internal static class Database
{
    private const string ConnectionString =
        "Server=localhost;Port=3306;Database=salary_payroll_db;Uid=payroll_admin;Pwd=Admin#2026;SslMode=None;AllowPublicKeyRetrieval=true;";

    public static DataTable Query(string sql)
    {
        using var connection = new MySqlConnection(ConnectionString);
        connection.Open();
        using var command = new MySqlCommand(sql, connection);
        using var adapter = new MySqlDataAdapter(command);
        var table = new DataTable();
        adapter.Fill(table);
        FixEncoding(table);
        return table;
    }

    private static void FixEncoding(DataTable table)
    {
        var win1252 = Encoding.GetEncoding("windows-1252");
        var utf8 = Encoding.UTF8;
        foreach (DataRow row in table.Rows)
        {
            foreach (DataColumn col in table.Columns)
            {
                if (row[col] is string s)
                {
                    row[col] = utf8.GetString(win1252.GetBytes(s));
                }
            }
        }
    }
}