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