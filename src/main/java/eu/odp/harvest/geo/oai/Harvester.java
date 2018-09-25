package eu.odp.harvest.geo.oai;

import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

/**
 * Business class that represents a harvester and can be marshalled to XML.
 */
@XmlRootElement
@XmlType(propOrder={"id","endpoint","type","name","description","url","selective"})
public class Harvester {
    String id;
    String endpoint;
    String type;
    String name;
    String description;
    String url;
    boolean selective;

    /**
     * Gets the ID.
     * @return id
     */
    public String getId() {
        return id;
    }

    /**
     * Sets the ID.
     * @param id id
     */
    public void setId(String id) {
        this.id = id;
    }

    /**
     * Gets the HTTP endpoint where this harvester is available.
     * @return enpoint URL
     */
    public String getEndpoint() {
        return endpoint;
    }

    /**
     * Sets the HTTP endpoint where this harvester is available.
     * @param endpoint endpoint URL
     */
    public void setEndpoint(String endpoint) {
        this.endpoint = endpoint;
    }

    /**
     * Gets the type of the harvester, e.g inspire.
     * @return type
     */
    public String getType() {
        return type;
    }

    /**
     * Sets the type of the harvester, e.g. inspire.
     * @param type type
     */
    public void setType(String type) {
        this.type = type;
    }

    /**
     * Gets the URL of the target catalog
     * @return URL of the target catalog
     */
    public String getUrl() {
        return url;
    }

    /**
     * Sets the URL of the target catalog.
     * @param url URL of the target catalog
     */
    public void setUrl(String url) {
        this.url = url;
    }

    /**
     * Gets the description.
     * @return description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Sets the description
     * @param description description
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * Gets the name.
     * @return name
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the name
     * @param name name
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Gets flag if the catalog supports selective harvesting.
     * @return true, if selective harvesting is supported
     */
    public boolean isSelective() {
        return selective;
    }

    /**
     * Sets flag if the catalog supports selective harvesting.
     * @param selective flag
     */
    public void setSelective(boolean selective) {
        this.selective = selective;
    }
}
