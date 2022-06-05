
using Godot;
using System.Linq;
using static Godot.GD;

public static class New
{
    public static T Node<T>(T node, string name = "") where T : Node
    {
        string fullName = typeof(T).FullName;
        Print(fullName);
        node.Name = name;
        return node.SetScriptSafe<T>($"res://{fullName}.cs");
    }
}