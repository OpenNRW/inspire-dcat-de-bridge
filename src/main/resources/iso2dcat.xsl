<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
                xmlns:earl="http://www.w3.org/ns/earl#"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cnt="http://www.w3.org/2011/content#"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:dcatde="http://dcat-ap.de/def/dcatde/"
                xmlns:adms="http://www.w3.org/ns/adms#"
                xmlns:org="http://www.w3.org/ns/org#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
                exclude-result-prefixes="gmd gmx gco srv xlink gmi csw">

    <xsl:output method="xml"/>

    <!-- Parameters from route -->
    <xsl:param name="contributorID"/>

    <!--
    <xsl:strip-space elements="*"/>
    -->
    <xsl:variable name="c_license">license</xsl:variable>
    <xsl:variable name="c_no_limitation">keine</xsl:variable>
    <xsl:variable name="c_other_restrictions">otherRestrictions</xsl:variable>

    <xsl:variable name="tokeDcatAp">:dcat_ap:</xsl:variable>
    <xsl:variable name="prefixDcatAp">dcat_ap</xsl:variable>

    <xsl:variable name="mdrFileTypes" select="document('filetypes-skos.rdf')"/>
    <xsl:variable name="ianaMediaTypes" select="document('iana-media-types.xml')"/>
    <xsl:variable name="languageCodes" select="document('languageCodes.rdf')"/>
    <xsl:variable name="inspireThemes" select="document('themes.rdf')"/>
    <xsl:variable name="dcatThemes" select="document('dcat-themes.rdf')"/>

    <xsl:variable name="inspire_md_codelist">http://inspire.ec.europa.eu/metadata-codelist/</xsl:variable>

    <xsl:variable name="resourceIdentifiers" select="replace(string-join(/csw:GetRecordsResponse/csw:SearchResults/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*, '|'), '#', '%23')"/>
    <xsl:variable name="coupledServicesUri">
        <xsl:value-of select="'direct:getCoupledServices'"/>
        <xsl:if test="/soapenv:Envelope" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
            <xsl:value-of select="'Soap11'"/>
        </xsl:if>
        <xsl:if test="/soap12:Envelope" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
            <xsl:value-of select="'Soap12'"/>
        </xsl:if>
        <xsl:value-of select="concat('?', $resourceIdentifiers)"/>
    </xsl:variable>
    <xsl:variable name="coupledServices" select="document($coupledServicesUri)"/>

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

            <!--dct:title-->
            <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:title/gco:CharacterString[text()]"/>

            <!--dct:description-->
            <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:abstract/gco:CharacterString[text()]"/>

            <!-- dcatde:contributorID -->
            <xsl:call-template name="contributorID"/>

            <!--dct:identifier-->
            <xsl:apply-templates select="gmd:fileIdentifier/gco:CharacterString"/>

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
            <xsl:variable name="accessConstraints" select="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*[*/gmd:MD_RestrictionCode/@codeListValue=$c_other_restrictions]/gmd:otherConstraints[. != $c_no_limitation]"/>
            <xsl:apply-templates select="$accessConstraints[1]"/>

            <!--dcat:keyword-->
            <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:descriptiveKeywords/*/gmd:keyword/gco:CharacterString[text()]"/>

            <!--dcatde:politicalGeocodingLevelURI-->
            <!--dcatde:politicalGeocodingURI-->

            <!--dct:spatial-->
            <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement|gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement"/>

            <!--dct:created dct:issued dct:modified-->
            <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue='publication' or gmd:dateType/*/@codeListValue='revision' or gmd:dateType/*/@codeListValue='creation']/gmd:date/*"/>

            <!--dcat:contactPoint dct:publisher dcatde:maintainer-->
            <xsl:variable name="pointOfContact" select="gmd:identificationInfo[1]/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='pointOfContact']"/>
            <xsl:variable name="publisher" select="gmd:identificationInfo[1]/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='publisher']"/>
            <xsl:apply-templates select="$pointOfContact | $publisher | gmd:identificationInfo[1]/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='custodian']"/>
            <xsl:choose>
                <xsl:when test="count($pointOfContact) = 0">
                    <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty" mode="contactPoint"/>
                    <xsl:if test="count($publisher) = 0">
                        <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty" mode="publisher"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="count($publisher) = 0">
                        <xsl:apply-templates select="$pointOfContact" mode="publisher"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation"/>
            <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue"/>
            <xsl:apply-templates select="gmd:hierarchyLevel"/>

            <!--dcat:distribution-->
            <xsl:call-template name="dataDistribution"/>

            <xsl:call-template name="dcatTheme"/>
        </dcat:Dataset>
    </xsl:template>

    <xsl:template name="contributorID">
        <xsl:if test="$contributorID">
            <dcatde:contributorID>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="$contributorID"/>
                </xsl:attribute>
            </dcatde:contributorID>
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

    <xsl:template match="gmd:specification/gmd:CI_Citation">
        <xsl:apply-templates select="." mode="conformsTo"/>
    </xsl:template>

    <xsl:template match="gmd:explanation/*">
        <earl:info>
            <xsl:call-template name="xmlLang"/>
            <xsl:value-of select="text()"/>
        </earl:info>
    </xsl:template>

    <xsl:template match="gmd:CI_Citation" mode="conformsTo"/>

    <!-- as we do not have the license URI at this point, no mapping -->
    <xsl:template match="gmd:CI_Citation[../../gmd:pass/gco:Boolean = 'true']" mode="conformsTo"/>

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
        match="gmd:dateStamp/*[text() castable as xs:date or text() castable as xs:dateTime]">
        <dct:modified>
            <xsl:call-template name="dateType"/>
            <xsl:value-of select="."/>
        </dct:modified>
    </xsl:template>

    <xsl:template match="gmd:hierarchyLevel[*/@codeListValue = 'dataset' or */@codeListValue = 'series']">
        <dct:type rdf:resource="{concat($inspire_md_codelist, 'ResourceType/', */@codeListValue)}"/>
    </xsl:template>

    <xsl:template match="gmd:hierarchyLevel"/>

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
        <xsl:if test="gmd:EX_GeographicBoundingBox[string(gmd:southBoundLatitude/*) != string(gmd:northBoundLatitude/*) and string(gmd:westBoundLongitude/*) != string(gmd:eastBoundLongitude/*)]">
            <dct:spatial>
                <dct:Location>
                    <xsl:apply-templates select="../gmd:description/gco:CharacterString"/>
                    <xsl:apply-templates select="gmd:EX_GeographicBoundingBox[string(gmd:southBoundLatitude/*) != string(gmd:northBoundLatitude/*) and string(gmd:westBoundLongitude/*) != string(gmd:eastBoundLongitude/*)]"/>
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

    <xsl:template name="dateType">
        <xsl:if test="text() castable as xs:date">
            <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#date</xsl:attribute>
        </xsl:if>
        <xsl:if test="text() castable as xs:dateTime">
            <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#dateTime</xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template
        match="gmd:date/*[gmd:dateType/*/@codeListValue = 'publication']/gmd:date/*[text() castable as xs:date or text() castable as xs:dateTime]">
        <xsl:if test="not(ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'revision']/gmd:date/*)">
            <dct:modified>
                <xsl:call-template name="dateType"/>
                <xsl:value-of select="."/>
            </dct:modified>
        </xsl:if>
        <xsl:if test="not(ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'creation']/gmd:date/*)">
            <dct:issued>
                <xsl:call-template name="dateType"/>
                <xsl:value-of select="."/>
            </dct:issued>
        </xsl:if>
    </xsl:template>

    <xsl:template
        match="gmd:date/*[gmd:dateType/*/@codeListValue = 'revision']/gmd:date/*[text() castable as xs:date or text() castable as xs:dateTime]">
        <dct:modified>
            <xsl:call-template name="dateType"/>
            <xsl:value-of select="."/>
        </dct:modified>
    </xsl:template>

    <xsl:template
        match="gmd:date/*[gmd:dateType/*/@codeListValue = 'creation']/gmd:date/*[text() castable as xs:date or text() castable as xs:dateTime]">
        <xsl:if
                test="not(ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'revision']/gmd:date/* or ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'publication']/gmd:date/*)">
            <dct:modified>
                <xsl:call-template name="dateType"/>
                <xsl:value-of select="."/>
            </dct:modified>
        </xsl:if>
        <dct:issued>
            <xsl:call-template name="dateType"/>
            <xsl:value-of select="."/>
        </dct:issued>
    </xsl:template>

    <xsl:template match="gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='pointOfContact']">
        <xsl:apply-templates select="." mode="contactPoint"/>
    </xsl:template>

    <xsl:template match="gmd:CI_ResponsibleParty" mode="contactPoint">
                    <dcat:contactPoint>
                        <xsl:call-template name="vcardOrg"/>
                    </dcat:contactPoint>
    </xsl:template>

    <xsl:template match="gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='publisher']">
        <xsl:apply-templates select="." mode="publisher"/>
    </xsl:template>

    <xsl:template match="gmd:CI_ResponsibleParty" mode="publisher">
                    <dct:publisher>
                        <xsl:call-template name="foafOrg"/>
                    </dct:publisher>
    </xsl:template>

    <xsl:template match="gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='custodian']">
                    <dcatde:maintainer>
                        <xsl:call-template name="foafOrg"/>
                    </dcatde:maintainer>
    </xsl:template>

    <xsl:template name="foafOrg">
        <rdf:Description>
            <xsl:variable name="orgName" select="string(gmd:organisationName/gco:CharacterString)"/>
            <xsl:variable name="indName" select="string(gmd:individualName/gco:CharacterString)"/>
            <xsl:choose>
                <xsl:when test="$orgName != ''">
                    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
                    <xsl:variable name="orgLink" select="string(gmd:organisationName/gmx:Anchor/@xlink:href)"/>
                    <xsl:if test="$orgLink != ''">
                        <xsl:attribute name="rdf:resource"><xsl:value-of select="$orgLink"/></xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="gmd:organisationName/gco:CharacterString[text()]"/>
                </xsl:when>
                <xsl:when test="$indName != ''">
                    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person"/>
                    <xsl:variable name="indLink" select="string(gmd:individualName/gmx:Anchor/@xlink:href)"/>
                    <xsl:if test="$indLink != ''">
                        <xsl:attribute name="rdf:resource"><xsl:value-of select="$indLink"/></xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="gmd:individualName/gco:CharacterString[text()]"/>
                </xsl:when>
                <xsl:otherwise>
                    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString[not(contains(text, ';') or contains(text, ',') or contains(text, ' '))]"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:phone/*/gmd:voice/*[text()]"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/*[text()]"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:address/*"/>
        </rdf:Description>
    </xsl:template>

    <xsl:template match="gmd:organisationName/gco:CharacterString|gmd:individualName/gco:CharacterString">
        <foaf:name><xsl:value-of select="."/></foaf:name>
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
            <xsl:variable name="orgName" select="string(gmd:organisationName/gco:CharacterString)"/>
            <xsl:variable name="indName" select="string(gmd:individualName/gco:CharacterString)"/>
            <xsl:choose>
                <xsl:when test="$orgName != ''">
                    <xsl:variable name="orgLink" select="string(gmd:organisationName/gmx:Anchor/@xlink:href)"/>
                    <xsl:if test="$orgLink != ''">
                        <xsl:attribute name="rdf:resource"><xsl:value-of select="$orgLink"/></xsl:attribute>
                    </xsl:if>
                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Organization"/>
                    <xsl:apply-templates select="gmd:organisationName/gco:CharacterString[text()]" mode="vcard"/>
                </xsl:when>
                <xsl:when test="$indName != ''">
                    <xsl:variable name="indLink" select="string(gmd:individualName/gmx:Anchor/@xlink:href)"/>
                    <xsl:if test="$indLink != ''">
                        <xsl:attribute name="rdf:resource"><xsl:value-of select="$indLink"/></xsl:attribute>
                    </xsl:if>
                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Individual"/>
                    <xsl:apply-templates select="gmd:individualName/gco:CharacterString[text()]" mode="vcard"/>
                </xsl:when>
                <xsl:otherwise>
                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Kind"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString[not(contains(text, ';') or contains(text, ',') or contains(text, ' '))]" mode="vcard"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:phone/*/gmd:voice/*[text()]"  mode="vcard"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/*[text()]" mode="vcard"/>
            <xsl:apply-templates select="gmd:contactInfo/*/gmd:address/*" mode="vcard"/>
        </rdf:Description>
    </xsl:template>

    <xsl:template match="gmd:organisationName/gco:CharacterString|gmd:individualName/gco:CharacterString" mode="vcard">
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

    <xsl:template match="srv:serviceType">
        <xsl:call-template name="dctFormat">
            <xsl:with-param name="format" select="*"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="dctFormat">
        <xsl:param name="format"/>
        <xsl:param name="version" select="../srv:serviceTypeVersion/*[text()]"/>
        <dct:format>
            <xsl:choose>
                <xsl:when test="starts-with($format, 'http:') or starts-with($format, 'https:')">
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$format"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$format"/>
                </xsl:otherwise>
            </xsl:choose>
        </dct:format>
    </xsl:template>

    <xsl:template name="dataDistribution">
        <xsl:variable name="distributionLinks" select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*[gmd:function/*/@codeListValue='download' and gmd:linkage/*[text()]]"/>
        <xsl:apply-templates select="$distributionLinks" mode="nrw"/>
        <!-- read and store license information start -->
        <xsl:variable name="accessConstraints" select="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*[*/gmd:MD_RestrictionCode/@codeListValue=$c_other_restrictions]/gmd:otherConstraints[gco:CharacterString != $c_no_limitation]"/>
        <xsl:variable name="accessConstraintsJson" select="$accessConstraints[starts-with(normalize-space(gco:CharacterString), '{')]"/>
        <!-- read and store license information end -->
        <xsl:variable name="resourceIdentifier" select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*"/>
        <!-- provide license information from metadata as fallback, if available -->
        <xsl:apply-templates select="$coupledServices/csw:GetRecordsResponse/csw:SearchResults/gmd:MD_Metadata[gmd:identificationInfo/*/srv:operatesOn/@xlink:href = $resourceIdentifier or gmd:identificationInfo/*/srv:operatesOn/@uuidref = $resourceIdentifier]" mode="serviceDistribution">
            <xsl:with-param name="licenseInMainMetadata" select="if (count($accessConstraintsJson) &gt; 0) then $accessConstraintsJson[1] else null"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="gmd:MD_Metadata" mode="serviceDistribution">
        <xsl:param name="licenseInMainMetadata"/>
        <xsl:variable name="serviceType" select="string(gmd:identificationInfo/*/srv:serviceType/*)"/>
        <xsl:variable name="capabilitiesLinkage" select="gmd:identificationInfo[1]/*/srv:containsOperations/*[lower-case(srv:operationName/*) = 'getcapabilities']/srv:connectPoint/*/gmd:linkage/*"/>
        <xsl:variable name="accessUrl">
            <xsl:if test="count($capabilitiesLinkage) &gt; 0">
                <xsl:variable name="ogcServiceType" select="if (lower-case($serviceType) = 'view') then 'WMS' else if (lower-case($serviceType) = 'download') then 'WFS' else $serviceType"/>
                <xsl:value-of select="if (ends-with(normalize-space($capabilitiesLinkage[1]), '?')) then concat(normalize-space($capabilitiesLinkage[1]), 'REQUEST=GetCapabilities&amp;SERVICE=', $ogcServiceType) else normalize-space($capabilitiesLinkage[1])"/>
            </xsl:if>
            <xsl:if test="count($capabilitiesLinkage) = 0">
                <xsl:value-of select="gmd:identificationInfo[1]/*/srv:containsOperations[1]/*/srv:connectPoint/*/gmd:linkage/*"/>
            </xsl:if>
        </xsl:variable>
        <dcat:distribution>
            <dcat:Distribution rdf:about="{$accessUrl}#distribution">
                <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:title/gco:CharacterString[text()]"/>
                <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:abstract/gco:CharacterString[text()]"/>
                <xsl:call-template name="dctFormat">
                    <xsl:with-param name="format" select="if ($serviceType = '') then 'Unbekannt' else $serviceType"/>
                </xsl:call-template>
                <dcat:accessURL rdf:resource="{$accessUrl}"/>
                <xsl:apply-templates select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue='publication' or gmd:dateType/*/@codeListValue='revision' or gmd:dateType/*/@codeListValue='creation']/gmd:date/*"
                    mode="serviceDistribution"/>
                <xsl:call-template name="constraints">
                    <xsl:with-param name="licenseInMainMetadata" select="$licenseInMainMetadata"/>
                </xsl:call-template>
            </dcat:Distribution>
        </dcat:distribution>
    </xsl:template>

    <xsl:template
        match="gmd:date/*[gmd:dateType/*/@codeListValue = 'publication']/gmd:date/*[text() castable as xs:date or text() castable as xs:dateTime]"
        mode="serviceDistribution">
        <xsl:if test="not(ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'revision']/gmd:date/*)">
            <dct:modified>
                <xsl:call-template name="dateType"/>
                <xsl:value-of select="."/>
            </dct:modified>
        </xsl:if>
    </xsl:template>

    <xsl:template
        match="gmd:date/*[gmd:dateType/*/@codeListValue = 'revision']/gmd:date/*[text() castable as xs:date or text() castable as xs:dateTime]"
        mode="serviceDistribution">
        <dct:modified>
            <xsl:call-template name="dateType"/>
            <xsl:value-of select="."/>
        </dct:modified>
    </xsl:template>

    <xsl:template
        match="gmd:date/*[gmd:dateType/*/@codeListValue = 'creation']/gmd:date/*[text() castable as xs:date or text() castable as xs:dateTime]"
        mode="serviceDistribution">
        <xsl:if
            test="not(ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'revision']/gmd:date/* or ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date/*[gmd:dateType/*/@codeListValue = 'publication']/gmd:date/*)">
            <dct:modified>
                <xsl:call-template name="dateType"/>
                <xsl:value-of select="."/>
            </dct:modified>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:CI_OnlineResource" mode="nrw">
        <dcat:distribution>
            <dcat:Distribution rdf:about="{gmd:linkage/*}#distribution">
                <xsl:variable name="linkage" select="string(gmd:linkage/*)"/>
                <xsl:choose>
                    <xsl:when test="gmd:name/*[text() != ''] | gmd:description/*[text() != '']">
                        <dct:title>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:choose>
                                <xsl:when test="gmd:name/*[text() != '']">
                                    <xsl:value-of select="gmd:name/*"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="gmd:description/*"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </dct:title>
                        <dct:description>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:choose>
                                <xsl:when test="gmd:description/*[text() != '']">
                                    <xsl:value-of select="gmd:description/*"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="gmd:name/*"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </dct:description>
                    </xsl:when>
                    <xsl:when test="starts-with($linkage, 'http') and contains($linkage, '?')">
                        <dct:title>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="$linkage"/>
                        </dct:title>
                        <dct:description>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="$linkage"/>
                        </dct:description>
                    </xsl:when>
                    <xsl:when test="contains(gmd:linkage/*, '/')">
                        <dct:title>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="tokenize($linkage,'/')[last()]"/>
                        </dct:title>
                        <dct:description>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="tokenize($linkage,'/')[last()]"/>
                        </dct:description>
                    </xsl:when>
                    <xsl:when test="contains(gmd:linkage/*, '\')">
                        <dct:title>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="tokenize($linkage,'\')[last()]"/>
                        </dct:title>
                        <dct:description>
                            <xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="tokenize($linkage,'\')[last()]"/>
                        </dct:description>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="ancestor::gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString[text()]"/>
                        <xsl:apply-templates select="ancestor::gmd:MD_Metadata/gmd:identificationInfo/*/gmd:abstract/gco:CharacterString[text()]"/>
                    </xsl:otherwise>
                </xsl:choose>
                <dcat:downloadURL rdf:resource="{gmd:linkage/*}"/>
                <dcat:accessURL rdf:resource="{gmd:linkage/*}"/>
                <xsl:apply-templates select="../../../../gmd:transferOptions/*/gmd:onLine/*[gmd:function/*/@codeListValue='information' and gmd:linkage/*[text()]]"/>
                <xsl:apply-templates select="gmd:applicationProfile/gco:CharacterString[text()] | ancestor::gmd:distributionInfo/*/gmd:distributionFormat[1]/*/gmd:name/gco:CharacterString[text()]"/>
                <xsl:call-template name="constraints"/>
            </dcat:Distribution>
        </dcat:distribution>
    </xsl:template>

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

    <xsl:template match="gmd:CI_OnlineResource/gmd:name/*">
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

    <xsl:template match="gmd:transferOptions/*/gmd:onLine/gmd:CI_OnlineResource[not(gmd:function/*/@codeListValue = 'download')]/gmd:linkage/*">
        <dcat:accessURL rdf:resource="{.}"/>
    </xsl:template>

    <xsl:template match="gmd:transferOptions/*/gmd:onLine/gmd:CI_OnlineResource[gmd:function/*/@codeListValue = 'download']/gmd:linkage/*">
        <dcat:downloadURL rdf:resource="{.}"/>
    </xsl:template>


    <xsl:template name="constraints">
        <xsl:param name="licenseInMainMetadata"/>
        <xsl:variable name="accessConstraints" select="ancestor::gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:resourceConstraints/*[*/gmd:MD_RestrictionCode/@codeListValue=$c_other_restrictions]/gmd:otherConstraints[gco:CharacterString != $c_no_limitation]"/>
        <xsl:variable name="accessConstraintsJson" select="$accessConstraints[starts-with(normalize-space(gco:CharacterString), '{')]"/>
        <xsl:choose>
            <xsl:when test="count($accessConstraintsJson) &gt; 0">
                <!-- dct:license -->
                <xsl:apply-templates select="$accessConstraintsJson[1]" mode="license"/>
                <!-- dcatde:licenseAttributionByText -->
                <xsl:call-template name="licenseAttributionByText">
                    <xsl:with-param name="accessConstraintsJson" select="$accessConstraintsJson[1]"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$licenseInMainMetadata">
                <!-- dct:license -->
                <xsl:apply-templates select="$licenseInMainMetadata" mode="license"/>
                <!-- dcatde:licenseAttributionByText -->
                <xsl:call-template name="licenseAttributionByText">
                    <xsl:with-param name="accessConstraintsJson" select="$licenseInMainMetadata"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- dct:license -->
                <xsl:apply-templates select="$accessConstraints[1]" mode="license"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="licenseAttributionByText">
        <xsl:param name="accessConstraintsJson"/>
        <xsl:if test="$accessConstraintsJson">
            <xsl:variable name="byText">
                <xsl:if test="starts-with(normalize-space($accessConstraintsJson), '{')">
                    <xsl:variable name="jsonWithQuelle" select="substring-after($accessConstraintsJson, '&quot;quelle&quot;')"/>
                    <xsl:variable name="quelle" select="substring-before(substring-after($jsonWithQuelle, '&quot;'), '&quot;')"/>
                    <xsl:value-of select="$quelle" />
                </xsl:if>
            </xsl:variable>
            <xsl:if test="$byText">
                <dcatde:licenseAttributionByText>
                    <xsl:call-template name="xmlLang"/>
                    <xsl:value-of select="$byText"/>
                </dcatde:licenseAttributionByText>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:resourceConstraints/*/gmd:useLimitation">
        <xsl:if test="(gco:CharacterString/text() or gmx:Anchor) and gco:CharacterString/text()!=$c_no_limitation">
            <dct:license>
                <xsl:apply-templates select="*" mode="license"/>
            </dct:license>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:useLimitation/gco:CharacterString|gmd:otherConstraints/gco:CharacterString" mode="license">
        <xsl:variable name="licenseUri">
            <xsl:call-template name="jsonLicenseToUrl"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$licenseUri != ''">
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="$licenseUri"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <dct:LicenseDocument>
                    <rdfs:label>
                        <xsl:call-template name="xmlLang"/>
                        <xsl:value-of select="."/>
                    </rdfs:label>
                    <xsl:apply-templates select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" mode="param">
                        <xsl:with-param name="mode" select="'label'"/>
                    </xsl:apply-templates>
                </dct:LicenseDocument>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:useLimitation/gmx:Anchor|gmd:otherConstraints/gmx:Anchor" mode="license">
        <xsl:attribute name="rdf:resource">
            <xsl:value-of select="@xlink:href"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="gmd:MD_RestrictionCode[@codeListValue!=$c_other_restrictions]" mode="license">
        <dct:license>
            <xsl:choose>
                <xsl:when test="@codeListValue!=$c_license and ../../gmd:accessConstraints/*/@codeListValue!=$c_license">
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
            <xsl:variable name="jsonWithId" select="substring-after(., '&quot;id&quot;')"/>
            <xsl:variable name="licenseId" select="substring-before(substring-after($jsonWithId, '&quot;'), '&quot;')"/>
            <xsl:value-of select="'http://dcat-ap.de/def/licenses/'"/>
            <xsl:choose>
                <xsl:when test="$licenseId = 'cc-by-4.0'">cc-by/4.0</xsl:when>
                <xsl:when test="$licenseId = 'dl-de-by-2.0'">dl-by-de/2.0</xsl:when>
                <xsl:when test="$licenseId = 'dl-de/by-2.0'">dl-by-de/2.0</xsl:when>
                <xsl:when test="$licenseId = 'dl-de/by-2-0'">dl-by-de/2.0</xsl:when>
                <xsl:when test="$licenseId = 'cc-by-nd-4.0'">cc-by-nd/4.0</xsl:when>
                <!-- from here on the mapping is unconfirmed -->
                <xsl:when test="$licenseId = 'cc-by-de-3.0'">cc-by-de/3.0</xsl:when>
                <xsl:when test="$licenseId = 'cc-by-nc-3.0'">cc-by-nc/3.0</xsl:when>
                <xsl:when test="$licenseId = 'cc-by-nc-4.0'">cc-by-nc/4.0</xsl:when>
                <xsl:when test="$licenseId = 'cc-by-nd-3.0'">cc-by-nd/3.0</xsl:when>
                <xsl:when test="$licenseId = 'cc-by-sa-4.0'">cc-by-sa/4.0</xsl:when>
                <xsl:when test="$licenseId = 'ccpdm-1.0'">ccpdm/1.0</xsl:when>
                <xsl:when test="$licenseId = 'dl-de-by-1.0'">dl-by-de/1.0</xsl:when>
                <xsl:when test="$licenseId = 'dl-by-nc-de-1.0'">dl-by-nc-de/1.0</xsl:when>
                <xsl:when test="$licenseId = 'dl-zero-de/2.0'">dl-zero-de/2.0</xsl:when>
                <xsl:when test="$licenseId = 'geoNutz-20130319'">geonutz/20130319</xsl:when>
                <xsl:when test="$licenseId = 'geoNutz/20130319'">geonutz/20130319</xsl:when>
                <xsl:when test="$licenseId = 'geonutzv-de-2013-03-19'">geonutz/20130319</xsl:when>
                <xsl:when test="$licenseId = 'geoNutz-20131001'">geoNutz/20131001</xsl:when>
                <xsl:when test="$licenseId = 'gpl-3.0'">gpl/3.0</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$licenseId"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

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

    <xsl:template match="gmd:applicationProfile/gco:CharacterString | gmd:distributionFormat/*/gmd:name/gco:CharacterString | gmd:distributorFormat/*/gmd:name/gco:CharacterString">
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
            <xsl:when test="$ianaMediaTypes/registry/registry/record/file[text() = $formatName]">
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
        <cnt:characterEncoding rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
            <xsl:value-of select="."/>
        </cnt:characterEncoding>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[not(gmd:thesaurusName)]/gmd:keyword/gco:CharacterString">
        <xsl:variable name="kwString" select="translate(text(),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        <xsl:variable name="listTheme" select="$dcatThemes/rdf:RDF/dcatThemes/dcatTheme[@name=$kwString]"/>
        <xsl:choose>
            <xsl:when test="$listTheme">
                <dcat:theme rdf:resource="{concat('http://publications.europa.eu/resource/authority/data-theme/', $kwString)}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="dcatKeyword"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[starts-with(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*, 'GEMET - INSPIRE themes')]/gmd:keyword[position() &gt; 1]/gco:CharacterString">
        <xsl:call-template name="dcatKeyword"/>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[starts-with(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*, 'GEMET - INSPIRE themes')]/gmd:keyword[1]/gco:CharacterString">
                <xsl:call-template name="dcatKeyword"/>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[gmd:thesaurusName and not(starts-with(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*, 'GEMET - INSPIRE themes'))]/gmd:keyword/gco:CharacterString">
                <xsl:call-template name="dcatKeyword"/>
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

    <xsl:template name="dcatTheme">
        <xsl:variable name="topicCategories" select="gmd:identificationInfo[1]/*/gmd:topicCategory/*"/>

        <xsl:variable name="inspireThemesLabels" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[starts-with(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString, 'GEMET - INSPIRE themes')]/gmd:keyword/gco:CharacterString/lower-case(text())"/>

        <xsl:variable name="inspireThemeUris" select="$inspireThemes/rdf:RDF/rdf:Description[some $title in dct:title satisfies lower-case($title) = $inspireThemesLabels]/@rdf:about"/>

        <xsl:variable name="keywords" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[not(gmd:thesaurusName)]/gmd:keyword/gco:CharacterString"/>

        <xsl:if test="$topicCategories[.='farming' or .='imageryBaseMapsEarthCover' or .='inlandWaters' or .='oceans']
            or $keywords[.='AGRI']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/AGRI"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='biota' or .='climatologyMeteorologyAtmosphere' or
            .='elevation' or .='environment' or .='imageryBaseMapsEarthCover' or .='inlandWaters' or .='oceans'
            or .='geoscientificInformation' or .='farming' or .='utilitiesCommunication']
            or ($topicCategories[.='economy'] and $inspireThemeUris[.='http://inspire.ec.europa.eu/theme/mr' or .='http://inspire.ec.europa.eu/theme/er'])
            or ($topicCategories[.='structure'] and $inspireThemeUris[.='http://inspire.ec.europa.eu/theme/ef'])
            or $keywords[.='ENVI']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ENVI"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='boundaries' or .='location' or .='planningCadastre' or
            .='geoscientificInformation' or .='structure' or .='imageryBaseMapsEarthCover']
            or $keywords[.='REGI']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/REGI"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='boundaries' or .='elevation' or .='imageryBaseMapsEarthCover' or
            .='location' or .='planningCadastre' or .='utilitiesCommunication']
            or $keywords[.='GOVE']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/GOVE"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='climatologyMeteorologyAtmosphere' or .='elevation' or
            .='geoscientificInformation' or .='imageryBaseMapsEarthCover']
            or ($topicCategories[.='economy'] and $inspireThemeUris[.='http://inspire.ec.europa.eu/theme/mr' or .='http://inspire.ec.europa.eu/theme/er'])
            or $keywords[.='TECH']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/TECH"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='economy']
            or ($topicCategories[.='structure'] and $inspireThemeUris[.='http://inspire.ec.europa.eu/theme/pf'])
            or $keywords[.='ECON']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ECON"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='health']
            or $keywords[.='HEAL']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/HEAL"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='intelligenceMilitary']
            or ($topicCategories[.='planningCadastre'] and $inspireThemeUris[.='http://inspire.ec.europa.eu/theme/cp'])
            or $keywords[.='JUST']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/JUST"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='society']
            or $keywords[.='SOCI']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/SOCI"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='society']
            or $keywords[.='EDUC']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/EDUC"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='transportation' or .='inlandWaters' or .='oceans' or .='structure']
            or $keywords[.='TRAN']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/TRAN"/>
        </xsl:if>
        <xsl:if test="$topicCategories[.='utilitiesCommunication']
            or ($topicCategories[.='economy'] and $inspireThemeUris[.='http://inspire.ec.europa.eu/theme/er'])
            or $keywords[.='ENER']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/ENER"/>
        </xsl:if>
        <xsl:if test="$keywords[.='INTR']">
            <dcat:theme rdf:resource="http://publications.europa.eu/resource/authority/data-theme/INTR"/>
        </xsl:if>
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
        <xsl:variable name="lang" select="$languageCodes/rdf:RDF/langCodes/langCode[@cswCode=$code]"/>
        <xsl:variable name="euListCode">
            <xsl:choose>
                <xsl:when test="$lang">
                    <xsl:value-of select="$lang/@dctLangCode"/>
                </xsl:when>
                <xsl:otherwise>deu</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <dct:language rdf:resource="{concat('http://publications.europa.eu/resource/authority/language/', translate($euListCode,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'))}"/>
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
