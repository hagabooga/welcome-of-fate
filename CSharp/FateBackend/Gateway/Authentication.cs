using Godot;
using System;
using System.Linq;
using static Godot.GD;

namespace Gateway
{
    public class Authentication : EzClient
    {
        public Authentication(NetworkedMultiplayerENetClientOptions options) : base(options)
        {
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
    }
}