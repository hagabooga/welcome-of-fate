using Godot;
using System;
using static Godot.GD;

public class Main : Node
{
    private const int AuthenticationPort = 1911;

    public override void _Ready()
    {
        Print("Main start.");
        var main = new SimpleInjector.Container();


        var authContainer = new SimpleInjector.Container();
        authContainer.RegisterInstance(new Auth.Servers(new NetworkedMultiplayerENetServerOptions(1915, 100)));
        authContainer.RegisterInstance(new NetworkedMultiplayerENetServerOptions(AuthenticationPort, 5));
        authContainer.RegisterSingleton<Accounts>();
        authContainer.RegisterSingleton<Auth.Authentication>();
        authContainer.Verify();

        main.RegisterInstance(authContainer.GetInstance<Auth.Servers>());
        main.RegisterInstance(authContainer.GetInstance<Auth.Authentication>());
        main.RegisterInstance(new Gateway.Authentication(
            new NetworkedMultiplayerENetClientOptions("localhost", AuthenticationPort)));
        X509Certificate certificate = new X509Certificate();
        certificate.Load("res://Certificate/X509Certificate.crt");
        CryptoKey key = new CryptoKey();
        key.Load("res://Certificate/X509Key.key");
        X509 x509 = new X509(certificate, key);
        main.RegisterInstance(new Gateway.Server(new NetworkedMultiplayerENetServerOptions(1969, 100),
                                                 new X509(certificate, key)));
        main.RegisterSingleton<Gateway.Controller>();
        main.Verify();

        var servers = main.GetInstance<Auth.Servers>();
        var auth = main.GetInstance<Auth.Authentication>();
        var gatewayController = main.GetInstance<Gateway.Controller>();

        AddChild(servers);
        AddChild(auth);
        AddChild(gatewayController);
    }
}
