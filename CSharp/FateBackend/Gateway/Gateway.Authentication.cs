using Godot;
using System;
using System.Linq;
using static Godot.GD;

public partial class Gateway
{
    public class Authentication : Node
    {
        public NetworkedMultiplayerENet Network { get; }
        public MultiplayerAPI MultiplayerApi { get; }
        public NetworkedMultiplayerENetClientOptions Options { get; }

        public Authentication(NetworkedMultiplayerENet network,
                              MultiplayerAPI multiplayerApi,
                              NetworkedMultiplayerENetClientOptions options)
        {
            Network = network;
            MultiplayerApi = multiplayerApi;
            Options = options;
        }

        public override void _Ready()
        {
            Network.CreateClient(Options.Ip, Options.Port);
            // GetTree().NetworkPeer 
            // CustomMultiplayer = MultiplayerApi;
            // CustomMultiplayer.NetworkPeer = Network;
            Network.Connect("connection_succeeded", this, nameof(ConnectionSucceeded));
            Network.Connect("connection_failed", this, nameof(ConnectionFailed));
            Print("Gateway authentication started.");
        }

        public void CreateAccount(int playerId, string username, string password)
        {
            Print("Sending out create account request.");
            RpcId(1, "CreateAccount", playerId, username, password);
        }

        public void AuthenticatePlayer(int playerId, string username, string password)
        {
            Print("Sending out authentication request.");
            RpcId(1, "AuthenticatePlayer", playerId, username, password);
        }

        void ConnectionSucceeded()
        {
            Print("Successfully connected to the authentication server.");
        }

        void ConnectionFailed()
        {
            Print("Failed to connect to the authentication server.");
        }
    }
}