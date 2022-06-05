
using Godot;
using System.Linq;
using static Godot.GD;

public static class New
{
    public static T GetNode<T>(this SimpleInjector.Container container, string name = "") where T : Node
    {
        if (name.IsNullOrEmpty())
        {
            name = typeof(T).Name;
        }
        var instance = container.GetInstance<T>();
        return Node(instance, name);
    }

    public static T Node<T>(T node, string name = "") where T : Node
    {
        string path = typeof(T).FullName
            .Replace("+", "/")
            .Replace(".", "/");
        Print(path);
        node.Name = name;
        return node.SetScriptSafe<T>($"res://Scripts/{path}.cs");
    }
}