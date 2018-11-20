package eu.odp.harvest.geo.oai.xslt;

import org.apache.camel.CamelContext;
import org.apache.camel.builder.xml.XsltUriResolver;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.MultiThreadedHttpConnectionManager;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.log4j.Logger;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayInputStream;

/**
 * Resolves a document reference for protocols "http" or "https" in an XSL document with HTTP client.
 * For all other URIs uses the default resolver base don classpath.
 */
public class HttpAwareUriResolver extends XsltUriResolver {

    private final static Logger LOG = Logger.getLogger(HttpAwareUriResolver.class);

    private static HttpClient httpClient = new HttpClient(new MultiThreadedHttpConnectionManager());

    public HttpAwareUriResolver(CamelContext context, String location) {
        super(context, location);
    }

    public Source resolve(String href, String base) throws TransformerException {
        if (href.startsWith("http:") || href.startsWith("https:")) {
            try {
                return resolveHttp(href);
            }
            catch (Exception e) {
                LOG.error("Error resolving resource " + href, e);
                throw new TransformerException("Error resolving resource " + href, e);
            }
        }
        else {
            return super.resolve(href, base);
        }
    }

    private Source resolveHttp(String href) throws Exception {
        GetMethod method = new GetMethod(href);
        try {
            httpClient.executeMethod(method);
            byte[] bytes = method.getResponseBody();
            return new StreamSource(new ByteArrayInputStream(bytes));
        }
        finally {
            method.releaseConnection();
        }
    }
}
