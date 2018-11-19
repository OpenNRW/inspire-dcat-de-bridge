<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- transforms a CKAN Dataset to an OAI-PMH response -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:ows="http://www.opengis.net/ows"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:hydra="http://www.w3.org/ns/hydra/core#"
                exclude-result-prefixes="dcat dct rdf ows">
    <xsl:import href="oai-pmhUtil.xsl"/>
    <xsl:import href="dcat2iso.xsl"/>

    <xsl:output method="xml"/>

    <!-- request parameters -->
    <xsl:param name="verb" select="$verb_ListIdentifiers"/>
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

    <xsl:template match="rdf:RDF">
        <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
            <responseDate>
                <xsl:value-of select="$response_date"/>
            </responseDate>
            <request>
                <xsl:call-template name="requestAttributes"/>
                <xsl:value-of select="$base_url"/>
            </request>

            <xsl:choose>
                <xsl:when test="dcat:Catalog/*/dcat:Dataset or dcat:Dataset">
                    <xsl:choose>
                        <xsl:when test="$verb_lc=$verb_ListIdentifiers">
                            <ListIdentifiers>
                                <xsl:apply-templates select="hydra:PagedCollection"/>
                                <xsl:apply-templates select="dcat:Catalog/*/dcat:Dataset|dcat:Dataset" mode="header"/>
                            </ListIdentifiers>
                        </xsl:when>
                        <xsl:when test="$verb_lc=$verb_ListRecords">
                            <ListRecords>
                                <xsl:apply-templates select="hydra:PagedCollection"/>
                                <xsl:apply-templates select="dcat:Catalog//*/dcat:Dataset|dcat:Dataset" mode="record"/>
                            </ListRecords>
                        </xsl:when>
                        <xsl:otherwise>
                            <GetRecord>
                                <xsl:apply-templates select="dcat:Catalog/*/dcat:Dataset|dcat:Dataset" mode="record"/>
                            </GetRecord>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="noRecordsMatch"/>
                </xsl:otherwise>
            </xsl:choose>
        </OAI-PMH>
    </xsl:template>

    <xsl:template match="hydra:PagedCollection">
        <xsl:variable name="numberOfRecordsMatched" select="number(hydra:totalItems/text())"/>
        <xsl:variable name="itemsPerPage" select="number(hydra:itemsPerPage/text())"/>
        <xsl:variable name="lastPage" select="number(substring-after(hydra:lastPage/text(),'page='))"/>
        <xsl:variable name="cursorPage" select="number(substring-after(@rdf:about,'page='))"/>
        <xsl:variable name="cursor" select="($cursorPage - 1) * $itemsPerPage + 1"/>
        <xsl:variable name="token">
            <xsl:if test="hydra:nextPage or $lastPage &gt; $cursorPage">
                <xsl:value-of select="concat($cursor + $itemsPerPage, $token_sep, $metadataPrefix, $token_sep, $from, $token_sep, $until)"/>
            </xsl:if>
        </xsl:variable>

        <resumptionToken xmlns="http://www.openarchives.org/OAI/2.0/" cursor="{$cursor}" completeListSize="{$numberOfRecordsMatched}">
            <xsl:value-of select="$token"/>
        </resumptionToken>
    </xsl:template>

    <xsl:template name="noRecordsMatch">
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

    <xsl:template match="dcat:Dataset" mode="record">
        <record xmlns="http://www.openarchives.org/OAI/2.0/">
            <xsl:apply-templates mode="header" select="."/>
            <metadata>
                <xsl:apply-templates select="."/>
            </metadata>
        </record>
    </xsl:template>

    <xsl:template match="dcat:Dataset" mode="header">
        <header xmlns="http://www.openarchives.org/OAI/2.0/">
            <identifier>
                <xsl:value-of select="dct:identifier/text()"/>
            </identifier>
            <datestamp>
                <xsl:value-of select="dct:modified/text()"/>
            </datestamp>
        </header>
    </xsl:template>

    <xsl:template match="ows:ExceptionReport">
        <xsl:message terminate="yes">The CKAN server returned an exception</xsl:message>
    </xsl:template>

</xsl:stylesheet>
