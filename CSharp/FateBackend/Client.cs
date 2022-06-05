using Godot;
using System;
using System.Linq;
using static Godot.GD;

public abstract class Client : Node
{
    readonly MultiplayerAPI multiplayerApi = new MultiplayerAPI();
    readonly NetworkedMultiplayerENet network = new NetworkedMultiplayerENet();
    private readonly NetworkedMultiplayerENetClientOptions options;

    public Client(NetworkedMultiplayerENetClientOptions options)
    {
        this.options = options;
    }

    public override void _Ready()
    {
        CustomMultiplayer = multiplayerApi;
        CustomMultiplayer.RootNode = this;
        CustomMultiplayer.Connect("connected_to_server", this, nameof(OnConnectedToServer));
        CustomMultiplayer.Connect("connection_failed", this, nameof(OnConnectionFailed));
        CustomMultiplayer.Connect("server_disconnected", this, nameof(OnServerDisconnected));

        network.CreateClient(options.Ip, options.Port);
        CustomMultiplayer.NetworkPeer = network;
        Print($"Client {Name} started.");
    }

    public override void _Process(float delta)
    {
        if (!CustomMultiplayer.HasNetworkPeer())
        {
            return;
        }
        CustomMultiplayer.Poll();
    }

    protected virtual void OnConnectedToServer()
    {
        Print("Connected to server.");
    }

    protected virtual void OnConnectionFailed()
    {
        Print("Connection to server failed.");
    }

    protected virtual void OnServerDisconnected()
    {
        Print("Server disconnected.");
    }
}