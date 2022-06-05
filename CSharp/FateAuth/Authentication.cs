using Godot;
using System;
using static Godot.GD;

public partial class Authentication : Node
{
    public NetworkedMultiplayerENet Network { get; }
    public NetworkedMultiplayerENetOptions Options { get; }
    public SceneTree Tree { get; }
    public AccountDatabase AccountDatabase { get; }
    public Servers Servers { get; }

    public Authentication(NetworkedMultiplayerENet networkedMultiplayerENet,
                          NetworkedMultiplayerENetOptions opt,
                          SceneTree sceneTree,
                          AccountDatabase accountDatabase,
                          Servers servers)
    {
        Network = networkedMultiplayerENet;
        Options = opt;
        Tree = sceneTree;
        AccountDatabase = accountDatabase;
        Servers = servers;
    }

    public override void _Ready()
    {
        Network.CreateServer(Options.Port, Options.MaxClients);
        Tree.NetworkPeer = Network;
        Print("Authentication Server Started");
        Network.Connect("peer_connected", this, nameof(PeerConnected));
        Network.Connect("peer_disconnected", this, nameof(PeerDisconnected));
    }

    [Remote]
    public void AuthenticatePlayer(string username, string password, int playerId)
    {
        Print("Authentication request recieved");
        var gatewayId = Tree.GetRpcSenderId();
        var result = Error.Ok;
        string token = null;

        Print("Starting authentication...");
        if (!(bool)AccountDatabase.Call("exists", username))
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
            Servers.DistributeLoginToken(server, token, username);
        }
        Print($"{username}: authentication results now sending to gateway server.");
        RpcId(gatewayId, "AuthenticationResults", playerId, token, result);
    }

    [Remote]
    public void CreateAccount(int playerId, string username, string password)
    {
        var gatewayId = Tree.GetRpcSenderId();
        var result = Error.Ok;
        if (AccountDatabase.Exists(username))
        {
            result = Error.AlreadyExists;
        }
        else
        {
            var salt = GenerateSalt();
            Print(salt);
            var hashedPassword = GenerateHashPassword(password, salt);
            AccountDatabase.Create(username, password, salt);
        }
        RpcId(gatewayId, "CreateAccountResults", playerId, result);
    }


    string GenerateSalt()
    {
        Randomize();
        return Randi().ToString().SHA256Text();
    }

    string GenerateHashPassword(string password, string salt)
    {
        var rounds = ((int)Mathf.Pow(2, 18));
        for (int i = 0; i < rounds; i++)
        {
            password = (password + salt).SHA256Text();
        }
        return password;
    }

    private void PeerDisconnected(int id)
    {
        Print($"Gateway {id} disconnected.");
    }

    private void PeerConnected(int id)
    {
        Print($"Gateway {id} connected.");
    }
}