using Godot;
using System;
using System.Linq;
using static Godot.GD;
namespace Gateway
{
    public class Controller : EzNode
    {
        public Server Server { get; }
        public Authentication Auth { get; }
        public Controller(Server server, Authentication auth)
        {
            Server = server;
            Auth = auth;
            AddChild(Server);
            AddChild(Auth);
        }

        [Remote]
        public void CreateAccountRequest(string username, string password)
        {
            var playerId = CustomMultiplayer.GetRpcSenderId();
            var checkIfBad = new[]
            {
            username.IsNullOrEmpty(),
            password.IsNullOrEmpty(),
            password.Length <= 6
        };
            if (checkIfBad.Any())
            {
                Server.ReturnCreateAccountRequest(playerId, Error.Failed);
            }
            else
            {
                Auth.CreateAccount(playerId, username.ToLower(), password);
            }
        }

        [Remote]
        public void LoginRequest(string username, string password)
        {
            Print("Login request received.");
            var playerId = CustomMultiplayer.GetRpcSenderId();
            Auth.AuthenticatePlayer(playerId, username, password);
        }

    }
}