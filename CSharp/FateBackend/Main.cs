using Godot;
using System;
using static Godot.GD;

public class Main : Node
{
    private const int AuthenticationPort = 1911;

    private void PeerDisconnected(int id)
    {
        Print($"Gateway {id} disconnected.");
    }

    private void PeerConnected(int id)
    {
        Print($"Gateway {id} connected.");
    }
    void ConnectionSucceeded()
    {
        Print("Successfully connected to the authentication server.");
    }

    void ConnectionFailed()
    {
        Print("Failed to connect to the authentication server.");
    }
    public override void _Ready()
    {
        var serversContainer = new SimpleInjector.Container();
        serversContainer.RegisterInstance(new NetworkedMultiplayerENetServerOptions(1915, 100));
        serversContainer.RegisterSingleton<NetworkedMultiplayerENet>();
        serversContainer.RegisterSingleton<MultiplayerAPI>();
        serversContainer.RegisterSingleton<Servers>();
        serversContainer.Verify();

        var authContainer = new SimpleInjector.Container();
        authContainer.RegisterSingleton<NetworkedMultiplayerENet>();
        authContainer.RegisterInstance(new NetworkedMultiplayerENetServerOptions(AuthenticationPort, 5));
        authContainer.RegisterInstance(GetTree());
        authContainer.RegisterSingleton<Accounts>();
        authContainer.RegisterInstance(serversContainer.GetInstance<Servers>());
        authContainer.RegisterSingleton<Authentication>();
        authContainer.Verify();

        var gatewayContainer = new SimpleInjector.Container();
        gatewayContainer.RegisterSingleton<NetworkedMultiplayerENet>();
        gatewayContainer.RegisterSingleton<MultiplayerAPI>();
        gatewayContainer.RegisterInstance(new NetworkedMultiplayerENetServerOptions(1969, 100));
        X509Certificate certificate = new X509Certificate();
        certificate.Load("res://Certificate/X509Certificate.crt");
        CryptoKey key = new CryptoKey();
        key.Load("res://Certificate/X509Key.key");
        X509 x509 = new X509(certificate, key);
        gatewayContainer.RegisterInstance(x509);
        gatewayContainer.RegisterSingleton<Gateway>();

        var gatewayAuthContainer = new SimpleInjector.Container();
        gatewayAuthContainer.RegisterSingleton<NetworkedMultiplayerENet>();
        gatewayAuthContainer.RegisterSingleton<MultiplayerAPI>();
        gatewayAuthContainer.RegisterInstance(new NetworkedMultiplayerENetClientOptions("127.0.0.1", AuthenticationPort));
        gatewayAuthContainer.RegisterSingleton<Gateway.Authentication>();
        gatewayAuthContainer.Verify();

        var gatewayControllerContainer = new SimpleInjector.Container();
        gatewayControllerContainer.RegisterInstance(gatewayContainer.GetInstance<Gateway>());
        gatewayControllerContainer.RegisterInstance(gatewayAuthContainer.GetInstance<Gateway.Authentication>());
        gatewayControllerContainer.RegisterSingleton<Gateway.Controller>();


        var servers = authContainer.GetInstance<Servers>();
        var auth = authContainer.GetInstance<Authentication>();
        var gatewayController = gatewayControllerContainer.GetInstance<Gateway.Controller>();

        AddChild(servers);
        AddChild(auth);
        AddChild(gatewayController);
    }
}
