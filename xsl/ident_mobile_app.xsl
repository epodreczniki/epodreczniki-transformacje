<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="test" xmlns:ep="http://epodreczniki.pl/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="html" />

    <xsl:template match="*[not(local-name() = 'math' or ancestor::node()[local-name()='math'] 
        or local-name() = 'svg' or ancestor::node()[local-name()='svg'])]">
        <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*[namespace-uri(.) != 'http://epodreczniki.pl/']">
         <xsl:copy/>
    </xsl:template>

</xsl:stylesheet>