package eu.odp.harvest.geo.oai.http;

import org.apache.commons.httpclient.protocol.Protocol;
import org.apache.commons.httpclient.protocol.ProtocolSocketFactory;

/**
 * Configures HttpClient that is used for Camel outgoing HTTP connections. Registers an SSL ProtocolSocketFactory that
 * trusts all server certificates.
 * WARNING: Use of this class is insecure, as it basically nullifies the purpose of HTTPS.
 * Do not use it if you need connections to trusted providers.
 */
public class AllowAllHttpClientConfig {
    /**
     * Constructor. Registers the custom ProtocolSocketFactory.
     */
    public AllowAllHttpClientConfig() {
        Protocol easyhttps = new Protocol("https", (ProtocolSocketFactory)new AllowAllSslProtocolSocketFactory(), 443);
        Protocol.registerProtocol("https", easyhttps);
    }
}
