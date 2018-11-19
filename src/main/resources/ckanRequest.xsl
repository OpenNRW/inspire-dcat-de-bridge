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
    <xsl:param name="soapVersion"/>

    <xsl:param name="response_date"/>
    <xsl:param name="CamelHttpQuery"/>

    <xsl:variable name="verb_lc">
        <xsl:call-template name="getVerb"/>
    </xsl:variable>

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
            <xsl:when test="$metadataPrefix != $prefix_eurodcat and $metadataPrefix != $prefix_geodcat and $metadataPrefix != $prefix_oai">
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
            <xsl:when test="not($resumptionToken) and $metadataPrefix != $prefix_eurodcat">
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
                    <xsl:when test="$tokenPrefix != $prefix_eurodcat">
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
        <xsl:variable name="httpUrl">${db.item.ckan.URL}</xsl:variable>
        <xsl:variable name="httpUri">
            <xsl:choose>
                <xsl:when test="$verb_lc=$verb_ListIdentifiers">
                    <xsl:value-of select="concat($httpUrl,'/catalog.xml')"/>
                </xsl:when>
                <xsl:when test="$verb_lc=$verb_ListRecords">
                    <xsl:value-of select="concat($httpUrl,'/catalog.xml')"/>
                </xsl:when>
                <xsl:when test="$verb_lc=$verb_GetRecord">
                    <xsl:value-of select="concat($httpUrl,'/dataset/', $identifier, '.xml')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!--httpQuery parameters-->
        <!--https://{ckan-instance-host}/catalog.{format}?[page={page}]&[modified_since={date}]&[profiles={profile1},{profile2}]-->
        <xsl:variable name="profiles">
            <xsl:call-template name="getParameter">
                <xsl:with-param name="httpQuery" select="$CamelHttpQuery"/>
                <xsl:with-param name="parameter" select="'profiles'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="otherQuery">
            <xsl:call-template name="removeParameters">
                <xsl:with-param name="httpQuery" select="$CamelHttpQuery"/>
                <xsl:with-param name="parameters" select="'modified_since,page,profiles,verb,metadataPrefix,from,until,set,identifier,resumptionToken'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="query">
            <xsl:choose>
                <xsl:when test="$resumptionToken">
                    <xsl:variable name="startPosition" select="number(substring-before($resumptionToken, ':'))"/>
                    <xsl:variable name="tokenPrefix">
                        <xsl:call-template name="addProfiles">
                            <xsl:with-param name="profiles" select="$profiles"/>
                            <xsl:with-param name="profile" select="substring-before(substring-after($resumptionToken, ':'), ':')"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="tokenFrom" select="substring-before(substring-after(substring-after($resumptionToken, ':'), ':'), ':')"/>

                    <xsl:value-of select="concat('profiles=',$tokenPrefix,'&amp;modified_since=',$tokenFrom,'&amp;page=',($startPosition - 1) div $recordsPerPage + 1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="_profiles">
                        <xsl:call-template name="addProfiles">
                            <xsl:with-param name="profiles" select="$profiles"/>
                            <xsl:with-param name="profile" select="$metadataPrefix"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$from">
                            <xsl:value-of select="concat('profiles=',$_profiles,'&amp;modified_since=',$from)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('profiles=',$_profiles)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
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
                    <xsl:choose>
                        <xsl:when test="$otherQuery">
                            <xsl:value-of select="concat($query,'&amp;',$otherQuery)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$query"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </value>
            </parameter>
        </parameters>
    </xsl:template>

    <xsl:template name="addProfiles">
        <xsl:param name="profiles"/>
        <xsl:param name="profile"/>
        <xsl:variable name="_profile" select="concat(normalize-space($profile), ',')"/>
        <xsl:variable name="_profiles" select="concat(normalize-space($profiles), ',')"/>
        <xsl:choose>
            <xsl:when test="contains($_profiles, $_profile)">
                <xsl:value-of select="$profiles"/>
            </xsl:when>
            <xsl:when test="string-length($profiles) > 0">
                <xsl:value-of select="concat($profiles, ',', $profile)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$profile"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getParameter">
        <xsl:param name="httpQuery"/>
        <xsl:param name="parameter"/>
        <xsl:variable name="pEQ" select="concat($parameter,'=')"/>
        <xsl:choose>
            <xsl:when test="contains($httpQuery, $pEQ)">
                <xsl:variable name="pEQ-after" select="substring-after($httpQuery, $pEQ)"/>
                <xsl:choose>
                    <xsl:when test="contains($pEQ-after, '&amp;')">
                        <xsl:value-of select="substring-before($pEQ-after, '&amp;')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$pEQ-after"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="removeParameters">
        <xsl:param name="httpQuery"/>
        <xsl:param name="parameters"/>

        <xsl:variable name="parameter">
            <xsl:choose>
                <xsl:when test="contains($parameters, ',')">
                    <xsl:value-of select="substring-before($parameters, ',')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$parameters"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="parameterList" select="substring-after($parameters, ',')"/>
        <xsl:variable name="pEQ" select="concat($parameter,'=')"/>
        <xsl:variable name="res">
            <xsl:choose>
                <xsl:when test="string-length($parameter) > 0 and contains($httpQuery, $pEQ)">
                    <xsl:variable name="pEQ-after" select="substring-after(substring-after($httpQuery, $pEQ), '&amp;')"/>
                    <xsl:value-of select="concat(substring-before($httpQuery, $pEQ),$pEQ-after)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$httpQuery"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="string-length($parameterList) > 0">
                <xsl:call-template name="removeParameters">
                    <xsl:with-param name="httpQuery" select="$res"/>
                    <xsl:with-param name="parameters" select="$parameterList"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="substring($res, string-length($res)) = '&amp;'" >
                <xsl:value-of select="substring($res, 1, string-length($res) - 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$res"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
