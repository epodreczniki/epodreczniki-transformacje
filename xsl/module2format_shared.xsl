<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ep="http://epodreczniki.pl/" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs ep" version="2.0">
    
    <xsl:template match="div[@class='answer']//textarea">
        <div>
            <xsl:attribute name="class" select="ep:map_role2css('textarea-placeholder')" />
            <xsl:value-of select="$locales/locale[@key='textarea_text_static_format']/text()"/>
        </div>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='date' or @ep:role='location' or @ep:role='author']/div">
        <xsl:element name="span">
            <xsl:attribute name="class" select="ep:map_role2css(@ep:role)"/>
            <xsl:apply-templates select="node()"></xsl:apply-templates>            
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="span[ancestor::div[@ep:role='date' or @ep:role='location' or @ep:role='author']]/text()">
        <xsl:value-of select="concat(translate(., '&#160;', ''), ': ')"></xsl:value-of>
    </xsl:template>
    
 </xsl:stylesheet>
