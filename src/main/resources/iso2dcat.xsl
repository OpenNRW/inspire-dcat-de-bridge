<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:locn="http://www.w3.org/ns/locn#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:schema="http://schema.org/"
                xmlns:prov="http://www.w3.org/ns/prov#"
                xmlns:wdrs="http://www.w3.org/2007/05/powder-s#"
                xmlns:earl="http://www.w3.org/ns/earl#"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:cnt="http://www.w3.org/2011/content#"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:dcatde="http://dcat-ap.de/def/dcatde/1_0/"
                xmlns:adms="http://www.w3.org/ns/adms#"
                xmlns:org="http://www.w3.org/ns/org#"
                exclude-result-prefixes="gmd gco srv xlink gmi">

    <xsl:output method="xml"/>

    <!--
    <xsl:strip-space elements="*"/>
    -->
    <!--todo: ISO zu Open.NRW erforderlich-->
    <xsl:param name="openNRW">true</xsl:param>

    <xsl:variable name="c_license">license</xsl:variable>
    <xsl:variable name="c_no_limitation">keine</xsl:variable>
    <xsl:variable name="c_other_restrictions">otherRestrictions</xsl:variable>

    <xsl:param name="resumptionToken">51:dcat_ap::</xsl:param>
    <xsl:variable name="tokeDcatAp">:dcat_ap:</xsl:variable>
    <xsl:param name="metadataPrefix">dcat_ap</xsl:param>
    <xsl:variable name="prefixDcatAp">dcat_ap</xsl:variable>
    <xsl:variable name="extended" select="($metadataPrefix and $metadataPrefix != $prefixDcatAp) or ($resumptionToken and not(contains($resumptionToken, $tokeDcatAp)))"/>

    <xsl:variable name="inspireThemes" select="document('themes.rdf')"/>
    <xsl:variable name="euroVocMapping" select="document('align_EuroVoc_Inspire.rdf')"/>
    <xsl:variable name="mdrFileTypes" select="document('filetypes-skos.rdf')"/>
    <xsl:variable name="ianaMediaTypes" select="document('iana-media-types.xml')"/>
    <xsl:variable name="languageCodes" select="document('languageCodes.rdf')"/>

    <xsl:variable name="inspire_md_codelist">http://inspire.ec.europa.eu/metadata-codelist/</xsl:variable>

    <xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata">
        <dcat:Dataset>
            <!--dct:description-->
            <!--dct:title-->
            <!--dcatde:contributorID-->
            <!--dcat:contactPoint-->
            <!--dcat:distribution-->
            <!--dcat:keyword-->
            <!--dct:publisher-->
            <!--dcat:theme-->
            <!--dct:subject-->
            <!--dcatde:politicalGeocodingLevelURI-->
            <!--dcatde:politicalGeocodingURI-->
            <!--dct:accessRights-->
            <!--dct:identifier-->
            <!--dct:language-->
            <!--dct:issued-->
            <!--dct:spatial-->
            <!--dct:modified-->

            <xsl:call-template name="commonProperties"/>

            <xsl:if test="$openNRW!='true'">
                <xsl:apply-templates select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement/gco:CharacterString[text()]"/>
            </xsl:if>

            <!--dcat:distribution-->
            <xsl:choose>
                <xsl:when test="$openNRW!='true'">
                    <!-- now services are handled the same way as datasets -->
                    <xsl:choose>
                        <xsl:when test="gmd:hierarchyLevel/*/@codeListValue='service'">
                            <xsl:call-template name="serviceDistribution"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="dataDistribution"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="gmd:hierarchyLevel/*/@codeListValue='service'">
                            <xsl:call-template name="serviceDistribution"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="dataDistributionNRW"/>
                        </xsl:otherwise>
                    </xsl:choose>
<!--
                    <xsl:apply-templates select="gmd:identificationInfo[1]/gmd:MD_DataIdentification" mode="distribution"/>
                    <xsl:apply-templates select="gmd:identificationInfo[1]/srv:SV_ServiceIdentification" mode="distribution"/>
                    <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution" mode="distribution"/>
