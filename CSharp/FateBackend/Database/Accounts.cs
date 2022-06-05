using Godot;
using static Godot.GD;
using Godot.Collections;

public class Accounts : Node
{
    const string CreateStatement = @"
create table 
if not exists 
accounts (
    username text PRIMARY KEY NOT NULL,
    password text NOT NULL,
    salt text NOT NULL
)";

    public string DatabaseName { get; }
    public Array<string> Columns { get; }
    public Script Sqlite { get; }
    public Godot.Object Database { get; }

    public Accounts()
    {
        DatabaseName = Engine.EditorHint ?
            OS.GetExecutablePath().GetBaseDir() + "\\" :
            "res://Database/";
        Columns = new Array<string>() { "username", "password", "salt" };
        Sqlite = Load<Script>("res://addons/godot-sqlite/bin/gdsqlite.gdns");
        Database = Sqlite.Call("new") as Godot.Object;
        Database.Set("path", DatabaseName);
        Database.Set("verbose_mode", true);
        Database.Set("foreign_keys", true);
        Database.Call("open_db");
        Database.Call("query", CreateStatement);
    }

    public Dictionary this[string username]
    {
        get
        {
            var rows = Database.Call("select_rows",
                                     "accounts",
                                     $"username == \"{username}\"",
                                     Columns) as Array;

            return rows.Count == 0 ? null : rows[0] as Dictionary;
        }
    }

    public void Create(string username, string password, string salt)
    {
        var row = new Dictionary();
        row.Add("username", username);
        row.Add("password", password);
        row.Add("salt", salt);
        Database.Call("insert_row", "accounts", row);
    }

    public bool Exists(string username) => this[username] != null;

}
