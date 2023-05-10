# open.nrw-fassaden (Version: 2.0.0)
Facades for open.nrw: Provide CKAN data to the catalog service of the Geoportal and vice versa.

##### Overview

* Provides an OAI-PMH interface to harvest ISO 19139 metadata from CSW (INSPIRE catalogs) and returns it in DCAT-AP.de 2.0 schema as used in Open.NRW
* Provides a DCAT-AP.de RDF XML catalog interface to harvest ISO 19139 metadata from CSW (INSPIRE catalogs)
* Provides an OAI-PMH interface to harvest DCAT-AP.de 2.0 metadata from CKAN and returns it in ISO 19139 schema
* Can be directly started using an embedded Tomcat server, or deployed as a web application in Java servlet container
* Implementation is based on Apache Camel

##### Requirements

* JRE 11
* Tomcat 9 (only when deploying in an external Tomcat installation)

##### Building with Apache Maven

1. cd to the root folder of this project (the folder that contains the pom.xml and this readme)
2. from the command line run

        > mvn clean package

##### Deployment

Use your preferred method to deploy the webapp in Tomcat, e.g.:

* Copy the war file to the Tomcat webapps folder
* Create a context file in the Tomcat host folder

##### Start Application with embedded Tomcat

Instead a deployment in an external Tomcat installation it is also possible to start the application in an embedded Tomcat with the Spring Boot Application. In the following example the embedded Tomcat will be started on port 8089

        /usr/bin/java -jar inspire-bridge.war --server.port=8089

##### Configuration

