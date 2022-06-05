using Godot;
using System;
using System.Linq;
using static Godot.GD;
public partial class Gateway
{
    public class Controller : Node
    {
        public Gateway Gateway { get; }
        public Authentication Auth { get; }
        public Controller(Gateway gateway, Gateway.Authentication auth)
        {
            Gateway = gateway;
            Auth = auth;
            AddChild(Gateway);
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
                Gateway.ReturnCreateAccountRequest(playerId, Error.Failed);
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