package eu.odp.harvest.geo.oai;

import org.apache.camel.Exchange;
import org.apache.camel.Message;
import org.apache.camel.Processor;
import org.apache.log4j.Logger;

import java.util.Map;

/**
 * Creates the OpenSearch URL by instantiating the template URL.
 */
public class OsParameterProcessor implements Processor {

    private final static String START_INDEX_TEMPLATE = "{startIndex?}";
    private final static String START_PAGE_TEMPLATE = "{startPage?}";

    // Logger
    private final static Logger LOG = Logger.getLogger(OsParameterProcessor.class);

    @Override
    public void process(Exchange exchange) throws Exception {
        Message in = exchange.getIn();
        Map<String, Object> headers = in.getHeaders();
        String urlTemplate = (String) headers.get(Exchange.HTTP_URI);
        if (urlTemplate == null) {
            LOG.warn("No CamelHttpUri set on message");
            return;
        }
        int index = urlTemplate.indexOf('?');
        if (index < 0) {
            LOG.warn("No query parameters in template URL");
            return;
        }
        headers.put(Exchange.HTTP_URI, urlTemplate.substring(0, index));
        String httpQuery = urlTemplate.substring(index + 1);
        if (httpQuery.contains(START_INDEX_TEMPLATE)) {
            headers.put(Exchange.HTTP_QUERY, httpQuery.replace(START_INDEX_TEMPLATE, in.getBody().toString()));
        }
        else if (httpQuery.contains(START_PAGE_TEMPLATE)) {
            headers.put(Exchange.HTTP_QUERY, httpQuery.replace(START_PAGE_TEMPLATE, in.getBody().toString()));
        }
        else {
            LOG.warn("No template parameters to replace");
        }
    }
}
