<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:locn="http://www.w3.org/ns/locn#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:dcatde="http://dcat-ap.de/def/dcatde/1_0/"
                exclude-result-prefixes="dcat dcatde dct foaf gml locn rdf rdfs vcard">
    <xsl:output method="xml"/>

    <xsl:variable name="c_coor_sep" select="' '"/>
    <xsl:variable name="c_point_sep" select="','"/>
    <xsl:variable name="c_leer_sep" select="'#*#'"/>
    <xsl:variable name="c_leer_bbox" select="'10101.10101 10101.10101,10101.10101 10101.10101'"/>
    <xsl:variable name="languageCodes" select="document('languageCodes.rdf')"/>

    <xsl:template match="dcat:Dataset">
        <gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd"
                         xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd">
            <xsl:apply-templates select="dct:identifier"/>
            <xsl:call-template name="language"/>
            <xsl:apply-templates select="dct:modified" mode="dateStamp"/>
            <xsl:apply-templates select="dct:type"/>
            <xsl:call-template name="identificationInfo"/>
            <xsl:call-template name="dataQualityInfo"/>
            <xsl:call-template name="distributionInfo"/>
        </gmd:MD_Metadata>
    </xsl:template>

    <xsl:template match="dct:type">
        <xsl:variable name="dctType">
            <xsl:call-template name="output-last-token">
                <xsl:with-param name="value" select="@rdf:resource"/>
                <xsl:with-param name="sep" select="'/'"/>
            </xsl:call-template>
        </xsl:variable>

        <gmd:hierarchyLevel>
            <gmd:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ScopeCode" codeListValue="{$dctType}"/>
        </gmd:hierarchyLevel>
    </xsl:template>

    <xsl:template name="distributionInfo">
        <gmd:distributionInfo>
            <gmd:MD_Distribution>
                <xsl:apply-templates select="dcat:distribution/dcat:Distribution/dct:format"/>
                <xsl:apply-templates select="dcat:distribution/dcat:Distribution/dcat:mediaType"/>
                <xsl:apply-templates select="ancestor::dcat:Dataset/dcat:landingPage"/>
                <xsl:apply-templates select="dcat:landingPage"/>
                <xsl:apply-templates select="dcat:distribution/dcat:Distribution/dct:downloadURL"/>
                <xsl:apply-templates select="dcat:distribution/dcat:Distribution/foaf:page/foaf:Document"/>
            </gmd:MD_Distribution>
        </gmd:distributionInfo>
    </xsl:template>

    <xsl:template match="dcat:landingPage">
        <gmd:transferOptions>
            <gmd:MD_DigitalTransferOptions>
                <gmd:onLine>
                    <gmd:CI_OnlineResource>
                        <gmd:linkage>
                            <gmd:URL>
                                <xsl:choose>
                                    <xsl:when test="@rdf:resource">
                                        <xsl:value-of select="@rdf:resource"/>
                                    </xsl:when>
                                    <xsl:when test="foaf:Document/@rdf:about">
                                        <xsl:value-of select="foaf:Document/@rdf:about"/>
                                    </xsl:when>
                                </xsl:choose>
                            </gmd:URL>
                        </gmd:linkage>
                        <xsl:call-template name="onLineFunctionCode">
                            <xsl:with-param name="function" select="'information'"/>
                        </xsl:call-template>
                    </gmd:CI_OnlineResource>
                </gmd:onLine>
            </gmd:MD_DigitalTransferOptions>
        </gmd:transferOptions>
    </xsl:template>

    <xsl:template match="dct:format | dcat:mediaType">
        <gmd:distributionFormat>
            <gmd:MD_Format>
                <gmd:name>
                    <xsl:call-template name="gcoCharacterStringAry"/>
                </gmd:name>
                <xsl:if test="dct:hasVersion">
                    <gmd:version>
                        <xsl:call-template name="gcoCharacterStringResource">
                            <xsl:with-param name="node" select="dct:hasVersion"/>
                        </xsl:call-template>
                    </gmd:version>
                </xsl:if>
            </gmd:MD_Format>
        </gmd:distributionFormat>
    </xsl:template>

    <xsl:template match="dct:format | dcat:mediaType" mode="srv">
        <srv:serviceType>
            <gco:LocalName>
                <xsl:call-template name="output-resource"/>
            </gco:LocalName>
        </srv:serviceType>
    </xsl:template>

    <xsl:template match="dcat:accessURL">
        <gmd:CI_OnlineResource>
            <gmd:linkage>
                <gmd:URL>
                    <xsl:value-of select="@rdf:resource"/>
                </gmd:URL>
            </gmd:linkage>
        </gmd:CI_OnlineResource>
    </xsl:template>

    <xsl:template match="dct:downloadURL">
        <gmd:transferOptions>
            <gmd:MD_DigitalTransferOptions>
                <gmd:onLine>
                    <gmd:CI_OnlineResource>
                        <gmd:linkage>
                            <gmd:URL>
                                <xsl:value-of select="@rdf:resource"/>
                            </gmd:URL>
                        </gmd:linkage>
                        <xsl:call-template name="onLineFunctionCode">
                            <xsl:with-param name="function" select="'download'"/>
                        </xsl:call-template>
                    </gmd:CI_OnlineResource>
                </gmd:onLine>
            </gmd:MD_DigitalTransferOptions>
        </gmd:transferOptions>
    </xsl:template>

    <xsl:template match="foaf:page/foaf:Document">
        <gmd:transferOptions>
            <gmd:MD_DigitalTransferOptions>
                <gmd:onLine>
                    <gmd:CI_OnlineResource>
                        <gmd:linkage>
                            <gmd:URL>
                                <xsl:value-of select="@rdf:about"/>
                            </gmd:URL>
                        </gmd:linkage>
                        <gmd:name>
                            <xsl:call-template name="gcoCharacterString">
                                <xsl:with-param name="node" select="foaf:name"/>
                            </xsl:call-template>
                        </gmd:name>
                        <gmd:description>
                            <xsl:call-template name="gcoCharacterStringResource">
                                <xsl:with-param name="node" select="dct:description"/>
                            </xsl:call-template>
                        </gmd:description>
                        <xsl:call-template name="onLineFunctionCode">
                            <xsl:with-param name="function" select="'information'"/>
                        </xsl:call-template>
                    </gmd:CI_OnlineResource>
                </gmd:onLine>
            </gmd:MD_DigitalTransferOptions>
        </gmd:transferOptions>
    </xsl:template>

    <xsl:template name="onLineFunctionCode">
        <xsl:param name="function"/>
        <gmd:function>
            <gmd:CI_OnLineFunctionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_OnLineFunctionCode"
                                       codeListValue="{$function}"/>
        </gmd:function>
    </xsl:template>

    <xsl:template name="dataQualityInfo">
        <gmd:dataQualityInfo>
            <gmd:DQ_DataQuality>
                <gmd:lineage>
                    <gmd:LI_Lineage>
                        <xsl:apply-templates select="dct:provenance/dct:ProvenanceStatement"/>
                    </gmd:LI_Lineage>
                </gmd:lineage>
                <gmd:report>
                    <gmd:DQ_DomainConsistency>
                        <result>
                            <DQ_ConformanceResult>
                                <specification>
                                    <CI_Citation>
                                        <xsl:apply-templates select="dct:conformsTo"/>
                                    </CI_Citation>
                                </specification>
                                <explanation>
                                    <gco:CharacterString/>
                                </explanation>
                                <pass>
                                    <gco:Boolean>true</gco:Boolean>
                                </pass>
                            </DQ_ConformanceResult>
                        </result>
                    </gmd:DQ_DomainConsistency>
                </gmd:report>
            </gmd:DQ_DataQuality>
        </gmd:dataQualityInfo>
    </xsl:template>

    <xsl:template match="dct:conformsTo">
        <xsl:apply-templates select="dct:title"/>
        <gmd:date>
            <xsl:apply-templates select="dct:issued"/>
        </gmd:date>
    </xsl:template>

    <xsl:template match="dct:provenance/dct:ProvenanceStatement">
        <gmd:statement>
            <gco:CharacterString>
                <xsl:value-of select="rdfs:label"/>
            </gco:CharacterString>
            <!--todo: ../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString-->
        </gmd:statement>
    </xsl:template>

    <xsl:template name="language">
        <xsl:variable name="languageCode">
            <xsl:choose>
                <xsl:when test="ancestor-or-self::dcat:Dataset/dct:language">
                    <xsl:call-template name="output-resource">
                        <xsl:with-param name="sep" select="'/'"/>
                        <xsl:with-param name="node" select="ancestor-or-self::dcat:Dataset/dct:language"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="ancestor-or-self::dcat:Dataset/dcat:distribution/dcat:Distribution/dct:language">
                    <xsl:call-template name="output-resource">
                        <xsl:with-param name="sep" select="'/'"/>
                        <xsl:with-param name="node" select="ancestor-or-self::dcat:Dataset/dcat:distribution/dcat:Distribution/dct:language"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>de</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <gmd:language>
            <xsl:variable name="lang" select="$languageCodes/rdf:RDF/langCodes/langCode[@ckanCode=$languageCode]"/>
            <xsl:variable name="code">
                <xsl:choose>
                    <xsl:when test="$lang">
                        <xsl:value-of select="$lang/@cswCode"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'ger'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <LanguageCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#LanguageCode"
                          codeListValue="{$code}"/>
        </gmd:language>
    </xsl:template>
    <xsl:template name="identificationInfo">
        <gmd:identificationInfo>
            <srv:SV_ServiceIdentification>
                <!--!ELEMENT srv:SV_ServiceIdentification (gmd:citation, gmd:abstract, gmd:status?, gmd:descriptiveKeywords*, srv:serviceType, srv:serviceTypeVersion?, srv:couplingType, srv:containsOperations+, srv:extent?)-->
                <xsl:if test="dcat:distribution/dcat:Distribution/dct:title">
                    <!--gmd:citation-->
                    <gmd:citation>
                        <gmd:CI_Citation>
                            <xsl:apply-templates select="dcat:distribution/dcat:Distribution/dct:title"/>
                        </gmd:CI_Citation>
                    </gmd:citation>
                </xsl:if>
                <!--gmd:abstract-->
                <xsl:apply-templates select="dcat:distribution/dcat:Distribution/dct:description"/>
                <!--srv:serviceType-->
                <xsl:apply-templates select="dcat:distribution/dcat:Distribution/dct:format" mode="srv"/>
                <!--srv:containsOperations-->
                <xsl:if test="dcat:distribution/dcat:Distribution/dcat:accessURL">
                    <srv:containsOperations>
                        <srv:SV_OperationMetadata>
                            <srv:connectPoint>
                                <xsl:apply-templates select="dcat:distribution/dcat:Distribution/dcat:accessURL"/>
                            </srv:connectPoint>
                        </srv:SV_OperationMetadata>
                    </srv:containsOperations>
                </xsl:if>
            </srv:SV_ServiceIdentification>
            <gmd:MD_DataIdentification>
                <xsl:apply-templates select="dct:description"/>
                <xsl:call-template name="language"/>
                <gmd:citation>
                    <gmd:CI_Citation>
                        <xsl:apply-templates select="dct:title"/>
                        <gmd:date>
                            <xsl:apply-templates select="dct:created"/>
                            <!--<xsl:apply-templates select="dct:modified" mode="creation"/>-->
                            <xsl:apply-templates select="dct:modified" mode="revision"/>
                            <!--<xsl:apply-templates select="dct:modified" mode="publication"/>-->
                            <xsl:apply-templates select="dct:issued"/>
                        </gmd:date>
                    </gmd:CI_Citation>
                </gmd:citation>
                <gmd:descriptiveKeywords>
                    <gmd:MD_Keywords>
                        <xsl:apply-templates select="dcat:keyword"/>
                    </gmd:MD_Keywords>
                </gmd:descriptiveKeywords>
                <xsl:apply-templates select="dcat:contactPoint"/>
                <xsl:apply-templates select="ancestor-or-self::dcat:Dataset/dct:accessRights"/>
                <xsl:apply-templates select="dcat:distribution/dcat:Distribution/dct:rights"/>
                <xsl:apply-templates select="dcat:distribution/dcat:Distribution/dct:license"/>
                <xsl:apply-templates select="dct:publisher"/>
                <xsl:apply-templates select="dcatde:maintainer"/>
                <xsl:apply-templates select="dct:creator"/>
                <xsl:apply-templates select="dct:rightsHolder"/>
                <xsl:apply-templates select="dct:spatial/dct:Location"/>
                <xsl:apply-templates select="dcat:theme"/>
            </gmd:MD_DataIdentification>
        </gmd:identificationInfo>
    </xsl:template>

    <xsl:template match="dcat:theme">
        <xsl:variable name="theme">
            <xsl:choose>
                <xsl:when test="@rdf:resource">
                    <xsl:value-of select="@rdf:resource"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ckanTheme">
            <xsl:call-template name="output-last-token">
                <xsl:with-param name="value" select="$theme"/>
                <xsl:with-param name="sep" select="'/'"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="c_ckanThemeAGRI" select="'AGRI'"/>
        <xsl:variable name="c_ckanThemeECON" select="'ECON'"/>
        <xsl:variable name="c_ckanThemeEDUC" select="'EDUC'"/>
        <xsl:variable name="c_ckanThemeENER" select="'ENER'"/>
        <xsl:variable name="c_ckanThemeENVI" select="'ENVI'"/>
        <xsl:variable name="c_ckanThemeHEAL" select="'HEAL'"/>
        <xsl:variable name="c_ckanThemeINTR" select="'INTR'"/>
        <xsl:variable name="c_ckanThemeJUST" select="'JUST'"/>
        <xsl:variable name="c_ckanThemeSOCI" select="'SOCI'"/>
        <xsl:variable name="c_ckanThemeGOVE" select="'GOVE'"/>
        <xsl:variable name="c_ckanThemeREGI" select="'REGI'"/>
        <xsl:variable name="c_ckanThemeTECH" select="'TECH'"/>
        <xsl:variable name="c_ckanThemeTRAN" select="'TRAN'"/>

        <xsl:choose>
            <xsl:when test="$ckanTheme=$c_ckanThemeAGRI">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'farming'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeECON">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'economy'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeEDUC">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'society'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeENER">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'utilitiesCommunication'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeENVI">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'environment'"/>
                </xsl:call-template>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'biota'"/>
                </xsl:call-template>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'climatologyMeteorology Atmosphere'"/>
                </xsl:call-template>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'geoscientificInformation'"/>
                </xsl:call-template>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'inlandWaters'"/>
                </xsl:call-template>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'oceans'"/>
                </xsl:call-template>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'imageryBaseMapsEarthCover'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeHEAL">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'health'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeINTR">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="$c_ckanThemeINTR"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeJUST">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'intelligenceMilitary'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeSOCI">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'society'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeGOVE">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="$c_ckanThemeGOVE"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeREGI">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'location'"/>
                </xsl:call-template>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'boundaries'"/>
                </xsl:call-template>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'planningCadastre'"/>
                </xsl:call-template>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'structure'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeTECH">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="$c_ckanThemeTECH"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ckanTheme=$c_ckanThemeTRAN">
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="'transportation'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="cswTheme">
                    <xsl:with-param name="theme" select="$ckanTheme"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="cswTheme">
        <xsl:param name="theme"/>
        <gmd:topicCategory>
            <gmd:MD_TopicCategoryCode>
                <xsl:value-of select="$theme"/>
            </gmd:MD_TopicCategoryCode>
        </gmd:topicCategory>
    </xsl:template>

    <xsl:template match="dct:accessRights">
        <gmd:resourceConstraints>
            <gmd:MD_LegalConstraints id="openDataLicense">
                <gmd:useConstraints>
                    <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="license" codeSpace="ISOTC211/19115"/>
                </gmd:useConstraints>
                <gmd:useConstraints>
                    <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions" codeSpace="ISOTC211/19115"/>
                </gmd:useConstraints>
                <xsl:apply-templates select="dct:RightsStatement"/>
            </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
    </xsl:template>

    <xsl:template match="dct:rights">
        <gmd:resourceConstraints>
            <gmd:MD_LegalConstraints>
                <gmd:useConstraints>
                    <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions" codeSpace="ISOTC211/19115"/>
                </gmd:useConstraints>
                <xsl:apply-templates select="dct:RightsStatement"/>
            </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
    </xsl:template>

    <xsl:template match="dct:RightsStatement">
        <gmd:otherConstraints>
            <xsl:call-template name="gcoCharacterStringValue">
                <xsl:with-param name="value" select="rdfs:label[text()]"/>
            </xsl:call-template>
        </gmd:otherConstraints>
    </xsl:template>

    <xsl:template match="dct:license">
        <gmd:resourceConstraints>
            <gmd:MD_LegalConstraints id="openDataLicense">
                <gmd:useConstraints>
                    <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="license" codeSpace="ISOTC211/19115"/>
                </gmd:useConstraints>
                <gmd:useConstraints>
                    <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions" codeSpace="ISOTC211/19115"/>
                </gmd:useConstraints>

                <xsl:choose>
                    <xsl:when test="dct:LicenseDocument">
                        <xsl:apply-templates select="dct:LicenseDocument/rdfs:label" mode="otherConstraints"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <gmd:otherConstraints>
                            <xsl:call-template name="gcoCharacterStringResource"/>
                        </gmd:otherConstraints>
                    </xsl:otherwise>
                </xsl:choose>
            </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
    </xsl:template>

    <xsl:template match="dct:spatial/dct:Location">
        <gmd:extent>
            <gmd:EX_Extent>
                <xsl:apply-templates select="rdfs:label"/>
                <xsl:variable name="datatype" select="locn:geometry[1]/@rdf:datatype"/>
                <xsl:choose>
                    <xsl:when test="contains($datatype, '#wktLiteral')">
                        <xsl:apply-templates select="locn:geometry[1]" mode="wktLiteral"/>
                    </xsl:when>
                    <xsl:when test="contains($datatype, '#gmlLiteral')">
                        <xsl:apply-templates select="locn:geometry[1]" mode="gmlLiteral"/>
                    </xsl:when>
                    <xsl:when test="contains($datatype, 'application/vnd.geo+json')">
                        <xsl:apply-templates select="locn:geometry[1]" mode="vndGeoJson"/>
                    </xsl:when>
                </xsl:choose>
            </gmd:EX_Extent>
        </gmd:extent>
    </xsl:template>

    <xsl:template match="locn:geometry" mode="gmlLiteral">
        <xsl:variable name="lowerCorner" select="substring-after(.,'&lt;gml:lowerCorner&gt;')"/>
        <xsl:variable name="southBoundLatitude" select="substring-before($lowerCorner,$c_coor_sep)"/>
        <xsl:variable name="lowerCorner1" select="substring-after($lowerCorner,$c_coor_sep)"/>
        <xsl:variable name="westBoundLongitude" select="substring-before($lowerCorner1,'&lt;')"/>

        <xsl:variable name="upperCorner" select="substring-after(.,'&lt;gml:upperCorner&gt;')"/>
        <xsl:variable name="northBoundLatitude" select="substring-before($upperCorner,$c_coor_sep)"/>
        <xsl:variable name="upperCorner1" select="substring-after($upperCorner,$c_coor_sep)"/>
        <xsl:variable name="eastBoundLongitude" select="substring-before($upperCorner1,'&lt;')"/>

        <xsl:call-template name="gmdEX_GeographicBoundingBox">
            <xsl:with-param name="bbox" select="concat($westBoundLongitude, $c_coor_sep, $southBoundLatitude, $c_point_sep, $eastBoundLongitude, $c_coor_sep, $northBoundLatitude)"/>
        </xsl:call-template>
    </xsl:template>

    <!--<dcat:Dataset>-->
    <!--<dct:spatial>-->
    <!--<dct:Location>-->
    <!--<locn:geometry-->
    <!--rdf:datatype="http://www.opengis.net/ont/geosparql#wktLiteral"><![CDATA[<http://www.opengis.net/def/EPSG/0/4326>-->
    <!--POLYGON((-10.58 70.09,34.59 70.09,34.59 34.56,-10.58 34.56,-10.58-->
    <!--70.09))]]></locn:geometry>-->
    <!--<locn:geometry-->
    <!--rdf:datatype="http://www.opengis.net/ont/geosparql#gmlLiteral"><![CDATA[<gml:Envelope-->
    <!--srsName="http://www.opengis.net/def/EPSG/0/4326"><gml:lowerCorner>34.56-->
    <!-- -10.58</gml:lowerCorner><gml:upperCorner>70.09-->
    <!--34.59</gml:upperCorner></gml:Envelope>]]>-->

    <!--POINT (-3.1450 53.0780)-->
    <!--{ "type": "Point", "coordinates": [-3.145,53.078] }-->

    <!--POLYGON ((9.9219 54.9831, 9.9396 54.5966, 10.9501 54.3636, 10.9395 54.0087, 11.9563 54.1965, 12.5184 54.4704, 13.6475 54.0755, 14.1197 53.7570, 14.3533 53.2482, 14.0745 52.9813, 14.4376 52.6249, 14.6850 52.0899, 14.6071 51.7452, 15.0170 51.1067, 14.5707 51.0023, 14.3070 51.1173, 14.0562 50.9269, 13.3381 50.7332, 12.9668 50.4841, 12.2401 50.2663, 12.4152 49.9691, 12.5210 49.5474, 13.0313 49.3071, 13.5959 48.8772, 13.2434 48.4161, 12.8841 48.2891, 13.0259 47.6376, 12.9326 47.4676, 12.6208 47.6724, 12.1414 47.7031, 11.4264 47.5238, 10.5445 47.5664, 10.4021 47.3025, 9.8961 47.5802, 9.5942 47.5251, 8.5226 47.8308, 8.3173 47.6136, 7.4668 47.6206, 7.5937 48.3330, 8.0993 49.0178, 6.6582 49.2020, 6.1863 49.4638, 6.2428 49.9022, 6.0431 50.1281, 6.1567 50.8037, 5.9887 51.8516, 6.5894 51.8520, 6.8429 52.2284, 7.0921 53.1440, 6.9051 53.4822, 7.1004 53.6939, 7.9362 53.7483, 8.1217 53.5278, 8.8007 54.0208, 8.5721 54.3956, 8.5262 54.9627, 9.2820 54.8309, 9.9219 54.9831))-->
    <!--POLYGON ((-80.3320 24.2069, -86.3086 29.5352, -97.2070 25.3242, -107.0508 29.9930, -119.5312 31.9522, -124.4531 38.9594, -124.9805 48.2247, -95.6250 49.1530, -84.0234 46.9203, -82.0898 41.9023, -68.7305 47.7541, -65.9180 43.8345, -80.5078 30.2970, -80.3320 24.2069))-->
    <!--{"type":"Polygon","coordinates":[[[-80.33203125,24.2068896224],[-86.30859375,29.5352295629],[-97.20703125,25.3241665257],[-107.05078125,29.9930022846],[-119.53125,31.952162238],[-124.453125,38.9594087925],[-124.98046875,48.2246726496],[-95.625,49.1529696562],[-84.0234375,46.9202553154],[-82.08984375,41.902277041],[-68.73046875,47.7540979797],[-65.91796875,43.8345267822],[-80.5078125,30.2970178834],[-80.33203125,24.2068896224]]]}-->

    <!--POLYGON ((-74.0000 4.7500, -74.0000 4.5000, -74.2000 4.5000, -74.2000 4.7500, -74.0000 4.7500))-->
    <!--{"type":"Polygon","coordinates":[[[-74,4.75],[-74,4.5],[-74.2,4.5],[-74.2,4.75],[-74,4.75]]]}-->

    <!--[?28.?08.?2018 13:51]  Antje Kügeler:-->
    <!--https://geoviewertest.sachsen.de/mapviewer2/resources/apps/egov/devdocumentation/index.html-->

    <!--[?28.?08.?2018 13:51]  Antje Kügeler:-->
    <!--https://geoviewertest.sachsen.de/mapviewer2/resources/apps/egov/devdocumentation/integrationapi_export.html?lang=de-->

    <!--[?28.?08.?2018 13:58]  Antje Kügeler:-->
    <!--https://svn-host41.eggits.net/!/#PRJ_LVA_GeosSN_Zentrale_Komponenten/view/head/Entwicklung/Geoviewer2/-->

    <!--https://geoviewer.sachsen.de/mapviewer2/resources/apps/egov/devdocumentation/integrationapi_export.html?lang=de-->
    <!--</locn:geometry>-->

    <!--<locn:geometry-->
    <!--rdf:datatype="https://www.iana.org/assignments/media-types/application/vnd.geo+json"><![CDATA[{"type":"Polygon","crs":{"type":"name","properties":{"name":"urn:ogc:def:EPSG::4326"}},"coordinates":[[[-10.58,70.09],[34.59,70.09],[34.59,34.56],[-10.58,34.56],[-10.58,70.09]]]}]]></locn:geometry>-->
    <!--</dct:Location>-->
    <!--</dct:spatial>-->
    <!--</dcat:Dataset>-->

    <xsl:template match="locn:geometry" mode="wktLiteral">
        <xsl:variable name="geoWkt">
            <xsl:call-template name="geoWktTrim">
                <xsl:with-param name="value" select="normalize-space(text())"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="gmdEX_GeographicBoundingBox">
            <xsl:with-param name="geoWkt" select="$geoWkt"/>
            <xsl:with-param name="wktPjsonLiteral" select="text()"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="locn:geometry" mode="vndGeoJson">
        <xsl:variable name="geoWkt">
            <xsl:call-template name="geoJson2wkt">
                <xsl:with-param name="value" select="concat('[',substring-before(substring-after(translate(normalize-space(text()),' ',''),':['),'}'))"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="gmdEX_GeographicBoundingBox">
            <xsl:with-param name="geoWkt" select="$geoWkt"/>
            <xsl:with-param name="wktPjsonLiteral" select="text()"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="gmdEX_GeographicBoundingBox">
        <xsl:param name="geoWkt"/>
        <xsl:param name="wktPjsonLiteral"/>
        <xsl:variable name="bbox">
            <xsl:choose>
                <xsl:when test="contains($wktPjsonLiteral, 'MultiPolygon') or contains($wktPjsonLiteral, 'MULTIPOLYGON')">
                    <xsl:call-template name="getBBoxByMultiPolygon">
                        <xsl:with-param name="polygons" select="concat('((',normalize-space(substring-before(substring-after($geoWkt,'((('),')))')),'))')"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="contains($wktPjsonLiteral, 'Polygon') or contains(text(), 'MultiLineString') or contains($wktPjsonLiteral, 'POLYGON') or contains($wktPjsonLiteral, 'MULTILINESTRING')">
                    <xsl:call-template name="getBBoxByPolygon">
                        <xsl:with-param name="polygon" select="concat('(',normalize-space(substring-before(substring-after($geoWkt,'(('),'))')),')')"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="contains($wktPjsonLiteral, 'LineString') or contains($wktPjsonLiteral, 'LINESTRING')">
                    <xsl:call-template name="getBBoxByLine">
                        <xsl:with-param name="line" select="normalize-space(substring-before(substring-after($geoWkt,'('),')'))"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="contains($wktPjsonLiteral, 'MultiPoint') or contains($wktPjsonLiteral, 'MULTIPOINT')">
                    <xsl:call-template name="getBBoxByMultiPoint">
                        <xsl:with-param name="points">
                            <xsl:choose>
                                <xsl:when test="contains($geoWkt, '((')">
                                    <xsl:value-of select="normalize-space(substring-before(substring-after($geoWkt,'(('),'))'))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="normalize-space(substring-before(substring-after($geoWkt,'('),')'))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="contains($wktPjsonLiteral, 'Point') or contains($wktPjsonLiteral, 'POINT')">
                    <xsl:call-template name="getBBoxByPoint">
                        <xsl:with-param name="point" select="normalize-space(substring-before(substring-after($geoWkt,'('),')'))"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="westBoundLongitude" select="number(substring-before($bbox, $c_coor_sep))"/>
        <xsl:variable name="southBoundLatitude" select="number(substring-before(substring-after($bbox, $c_coor_sep), $c_point_sep))"/>
        <xsl:variable name="eastBoundLongitude" select="number(substring-before(substring-after($bbox, $c_point_sep), $c_coor_sep))"/>
        <xsl:variable name="northBoundLatitude" select="number(substring-after(substring-after($bbox, $c_point_sep), $c_coor_sep))"/>
        <gmd:geographicElement>
            <gmd:EX_GeographicBoundingBox>
                <gmd:extentTypeCode>
                    <gco:Boolean>true</gco:Boolean>
                </gmd:extentTypeCode>
                <gmd:westBoundLongitude>
                    <gco:Decimal>
                        <xsl:value-of select="$westBoundLongitude"/>
                    </gco:Decimal>
                </gmd:westBoundLongitude>
                <gmd:eastBoundLongitude>
                    <gco:Decimal>
                        <xsl:value-of select="$eastBoundLongitude"/>
                    </gco:Decimal>
                </gmd:eastBoundLongitude>
                <gmd:southBoundLatitude>
                    <gco:Decimal>
                        <xsl:value-of select="$southBoundLatitude"/>
                    </gco:Decimal>
                </gmd:southBoundLatitude>
                <gmd:northBoundLatitude>
                    <gco:Decimal>
                        <xsl:value-of select="$northBoundLatitude"/>
                    </gco:Decimal>
                </gmd:northBoundLatitude>
            </gmd:EX_GeographicBoundingBox>

            <xsl:apply-templates select="ancestor-or-self::dcat:Dataset/dcatde:politicalGeocodingURI"/>
            <xsl:apply-templates select="ancestor-or-self::dcat:Dataset/dcatde:politicalGeocodingLevelURI"/>
        </gmd:geographicElement>
    </xsl:template>

    <xsl:template name="geoWktTrim">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="contains($value,', ')">
                <xsl:call-template name="geoWktTrim">
                    <xsl:with-param name="value" select="concat(substring-before($value, ', '),',',substring-after($value, ', '))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="geoJson2wkt">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="contains($value,'],[')">
                <xsl:call-template name="geoJson2wkt">
                    <xsl:with-param name="value" select="concat(substring-before($value, '],['),'s',substring-after($value, '],['))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="value_" select="translate($value,'[,s]','( ,)')"/>
                <xsl:choose>
                    <xsl:when test="contains($value_, '((')">
                        <xsl:value-of select="substring($value_,2,string-length($value_)-2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$value_"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getBBoxByMultiPolygon">
        <xsl:param name="polygons"/>
        <xsl:param name="bbox" select="$c_leer_bbox"/>
        <xsl:variable name="polygon" select="concat('(',substring-before(substring-after($polygons, '(('), '))'),')')"/>
        <xsl:call-template name="getBBoxByPolygon">
            <xsl:with-param name="polygon" select="$polygon"/>
            <xsl:with-param name="bbox">
                <xsl:choose>
                    <xsl:when test="string-length(substring-after($polygons,')),'))>4">
                        <xsl:call-template name="getBBoxByMultiPolygon">
                            <xsl:with-param name="polygons" select="substring-after($polygons,')),')"/>
                            <xsl:with-param name="bbox" select="$bbox"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$bbox"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="getBBoxByPolygon">
        <xsl:param name="polygon"/>
        <xsl:param name="bbox" select="$c_leer_bbox"/>
        <xsl:variable name="line" select="substring-before(substring-after($polygon, '('), ')')"/>
        <xsl:call-template name="getBBoxByLine">
            <xsl:with-param name="line" select="$line"/>
            <xsl:with-param name="bbox">
                <xsl:choose>
                    <xsl:when test="string-length(substring-after($polygon,'),'))>4">
                        <xsl:call-template name="getBBoxByPolygon">
                            <xsl:with-param name="polygon" select="substring-after($polygon,'),')"/>
                            <xsl:with-param name="bbox" select="$bbox"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$bbox"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="getBBoxByLine">
        <xsl:param name="line"/>
        <xsl:param name="bbox" select="$c_leer_bbox"/>
        <xsl:variable name="point" select="substring-before($line, $c_point_sep)"/>
        <xsl:choose>
            <xsl:when test="string-length($point) > 0">
                <xsl:call-template name="getBBoxByLine">
                    <xsl:with-param name="line" select="substring-after($line, $c_point_sep)"/>
                    <xsl:with-param name="bbox">
                        <xsl:call-template name="getBBoxByPoint">
                            <xsl:with-param name="point" select="$point"/>
                            <xsl:with-param name="bbox" select="$bbox"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getBBoxByPoint">
                    <xsl:with-param name="point" select="$line"/>
                    <xsl:with-param name="bbox" select="$bbox"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getBBoxByMultiPoint">
        <xsl:param name="points"/>
        <xsl:param name="bbox" select="$c_leer_bbox"/>
        <xsl:call-template name="getBBoxByLine">
            <xsl:with-param name="bbox" select="$bbox"/>
            <xsl:with-param name="line" select="translate($points, '()', '')"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="getBBoxByPoint">
        <xsl:param name="point"/>
        <xsl:param name="bbox" select="$c_leer_bbox"/>
        <xsl:variable name="x" select="number(substring-before($point, $c_coor_sep))"/>
        <xsl:variable name="y" select="number(substring-after($point, $c_coor_sep))"/>
        <xsl:variable name="xmin" select="number(substring-before($bbox, $c_coor_sep))"/>
        <xsl:variable name="ymin" select="number(substring-before(substring-after($bbox, $c_coor_sep), $c_point_sep))"/>
        <xsl:variable name="xmax" select="number(substring-before(substring-after($bbox, $c_point_sep), $c_coor_sep))"/>
        <xsl:variable name="ymax" select="number(substring-after(substring-after($bbox, $c_point_sep), $c_coor_sep))"/>
        <xsl:call-template name="getMin">
            <xsl:with-param name="value" select="$x"/>
            <xsl:with-param name="min" select="$xmin"/>
        </xsl:call-template>
        <xsl:value-of select="$c_coor_sep"/>
        <xsl:call-template name="getMin">
            <xsl:with-param name="value" select="$y"/>
            <xsl:with-param name="min" select="$ymin"/>
        </xsl:call-template>
        <xsl:value-of select="$c_point_sep"/>
        <xsl:call-template name="getMax">
            <xsl:with-param name="value" select="$x"/>
            <xsl:with-param name="max" select="$xmax"/>
        </xsl:call-template>
        <xsl:value-of select="$c_coor_sep"/>
        <xsl:call-template name="getMax">
            <xsl:with-param name="value" select="$y"/>
            <xsl:with-param name="max" select="$ymax"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="getMin">
        <xsl:param name="value"/>
        <xsl:param name="min"/>
        <xsl:choose>
            <xsl:when test="$min=10101.10101 or $min &gt; $value">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$min"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getMax">
        <xsl:param name="value"/>
        <xsl:param name="max"/>
        <xsl:choose>
            <xsl:when test="$max=10101.10101 or $max &lt; $value">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$max"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dcat:Dataset/dcatde:politicalGeocodingURI|dcatde:politicalGeocodingLevelURI">
        <gmd:EX_GeographicDescription>
            <gmd:EX_GeographicDescription>
                <gmd:extentTypeCode>
                    <gco:Boolean>true</gco:Boolean>
                </gmd:extentTypeCode>
                <gmd:geographicIdentifier>
                    <gmd:MD_Identifier>
                        <gmd:authority/>
                        <gmd:code>
                            <xsl:call-template name="gcoCharacterStringResource"/>
                        </gmd:code>
                    </gmd:MD_Identifier>
                </gmd:geographicIdentifier>
            </gmd:EX_GeographicDescription>
        </gmd:EX_GeographicDescription>
    </xsl:template>

    <xsl:template match="rdfs:label">
        <gmd:description>
            <xsl:call-template name="gcoCharacterString"/>
        </gmd:description>
        <!--todo: ../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString-->
    </xsl:template>

    <xsl:template match="rdfs:label" mode="useLimitation">
        <!--todo: ../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString-->
    </xsl:template>

    <xsl:template match="rdfs:label" mode="otherConstraints">
        <gmd:otherConstraints>
            <xsl:call-template name="gcoCharacterString"/>
        </gmd:otherConstraints>
        <!--todo: ../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString-->
    </xsl:template>

    <xsl:template match="dcat:contactPoint">
        <gmd:pointOfContact>
            <!--!ELEMENT gmd:CI_ResponsibleParty (gmd:individualName?, gmd:organisationName, gmd:positionName?, gmd:contactInfo?, gmd:role)-->
            <gmd:CI_ResponsibleParty>
                <xsl:apply-templates select="vcard:Organization/vcard:organization-name|vcard:Organization/vcard:fn"/>
                <xsl:apply-templates select="vcard:Individual/vcard:fn" mode="individual"/>
                <xsl:call-template name="contactInfo"/>
                <gmd:role>
                    <gmd:CI_RoleCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact">pointOfContact</gmd:CI_RoleCode>
                </gmd:role>
            </gmd:CI_ResponsibleParty>
        </gmd:pointOfContact>
    </xsl:template>

    <xsl:template name="contactInfo">
        <xsl:if test="vcard:Individual/vcard:hasTelephone|vcard:Individual|vcard:Organization/vcard:hasEmail|vcard:Organization/vcard:hasURL|foaf:Organization/foaf:homepage|foaf:Person/foaf:homepage|foaf:Organization/foaf:mbox|foaf:Person/foaf:mbox">
            <gmd:contactInfo>
                <!--!ELEMENT gmd:CI_Contact (address?, contactInstructions?, hoursOfService?, onlineResource?, phone?)-->
                <gmd:CI_Contact>
                    <xsl:if test="vcard:Individual/vcard:hasTelephone">
                        <gmd:phone>
                            <gmd:CI_Telephone>
                                <xsl:apply-templates select="vcard:Individual/vcard:hasTelephone"/>
                            </gmd:CI_Telephone>
                        </gmd:phone>
                    </xsl:if>
                    <gmd:address>
                        <gmd:CI_Address>
                            <xsl:apply-templates select="vcard:Individual"/>
                            <xsl:choose>
                                <xsl:when test="vcard:Individual/vcard:hasEmail">
                                    <xsl:apply-templates select="vcard:Individual/vcard:hasEmail"/>
                                </xsl:when>
                                <xsl:when test="vcard:Organization/vcard:hasEmail">
                                    <xsl:apply-templates select="vcard:Organization/vcard:hasEmail"/>
                                </xsl:when>
                                <xsl:when test="foaf:Organization/foaf:mbox">
                                    <xsl:apply-templates select="foaf:Organization/foaf:mbox"/>
                                </xsl:when>
                                <xsl:when test="foaf:Person/foaf:mbox">
                                    <xsl:apply-templates select="foaf:Person/foaf:mbox"/>
                                </xsl:when>
                            </xsl:choose>
                        </gmd:CI_Address>
                    </gmd:address>
                    <xsl:apply-templates select="vcard:Organization/vcard:hasURL|foaf:Organization/foaf:homepage|foaf:Person/foaf:homepage"/>
                </gmd:CI_Contact>
            </gmd:contactInfo>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dcatde:maintainer">
        <xsl:call-template name="gmdPointOfContact">
            <xsl:with-param name="codeListValue" select="'custodian'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dct:publisher">
        <xsl:call-template name="gmdPointOfContact">
            <xsl:with-param name="codeListValue" select="'publisher'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dct:creator">
        <xsl:call-template name="gmdPointOfContact">
            <xsl:with-param name="codeListValue" select="'originator'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dct:rightsHolder">
        <xsl:call-template name="gmdPointOfContact">
            <xsl:with-param name="codeListValue" select="'owner'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="gmdPointOfContact">
        <xsl:param name="codeListValue"/>
        <gmd:pointOfContact>
            <gmd:CI_ResponsibleParty>
                <xsl:apply-templates select="foaf:Organization/foaf:name"/>
                <xsl:apply-templates select="foaf:Person/foaf:name" mode="individual"/>
                <xsl:call-template name="contactInfo"/>
                <gmd:role>
                    <gmd:CI_RoleCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_RoleCode" codeListValue="{$codeListValue}">
                        <xsl:value-of select="$codeListValue"/>
                    </gmd:CI_RoleCode>
                </gmd:role>
            </gmd:CI_ResponsibleParty>
        </gmd:pointOfContact>
    </xsl:template>

    <xsl:template match="vcard:organization-name|vcard:fn|foaf:name">
        <xsl:call-template name="organisationName"/>
    </xsl:template>

    <xsl:template match="vcard:fn|foaf:name" mode="individual">
        <gmd:individualName>
            <xsl:call-template name="gcoCharacterString"/>
        </gmd:individualName>
    </xsl:template>

    <xsl:template name="organisationName">
        <gmd:organisationName>
            <xsl:call-template name="gcoCharacterString"/>
        </gmd:organisationName>
    </xsl:template>

    <xsl:template match="vcard:hasTelephone">
        <xsl:for-each select="rdf:type">
            <xsl:choose>
                <xsl:when test="contains(@rdf:resource, '#Fax')">
                    <gmd:facsimile>
                        <xsl:apply-templates select=".." mode="ary"/>
                    </gmd:facsimile>
                </xsl:when>
                <xsl:when test="contains(@rdf:resource, '#Voice')">
                    <gmd:voice>
                        <xsl:apply-templates select=".." mode="ary"/>
                    </gmd:voice>
                </xsl:when>
                <!--<xsl:otherwise>-->
                <!--<gmd:voice>-->
                <!--<xsl:apply-templates select=".." mode="ary"/>-->
                <!--</gmd:voice>-->
                <!--</xsl:otherwise>-->
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="vcard:Individual">
        <gmd:deliveryPoint>
            <xsl:apply-templates select="vcard:hasStreetAddress|vcard:street-address" mode="ary"/>
        </gmd:deliveryPoint>
        <gmd:city>
            <xsl:apply-templates select="vcard:hasLocality|vcard:locality" mode="ary"/>
        </gmd:city>
        <gmd:administrativeArea>
            <xsl:apply-templates select="vcard:hasRegion|vcard:region" mode="ary"/>
        </gmd:administrativeArea>
        <gmd:postalCode>
            <xsl:apply-templates select="vcard:hasPostalCode|vcard:postal-code" mode="ary"/>
        </gmd:postalCode>
        <gmd:country>
            <xsl:apply-templates select="vcard:hasCountryName|vcard:country-name" mode="ary"/>
        </gmd:country>
    </xsl:template>

    <xsl:template match="vcard:hasEmail|foaf:mbox">
        <gmd:electronicMailAddress>
            <xsl:apply-templates select="." mode="ary"/>
        </gmd:electronicMailAddress>
    </xsl:template>

    <xsl:template mode="ary"
                  match="vcard:street-address|vcard:locality|vcard:region|vcard:postal-code|vcard:country-name|vcard:hasStreetAddress|vcard:hasLocality|vcard:hasRegion|vcard:hasPostalCode|vcard:hasCountryName|vcard:hasTelephone|foaf:mbox|vcard:hasEmail">
        <xsl:call-template name="gcoCharacterStringAry">
            <xsl:with-param name="sep" select="':'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="vcard:hasURL|foaf:homepage">
        <gmd:onlineResource>
            <gmd:CI_OnlineResource>
                <gmd:linkage>
                    <gmd:URL>
                        <xsl:value-of select="@rdf:resource"/>
                    </gmd:URL>
                </gmd:linkage>
            </gmd:CI_OnlineResource>
        </gmd:onlineResource>
    </xsl:template>

    <xsl:template match="dct:title">
        <gmd:title>
            <xsl:call-template name="gcoCharacterString"/>
            <!--todo: add ../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString-->
        </gmd:title>
    </xsl:template>

    <xsl:template match="dct:created">
        <xsl:call-template name="gmdCI_Date">
            <xsl:with-param name="dateTypeCode" select="'creation'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dct:modified" mode="creation">
        <xsl:call-template name="gmdCI_Date">
            <xsl:with-param name="dateTypeCode" select="'creation'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dct:modified" mode="revision">
        <xsl:call-template name="gmdCI_Date">
            <xsl:with-param name="dateTypeCode" select="'revision'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dct:modified" mode="publication">
        <xsl:call-template name="gmdCI_Date">
            <xsl:with-param name="dateTypeCode" select="'publication'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dct:modified" mode="dateStamp">
        <gmd:dateStamp>
            <xsl:call-template name="gcoDate"/>
        </gmd:dateStamp>
    </xsl:template>

    <xsl:template match="dct:issued">
        <xsl:call-template name="gmdCI_Date">
            <xsl:with-param name="dateTypeCode" select="'publication'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dct:description">
        <gmd:abstract>
            <xsl:call-template name="gcoCharacterString"/>
            <!--todo: add ../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString-->
        </gmd:abstract>
    </xsl:template>

    <xsl:template match="dct:identifier">
        <gmd:fileIdentifier>
            <xsl:call-template name="gcoCharacterString"/>
        </gmd:fileIdentifier>
    </xsl:template>

    <xsl:template match="dcat:keyword">
        <gmd:keyword>
            <xsl:call-template name="gcoCharacterString"/>
            <!--todo: add ../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString-->
        </gmd:keyword>
    </xsl:template>

    <xsl:template name="gmdCI_Date">
        <xsl:param name="dateTypeCode"/>
        <gmd:CI_Date>
            <gmd:date>
                <xsl:call-template name="gcoDate"/>
            </gmd:date>
            <gmd:dateType>
                <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="{$dateTypeCode}"/>
            </gmd:dateType>
        </gmd:CI_Date>
    </xsl:template>

    <xsl:template name="gcoDate">
        <gco:Date>
            <xsl:value-of select="substring(., 1, 10)"/>
        </gco:Date>
    </xsl:template>

    <xsl:template name="gcoCharacterString">
        <xsl:param name="node" select="."/>
        <xsl:call-template name="gcoCharacterStringValue">
            <xsl:with-param name="value" select="$node"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="gcoCharacterStringValue">
        <xsl:param name="value"/>
        <gco:CharacterString>
            <xsl:value-of select="$value"/>
        </gco:CharacterString>
    </xsl:template>

    <xsl:template name="gcoCharacterStringResource">
        <xsl:param name="sep" select="$c_leer_sep"/>
        <xsl:param name="node" select="."/>
        <xsl:call-template name="gcoCharacterStringValue">
            <xsl:with-param name="value">
                <xsl:call-template name="output-resource">
                    <xsl:with-param name="sep" select="$sep"/>
                    <xsl:with-param name="node" select="$node"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="gcoCharacterStringAry">
        <xsl:param name="sep" select="$c_leer_sep"/>
        <xsl:call-template name="gcoCharacterStringValue">
            <xsl:with-param name="value">
                <xsl:choose>
                    <xsl:when test="@rdf:parseType='Resource'">
                        <xsl:choose>
                            <xsl:when test="vcard:hasValue">
                                <xsl:call-template name="output-resource">
                                    <xsl:with-param name="node" select="vcard:hasValue"/>
                                    <xsl:with-param name="sep" select="$sep"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="rdfs:label">
                                <xsl:call-template name="output-resource">
                                    <xsl:with-param name="node" select="rdfs:label"/>
                                    <xsl:with-param name="sep" select="$sep"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="output-resource">
                                    <xsl:with-param name="node" select="vcard:value"/>
                                    <xsl:with-param name="sep" select="$sep"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="output-resource">
                            <xsl:with-param name="sep" select="$sep"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="output-resource">
        <xsl:param name="sep" select="$c_leer_sep"/>
        <xsl:param name="node" select="."/>
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="$node/@rdf:resource">
                    <xsl:value-of select="$node/@rdf:resource"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="output-last-token">
            <xsl:with-param name="sep" select="$sep"/>
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="output-last-token">
        <xsl:param name="sep" select="$c_leer_sep"/>
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="$sep!=$c_leer_sep and contains($value, $sep)">
                <xsl:call-template name="output-last-token">
                    <xsl:with-param name="value" select="substring-after($value, $sep)"/>
                    <xsl:with-param name="sep" select="$sep"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
