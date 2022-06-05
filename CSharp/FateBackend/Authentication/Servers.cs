using Godot;
using System;
using Godot.Collections;
using System.Linq;
using static Godot.GD;

public class Servers : Server
{
    readonly Dictionary servers = new Dictionary();

    public Servers(NetworkedMultiplayerENetServerOptions options) : base(options)
    {
    }
    // public Dictionary CreatedServers { get; } = new Dictionary();
    // public NetworkedMultiplayerENet Network { get; }
    // public MultiplayerAPI GatewayApi { get; }
    // public NetworkedMultiplayerENetServerOptions Options { get; }

    // public Servers(NetworkedMultiplayerENet networkedMultiplayerENet,
    //                MultiplayerAPI multiplayerAPI,
    //                NetworkedMultiplayerENetServerOptions options)
    // {
    //     Network = networkedMultiplayerENet;
    //     GatewayApi = multiplayerAPI;
    //     Options = options;
    // }

    // public override void _Ready()
    // {
    //     Network.CreateServer(Options.Port, Options.MaxClients);
    //     CustomMultiplayer = GatewayApi;
    //     CustomMultiplayer.RootNode = this;
    //     CustomMultiplayer.NetworkPeer = Network;
    //     Network.Connect("peer_connected", this, nameof(PeerConnected));
    //     Network.Connect("peer_disconnected", this, nameof(PeerDisconnected));
    //     Print("Server hub started.");
    // }

    // public override void _Process(float delta)
    // {
    //     var checks = new[]{
    //         CustomMultiplayer == null,
    //         !CustomMultiplayer.HasNetworkPeer()
    //     };
    //     if (checks.Any())
    //     {
    //         return;
    //     }
    //     CustomMultiplayer.Poll();
    // }

    // public void DistributeLoginToken(string server, string token, string username)
    // {
    //     var serverId = (int)CreatedServers[server];
    //     RpcId(serverId, "ReceiveLoginToken", token, username);
    // }


    // private void PeerConnected(int serverId)
    // {
    //     Print($"Server {serverId} connected.");
    //     CreatedServers["Server 1"] = serverId;
    //     Print(CreatedServers);
    // }

    // private void PeerDisconnected(int serverId)
    // {
    //     Print($"Server {serverId} disconnected.");
    // }

}
