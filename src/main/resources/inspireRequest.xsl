<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- transforms an OAI-PMH request to a GetRecords request or directly to a response, if possible (e.g. errors) -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ogc="http://www.opengis.net/ogc"
                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
        exclude-result-prefixes="ogc csw">

    <xsl:import href="oai-pmhUtil.xsl"/>

    <xsl:output method="xml"/>

    <!-- request parameters -->
    <xsl:param name="verb"/>
    <xsl:param name="identifier"/>
    <xsl:param name="metadataPrefix"/>
    <xsl:param name="from"/>
    <xsl:param name="until"/>
    <xsl:param name="set"/>
    <xsl:param name="resumptionToken"/>
    <xsl:param name="page"/>
    <xsl:param name="soapVersion"/>

    <xsl:param name="response_date"/>

    <xsl:variable name="verb_lc">
        <xsl:call-template name="getVerb"/>
    </xsl:variable>

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
        <xsl:choose>
            <xsl:when test="$verb_lc = 'ListSets'">
                <xsl:call-template name="listSets"/>
            </xsl:when>
            <xsl:when test="$verb_lc = $verb_ListRecords or $verb_lc = $verb_ListIdentifiers">
                <xsl:call-template name="listRecords"/>
            </xsl:when>
            <xsl:when test="$verb_lc = $verb_GetRecord">
                <xsl:call-template name="getRecord"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="error">
                    <xsl:with-param name="errorMessage">Bad or missing verb</xsl:with-param>
                    <xsl:with-param name="errorCode">badVerb</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="listSets">
        <xsl:call-template name="error">
            <xsl:with-param name="errorMessage">Sets not supported</xsl:with-param>
            <xsl:with-param name="errorCode">noSetHierarchy</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="getRecord">
        <xsl:choose>
            <xsl:when test="$metadataPrefix != $prefix_eurodcat and $metadataPrefix != $prefix_dcat and $metadataPrefix != $prefix_oai and $metadataPrefix != $prefix_iso19139 and $metadataPrefix != $prefix_geodcat">
                <xsl:call-template name="error">
                    <xsl:with-param name="errorCode">badArgument</xsl:with-param>
                    <xsl:with-param name="errorMessage">Bad argument: metadataPrefix</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not($identifier)">
                <xsl:call-template name="error">
                    <xsl:with-param name="errorCode">badArgument</xsl:with-param>
                    <xsl:with-param name="errorMessage">Missing argument: identifier</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getRecords">
                    <xsl:with-param name="identifierParam" select="$identifier"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="listRecords">
        <xsl:choose>
            <xsl:when test="not($resumptionToken) and $metadataPrefix != $prefix_eurodcat and $metadataPrefix != $prefix_dcat and $metadataPrefix != $prefix_oai and $metadataPrefix != $prefix_iso19139 and $metadataPrefix != $prefix_geodcat">
                <xsl:call-template name="error">
                    <xsl:with-param name="errorCode">cannotDisseminateFormat</xsl:with-param>
                    <xsl:with-param name="errorMessage">Cannot disseminate format specified by metadataPrefix</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$set">
                <xsl:call-template name="error">
                    <xsl:with-param name="errorCode">noSetHierarchy</xsl:with-param>
                    <xsl:with-param name="errorMessage">Sets not supported</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$resumptionToken">
                <xsl:variable name="startPosition" select="number(substring-before($resumptionToken, ':'))"/>
                <xsl:variable name="tokenPrefix" select="substring-before(substring-after($resumptionToken, ':'), ':')"/>
                <xsl:variable name="tokenFrom" select="substring-before(substring-after(substring-after($resumptionToken, ':'), ':'), ':')"/>
                <xsl:variable name="tokenUntil" select="substring-after(substring-after(substring-after($resumptionToken, ':'), ':'), ':')"/>
                <xsl:choose>
                    <xsl:when test="string($startPosition) = 'NaN' or $startPosition &lt; 1">
                        <xsl:call-template name="badResumptionToken"/>
                    </xsl:when>
                    <xsl:when test="$tokenPrefix != $prefix_oai and $metadataPrefix != $prefix_eurodcat and $tokenPrefix != $prefix_dcat and $tokenPrefix != $prefix_iso19139 and $tokenPrefix != $prefix_geodcat">
                        <xsl:call-template name="badResumptionToken"/>
                    </xsl:when>
                    <xsl:when test="$tokenFrom and (string-length($tokenFrom) != 10 or string(number(substring-before($tokenFrom, '-'))) = 'NaN')">
                        <xsl:call-template name="badResumptionToken"/>
                    </xsl:when>
                    <xsl:when test="$tokenUntil and (string-length($tokenUntil) != 10 or string(number(substring-before($tokenUntil, '-'))) = 'NaN')">
                        <xsl:call-template name="badResumptionToken"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getRecords">
                            <xsl:with-param name="startPosition" select="$startPosition"/>
                            <xsl:with-param name="fromParam" select="$tokenFrom"/>
                            <xsl:with-param name="untilParam" select="$tokenUntil"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$page and number($page) > 1">
                <xsl:variable name="startPosition" select="((number($page) - 1) * $recordsPerPage) + 1"/>
                <xsl:call-template name="getRecords">
                    <xsl:with-param name="startPosition" select="$startPosition"/>
                    <xsl:with-param name="fromParam" select="$from"/>
                    <xsl:with-param name="untilParam" select="$until"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getRecords">
                    <xsl:with-param name="fromParam" select="$from"/>
                    <xsl:with-param name="untilParam" select="$until"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getRecords">
        <xsl:param name="startPosition">1</xsl:param>
        <xsl:param name="fromParam"/>
        <xsl:param name="untilParam"/>
        <xsl:param name="identifierParam"/>
        <csw:GetRecords
                        startPosition="{$startPosition}" maxRecords="{$recordsPerPage}" outputFormat="application/xml"
                        resultType="results" service="CSW" version="2.0.2"
                        outputSchema="http://www.isotc211.org/2005/gmd">
            <csw:Query typeNames="gmd:MD_Metadata" xmlns:gmd="http://www.isotc211.org/2005/gmd">
                <csw:ElementSetName>full</csw:ElementSetName>
                <csw:Constraint version="1.1.0">
                    <ogc:Filter>
                        <xsl:choose>
                            <xsl:when test="$identifierParam">
                                <ogc:PropertyIsEqualTo>
                                    <ogc:PropertyName xmlns:apiso="http://www.opengis.net/cat/apiso/1.0">apiso:identifier</ogc:PropertyName>
                                    <ogc:Literal><xsl:value-of select="$identifierParam"/></ogc:Literal>
                                </ogc:PropertyIsEqualTo>
                            </xsl:when>
                            <xsl:otherwise>
                                <ogc:And>
                                    <ogc:PropertyIsEqualTo>
                                        <ogc:PropertyName xmlns:apiso="http://www.opengis.net/cat/apiso/1.0">apiso:subject</ogc:PropertyName>
                                        <ogc:Literal>opendata</ogc:Literal>
                                    </ogc:PropertyIsEqualTo>
                                    <xsl:call-template name="fromFilter">
                                        <xsl:with-param name="fromParam" select="$fromParam"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="untilFilter">
                                        <xsl:with-param name="untilParam" select="$untilParam"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="typeFilter"/>
                                </ogc:And>
                            </xsl:otherwise>
                        </xsl:choose>
                    </ogc:Filter>
                </csw:Constraint>
            </csw:Query>
        </csw:GetRecords>
    </xsl:template>

    <xsl:template name="typeFilter">
        <ogc:Or>
            <ogc:PropertyIsEqualTo>
                <ogc:PropertyName xmlns:apiso="http://www.opengis.net/cat/apiso/1.0">apiso:Type</ogc:PropertyName>
                <ogc:Literal>dataset</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
                <ogc:PropertyName xmlns:apiso="http://www.opengis.net/cat/apiso/1.0">apiso:Type</ogc:PropertyName>
                <ogc:Literal>datasetCollection</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
                <ogc:PropertyName xmlns:apiso="http://www.opengis.net/cat/apiso/1.0">apiso:Type</ogc:PropertyName>
                <ogc:Literal>series</ogc:Literal>
            </ogc:PropertyIsEqualTo>
        </ogc:Or>
    </xsl:template>

    <xsl:template name="fromFilter">
        <xsl:param name="fromParam"/>
        <xsl:if test="$fromParam">
            <ogc:PropertyIsGreaterThanOrEqualTo>
                <ogc:PropertyName xmlns:apiso="http://www.opengis.net/cat/apiso/1.0">apiso:Modified</ogc:PropertyName>
                <ogc:Literal><xsl:value-of select="$fromParam"/></ogc:Literal>
            </ogc:PropertyIsGreaterThanOrEqualTo>
        </xsl:if>
    </xsl:template>

    <xsl:template name="untilFilter">
        <xsl:param name="untilParam"/>
        <xsl:if test="$untilParam">
            <ogc:PropertyIsLessThanOrEqualTo>
                <ogc:PropertyName xmlns:apiso="http://www.opengis.net/cat/apiso/1.0">apiso:Modified</ogc:PropertyName>
                <ogc:Literal><xsl:value-of select="$untilParam"/></ogc:Literal>
            </ogc:PropertyIsLessThanOrEqualTo>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
