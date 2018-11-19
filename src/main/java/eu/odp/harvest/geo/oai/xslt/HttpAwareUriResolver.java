package eu.odp.harvest.geo.oai.xslt;

import org.apache.camel.CamelContext;
import org.apache.camel.builder.xml.XsltUriResolver;
import org.apache.camel.spi.ClassResolver;
import org.apache.camel.util.FileUtil;
import org.apache.camel.util.ObjectHelper;
import org.apache.camel.util.ResourceHelper;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.MultiThreadedHttpConnectionManager;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.log4j.Logger;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Resolves a document reference for protcols "http" or "https" in an XSL document with HTTP client.
 * For all other URIs uses the default rsolver base don classpath.
 */
public class HttpAwareUriResolver implements URIResolver {

    private final static Logger LOG = Logger.getLogger(HttpAwareUriResolver.class);

    private static HttpClient httpClient = new HttpClient(new MultiThreadedHttpConnectionManager());

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        if (ObjectHelper.isEmpty(href)) {
            throw new TransformerException("include href is empty");
        } else {
            LOG.debug("Resolving URI with href: " + href);
            if (href.startsWith("http:") || href.startsWith("https:")) {
                try {
                    return resolveHttp(href);
                } catch (Exception e) {
                    throw new TransformerException(e);
                }
            } else {
                String scheme = ResourceHelper.getScheme(href);
                href = href.startsWith("/") ? href : "/" + href;
                return new StreamSource(getClass().getResourceAsStream(href));
            }
        }
    }
/*
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
*/

    private Source resolveHttp(String href) throws Exception {
        GetMethod method = new GetMethod(href);
        try {
            httpClient.executeMethod(method);
            byte[] bytes = method.getResponseBody();
            return new StreamSource(new ByteArrayInputStream(bytes));
//            return new StreamSource(method.getResponseBodyAsStream());
        }
        finally {
            method.releaseConnection();
        }
    }
}
