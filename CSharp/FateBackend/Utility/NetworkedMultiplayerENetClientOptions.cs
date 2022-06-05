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