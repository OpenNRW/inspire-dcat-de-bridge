<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    xmlns:dcat="http://www.w3.org/ns/dcat#"
    expand-text="yes"
    version="3.0">
    
    <xsl:import href="oai-pmhUtil.xsl"/>
    <xsl:import href="dcat2iso.xsl"/>
    
    <!-- request parameters -->
    <xsl:param name="verb"  select="$verb_ListIdentifiers"/>
    <xsl:param name="identifier"/>
    <xsl:param name="metadataPrefix"/>
    <xsl:param name="from"/>
    <xsl:param name="until"/>
    <xsl:param name="set"/>
    <xsl:param name="resumptionToken"/>
    <xsl:param name="soapVersion"/>
    <xsl:param name="response_date" select="current-dateTime()"/>
    <xsl:param name="json"/>

    <xsl:variable name="response" select="json-to-xml($json)"/>
    <xsl:variable name="total" select="number($response/j:map/j:map[@key='result']/j:number[@key = 'count'])" as="xs:double"/>
    
    <xsl:variable name="verb_lc">
        <xsl:call-template name="getVerb"/>
    </xsl:variable>    
    
    <xsl:template match="/">
        <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
            <responseDate>{current-dateTime()}</responseDate>
            <request>
                <xsl:call-template name="requestAttributes"/>
                <xsl:value-of select="$base_url"/>
            </request>
            <xsl:choose>
                <xsl:when test="$verb_lc = $verb_ListRecords">
                    <ListRecords>
                        <xsl:apply-templates select="$response/j:map/j:map[@key='result']/j:array[@key='results']/j:map" mode="record"/>
                        <xsl:call-template name="resumptionToken"/>
                    </ListRecords>
                </xsl:when>
                <xsl:when test="$verb_lc = $verb_ListIdentifiers">
                    <ListIdentifiers>
                        <xsl:apply-templates select="$response/j:map/j:map[@key='result']/j:array[@key='results']/j:map" mode="header"/>
                        <xsl:call-template name="resumptionToken"/>
                    </ListIdentifiers>
                </xsl:when>
                <xsl:otherwise>
                    <GetRecord>
                        <xsl:apply-templates select="$response/j:map/j:map[@key='result']/j:array[@key='results']/j:map" mode="record"/>
                    </GetRecord>
                </xsl:otherwise>
            </xsl:choose>
        </OAI-PMH>
    </xsl:template>
    
    <xsl:template match="j:map/j:map[@key='result']/j:array[@key='results']/j:map" mode="record">
        <record xmlns="http://www.openarchives.org/OAI/2.0/">
            <xsl:apply-templates select="." mode="header"/>
            <xsl:variable name="id" select="j:string[@key='id']"/>
            <xsl:variable name="resourceUri" select="concat('https://ckan.test.open.nrw.de/dataset/', $id, '.xml?profiles=euro_dcat_ap')"/>
            <metadata>
                <xsl:variable name="dcatDoc" select="document($resourceUri)"/>
                <xsl:choose>
                    <xsl:when test="$metadataPrefix != 'iso19139'">
                        <xsl:copy-of select="$dcatDoc/*/dcat:Dataset"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$dcatDoc/*/dcat:Dataset"/>
                    </xsl:otherwise>
                </xsl:choose>
            </metadata>
        </record>
    </xsl:template>

    <xsl:template match="j:map/j:map[@key='result']/j:array[@key='results']/j:map" mode="header">
        <header xmlns="http://www.openarchives.org/OAI/2.0/">
            <identifier>{j:string[@key='id']}</identifier>
            <timestamp>{j:string[@key='metadata_modified']}</timestamp>
        </header>
    </xsl:template>

    <xsl:template name="resumptionToken">
        <xsl:variable name="numberOfRecordsMatched" select="number($response/j:map/j:map[@key='result']/j:number[@key='count'])"/>
        <xsl:variable name="numberOfRecordsReturned" select="count($response/j:map/j:map[@key='result']/j:array[@key='results']/j:map)"/>
        <xsl:choose>
            <xsl:when test="not($resumptionToken) and $numberOfRecordsReturned &lt; $numberOfRecordsMatched">
                <resumptionToken xmlns="http://www.openarchives.org/OAI/2.0/" cursor="1" completeListSize="{$numberOfRecordsMatched}">
                    <xsl:value-of select="concat($numberOfRecordsReturned + 1,
                        $token_sep, $metadataPrefix, $token_sep, $from, $token_sep, $until)"/>
                </resumptionToken>
            </xsl:when>
            <xsl:when test="not($resumptionToken)">
                <resumptionToken xmlns="http://www.openarchives.org/OAI/2.0/" cursor="1" completeListSize="{$numberOfRecordsMatched}"/>
            </xsl:when>
            <xsl:when test="$resumptionToken">
                <resumptionToken xmlns="http://www.openarchives.org/OAI/2.0/" cursor="{number(substring-before($resumptionToken, $token_sep))}" completeListSize="{$numberOfRecordsMatched}">
                    <xsl:if test="$numberOfRecordsReturned + number(substring-before($resumptionToken, $token_sep)) - 1 &lt; $numberOfRecordsMatched">
                        <xsl:value-of select="concat($numberOfRecordsReturned + number(substring-before($resumptionToken, $token_sep)),
                            $token_sep, substring-after($resumptionToken, $token_sep))"/>
                    </xsl:if>
                </resumptionToken>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="suppressXsltNamespaceCheck"/>
</xsl:stylesheet>