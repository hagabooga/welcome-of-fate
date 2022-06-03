public partial class Authentication
{
    public class Options
    {
        public int Port { get; }
        public int MaxNumServers { get; }

        public Options(int port, int maxNumServers)
        {
            Port = port;
            MaxNumServers = maxNumServers;
        }
    }
}