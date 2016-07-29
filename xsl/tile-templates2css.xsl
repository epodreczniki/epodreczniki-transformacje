<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ep="http://epodreczniki.pl/"
    exclude-result-prefixes="xs ep"
    version="2.0">
    
    <xsl:output method="xml" indent="no"></xsl:output>
    
    <xsl:param name="resultPath"></xsl:param>
    
    <xsl:template match="/">
        <xsl:result-document href="file:///{$resultPath}">
            <roles>
                <xsl:apply-templates></xsl:apply-templates>
            </roles>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="moduleTypeSet|tiled">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="module">
        <xsl:variable name="type_key">
            <xsl:choose>
                <xsl:when test="type != ''">
                    <xsl:value-of select="ep:only_alpha_numeric(ep:only_ascii(concat(../typesSetCode, '_', type)))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ep:only_alpha_numeric(ep:only_ascii(../typesSetCode))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="type_value" select="$type_key"></xsl:variable>
        <role key="{$type_key}" value="{concat('mt_', $type_value)}"></role>
        <xsl:apply-templates select="*/section">
            <xsl:with-param name="type_key" select="$type_key"></xsl:with-param>
            <xsl:with-param name="type_value" select="$type_value"></xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="section">
        <xsl:param name="type_key"></xsl:param>
        <xsl:param name="type_value"></xsl:param>
        <role key="{concat($type_key, '_', ep:only_alpha_numeric(ep:only_ascii(role)))}" 
            value="{concat('sr_', $type_value, '_', ep:only_alpha_numeric(ep:only_ascii(role)))}">
            <xsl:copy-of select="parameters/parameter" copy-namespaces="no"></xsl:copy-of>
        </role>
        <role key="{concat($type_key, '_', ep:only_alpha_numeric(ep:only_ascii(role)), '_display')}" value="{role}">
        </role>
    </xsl:template>
    
    <xsl:function name="ep:only_ascii" as="xs:string">
        <xsl:param name="input"></xsl:param>
        <xsl:value-of  select="translate($input, 'ąęćńłóśżźĄĘĆŃŁÓŚŻŹ','aecnloszzAECNLOSZZ')"></xsl:value-of>
    </xsl:function>
    
    <xsl:function name="ep:only_alpha_numeric" as="xs:string">
        <xsl:param name="input"/>
        <xsl:value-of select="replace($input, '[^a-zA-Z0-9_]', '')"></xsl:value-of>
    </xsl:function>
    
    <xsl:template match="text()"></xsl:template>
    
</xsl:stylesheet>