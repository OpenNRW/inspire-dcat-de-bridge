package eu.odp.harvest.geo.oai;

/**
 * Exception thrown by the <class>HarvesterManager</class>.
 */
public class ManagerException extends RuntimeException {

    // used in the response as HTTP status code
    private final int statusCode;

    /**
     * Constructor
     * @param msg exception message
     * @param statusCode status code
     */
    public ManagerException(String msg, int statusCode) {
        super(msg);
        this.statusCode = statusCode;
    }

    /**
     * Returns the status code
     * @return status code
     */
    public int getStatusCode() {
        return statusCode;
    }
}
