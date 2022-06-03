using Godot;
using System;
using static Godot.GD;

public partial class Authentication
{
    public NetworkedMultiplayerENet Network { get; }
    public Options Opt { get; }
    public SceneTree SceneTree { get; }

    public Authentication(NetworkedMultiplayerENet networkedMultiplayerENet, Options opt, SceneTree sceneTree)
    {
        Network = networkedMultiplayerENet;
        Opt = opt;
        SceneTree = sceneTree;
    }

    public void StartServer()
    {
        Network.CreateServer(Opt.Port, Opt.MaxNumServers);
        SceneTree.NetworkPeer = Network;
        Print("Authentication Server Started");
    }
}