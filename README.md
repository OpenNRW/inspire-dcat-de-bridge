# open.nrw-fassaden (Version: 1.0.0-SNAPSHOT)
Facades for open.nrw: Provide CKAN data to the catalog service of the Geoportal and vice versa.

##### Overview

* Provides an OAI-PMH interface to harvest ISO 19139 metadata from CSW (INSPIRE catalogs) and returns it in DCAT-AP.DE 1.0.1 schema as used in Open.NRW
* Provides a DCAT-AP.de RDF XML catalog interface to harvest ISO 19139 metadata from CSW (INSPIRE catalogs)
* Provides an OAI-PMH interface to harvest DCAT-AP.DE 1.0.1 metadata from CKAN and returns it in ISO 19139 schema (STILL WORK IN PROGRESS)
* Deployed as a web application in Java servlet container
* Implementation is based on Apache Camel

##### Requirements

* JRE 8
* Tomcat 8

##### Building with Apache Maven

1. cd to the root folder of this project (the folder that contains the pom.xml and this readme)
2. from the command line run

        > mvn clean package

##### Deployment

Use your preferred method to deploy the webapp in Tomcat, e.g.:

* Copy the war file to the Tomcat webapps folder
* Create a context file in the Tomcat host folder

##### Configuration

Logging can be configured with the log4j framework (see http://logging.apache.org/log4j/1.2/).
By default a logfile is created here: tomcat/logs/open-nrw-ci-fassaden.log.

If you build with the env-dev profile, you can set your parameters during build, by including a build.poperties
file in the modile base directory. Please check the pom.xml
to see how parameters are set. The parameters can be changed after deployment in the file
camel-oai-pmh.properties. The available parameters are:

* oai-pmh.base.url.external: URL that external clients use to access the OAI-PMH interface web application
* rdf.catalog.base.url: Endpoint where the DCAT-AP.de RDF catalog should be reachable
* dcatde.contributorID: [dcatde:contributorID](https://www.dcat-ap.de/def/contributors/) which is to be inserted in all DCAT datasets
* db.item.csw.TYPE: should be one of inspire, inspireSoap11 or inspireSoap11, depending on the protocol of the Geoportal
* db.item.csw.URL: GetRecords URL of the geoportal to be harvested
* db.item.ckan.TYPE: currently only ckan is supported
* db.item.ckan.URL: CKAN catalog URL to be harvested

Note on HTTPS: There are a few catalogs that use HTTPS connections. However, some use self-signed certificates, or
certificates from a CA that is not trusted by the JVM per default. In order to allow integration of such catalogs,
the Facades trusts all server certificates. Of course this is insecure, as it makes the harvester vulnerable
to man-in-the-middle attacks. But the same is true for catalogs that are connected via plain HTTP (ca. 90% of
catalogs), so this vulnerability is inherent as long as HTTP connections are allowed.
If you require trusted connections via HTTPS, just remove the bean
eu.odp.harvest.geo.oai.http.AllowAllHttpClientConfig from the Apache Camel Spring configuration
(/WEB-INF/classes/camel-oai-pmh.xml).

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
different, such that it can used with a DCAT-AP.de RDF harvester.

##### Further Reading

* http://www.openarchives.org/OAI/openarchivesprotocol.html
* http://www.w3.org/TR/vocab-dcat/
* https://joinup.ec.europa.eu/asset/dcat_application_profile/description
* https://joinup.ec.europa.eu/asset/dcat_application_profile/asset_release/geodcat-ap-v10
* http://camel.apache.org/

