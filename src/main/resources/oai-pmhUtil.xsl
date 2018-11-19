<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <xsl:output method="xml"/>

    <xsl:variable name="base_url">${oai-pmh.base.url.external}</xsl:variable>

    <xsl:variable name="recordsPerPage">100</xsl:variable>

    <xsl:variable name="prefix_oai">oai_dc</xsl:variable>
    <xsl:variable name="prefix_dcat">dcat_ap</xsl:variable>
    <xsl:variable name="prefix_eurodcat">euro_dcat_ap</xsl:variable>
    <xsl:variable name="prefix_geodcat">geodcat_ap_extended</xsl:variable>
    <xsl:variable name="prefix_iso19139">iso19139</xsl:variable>

    <xsl:variable name="token_sep">:</xsl:variable>

    <xsl:variable name="verb_GetRecord">GetRecord</xsl:variable>
    <xsl:variable name="verb_ListRecords">ListRecords</xsl:variable>
    <xsl:variable name="verb_ListIdentifiers">ListIdentifiers</xsl:variable>

    <xsl:template name="getVerb">
        <xsl:variable name="lc" select="translate($verb, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
        <xsl:choose>
            <xsl:when test="$lc=translate($verb_GetRecord, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')">
                <xsl:value-of select="$verb_GetRecord"/>
            </xsl:when>
            <xsl:when test="$lc=translate($verb_ListRecords, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')">
                <xsl:value-of select="$verb_ListRecords"/>
            </xsl:when>
            <xsl:when test="$lc=translate($verb_ListIdentifiers, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')">
                <xsl:value-of select="$verb_ListIdentifiers"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$verb"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="badResumptionToken">
        <xsl:call-template name="error">
            <xsl:with-param name="errorCode">badResumptionToken</xsl:with-param>
            <xsl:with-param name="errorMessage" select="concat('Bad resumptionToken: ', $resumptionToken)"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="error">
        <xsl:param name="errorMessage">Unspecified error</xsl:param>
        <xsl:param name="errorCode"/>
        <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
            <responseDate><xsl:value-of select="$response_date"/></responseDate>
            <request>
                <!--<xsl:if test="$errorCode != 'badVerb' and $errorCode != 'badArgument'">-->
                    <!--<xsl:call-template name="requestAttributes"/>-->
                <!--</xsl:if>-->
                <xsl:call-template name="requestAttributes"/>
                <xsl:value-of select="$base_url"/>
            </request>
            <error code="{$errorCode}"><xsl:value-of select="$errorMessage"/></error>
        </OAI-PMH>
    </xsl:template>

    <xsl:template name="requestAttributes">
        <xsl:if test="$verb_lc">
            <xsl:attribute name="verb"><xsl:value-of select="$verb_lc"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$identifier">
            <xsl:attribute name="identifier"><xsl:value-of select="$identifier"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$metadataPrefix">
            <xsl:attribute name="metadataPrefix"><xsl:value-of select="$metadataPrefix"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$from">
            <xsl:attribute name="from"><xsl:value-of select="$from"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$until">
            <xsl:attribute name="until"><xsl:value-of select="$until"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$set">
            <xsl:attribute name="set"><xsl:value-of select="$set"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$resumptionToken">
            <xsl:attribute name="resumptionToken"><xsl:value-of select="$resumptionToken"/></xsl:attribute>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
