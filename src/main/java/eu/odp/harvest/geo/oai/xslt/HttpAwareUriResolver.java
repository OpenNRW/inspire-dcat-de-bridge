package eu.odp.harvest.geo.oai.xslt;

import org.apache.camel.CamelContext;
import org.apache.camel.Exchange;
import org.apache.camel.ExchangePattern;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.component.xslt.XsltUriResolver;
import org.apache.camel.support.DefaultExchange;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamSource;

/**
 * Resolves a document reference for protocols "http" or "https" in an XSL document with HTTP client.
 * It can also invoke custom Camel routes to get documents for protocol type "direct".
 * For all other URIs uses the default resolver base don classpath.
 */
public class HttpAwareUriResolver extends XsltUriResolver {

    private final static Logger LOG = LogManager.getLogger(HttpAwareUriResolver.class);

    private static HttpClient httpClient = HttpClients.custom()
            .setConnectionManager(new PoolingHttpClientConnectionManager())
            .useSystemProperties()
            .build();
    private ProducerTemplate template;
    private CamelContext context;

    /**
     * Constructor.
     * @param context Camel Context
     * @param location location
     * @param template producer template used to call other Camel routes
     */
    public HttpAwareUriResolver(CamelContext context, String location, ProducerTemplate template) {
        super(context, location);
        this.template = template;
        this.context = context;
    }

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        if (href.startsWith("direct:getCoupledServices")) {
            try {
                return resolveRoute(href);
            }
            catch (Exception e) {
                LOG.error("Error resolving direct resource " + href, e);
                throw new TransformerException("Error resolving direct resource " + href, e);
            }
        }
        else if (href.startsWith("http:") || href.startsWith("https:")) {
            try {
                return resolveHttp(href);
            }
            catch (Exception e) {
                LOG.error("Error resolving http resource " + href, e);
                throw new TransformerException("Error resolving http resource " + href, e);
            }
        }
        else {
            return super.resolve(href, base);
        }
    }

    private Source resolveRoute(String href) {
        Exchange exchange = new DefaultExchange(context, ExchangePattern.InOut);
        String[] parts = href.split("\\?");
        exchange.getIn().setHeader("resourceIdentifiers", parts[1]);
        template.send(parts[0], exchange);
        return new StreamSource(exchange.getMessage().getBody(java.io.InputStream.class));
    }

    private Source resolveHttp(String href) throws Exception {
        HttpResponse response = httpClient.execute(new HttpGet(href));
        return new StreamSource(response.getEntity().getContent());
    }
}
