<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- transforms an OAI-PMH request to a GetRecords request or directly to a response, if possible (e.g. errors) -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ogc="http://www.opengis.net/ogc"
                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
        exclude-result-prefixes="xs">

    <xsl:output method="xml"/>

    <!-- request parameters -->
    <xsl:param name="resourceIdentifiers" as="xs:string"/>
    <xsl:param name="soapVersion" as="xs:string" select="''"/>
    <xsl:param name="hopCount"/>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$soapVersion = '1.1'">
                <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                    <soapenv:Body>
                        <xsl:call-template name="processRequest"/>
                    </soapenv:Body>
                </soapenv:Envelope>
            </xsl:when>
            <xsl:when test="$soapVersion = '1.2'">
                <soap12:Envelope xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
                    <soap12:Body>
                        <xsl:call-template name="processRequest"/>
                    </soap12:Body>
                </soap12:Envelope>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="processRequest"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="processRequest">
        <csw:GetRecords startPosition="1" maxRecords="500" outputFormat="application/xml"
                        resultType="results" service="CSW" version="2.0.2"
                        outputSchema="http://www.isotc211.org/2005/gmd">
            <xsl:if test="number($hopCount) > 0">
                <csw:DistributedSearch hopCount="{$hopCount}"/>
            </xsl:if>
            <csw:Query typeNames="gmd:MD_Metadata" xmlns:gmd="http://www.isotc211.org/2005/gmd">
                <csw:ElementSetName>full</csw:ElementSetName>
                <csw:Constraint version="1.1.0">
                    <ogc:Filter>
                        <xsl:variable name="ids" select="tokenize(replace($resourceIdentifiers, '%23', '#'), '\|')"/>
                        <xsl:choose>
                            <xsl:when test="count($ids) = 1">
                                <ogc:PropertyIsEqualTo>
                                    <ogc:PropertyName xmlns:apiso="http://www.opengis.net/cat/apiso/1.0">apiso:operatesOn</ogc:PropertyName>
                                    <ogc:Literal><xsl:value-of select="$ids[1]"/></ogc:Literal>
                                </ogc:PropertyIsEqualTo>
                            </xsl:when>
                            <xsl:otherwise>
                                <ogc:Or>
                                    <xsl:for-each select="$ids">
                                        <ogc:PropertyIsEqualTo>
                                            <ogc:PropertyName xmlns:apiso="http://www.opengis.net/cat/apiso/1.0">apiso:operatesOn</ogc:PropertyName>
                                            <ogc:Literal><xsl:value-of select="."/></ogc:Literal>
                                        </ogc:PropertyIsEqualTo>
                                    </xsl:for-each>
                                </ogc:Or>
                            </xsl:otherwise>
                        </xsl:choose>
                    </ogc:Filter>
                </csw:Constraint>
            </csw:Query>
        </csw:GetRecords>
    </xsl:template>
</xsl:stylesheet>