Logging can be configured with the log4j framework (see http://logging.apache.org/log4j/1.2/).
By default a logfile is created here: /var/log/inspire-bridge/inspire-bridge.log.
The default location of the log file can be overwritten in the build.properties.

In general, configuration is done via Spring properties. The parameters can be changed after deployment in the file camel-oai-pmh.properties. It is also possible to add a configuration file at `/opt/app/inspire-bridge/config/camel-oai-pmh.properties`. This is useful in combination with the embedded Tomcat, because the configuration file on classpath is within the war file. The properties defined in the configuration file in the classpath will be overridden.

The available parameters in the camel-oai-pmh.properties file are:

* oai-pmh.base.url.external: URL that external clients use to access the OAI-PMH interface web application
* oai-pmh.rdf.catalog.base.url: Endpoint where the DCAT-AP.de RDF catalog should be reachable
* oai-pmh.dcatde.contributorID: [dcatde:contributorID](https://www.dcat-ap.de/def/contributors/) which is to be inserted in all DCAT datasets
* oai-pmh.csw.serviceShowMetadata.URL: Base URL for the `rdf:about` attribute of DCAT Dataset elements. The URL may contain a placeholder of the form `%uid%`, which gets replaced by the dataset ID. If there is no placeholder, the ID gets appended with a "#".
* oai-pmh.db.item.csw.TYPE: should be one of inspire, inspireSoap11 or inspireSoap11, depending on the protocol of the Geoportal
* oai-pmh.db.item.csw.URL: GetRecords URL of the geoportal to be harvested
* oai-pmh.db.item.csw.sortResults: toggle whether the results should be sorted or not. Possible values are `true` and `false`. Defaults to `false`.
* oai-pmh.db.item.ckan.TYPE: currently only ckan is supported
* oai-pmh.db.item.ckan.URL: CKAN catalog URL to be harvested

If you build with the env-dev profile, you can also set some parameters during build, by including a build.poperties
file in the module base directory. Please check the pom.xml and camel-oai-pmh.properties
to see how parameters are set.

## Usage

##### OAI-PMH

Each Facades is exposed by a distinct HTTP endpoint. The endpoints are reached with this URL pattern:

        <tomcat-base-url><webapp-path>/omdf/<harvester>?<verb=operation>&<OPTIONAL argument>

So for example if tomcat-base-url is "http://localhost:8080", webapp-path is "/" and
you have a harvester "gp-csw" for the Geoportal, you can reach it with this URL:

        http://localhost:8080/omdf/gp-csw

a harvester "gp-ckan" for the NRW open data portal:

        http://localhost:8080/omdf/gp-ckan

You can issue OAI-PMH requests to all of the available endpoints. All endpoints support the same set of operations.

Supported operations:
* <b>ListIdentifiers</b>: This verb is used to retrieve the identifiers of records that can be harvested from a repository.  Optional arguments permit selectivity of the identifiers - based on their membership in a specific Set in the repository or based on their modification, creation, or deletion within a specific date range.
* <b>ListRecords</b>: This verb is used to harvest records from a repository. Optional arguments permit selective harvesting of records based on set membership and/or datestamp. Depending on the repository's support for deletions, a returned header may have a status attribute of "deleted" if a record matching the arguments specified in the request has been deleted. No metadata will be present for records with deleted status.
* <b>GetRecord</b>: This verb is used to retrieve an individual metadata record from a repository. Required arguments specify the identifier of the item from which the record is requested and the format of the metadata that should be included in the record. Depending on the level at which a repository tracks deletions, a header with a "deleted" value for the status attribute may be returned, in case the metadata format specified by the metadataPrefix is no longer available from the repository or from the specified item.

Operations arguments:
* <b>ListIdentifiers</b>
    * <b>from</b> an OPTIONAL argument with a date value, which specifies that only the unique identifiers of records with a datestamp that is more recent than or equal to the specified date should be returned.
    * <b>until</b> an OPTIONAL argument with a date value, which specifies that only the unique identifiers of records with a datestamp older than or equal to the specified date should be returned.
    * <b>resumptionToken</b> an EXCLUSIVE argument with a value that is the flow control token returned by a previous ListIdentifiers request that issued a partial response.
        * Example:<br>
                http://localhost:8080/omdf/gp-csw?verb=ListIdentifiers&from=2018-06-26&until=2018-07-01<br>
                http://localhost:8080/omdf/gp-ckan?verb=ListIdentifiers&from=2018-06-26

* <b>ListRecords</b>
    * <b>from</b> an optional argument with a UTCdatetime value, which specifies a lower bound for datestamp-based selective harvesting.
    * <b>until</b> an optional argument with a UTCdatetime value, which specifies a upper bound for datestamp-based selective harvesting.
    * <b>resumptionToken</b> an EXCLUSIVE argument with a value that is the flow control token returned by a previous ListIdentifiers request that issued a partial response.
        * Example:<br>
                http://localhost:8080/omdf/gp-csw?verb=ListRecords&from=2018-06-26&until=2018-07-01<br>
                http://localhost:8080/omdf/gp-ckan?verb=ListRecords&from=2018-06-26

* <b>GetRecord</b>
    * <b>identifier</b> a required argument that specifies the unique identifier of the item in the repository from which the record must be disseminated.
        * Example:<br>
                http://localhost:8080/omdf/gp-csw?verb=GetRecord&identifier=2c0b2365-347e-44aa-a1c8-a67b7ca5328e<br>
                http://localhost:8080/omdf/gp-ckan?verb=GetRecord&identifier=d04a7b1e-3e60-4591-b04c-94912ac54afe

##### DCAT-AP.de catalog

In addition to the OAI-PMH endpoints, a DCAT-AP.de RDF XML catalog is available. It is exposed at the endpoint `gp-csw/catalog.rdf`. The URL which is to be included in the catalog (e.g. for paging) can be configured in `rdf.catalog.base.url`. This should be the URL from which the catalog is externally reachable.

With the default properties, you can access the catalog on

        http://localhost:8080/omdf/gp-csw/catalog.rdf

The records are fetched in the same way and from the same portal as for the OAI-PMH endpoint. Only the output format is
different, such that it can be used with a DCAT-AP.de RDF harvester.

##### Further Reading

* http://www.openarchives.org/OAI/openarchivesprotocol.html
* http://www.w3.org/TR/vocab-dcat/
* https://joinup.ec.europa.eu/asset/dcat_application_profile/description
* https://joinup.ec.europa.eu/asset/dcat_application_profile/asset_release/geodcat-ap-v10
* http://camel.apache.org/

