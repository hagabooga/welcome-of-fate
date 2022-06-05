using Godot;

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