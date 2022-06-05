using Godot;
using System;
using static Godot.GD;

public class Authentication : Server
{
    readonly Servers servers;
    readonly Accounts accounts;

    public Authentication(NetworkedMultiplayerENetServerOptions options,
                          Servers servers,
                          Accounts accounts)
                          : base(options)
    {
        this.servers = servers;
        this.accounts = accounts;
    }

    [Remote]
    public void AuthenticatePlayer(string username, string password, int playerId)
    {
        Print("Authentication request recieved");
        var gatewayId = Multiplayer.GetRpcSenderId();
        var result = Error.Ok;
        string token = null;

        Print("Starting authentication...");
        if (!accounts.Exists(username))
        {
            Print($"User {username} is not recognized.");
            result = Error.Failed;
        }
        else
        {
            Print("Successful Authentication");
            Randomize();
            var hashed = Randi().ToString().SHA256Text();
            var timeStamp = OS.GetUnixTime().ToString();
            token = hashed + timeStamp;
            Print(token);
            var server = "Server 1"; // Replace with load balancers
            servers.DistributeLoginToken(server, token, username);
        }
        Print($"{username}: authentication results now sending to gateway server.");
        RpcId(gatewayId, "AuthenticationResults", playerId, token, result);
    }

    [Remote]
    public void CreateAccount(int playerId, string username, string password)
    {
        var gatewayId = Multiplayer.GetRpcSenderId();
        var result = Error.Ok;
        if (accounts.Exists(username))
        {
            result = Error.AlreadyExists;
        }
        else
        {
            var salt = Fast.GenerateSalt();
            Print(salt);
            var hashedPassword = Fast.GenerateHashPassword(password, salt);
            accounts.Create(username, password, salt);
        }
        RpcId(gatewayId, "CreateAccountResults", playerId, result);
    }




    // public NetworkedMultiplayerENet Network { get; }
    // public NetworkedMultiplayerENetServerOptions Options { get; }
    // public SceneTree Tree { get; }
    // public Accounts AccountDatabase { get; }
    // public Servers Servers { get; }

    // public Authentication(NetworkedMultiplayerENet networkedMultiplayerENet,
    //                       NetworkedMultiplayerENetServerOptions opt,
    //                       SceneTree sceneTree,
    //                       Accounts accountDatabase,
    //                       Servers servers)
    // {
    //     Network = networkedMultiplayerENet;
    //     Options = opt;
    //     Tree = sceneTree;
    //     AccountDatabase = accountDatabase;
    //     Servers = servers;
    // }

    // public override void _Ready()
    // {
    //     Network.CreateServer(Options.Port, Options.MaxClients);
    //     Tree.NetworkPeer = Network;
    //     Print("Authentication server started.");
    //     Network.Connect("peer_connected", this, nameof(PeerConnected));
    //     Network.Connect("peer_disconnected", this, nameof(PeerDisconnected));
    // }





    // private void PeerDisconnected(int id)
    // {
    //     Print($"Gateway {id} disconnected.");
    // }

    // private void PeerConnected(int id)
    // {
    //     Print($"Gateway {id} connected.");
    // }

}