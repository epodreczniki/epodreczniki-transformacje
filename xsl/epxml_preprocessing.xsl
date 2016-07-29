<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cnxsi="http://cnx.rice.edu/system-info"
    xmlns:col="http://cnx.rice.edu/collxml" xmlns:ep="http://epodreczniki.pl/"
    xmlns:cnxml="http://cnx.rice.edu/cnxml" xmlns:md="http://cnx.rice.edu/mdml" 
    xmlns:epe="http://epodreczniki.pl/editor" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:bib="http://bibtexml.sf.net/"
    exclude-result-prefixes="xs ep epe cnxml md mml" version="2.0">
    
    <xsl:import href="common.xslt"/>  
    <xsl:include href="mathml_corrector.xsl"/>
    <xsl:include href="glossary_generator.xsl"/>
    
    <xsl:param name="resultDir" select="'1'"/>
    <xsl:param name="path_to_files_epxml_of_modules_in_col" select="'1'"/>
    
    <xsl:variable name="modules_preproc">
        <xsl:variable name="moduleIds">
            <xsl:for-each select="$coll//col:module">
                <id><xsl:value-of select="@document"/></id>
            </xsl:for-each>
        </xsl:variable>
        
        <documents xmlns="http://cnx.rice.edu/cnxml">
            <xsl:for-each select="$moduleIds/id">
                <xsl:variable name="moduleContent" select="document(concat($path_to_files_epxml_of_modules_in_col, '/', ., '/index.epxml'))"/>
                <xsl:choose>
                    <xsl:when test="not($moduleContent//ep:e-textbook-module/ep:generated-type)">
                        <xsl:copy-of select="$moduleContent"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <document to_remove="true" module_id="{.}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </documents>      
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:message>
            <xsl:text>[xslt] Transforming module to passed variants </xsl:text>
        </xsl:message>
        
        <xsl:call-template name="create_new_glossaries"/>
        
        <xsl:for-each select="$modules_preproc//cnxml:document">
            <xsl:if test="not(@to_remove)">
                <xsl:variable name="moduleId" select=".//@module-id"/>
                <xsl:result-document href="file:///{$resultDir}/{$moduleId}/index.epxml">
                    <xsl:apply-templates select="." mode="copy_module_content"/>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
    <xsl:template match="bib:entry" mode="copy_module_content">
        <xsl:if test="@ep:show-in != 'bibliography-only'">
            <xsl:copy>
                <xsl:apply-templates select="node() | @*" mode="#current"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="#all">        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ep:technical-remarks" mode="#all">
        <xsl:if test="ep:show_technical_remarks() = 'true'">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="epe:review" mode="#all">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="epe:*" mode="#all">  
    </xsl:template>
    
</xsl:stylesheet>