-->
                </xsl:otherwise>
            </xsl:choose>

            <xsl:choose>
                <xsl:when test="$openNRW!='true'">
                    <xsl:if test="not(gmd:identificationInfo[1]/*/gmd:descriptiveKeywords/*[starts-with(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*, 'GEMET - INSPIRE themes')]/gmd:keyword/gco:CharacterString[text()])">
                        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:topicCategory/*" mode="dcatTheme"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:topicCategory/*" mode="openNRW"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="$openNRW!='true'">
                <xsl:apply-templates select="gmd:parentIdentifier/*[text()]"/>
            </xsl:if>
            <xsl:if test="$extended">
                <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:topicCategory/*"/>
            </xsl:if>
        </dcat:Dataset>
    </xsl:template>

    <xsl:template name="commonProperties">
        <!--dct:title-->
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:title/gco:CharacterString[text()]"/>

        <!--dct:description-->
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:abstract/gco:CharacterString[text()]"/>

        <!--dct:identifier-->
        <xsl:apply-templates select="gmd:fileIdentifier/gco:CharacterString"/>
        <xsl:if test="$openNRW!='true'">
            <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString"/>
        </xsl:if>

        <!--dct:language-->
        <!--cnt:characterEncoding-->
        <xsl:choose>
            <xsl:when test="gmd:language/*[string-length(@codeListValue) = 3]|gmd:identificationInfo/*/gmd:language/gco:CharacterString[string-length(text()) = 3]">
                <xsl:apply-templates select="gmd:language/*[string-length(@codeListValue) = 3]|gmd:identificationInfo/*/gmd:language/gco:CharacterString[string-length(text()) = 3]"/>
                <xsl:apply-templates select="gmd:characterSet/*/@codeListValue"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:language/*[string-length(@codeListValue) = 3]|gmd:identificationInfo/*/gmd:language/gco:CharacterString[string-length(text()) = 3]"/>
                <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:characterSet/*/@codeListValue|ancestor::gmi:MI_Metadata/gmd:identificationInfo/*/gmd:characterSet/*/@codeListValue"/>
            </xsl:otherwise>
        </xsl:choose>


        <!--dct:accessRights-->
<!--
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:useConstraints/gmd:MD_RestrictionCode" mode="accessRights"/>
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:accessConstraints/gmd:MD_RestrictionCode" mode="accessRights"/>
-->
        <xsl:variable name="accessConstraints" select="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*[*/gmd:MD_RestrictionCode/@codeListValue=$c_other_restrictions]/gmd:otherConstraints[. != $c_no_limitation]"/>
        <xsl:apply-templates select="$accessConstraints[1]"/>
        
        <!--dcat:keyword-->
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:descriptiveKeywords/*/gmd:keyword/gco:CharacterString[text()]"/>

        <!--dcatde:politicalGeocodingLevelURI-->
        <!--dcatde:politicalGeocodingURI-->
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicDescription" mode="openNRW"/>

        <!--dct:spatial-->
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement|gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement"/>

        <!--<dct:temporal>-->
        <xsl:if test="$openNRW!='true'">
            <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod[string-length(gml:beginPosition/text()) &gt; 9 or string-length(gml:endPosition/text()) &gt; 9]"/>
            <xsl:apply-templates select="gmd:identificationInfo[1]/*/srv:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod[string-length(gml:beginPosition/text()) &gt; 9 or string-length(gml:endPosition/text()) &gt; 9]"/>
        </xsl:if>

        <!--dct:created dct:issued dct:modified-->
        <xsl:choose>
            <xsl:when test="$openNRW!='true'">
                <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue='publication' or gmd:dateType/*/@codeListValue='revision' or gmd:dateType/*/@codeListValue='creation']/gmd:date/*"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue='publication' or gmd:dateType/*/@codeListValue='revision' or gmd:dateType/*/@codeListValue='creation']/gmd:date/*"
                                     mode="openNRW"/>
            </xsl:otherwise>
        </xsl:choose>

        <!--dcat:contactPoint dct:publisher dct:creator dct:rightsHolder dcatde:maintainer-->
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty"/>
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:pointOfContact/gmd:CI_ResponsibleParty"/>

        <xsl:apply-templates select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation"/>
        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue"/>
        <xsl:apply-templates select="gmd:hierarchyLevel"/>

        <xsl:if test="$openNRW!='true'">
            <xsl:if test="$extended">
                <foaf:isPrimaryTopicOf>
                    <rdf:Description>
                        <rdf:type rdf:resource="http://www.w3.org/ns/dcat#CatalogRecord"/>
                        <xsl:apply-templates select="gmd:language/*[@codeListValue]|gmd:language/gco:CharacterString"/>
                        <xsl:apply-templates select="gmd:dateStamp/*"/>
                        <xsl:apply-templates select="gmd:contact/*[gmd:organisationName]"/>
                        <xsl:apply-templates select="gmd:contact/*[gmd:organisationName]" mode="qualifiedAttribution"/>
                        <xsl:apply-templates select="gmd:fileIdentifier/gco:CharacterString"/>
                        <xsl:apply-templates select="gmd:metadataStandardName/gco:CharacterString"/>
                    </rdf:Description>
                </foaf:isPrimaryTopicOf>
                <xsl:apply-templates select="gmd:contact/*[gmd:organisationName]" mode="qualifiedAttribution"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:fileIdentifier/*">
        <adms:identifier>
            <xsl:value-of select="."/>
        </adms:identifier>
        <dct:identifier rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
            <xsl:value-of select="."/>
        </dct:identifier>
    </xsl:template>

    <xsl:template match="gmd:metadataStandardName/gco:CharacterString">
        <dct:source rdf:parseType="Resource">
            <dct:conformsTo rdf:parseType="Resource">
                <dct:title>
                    <xsl:call-template name="xmlLang"/>
                    <xsl:value-of select="."/>
                </dct:title>
                <xsl:apply-templates select="../../gmd:metadataStandardVersion/*"/>
            </dct:conformsTo>
        </dct:source>
    </xsl:template>

    <xsl:template match="gmd:metadataStandardName/gmx:Anchor">
        <dct:source rdf:parseType="Resource">
            <dct:conformsTo rdf:resource="{@xlink:href}"/>
        </dct:source>
    </xsl:template>

    <xsl:template match="gmd:metadataStandardVersion/*">
        <owl:versionInfo>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="."/>
        </owl:versionInfo>
    </xsl:template>

    <xsl:template match="gmd:specification/gmd:CI_Citation">
        <xsl:if test="$extended">
            <wdrs:describedby>
                <earl:Assertion>
                    <earl:test>
                        <xsl:apply-templates select="." mode="specinfo"/>
                    </earl:test>
                    <earl:result>
                        <earl:TestResult>
                            <earl:outcome>
                                <xsl:variable name="pass" select="../../gmd:pass/gco:Boolean"/>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="concat($inspire_md_codelist, 'DegreeOfConformity/')"/>
                                    <xsl:choose>
                                        <xsl:when test="$pass = 'true'">conformant</xsl:when>
                                        <xsl:when test="$pass = 'false'">notConformant</xsl:when>
                                        <xsl:otherwise>notEvaluated</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </earl:outcome>
                            <xsl:apply-templates select="../../gmd:explanation/*"/>
                        </earl:TestResult>
                    </earl:result>
                </earl:Assertion>
            </wdrs:describedby>
        </xsl:if>
        <xsl:apply-templates select="." mode="conformsTo"/>
    </xsl:template>

    <xsl:template match="gmd:explanation/*">
        <earl:info>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="text()"/>
        </earl:info>
    </xsl:template>

    <xsl:template match="gmd:CI_Citation" mode="conformsTo"/>

    <xsl:template match="gmd:CI_Citation[../../gmd:pass/gco:Boolean = 'true']" mode="conformsTo">
        <dct:conformsTo>
            <xsl:apply-templates select="." mode="specinfo"/>
        </dct:conformsTo>
    </xsl:template>

    <xsl:template match="gmd:specification/gmd:CI_Citation[not(../@xlink:href) or ../@xlink:href = '']" mode="specinfo">
        <xsl:attribute name="rdf:parseType">Resource</xsl:attribute>
        <xsl:call-template name="specinfo"/>
    </xsl:template>

    <xsl:template match="gmd:specification/gmd:CI_Citation[../@xlink:href != '']" mode="specinfo">
        <xsl:attribute name="rdf:resource">
            <xsl:value-of select="../@xlink:href"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="specinfo">
        <dct:title>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="gmd:title/gco:CharacterString"/>
        </dct:title>
        <xsl:apply-templates select="gmd:date/*/gmd:date/*"/>
    </xsl:template>

    <xsl:template match="gmd:pass">
        <earl:result>
            <earl:TestResult>
                <earl:outcome>
                    <xsl:attribute name="rdf:resource">
                        <xsl:apply-templates select="." mode="value"/>
                    </xsl:attribute>
                </earl:outcome>
            </earl:TestResult>
        </earl:result>
    </xsl:template>

    <xsl:template match="gmd:pass[text() = 'true']" mode="value">
        <xsl:value-of select="concat($inspire_md_codelist, 'DegreeOfConformity/conformant')"/>
    </xsl:template>

    <xsl:template match="gmd:pass[text() = 'false']" mode="value">
        <xsl:value-of select="concat($inspire_md_codelist, 'DegreeOfConformity/notConformant')"/>
    </xsl:template>

    <xsl:template match="gmd:pass" mode="value">
        <xsl:value-of select="concat($inspire_md_codelist, 'DegreeOfConformity/notEvaluated')"/>
    </xsl:template>

    <xsl:template
            match="gmd:dateStamp/*[(string-length(text()) = 10 and not (contains(text(), ' '))) or ((string-length(text()) = 19 and not (contains(text(), ' ')))) or ((string-length(text()) = 20 and not (contains(text(), ' ')) and (contains(text(), 'Z'))))]">
        <dct:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
            <xsl:value-of select="."/>
        </dct:modified>
    </xsl:template>

    <xsl:template match="gmd:contact/*[gmd:organisationName]" mode="qualifiedAttribution">
        <prov:qualifiedAttribution>
            <prov:Attribution>
                <prov:agent>
                    <xsl:call-template name="vcardOrg"/>
                </prov:agent>
                <dct:type rdf:resource="http://inspire.ec.europa.eu/metadata-codelist/ResponsiblePartyRole/pointOfContact"/>
            </prov:Attribution>
        </prov:qualifiedAttribution>
    </xsl:template>

    <xsl:template match="gmd:hierarchyLevel[*/@codeListValue = 'dataset' or */@codeListValue = 'series']">
        <dct:type rdf:resource="{concat($inspire_md_codelist, 'ResourceType/', */@codeListValue)}"/>
    </xsl:template>

    <xsl:template match="gmd:hierarchyLevel[*/@codeListValue = 'service']">
        <dct:type rdf:resource="{concat($inspire_md_codelist, 'ResourceType/services')}"/>
        <xsl:apply-templates select="../gmd:identificationInfo/*/srv:serviceType[*/text()]" mode="spatialDataServiceType"/>
    </xsl:template>

    <xsl:template match="gmd:hierarchyLevel"/>

    <xsl:template match="srv:serviceType[* = 'WMS' or * = 'wms' or */text() = 'view' or * = 'VIEW' or * = 'View' or * = 'OGC:WMS' or * = 'ogc:wms']" mode="spatialDataServiceType">
        <dct:type rdf:resource="{concat($inspire_md_codelist, 'SpatialDataServiceType/view')}"/>
    </xsl:template>

    <xsl:template match="srv:serviceType[* = 'WFS' or * = 'wfs' or * = 'download' or * = 'DOWNLOAD' or * = 'Download' or * = 'OGC:WFS' or * = 'ogc:wfs' or * = 'WCS' or * = 'wcs' or * = 'OGC:WCS' or * = 'ogc:wcs']" mode="spatialDataServiceType">
        <dct:type rdf:resource="{concat($inspire_md_codelist, 'SpatialDataServiceType/download')}"/>
    </xsl:template>

    <xsl:template match="srv:serviceType[* = 'CSW' or * = 'csw' or * = 'discovery' or * = 'DISCOVERY' or * = 'Discovery' or * = 'OGC:CSW' or * = 'ogc:csw']" mode="spatialDataServiceType">
        <dct:type rdf:resource="{concat($inspire_md_codelist, 'SpatialDataServiceType/download')}"/>
    </xsl:template>

    <xsl:template match="srv:serviceType[* = 'transformation' or * = 'Transformation' or * = 'TRANSFORMATION']" mode="spatialDataServiceType">
        <dct:type rdf:resource="{concat($inspire_md_codelist, 'SpatialDataServiceType/transformation')}"/>
    </xsl:template>

    <xsl:template match="srv:serviceType[* = 'WPS' or * = 'wps' or * = 'invoke' or * = 'Invoke' or * = 'INVOKE' or * = 'OGC:WPS' or * = 'ogc:wps']" mode="spatialDataServiceType">
        <dct:type rdf:resource="{concat($inspire_md_codelist, 'SpatialDataServiceType/transformation')}"/>
    </xsl:template>

    <xsl:template match="srv:serviceType" mode="spatialDataServiceType">
        <dct:type rdf:resource="{concat($inspire_md_codelist, 'SpatialDataServiceType/other')}"/>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString">
        <dct:title>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="."/>
        </dct:title>
        <xsl:apply-templates select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" mode="param">
            <xsl:with-param name="mode" select="'title'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" mode="param">
        <xsl:param name="mode" select="'description'"/>
        <xsl:variable name="localeRef" select="substring-after(@locale, '#')"/>
        <xsl:variable name="locale" select="ancestor::gmd:MD_Metadata/gmd:locale/*[@id = $localeRef]|ancestor::gmi:MI_Metadata/gmd:locale/*[@id = $localeRef]"/>
        <xsl:if test="$locale">
            <xsl:variable name="language" select="$locale/gmd:languageCode"/>
            <xsl:if test="ancestor::gmd:MD_Metadata/gmd:language/*/gco:CharacterString">
                <xsl:call-template name="language">
                    <xsl:with-param name="mode" select="$mode"/>
                    <xsl:with-param name="language" select="$language"/>
                    <xsl:with-param name="languageCode" select="string(ancestor::gmd:MD_Metadata/gmd:language/*/gco:CharacterString)"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="ancestor::gmd:MD_Metadata/gmd:language/*/@codeListValue">
                <xsl:call-template name="language">
                    <xsl:with-param name="mode" select="$mode"/>
                    <xsl:with-param name="language" select="$language"/>
                    <xsl:with-param name="languageCode" select="string(ancestor::gmd:MD_Metadata/gmd:language/*/@codeListValue)"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template name="language">
        <xsl:param name="mode"/>
        <xsl:param name="language"/>
        <xsl:param name="languageCode"/>
        <xsl:if test="not($languageCode = string($language/*/@codeListValue))">
            <xsl:choose>
                <xsl:when test="$mode='title'">
                    <dct:title>
                        <xsl:apply-templates select="$language/*" mode="xmlLang"/>
                        <xsl:value-of select="."/>
                    </dct:title>
                </xsl:when>
                <xsl:when test="$mode='label'">
                    <rdfs:label>
                        <xsl:apply-templates select="$language/*" mode="xmlLang"/>
                        <xsl:value-of select="."/>
                    </rdfs:label>
                </xsl:when>
                <xsl:otherwise>
                    <dct:description>
                        <xsl:apply-templates select="$language/*" mode="xmlLang"/>
                        <xsl:value-of select="."/>
                    </dct:description>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString">
        <dct:description>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="."/>
        </dct:description>
        <xsl:apply-templates select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" mode="param"/>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement|gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement">
        <xsl:if test="gmd:EX_GeographicBoundingBox or $openNRW!='true'">
            <dct:spatial>
                <dct:Location>
                    <xsl:apply-templates select="../gmd:description/gco:CharacterString"/>
                    <xsl:apply-templates select="gmd:EX_GeographicBoundingBox"/>
                    <xsl:if test="$openNRW!='true'">
                        <xsl:apply-templates select="gmd:EX_GeographicDescription"/>
                    </xsl:if>
                </dct:Location>
            </dct:spatial>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:extent/*/gmd:description/gco:CharacterString">
        <rdfs:label>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="text()"/>
        </rdfs:label>
        <xsl:apply-templates select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString"/>
    </xsl:template>

    <xsl:template match="gmd:extent/*/gmd:description/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
        <xsl:variable name="localeRef" select="substring-after(@locale, '#')"/>
        <xsl:variable name="locale" select="ancestor::gmd:MD_Metadata/gmd:locale/*[@id = $localeRef]|ancestor::gmi:MI_Metadata/gmd:locale/*[@id = $localeRef]"/>
        <xsl:if test="$locale">
            <rdfs:label>
                <xsl:apply-templates select="$locale/gmd:languageCode/*" mode="xmlLang"/>
                <xsl:value-of select="."/>
            </rdfs:label>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:geographicElement/gmd:EX_GeographicBoundingBox">
        <locn:geometry rdf:datatype="http://www.opengis.net/ont/geosparql#gmlLiteral">
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;gml:Envelope srsName="http://www.opengis.net/def/EPSG/0/4326"&gt;&lt;gml:lowerCorner&gt;</xsl:text>
            <xsl:value-of select="concat(gmd:southBoundLatitude/*, ' ', gmd:westBoundLongitude/*)"/>
            <xsl:text disable-output-escaping="yes">&lt;/gml:lowerCorner&gt;&lt;gml:upperCorner&gt;</xsl:text>
            <xsl:value-of select="concat(gmd:northBoundLatitude/*, ' ', gmd:eastBoundLongitude/*)"/>
            <xsl:text disable-output-escaping="yes">&lt;/gml:upperCorner&gt;&lt;/gml:Envelope&gt;]]&gt;</xsl:text>
        </locn:geometry>
        <locn:geometry rdf:datatype="http://www.opengis.net/ont/geosparql#wktLiteral">
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[POLYGON((</xsl:text>
            <xsl:value-of select="concat(gmd:westBoundLongitude/*, ' ', gmd:northBoundLatitude/*, ',', gmd:eastBoundLongitude/*, ' ', gmd:northBoundLatitude/*, ',', gmd:eastBoundLongitude/*, ' ', gmd:southBoundLatitude/*,',')"/>
            <xsl:value-of select="concat(gmd:westBoundLongitude/*, ' ', gmd:southBoundLatitude/*, ',', gmd:westBoundLongitude/*, ' ', gmd:northBoundLatitude/*)"/>
            <xsl:text disable-output-escaping="yes">))]]&gt;</xsl:text>
        </locn:geometry>
    </xsl:template>

    <xsl:template match="gmd:geographicElement/gmd:EX_GeographicDescription[gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code]">
        <rdfs:seeAlso>
            <skos:Concept>
                <xsl:apply-templates select="gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString|gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gmx:Anchor"/>
                <xsl:apply-templates select="gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gmd:authority/gmd:CI_Citation"/>
            </skos:Concept>
        </rdfs:seeAlso>
    </xsl:template>

    <xsl:template match="gmd:geographicElement/gmd:EX_GeographicDescription[gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code]" mode="openNRW">
        <dcatde:politicalGeocodingLevelURI>
            <xsl:value-of select="gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString"/>
        </dcatde:politicalGeocodingLevelURI>
    </xsl:template>

    <xsl:template match="gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
        <skos:prefLabel>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="text()"/>
        </skos:prefLabel>
    </xsl:template>

    <xsl:template match="gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gmx:Anchor">
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="@xlink:href"/>
        </xsl:attribute>
        <xsl:if test="text()">
            <skos:prefLabel>
                <xsl:call-template name="xmlLang"/>
                <xsl:value-of select="text()"/>
            </skos:prefLabel>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:authority/gmd:CI_Citation">
        <skos:inScheme>
            <skos:ConceptScheme>
                <rdfs:label>
                    <xsl:call-template name="xmlLang"/>
                    <xsl:value-of select="gmd:title/gco:CharacterString"/>
                </rdfs:label>
                <xsl:apply-templates select="gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString"/>
                <xsl:apply-templates select="gmd:date/*/gmd:date/*"/>
            </skos:ConceptScheme>
        </skos:inScheme>
    </xsl:template>

    <xsl:template match="gmd:authority/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
        <xsl:variable name="localeRef" select="substring-after(@locale, '#')"/>
        <xsl:variable name="locale" select="ancestor::gmd:MD_Metadata/gmd:locale/*[@id = $localeRef]|ancestor::gmi:MI_Metadata/gmd:locale/*[@id = $localeRef]"/>
        <xsl:if test="$locale">
            <rdfs:label>
                <xsl:apply-templates select="$locale/gmd:languageCode/*" mode="xmlLang"/>
                <xsl:value-of select="."/>
            </rdfs:label>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod">
        <dct:temporal>
            <dct:PeriodOfTime>
                <xsl:apply-templates select="gml:beginPosition[string-length(text()) &gt; 9]"/>
                <xsl:apply-templates select="gml:endPosition[string-length(text()) &gt; 9]"/>
            </dct:PeriodOfTime>
        </dct:temporal>
    </xsl:template>

    <xsl:template
            match="gml:beginPosition[(string-length(text()) = 10 and not (contains(text(), ' '))) or ((string-length(text()) = 19 and not (contains(text(), ' ')))) or ((string-length(text()) = 20 and not (contains(text(), ' ')) and (contains(text(), 'Z'))))]">
        <schema:startDate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
            <xsl:value-of select="."/>
        </schema:startDate>
    </xsl:template>

    <xsl:template
            match="gml:endPosition[(string-length(text()) = 10 and not (contains(text(), ' '))) or ((string-length(text()) = 19 and not (contains(text(), ' ')))) or ((string-length(text()) = 20 and not (contains(text(), ' ')) and (contains(text(), 'Z'))))]">
        <schema:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
            <xsl:value-of select="."/>
        </schema:endDate>
    </xsl:template>

    <xsl:template
            match="gmd:date/*[gmd:dateType/*/@codeListValue='publication']/gmd:date/*[(string-length(text()) = 10 and not (contains(text(), ' '))) or ((string-length(text()) = 19 and not (contains(text(), ' ')))) or ((string-length(text()) = 20 and not (contains(text(), ' ')) and (contains(text(), 'Z'))))]">
        <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
            <xsl:value-of select="."/>
        </dct:issued>
    </xsl:template>

    <xsl:template
            match="gmd:date/*[gmd:dateType/*/@codeListValue='revision']/gmd:date/*[(string-length(text()) = 10 and not (contains(text(), ' '))) or ((string-length(text()) = 19 and not (contains(text(), ' ')))) or ((string-length(text()) = 20 and not (contains(text(), ' ')) and (contains(text(), 'Z'))))]">
        <dct:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
            <xsl:value-of select="."/>
        </dct:modified>
    </xsl:template>

    <xsl:template
            match="gmd:date/*[gmd:dateType/*/@codeListValue='creation']/gmd:date/*[(string-length(text()) = 10 and not (contains(text(), ' '))) or ((string-length(text()) = 19 and not (contains(text(), ' ')))) or ((string-length(text()) = 20 and not (contains(text(), ' ')) and (contains(text(), 'Z'))))]">
        <dct:created rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
            <xsl:value-of select="."/>
        </dct:created>
    </xsl:template>

    <xsl:template
            match="gmd:date/*[gmd:dateType/*/@codeListValue = 'publication']/gmd:date/*[(string-length(text()) = 10 and not (contains(text(), ' '))) or ((string-length(text()) = 19 and not (contains(text(), ' ')))) or ((string-length(text()) = 20 and not (contains(text(), ' ')) and (contains(text(), 'Z'))))]"
            mode="openNRW">
        <xsl:if test="not(ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'revision']/gmd:date/*)">
            <dct:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                <xsl:value-of select="."/>
            </dct:modified>
        </xsl:if>
        <xsl:if test="not(ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'creation']/gmd:date/*)">
            <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                <xsl:value-of select="."/>
            </dct:issued>
        </xsl:if>
    </xsl:template>

    <xsl:template
            match="gmd:date/*[gmd:dateType/*/@codeListValue = 'revision']/gmd:date/*[(string-length(text()) = 10 and not (contains(text(), ' '))) or ((string-length(text()) = 19 and not (contains(text(), ' ')))) or ((string-length(text()) = 20 and not (contains(text(), ' ')) and (contains(text(), 'Z'))))]"
            mode="openNRW">
        <dct:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
            <xsl:value-of select="."/>
        </dct:modified>
    </xsl:template>

    <xsl:template
            match="gmd:date/*[gmd:dateType/*/@codeListValue = 'creation']/gmd:date/*[(string-length(text()) = 10 and not (contains(text(), ' '))) or ((string-length(text()) = 19 and not (contains(text(), ' ')))) or ((string-length(text()) = 20 and not (contains(text(), ' ')) and (contains(text(), 'Z'))))]"
            mode="openNRW">
        <xsl:if
                test="not(ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'revision']/gmd:date/* or ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'publication']/gmd:date/*)">
            <dct:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                <xsl:value-of select="."/>
            </dct:modified>
        </xsl:if>
        <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
            <xsl:value-of select="."/>
        </dct:issued>
    </xsl:template>

    <xsl:template match="gmd:CI_ResponsibleParty">
        <xsl:if test="gmd:organisationName or gmd:individualName">
            <xsl:variable name="code" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/>
            <xsl:choose>
                <xsl:when test="$code='pointOfContact'">
                    <dcat:contactPoint>
                        <xsl:call-template name="vcardOrg"/>
                    </dcat:contactPoint>
                </xsl:when>
                <xsl:when test="$code='publisher' or $code='author'">
                    <dct:publisher>
                        <xsl:call-template name="foafOrg"/>
                    </dct:publisher>
                </xsl:when>
                <xsl:when test="$code='originator'">
                    <dct:creator>
                        <xsl:call-template name="foafOrg"/>
                    </dct:creator>
                </xsl:when>
                <xsl:when test="$code='owner'">
                    <dct:rightsHolder>
                        <xsl:call-template name="foafOrg"/>
                    </dct:rightsHolder>
                </xsl:when>
                <xsl:when test="$code='custodian'">
                    <dcatde:maintainer>
                        <xsl:call-template name="foafOrg"/>
                    </dcatde:maintainer>
                </xsl:when>
                <xsl:otherwise>
                    <dcat:contactPoint>
                        <xsl:call-template name="vcardOrg"/>
                    </dcat:contactPoint>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="foafOrg">
        <rdf:Description>
            <xsl:variable name="orgLink" select="string(gmd:organisationName/gmx:Anchor/@xlink:href)"/>
            <xsl:variable name="indLink" select="string(gmd:individualName/gmx:Anchor/@xlink:href)"/>
            <xsl:choose>
                <xsl:when test="$indLink != ''">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$indLink"/></xsl:attribute>
                </xsl:when>
                <xsl:when test="$orgLink != ''">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$orgLink"/></xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:variable name="orgName" select="string(gmd:organisationName/gco:CharacterString)"/>
            <xsl:variable name="indName" select="string(gmd:individualName/gco:CharacterString)"/>
            <xsl:choose>
                <xsl:when test="$indName != ''">
                    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person"/>
                </xsl:when>
                <xsl:when test="$orgName != ''">
                    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
                </xsl:when>
                <xsl:otherwise>
                    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="gmd:organisationName[not(../gmd:individualName/gco:CharacterString/text())]/gco:CharacterString[text()]"/>
            <xsl:apply-templates select="gmd:individualName/gco:CharacterString[text()]"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString[not(contains(text, ';') or contains(text, ',') or contains(text, ' '))]"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:phone/*/gmd:voice/*[text()]"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/*[text()]"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:address/*"/>
        </rdf:Description>
    </xsl:template>
    
    <xsl:template match="gmd:organisationName/gco:CharacterString">
        <foaf:name><xsl:value-of select="."/></foaf:name>
    </xsl:template>
    
    <xsl:template match="gmd:individualName/gco:CharacterString">
        <foaf:name><xsl:value-of select="."/></foaf:name>
        <xsl:apply-templates select="../../gmd:organisationName/gco:CharacterString[text()]" mode="memberOf"/>
    </xsl:template>
    
    <xsl:template match="gmd:organisationName/gco:CharacterString" mode="memberOf">
        <org:memberOf>
            <foaf:Organization>
                <xsl:apply-templates select="."/>
            </foaf:Organization>
        </org:memberOf>
    </xsl:template>
    
    <xsl:template match="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*">
        <foaf:mbox rdf:resource="{concat('mailto:', text())}"/>
    </xsl:template>
    
    <xsl:template match="gmd:contactInfo/*/gmd:phone/*/gmd:voice/*">
        <foaf:phone rdf:resource="{concat('tel:+', translate(translate(translate(translate(translate(normalize-space(.),' ',''),'(',''),')',''),'+',''),'.',''))}"/>
    </xsl:template>
    
    <xsl:template match="gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/*">
        <foaf:homepage rdf:resource="{text()}" />
    </xsl:template>
    
    <xsl:template match="gmd:contactInfo/*/gmd:address/*">
        <locn:address>
            <locn:Address>
                <xsl:apply-templates select="gmd:deliveryPoint/*[text()]"/>
                <xsl:apply-templates select="gmd:city/*[text()]"/>
                <xsl:apply-templates select="gmd:postalCode/*[text()]"/>
                <xsl:apply-templates select="gmd:administrativeArea/*[text()]"/>
                <xsl:apply-templates select="gmd:country/*[text()]"/>
            </locn:Address>
        </locn:address>
    </xsl:template>
    
    <xsl:template match="gmd:deliveryPoint/*">
        <locn:thoroughfare><xsl:value-of select="."/></locn:thoroughfare>
    </xsl:template>
    
    <xsl:template match="gmd:city/*">
        <locn:postName><xsl:value-of select="."/></locn:postName>
    </xsl:template>
    
    <xsl:template match="gmd:postalCode/*">
        <locn:postCode><xsl:value-of select="."/></locn:postCode>
    </xsl:template>
    
    <xsl:template match="gmd:administrativeArea/*">
        <locn:adminUnitL2><xsl:value-of select="."/></locn:adminUnitL2>
    </xsl:template>
    
    <xsl:template match="gmd:country/*">
        <locn:adminUnitL1><xsl:value-of select="."/></locn:adminUnitL1>
    </xsl:template>
    
    <xsl:template name="vcardOrg">
        <rdf:Description>
            <xsl:variable name="orgLink" select="string(gmd:organisationName/gmx:Anchor/@xlink:href)"/>
            <xsl:variable name="indLink" select="string(gmd:individualName/gmx:Anchor/@xlink:href)"/>
            <xsl:choose>
                <xsl:when test="$indLink != ''">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$indLink"/></xsl:attribute>
                </xsl:when>
                <xsl:when test="$orgLink != ''">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$orgLink"/></xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:variable name="orgName" select="string(gmd:organisationName/gco:CharacterString)"/>
            <xsl:variable name="indName" select="string(gmd:individualName/gco:CharacterString)"/>
            <xsl:choose>
                <xsl:when test="$indName != ''">
                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Individual"/>
                </xsl:when>
                <xsl:when test="$orgName != ''">
                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Organization"/>
                </xsl:when>
                <xsl:otherwise>
                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Kind"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="gmd:organisationName/gco:CharacterString[text()]" mode="vcard"/>
            <xsl:apply-templates select="gmd:individualName/gco:CharacterString[text()]" mode="vcard"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString[not(contains(text, ';') or contains(text, ',') or contains(text, ' '))]" mode="vcard"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:phone/*/gmd:voice/*[text()]"  mode="vcard"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/*[text()]" mode="vcard"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:address/*" mode="vcard"/>
        </rdf:Description>
    </xsl:template>
    
    <xsl:template match="gmd:organisationName/gco:CharacterString" mode="vcard">
        <vcard:organization-name><xsl:value-of select="."/></vcard:organization-name>
    </xsl:template>
    
    <xsl:template match="gmd:individualName/gco:CharacterString" mode="vcard">
        <vcard:fn><xsl:value-of select="."/></vcard:fn>
    </xsl:template>
    
    <xsl:template match="gmd:electronicMailAddress/*" mode="vcard">
        <vcard:hasEmail rdf:resource="{concat('mailto:', .)}"/>
    </xsl:template>
    
    <xsl:template match="gmd:contactInfo/*/gmd:phone/*/gmd:voice/*" mode="vcard">
        <vcard:hasTelephone rdf:parseType="Resource">
            <vcard:hasValue rdf:resource="{concat('tel:+', translate(translate(translate(translate(translate(normalize-space(.),' ',''),'(',''),')',''),'+',''),'.',''))}"/>
            <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Voice"/>
        </vcard:hasTelephone>
    </xsl:template>
    
    <xsl:template match="gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/*" mode="vcard">
        <vcard:hasURL rdf:resource="{.}"/>
    </xsl:template>
    
    <xsl:template match="gmd:contactInfo/*/gmd:address/*" mode="vcard">
        <vcard:hasAddress>
            <vcard:Address>
                <xsl:apply-templates select="gmd:deliveryPoint/*[text()]" mode="vcard"/>
                <xsl:apply-templates select="gmd:city/*[text()]" mode="vcard"/>
                <xsl:apply-templates select="gmd:postalCode/*[text()]" mode="vcard"/>
                <xsl:apply-templates select="gmd:administrativeArea/*[text()]" mode="vcard"/>
                <xsl:apply-templates select="gmd:country/*[text()]" mode="vcard"/>
            </vcard:Address>
        </vcard:hasAddress>
    </xsl:template>
    
    <xsl:template match="gmd:deliveryPoint/*" mode="vcard">
        <vcard:street-address><xsl:value-of select="."/></vcard:street-address>
    </xsl:template>
    
    <xsl:template match="gmd:city/*" mode="vcard">
        <vcard:locality><xsl:value-of select="."/></vcard:locality>
    </xsl:template>
    
    <xsl:template match="gmd:postalCode/*" mode="vcard">
        <vcard:postal-code><xsl:value-of select="."/></vcard:postal-code>
    </xsl:template>
    
    <xsl:template match="gmd:administrativeArea/*" mode="vcard">
        <vcard:region><xsl:value-of select="."/></vcard:region>
    </xsl:template>
    
    <xsl:template match="gmd:country/*" mode="vcard">
        <vcard:country-name><xsl:value-of select="."/></vcard:country-name>
    </xsl:template>
    
    <xsl:template name="serviceDistribution">
        <xsl:variable name="accessUrl">
            <xsl:variable name="getCapsUrl" select="gmd:identificationInfo[1]/*/srv:containsOperations/*[srv:operationName/* = 'GetCapabilities']/srv:connectPoint/*/gmd:linkage/*"/>
            <xsl:choose>
                <xsl:when test="$getCapsUrl">
                    <xsl:value-of select="$getCapsUrl"/>
                </xsl:when>
                <xsl:when test="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*[text()]">
                    <xsl:value-of select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="gmd:distributionInfo/*/gmd:distributor/*/gmd:distributorTransferOptions/*/gmd:onLine/*/gmd:linkage/*"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$accessUrl != ''">
            <dcat:distribution>
                <dcat:Distribution>
                    <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:title/gco:CharacterString[text()]"/>
                    <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:abstract/gco:CharacterString[text()]"/>
                    <dcat:accessURL rdf:resource="{$accessUrl}"/>
                    <xsl:apply-templates select="gmd:identificationInfo/*/srv:serviceType[*/text()]"/>
                    <xsl:apply-templates select="ancestor::gmd:MD_Metadata/gmd:identificationInfo/*/gmd:characterSet/*/@codeListValue|ancestor::gmi:MI_Metadata/gmd:identificationInfo/*/gmd:characterSet/*/@codeListValue"/>
                    <xsl:call-template name="constraints"/>
                </dcat:Distribution>
            </dcat:distribution>
        </xsl:if>
    </xsl:template>
