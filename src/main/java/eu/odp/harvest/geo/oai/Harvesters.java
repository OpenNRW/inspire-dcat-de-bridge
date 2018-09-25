package eu.odp.harvest.geo.oai;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.util.ArrayList;

/**
 * Business class that represents a list of harvesters and can be marshalled to XML.
 */
@XmlRootElement
public class Harvesters {
    private ArrayList<Harvester> harvesters;

    /**
     * Default constructor.
     */
    public Harvesters() {
    }

    /**
     * Constructor.
     * @param harvesters list of harvesters
     */
    public Harvesters(ArrayList<Harvester> harvesters) {
        setHarvesters(harvesters);
    }

    /**
     * Gets the harvesters.
     * @return harvesters
     */
    @XmlElement(name = "harvester")
    public ArrayList<Harvester> getHarvesters() {
        return harvesters;
    }

    /**
     * Sets the harvesters.
     * @param harvesters harvesters
     */
    public void setHarvesters(ArrayList<Harvester> harvesters) {
        this.harvesters = harvesters;
    }
}
