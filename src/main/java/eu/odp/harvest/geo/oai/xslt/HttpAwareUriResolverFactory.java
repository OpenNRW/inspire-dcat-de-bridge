package eu.odp.harvest.geo.oai.xslt;

import org.apache.camel.CamelContext;
import org.apache.camel.component.xslt.XsltUriResolverFactory;

import javax.xml.transform.URIResolver;

public class HttpAwareUriResolverFactory implements XsltUriResolverFactory {
    public URIResolver createUriResolver(CamelContext camelContext, String resourceUri) {
        return new HttpAwareUriResolver(camelContext, resourceUri);
    }
}
