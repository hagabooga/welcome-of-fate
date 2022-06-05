using Godot;
using static Godot.GD;

public static class Extensions
{
    public static bool IsNullOrEmpty(this string x) => string.IsNullOrEmpty(x);

    public static T SafelySetScript<T>(this Object obj, Resource resource) where T : Object
    {
        var godotObjectId = obj.GetInstanceId();
        // Replaces old C# instance with a new one. Old C# instance is disposed.
        obj.SetScript(resource);
        // Get the new C# instance
        return GD.InstanceFromId(godotObjectId) as T;
    }

    public static T SetScriptSafe<T>(this Object obj, string resource) where T : Object
    {
        return SafelySetScript<T>(obj, ResourceLoader.Load(resource));
    }
}

public static class Fast
{
    public static string GenerateSalt()
    {
        Randomize();
        return Randi().ToString().SHA256Text();
    }

    public static string GenerateHashPassword(string password, string salt)
    {
        var rounds = ((int)Mathf.Pow(2, 18));
        for (int i = 0; i < rounds; i++)
        {
            password = (password + salt).SHA256Text();
        }
        return password;
    }
}