using Godot;
using System;
using System.Linq;
using static Godot.GD;

public partial class Gateway : Node
{
    public NetworkedMultiplayerENet Network { get; }
    public MultiplayerAPI GatewayApi { get; }
    public NetworkedMultiplayerENetServerOptions Options { get; }
    public X509 X509 { get; }

    public Gateway(NetworkedMultiplayerENet network,
                   MultiplayerAPI gatewayApi,
                   NetworkedMultiplayerENetServerOptions options,
                   X509 x509)
    {
        Network = network;
        GatewayApi = gatewayApi;
        Options = options;
        X509 = x509;
    }

    public override void _Ready()
    {
        Network.UseDtls = true;
        Network.SetDtlsCertificate(X509.Certificate);
        Network.SetDtlsKey(X509.Key);
        Network.CreateServer(Options.Port, Options.MaxClients);
        CustomMultiplayer = GatewayApi;
        CustomMultiplayer.RootNode = this;
        CustomMultiplayer.NetworkPeer = Network;
        Network.Connect("peer_connected", this, nameof(PeerConnected));
        Network.Connect("peer_disconnected", this, nameof(PeerDisconnected));
        Print("Gateway server started.");

    }

    public override void _Process(float delta)
    {
        if (!CustomMultiplayer.HasNetworkPeer())
        {
            return;
        }
        CustomMultiplayer.Poll();
    }

    public void ReturnCreateAccountRequest(int playerId, Error result)
    {
        RpcId(playerId, nameof(ReturnCreateAccountRequest), result);
        Network.DisconnectPeer(playerId);
    }

    public void ReturnLoginRequest(int playerId, string token, Error result)
    {
        RpcId(playerId, nameof(ReturnLoginRequest), result, token);
        Network.DisconnectPeer(playerId);
    }


    void PeerConnected(int playerId)
    {
        Print($"User {playerId} connected.");
    }

    void PeerDisconnected(int playerId)
    {
        Print($"User {playerId} disconnected.");
    }
}