<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- transforms an OAI-PMH request to a GetRecords request or directly to a response, if possible (e.g. errors) -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

    <xsl:param name="response_date"/>
    <xsl:param name="CamelHttpQuery"/>

    <xsl:param name="db.item.ckan.URL"/>

    <xsl:variable name="verb_lc">
        <xsl:call-template name="getVerb"/>
    </xsl:variable>

    <xsl:variable name="defaultFilter" select="'fq=-metadata_original_portal:&quot;http://www.geoportal.de&quot;-type:harvest+opennrw_geodata:true'"/>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$verb_lc=$verb_ListIdentifiers">
                <xsl:call-template name="listRecords"/>
            </xsl:when>
            <xsl:when test="$verb_lc=$verb_ListRecords">
                <xsl:call-template name="listRecords"/>
            </xsl:when>
            <xsl:when test="$verb_lc=$verb_GetRecord">
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

    <xsl:template name="getRecord">
        <xsl:choose>
            <xsl:when test="$metadataPrefix != $prefix_iso19139 and $metadataPrefix != $prefix_eurodcat and $metadataPrefix != $prefix_dcat and $metadataPrefix != $prefix_geodcat and $metadataPrefix != $prefix_oai">
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
                <xsl:call-template name="ckanget"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="listRecords">
        <xsl:choose>
            <xsl:when test="not($resumptionToken) and $metadataPrefix != $prefix_iso19139 and $metadataPrefix != $prefix_eurodcat and $metadataPrefix != $prefix_dcat and $metadataPrefix != $prefix_geodcat">
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
            <xsl:when test="$until">
                <xsl:call-template name="error">
                    <xsl:with-param name="errorCode">noSetHierarchy</xsl:with-param>
                    <xsl:with-param name="errorMessage">Until not supported</xsl:with-param>
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
                    <xsl:when test="$tokenPrefix != $prefix_iso19139 and $tokenPrefix != $prefix_dcat and $tokenPrefix != $prefix_eurodcat and $tokenPrefix != $prefix_geodcat">
                        <xsl:call-template name="badResumptionToken"/>
                    </xsl:when>
                    <xsl:when test="$tokenFrom and (string-length($tokenFrom) != 10 or string(number(substring-before($tokenFrom, '-'))) = 'NaN')">
                        <xsl:call-template name="badResumptionToken"/>
                    </xsl:when>
                    <xsl:when test="$tokenUntil and (string-length($tokenUntil) != 10 or string(number(substring-before($tokenUntil, '-'))) = 'NaN')">
                        <xsl:call-template name="badResumptionToken"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="ckanget"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="ckanget"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="ckanget">
        <!--operation-->
        <xsl:variable name="httpUri" select="concat($db.item.ckan.URL, '/api/3/action/package_search')"/>
        <xsl:variable name="filter">
            <xsl:if test="$verb != $verb_GetRecord">
                <xsl:value-of select="$defaultFilter"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$identifier">
                    <xsl:value-of select="concat('fq=+id:', $identifier)"/>
                </xsl:when>
                <xsl:when test="$resumptionToken">
                    <xsl:variable name="tokenFrom" select="substring-before(substring-after(substring-after($resumptionToken, ':'), ':'), ':')"/>
                    <xsl:if test="$tokenFrom">
                        <xsl:value-of select="concat('+metadata_modified:[', $tokenFrom, ']')"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$from">
                    <xsl:value-of select="concat('+metadata_modified:[', $from)"/>
                    <xsl:choose>
                        <xsl:when test="not(contains($from, 'T'))">
                            <xsl:value-of select="'T00:00:00Z'"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:value-of select="'%20TO%20NOW]'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="query" select="concat($filter, '&amp;rows=50')"></xsl:variable>
        <xsl:variable name="otherQuery">
            <xsl:if test="$resumptionToken">
                <xsl:variable name="startPosition" select="number(substring-before($resumptionToken, ':'))"/>
                <xsl:value-of select="concat('&amp;start=', number($startPosition) - 1)"/>
            </xsl:if>
        </xsl:variable>
        <parameters>
            <parameter>
                <name>httpUri</name>
                <value>
                    <xsl:value-of select="$httpUri"/>
                </value>
            </parameter>
            <parameter>
                <name>httpQuery</name>
                <value>
                    <xsl:value-of select="$query"/>
                    <xsl:if test="$otherQuery">
                        <xsl:value-of select="concat('&amp;',$otherQuery)"/>
                    </xsl:if>
                </value>
            </parameter>
        </parameters>
    </xsl:template>
</xsl:stylesheet>
