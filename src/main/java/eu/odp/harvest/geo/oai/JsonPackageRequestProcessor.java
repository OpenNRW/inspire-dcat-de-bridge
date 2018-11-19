package eu.odp.harvest.geo.oai;

import org.apache.camel.Exchange;
import org.apache.camel.Message;
import org.apache.camel.Processor;

public class JsonPackageRequestProcessor implements Processor {
    @Override
    public void process(Exchange exchange) throws Exception {
        Message in = exchange.getIn();
        String verb = in.getHeader("verb", String.class);
        if ("ListRecords".equals(verb)) {

        }
        else if ("GetRecord".equals(verb)) {

        }
        else if ("ListIdentifiers".equals(verb)) {

        }
        else {
        }
    }
}
