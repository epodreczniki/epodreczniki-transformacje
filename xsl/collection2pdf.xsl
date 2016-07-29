<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cnxml="http://cnx.rice.edu/cnxml" xmlns:md="http://cnx.rice.edu/mdml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:q="http://cnx.rice.edu/qml/1.0"
    xmlns:ep="http://epodreczniki.pl/" xmlns:col="http://cnx.rice.edu/collxml"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs ep col mml q md cnxml"
    version="2.0">
    
    <xsl:import href="ident_pdf.xsl"/>
    <xsl:import href="common.xslt"/>
    <xsl:import href="resolve_css.xslt"/>
    <xsl:import href="pdf_toc.xsl"/>
    <xsl:import href="module2static.xsl"/>
    <xsl:import href="resolve-womi-static.xsl"/>
    
    <xsl:param name="epxhtml_path" select="'1'"/>
    <xsl:param name="resultDir" select="'1'"/>
    <xsl:param name="color_stylesheet" select="'pdf.css'"/>
    <xsl:param name="womiLocalPath" select="'1'"/>
    <xsl:param name="outputFormat" select="'pdf'"/>
    
    <xsl:output method="xhtml"></xsl:output>
    
    <xsl:variable name="modules_before_toc_epxhtml">
        <xsl:for-each select="(/col:collection/col:content/col:subcollection)[1]">
            <xsl:if test="md:title">
                <h1 ep:role="subcollection-title">
                    <xsl:value-of select="md:title"/>
                </h1>
            </xsl:if>
            <xsl:for-each select="ep:extract_module_ids_from_module_elements(.//col:module)">
                <xsl:copy-of select="document(concat($epxhtml_path, '/', ., '.xhtml'))"/>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:function name="ep:calcDepthSubColl" as="xs:integer">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="count($context/preceding-sibling::col:subcollection[
            (not(@ep:numbering) or @ep:numbering != 'skip') 
            and (not(@toc) or @toc='include') 
            and (contains((./descendant::node()[local-name() = 'module'])[1]/@document, 'answers')
                 or (count(./descendant::node()[local-name() = 'module' and (((not(@ep:numbering) or @ep:numbering != 'skip') and (not(@toc) or @toc='include')))]) > 0))]
            | $context/preceding-sibling::col:module[(not(@ep:numbering) or @ep:numbering != 'skip') and (not(@toc) or @toc='include')])"/>
    </xsl:function>
    
    <xsl:variable name="modules_epxhtml">
        <xsl:for-each select="col:collection/col:content/col:subcollection">
            <xsl:if test="position() > 1"> 
                <xsl:variable name="pos" select="ep:calcDepthSubColl(.)+1"></xsl:variable>
                
                <div class="main-subcollection" id="{@id}" xmlns="http://www.w3.org/1999/xhtml">
		        	<xsl:call-template name="processModules">
		                <xsl:with-param name="ctx" select="."></xsl:with-param>
		                <xsl:with-param name="position" select="$pos"></xsl:with-param>
		            </xsl:call-template>
				</div>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template name="processModules">
        <xsl:param name="ctx"></xsl:param>
        <xsl:param name="position"></xsl:param>
        
        <xsl:for-each select="$ctx/col:content/child::node()">            
            <xsl:choose>
                <xsl:when test="local-name() = 'module'">
                    <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:choose>
                            <xsl:when test="contains(./@document, 'about') or contains(./@document, 'answers_licenses')">
                                <xsl:attribute name="class" select="ep:map_role2css('chapter_about')"/>
                            </xsl:when>
                            <xsl:when test="contains(./@document, 'answers')">
                                <xsl:attribute name="class" select="ep:map_role2css('chapter_answers')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class" select="ep:map_role2css('chapter')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:copy-of select="document(concat($epxhtml_path, '/', ./@document, '.xhtml'))"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="local-name() = 'subcollection' and contains(ancestor::col:subcollection[last()]/@id, 'answers')">
                    <xsl:variable name="num" select="concat($position, '.', count(preceding-sibling::node()[(local-name() = 'subcollection' or local-name() = 'module') and (not(@toc) or @toc='include')])+1)"></xsl:variable>
                    <xsl:element name="div">
                        <xsl:attribute name="class">main-subcollection-answer</xsl:attribute>
                        <xsl:attribute name="id" select="concat(@id, '-answer')"/>
                        <xsl:call-template name="processModules">
                            <xsl:with-param name="ctx" select="."/>
                            <xsl:with-param name="position" select="$num"></xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="local-name() = 'subcollection'">
                    <xsl:variable name="num" select="concat($position, '.', count(preceding-sibling::node()[(local-name() = 'subcollection' or local-name() = 'module') and (not(@toc) or @toc='include')])+1)"></xsl:variable>
                    <xsl:call-template name="processModules">
                        <xsl:with-param name="ctx" select="."/>
                        <xsl:with-param name="position" select="$num"></xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="/">      
        <xsl:message>
            <xsl:text>[xslt] Starting PDF transform</xsl:text>
        </xsl:message>
        
        <xsl:message>
            <xsl:text>[xslt] Transforming modules to PDF</xsl:text>
        </xsl:message>
        <xsl:result-document method="xhtml" omit-xml-declaration="yes" encoding="UTF-8" indent="no" href="file:///{$resultDir}/collection.html">
            <xsl:call-template name="create_body"></xsl:call-template>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="comment()">
        <xsl:if test="contains((following::node()[1]/div)[1]/@id, 'second_page')">
            <xsl:copy-of select="." copy-namespaces="no"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="create_body">
        <xsl:copy-of select="$modules_before_toc_epxhtml/comment()"></xsl:copy-of>
        
        <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:call-template name="book-cover"/>
            <xsl:apply-templates select="$modules_before_toc_epxhtml/div">
                <xsl:with-param name="counter_subcoll_ancestor" tunnel="yes">0</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates mode="pdf_generate_toc"/>
            <xsl:element name="div">
                <xsl:attribute name="class" select="ep:map_role2css('reader-content')"/>
                <xsl:variable name="col_id" select="/col:collection/col:metadata/md:content-id/text()"></xsl:variable>
                <xsl:variable name="col_md_version" select="/col:collection/col:metadata/md:version/text()"></xsl:variable>
                <xsl:variable name="col_variant" select="ep:getVariant(.)"></xsl:variable>
                <xsl:for-each select="$modules_epxhtml/node()">
                    <div class="{@class}" id="{@id}" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:for-each select="node()">
                            <xsl:variable name="module_id" select="(descendant::*[@id])[1]/@id"/>
                            <xsl:variable name="col_module" select="$coll//col:subcollection//col:module[@document=$module_id]"></xsl:variable>
                            
                            <xsl:variable name="counter_subcoll_ancestor">
                                <xsl:value-of select="count($col_module/ancestor::node()[local-name() = 'subcollection'])"></xsl:value-of>
                            </xsl:variable>

                            <xsl:apply-templates select=".">
                                <xsl:with-param name="col_id" tunnel="yes" select="$col_id"/>
                                <xsl:with-param name="col_md_version" tunnel="yes"
                                    select="$col_md_version"/>
                                <xsl:with-param name="col_variant" tunnel="yes"
                                    select="$col_variant"/>
                                <xsl:with-param name="counter_subcoll_ancestor" tunnel="yes">
                                    <xsl:choose>
                                        <xsl:when test="contains($module_id, 'answer')">
                                            <xsl:value-of select="0"></xsl:value-of>
                                        </xsl:when>
                                        <xsl:when test="not($col_module/ancestor::node()[local-name() = 'subcollection'][1]/md:title) 
                                            and count($col_module/preceding-sibling::node()[local-name()='module']) = 0">
                                            <xsl:value-of select="number($counter_subcoll_ancestor)-1"></xsl:value-of>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="number($counter_subcoll_ancestor)"></xsl:value-of>
                                        </xsl:otherwise>
                                    </xsl:choose> 
                                </xsl:with-param>
                            </xsl:apply-templates>
                        </xsl:for-each>
                    </div>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="book-cover">
        <xsl:variable name="cover_id" select="//ep:cover/text()"/>
        <xsl:variable name="cover_filename">
            <xsl:if test="$cover_id">
                <xsl:value-of select="$cover_id"/>
                <xsl:text>-pdf-cover.</xsl:text>
                <xsl:value-of select="ep:getCoverExtension($cover_id, $outputFormat)"/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:if test="$cover_filename != ''">
            <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="id" select="ep:map_role2css('cover-page')"/>
                <xsl:element name="img" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="src" select="concat('womi/',$cover_filename)"/>
                </xsl:element>
                <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class">
                        <xsl:text>cover-title cover-class</xsl:text>
                        <xsl:if test="$coll//col:metadata/ep:e-textbook/ep:class">
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="$coll//col:metadata/ep:e-textbook/ep:class"/>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class" select="'cover-subject'"/>
                        <xsl:value-of select="upper-case(replace($subject,';',','))"/>
                    </xsl:element>
                    <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class" select="'cover-topic'"/>
                        <xsl:value-of select="$coll//col:metadata/md:title"/>
                    </xsl:element>
                    <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class" select="'cover-class-level'"/>
                        <xsl:attribute name="data-class" select="$coll//col:metadata/ep:e-textbook/ep:class"/>
                        <xsl:if test="$coll//col:metadata/ep:e-textbook/ep:class 
                            and count($coll//col:metadata/md:education-levellist/md:education-level)>0"></xsl:if>
                        <xsl:value-of select="concat($locales/locale[@key='class']/text(),' ',$coll//col:metadata/ep:e-textbook/ep:class)"/>
                        <xsl:text>, </xsl:text>
                        <xsl:for-each select="$coll//col:metadata/md:education-levellist/md:education-level">
                            <xsl:if test="position() > 1">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:call-template name="ep:show_school_type">
                                <xsl:with-param name="school_type" select="."/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:element>
                    <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class" select="'cover-logo'"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mml:*">
        <xsl:copy copy-namespaces="no">
            <xsl:attribute name="class">
                <xsl:text>mathmlik</xsl:text>
                <xsl:if test="descendant::node()[(local-name()='mfenced' and @open) or local-name() = 'mfrac']">
                    <xsl:text> more-space</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:copy-of select="child::node()" copy-namespaces="no"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[@ep:role = 'para']">
        <xsl:element name="p">
            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="div[@ep:role = 'effect-of-education']">
        <xsl:element name="div">
            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="li[ancestor::node()[local-name()= 'div' and @ep:role='gallery-contents']]">
        <xsl:element name="li">
            <xsl:apply-templates>
                <xsl:with-param name="isGalleryElement" select="1" tunnel="yes" as="xs:integer"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="ep:checkIfOneOfThreeWomiHasHeightRatioLow025">
        <xsl:param name="listWomi"/>
        <xsl:variable name="countLow025">
            <xsl:for-each select="$listWomi">
                <xsl:if test="position() &lt; 4 and @ratio &lt; 0.25">
                    <xsl:text>1</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$countLow025"></xsl:value-of>
    </xsl:function>
    
    <xsl:template match="div[contains(@ep:role,'gallery-contents')]">
        <xsl:variable name="list_womi_height_ratio" as="element()*">
            <xsl:for-each select=".//ep:reference">
                <item id="{@ep:id}" pos="{position()}" ratio="{number(ep:getManifestById(number(@ep:id))/parameters/pdf/heightRatio)}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="countRef" select="count(.//ep:reference)"/>
        <xsl:variable name="countRatioLow025" select="string-length(ep:checkIfOneOfThreeWomiHasHeightRatioLow025($list_womi_height_ratio))"></xsl:variable>    
        
        <xsl:choose>
            <xsl:when test="$countRef > 2
                and $countRatioLow025 &gt;0 and $countRatioLow025 &lt; 2">
                <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="ep:map_role2css('gallery-contents')"/>
                    <xsl:element name="ol" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:apply-templates select=".//li[1]"/>
                        <xsl:apply-templates select=".//li[2]"/>
                        <xsl:apply-templates select=".//li[3]"/>
                    </xsl:element>
                    <xsl:if test="$countRef &lt;= 3">
                        <xsl:call-template name="create_gallery_legend"/>
                    </xsl:if>
                </xsl:element>
                <xsl:if test="$countRef > 3">
                    <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class" select="ep:map_role2css('gallery-contents-others')"/>
                        <xsl:element name="ol" xmlns="http://www.w3.org/1999/xhtml">
                            <xsl:for-each select=".//li">
                                <xsl:if test="position() > 3">
                                    <xsl:apply-templates select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>
                        <xsl:call-template name="create_gallery_legend"/>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$countRef > 1
                and ($list_womi_height_ratio[1]/@ratio &lt; 0.25
                or $list_womi_height_ratio[2]/@ratio &lt; 0.25)">
                <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="ep:map_role2css('gallery-contents')"/>
                    <xsl:element name="ol" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:apply-templates select=".//li[1]"/>
                        <xsl:apply-templates select=".//li[2]"/>
                    </xsl:element>
                    <xsl:if test="$countRef &lt;= 2">
                        <xsl:call-template name="create_gallery_legend"/>
                    </xsl:if>
                </xsl:element>
                <xsl:if test="$countRef > 2">
                    <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class" select="ep:map_role2css('gallery-contents-others')"/>
                        <xsl:element name="ol" xmlns="http://www.w3.org/1999/xhtml">
                            <xsl:for-each select=".//li">
                                <xsl:if test="position() > 2">
                                    <xsl:apply-templates select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>
                        <xsl:call-template name="create_gallery_legend"/>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="ep:map_role2css('gallery-contents')"/>
                    <xsl:element name="ol" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:apply-templates select=".//li[1]"/>
                        <xsl:apply-templates select=".//li[2]"/>
                        <xsl:apply-templates select=".//li[3]"/>
                        <xsl:apply-templates select=".//li[4]"/>
                    </xsl:element>
                    <xsl:if test="$countRef &lt;= 4">
                        <xsl:call-template name="create_gallery_legend"/>
                    </xsl:if>
                </xsl:element>
                <xsl:if test="$countRef > 4">
                    <xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class" select="ep:map_role2css('gallery-contents-others')"/>
                        <xsl:element name="ol" xmlns="http://www.w3.org/1999/xhtml">
                            <xsl:for-each select=".//li">
                                <xsl:if test="position() > 4">
                                    <xsl:apply-templates select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>
                        <xsl:call-template name="create_gallery_legend"/>
                    </xsl:element>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="create_gallery_legend">
        <xsl:if test="ep:checkIfGalleryElementsHaveDesciption(.)">
            <xsl:element name="div">
                <xsl:attribute name="class">
                    <xsl:value-of select="'qr-code-gallery'"/>
                </xsl:attribute> 
                <xsl:call-template name="create_qr_image">
                    <xsl:with-param name="href">
                        <xsl:call-template name="getHref"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>            
            
            <xsl:element name="div">
                <xsl:attribute name="class" select="'gallery-legend'"></xsl:attribute>
                <div class="gallery-legend-title">
                    <xsl:value-of select="$locales/locale[@key='gallery-legend-title']/text()"/>
                </div>
                <xsl:for-each select=".//ep:reference">
                    <xsl:variable name="womiId" select="ep:getWomiId(.)"></xsl:variable>
                    <xsl:variable name="alternativeContent">
                        <xsl:call-template name="getAlternativeContent">
                            <xsl:with-param name="womiId" select="$womiId"></xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="womiType" select="ep:getMetadataWomiType($womiId)"/>
                    
                    <xsl:if test="(((not(ep:hide-caption) or (ep:hide-caption != 'true'  
                        and ep:hide-caption != 'all' and ep:hide-caption != 'title') ) 
                        and not(doc-available($alternativeContent)))
                        or (ep:content and not(empty(ep:content[@ep:format='static']/text()))))">
                        <div class="gallery-legend-element-position">
                            <xsl:value-of select="position()"/>
                            <xsl:text>. </xsl:text>
                        </div>
                        <xsl:call-template name="createWomiCapitonAndAltermativeText">
                            <xsl:with-param name="womiId" select="$womiId"/>
                            <xsl:with-param name="womiType" select="ep:getMetadataWomiType($womiId)"></xsl:with-param>
                            <xsl:with-param name="isGalleryElement" select="1" tunnel="yes" as="xs:integer"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="ep:checkIfGalleryElementsHaveDesciption" as="xs:boolean">
        <xsl:param name="ctx"></xsl:param>
        <xsl:variable name="result">
            <xsl:for-each select="$ctx//ep:reference">
                <xsl:variable name="alternativeContent">
                    <xsl:call-template name="getAlternativeContent">
                        <xsl:with-param name="womiId" select="ep:getWomiId(.)"></xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="((not(ep:hide-caption) or (ep:hide-caption != 'true'  
                    and ep:hide-caption != 'all' and ep:hide-caption != 'title') or ep:content/@ep:format='static') 
                    ) 
                    ">
                    <xsl:text>1</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:value-of select="$result != ''"></xsl:value-of>
    </xsl:function>
    
    <xsl:template match="div[@ep:role='module-header-caption']"/>
    
    <xsl:template match="div[@ep:role='module-presentation-title']"/>
    
</xsl:stylesheet>

