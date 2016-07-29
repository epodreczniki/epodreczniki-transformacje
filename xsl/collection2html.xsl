<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ep="http://epodreczniki.pl/" xmlns:col="http://cnx.rice.edu/collxml"
    xmlns:x="http://www.w3.org/1999/xhtml" xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:cnxml="http://cnx.rice.edu/cnxml"
    exclude-result-prefixes="ep x mml cnxml xs col"
    version="2.0">
    
    <xsl:import href="ident_html.xsl"/>
    <xsl:import href="common.xslt"/>
    <xsl:import href="resolve_css.xslt"/>
    <xsl:import href="resolve-womi-dynamic.xsl"/>
    
    <xsl:param name="epxhtml_path" select="'1'"/>
    <xsl:param name="resultDir" select="'1'"/>
    <xsl:param name="variant"/>
    
    <xsl:output method="html" version="5.0" use-character-maps="m1" indent="no"/>
	
	<xsl:character-map name="m1">
		<xsl:output-character character="&#150;" string="&#8211;"/>
		<xsl:output-character character="&#136;" string=" "/>
		<xsl:output-character character="&#129;" string=" "/>
		<xsl:output-character character="&#131;" string=""/>
	</xsl:character-map>
    
    <xsl:variable name="modules_epxhtml">
        <xsl:for-each select="ep:extract_module_ids_from_module_elements(//col:module)">
            <xsl:if test="every $x in ('answers', 'second_page', 'about') satisfies not(contains(.,$x))">
                <xsl:copy-of select="ep:getDocumentContent(concat($epxhtml_path, '/', ., '.xhtml'))"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
	
	<xsl:variable name="mathml_digest">
        <xsl:variable name="path" select="concat($epxhtml_path, '/mathml_digest.xml')"/>
        <xsl:if test="doc-available($path)">
            <xsl:copy-of select="document($path)"/>
        </xsl:if>
    </xsl:variable>
    
    <xsl:template match="comment()" mode="add-variant">
        <xsl:copy-of select="."></xsl:copy-of>
    </xsl:template>
    
    <xsl:function name="ep:getMappingGlossaryModuleIdByTypeHtml" as="text()*">
        <xsl:param name="genType"/>
        <xsl:variable name="filepath" select="concat($epxhtml_path, '/mappingGlossary.xml')"/>
		<xsl:if test="doc-available($filepath)">
			<xsl:value-of select="ep:getDocumentContent($filepath)/*:glossaryMapping/*:item[@type=$genType]/@module_id"/>
		</xsl:if>
    </xsl:function>
    
    <xsl:template match="/col:collection">
        <xsl:for-each select="$modules_epxhtml/div">
            <xsl:result-document method="html" version="5.0" href="file:///{$resultDir}/{$variant}/{@id}.html">
                <xsl:copy-of select="preceding::comment()[1]"></xsl:copy-of>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@id|node()|@*"/>
                </xsl:copy>
                <xsl:element name="div">
                    <xsl:attribute name="class" select="'glossary-elements'"></xsl:attribute>
                    <xsl:attribute name="style" select="'display:none;'"></xsl:attribute>
                    <xsl:variable name="biblio_module_id" select="ep:getMappingGlossaryModuleIdByTypeHtml('bibliography')"/>
                    <xsl:variable name="glossary-elements">
                        <xsl:apply-templates select="div//node()[@ep:local-reference = 'false']" mode="glossary"/>
                        <xsl:if test="doc-available(concat($epxhtml_path, '/', $biblio_module_id, '.xhtml'))">
                            <xsl:variable name="biblio-ref-local" select="div//node()[@ep:local-reference = 'true']/@href"/>
                            <xsl:variable name="biblio-entry-global"
                                select="document(concat($epxhtml_path, '/', $biblio_module_id, '.xhtml'))//node()[some $x in $biblio-ref-local satisfies (contains(@id, substring-after($x, '#')))]"/>
                            <xsl:apply-templates select="$biblio-entry-global">
                                <xsl:with-param name="copied_from_glossary" tunnel="yes">true</xsl:with-param>
                                <xsl:with-param name="change_to_local" tunnel="yes">true</xsl:with-param>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:for-each-group select="$glossary-elements/div" group-by="@id">
                        <xsl:copy-of select="."></xsl:copy-of>
                    </xsl:for-each-group>
                </xsl:element>
                <xsl:element name="div">
                    <xsl:attribute name="class" select="'tooltip-elements'"></xsl:attribute>
                    <xsl:attribute name="style" select="'display:none;'"></xsl:attribute>
                    <xsl:variable name="tooltip-elements">
                        <xsl:if test="./contains(@ep:role, 'EP_technical_module_')">
                            <xsl:for-each select=".//a[@ep:link-type='tooltip']">
                                <xsl:variable name="tooltipId" select="substring-after(@href,'#tooltip_')"/>
                                <xsl:apply-templates select="preceding::div[@id=$tooltipId]">
                                    <xsl:with-param name="for-glossary" select="true()"/>
                                    <xsl:with-param name="tooltip_id_tech_module" select="substring-after(@href, '#')" tunnel="yes"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </xsl:if>
                        
                        <xsl:apply-templates select="div//node()[contains(@ep:role,'tooltip') 
                            and not(contains(@ep:role,'tooltip-link'))
                            and not(contains(@ep:role,'tooltip-header'))
                            and not(contains(@ep:role,'tooltip-contents'))]">
                            <xsl:with-param name="for-glossary" select="true()"/>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <xsl:for-each-group select="$tooltip-elements/div" group-by="@id">
                        <xsl:copy-of select="."></xsl:copy-of>
                    </xsl:for-each-group>
                </xsl:element>
                <xsl:if test="div[@ep:role='module-header-caption'] or div[@ep:role='module-presentation-title']">
                    <xsl:variable name="womi_id"
                        select="div[@ep:role='module-header-caption']/node()[@baner-womi]/@baner-womi"/>
                    
                    <xsl:element name="div">
                        <xsl:attribute name="class" select="'module-header-metadata'"/>
                        <xsl:if test="div[@ep:role='module-header-caption']">
                            <xsl:element name="div">
                                <xsl:attribute name="class" select="'module-header-caption'"/>
                                <xsl:attribute name="style" select="'display:none;'"/>
                                <div class="title">
                                    <xsl:value-of
                                        select="ep:getDocumentContent(concat('file:///', $womiLocalPath, '/', number($womi_id), '-metadata2.xml'))/metadata/Tytul"
                                    />
                                </div>
                                <div class="caption">
                                    <xsl:apply-templates
                                        select="div[@ep:role='module-header-caption']/node()[not(local-name()='div' and @baner-womi) and contains(@ep:role, 'classic')]"
                                    />
                                </div>
                            </xsl:element>
                            <xsl:element name="div">
                                <xsl:attribute name="class" select="'module-header-baner'"/>
                                <xsl:attribute name="data-womi-id" select="$womi_id"/>
                                <xsl:attribute name="data-module-header-interactive">
                                    <xsl:value-of select="ep:getMetadataWomiType($womi_id) = 'INTERACTIVE'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="div[@ep:role='module-presentation-title']">
                            <xsl:element name="div">
                                <xsl:attribute name="class" select="'module-presentation-title'"/>
                                <xsl:attribute name="style" select="'display:none;'"/>
                                <xsl:apply-templates
                                    select="div[@ep:role='module-presentation-title']/node()"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:element>
                </xsl:if>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="li[contains(@ep:role, 'bib-entry')]|div[contains(@ep:role, 'bib-entry')]">
        <xsl:element name="div">
            <xsl:apply-templates select="@*"/>
            <xsl:if test="ancestor::div[@ep:role='module-header-caption']">
                <xsl:text>Źródło: </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="div[contains(@ep:role,'tooltip') and @id]">
        <xsl:param name="for-glossary"/>
        <xsl:if test="$for-glossary">
            <xsl:copy copy-namespaces="no">
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="div[contains(@ep:role,'tooltip') and @id]/@id">
        <xsl:param name="tooltip_id_tech_module" tunnel="yes"/>
        <xsl:attribute name="{local-name()}">
            <xsl:choose>
                <xsl:when test="$tooltip_id_tech_module != ''">
                    <xsl:value-of select="$tooltip_id_tech_module"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="a[@ep:local-reference='false']" mode="glossary">
        <xsl:param name="prev_ids"></xsl:param>       
        <xsl:variable name="this" select="."></xsl:variable>
        <xsl:analyze-string select="@href" regex="^\.\./(.+)#(.+)$">
            <xsl:matching-substring>
                <xsl:variable name="all_prev_ids" as="xs:string*">
                    <xsl:copy-of select="$prev_ids"/>
                    <xsl:copy-of select="regex-group(2)"/>
                </xsl:variable>

                <xsl:variable name="glossaryPath" select="concat($epxhtml_path, '/', regex-group(1), '.xhtml')"/>
                <xsl:apply-templates select="ep:getDocumentContent($glossaryPath)
                            //node()[@id = regex-group(2) or @ep:id = regex-group(2)]">
                    <xsl:with-param name="copied_from_glossary" tunnel="yes">true</xsl:with-param>
                </xsl:apply-templates>

                <xsl:apply-templates
                    select="ep:getDocumentContent($glossaryPath)
                            //node()[@id = regex-group(2) or @ep:id = regex-group(2)]//node()[@ep:local-reference and not(substring-after(@href, '#') = $all_prev_ids)]"
                    mode="glossary">
                    <xsl:with-param name="prev_ids" select="$all_prev_ids"/>
                </xsl:apply-templates>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="a[@ep:local-reference='true']" mode="glossary">
        <xsl:param name="prev_ids"></xsl:param>
        <xsl:variable name="id" select="substring-after(@href, '#')"></xsl:variable>
        <xsl:variable name="all_prev_ids" as="xs:string*">
            <xsl:copy-of select="$prev_ids"></xsl:copy-of>
            <xsl:copy-of select="$id"></xsl:copy-of>
        </xsl:variable>
        <xsl:apply-templates select="root(.)//node()[@id = $id or @ep:id = $id]"/>
        <xsl:apply-templates select="root(.)//node()[@id = $id or @ep:id = $id]//node()[@ep:local-reference and not(substring-after(@href, '#') = $all_prev_ids)]" mode="glossary">
            <xsl:with-param name="prev_ids" select="$all_prev_ids"></xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='concept-contents' or @ep:role='definition-contents' or @ep:role='rule-contents' or
                            @ep:role='biography-contents' or @ep:role='event-contents']">
        <xsl:param name="copied_from_glossary" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$copied_from_glossary = 'true'">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()[not(@ep:role='go-to-glossary')]"/>
                    <xsl:element name="div">
                        <xsl:attribute name="class">go-to-glossary</xsl:attribute>
                        <xsl:element name="a">
                            <xsl:attribute name="href" select="concat('../', root()/div[1]/@id, '#', parent::div/@id)"/>
                            <xsl:value-of select="ep:getGoToGlossaryLabel(parent::node()/@ep:glossary-merge-type)"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="li">
        <xsl:param name="copied_from_glossary" tunnel="yes"/>
        <xsl:param name="change_to_local" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$copied_from_glossary = 'true'">
                <xsl:element name="div">
                    <xsl:attribute name="id">
                        <xsl:choose>
                            <xsl:when test="$change_to_local='true'">
                                <xsl:value-of select="substring-after(@id,'bibliography_')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@id"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates select="@*[local-name()!='id']|node()[not(@ep:role='go-to-glossary')]"/>
                    <xsl:element name="div">
                        <xsl:attribute name="class">go-to-glossary</xsl:attribute>
                        <xsl:element name="a">
                            <xsl:attribute name="href" select="concat('../', root()/div[1]/@id, '#', @id)"/>
                            <xsl:value-of select="ep:getGoToGlossaryLabel('bibliography')"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="a[@ep:link-type]">
        <xsl:copy copy-namespaces="no">
            <xsl:attribute name="data-tooltip-id" select="concat('#', substring-after(@href, '#'))"/>
            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="a[@ep:local-reference='false']/@href">
        <xsl:attribute name="href" select="concat('#', substring-after(., '#'))"/>
    </xsl:template>
    
    <xsl:template match="ep:mathElement">
        <span aria-hidden="true">
            <xsl:apply-templates/>
        </span>
        <span class="mathml-alttext">
            <xsl:value-of select="@alttext"/>
        </span>
    </xsl:template>
    
    <xsl:template match="mml:*">
        <xsl:element name="{local-name(.)}">
            <xsl:if test="local-name() = 'math' and $mathml_digest/root">
                <xsl:variable name="curr_mathml_digest" select="parent::node()/@id"/>
                <xsl:variable name="alttext" select="$mathml_digest//mathElement[@id=$curr_mathml_digest][1]/@alt"/>
                <xsl:if test="$alttext">
                    <xsl:attribute name="alttext">
                        <xsl:value-of select="$alttext"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@ep:role">
        <xsl:attribute name="class">
            <xsl:value-of select="ep:map_role2css(.)" />
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@data-role">
        <xsl:attribute name="data-role">
            <xsl:choose>
                <xsl:when test="ep:map_role2css(concat(., '_display')) != ''">
                    <xsl:value-of select="ep:map_role2css(concat(., '_display'))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="form/div/span[@ep:role = 'answer-prefix']">
    </xsl:template>

    <xsl:template match="@ep:interactivity|@ep:type">
    </xsl:template>
    
	<xsl:template match="mml:math/@alttext">
    </xsl:template>
	
    <xsl:template match="ep:alternatives">
        <xsl:apply-templates select="ep:alternative[ep:formats/ep:format = 'classic' or ep:formats/ep:format = 'classicmobile']/node()[self::div|self::ep:reference]"></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='problem']">
        <xsl:choose>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'static']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'random']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'interactive']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='solution']">
        <xsl:choose>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'static']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'random']">
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'interactive']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='commentary']">
        <xsl:variable name="type" select="@type"></xsl:variable>
        <xsl:choose>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'static']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'random' and (not($type) or $type != 'example')]">
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'interactive']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='solution-toggles']">
        <xsl:choose>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'static']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'random']">
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'interactive']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='commentary-toggles']">
        <xsl:variable name="type" select="preceding-sibling::div[@ep:role='commentary'][1]/@type"></xsl:variable>
        <xsl:choose>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'static']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'random' and (not($type) or $type != 'example')]">
            </xsl:when>
            <xsl:when test="ancestor::div[@ep:role='exercise' and @ep:interactivity = 'interactive']">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@type[parent::div[contains(@ep:role, 'commentary')]]|@ep:local-reference">
    </xsl:template>
    
    <xsl:template match="span[@ep:role='label' and parent::div[@ep:role='tooltip-header']]">
    </xsl:template>
    
    <xsl:template match="span[@ep:role='recipient-teacher' or @ep:role='content-status-expanding']">
    </xsl:template>
    
    <xsl:template match="div[@ep:role='gallery-contents']/div[@ep:role='content static' or @ep:role='content static-mono']">
    </xsl:template>
    
    <xsl:template match="@ep:*[parent::div[contains(@ep:role, 'gallery')] and local-name(.) != 'role']|@ep:name|@ep:link-type|@ep:tooltip-type|@ep:target-name">
        <xsl:attribute name="data-{local-name(.)}" select="."></xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@ep:glossary|@ep:glossary-merge-type"/>
    
    <xsl:template match="custom_bib">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='module-header-caption']"/>
    <xsl:template match="div[@ep:role='module-presentation-title']"/>
   
</xsl:stylesheet>
