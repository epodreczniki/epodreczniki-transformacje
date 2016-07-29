<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cnxsi="http://cnx.rice.edu/system-info"
    xmlns:col="http://cnx.rice.edu/collxml" xmlns:ep="http://epodreczniki.pl/"
    xmlns:cnxml="http://cnx.rice.edu/cnxml" xmlns:md="http://cnx.rice.edu/mdml"
    exclude-result-prefixes="xs" version="2.0">
    
    <xsl:param name="resultDir"
        select="'1'"/>
    <xsl:param name="variants" select="'sc:se:ss:tc:te:ts'"/>
    
    <xsl:template match="/">
        <xsl:if test="contains($variants, 'tc')">
            <xsl:call-template name="checkIfCollectionsHasAtLeastOneModule">
                <xsl:with-param name="p_recipient" select="'teacher'"/>
                <xsl:with-param name="p_content-status" select="'canon'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="contains($variants, 'te')">
            <xsl:call-template name="checkIfCollectionsHasAtLeastOneModule">
                <xsl:with-param name="p_recipient" select="'teacher'"/>
                <xsl:with-param name="p_content-status" select="'expanding'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="contains($variants, 'ts')">
            <xsl:call-template name="checkIfCollectionsHasAtLeastOneModule">
                <xsl:with-param name="p_recipient" select="'teacher'"/>
                <xsl:with-param name="p_content-status" select="'supplemental'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="contains($variants, 'sc')">
            <xsl:call-template name="checkIfCollectionsHasAtLeastOneModule">
                <xsl:with-param name="p_recipient" select="'student'"/>
                <xsl:with-param name="p_content-status" select="'canon'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="contains($variants, 'se')">
            <xsl:call-template name="checkIfCollectionsHasAtLeastOneModule">
                <xsl:with-param name="p_recipient" select="'student'"/>
                <xsl:with-param name="p_content-status" select="'expanding'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="contains($variants, 'ss')">
            <xsl:call-template name="checkIfCollectionsHasAtLeastOneModule">
                <xsl:with-param name="p_recipient" select="'student'"/>
                <xsl:with-param name="p_content-status" select="'supplemental'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="checkIfCollectionsHasAtLeastOneModule">
        <xsl:param name="p_recipient"/>
        <xsl:param name="p_content-status"/>
        
        <xsl:choose>
            <xsl:when test="count(ep:getNoOfCurrSubcollModulesInCurrVariant(., $p_recipient, $p_content-status)) > 0">
                <xsl:message>
                    <xsl:value-of select="concat('[xslt] Variant: ', concat($p_recipient, '-', $p_content-status), ' occurs')"></xsl:value-of>
                </xsl:message>
                <xsl:element name="col:content">
                <xsl:call-template name="createModifiedCollXML">
                    <xsl:with-param name="p_recipient" select="$p_recipient"/>
                    <xsl:with-param name="p_content-status" select="$p_content-status"/>
                </xsl:call-template>
            </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:value-of select="concat('[xslt] Variant: ', concat($p_recipient, '-', $p_content-status), ' NOT occurs')"></xsl:value-of>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    
    <xsl:template name="createModifiedCollXML">
        <xsl:param name="p_recipient"/>
        <xsl:param name="p_content-status"/>
        
        <xsl:result-document
            href="file:///{$resultDir}/{$p_recipient}-{$p_content-status}/collection.xml">
            <xsl:apply-templates select="node() | @*" mode="modifyCollXML">
                <xsl:with-param name="p_recipient" select="$p_recipient"/>
                <xsl:with-param name="p_content-status" select="$p_content-status"/>
            </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="ep:e-textbook" mode="modifyCollXML">
        <xsl:param name="p_recipient"/>
        <xsl:param name="p_content-status"/>
        
        <xsl:copy>
            <xsl:attribute name="ep:content-status" select="$p_content-status"/>
            <xsl:attribute name="ep:recipient" select="$p_recipient"/>
            <xsl:apply-templates  select="node() | @*[not(name()='ep:content-status' or name()='ep:recipient')]" mode="modifyCollXML">
                <xsl:with-param name="p_recipient" select="$p_recipient"/>
                <xsl:with-param name="p_content-status" select="$p_content-status"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="col:collection//col:subcollection" mode="modifyCollXML">
        <xsl:param name="p_recipient"/>
        <xsl:param name="p_content-status"/>
        
        <xsl:for-each select=".">
            <xsl:if
                test="count(ep:getNoOfCurrSubcollModulesInCurrVariant(., $p_recipient, $p_content-status)) > 0">
                <xsl:element name="col:subcollection">
                    <xsl:apply-templates select="node() | @*" mode="modifyCollXML">
                        <xsl:with-param name="p_recipient" select="$p_recipient"/>
                        <xsl:with-param name="p_content-status" select="$p_content-status"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="ep:getNoOfCurrSubcollModulesInCurrVariant" as="xs:string*">
        <xsl:param name="ctx"></xsl:param>
        <xsl:param name="p_recipient"/>
        <xsl:param name="p_content-status"/>
        
        <xsl:for-each select="$ctx//col:module">
            <xsl:variable name="path" select="concat('file:///', $resultDir, '/' ,$p_recipient, '-', $p_content-status, '/', ./@document, '/index.epxml')"></xsl:variable>
            
            <xsl:if test="ep:checkIfFileExists($path) = '1'">
                <xsl:value-of select="'1'"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template match="col:content/col:module" mode="modifyCollXML">
        <xsl:param name="p_recipient"/>
        <xsl:param name="p_content-status"/>
        
        <xsl:variable name="path" select="concat('file:///', $resultDir, '/' ,$p_recipient, '-', $p_content-status, '/', ./@document, '/index.epxml')"></xsl:variable>
        
        <xsl:choose>
            <xsl:when test="ep:checkIfFileExists($path) = '1'">
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*" mode="modifyCollXML">
                        <xsl:with-param name="p_recipient" select="$p_recipient"/>
                        <xsl:with-param name="p_content-status" select="$p_content-status"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="ep:checkIfFileExists" as="xs:string">
        <xsl:param name="p_path"/>
        
        <xsl:choose>
            <xsl:when test="doc-available($p_path)">
                <xsl:value-of select="'1'"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'0'"></xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="node() | @*" mode="modifyCollXML">
        <xsl:param name="p_recipient"/>
        <xsl:param name="p_content-status"/>
        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="modifyCollXML">
                <xsl:with-param name="p_recipient" select="$p_recipient"/>
                <xsl:with-param name="p_content-status" select="$p_content-status"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>