<!--
    <xsl:template match="srv:operationName/*|srv:serviceType/*|gmd:title/*" mode="title">
        <dct:title>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="text()"/>
        </dct:title>
    </xsl:template>
-->
    <xsl:template match="srv:serviceType[* = 'WMS' or * = 'wms' or */text() = 'view' or * = 'VIEW' or * = 'View' or * = 'OGC:WMS']">
        <xsl:call-template name="dctFormat">
            <xsl:with-param name="format" select="'WMS'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- download could also be WCS? -->
    <xsl:template match="srv:serviceType[* = 'WFS' or * = 'wfs' or * = 'download' or * = 'DOWNLOAD' or * = 'Download' or * = 'OGC:WFS']">
        <xsl:call-template name="dctFormat">
            <xsl:with-param name="format" select="'WFS'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="srv:serviceType[* = 'WCS' or * = 'wcs' or * = 'OGC:WCS']">
        <xsl:call-template name="dctFormat">
            <xsl:with-param name="format" select="'WCS'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="srv:serviceType">
        <xsl:call-template name="dctFormat">
            <xsl:with-param name="format" select="*"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="dctFormat">
        <xsl:param name="format"/>
        <xsl:param name="version" select="../srv:serviceTypeVersion/*[text()]"/>
        <xsl:choose>
            <xsl:when test="$version!=''">
                <dct:format rdf:parseType="Resource">
                    <rdfs:label>
                        <xsl:value-of select="$format"/>
                    </rdfs:label>
                    <dct:hasVersion rdf:parseType="Resource">
                        <vcard:hasValue rdf:resource="{$version}"/>
                    </dct:hasVersion>
                </dct:format>
            </xsl:when>
            <xsl:otherwise>
                <dct:format>
                    <xsl:value-of select="$format"/>
                </dct:format>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="dataDistributionNRW">
        <xsl:variable name="distributionLinks" select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*[gmd:function/*/@codeListValue='download' and gmd:linkage/*[text()]]"/>
        <xsl:apply-templates select="$distributionLinks" mode="nrw"/>
    </xsl:template>

    <xsl:template name="dataDistribution">
        <xsl:variable name="distributorLinks" select="gmd:distributionInfo/*/gmd:distributor/*/gmd:distributorTransferOptions/*/gmd:onLine/*[gmd:linkage/*[text()]]"/>
        <xsl:variable name="distributionLinks" select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*[gmd:linkage/*[text()]]"/>
        <xsl:for-each select="$distributorLinks">
            <xsl:variable name="link" select="gmd:linkage/*/text()"/>
            <xsl:if test="not($distributionLinks/gmd:linkage/*[text() = $link])">
                <xsl:apply-templates select="."/>
            </xsl:if>
        </xsl:for-each>
        <xsl:apply-templates select="$distributionLinks"/>
    </xsl:template>
    
    <xsl:template match="gmd:CI_OnlineResource" mode="nrw">
        <dcat:distribution>
            <dcat:Distribution>
                <xsl:apply-templates select="ancestor::gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString[text()]"/>
                <xsl:apply-templates select="ancestor::gmd:MD_Metadata/gmd:identificationInfo/*/gmd:abstract/gco:CharacterString[text()]"/>
                <dcat:downloadURL rdf:resource="{gmd:linkage/*}"/>
                <dcat:accessURL rdf:resource="{gmd:linkage/*}"/>
                <xsl:apply-templates select="../../../../gmd:transferOptions/*/gmd:onLine/*[gmd:function/*/@codeListValue='information' and gmd:linkage/*[text()]]"/>
                <xsl:apply-templates select="ancestor::gmd:distributionInfo/*/gmd:distributionFormat[1]/*/gmd:name/gco:CharacterString[text()]"/>
                <xsl:call-template name="constraints"/>
            </dcat:Distribution>
        </dcat:distribution>
    </xsl:template>
    
<!--
    <xsl:template match="gmd:CI_OnlineResource[gmd:function/*/@codeListValue = 'download' or gmd:function/*/@codeListValue = 'offlineAccess' or gmd:function/*/@codeListValue = 'order']">
    <dcat:distribution>
    <dcat:Distribution>
    <xsl:apply-templates select="gmd:name/gco:CharacterString[text()]"/>
    <xsl:apply-templates select="gmd:description/gco:CharacterString[text()]"/>
    <xsl:apply-templates select="gmd:linkage/*"/>
    <xsl:variable name="distributorFormat" select="../../../../gmd:distributorFormat/*/gmd:name/gco:CharacterString[text()]"/>
    <xsl:choose>
    <xsl:when test="$distributorFormat">
    <xsl:apply-templates select="$distributorFormat"/>
    </xsl:when>
    <xsl:otherwise>
    <xsl:apply-templates select="ancestor::gmd:distributionInfo/*/gmd:distributionFormat[1]/*/gmd:name/gco:CharacterString[text()]"/>
    </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="ancestor::gmd:MD_Metadata/gmd:identificationInfo/*/gmd:characterSet/*/@codeListValue|ancestor::gmi:MI_Metadata/gmd:identificationInfo/*/gmd:characterSet/*/@codeListValue"/>
    <xsl:call-template name="constraints"/>
    </dcat:Distribution>
    </dcat:distribution>
    </xsl:template>
-->
    <xsl:template match="gmd:CI_OnlineResource[gmd:function/*/@codeListValue = 'information' or gmd:function/*/@codeListValue = 'search']">
        <foaf:page>
            <xsl:call-template name="foafDocument"/>
        </foaf:page>
    </xsl:template>

    <xsl:template match="gmd:CI_OnlineResource[not(gmd:function/*/@codeListValue)]">
        <dcat:landingPage>
            <xsl:call-template name="foafDocument"/>
        </dcat:landingPage>
    </xsl:template>

    <xsl:template name="foafDocument">
        <foaf:Document rdf:about="{gmd:linkage/*}">
            <xsl:apply-templates select="gmd:name/gco:CharacterString[text()]"/>
            <xsl:apply-templates select="../../srv:operationName/gco:CharacterString[text()]"/>
            <xsl:apply-templates select="gmd:description/gco:CharacterString[text()]"/>
        </foaf:Document>
    </xsl:template>

    <xsl:template match="gmd:CI_OnlineResource/gmd:name/*|srv:containsOperations/*/srv:operationName/*">
        <dct:title>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="."/>
        </dct:title>
    </xsl:template>

    <xsl:template match="gmd:CI_OnlineResource/gmd:description/gco:CharacterString">
        <dct:description>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="."/>
        </dct:description>
        <xsl:apply-templates select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" mode="param"/>
    </xsl:template>

    <xsl:template match="gmd:CI_OnlineResource[not(gmd:function/*/@codeListValue = 'download')]/gmd:linkage/*|gmd:citation/*/gmd:identifier/*/gmd:code/*">
        <dcat:accessURL rdf:resource="{.}"/>
    </xsl:template>

    <xsl:template match="gmd:CI_OnlineResource[gmd:function/*/@codeListValue = 'download']/gmd:linkage/*">
        <dcat:downloadURL rdf:resource="{.}"/>
    </xsl:template>


    <xsl:template name="constraints">
        <xsl:choose>
            <xsl:when test="$openNRW!='true'">
                <xsl:variable name="useLimitations" select="ancestor::gmd:MD_Metadata/gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation[gco:CharacterString!=$c_no_limitation] |
                    ancestor::gmi:MI_Metadata/gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation[gco:CharacterString!=$c_no_limitation]"/>
                <xsl:apply-templates select="$useLimitations[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="accessConstraints" select="ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:resourceConstraints/*[*/gmd:MD_RestrictionCode/@codeListValue=$c_other_restrictions]/gmd:otherConstraints[gco:CharacterString != $c_no_limitation]"/>
                <xsl:variable name="accessConstraintsJson" select="$accessConstraints[starts-with(normalize-space(gco:CharacterString), '{')]"/>
                <xsl:choose>
                    <xsl:when test="count($accessConstraintsJson) &gt; 0">
                        <xsl:apply-templates select="$accessConstraintsJson[1]" mode="license"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$accessConstraints[1]" mode="license"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:resourceConstraints/*/gmd:useLimitation">
        <xsl:if test="(gco:CharacterString/text() or gmx:Anchor) and gco:CharacterString/text()!=$c_no_limitation">
            <dct:license>
                <xsl:apply-templates select="*" mode="license"/>
            </dct:license>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:useLimitation/gco:CharacterString|gmd:otherConstraints/gco:CharacterString" mode="license">
        <dct:LicenseDocument>
            <xsl:call-template name="jsonLicenseToUrl"/>
            <rdfs:label>
                <xsl:call-template name="xmlLang"/>
                <xsl:value-of select="."/>
            </rdfs:label>
            <xsl:apply-templates select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" mode="param">
                <xsl:with-param name="mode" select="'label'"/>
            </xsl:apply-templates>
        </dct:LicenseDocument>
    </xsl:template>

    <xsl:template match="gmd:useLimitation/gmx:Anchor|gmd:otherConstraints/gmx:Anchor" mode="license">
        <xsl:attribute name="rdf:resource">
            <xsl:value-of select="@xlink:href"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="gmd:MD_RestrictionCode[@codeListValue!=$c_other_restrictions]" mode="license">
        <dct:license>
            <xsl:choose>
                <xsl:when test="$openNRW!='true' or (@codeListValue!=$c_license and ../../gmd:accessConstraints/*/@codeListValue!=$c_license)">
                    <dct:LicenseDocument>
                        <rdfs:label>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="@codeListValue"/>
                        </rdfs:label>
                    </dct:LicenseDocument>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="../../gmd:otherConstraints" mode="license"/>
                </xsl:otherwise>
            </xsl:choose>
        </dct:license>
    </xsl:template>
    
    <xsl:template name="jsonLicenseToUrl">
        <xsl:if test="starts-with(normalize-space(.), '{')">
            <xsl:variable name="jsonWithUrl" select="substring-after(., '&quot;url&quot;')"/>
            <xsl:variable name="url" select="substring-before(substring-after($jsonWithUrl, '&quot;'), '&quot;')"/>
            <xsl:if test="$url">
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$url"/>
                </xsl:attribute>
            </xsl:if>
        </xsl:if>
    </xsl:template>
