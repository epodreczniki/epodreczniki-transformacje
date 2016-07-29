<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:epub="http://www.idpf.org/2007/ops" xmlns:ep="http://epodreczniki.pl/"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:col="http://cnx.rice.edu/collxml"
    xmlns:md="http://cnx.rice.edu/mdml"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs col md m ep epub svg" version="2.0">

    <xsl:import href="epub_table_of_content_toc_html.xsl"/>

    <xsl:template match="col:collection" mode="pdf_generate_toc">
        <xsl:call-template name="ep:pdf_bk_generate_nav"> </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="ep:pdf_bk_generate_nav">
        <xsl:element name="div">
            <xsl:attribute name="id">
                <xsl:text>toc</xsl:text>
            </xsl:attribute>
            
            <h1 class="title">
                <xsl:value-of select="$locales/locale[@key='table_of_content']/text()"/>
            </h1>
            
            <ol>
                <xsl:call-template name="ep:epub_process_subcollection">
                    <xsl:with-param name="context" select="/col:collection/col:content/col:subcollection"/>
                    <xsl:with-param name="node_type">chapter</xsl:with-param>
                    <xsl:with-param name="title_no_profix"></xsl:with-param>
                </xsl:call-template>         
            </ol>
        </xsl:element>
    </xsl:template>
 
    <xsl:template name="ep:epub_bk_generate_a_href">
        <xsl:param name="context"></xsl:param>
        <xsl:param name="node_type"></xsl:param>
        <xsl:param name="title_no_profix"></xsl:param>
        <xsl:param name="title_value"></xsl:param>
        
        <xsl:variable name="mod_id">
            <xsl:choose>
                <xsl:when test="local-name() = 'subcollection'">
                    <xsl:value-of select="(.//col:module)[1]/@document"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@document"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <a>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('target-', $node_type)"/>
            </xsl:attribute>
            
            <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:choose>
                    <xsl:when test="$node_type = 'chapter' or $node_type = 'subchapter'">
                        <xsl:value-of select="concat('toc_', $mod_id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ep:extract_module_ids_from_module_elements($context)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <span>
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('cnx-gentext-', $node_type)"/>
                </xsl:attribute>

                <xsl:variable name="are_count_modules_without_numbering" select="count(descendant::node()[local-name() = 'module' and (not(@ep:numbering) or @ep:numbering != 'skip')]) > 0"></xsl:variable>
                <xsl:if test="$node_type='chapter' and $are_count_modules_without_numbering">
                    <xsl:value-of select="$locales/locale[@key='chapter']/text()"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
                
                <xsl:choose>
                    <xsl:when test="$node_type = 'chapter' or $node_type = 'subchapter'">
                        <xsl:if test="$are_count_modules_without_numbering">
                            <xsl:value-of select="$title_no_profix"/>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="not(@ep:numbering) or @ep:numbering != 'skip'">
                            <xsl:value-of select="$title_no_profix"/>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:choose>
                    <xsl:when test="$title_value">
                        <xsl:value-of select="$title_value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./md:title"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:variable name="module_id">
                    <xsl:choose>
                        <xsl:when test="local-name() = 'subcollection'">
                            <xsl:value-of select=".//col:module[1]/@document"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'module'">
                            <xsl:value-of select="./@document"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:for-each select="tokenize($modules_epxhtml//div[@id = $module_id]/@ep:role, ' ')">
                    <xsl:choose>
                        <xsl:when test="contains(., 'recipient-teacher')">
                            <span class="recipient-teacher" title="{$locales/locale[@key='label_content_status_teacher']/text()}">
                                <xsl:value-of select="$locales/locale[@key='shortcut_content_status_teacher']/text()"></xsl:value-of>
                            </span>
                        </xsl:when>
                        <xsl:when test="contains(., 'content-status-expanding')">
                            <span class="content-status-expanding" title="{$locales/locale[@key='label_content_status_expanding']/text()}">
                                <xsl:value-of select="$locales/locale[@key='shortcut_content_status_expanding']/text()"></xsl:value-of>
                            </span>
                        </xsl:when>
                        <xsl:when test="every $x in ('recipient-student','content-status-canon') satisfies not(contains(.,$x))">
                            <xsl:if test=". != ''">
                                <span>
                                    <xsl:attribute name="class">
                                        <xsl:choose>
                                            <xsl:when test="contains(., 'EP_technical_module')">
                                                <xsl:value-of select="ep:map_role2css(.)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="."></xsl:value-of>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </span>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </span>
        </a>
    </xsl:template>

</xsl:stylesheet>
