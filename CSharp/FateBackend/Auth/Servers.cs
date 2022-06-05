using Godot;
using System;
using Godot.Collections;
using System.Linq;
using static Godot.GD;

namespace Auth
{
    public class Servers : Server
    {
        readonly Dictionary servers = new Dictionary();

        public Servers(NetworkedMultiplayerENetServerOptions options) : base(options)
        {
        }
        public void DistributeLoginToken(string server, string token, string username)
        {
            var serverId = (int)servers[server];
            RpcId(serverId, "ReceiveLoginToken", token, username);
        }


        protected override void OnNetworkPeerConnected(int serverId)
        {
            Print($"Server {serverId} connected.");
            servers["Server 1"] = serverId;
            Print(servers);
        }
    }
}