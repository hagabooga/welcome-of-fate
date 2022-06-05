using Godot;
using System;
using static Godot.GD;

namespace Auth
{
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
    }
}