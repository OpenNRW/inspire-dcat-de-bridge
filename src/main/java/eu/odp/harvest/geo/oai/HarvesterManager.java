package eu.odp.harvest.geo.oai;

import org.apache.camel.CamelContext;
import org.apache.camel.CamelContextAware;
import org.apache.camel.Route;
import org.apache.camel.model.ModelCamelContext;
import org.apache.camel.model.RoutesDefinition;
import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Node;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Management class for new harvesters.
 * This class provides methods to create a list of harvesters from a list of parameter maps and
 * to validate parameters for new or updated harvesters.
 */
public class HarvesterManager implements CamelContextAware {

    // Logger
    private final static Logger LOG = Logger.getLogger(HarvesterManager.class);

    // Camel context to deploy harvester routes to
    private ModelCamelContext camelContext;

    // Regular expression that harvester IDs must match, can also be set via Spring config
    private String idRegex =  "^[a-zA-Z0-9\\-]*$";

    private String harvesterBaseUrl;

    /**
     * Creates the list of harvesters from a list of parameter maps.
     * @param mapList list of parameter maps
     * @return harvesters
     */
    public Harvesters createHarvesters(List<Map> mapList) {
        ArrayList<Harvester> harvesters = new ArrayList<Harvester>(mapList.size());
        for (Map map : mapList) {
            harvesters.add(createHarvester(map));
        }
        return new Harvesters(harvesters);
    }

    /**
     * Creates a single harvester instance.
     * @param mapList the list of results. Must be of size 1.
     * @return a harvester instance
     */
    public Harvester createHarvester(List<Map> mapList) {
        if (mapList.size() == 0) {
            throw new ManagerException("No such harvester", 404);
        }
        if (mapList.size() > 1) {
            throw new ManagerException("The request resulted in ambiguous response", 500);
        }
        return createHarvester(mapList.get(0));
    }

    private Harvester createHarvester(Map map) {
        Harvester harvester = new Harvester();
        harvester.setId((String) map.get("id"));
        harvester.setEndpoint(harvesterBaseUrl + harvester.getId());
        harvester.setType((String) map.get("type"));
        harvester.setUrl((String) map.get("url"));
        harvester.setDescription((String) map.get("description"));
        harvester.setName((String) map.get("name"));
        harvester.setSelective(((Number) map.get("selective")).intValue() != 0);
        return harvester;
    }

    /**
     * Validates parameters for a new or updated harvester.
     * @param id id of the harvester, will be part of the URL path
     * @param type type of the harvester, must be a known Camel route
     * @param url URL of the target catalog
     */
    public void validateParams(String id, String type, String url) {
        if (id == null || id.isEmpty() || ! id.matches(idRegex)) {
            throw new ManagerException("Please specify a valid ID that matches the regular expression " +
                    idRegex, 400);
        }
        if (camelContext.getEndpoint(type) == null) {
            throw new ManagerException("No such harvester type: " + type, 400);
        }
        try {
            URL tmp = new URL(url);
        } catch (MalformedURLException e) {
            throw new ManagerException("The URL is invalid: " + e.getMessage(), 400);
        }
    }

    @Override
    public void setCamelContext(CamelContext camelContext) {
        if (LOG.isDebugEnabled()) {
            LOG.debug("Setting camel context to " + camelContext);
        }
        this.camelContext = (ModelCamelContext) camelContext;
    }

    @Override
    public CamelContext getCamelContext() {
        return camelContext;
    }

    /**
     * Sets the regular expression that checks if a new harvester ID is valid
     * @param idRegex regular expression
     */
    public void setIdRegex(String idRegex) {
        this.idRegex = idRegex;
    }

    public void setHarvesterBaseUrl(String harvesterBaseUrl) {
        if (! harvesterBaseUrl.endsWith("/")) {
            harvesterBaseUrl = harvesterBaseUrl + "/";
        }
        this.harvesterBaseUrl = harvesterBaseUrl;
    }
}
