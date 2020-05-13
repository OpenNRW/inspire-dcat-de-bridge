<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- transforms a CSW GetRecordsResponse to an OAI-PMH response -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml"
                xmlns:apiso="http://www.opengis.net/cat/apiso/1.0"
                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:ows="http://www.opengis.net/ows" xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:hydra="http://www.w3.org/ns/hydra/core#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:locn="http://www.w3.org/ns/locn#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:schema="http://schema.org/"
                xmlns:prov="http://www.w3.org/ns/prov#"
                xmlns:wdrs="http://www.w3.org/2007/05/powder-s#"
                xmlns:earl="http://www.w3.org/ns/earl#"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:cnt="http://www.w3.org/2011/content#"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:dcatde="http://dcat-ap.de/def/dcatde"
                xmlns:adms="http://www.w3.org/ns/adms#"
                xmlns:org="http://www.w3.org/ns/org#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope"
                exclude-result-prefixes="gmd gml apiso dc csw gco ows soap soap12">
    <xsl:import href="oai-pmhUtil.xsl"/>
    <xsl:import href="iso2dcat.xsl"/>

    <xsl:output method="xml"/>

    <!-- request parameters -->
    <xsl:param name="verb"  select="$verb_ListIdentifiers"/>
    <xsl:param name="identifier"/>
    <xsl:param name="metadataPrefix"/>
    <xsl:param name="from"/>
    <xsl:param name="until"/>
    <xsl:param name="set"/>
    <xsl:param name="resumptionToken"/>
    <xsl:param name="page"/>
    <xsl:param name="soapVersion"/>
    <xsl:param name="baseCatalogUri"/>

    <xsl:param name="response_date"/>

    <xsl:variable name="verb_lc">
        <xsl:call-template name="getVerb"/>
    </xsl:variable>

    <!--
    <xsl:strip-space elements="*"/>
    -->
    <xsl:template match="csw:GetRecordsResponse">
        <rdf:RDF>
            <dcat:Catalog>
                <xsl:apply-templates select="csw:SearchResults/gmd:MD_Metadata" mode="record"/>
            </dcat:Catalog>
            <xsl:call-template name="pagedCollection"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="pagedCollection">
        <xsl:variable name="numberOfRecordsMatched" select="number(csw:SearchResults/@numberOfRecordsMatched)"/>
        <xsl:variable name="currentPage">
            <xsl:choose>
                <xsl:when test="$page and number($page) > 1">
                    <xsl:value-of select="number($page)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="lastPage">
            <xsl:choose>
                <xsl:when test="$numberOfRecordsMatched > $recordsPerPage">
                    <xsl:value-of select="ceiling($numberOfRecordsMatched div $recordsPerPage)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <hydra:PagedCollection rdf:about="{$baseCatalogUri}?page={$currentPage}">
            <hydra:totalItems rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="$numberOfRecordsMatched"/></hydra:totalItems>
            <hydra:firstPage><xsl:value-of select="$baseCatalogUri"/>?page=1</hydra:firstPage>
            <hydra:lastPage><xsl:value-of select="$baseCatalogUri"/>?page=<xsl:value-of select="$lastPage"/></hydra:lastPage>
            <xsl:if test="$numberOfRecordsMatched > ($currentPage * $recordsPerPage)">
                <hydra:nextPage><xsl:value-of select="$baseCatalogUri"/>?page=<xsl:value-of select="$currentPage + 1"/></hydra:nextPage>
            </xsl:if>
            <xsl:if test="$currentPage > 1">
                <hydra:previousPage><xsl:value-of select="$baseCatalogUri"/>?page=<xsl:value-of select="$currentPage - 1"/></hydra:previousPage>
            </xsl:if>
            <hydra:itemsPerPage rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="$recordsPerPage"/></hydra:itemsPerPage>
        </hydra:PagedCollection>
    </xsl:template>

    <xsl:template match="csw:GetRecordsResponse[csw:SearchResults/@numberOfRecordsMatched &lt; 1]">
        <xsl:call-template name="error">
            <xsl:with-param name="errorCode">
                <xsl:choose>
                    <xsl:when test="$verb_lc = $verb_GetRecord">
                        <xsl:value-of select="'idDoesNotExist'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'noRecordsMatch'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="errorMessage">The target catalog has no matching records</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="gmd:MD_Metadata" mode="record">
        <dcat:dataset>
            <xsl:if test="$verb_lc != $verb_ListIdentifiers">
                <xsl:choose>
                    <xsl:when test="$metadataPrefix = $prefix_oai">
                        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
                                xmlns:dc="http://purl.org/dc/elements/1.1/"
                                xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
                            <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/*" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*[gmd:role/gmd:CI_RoleCode/@codeListValue='originator']/gmd:organisationName/*" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*/gmd:keyword/*" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:identificationInfo//gmd:abstract/*" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/*/gmd:date/*[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']/gmd:date/*" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:hierarchyLevel/gmd:MD_ScopeCode" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:name/*" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:fileIdentifier/*" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:identificationInfo/*/gmd:language/*" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:identificationInfo/*/*/*/gmd:geographicElement/*/gmd:geographicIdentifier/*/gmd:code/*" mode="oai_dc"/>
                            <xsl:apply-templates select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation/*|gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints/*/@codeListValue|gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints/*" mode="oai_dc"/>
                        </oai_dc:dc>
                    </xsl:when>
                    <xsl:when test="$metadataPrefix = $prefix_iso19139">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                            <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </dcat:dataset>
    </xsl:template>

    <xsl:template match="gmd:MD_Metadata" mode="header">
        <header xmlns="http://www.openarchives.org/OAI/2.0/">
            <identifier><xsl:value-of select="gmd:fileIdentifier/*"/></identifier>
            <datestamp><xsl:value-of select="gmd:dateStamp/*"/></datestamp>
        </header>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:citation/*/gmd:title/*" mode="oai_dc">
        <dc:title>
            <xsl:value-of select="."/>
        </dc:title>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*[gmd:role/gmd:CI_RoleCode/@codeListValue='originator']/gmd:organisationName/*" mode="oai_dc">
        <dc:creator>
            <xsl:value-of select="."/>
        </dc:creator>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:descriptiveKeywords/*/gmd:keyword/*" mode="oai_dc">
        <dc:subject>
            <xsl:value-of select="."/>
        </dc:subject>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo//gmd:abstract/*" mode="oai_dc">
        <dc:description>
            <xsl:value-of select="."/>
        </dc:description>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:citation/*/gmd:date/*[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']/gmd:date/*" mode="oai_dc">
        <dc:date>
            <xsl:value-of select="."/>
        </dc:date>
    </xsl:template>

    <xsl:template match="gmd:hierarchyLevel/gmd:MD_ScopeCode" mode="oai_dc">
        <dc:type>
            <xsl:value-of select="@codeListValue"/>
        </dc:type>
    </xsl:template>

    <xsl:template match="gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:name/*" mode="oai_dc">
        <dc:format>
            <xsl:value-of select="."/>
        </dc:format>
    </xsl:template>

    <xsl:template match="gmd:fileIdentifier/*" mode="oai_dc">
        <dc:identifier>
            <xsl:value-of select="."/>
        </dc:identifier>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:language/*" mode="oai_dc">
        <dc:language>
            <xsl:value-of select="@codeListValue"/>
        </dc:language>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/*/*/gmd:geographicElement/*/gmd:geographicIdentifier/*/gmd:code/*" mode="oai_dc">
        <dc:coverage>
            <xsl:value-of select="."/>
        </dc:coverage>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation/*|gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useConstraints/*/@codeListValue|gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints/*" mode="oai_dc">
        <dc:rights>
            <xsl:value-of select="."/>
        </dc:rights>
    </xsl:template>

    <xsl:template match="ows:ExceptionReport">
        <xsl:message terminate="yes">The CSW server returned an exception</xsl:message>
    </xsl:template>

    <xsl:template match="soap:Envelope|soap12:Envelope">
        <xsl:apply-templates select="soap:Body/*|soap12:Body/*"/>
    </xsl:template>

    <xsl:template match="soap:Fault|soap12:Fault">
        <xsl:message terminate="yes">The CSW server returned a SOAP Fault</xsl:message>
    </xsl:template>

</xsl:stylesheet>
