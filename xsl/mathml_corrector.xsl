<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cnxml="http://cnx.rice.edu/cnxml" xmlns:md="http://cnx.rice.edu/mdml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:q="http://cnx.rice.edu/qml/1.0" xmlns:ep="http://epodreczniki.pl/" xmlns="http://cnx.rice.edu/cnxml"
    xmlns:col="http://cnx.rice.edu/collxml" xmlns:bib="http://bibtexml.sf.net/" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:tmp="tmp" exclude-result-prefixes="md col tmp"
    version="2.0">

    <xsl:function name="ep:checkIfIsIncorrectFunTryInPowerNode" as="element()*">
        <xsl:param name="node_curr"/>
        <xsl:param name="node_next"/>
        
        <xsl:variable name="node_next_child" select="($node_next//descendant::node()[normalize-space(.) 
            and local-name()='mi'][1])[1]"/>
        <xsl:variable name="concatVal" select="concat($node_curr,$node_next_child)"/>
        
        
        <xsl:choose>
            <xsl:when test="some $x in ('sin', 'cos', 'tg', 'ctg', 'log', 'ln', 'log', 'sgn') satisfies $concatVal=$x">
                <tmp:result>
                    <tmp:value>
                        <xsl:value-of select="$concatVal"/>
                    </tmp:value>
                </tmp:result>
            </xsl:when>
            <xsl:when test="some $x in ('sin', 'cos', 'tg', 'ctg', 'log', 'ln', 'log', 'sgn') satisfies ends-with($concatVal,$x)">
                <xsl:variable name="part1" select="tokenize($concatVal,'sin|cos|tg|ctg|log|ln|log|sgn')[1]"/>
                <tmp:result>
                    <tmp:new_elem>
                        <xsl:value-of select="$part1"/>
                    </tmp:new_elem>
                    <tmp:value>
                        <xsl:value-of select="substring-after($concatVal,$part1)"/>
                    </tmp:value>
                </tmp:result>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="mml:math[descendant::mml:msup]">
        <xsl:call-template name="processMathmlData"/>
    </xsl:template>
    
    <xsl:template name="processMathmlData">        
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="node()[normalize-space(.)]">
                <xsl:variable name="node_curr" select="."/>
                <xsl:variable name="node_next" select="following::node()[normalize-space(.)][1]"/>
                
                <xsl:choose>
                    <xsl:when test="local-name($node_next)='msup'">
                        <xsl:variable name="concatFunction" select="ep:checkIfIsIncorrectFunTryInPowerNode(.,$node_next)"/>
                        
                        <xsl:if test="empty($concatFunction)">
                            <xsl:copy copy-namespaces="no">
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="local-name($node_curr) = 'msup' and $node_curr/preceding-sibling::node()/normalize-space(local-name())[1]='mi'">
                        <xsl:variable name="node_next_child" select="($node_curr//descendant::node()[normalize-space(.) 
                            and local-name()='mi'][1])[1]"/>
                        
                        <xsl:choose>
                            <xsl:when test="some $x in ('sin', 'cos', 'tg', 'ctg', 'log', 'ln', 'log', 'sgn') satisfies contains($node_next_child,$x)">
                                <xsl:copy copy-namespaces="no">
                                    <xsl:apply-templates select="@*|node()"/>
                                </xsl:copy>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="node_prev" select="$node_curr/preceding::node()[normalize-space(.) and local-name() = 'mi' and ancestor::mml:math][1]"/>
                                <xsl:variable name="concatFunction" select="ep:checkIfIsIncorrectFunTryInPowerNode($node_prev,.)"/>

                                <xsl:choose>
                                    <xsl:when test="$concatFunction">
                                        <xsl:if test="count($concatFunction/node()) = 2">
                                            <mml:mi><xsl:value-of select="$concatFunction/tmp:new_elem"/></mml:mi>
                                        </xsl:if>
                                        
                                        <xsl:copy copy-namespaces="no">
                                            <xsl:apply-templates select="@*|node()" mode="modify_msup_child">
                                                <xsl:with-param name="new_msup_child_value" select="$concatFunction/tmp:value" tunnel="yes"/>
                                            </xsl:apply-templates>
                                        </xsl:copy>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy copy-namespaces="no">
                                            <xsl:choose>
                                                <xsl:when test="descendant::node()/local-name() = 'msup'">
                                                    <xsl:call-template name="processMathmlData"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:apply-templates select="@*|node()"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:copy>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="count(descendant::node()[normalize-space(.)]) = 1">
                                <xsl:copy copy-namespaces="no">
                                    <xsl:apply-templates select="@*|node()"/>
                                </xsl:copy>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="processMathmlData"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()" mode="modify_msup_child" priority="1">
        <xsl:param name="new_msup_child_value" tunnel="yes"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="local-name(.) = 'mi'">
                    <xsl:value-of select="$new_msup_child_value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|node()" mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
	
	<xsl:template match="mml:mfenced" mode="variants">
        <xsl:copy copy-namespaces="no">
            <xsl:choose>
                <xsl:when test="ancestor::mml:mfenced">
                    <xsl:attribute name="open" select="'('"/>
                    <xsl:attribute name="close" select="')'"/>
                    <xsl:apply-templates select="@*|node()" mode="variants"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|node()" mode="variants"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="cnxml:equation" mode="variants">
        <xsl:if test="count(child::node()[normalize-space(.)]) > 0">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="variants"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mml:math" mode="variants">
        <xsl:if test="count(child::node()[normalize-space(.)]) > 0">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="variants"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
   
</xsl:stylesheet>