<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="2.0">

<xsl:output method="xhtml"/>

<xsl:template name="ident" match="@*|node()|comment()|processing-instruction()">
    <xsl:copy copy-namespaces="no">
        <xsl:apply-templates select="@*|node()|comment()|processing-instruction()"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
