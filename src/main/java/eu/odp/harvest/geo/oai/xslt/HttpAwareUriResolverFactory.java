package eu.odp.harvest.geo.oai.xslt;

import org.apache.camel.CamelContext;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.component.xslt.XsltUriResolverFactory;

import javax.xml.transform.URIResolver;

/**
 * Factory class for custom XSLT URI resolver.
 */
public class HttpAwareUriResolverFactory implements XsltUriResolverFactory {
    private ProducerTemplate template;

    /**
     * Factory method.
     * @param camelContext camel context
     * @param resourceUri URI to be resolved
     * @return URI resolver
     */
    public URIResolver createUriResolver(CamelContext camelContext, String resourceUri) {
        return new HttpAwareUriResolver(camelContext, resourceUri, template);
    }

    /**
     * Sets the producer template.
     * @param template producer template
     */
    public void setProducer(ProducerTemplate template) {
        this.template = template;
    }
}
