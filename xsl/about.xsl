<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:col="http://cnx.rice.edu/collxml" xmlns:tmp="tmp" xmlns:cnxml="http://cnx.rice.edu/cnxml"
    xmlns:md="http://cnx.rice.edu/mdml" xmlns:q="http://cnx.rice.edu/qml/1.0" xmlns:ep="http://epodreczniki.pl/"
    xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns="http://cnx.rice.edu/cnxml" exclude-result-prefixes="xs fn"
    version="2.0">

    <xsl:template match="col:collection" mode="about_page">
        <xsl:variable name="variant" select="ep:getVariant(.)"/>

        <xsl:call-template name="createAboutContent">
            <xsl:with-param name="variant" select="$variant"/>
        </xsl:call-template>
        <xsl:call-template name="createAnswersLicensesModule"> </xsl:call-template>
        <xsl:call-template name="createLicencesModule"/>
        <xsl:call-template name="createAboutContent">
            <xsl:with-param name="variant" select="$variant"/>
            <xsl:with-param name="dataFormat" select="'mobile_app'" tunnel="yes"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="createAboutContent">
        <xsl:param name="variant"/>
        <xsl:param name="dataFormat" tunnel="yes"/>

        <xsl:for-each select="col:content/col:subcollection">
            <xsl:variable name="doc_id">
                <xsl:value-of select="ep:generate_doc_id(preceding::col:metadata/md:content-id, '_about_')"/>
                <xsl:value-of select="position()"/>
            </xsl:variable>
            
            <xsl:variable name="modId" select=".//col:module[1]/@document"></xsl:variable>
            <xsl:variable name="modContent" select="$modules/cnxml:documents/cnxml:document[@id=$modId]"/>

            <document id="{$doc_id}" module-id="{$doc_id}">
                <xsl:if test="$dataFormat = 'mobile_app'">
                    <xsl:attribute name="data-format" select="$dataFormat"></xsl:attribute>
                </xsl:if>
                <xsl:copy-of select="$modContent/@cnxml-version"></xsl:copy-of>
                <xsl:element name="title">
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="$locales/locale[@key='about_etextbook']/text()"/>
                    </xsl:if>
                </xsl:element>
                <metadata>
                    <xsl:copy-of select="$modContent/cnxml:metadata/@*"/>
                    <ep:e-textbook-module>
                        <xsl:copy-of select="$modContent/cnxml:metadata/ep:e-textbook-module/@*"/>
                        <ep:presentation>
                            <ep:type>EP_technical_module_about</ep:type>
                        </ep:presentation>
                    </ep:e-textbook-module>
                </metadata>
                <content>
                    <xsl:if test="count(preceding-sibling::col:subcollection) = 0 
                        and preceding::col:metadata/ep:e-textbook/ep:learning-objectives">
                        
                        <xsl:call-template name="createLearningObjectives"/>
                    </xsl:if>
                    
                    <xsl:call-template name="content_about">
                        <xsl:with-param name="doc_id" select="$doc_id"/>
                        <xsl:with-param name="variant" select="$variant"/>
                        <xsl:with-param name="col_id" select="preceding::col:metadata/md:content-id"/>
                        <xsl:with-param name="col_ver" select="preceding::col:metadata/md:version"/>
                        <xsl:with-param name="chapter_title" select="md:title"/>
                        <xsl:with-param name="context" select="."/>
                    </xsl:call-template>
                </content>
            </document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="createLearningObjectives">  
        <xsl:variable name="mainId" select="ep:generate_doc_id(preceding::col:metadata/md:content-id, '_about_module_learning_objectives')"></xsl:variable>
        <xsl:variable name="mainRole" select="'about_module_learning_objectives'"></xsl:variable>
        
        <section id="{$mainId}" ep:role="{$mainRole}">
            <table id="{concat($mainId, '_t')}" ep:role="{concat($mainRole, '_table')}" summary="{$locales/locale[@key='about_learning_objectives_table']}">
                <title/>
                <tgroup cols="1">
                    <colspec colnum="1" colname="c1"/>
                    <tbody>
                        <row>
                            <entry ep:role="{concat($mainRole, '_title_label')}">
                                <span ep:role="{concat($mainRole, '_title')}">
                                    <xsl:value-of select="$locales/locale[@key='learning_objectives_label']/text()"/>
                                </span>
                            </entry>
                        </row>
                        <xsl:for-each
                            select="preceding::col:metadata/ep:e-textbook/ep:learning-objectives/ep:learning-objective">
                            <row>
                                <entry ep:role="learning_objective">
                                    <span ep:role="learning_objective_label">
                                        <span ep:role="learning_objective_label_key">
                                            <xsl:value-of select="./ep:learning-objective-name/@ep:key"/>
                                        </span>
                                        <xsl:text>: </xsl:text>
                                        <span ep:role="learning_objective_label_name">
                                            <xsl:value-of select="./ep:learning-objective-name/text()"/>
                                        </span>
                                    </span>
                                    <newline/>
                                    <span ep:role="learning_objective_text">
                                        <xsl:value-of select="./ep:learning-objective-text/text()"/>
                                    </span>
                                </entry>
                            </row>
                        </xsl:for-each>
                    </tbody>
                </tgroup>
            </table>
        </section>
    </xsl:template>

    <xsl:template name="createLicencesModule">
        <xsl:variable name="doc_id">
            <xsl:value-of select="ep:generate_doc_id(col:metadata/md:content-id, '_about_licenses')"/>
        </xsl:variable>

        <document id="{$doc_id}" module-id="{$doc_id}" cnxml-version="0.7">
            <xsl:element name="title"/>
            <metadata>
                <xsl:copy-of select="$modules/cnxml:documents/cnxml:document[1]/cnxml:metadata/@*"/>
                <ep:e-textbook-module>
                    <xsl:copy-of select="$modules/cnxml:documents/cnxml:document[1]/cnxml:metadata/ep:e-textbook-module/@ep:version"/>
                    <ep:presentation>
                        <ep:type>EP_technical_module_about</ep:type>
                    </ep:presentation>
                </ep:e-textbook-module>
            </metadata>
            <content>
                <section id="{concat($doc_id, '-licenses')}" ep:role="about_module">
                    <table id="{concat($doc_id, '-licenses_t')}" ep:role="about_module_table" summary="{md:content-id}">
                        <title/>
                        <tgroup cols="1">
                            <colspec colnum="1" colname="c1"/>
                            <tbody>
                                <row>
                                    <entry ep:role="label_module_title">
                                        <span>
                                            <xsl:value-of select="$locales/locale[@key='license_list_title']"/>
                                        </span>
                                    </entry>
                                </row>
                                <row>
                                    <entry ep:role="label_module_license">
                                        <xsl:for-each select="$licenseMap">
                                            <span>
                                                <xsl:value-of select="./@name"/>
                                                <xsl:text> </xsl:text>
                                            </span>
                                            <span>
                                                <xsl:element name="a">
                                                    <xsl:attribute name="href" select="./@link"/>
                                                    <xsl:attribute name="target" select="'_blank'"/>
                                                    <xsl:value-of select="./@link"/>
                                                </xsl:element>
                                            </span>
                                            <newline/>
                                        </xsl:for-each>

                                        <xsl:variable name="key">
                                            <xsl:for-each select="col:metadata/md:subjectlist/md:subject">
                                                <xsl:value-of select="."/>
                                                <xsl:text>;</xsl:text>
                                            </xsl:for-each>
                                        </xsl:variable>

                                        <xsl:if test="some $x in $locales/locale[@key='subject_mathematics'] satisfies contains($key,$x)">
                                            <span>
                                                <xsl:value-of select="'PŁ - Politechnika Łódzka'"/>
                                                <xsl:text> </xsl:text>
                                            </span>
                                        </xsl:if>
                                    </entry>
                                </row>
                            </tbody>
                        </tgroup>
                    </table>
                </section>
            </content>
        </document>
    </xsl:template>

    <xsl:template name="createAnswersLicensesModule">
        <xsl:variable name="doc_id">
            <xsl:value-of select="$ep:get_doc_id_answers_licenses"/>
        </xsl:variable>
        <xsl:variable name="answerWOMIs" select="$womi_image_metadata_info/womi[@solution = 'true']"/>

        <xsl:if test="$answerWOMIs">
            <document id="{$doc_id}" module-id="{$doc_id}" cnxml-version="0.7">
                <xsl:element name="title"/>
                <metadata>
                    <xsl:copy-of select="$modules/cnxml:documents/cnxml:document[1]/cnxml:metadata/@*"/>
                    <ep:e-textbook-module>
                        <xsl:copy-of select="$modules/cnxml:documents/cnxml:document[1]/cnxml:metadata/ep:e-textbook-module/@ep:version"/>
                        <ep:presentation>
                            <ep:type>EP_technical_module_about</ep:type>
                        </ep:presentation>
                    </ep:e-textbook-module>
                </metadata>
                <content>
                    <section id="{concat($doc_id, '-answers_licenses')}" ep:role="about_module">

                        <table id="{concat($doc_id, '-answers_licenses_t')}" ep:role="about_module_table" summary="{md:content-id}">
                            <title/>
                            <tgroup cols="1">
                                <colspec colnum="1" colname="c1"/>
                                <tbody>
                                    <row>
                                        <entry ep:role="label_module_title">
                                            <span>
                                                <xsl:value-of select="$locales/locale[@key='label_womi_answers_licenses']"/>
                                            </span>
                                        </entry>
                                    </row>
                                    <row>
                                        <entry ep:role="label_module_license">
                                            <xsl:for-each-group select="$answerWOMIs" group-by="@subcollection_id">
                                                <span id="{current-grouping-key()}">
                                                    <xsl:for-each select="current-group()">
                                                        <xsl:variable name="format" select="@format"/>
        
                                                        <xsl:choose>
                                                            <xsl:when test="not($format) or $format = ''">
                                                                <xsl:call-template name="storeAnswerWOMILicenseInformation"/>
                                                            </xsl:when>
                                                            <xsl:when test="$format = 'pdf'">
                                                                <ep:alternatives>
                                                                    <ep:alternative>
                                                                        <ep:formats>
                                                                            <ep:format>static</ep:format>
                                                                        </ep:formats>
                                                                        <xsl:call-template name="storeAnswerWOMILicenseInformation"/>
                                                                    </ep:alternative>
                                                                </ep:alternatives>
                                                            </xsl:when>
                                                            <xsl:when test="$format = 'ebook'">
                                                                <ep:alternatives>
                                                                    <ep:alternative>
                                                                        <ep:formats>
                                                                            <ep:format>static-mono</ep:format>
                                                                        </ep:formats>
                                                                        <xsl:call-template name="storeAnswerWOMILicenseInformation"/>
                                                                    </ep:alternative>
                                                                </ep:alternatives>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </xsl:for-each>
                                                </span>
                                            </xsl:for-each-group>
                                        </entry>
                                    </row>
                                </tbody>
                            </tgroup>
                        </table>
                    </section>
                </content>
            </document>
        </xsl:if>
    </xsl:template>

    <xsl:template name="storeAnswerWOMILicenseInformation">
        <span ep:role='license-womi-author'>
            <xsl:choose>
                <xsl:when test="@authors and @authors != ''">
                    <xsl:value-of select="@authors"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$locales/locale[@key='womi_information_undefined']/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
        <xsl:text>: </xsl:text>
        <span ep:role="license-womi-title">
            <xsl:choose>
                <xsl:when test="@title and @title != ''">
                    <xsl:value-of select="@title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$locales/locale[@key='womi_information_undefined']/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
        <span ep:role="license-type">
            <xsl:text> [</xsl:text>
            <xsl:value-of select="$locales/locale[@key='womi_license']/text()"/>
            <xsl:choose>
                <xsl:when test="@licences and @licences != ''">
                    <xsl:value-of select="@licences"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$locales/locale[@key='womi_information_undefined']/text()"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>]</xsl:text>
        </span>
        <xsl:if test="@licenceAdditionalInfo and @licenceAdditionalInfo != ''">
            <span ep:role="license-additional-info">
                <xsl:value-of select="$locales/locale[@key='womi_license_additional_info']/text()"/>
                <xsl:value-of select="@licenceAdditionalInfo"/>
            </span>
        </xsl:if>
        <newline/>
    </xsl:template>

    <xsl:template name="storeWOMILicenseInformation">
        <div>
            <span ep:role='license-womi-author'>
            <xsl:choose>
                    <xsl:when test="@authors and @authors != ''">
                        <xsl:value-of select="@authors"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$locales/locale[@key='womi_information_undefined']/text()"/>
                </xsl:otherwise>
            </xsl:choose>
            </span>
            <xsl:text>: </xsl:text>
            <span ep:role="license-womi-title">
            <xsl:choose>
                    <xsl:when test="@cover">
                        <xsl:value-of select="$locales/locale[@key='womi_cover_title']/text()"/>
                    </xsl:when>
                    <xsl:when test="@title and @title != ''">
                        <xsl:value-of select="@title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$locales/locale[@key='womi_information_undefined']/text()"/>
                </xsl:otherwise>
            </xsl:choose>
            </span>
            <span ep:role="license-type">
                <xsl:text> [</xsl:text>
            <xsl:value-of select="$locales/locale[@key='womi_license']/text()"/>
            <xsl:choose>
                <xsl:when test="@licences and @licences != ''">
                    <xsl:value-of select="@licences"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$locales/locale[@key='womi_information_undefined']/text()"/>
                </xsl:otherwise>
            </xsl:choose>
                <xsl:text>]</xsl:text>
            </span>
            
            <xsl:if test="@licenceAdditionalInfo and @licenceAdditionalInfo != ''">
                <span ep:role="license-additional-info">
                    <xsl:value-of select="$locales/locale[@key='womi_license_additional_info']/text()"/>
                    <xsl:value-of select="@licenceAdditionalInfo"/>
                </span>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="content_about">
        <xsl:param name="doc_id"/>
        <xsl:param name="variant"/>
        <xsl:param name="col_id"/>
        <xsl:param name="col_ver"/>
        <xsl:param name="chapter_title"/>
        <xsl:param name="context"/>
        <xsl:param name="mode"/>
        <xsl:param name="mergedModules" tunnel="yes"></xsl:param>
        <xsl:param name="dataFormat" tunnel="yes"></xsl:param>

        <xsl:for-each select="$context/col:content/node()">
            <xsl:choose>
                <xsl:when test="local-name() = 'subcollection'">
                    <xsl:call-template name="content_about">
                        <xsl:with-param name="doc_id" select="$doc_id"/>
                        <xsl:with-param name="variant" select="$variant"/>
                        <xsl:with-param name="col_id" select="$col_id"/>
                        <xsl:with-param name="col_ver" select="$col_ver"/>
                        <xsl:with-param name="chapter_title" select="concat($chapter_title, ' / ', md:title)"/>
                        <xsl:with-param name="context" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="local-name() = 'module'">
                    <xsl:variable name="document_id" select="./@document"/>
                    <xsl:variable name="module" select="$mergedModules/cnxml:documents/cnxml:document[@id = $document_id]/cnxml:metadata"/>
                    <xsl:variable name="module_link"
                        select="concat($www_link, $col_id, '/v/', $col_ver, '/t/', $variant,'/m/', $module/md:content-id)"/>
                    <xsl:variable name="module_id" select="$module/md:content-id"/>

                    <section id="{concat($doc_id, '-', ep:generate-id($module))}" ep:role="about_module">
                        <table id="{concat($doc_id, '-', ep:generate-id($module),'t')}" ep:role="about_module_table" summary="{$locales/locale[@key='about_description_table']}">
                            <title/>
                            <tgroup cols="1">
                                <colspec colnum="1" colname="c1"/>
                                <tbody>
                                    <row>
                                        <entry ep:role="label_module_title">
                                            <span>
                                                <xsl:value-of select="$locales/locale[@key='label_module_title']/text()"/>
                                            </span>
                                            <span>
                                                <xsl:if test="$chapter_title">
                                                    <xsl:value-of select="$chapter_title"/>
                                                    <xsl:text> / </xsl:text>
                                                </xsl:if>

                                                <xsl:value-of select="$module/md:title"/>
                                            </span>
                                        </entry>
                                    </row>
                                    <row>
                                        <entry ep:role="label_module_author">
                                            <xsl:choose>
                                                <xsl:when test="exists($module//ep:generated-type)">
                                                    <span>
                                                        <xsl:value-of select="$locales/locale[@key='label_about_author_generatedType']/text()"/>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <span>
                                                        <xsl:choose>
                                                            <xsl:when test="count($module/md:actors//md:person) > 1">
                                                                <xsl:value-of select="$locales/locale[@key='label_module_author_x']/text()"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="$locales/locale[@key='label_module_author_1']/text()"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                    <span>
                                                        <xsl:apply-templates select="ep:get_authors_from_modules($module)"/>
                                                    </span>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </entry>
                                    </row>
                                    <row>
                                        <entry ep:role="label_module_license">
                                            <span>
                                                <xsl:value-of select="$locales/locale[@key='label_module_license']/text()"/>
                                            </span>
                                            <span>
                                                <xsl:element name="a">
                                                    <xsl:attribute name="href" select="$module/md:license/@url"/>
                                                    <xsl:attribute name="target" select="'_blank'"/>
                                                    <xsl:value-of select="ep:getLicenseNameByLink($module/md:license/@url)"/>
                                                </xsl:element>
                                            </span>
                                        </entry>
                                    </row>
                                    <row>
                                        <entry ep:role="label_module_contact">
                                            <span>
                                                <xsl:value-of select="$locales/locale[@key='label_module_contact']/text()"/>
                                            </span>
                                            <span>
                                                <a>
                                                    <xsl:attribute name="href" select="concat($module_link, '/contact')"/>
                                                    <xsl:attribute name="target" select="'_blank'"/>
                                                    <xsl:value-of select="concat($module_link, '/contact')"/>
                                                </a>
                                            </span>
                                        </entry>
                                    </row>
                                    <row>
                                        <entry ep:role="label_module_www">
                                            <span>
                                                <xsl:value-of select="$locales/locale[@key='label_module_www']/text()"/>
                                            </span>
                                            <span>
                                                <a>
                                                    <xsl:attribute name="href" select="$module_link"/>
                                                    <xsl:attribute name="target" select="'_blank'"/>
                                                    <xsl:value-of select="$module_link"/>
                                                </a>
                                            </span>
                                        </entry>
                                    </row>
                                    <xsl:if test="$module/ep:e-textbook-module/ep:core-curriculum-entries">
                                        <row>
                                            <entry ep:role="label_module_core_curriculum">
                                                <span>
                                                    <xsl:value-of select="$locales/locale[@key='label_module_core_curriculum']/text()"/>
                                                </span>
                                                <newline/>
                                                <xsl:for-each
                                                    select="$module//ep:e-textbook-module/ep:core-curriculum-entries/ep:core-curriculum-entry">
                                                    <span>
                                                        <xsl:choose>
                                                            <xsl:when test="exists(ep:core-curriculum-stage/@ep:key) and exists(ep:core-curriculum-school/@ep:key)">
                                                                <xsl:choose>
                                                                    <xsl:when test="exists(ep:core-curriculum-ability)">
                                                                        <xsl:value-of select="ep:core-curriculum-ability/@ep:key"/>
                                                                        <xsl:text>: </xsl:text>
                                                                        <xsl:value-of select="ep:core-curriculum-ability"/>        
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="ep:core-curriculum-stage/@ep:key"/>
                                                                        <xsl:text>-</xsl:text>
                                                                        <xsl:value-of select="ep:core-curriculum-school/@ep:key"/>
                                                                        <xsl:text>-</xsl:text>
                                                                        <xsl:value-of select="ep:core-curriculum-subject/@ep:key"/>
                                                                        <xsl:text>: </xsl:text>
                                                                        <xsl:value-of select="$locales/locale[@key='text_hpp_outside_ability']/text()"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="ep:core-curriculum-subject"/>
                                                                <xsl:text> </xsl:text>
                                                                <xsl:value-of select="ep:core-curriculum-code"/>
                                                                <xsl:text>: </xsl:text>
                                                                <xsl:copy-of
                                                               select="ep:core-curriculum-keyword/node()"
                                                               copy-namespaces="no"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                    <newline/>
                                                </xsl:for-each>
                                            </entry>
                                        </row>
                                    </xsl:if>
                                    <xsl:if test="$womi_image_metadata_info/womi[@module_id = $module_id]">
                                        <row>
                                            <entry ep:role="label_womi_licenses">
                                                <span>
                                                    <xsl:value-of select="$locales/locale[@key='title_module_answers_licenses']/text()"/>
                                                </span>
                                                <xsl:choose>
                                                    <xsl:when test="$dataFormat = 'mobile_app'">
                                                        <xsl:choose>
                                                            <xsl:when test="$module//ep:generated-type">
                                                                <xsl:for-each select="$mergedModules/cnxml:documents/cnxml:document[@module-id = $module_id]//ep:reference">
                                                                    <xsl:variable name="womiId" select="number(@ep:id)"></xsl:variable>
                                                                    
                                                                    <xsl:if test="$womi_image_metadata_info/womi[@id = $womiId and @module_id = $module_id and @format='mobile_app']">
                                                                        <xsl:apply-templates mode="writeAllLicences"
                                                                            select="$womi_image_metadata_info/womi[@id = $womiId and @module_id = $module_id]"/>
                                                                    </xsl:if>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:for-each select="$womi_image_metadata_info/womi[@module_id = $module_id]">
                                                                    <xsl:if test="./@format='mobile_app'">
                                                                        <xsl:apply-templates mode="writeAllLicences" select="."/>
                                                                    </xsl:if>
                                                                </xsl:for-each>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:choose>
                                                            <xsl:when test="$module//ep:generated-type">
                                                                <xsl:for-each select="$mergedModules/cnxml:documents/cnxml:document[@module-id = $module_id]//ep:reference">
                                                                    <xsl:variable name="womiId" select="number(@ep:id)"></xsl:variable>
                                                                    
                                                                    <xsl:if test="$womi_image_metadata_info/womi[@id = $womiId and @module_id = $module_id][not(@solution) or @solution = '']">
                                                                        <xsl:apply-templates mode="writeAllLicences"
                                                                            select="$womi_image_metadata_info/womi[@id = $womiId and @module_id = $module_id][not(@solution) or @solution = '']"/>
                                                                    </xsl:if>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:for-each select="$womi_image_metadata_info/womi[@module_id = $module_id][not(@solution) or @solution = '']">
                                                                    <xsl:apply-templates mode="writeAllLicences" select="."></xsl:apply-templates>
                                                                </xsl:for-each>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </entry>
                                        </row>
                                    </xsl:if>
                                </tbody>
                            </tgroup>
                        </table>
                    </section>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*" mode="writeAllLicences">        
        <xsl:param name="dataFormat" tunnel="yes"/>
        <xsl:variable name="format" select="@format"/>
        
        <xsl:choose>
            <xsl:when test="$dataFormat = 'mobile_app' and $format = 'mobile_app'">
                <xsl:call-template name="storeWOMILicenseInformation"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$dataFormat"></xsl:when>
                    <xsl:when test="not($format) or $format = ''">
                        <xsl:call-template name="storeWOMILicenseInformation"/>
                    </xsl:when>
                    <xsl:when test="$format = 'pdf'">
                        <ep:alternatives>
                            <ep:alternative>
                                <ep:formats>
                                    <ep:format>static</ep:format>
                                </ep:formats>
                                <xsl:call-template name="storeWOMILicenseInformation"/>
                            </ep:alternative>
                        </ep:alternatives>
                    </xsl:when>
                    <xsl:when test="$format = 'ebook'">
                        <ep:alternatives>
                            <ep:alternative>
                                <ep:formats>
                                    <ep:format>static-mono</ep:format>
                                </ep:formats>
                                <xsl:call-template name="storeWOMILicenseInformation"/>
                            </ep:alternative>
                        </ep:alternatives>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