<!--
    <xsl:template match="gmd:MD_RestrictionCode[@codeListValue!=$c_other_restrictions]" mode="accessRights">
        <dct:accessRights>
            <xsl:choose>
                <xsl:when test="$openNRW!='true' or (@codeListValue!=$c_license and ../../gmd:accessConstraints/*/@codeListValue!=$c_license)">
                    <xsl:call-template name="rightsStatement">
                        <xsl:with-param name="value" select="@codeListValue"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="../../gmd:otherConstraints/*"/>
                </xsl:otherwise>
            </xsl:choose>
        </dct:accessRights>
    </xsl:template>

    <xsl:template match="gmd:MD_RestrictionCode[@codeListValue=$c_other_restrictions]" mode="accessRights"/>

    <xsl:template match="gmd:resourceConstraints/*/gmd:accessConstraints/*[@codeListValue!=$c_license and @codeListValue!=$c_other_restrictions]/@codeListValue">
        <dct:rights>
            <xsl:call-template name="rightsStatement">
                <xsl:with-param name="value" select="."/>
            </xsl:call-template>
        </dct:rights>
    </xsl:template>
-->
    <xsl:template name="rightsStatement">
        <xsl:param name="value"/>
        <dct:RightsStatement>
            <rdfs:label>
                <xsl:call-template name="xmlLang"/>
                <xsl:value-of select="$value"/>
            </rdfs:label>
            <xsl:apply-templates select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" mode="param"/>
        </dct:RightsStatement>
    </xsl:template>

    <xsl:template match="gmd:resourceConstraints/*/gmd:otherConstraints" mode="license">
        <dct:license>
            <xsl:apply-templates select="*" mode="license"/>
        </dct:license>
    </xsl:template>

    <xsl:template match="gmd:resourceConstraints/*/gmd:otherConstraints">
        <dct:accessRights>
            <xsl:apply-templates select="*"/>
        </dct:accessRights>
    </xsl:template>

    <xsl:template match="gmd:otherConstraints/gco:CharacterString">
        <xsl:call-template name="rightsStatement">
            <xsl:with-param name="value" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="gmd:otherConstraints/gmx:Anchor">
        <xsl:attribute name="rdf:resource">
            <xsl:value-of select="@xlink:href"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="gmd:distributionFormat/*/gmd:name/gmx:Anchor | gmd:distributorFormat/*/gmd:name/gmx:Anchor">
        <xsl:call-template name="dctFormat">
            <xsl:with-param name="format" select="@xlink:href"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="gmd:distributionFormat/*/gmd:name/gco:CharacterString | gmd:distributorFormat/*/gmd:name/gco:CharacterString">
        <xsl:variable name="formatName" select="text()"/>
        <xsl:variable name="formatNameUC" select="translate($formatName,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        <xsl:variable name="mdrUri" select="$mdrFileTypes/*/skos:Concept[*/text() = $formatNameUC]/@rdf:about"/>
        <xsl:choose>
            <xsl:when test="$mdrUri">
                <xsl:call-template name="dctFormat">
                    <xsl:with-param name="format" select="$mdrUri"/>
                    <xsl:with-param name="version" select="../../gmd:version/gco:CharacterString"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ianaMediaTypes/registry/file[text() = $formatName]">
                <dcat:mediaType rdf:resource="{concat('https://www.iana.org/assignments/media-types/', $formatName)}"/>
            </xsl:when>
            <xsl:otherwise>
                <!--omit the format if it is unknown -->
                <xsl:call-template name="dctFormat">
                    <xsl:with-param name="format" select="."/>
                    <xsl:with-param name="version" select="../../gmd:version/gco:CharacterString"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:characterSet/*/@codeListValue">
        <!--<xsl:if test="$extended">-->
            <!--<cnt:characterEncoding rdf:datatype="http://www.w3.org/2001/XMLSchema#string">-->
                <!--<xsl:value-of select="."/>-->
            <!--</cnt:characterEncoding>-->
        <!--</xsl:if>-->
        <cnt:characterEncoding rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
            <xsl:value-of select="."/>
        </cnt:characterEncoding>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*">
        <dct:identifier>
            <xsl:apply-templates select="." mode="identifier"/>
        </dct:identifier>
    </xsl:template>

    <xsl:template match="gmd:identifier/*[not(gmd:codeSpace)]/gmd:code/*" mode="identifier">
        <xsl:apply-templates select="." mode="identifierType"/>
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="gmd:identifier/*[gmd:codeSpace and substring(gmd:codeSpace/*,string-length(gmd:codeSpace/*),1) != '/']/gmd:code/*" mode="identifier">
        <xsl:apply-templates select="../../gmd:codeSpace/*" mode="identifierType"/>
        <xsl:call-template name="replace">
            <xsl:with-param name="str" select="concat(../../gmd:codeSpace/*, '/', ../../gmd:code/*)"/>
            <xsl:with-param name="from" select="' '"/>
            <xsl:with-param name="to" select="'%20'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="gmd:identifier/*[gmd:codeSpace and substring(gmd:codeSpace/*,string-length(gmd:codeSpace/*),1) = '/']/gmd:code/*" mode="identifier">
        <xsl:apply-templates select="../../gmd:codeSpace/*" mode="identifierType"/>
        <xsl:call-template name="replace">
            <xsl:with-param name="str" select="concat(../../gmd:codeSpace/*, ../../gmd:code/*)"/>
            <xsl:with-param name="from" select="' '"/>
            <xsl:with-param name="to" select="'%20'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[starts-with(text(), 'http://') or starts-with(text(), 'https://')]" mode="identifierType">
        <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#anyURI</xsl:attribute>
    </xsl:template>

    <xsl:template match="*[not(starts-with(text(), 'http://') or starts-with(text(), 'https://'))]" mode="identifierType">
        <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>
    </xsl:template>

    <xsl:template name="replace">
        <xsl:param name="str"/>
        <xsl:param name="from"/>
        <xsl:param name="to"/>
        <xsl:choose>
            <xsl:when test="contains($str, $from)">
                <xsl:value-of select="concat(substring-before($str, $from), $to)"/>
                <xsl:call-template name="replace">
                    <xsl:with-param name="str" select="substring-after($str, $from)"/>
                    <xsl:with-param name="from" select="$from"/>
                    <xsl:with-param name="to" select="$to"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:parentIdentifier/*[text()]">
        <dct:isPartOf rdf:resource="{text()}"/>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[not(gmd:thesaurusName)]/gmd:keyword/gco:CharacterString">
        <xsl:call-template name="dcatKeyword"/>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[starts-with(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*, 'GEMET - INSPIRE themes')]/gmd:keyword[position() &gt; 1]/gco:CharacterString">
        <xsl:call-template name="dcatKeyword"/>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[starts-with(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*, 'GEMET - INSPIRE themes')]/gmd:keyword[1]/gco:CharacterString">
        <xsl:variable name="themeLabel" select="text()"/>
        <xsl:variable name="themeUri" select="$inspireThemes/rdf:RDF/rdf:Description[dct:title = $themeLabel]/@rdf:about"/>
        <xsl:choose>
            <xsl:when test="$themeUri and $openNRW!='true'">
                <dcat:theme rdf:resource="{$themeUri}"/>
                <xsl:call-template name="euroVocDomain">
                    <xsl:with-param name="inspireTheme" select="$themeUri"/>
                </xsl:call-template>
                <xsl:variable name="euroVocUri" select="$euroVocMapping/rdf:RDF/rdf:Description[skos:exactMatch/@rdf:resource=$themeUri]/@rdf:about"/>
                <xsl:choose>
                    <xsl:when test="$euroVocUri">
                        <dcat:theme rdf:resource="{$euroVocUri}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="broaderEuroVocUri" select="$euroVocMapping/rdf:RDF/rdf:Description[skos:narrowMatch/@rdf:resource=$themeUri]/@rdf:about"/>
                        <xsl:if test="$broaderEuroVocUri">
                            <dcat:theme rdf:resource="{$broaderEuroVocUri}"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$extended">
                <xsl:call-template name="themeSkos"/>
                <xsl:if test="$openNRW!='true'">
                    <xsl:apply-templates select="ancestor::gmd:MD_Metadata/gmd:identificationInfo/*/gmd:topicCategory/*|ancestor::gmi:MI_Metadata/gmd:identificationInfo/*/gmd:topicCategory/*" mode="dcatTheme"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="dcatKeyword"/>
                <xsl:if test="$openNRW!='true'">
                    <xsl:apply-templates select="ancestor::gmd:MD_Metadata/gmd:identificationInfo/*/gmd:topicCategory/*|ancestor::gmi:MI_Metadata/gmd:identificationInfo/*/gmd:topicCategory/*" mode="dcatTheme"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[gmd:thesaurusName and not(starts-with(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*, 'GEMET - INSPIRE themes'))]/gmd:keyword/gco:CharacterString">
        <xsl:choose>
            <xsl:when test="$extended">
                <xsl:call-template name="themeSkos"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="dcatKeyword"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="dcatKeyword">
        <dcat:keyword>
            <xsl:apply-templates select="." mode="dcatKeyword"/>
        </dcat:keyword>
        <xsl:apply-templates select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString"/>
    </xsl:template>

    <xsl:template match="gmx:Anchor" mode="dcatKeyword">
        <xsl:attribute name="rdf:resource">
            <xsl:value-of select="@xlink:href"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="*" mode="dcatKeyword">
        <xsl:call-template name="xmlLang"/>
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template name="themeSkos">
        <dcat:theme>
            <skos:Concept>
                <skos:prefLabel>
                    <xsl:value-of select="."/>
                </skos:prefLabel>
                <skos:inScheme>
                    <skos:ConceptScheme>
                        <rdfs:label>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="../../gmd:thesaurusName/*/gmd:title/*"/>
                        </rdfs:label>
                        <xsl:apply-templates select="../../gmd:thesaurusName/*/gmd:date/*[gmd:dateType/*/@codeListValue='creation']/gmd:date/*"/>
                    </skos:ConceptScheme>
                </skos:inScheme>
            </skos:Concept>
        </dcat:theme>
    </xsl:template>

    <xsl:template match="gmd:keyword/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
        <xsl:variable name="localeRef" select="substring-after(@locale, '#')"/>
        <xsl:variable name="locale" select="ancestor::gmd:MD_Metadata/gmd:locale/*[@id = $localeRef]|ancestor::gmi:MI_Metadata/gmd:locale/*[@id = $localeRef]"/>
        <xsl:if test="$locale">
            <dcat:keyword>
                <xsl:apply-templates select="$locale/gmd:languageCode/*" mode="xmlLang"/>
                <xsl:value-of select="."/>
            </dcat:keyword>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement/gco:CharacterString">
        <dct:provenance>
            <dct:ProvenanceStatement>
                <rdfs:label>
                    <xsl:call-template name="xmlLang"/>
                    <xsl:value-of select="."/>
                </rdfs:label>
                <xsl:apply-templates select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" mode="param">
                    <xsl:with-param name="mod" select="'label'"/>
                </xsl:apply-templates>
            </dct:ProvenanceStatement>
        </dct:provenance>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:topicCategory/*">
        <dct:subject rdf:resource="{concat($inspire_md_codelist, 'TopicCategory/', .)}"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='continual']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/CONT"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='fortnightly']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/BIWEEKLY"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='biannually']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/ANNUAL_2"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='annually']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/ANNUAL"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='irregular']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/IRREG"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='daily']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/DAILY"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='weekly']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/WEEKLY"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='monthly']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/MONTHLY"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='quarterly']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/QUARTERLY"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='unknown']">
        <dct:accrualPeriodicity rdf:resource="http://publications.europa.eu/resource/authority/frequency/UNKNOWN"/>
    </xsl:template>

    <xsl:template match="gmd:maintenanceAndUpdateFrequency/*/@codeListValue[.='asNeeded' or .='notPlanned']">
        <dct:accrualPeriodicity rdf:resource="{concat('http://inspire.ec.europa.eu/metadata-codelist/MaintenanceFrequencyCode/', .)}"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='farming']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/AGRI"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='biota' or .='climatologyMeteorologyAtmosphere' or
     .='elevation' or .='environment' or .='imageryBaseMapsEarthCover' or .='inlandWaters' or .='oceans']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ENVI"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='boundaries' or .='location' or .='planningCadastre']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/REGI"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='economy']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ECON"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='geoscientificInformation']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ENVI"/>
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/REGI"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='health']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/HEAL"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='intelligenceMilitary']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/JUST"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='society']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/SOCI"/>
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/EDUC"/>
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/JUST"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='transportation']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/TRAN"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode[.='utilitiesCommunication']" mode="openNRW">
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ENER"/>
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/INTR"/>
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/GOVE"/>
        <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/TECH"/>
    </xsl:template>

    <xsl:template match="gmd:MD_TopicCategoryCode" mode="openNRW"/>

    <xsl:template match="gmd:identificationInfo/*/gmd:topicCategory/*" mode="dcatTheme">
        <xsl:param name="ckanTheme" select="''"/>
        <xsl:call-template name="euroVocDomain">
            <xsl:with-param name="inspireTheme" select="text()"/>
            <xsl:with-param name="ckanTheme" select="$ckanTheme"/>
        </xsl:call-template>
    </xsl:template>

    <!-- mapping of INSPIRE themes / ISO topicCategory to the EuroVoc domain and categorization topic -->
    <xsl:template name="euroVocDomain">
        <xsl:param name="inspireTheme"/>
        <xsl:param name="ckanTheme" select="''"/>
        <xsl:choose>
            <xsl:when test="$ckanTheme!=''">
                <dcat:theme rdf:resource="{concat('http://publications.europa.eu/resource/authority/data-theme/',$ckanTheme)}"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/ad' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/oi' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/rs' or
                $inspireTheme = 'intelligenceMilitary' or $inspireTheme = 'imageryBaseMapsEarthCover'
                or $inspireTheme = 'location'">
                <!-- there is no mapping for these themes -->
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/gn'">
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/REGI"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/ac' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/am' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/br' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/ef' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/el' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/er' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/hb' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/lc' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/mr' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/nz' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/of' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/ps' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/sr' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/sd' or
                $inspireTheme = 'biota' or $inspireTheme = 'climatologyMeteorologyAtmosphere' or
                $inspireTheme = 'elevation' or $inspireTheme = 'environment' or
                $inspireTheme = 'inlandWaters' or
                $inspireTheme = 'oceans'">
                <!-- environment -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100155"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ENVI"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/af' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/lu' or
                $inspireTheme = 'farming'">
                <!-- agriculture, forestry and fishery -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100156"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/AGRI"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/au' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/us' or
                $inspireTheme = 'boundaries'">
                <!-- politics -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100142"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/GOVE"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/bu' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/pf' or
                $inspireTheme = 'utilitiesCommunication' or $inspireTheme = 'structure'">
                <!-- industry -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100160"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ECON"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/cp' or
                $inspireTheme = 'planningCadastre'">
                <!-- law -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100145"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/JUST"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/hh' or
                $inspireTheme = 'health'">
                <!-- health -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100149"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/HEAL"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/pd' or
                $inspireTheme = 'society'">
                <!-- social questions -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100149"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/SOCI"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/ge' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/gg' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/hy' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/mf' or
                $inspireTheme = 'http://inspire.ec.europa.eu/theme/so' or
                $inspireTheme = 'geoscientificInformation'">
                <!-- sciences -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100151"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/TECH"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/su' or
                $inspireTheme = 'economy'">
                <!-- economics -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100146"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ECON"/>
            </xsl:when>
            <xsl:when test="$inspireTheme = 'http://inspire.ec.europa.eu/theme/tn' or
                $inspireTheme = 'transportation'">
                <!-- transport -->
                <dcat:theme rdf:resource="http://eurovoc.europa.eu/100154"/>
                <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/TRAN"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:language/*[@codeListValue]|gmd:language/gco:CharacterString">
        <xsl:variable name="code">
            <xsl:choose>
                <xsl:when test="@codeListValue">
                    <xsl:value-of select="@codeListValue"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <dct:language rdf:resource="{concat('http://publications.europa.eu/resource/authority/language/', translate($code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'))}"/>
    </xsl:template>

    <xsl:template name="xmlLang">
        <xsl:apply-templates select="
                ancestor-or-self::gmd:MD_Metadata/gmd:language/*[@codeListValue]|
                ancestor-or-self::gmd:MD_Metadata/gmd:language/gco:CharacterString|
                ancestor::gmi:MI_Metadata/gmd:language/*[@codeListValue]|
                ancestor::gmi:MI_Metadata/gmd:language/gco:CharacterString" mode="xmlLang"/>
    </xsl:template>

    <xsl:template match="gmd:language/*[@codeListValue]|gmd:language/gco:CharacterString" mode="xmlLang">
        <xsl:variable name="listValue" select="."/>
        <xsl:variable name="lang" select="$languageCodes/rdf:RDF/langCodes/langCode[@cswCode=$listValue]"/>
        <xsl:variable name="code">
            <xsl:choose>
                <xsl:when test="$lang">
                    <xsl:value-of select="$lang/@ckanCode"/>
                </xsl:when>
                <xsl:otherwise>de</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:attribute name="xml:lang">
            <xsl:value-of select="$code"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template priority="0" match="gmd:language/gco:CharacterString" mode="xmlLang">
        <xsl:attribute name="xml:lang">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <!--<xsl:template match="node()|@*"/>-->

</xsl:stylesheet>
