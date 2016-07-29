<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bib="http://bibtexml.sf.net/" 
    xmlns:ep="http://epodreczniki.pl/" xmlns:cnxml="http://cnx.rice.edu/cnxml"
    xmlns:col="http://cnx.rice.edu/collxml" xmlns:md="http://cnx.rice.edu/mdml" 
    xmlns:cnxsi="http://cnx.rice.edu/system-info" 
    exclude-result-prefixes="xs xsl bib ep col md cnxml cnxsi"
    version="2.0">

    <xsl:variable name="glossaryElements" as="element()*">
        <elements xmlns="http://cnx.rice.edu/cnxml">
            <xsl:for-each select="$modules_preproc//cnxml:document//node()">
                <xsl:apply-templates select="bib:entry|node()[@ep:glossary='true']" mode="glossary"/>
            </xsl:for-each>
        </elements>
    </xsl:variable>  
    
    <xsl:variable name="glossaryTypes">
        <xsl:text>glossary,concept,event,biography,bibliography</xsl:text>
    </xsl:variable>
    
    <xsl:template name="create_new_glossaries">
        <xsl:variable name="tmp_list" as="element()*">
            <xsl:for-each-group select="$glossaryElements/node()" group-by="local-name(.)">
                <xsl:variable name="curr_key" select="current-grouping-key()"></xsl:variable>
                <xsl:choose>
                    <xsl:when test="some $x in ('biography', 'event', 'concept') satisfies contains($curr_key,$x)">
                        <item><xsl:value-of select="$curr_key"/></item>
                    </xsl:when>
                    <xsl:when test="$curr_key = 'entry'">
                        <item><xsl:value-of select="'bibliography'"/></item>
                    </xsl:when>
                    <xsl:otherwise>
                        <item><xsl:value-of select="'glossary'"/></item>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:variable>
               
        <xsl:variable name="list_glossary_types" as="element()*">
            <xsl:variable name="prefix_module_id" select="concat($coll//col:metadata/md:content-id,'_',$coll//col:metadata/md:version,'_')"/>
            <list>
                <xsl:for-each select="tokenize($glossaryTypes, ',')">
                    <xsl:variable name="curr_type" select="."/>
                    <item module_id="{concat($prefix_module_id,$curr_type)}" module_name="{$locales/locale[@key=concat('gen_',$curr_type)]/text()}" module_type="{$curr_type}"/>
                </xsl:for-each>
            </list>
        </xsl:variable>
        
        <xsl:call-template name="create_glossary_files">
            <xsl:with-param name="list_glossary_types" select="$list_glossary_types"/>
        </xsl:call-template>
        
        <xsl:call-template name="create_new_collection_file">
            <xsl:with-param name="list_glossary_types" select="$list_glossary_types" tunnel="yes"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="create_glossary_files">
        <xsl:param name="list_glossary_types"/>
        
        <xsl:variable name="versions" as="element()*">
            <version cnxml_version="{$modules_preproc//cnxml:document[1]/@cnxml-version}"
                mdml_version="{$modules_preproc//cnxml:document[1]/cnxml:metadata/@mdml-version}"/>
        </xsl:variable>
        <xsl:variable name="eu-timestamp" select="adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT1H'))"/>
        <xsl:variable name="timeInCET" select="format-dateTime($eu-timestamp, '[Y]-[M01]-[D01] [h01]:[m01] CET')"/>

        <xsl:for-each select="$list_glossary_types//item">
            <xsl:call-template name="create_glossary_file">
                <xsl:with-param name="module_data" select="."/>
                <xsl:with-param name="versions" select="$versions"/>
                <xsl:with-param name="timeInCET" select="$timeInCET"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*[@ep:glossary='true']|bib:entry[@ep:show-in='bibliography-and-module']" mode="new_glossary">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:element name="ep:link">
                <xsl:attribute name="ep:role" select="'go-back-from-glossary'"/>
                
                <xsl:variable name="elem_id" select="substring-after(@ep:id|@id, '_')"/>
                <xsl:attribute name="href" select="concat('../',substring-before($elem_id,'_'),'#',$elem_id)"/>
            </xsl:element>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template name="create_glossary_file">
        <xsl:param name="module_data"/>
        <xsl:param name="versions"/>
        <xsl:param name="timeInCET"/>
        
        <xsl:variable name="id" select="$module_data/@module_id"/>
        <xsl:variable name="type" select="$module_data/@module_type"/>
        <xsl:variable name="moduleName" select="$module_data/@module_name"/>
        
        <xsl:result-document href="file:///{$resultDir}/{$id}/index.epxml" indent="no">
            <xsl:element name="document" xmlns="http://cnx.rice.edu/cnxml">
                <xsl:for-each select="$modules_preproc//cnxml:document[1]/namespace::node()">
                    <xsl:if test="local-name(.)">
                        <xsl:namespace name="{local-name(.)}" select="."/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:attribute name="id" select="$id"/>
                <xsl:attribute name="module-id" select="$id"/>
                <xsl:attribute name="cnxml-version" select="$versions/@cnxml_version"/>
                <title>
                    <xsl:value-of select="$moduleName"/>
                </title>
                <metadata mdml-version="{$versions/@mdml_version}">
                    <md:content-id>
                        <xsl:value-of select="$id"/>
                    </md:content-id>
                    <md:repository>https://epodreczniki.pcss.pl/</md:repository>
                    <md:version>1</md:version>
                    <md:created>
                        <xsl:value-of select="$timeInCET"/>
                    </md:created>
                    <md:revised>
                        <xsl:value-of select="$timeInCET"/>
                    </md:revised>
                    <md:title>
                        <xsl:value-of select="$moduleName"/>
                    </md:title>
                    <md:language>pl-PL</md:language>
                    <md:license url="http://creativecommons.org/licenses/by/3.0/pl/legalcode">CC BY 3.0</md:license>
                    <ep:e-textbook-module ep:version="1.5" ep:recipient="student" ep:content-status="canon">
                        <ep:generated-type>
                            <xsl:value-of select="$type"/>
                        </ep:generated-type>
                        <ep:presentation>
                            <ep:numbering>skip</ep:numbering>
                            <ep:type>
                                <xsl:text>EP_technical_module_</xsl:text>
                                <xsl:value-of select="$type"/>
                            </ep:type>
                            <ep:template>linear</ep:template>
                        </ep:presentation>
                    </ep:e-textbook-module>
                </metadata>
                <xsl:choose>
                    <xsl:when test="$type='bibliography'">
                        <content/>
                        <bib:file>
                            <xsl:for-each select="$glossaryElements/bib:entry">
                                <xsl:apply-templates select="." mode="new_glossary"/>
                            </xsl:for-each>
                        </bib:file>
                    </xsl:when>
                    <xsl:otherwise>
                        <content>
                            <section id="{concat($type,'_',ep:generate-id(.))}">
                                <xsl:choose>
                                    <xsl:when test="$type='biography'">
                                        <xsl:for-each select="$glossaryElements/ep:biography">
                                            <xsl:apply-templates select="." mode="new_glossary"/>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="$type='concept'">
                                        <xsl:for-each select="$glossaryElements/ep:concept">
                                            <xsl:apply-templates select="." mode="new_glossary"/>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="$type='event'">
                                        <xsl:for-each select="$glossaryElements/ep:event">
                                            <xsl:apply-templates select="." mode="new_glossary"/>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="$type='glossary'">
                                        <xsl:for-each select="$glossaryElements/cnxml:*">
                                            <xsl:apply-templates select="." mode="new_glossary"/>
                                        </xsl:for-each>
                                    </xsl:when>
                                </xsl:choose>
                            </section>
                        </content>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>     
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="create_new_collection_file">
        <xsl:result-document href="file:///{$resultDir}/collection.xml" indent="no">
            <xsl:apply-templates select="$coll" mode="new_collxml"/>
        </xsl:result-document>        
    </xsl:template>
    
    <xsl:template match="col:collection/col:content" mode="new_collxml">
        <xsl:copy>
            <xsl:apply-templates mode="new_collxml"/>
            <xsl:call-template name="add_new_glossary_module_declaration"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="add_new_glossary_module_declaration">
        <xsl:param name="list_glossary_types" tunnel="yes"/>
        
        <xsl:for-each select="$list_glossary_types//item">
            <xsl:call-template name="create_new_module_def">
                <xsl:with-param name="module_data" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="create_new_module_def">
        <xsl:param name="module_data"/>
        
        <col:module cnxsi:version-at-this-collection-version="1" 
            document="{$module_data/@module_id}" 
            repository="http://epodreczniki.pcss.pl/repo/collxml/module/" 
            version="1">
            <md:title>
                <xsl:value-of select="$module_data/@module_name"/>
            </md:title>
        </col:module>
    </xsl:template>
    
    <xsl:template match="col:module" mode="new_collxml">
        <xsl:variable name="module_id" select="@document"/>
        <xsl:if test="not($modules_preproc//cnxml:document[@module_id = $module_id]/@to_remove)">
            <xsl:copy>
                <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="bib:entry|node()[@ep:glossary='true']" mode="glossary">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="some $x in ('biography', 'event', 'concept') satisfies contains(local-name(.),$x)">
                    <xsl:value-of select="local-name(.)"/>
                </xsl:when>
                <xsl:when test="local-name(.) = 'entry'">
                    <xsl:value-of select="'bibliography'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'glossary'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="type" select="$type" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="cnxml:link" mode="glossary">
        <xsl:copy>
            <xsl:if test="not(@document)">
                <xsl:attribute name="document-refGlossary" select="ancestor::cnxml:document/@module-id"></xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@ep:id|@id|@ep:instance-id" mode="glossary">
        <xsl:param name="type" tunnel="yes"/>
        <xsl:attribute name="{name()}">
            <xsl:choose>
                <xsl:when test="name() = 'ep:id' and parent::node()/name() = 'ep:reference'">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:when test="contains(parent::node()/local-name(), '-reference')">
                    <xsl:choose>
                        <xsl:when test="contains($glossaryTypes,tokenize(.,'_')[1])">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(substring-before(parent::node()/local-name(), '-reference'),'_',.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($type,'_',.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="ep:bibliography-reference" mode="#all">
        <xsl:variable name="curr_id" select="./@ep:id"></xsl:variable>
        <xsl:variable name="ref_bib_sho_opt" select="ancestor::cnxml:document/bib:file/bib:entry[@id=$curr_id]/@ep:show-in"/>
        <xsl:copy copy-namespaces="no">
            <xsl:choose>
                <xsl:when test="@ep:local-reference = 'true' and ($ref_bib_sho_opt='bibliography-only'
                    or $ref_bib_sho_opt='inline-only')">
                    <xsl:copy-of select="@*[local-name() != 'local-reference']"/>
                    <xsl:attribute name="ep:local-reference" select="'false'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@*"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
        
</xsl:stylesheet>