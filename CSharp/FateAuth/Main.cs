using Godot;
using System;
using static Godot.GD;

public class Main : Node
{
    public override void _Ready()
    {
        var serversContainer = new SimpleInjector.Container();
        serversContainer.RegisterInstance(new NetworkedMultiplayerENetOptions(1915, 100));
        serversContainer.RegisterSingleton<NetworkedMultiplayerENet>();
        serversContainer.RegisterSingleton<MultiplayerAPI>();
        serversContainer.RegisterSingleton<Servers>();
        serversContainer.Verify();

        var authContainer = new SimpleInjector.Container();
        authContainer.RegisterSingleton<NetworkedMultiplayerENet>();
        authContainer.RegisterInstance(new NetworkedMultiplayerENetOptions(1911, 5));
        authContainer.RegisterInstance(GetTree());
        authContainer.RegisterSingleton<AccountDatabase>();
        authContainer.RegisterInstance(serversContainer.GetInstance<Servers>());
        authContainer.RegisterSingleton<Authentication>();
        authContainer.Verify();

        var servers = authContainer.GetInstance<Servers>();
        var auth = authContainer.GetInstance<Authentication>();

        AddChild(servers);
        AddChild(auth);

    }
}
