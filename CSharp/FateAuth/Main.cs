using Godot;
using System;

public class Main : Node
{
    public override void _Ready()
    {
        var container = new SimpleInjector.Container();

        container.RegisterInstance(new Authentication.Options(1911, 5));
        container.RegisterSingleton<NetworkedMultiplayerENet>();
        container.RegisterInstance(GetTree());
        container.RegisterSingleton<Authentication>();


    }
}
