<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- transforms a CSW GetRecordsResponse to an OAI-PMH response -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml"
                xmlns:apiso="http://www.opengis.net/cat/apiso/1.0"
                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:ows="http://www.opengis.net/ows" xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope"
                exclude-result-prefixes="gmd gml apiso dc csw gco ows soap soap12">
    <xsl:import href="iso2dcat.xsl"/>

    <xsl:output method="xml"/>

    <xsl:template match="csw:GetRecordsResponse">
        <xsl:apply-templates select="csw:SearchResults/gmd:MD_Metadata" />
    </xsl:template>

    <xsl:template match="csw:GetRecordsResponse[csw:SearchResults/@numberOfRecordsMatched &lt; 1]">
        <error>not found</error>
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
