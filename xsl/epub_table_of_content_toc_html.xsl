<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:ep="http://epodreczniki.pl/"
    xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:svg="http://www.w3.org/2000/svg" xmlns:col="http://cnx.rice.edu/collxml" xmlns:md="http://cnx.rice.edu/mdml" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs col md svg m ep epub" version="2.0">

    <xsl:param name="files_to_stylesheet"/>

    <xsl:template match="/">
        <xsl:apply-templates mode="epub_generate_toc_html"/>
    </xsl:template>

    <xsl:template match="col:collection" mode="epub_generate_toc_html">
        <xsl:param name="epub_format"/>
        <xsl:param name="files_to_stylesheet"/>
        <html>
            <head>
                <title><xsl:value-of select="//col:metadata/md:title"/> - spis treści</title>
                <meta charset="utf-8" />
                <xsl:for-each select="tokenize($files_to_stylesheet, ':')">
                    <link rel="stylesheet" type="text/css">
                        <xsl:attribute name="href" select="."/>
                    </link>
                </xsl:for-each>
            </head>
            <body>
                <xsl:call-template name="ep:epub_bk_generate_nav"> </xsl:call-template>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="ep:epub_bk_generate_nav">
        <xsl:element name="nav">
            <xsl:attribute name="id">
                <xsl:text>toc</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="epub:type">
                <xsl:text>toc</xsl:text>
            </xsl:attribute>

            <h1 class="chapter-header">
                <xsl:value-of select="$locales/locale[@key='table_of_content']/text()"/>
            </h1>

            <ol>
                <xsl:call-template name="ep:epub_process_subcollection">
                    <xsl:with-param name="context" select="/col:collection/col:content/col:subcollection"/>
                    <xsl:with-param name="node_type">chapter</xsl:with-param>
                    <xsl:with-param name="title_no_profix"/>
                </xsl:call-template>
            </ol>
        </xsl:element>
    </xsl:template>

    <xsl:function name="ep:calcDepthSubColl" as="xs:integer">
        <xsl:param name="context"/>
        <xsl:value-of select="count($context/preceding-sibling::col:subcollection[(not(@ep:numbering) or @ep:numbering != 'skip') and (not(@toc) or @toc='include') 
            and (contains(./descendant::node()[local-name() = 'module'][1]/@document, 'answers')
            or (count(./descendant::node()[local-name() = 'module' and (((not(@ep:numbering) or @ep:numbering != 'skip') and (not(@toc) or @toc='include')))]) > 0))]
            | $context/preceding-sibling::col:module[(not(@ep:numbering) or @ep:numbering != 'skip') and (not(@toc) or @toc='include')])"/>
    </xsl:function>

    <xsl:template name="ep:epub_process_subcollection">
        <xsl:param name="context"/>
        <xsl:param name="node_type"/>
        <xsl:param name="title_no_profix"/>
        <xsl:for-each select="$context">
            <xsl:choose>
                <xsl:when test="@toc = 'skip'"/>
                <xsl:otherwise>
                    <xsl:variable name="title_no_profix2" select="concat($title_no_profix, ep:calcDepthSubColl(.)+1, '.')"/>
                    <li>
                        <xsl:attribute name="class">
                            <xsl:value-of select="concat('toc-', $node_type)"/>
                        </xsl:attribute>

                        <xsl:choose>
                            <xsl:when test="count(./col:content/col:module) = 1 and not(./md:title)">
                                <xsl:call-template name="ep:epub_bk_generate_a_href">
                                    <xsl:with-param name="context" select="./col:content/col:module[1]"/>
                                    <xsl:with-param name="node_type" select="$node_type"/>
                                    <xsl:with-param name="title_no_profix" select="$title_no_profix2"/>
                                    <xsl:with-param name="title_value" select="./col:content/col:module/md:title"/>
                                </xsl:call-template>

                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="ep:epub_bk_generate_a_href">
                                    <xsl:with-param name="context" select="./col:content/child::node()[local-name() = 'subcollection' or local-name() = 'module'][1]/descendant-or-self::col:module[1]"/>
                                    <xsl:with-param name="node_type" select="$node_type"/>
                                    <xsl:with-param name="title_no_profix" select="$title_no_profix2"/>
                                    <xsl:with-param name="title_value"/>
                                </xsl:call-template>

                                <xsl:if test="./col:content/col:module | ./col:content/col:subcollection">
                                    <ol>
                                        <xsl:for-each select="./col:content/child::*">
                                            <xsl:choose>
                                                <xsl:when test="@toc = 'skip'"/>
                                                <xsl:otherwise>
                                                    <xsl:choose>
                                                        <xsl:when test="local-name(.) = 'module'">
                                                            <xsl:call-template name="ep:epub_bk_process_module">
                                                                <xsl:with-param name="context" select="."/>
                                                                <xsl:with-param name="title_no_profix" select="$title_no_profix2"/>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                        <xsl:when test="local-name(.) = 'subcollection'">
                                                            <xsl:call-template name="ep:epub_process_subcollection">
                                                                <xsl:with-param name="context" select="."/>
                                                                <xsl:with-param name="node_type">subchapter</xsl:with-param>
                                                                <xsl:with-param name="title_no_profix" select="$title_no_profix2"/>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>
                                    </ol>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </li>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="ep:epub_bk_process_module">
        <xsl:param name="context"/>
        <xsl:param name="title_no_profix"/>

        <li class="toc-section">
            <xsl:call-template name="ep:epub_bk_generate_a_href">
                <xsl:with-param name="context" select="."> </xsl:with-param>
                <xsl:with-param name="node_type">section</xsl:with-param>
                <xsl:with-param name="title_no_profix" select="concat($title_no_profix, ep:calcDepthSubColl(.)+1, '.')"/>
                <xsl:with-param name="title_value"/>
            </xsl:call-template>
        </li>

    </xsl:template>

    <xsl:template name="ep:epub_bk_generate_a_href">
        <xsl:param name="context"/>
        <xsl:param name="node_type"/>
        <xsl:param name="title_no_profix"/>
        <xsl:param name="title_value"/>

        <a>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('target-', $node_type)"/>
                
                <xsl:variable name="mod_id">
                    <xsl:choose>
                        <xsl:when test="local-name() = 'subcollection'">
                            <xsl:value-of select="./col:content/col:module[1]/@document"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@document"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:if test="$modules_epxhtml/div[@id = $mod_id]/@ep:role">
                    <xsl:text> </xsl:text>
                    <xsl:apply-templates select="$modules_epxhtml/div[@id = $mod_id]/@ep:role"></xsl:apply-templates>
                </xsl:if>
                
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:text>m_</xsl:text>
                <xsl:value-of select="ep:extract_module_ids_from_module_elements($context)"/>
                <xsl:text>.html</xsl:text>
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
            </span>
        </a>
    </xsl:template>

</xsl:stylesheet>
