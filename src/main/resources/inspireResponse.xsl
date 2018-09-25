<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- transforms a CSW GetRecordsResponse to an OAI-PMH response -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml"
                xmlns:apiso="http://www.opengis.net/cat/apiso/1.0"
                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:ows="http://www.opengis.net/ows" xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:gco="http://www.isotc211.org/2005/gco"
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
    <xsl:param name="soapVersion"/>

    <xsl:param name="response_date"/>

    <xsl:variable name="verb_lc">
        <xsl:call-template name="getVerb"/>
    </xsl:variable>

    <!--
    <xsl:strip-space elements="*"/>
    -->
    <xsl:template match="csw:GetRecordsResponse">
        <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
            <responseDate><xsl:value-of select="$response_date"/></responseDate>
            <request>
                <xsl:call-template name="requestAttributes"/>
                <xsl:value-of select="$base_url"/>
            </request>
            <xsl:choose>
                <xsl:when test="$verb_lc = $verb_ListRecords">
                    <ListRecords>
                        <xsl:apply-templates select="csw:SearchResults/gmd:MD_Metadata" mode="record"/>
                        <xsl:call-template name="resumptionToken"/>
                    </ListRecords>
                </xsl:when>
                <xsl:when test="$verb_lc = $verb_ListIdentifiers">
                    <ListIdentifiers>
                        <xsl:apply-templates select="csw:SearchResults/gmd:MD_Metadata" mode="header"/>
                        <xsl:call-template name="resumptionToken"/>
                    </ListIdentifiers>
                </xsl:when>
                <xsl:otherwise>
                    <GetRecord>
                        <xsl:apply-templates select="csw:SearchResults/gmd:MD_Metadata" mode="record"/>
                    </GetRecord>
                </xsl:otherwise>
            </xsl:choose>
        </OAI-PMH>
    </xsl:template>

    <xsl:template name="resumptionToken">
        <xsl:variable name="numberOfRecordsMatched" select="number(csw:SearchResults/@numberOfRecordsMatched)"/>
        <xsl:choose>
            <xsl:when test="not($resumptionToken) and count(csw:SearchResults/*) &lt; $numberOfRecordsMatched">
                <resumptionToken xmlns="http://www.openarchives.org/OAI/2.0/" cursor="1" completeListSize="{$numberOfRecordsMatched}">
                    <xsl:value-of select="concat(count(csw:SearchResults/*) + 1,
                        $token_sep, $metadataPrefix, $token_sep, $from, $token_sep, $until)"/>
                </resumptionToken>
            </xsl:when>
            <xsl:when test="not($resumptionToken)">
                <resumptionToken xmlns="http://www.openarchives.org/OAI/2.0/" cursor="1" completeListSize="{$numberOfRecordsMatched}"/>
            </xsl:when>
            <xsl:when test="$resumptionToken">
                <resumptionToken xmlns="http://www.openarchives.org/OAI/2.0/" cursor="{number(substring-before($resumptionToken, $token_sep))}" completeListSize="{$numberOfRecordsMatched}">
                    <xsl:if test="count(csw:SearchResults/*) + number(substring-before($resumptionToken, $token_sep)) - 1 &lt; $numberOfRecordsMatched">
                        <xsl:value-of select="concat(count(csw:SearchResults/*) + number(substring-before($resumptionToken, $token_sep)),
                            $token_sep, substring-after($resumptionToken, $token_sep))"/>
                    </xsl:if>
                </resumptionToken>
            </xsl:when>
        </xsl:choose>
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
        <record xmlns="http://www.openarchives.org/OAI/2.0/">
            <xsl:apply-templates mode="header" select="."/>
            <xsl:if test="$verb_lc != $verb_ListIdentifiers">
                <metadata>
                    <xsl:choose>
                        <xsl:when test="$metadataPrefix = $prefix_oai or contains($resumptionToken, $prefix_oai)">
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
                        <xsl:when test="$metadataPrefix = $prefix_iso19139 or contains($resumptionToken, $prefix_iso19139)">
                            <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                             <xsl:apply-templates select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </metadata>
            </xsl:if>
        </record>
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
