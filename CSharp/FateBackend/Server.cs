using Godot;
using System;
using System.Linq;
using static Godot.GD;

public abstract class Server : Node
{
    readonly MultiplayerAPI multiplayerApi = new MultiplayerAPI();
    readonly NetworkedMultiplayerENet network = new NetworkedMultiplayerENet();
    private readonly NetworkedMultiplayerENetServerOptions options;

    public Server(NetworkedMultiplayerENetServerOptions options)
    {
        this.options = options;
    }

    public override void _Ready()
    {
        CustomMultiplayer = multiplayerApi;
        CustomMultiplayer.RootNode = this;
        CustomMultiplayer.Connect("network_peer_connected", this, nameof(OnNetworkPeerConnected));
        CustomMultiplayer.Connect("network_peer_disconnected", this, nameof(OnNetworkPeerDisconnected));

        network.CreateServer(options.Port, options.MaxClients);
        CustomMultiplayer.NetworkPeer = network;
        Print($"Server {Name} started.");
    }

    public override void _Process(float delta)
    {
        if (CustomMultiplayer == null || !CustomMultiplayer.HasNetworkPeer())
        {
            return;
        }
        CustomMultiplayer.Poll();
    }

    public void OnNetworkPeerConnected(int id)
    {
        Print($"{Name}: Network peer {id} connected.");
    }

    public void OnNetworkPeerDisconnected(int id)
    {
        Print($"{Name}: Network peer {id} disconnected.");
    }
}