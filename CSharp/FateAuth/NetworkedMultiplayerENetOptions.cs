public class NetworkedMultiplayerENetOptions
{
    public int Port { get; }
    public int MaxClients { get; }

    public NetworkedMultiplayerENetOptions(int port, int maxNumServers)
    {
        Port = port;
        MaxClients = maxNumServers;
    }
}