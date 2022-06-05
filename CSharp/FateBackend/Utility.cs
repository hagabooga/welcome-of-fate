using Godot;
using System.Linq;
using static Godot.GD;


public abstract class EzClient : EzNode
{
    protected readonly MultiplayerAPI multiplayerApi = new MultiplayerAPI();
    protected readonly NetworkedMultiplayerENet network = new NetworkedMultiplayerENet();
    protected readonly NetworkedMultiplayerENetClientOptions options;

    public EzClient(NetworkedMultiplayerENetClientOptions options)
    {
        this.options = options;
    }

    public override void _Ready()
    {
        base._Ready();
        CustomMultiplayer = multiplayerApi;
        CustomMultiplayer.RootNode = this;
        CustomMultiplayer.Connect("connected_to_server", this, nameof(OnConnectedToServer));
        CustomMultiplayer.Connect("connection_failed", this, nameof(OnConnectionFailed));
        CustomMultiplayer.Connect("server_disconnected", this, nameof(OnServerDisconnected));

        network.CreateClient(options.Ip, options.Port);

        CustomMultiplayer.NetworkPeer = network;
        Print($"Client {Name} started.");
    }

    public override void _Process(float delta)
    {
        if (!CustomMultiplayer.HasNetworkPeer())
        {
            return;
        }
        CustomMultiplayer.Poll();
    }

    protected virtual void OnConnectedToServer()
    {
        Print($"Client {Name} has connected to the server.");
    }

    protected virtual void OnConnectionFailed()
    {
        Print($"Client {Name}: Connection to server has failed.");
    }

    protected virtual void OnServerDisconnected()
    {
        Print("Server disconnected.");
    }
}
public abstract class EzServer : EzNode
{
    protected readonly MultiplayerAPI multiplayerApi = new MultiplayerAPI();
    protected readonly NetworkedMultiplayerENet network = new NetworkedMultiplayerENet();
    protected private readonly NetworkedMultiplayerENetServerOptions options;

    public EzServer(NetworkedMultiplayerENetServerOptions options)
    {
        this.options = options;
    }

    public override void _Ready()
    {
        base._Ready();
        CustomMultiplayer = multiplayerApi;
        CustomMultiplayer.RootNode = this;
        CustomMultiplayer.Connect("network_peer_connected", this, nameof(OnNetworkPeerConnected));
        CustomMultiplayer.Connect("network_peer_disconnected", this, nameof(OnNetworkPeerDisconnected));

        network.CreateServer(options.Port, options.MaxClients);
        CustomMultiplayer.NetworkPeer = network;
        Print($"Server {Name} started.");
    }

    public override void _Process(float delta)
    {
        if (CustomMultiplayer == null || !CustomMultiplayer.HasNetworkPeer())
        {
            return;
        }
        CustomMultiplayer.Poll();
    }

    protected virtual void OnNetworkPeerConnected(int id)
    {
        Print($"Server {Name}: Network peer {id} connected.");
    }

    protected virtual void OnNetworkPeerDisconnected(int id)
    {
        Print($"Server {Name}: Network peer {id} disconnected.");
    }
}


public static class Extensions
{
    public static bool IsNullOrEmpty(this string x) => string.IsNullOrEmpty(x);

    public static T SafelySetScript<T>(this Object obj, Resource resource) where T : Object
    {
        var godotObjectId = obj.GetInstanceId();
        // Replaces old C# instance with a new one. Old C# instance is disposed.
        obj.SetScript(resource);
        // Get the new C# instance
        return GD.InstanceFromId(godotObjectId) as T;
    }

    public static T SetScriptSafe<T>(this Object obj, string resource) where T : Object
    {
        return SafelySetScript<T>(obj, ResourceLoader.Load(resource));
    }

}

public static class Fast
{
    public static string GenerateSalt()
    {
        Randomize();
        return Randi().ToString().SHA256Text();
    }

    public static string GenerateHashPassword(string password, string salt)
    {
        var rounds = ((int)Mathf.Pow(2, 18));
        for (int i = 0; i < rounds; i++)
        {
            password = (password + salt).SHA256Text();
        }
        return password;
    }
}


public class NetworkedMultiplayerENetClientOptions
{
    public string Ip { get; }
    public int Port { get; }

    public NetworkedMultiplayerENetClientOptions(string ip, int port)
    {
        Ip = ip;
        Port = port;
    }
}

public class NetworkedMultiplayerENetServerOptions
{
    public int Port { get; }
    public int MaxClients { get; }

    public NetworkedMultiplayerENetServerOptions(int port, int maxNumServers)
    {
        Port = port;
        MaxClients = maxNumServers;
    }
}

public class X509
{
    public X509Certificate Certificate { get; }
    public CryptoKey Key { get; }

    public X509(X509Certificate certificate, CryptoKey key)
    {
        Certificate = certificate;
        Key = key;
    }
}


public abstract class EzNode : Node
{
    public override void _Ready()
    {
        Name = GetType().FullName;
    }
}