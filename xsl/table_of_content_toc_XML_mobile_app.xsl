<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops"
    xmlns:ep="http://epodreczniki.pl/" xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:cnxml="http://cnx.rice.edu/cnxml" xmlns:col="http://cnx.rice.edu/collxml" xmlns:md="http://cnx.rice.edu/mdml"
    exclude-result-prefixes="xs col md svg m ep epub cnxml" version="2.0">

    <xsl:param name="files_to_stylesheet"/>
    <xsl:param name="outputFormat"/>

    <xsl:template match="col:collection" mode="generate_toc_html">
        <toc>
            <xsl:call-template name="ep:process_subcollection">
                <xsl:with-param name="context" select="/col:collection/col:content/col:subcollection"/>
                <xsl:with-param name="title_no_profix"/>
            </xsl:call-template>
        </toc>
    </xsl:template>

    <xsl:template name="ep:process_subcollection">
        <xsl:param name="context"/>
        <xsl:param name="title_no_profix"/>

        <xsl:for-each select="$context">
            <xsl:choose>
                <xsl:when test="contains((.//col:module[1])[1]/@document, 'second_page')">
                    <node>
                        <xsl:call-template name="ep:process_module">
                            <xsl:with-param name="context" select="./col:content/col:module[1]"/>
                            <xsl:with-param name="title_value" select="./col:content/col:module[1]/md:title"/>
                        </xsl:call-template>
                    </node>
                </xsl:when>
                <xsl:when test="contains((.//col:module[1])[1]/@document, 'answers')"/>
                <xsl:otherwise>
                    <xsl:variable name="title_no_profix2">
                        <xsl:value-of select="$title_no_profix"/>
                        <xsl:if test="$title_no_profix">
                            <xsl:text>.</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="ep:calcDepthSubColl(.)+1"></xsl:value-of>
                    </xsl:variable>
                    <node>
                        <xsl:choose>
                            <xsl:when test="count(./col:content/col:module) = 1 and not(./md:title)">
                                <xsl:call-template name="ep:process_module">
                                    <xsl:with-param name="context" select="./col:content/col:module[1]"/>
                                    <xsl:with-param name="title_value" select="./col:content/col:module[1]/md:title"/>
                                    <xsl:with-param name="title_no_profix" select="$title_no_profix2"/>
                                    <xsl:with-param name="isSubcollectioOneElem" select="true()"></xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="ep:process_module">
                                    <xsl:with-param name="context"
                                        select="./col:content/child::node()[local-name() = 'subcollection' or local-name() = 'module'][1]/descendant-or-self::col:module[1]"/>
                                    <xsl:with-param name="title_value" select="./md:title"/>
                                    <xsl:with-param name="isSubcollection" select="true()"></xsl:with-param>
                                    <xsl:with-param name="title_no_profix" select="$title_no_profix2"/>
                                </xsl:call-template>

                                <xsl:if test="./col:content/col:module | ./col:content/col:subcollection">
                                    <children>
                                        <xsl:for-each select="./col:content/child::*">
                                            <xsl:choose>
                                                <xsl:when
                                                    test="contains(./@document, 'second_page') or contains(./@document, 'answers')"/>
                                                <xsl:otherwise>
                                                    <xsl:choose>
                                                        <xsl:when test="local-name(.) = 'module'">
                                                            <node>
                                                                <xsl:call-template name="ep:process_module">
                                                                    <xsl:with-param name="context" select="."> </xsl:with-param>
                                                                    <xsl:with-param name="title_value" select="./md:title"/>
                                                                    <xsl:with-param name="title_no_profix" select="$title_no_profix2"/>
                                                                </xsl:call-template>
                                                            </node>
                                                        </xsl:when>
                                                        <xsl:when test="local-name(.) = 'subcollection'">
                                                            <xsl:call-template name="ep:process_subcollection">
                                                                <xsl:with-param name="context" select="."/>
                                                                <xsl:with-param name="title_no_profix" select="$title_no_profix2"/>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>
                                    </children>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </node>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="ep:process_module">
        <xsl:param name="context"/>
        <xsl:param name="title_value"/>
        <xsl:param name="title_no_profix"/>
        <xsl:param name="isSubcollection" select="false()"/>
        <xsl:param name="isSubcollectioOneElem" select="false()"></xsl:param>

        <xsl:variable name="currModule" select="$modules_epxhtml/div[contains(@id,$context/@document)][1]"/>
        <xsl:variable name="modulePaginations" select="$modules_epxhtml/div[contains(@id,$context/@document)]"/>
        <xsl:variable name="isFirstPaginationHasTile">
            <xsl:choose>
                <xsl:when test="not(contains($currModule/@id, 'about')) 
                    and count($modulePaginations) > 1 
                    and (($modulePaginations/div)[1][@data-start-new-page='true']//span[@ep:role='title' and parent::node()[contains(@ep:role,'section')]][1])[1]">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="subIdPostfix">
            <xsl:text>_k</xsl:text>
            <xsl:value-of select="count(ancestor::col:subcollection)+1"/>
            <xsl:value-of select="count(ancestor::col:module)+1"/>
            <xsl:value-of select="ep:generate-id(.)"/>
        </xsl:variable>
        
        <xsl:variable name="moduleTocId">
            <xsl:choose>
                <xsl:when test="contains($currModule/@id, 'about')">
                    <xsl:value-of select="concat(substring-before($currModule/@id,'_about_'),'_about_1')"/>
                    <xsl:text>_k123</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$currModule/@id"/>
                    <xsl:value-of select="$subIdPostfix"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="currTitleValue">
            <xsl:choose>
                <xsl:when test="not($title_value)">
                    <xsl:value-of select="$context/md:title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$title_value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:call-template name="ep:create_toc_module">
            <xsl:with-param name="contextCollModule" select="$context"/>
            <xsl:with-param name="title_value" select="$currTitleValue"/>
            <xsl:with-param name="currModule" select="$currModule"/>
            <xsl:with-param name="title_no_profix">
                <xsl:value-of select="$title_no_profix"></xsl:value-of>
                <xsl:if test="$isSubcollection = false() and $isSubcollectioOneElem = false()">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="ep:calcDepthSubColl(.)+1"></xsl:value-of>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="tocId" select="$moduleTocId"/>
        </xsl:call-template>

        <xsl:if test="$isSubcollection = false()">
            <children>
                <xsl:if test="not(contains($currModule/@id, 'about')) and count($modulePaginations) > 1">
                    <xsl:for-each select="$modulePaginations">
                        <xsl:variable name="currNewPage" select="./div[contains(@ep:role, 'section') and contains(@ep:role, 'level_1') and @data-start-new-page='true']"/>
                        
                        <xsl:variable name="lastSectionWithTitleTocId">
                            <xsl:if test="not($currNewPage/node()[@ep:role='section-header']/span/@ep:title != '')">
                                <xsl:variable name="preSectionWithTitle" select="preceding::div[contains(@ep:role, 'section') and contains(@ep:role, 'level_1') and @data-start-new-page='true' 
                                    and .//span[@ep:role='title'] and ./parent::div[@id = $currModule/@id]][1]"/>
                                <xsl:choose>
                                    <xsl:when test="$preSectionWithTitle">
                                        <xsl:value-of select="$preSectionWithTitle/parent::div/@data-pagination-id"/>
                                        <xsl:value-of select="$subIdPostfix"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$moduleTocId"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </xsl:variable>
                        
                        <node>
                            <xsl:call-template name="ep:create_toc_module">
                                <xsl:with-param name="contextCollModule" select="$context"/>
                                <xsl:with-param name="title_value" select="(./div[@data-start-new-page='true']//span[@ep:role='title' and parent::node()[contains(@ep:role,'section')]][1])[1]"/>
                                <xsl:with-param name="currModule" select="."/>
                                <xsl:with-param name="isPaginationOfModule" select="true()"/>
                                <xsl:with-param name="tocId">
                                    <xsl:value-of select="@data-pagination-id"/>
                                    <xsl:value-of select="$subIdPostfix"/>
                                </xsl:with-param>
                                <xsl:with-param name="lastSectionWithTitleTocId" select="$lastSectionWithTitleTocId"/>
                            </xsl:call-template>
                            <children/>
                        </node>
                    </xsl:for-each>
                </xsl:if>
            </children>
        </xsl:if>
    </xsl:template>

    <xsl:template name="ep:create_toc_module">
        <xsl:param name="contextCollModule"/>
        <xsl:param name="title_value"/>
        <xsl:param name="currModule"/>
        <xsl:param name="isPaginationOfModule" select="false()"></xsl:param>
        <xsl:param name="tocId"/>
        <xsl:param name="lastSectionWithTitleTocId"/>
        <xsl:param name="title_no_profix"/>
        
        <id>
            <xsl:value-of select="$tocId"></xsl:value-of>
        </id>
        
        <moduleId>
            <xsl:value-of select="$contextCollModule/@document"></xsl:value-of>
        </moduleId>
        
        <pageId>
            <xsl:choose>
                <xsl:when test="$currModule/@data-pagination-id">
                    <xsl:value-of select="$currModule/@data-pagination-id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$currModule/@id"/>
                </xsl:otherwise>
            </xsl:choose>
        </pageId>
        
        <numbering>
            <xsl:if test="not(($contextCollModule/@ep:numbering = 'skip') or ($isPaginationOfModule) or (some $x in ('second_page', 'about') satisfies contains($currModule/@id,$x)))">
                <xsl:value-of select="$title_no_profix"/>
            </xsl:if>
        </numbering>
        
        <title>
            <xsl:choose>
                <xsl:when
                    test="contains(md:title, 'Zadania') and (contains(md:title, 'cz') or contains(md:title, 'Zadania generatorowe')
                    or ./following-sibling::node()[contains(md:title, 'Zadania generatorowe')] or matches(md:title, ',\s+zadania generatorowe'))">
                    <xsl:value-of select="ep:getNewNodeTitle($contextCollModule)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$title_value"/>
                </xsl:otherwise>
            </xsl:choose>
        </title>

        <path>
            <xsl:choose>
                <xsl:when test="$currModule/@data-pagination-id">
                    <xsl:value-of select="ep:concatHref($currModule/@data-pagination-id)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ep:concatHref($currModule/@id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </path>

        <isTeacher>
            <xsl:choose>
                <xsl:when test="contains($currModule/@ep:role, 'recipient-teacher')">
                    <xsl:text>true</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>false</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </isTeacher>

        <contentStatus>
            <xsl:for-each select="tokenize($currModule/@ep:role, ' ')">
                <xsl:if test="every $x in ('recipient-student', 'content-status-canon') satisfies not(contains(.,$x))">
                    <xsl:value-of select="."/>
    
                    <xsl:if test="position() != last()">
                        <xsl:text>;</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </contentStatus>
        
        <xsl:if test="contains($title_value, 'about') and count(preceding-sibling::node()[contains(./md:title,'about')]) > 0">
            <not_in_toc>
                <xsl:text>yes</xsl:text>
            </not_in_toc>
        </xsl:if>
        
        <xsl:if test="not($title_value)">
            <lastSectionWithTitleTocId>
                <xsl:value-of select="$lastSectionWithTitleTocId"/>
            </lastSectionWithTitleTocId>
        </xsl:if>
    </xsl:template>

    <xsl:function name="ep:concatHref">
        <xsl:param name="moduleId"/>
        <xsl:text>m_</xsl:text>
        <xsl:value-of select="$moduleId"/>
        <xsl:text>.html</xsl:text>
    </xsl:function>
    
    <xsl:function name="ep:calcDepthSubColl" as="xs:integer">
        <xsl:param name="context"/>
        <xsl:value-of select="count($context/preceding-sibling::col:subcollection[(not(@ep:numbering) or @ep:numbering != 'skip') and (not(@toc) or @toc='include') 
            and not(contains(./col:content/col:module[1]/@document, 'answers'))
            and (count(./descendant::node()[local-name() = 'module' and (not(@ep:numbering) or @ep:numbering != 'skip') and (not(@toc) or @toc='include')]) > 0)]
            | $context/preceding-sibling::col:module[(not(@ep:numbering) or @ep:numbering != 'skip') and (not(@toc) or @toc='include')])"/>
    </xsl:function>
    
</xsl:stylesheet>