using System.Data;
using MySql.Data.MySqlClient;

namespace PayrollWinFormsPrototype;

internal static class Database
{
    private const string ConnectionString =
        "Server=localhost;Port=3306;Database=salary_payroll_db;Uid=payroll_admin;Pwd=Admin#2026;SslMode=None;AllowPublicKeyRetrieval=true;";

    public static DataTable Query(string sql)
    {
        using var connection = new MySqlConnection(ConnectionString);
        using var command = new MySqlCommand(sql, connection);
        using var adapter = new MySqlDataAdapter(command);
        var table = new DataTable();
        connection.Open();
        adapter.Fill(table);
        return table;
    }
}
