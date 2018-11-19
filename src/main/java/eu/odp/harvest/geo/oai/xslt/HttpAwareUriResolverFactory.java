package eu.odp.harvest.geo.oai.xslt;

import org.apache.camel.CamelContext;
//import org.apache.camel.builder.xml.XsltUriResolver;
//import org.apache.camel.component.xslt.DefaultXsltUriResolverFactory;

import javax.xml.transform.URIResolver;

public class HttpAwareUriResolverFactory  {
    public URIResolver createUriResolver(CamelContext camelContext, String resourceUri) {
//        return new HttpAwareUriResolver(camelContext, resourceUri);
        return null;
    }
}
