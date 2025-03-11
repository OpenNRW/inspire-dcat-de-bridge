<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- transforms a CSW GetRecordsResponse to an OAI-PMH response -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml"
                xmlns:apiso="http://www.opengis.net/cat/apiso/1.0"
                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:ows="http://www.opengis.net/ows" xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:hydra="http://www.w3.org/ns/hydra/core#"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
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
                <xsl:apply-templates select="csw:SearchResults/gmd:MD_Metadata" mode="dataset"/>
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

    <xsl:template match="gmd:MD_Metadata" mode="dataset">
        <dcat:dataset>
            <xsl:apply-templates select="."/>
        </dcat:dataset>
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
