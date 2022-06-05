using Godot;
using System;
using System.Linq;
using static Godot.GD;

namespace Gateway
{
    public class Server : EzServer
    {
        readonly X509 x509;

        public Server(NetworkedMultiplayerENetServerOptions options,
                      X509 x509) : base(options)
        {
            this.x509 = x509;
        }

        public void ReturnCreateAccountRequest(int playerId, Error result)
        {
            RpcId(playerId, nameof(ReturnCreateAccountRequest), result);
            network.DisconnectPeer(playerId);
        }

        public void ReturnLoginRequest(int playerId, string token, Error result)
        {
            RpcId(playerId, nameof(ReturnLoginRequest), result, token);
            network.DisconnectPeer(playerId);
        }
    }
}