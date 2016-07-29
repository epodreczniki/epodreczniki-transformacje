<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cnxml="http://cnx.rice.edu/cnxml" xmlns:md="http://cnx.rice.edu/mdml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:q="http://cnx.rice.edu/qml/1.0" xmlns:ep="http://epodreczniki.pl/" xmlns:col="http://cnx.rice.edu/collxml" xmlns:mml="http://www.w3.org/1998/Math/MathML"
	xmlns:svg="http://www.w3.org/2000/svg"  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/" exclude-result-prefixes="xs ep mml svg cnxml md q col pmml2svg" version="2.0">

	<xsl:import href="ident_mobile_app.xsl"/>
	<xsl:import href="resolve-womi-mobile-app.xsl"/>
	<xsl:import href="table_of_content_toc_XML_mobile_app.xsl"/>
	<xsl:import href="common.xslt"/>
	<xsl:import href="resolve_css.xslt"/>
	<xsl:import href="module2format_shared.xsl"/>
	
	<xsl:param name="outputFormat" select="'mobile_app'"/>

	<xsl:param name="epxhtml_path" select="'1'"/>
	<xsl:param name="resultDir" select="'1'"/>
	<xsl:param name="files_to_stylesheet" select="'css/mobile_app.css'"/>
	<xsl:param name="womiLocalPath" select="'1'"/>
	<xsl:param name="womiLocalPath_modifyWomi" select="'1'"/>
	<xsl:param name="collWithGeogebraExercises"></xsl:param>
		
	<xsl:output method="html" version="5.0" use-character-maps="m1"/>
	
    <xsl:strip-space  elements="span"/>

	
	<xsl:character-map name="m1">
		<xsl:output-character character="&#150;" string="&#8211;"/>
		<xsl:output-character character="&#136;" string=" "/>
	</xsl:character-map>
	
	<xsl:variable name="modules_epxhtml">
		<xsl:for-each select="//col:module">
			<xsl:variable name="chapterId" select="@document"/>

			<xsl:if test="not(contains($chapterId, 'answers'))">
				<xsl:choose>
					<xsl:when test="contains(./md:title, 'Zadania') and (contains(md:title, 'cz') or contains(md:title, 'Zadania generatorowe')
						or following-sibling::node()[contains(./md:title, 'Zadania generatorowe')] or matches(./md:title, ',\s+zadania generatorowe'))">
						<xsl:call-template name="divide_module_with_padding_to_single_submodules_generated_tasks">
							<xsl:with-param name="chapterId" select="$chapterId"></xsl:with-param>
							<xsl:with-param name="currModuleContent" select="."></xsl:with-param>
						</xsl:call-template>
						
					</xsl:when>
					<xsl:otherwise>
					<xsl:call-template name="divide_module_with_padding_to_single_submodules">
							<xsl:with-param name="chapterId">
								<xsl:choose>
									<xsl:when test="matches($chapterId, '_about_[0-9]+')">
										<xsl:value-of select="concat($chapterId, '_mobile_app')"></xsl:value-of>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$chapterId"></xsl:value-of>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
		
	<xsl:template name="divide_module_with_padding_to_single_submodules">
		<xsl:param name="chapterId"/>
		<xsl:variable name="module_data" select="ep:getDocumentContent(concat($epxhtml_path, '/', $chapterId, '.xhtml'))/div"/>
		
		<xsl:choose>
			<xsl:when test="$module_data/div[every $x in ('section', 'level_1') satisfies contains(@ep:role,$x)
				and @data-start-new-page='true']">
				<xsl:variable name="firstElementWithoutPagination">
					<xsl:copy-of
						select="$module_data/div[every $x in ('section', 'level_1') satisfies contains(@ep:role,$x) 
					and @data-start-new-page='true'][1]/preceding-sibling::node()[not(every $x in ('section', 'level_1') satisfies contains(@ep:role,$x) 
					and @data-start-new-page='true')]"
					/>
				</xsl:variable>
				
				<xsl:for-each
					select="$module_data/div[every $x in ('section', 'level_1') satisfies contains(@ep:role,$x) 
					and @data-start-new-page='true']">
					<xsl:element name="div">
						<xsl:copy-of select="$module_data/@*[name()!='ep:role']"/>
						<xsl:variable name="localRoles" select="./@ep:role"/>
						
						<xsl:attribute name="ep:role">
							<xsl:for-each select="tokenize($module_data/@ep:role, ' ')">
								<xsl:choose>
									<xsl:when test="contains(.,'recipient')">
										<xsl:if test="not(contains($localRoles, 'recipient'))">
											<xsl:value-of select="."/>
											<xsl:text> </xsl:text>
										</xsl:if>
									</xsl:when>
									<xsl:when test="contains(.,'content-status')">
										<xsl:if test="not(contains($localRoles, 'content-status'))">
											<xsl:value-of select="."/>
											<xsl:text> </xsl:text>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="."/>
										<xsl:text> </xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
							<xsl:for-each select="tokenize($localRoles, ' ')">
								<xsl:if test="every $x in ('section','level_1') satisfies not(contains(., $x))">
									<xsl:value-of select="."/>
									<xsl:text> </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:attribute>
						<xsl:attribute name="data-pagination-id" select="./@id"></xsl:attribute>
						<xsl:if test="position() = 1">
							<xsl:copy-of select="$firstElementWithoutPagination"/>
							<xsl:if test="./following-sibling::div[@ep:role='module-header-caption']">
								<xsl:copy-of select="./following-sibling::div[@ep:role='module-header-caption']"/>
							</xsl:if>
						</xsl:if>
						<xsl:copy-of select="."/>
						
						<xsl:choose>
							<xsl:when test="position() != last()">
								<xsl:variable name="currElemId" select="./@id"></xsl:variable>
								
								<xsl:copy-of select="./following-sibling::node()[not(@data-start-new-page)][preceding-sibling::node()[@data-start-new-page='true'][1]/@id = $currElemId]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="./following-sibling::node()[not(local-name() = 'div' and @ep:role='module-header-caption')]"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="ep:getDocumentContent(concat($epxhtml_path, '/', $chapterId, '.xhtml'))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="divide_module_with_padding_to_single_submodules_generated_tasks">
		<xsl:param name="chapterId"/>
		<xsl:param name="currModuleContent"/>
		
		<xsl:variable name="module_data" select="ep:getDocumentContent(concat($epxhtml_path, '/', $chapterId, '.xhtml'))/div"/>
		
		<xsl:choose>
			<xsl:when test="$module_data/div[every $x in ('section', 'level_1') satisfies contains(@ep:role,$x)
				and @data-start-new-page='true']">
				<xsl:variable name="firstElementWithoutPagination">
					<xsl:for-each select="$module_data/div[every $x in ('section', 'level_1') satisfies contains(@ep:role,$x) 
						and @data-start-new-page='true'][1]/preceding-sibling::node()[not(every $x in ('section', 'level_1') satisfies contains(@ep:role,$x) 
						and @data-start-new-page='true')]">
						<xsl:choose>
							<xsl:when test="local-name() = 'h1'">
								<xsl:element name="h1">
									<xsl:apply-templates select="$module_data/h1/@*"/>
									<xsl:apply-templates select="$module_data/h1/span[not(@ep:role = 'title')]"/>
									<xsl:element name="span">
										<xsl:apply-templates select="$module_data/h1/span[@ep:role = 'title']/@*"/>
										<xsl:value-of select="ep:getNewNodeTitle($currModuleContent)"></xsl:value-of>
									</xsl:element>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="$module_data/div"></xsl:copy-of>
							</xsl:otherwise>
						</xsl:choose>	
					</xsl:for-each>
				</xsl:variable>
				
				<xsl:for-each
					select="$module_data/div[every $x in ('section', 'level_1') satisfies contains(@ep:role,$x) 
					and @data-start-new-page='true']">
					
					<xsl:element name="div">
						<xsl:copy-of select="$module_data/@*"/>
						<xsl:attribute name="data-pagination-id" select="./@id"></xsl:attribute>
						<xsl:element name="div">
							<xsl:copy-of select="./@*"/>
							<xsl:if test="position() = 1">
								<xsl:copy-of select="$firstElementWithoutPagination"/>
								<xsl:if test="./following-sibling::div[@ep:role='module-header-caption']">
									<xsl:copy-of select="./following-sibling::div[@ep:role='module-header-caption']"/>
								</xsl:if>
							</xsl:if>
							<xsl:copy-of select="."/>
						</xsl:element>
						
						<xsl:choose>
							<xsl:when test="position() != last()">
								<xsl:variable name="currElemId" select="./@id"></xsl:variable>
								
								<xsl:copy-of select="./following-sibling::node()[not(@data-start-new-page)][preceding-sibling::node()[@data-start-new-page='true'][1]/@id = $currElemId]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="./following-sibling::node()[not(local-name() = 'div' and @ep:role='module-header-caption')]"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="div">
					<xsl:apply-templates select="$module_data/@*"/>
					<xsl:element name="h1">
						<xsl:apply-templates select="$module_data/h1/@*"/>
						<xsl:apply-templates select="$module_data/h1/span[not(@ep:role = 'title')]"/>
						<xsl:element name="span">
							<xsl:apply-templates select="$module_data/h1/span[@ep:role = 'title']/@*"/>
							<xsl:value-of select="ep:getNewNodeTitle(.)"></xsl:value-of>
						</xsl:element>
					</xsl:element>
					<xsl:copy-of select="$module_data/div"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="ep:head_meta_data">
		<xsl:call-template name="ep:head_properties"/>
		<xsl:call-template name="ep:head_css_font_script"/>
		<xsl:call-template name="ep:head_js_script"/>
	</xsl:template>
	
	<xsl:template name="ep:head_properties">
		<xsl:element name="meta" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="http-equiv" select="'Content-Type'"/>
			<xsl:attribute name="content" select="'text/html; charset=utf-8'"/>
		</xsl:element>
		<xsl:element name="meta" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="name" select="'viewport'"/>
			<xsl:attribute name="content" select="'initial-scale=1.0, maximum-scale=5.0, user-scalable=1'"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="ep:head_css_font_script">
		<xsl:element name="link" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="rel">stylesheet</xsl:attribute>
			<xsl:attribute name="type">text/css</xsl:attribute>
			<xsl:attribute name="href" select="'font/font-awesome-4.0.3/css/font-awesome.min.css'"/>
		</xsl:element>
		<xsl:for-each select="tokenize($files_to_stylesheet, ':')">
			<xsl:element name="link" xmlns="http://www.w3.org/1999/xhtml">
				<xsl:attribute name="rel">stylesheet</xsl:attribute>
				<xsl:attribute name="type">text/css</xsl:attribute>
				<xsl:attribute name="href" select="substring-after(., '/')"/>
			</xsl:element>
		</xsl:for-each>
		<xsl:element name="link" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="rel">stylesheet</xsl:attribute>
			<xsl:attribute name="type">text/css</xsl:attribute>
			<xsl:attribute name="href" select="'css.css'"/>
		</xsl:element>
		<xsl:element name="link" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="rel">stylesheet</xsl:attribute>
			<xsl:attribute name="type">text/css</xsl:attribute>
			<xsl:attribute name="href" select="'ep.modern.css'"/>
		</xsl:element>
	</xsl:template>

	<xsl:template name="ep:head_js_script">
		<xsl:element name="script" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="type" select="'text/javascript'"/>
			<xsl:attribute name="src" select="'js/device/device.js'"/>
			<xsl:text> </xsl:text>
		</xsl:element>
		<xsl:element name="script" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="data-main" select="'configs/default_config.js'"/>
			<xsl:attribute name="src" select="'js/libs/require.js'"/>
			<xsl:text> </xsl:text>
		</xsl:element>
		<xsl:if test="$collWithGeogebraExercises='1'">
			<xsl:element name="script" xmlns="http://www.w3.org/1999/xhtml">
				<xsl:attribute name="type" select="'text/javascript'"/>
				<xsl:attribute name="src" select="'js/3rdparty/geogebra/deployggb.js'"/>
				<xsl:text> </xsl:text>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<xsl:message>
			<xsl:text>[xslt] Starting mobile-app transform</xsl:text>
		</xsl:message>

		<xsl:message>
			<xsl:text>[xslt] Transforming modules to mobile-app </xsl:text>
		</xsl:message>
		<xsl:variable name="col_id" select="/col:collection/col:metadata/md:content-id/text()"/>
		<xsl:variable name="col_md_version" select="/col:collection/col:metadata/md:version/text()"/>
		<xsl:variable name="col_variant" select="ep:getVariant(.)"/>

		<xsl:for-each select="$modules_epxhtml/div">
			<xsl:variable name="filename_id">
				<xsl:choose>
					<xsl:when test="./@data-pagination-id">
						<xsl:value-of select="./@data-pagination-id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="./@id"></xsl:value-of>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:result-document method="html" version="5.0" encoding="UTF-8" href="file:///{$resultDir}/m_{$filename_id}.html">
				<xsl:copy-of select="preceding::comment()[1]"></xsl:copy-of>
				<xsl:element name="html" xmlns="http://www.w3.org/1999/xhtml">
					<xsl:element name="head">
						<xsl:call-template name="ep:head_meta_data"/>
					</xsl:element>
					<xsl:element name="body">
						<xsl:element name="div">
							<xsl:attribute name="class" select="ep:map_role2css('reader-content')"/>
							<xsl:attribute name="id" select="'reader-content'"/>
							
							<xsl:apply-templates select=".">
								<xsl:with-param name="col_id" tunnel="yes" select="$col_id"/>
								<xsl:with-param name="col_md_version" tunnel="yes" select="$col_md_version"/>
								<xsl:with-param name="col_variant" tunnel="yes" select="$col_variant"/>
							</xsl:apply-templates>
						</xsl:element>
						<xsl:element name="div">
							<xsl:attribute name="class" select="'big-image-container'"/>
							<xsl:attribute name="id" select="'big_image_container'"/>
							<xsl:element name="div">
								<xsl:attribute name="id" select="'controls'"/>
								<xsl:element name="button">
									<xsl:attribute name="id" select="'close_btn'"/>
									<xsl:attribute name="onclick" select="'closeImage()'"/>
									<xsl:attribute name="title" select="$locales/locale[@key='button_close']"/>
									<xsl:attribute name="type" select="'button'"/>
								</xsl:element>
								<xsl:element name="button">
									<xsl:attribute name="id" select="'display_btn'"/>
									<xsl:attribute name="class" select="'zoom-img'"/>
									<xsl:attribute name="title" select="$locales/locale[@key='button_zoom_in_out_img']"/>
									<xsl:attribute name="type" select="'button'"/>
								</xsl:element>
							</xsl:element>
							<xsl:element name="div">
								<xsl:attribute name="id" select="'img-container'"/>
								<xsl:element name="img">
									<xsl:attribute name="id" select="'img_bigger'"/>
									<xsl:attribute name="class" select="'img_bigger'"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:result-document>
		</xsl:for-each>

		<xsl:message>
			<xsl:text>[xslt] Transforming table of content - toc.html </xsl:text>
		</xsl:message>
		<xsl:result-document method="html" encoding="UTF-8" indent="no" href="file:///{$resultDir}/toc.xml" >
			<xsl:apply-templates mode="generate_toc_html"/>
		</xsl:result-document>

		<xsl:call-template name="genetarateGlossaryElements"></xsl:call-template>
		
		<xsl:call-template name="ep:save_all_womi_occur_in_gallery"></xsl:call-template>
	</xsl:template>
		
		
	<xsl:template match="div[contains(@ep:role, 'section-contents') and contains(@ep:role, 'foldable-contents')]">
		<div class="foldable-header generated-header" xmlns="http://www.w3.org/1999/xhtml">
			<a>
				<xsl:value-of select="$locales/locale[@key='label-expand']"/>
			</a>
			<a class="foldable-header-anchor-expanded">
				<xsl:value-of select="$locales/locale[@key='label-collapse']"/>
			</a>
		</div>
		<xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:apply-templates select="@*|node()"/>
		</xsl:element>
	</xsl:template>
		
	<xsl:template name="genetarateGlossaryElements">
		<xsl:if test="doc-available(concat($epxhtml_path, '/mappingGlossary.xml'))">
			<xsl:for-each-group select="ep:getDocumentContent(concat($epxhtml_path, '/mappingGlossary.xml'))//cnxml:item" group-by="@module_id">
				<xsl:variable name="module_id" select="./@module_id"/>
				<xsl:for-each select="$modules_epxhtml/div[@id=$module_id]//div[@ep:role='section-contents']/div">
					<xsl:call-template name="createGlossaryFile">
						<xsl:with-param name="filename" select="@id"/>
						<xsl:with-param name="ctx" select="."/>
					</xsl:call-template>
				</xsl:for-each>
				<xsl:for-each select="$modules_epxhtml/div[@id=$module_id]/div[@ep:role='bibliography']//li">
					<xsl:call-template name="generateOneGlossaryElement_bib"/>
				</xsl:for-each>
			</xsl:for-each-group>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template name="createGlossaryFile">
		<xsl:param name="filename"/>
		<xsl:param name="ctx"/>
		<xsl:if test="not($ctx)">
			<xsl:message terminate="yes">
				<xsl:text>[XSLT_ERR] Missing glossary element - </xsl:text>
				<xsl:value-of select="$filename"/>
			</xsl:message>
		</xsl:if>
		<xsl:variable name="filePath" select="concat('file:///',$resultDir,'/tooltips/',$filename,'.html')"/>
		<xsl:if test="$ctx and $filename and not(unparsed-text-available($filePath))">
			<xsl:result-document method="html" version="5.0" encoding="UTF-8" indent="no" href="{$filePath}">
				<xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
					<xsl:attribute name="class" select="ep:map_role2css('reader-content')"/>
					<xsl:apply-templates select="$ctx">
						<xsl:with-param name="glossary_mode" select="'1'" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:result-document>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="generateOneGlossaryElement_bib">
		<xsl:variable name="filePath" select="concat('file:///',$resultDir,'/tooltips/',@id,'.html')"/>
		<xsl:if test="@id and not(unparsed-text-available($filePath))">
			<xsl:result-document method="html" version="5.0" encoding="UTF-8" indent="no" href="{$filePath}">
				<xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
					<xsl:attribute name="class" select="ep:map_role2css('reader-content')"/>
					<xsl:element name="div">
						<xsl:apply-templates select="@*|node()">
							<xsl:with-param name="glossary_mode" select="'1'" tunnel="yes"/>
						</xsl:apply-templates>
					</xsl:element>
				</xsl:element>
			</xsl:result-document>
		</xsl:if>
	</xsl:template>
	
	<xsl:function name="ep:getNewNodeTitle">
		<xsl:param name="context" as="node()*"/>
		<xsl:variable name="nodeTitle" select="$context/md:title"></xsl:variable>
		
		<xsl:choose>
			<xsl:when test="matches($nodeTitle, '^\s*Zadania\s*$') and $context/following-sibling::node()[1][contains(./md:title, 'Zadania generatorowe')]">
				<xsl:value-of select="'Zadania cz. I'"/>
			</xsl:when>
			<xsl:when test="contains($nodeTitle, 'Zadania generatorowe')">
				<xsl:variable name="prec_sib_node" select="$context/preceding-sibling::node()[1]"></xsl:variable>
				<xsl:choose>
					<xsl:when test="matches($prec_sib_node/md:title, '^\s*Zadania\s*$')">
						<xsl:value-of select="'Zadania cz. II'"></xsl:value-of>
					</xsl:when>
					<xsl:when test="matches($prec_sib_node/md:title, 'I')">
						<xsl:value-of select="concat($context/preceding-sibling::node()[contains(./md:title, 'Zadania cz')][1], 'I')"></xsl:value-of>
					</xsl:when>
					<xsl:when test="matches($prec_sib_node/md:title, '[0-9]+')">
						<xsl:analyze-string select="$prec_sib_node/md:title" regex="([0-9]+)">
							<xsl:matching-substring>
								<xsl:value-of select="concat('Zadania cz. ', number(regex-group(1))+1)"></xsl:value-of>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</xsl:when>
					<xsl:when test="not($prec_sib_node)">
						<xsl:value-of select="'Zadania cz. I'"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="matches($nodeTitle, ',\s+zadania generatorowe')">
				<xsl:value-of select="replace($nodeTitle, ',\s+zadania generatorowe', '')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$nodeTitle"></xsl:value-of>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:template match="div[@ep:role='about_module']//td[@ep:role='label_module_title']/span[contains(text(), 'Zadania')]/text()">
		<xsl:variable name="node_foll" select="ancestor::node()[@ep:role='about_module']/following-sibling::node()[1]//td[@ep:role='label_module_title']/span[2]/text()"></xsl:variable>
		
		<xsl:choose>
			<xsl:when test="matches(., '/\s*Zadania\s*$') and contains($node_foll, 'Zadania generatorowe')">
				<xsl:value-of select="replace(., 'Zadania', 'Zadania cz. I')"/>
			</xsl:when>
			<xsl:when test="contains(., 'Zadania generatorowe')">
				<xsl:variable name="prec_sib_node" select="ancestor::node()[@ep:role='about_module']/preceding-sibling::node()[1]//td[@ep:role='label_module_title']/span[2]/text()"></xsl:variable>
				<xsl:choose>
					<xsl:when test="matches($prec_sib_node, '/\s*Zadania\s*$')">
						<xsl:value-of select="replace(., 'Zadania generatorowe', 'Zadania cz. II')"></xsl:value-of>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="task_no" select="substring-after($prec_sib_node, 'Zadania ')"></xsl:variable>
						
						<xsl:choose>
							<xsl:when test="matches($task_no, 'I')">
								<xsl:value-of select="replace(., 'generatorowe', $task_no)"></xsl:value-of>
								<xsl:text>I</xsl:text>
							</xsl:when>
							<xsl:when test="matches($task_no, '[0-9]+')">
								<xsl:value-of select="replace(., 'generatorowe', 'cz. ')"/>
								
								<xsl:analyze-string select="$task_no" regex="([0-9]+)">
									<xsl:matching-substring>
										<xsl:value-of select="number(regex-group(1))+1"/>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="matches(., ',\s+zadania generatorowe')">
				<xsl:value-of select="replace(., ',\s+zadania generatorowe', '')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."></xsl:value-of>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<xsl:template match="div[descendant::div[@ep:role='section' and contains(./node()[@ep:role='section-header']/span[@ep:role='title']/text(), 'Zadania generatorowe')]]">
		<xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="./h1"/>
				
			<xsl:element name="div">
				<xsl:apply-templates select="./div[1]/@*"/>
				<xsl:element name="div">
					<xsl:apply-templates select="./div/div[@ep:role = 'section-contents']/@*"/>
					<xsl:for-each select="./div/div[@ep:role = 'section-contents']/child::node()">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ep:alternatives">
		<xsl:variable name="alternativeClassic" select="ep:alternative[ep:formats/ep:format = 'classicmobile']"></xsl:variable>
		<xsl:variable name="womiId" select="number($alternativeClassic/ep:reference/@ep:id)"/>
		
		<xsl:choose>
			<xsl:when test="$alternativeClassic">
				<xsl:choose>
					<xsl:when test="$alternativeClassic/div/@ep:role='qmlitem' 
						or (some $x in ('womi_exercise_engine','custom_logic_exercise_womi','geogebra','custom_womi','processingjs_animation') satisfies contains(ep:getManifestById($womiId)/engine, $x))">
						<xsl:apply-templates select="$alternativeClassic/node()[self::div|self::ep:reference]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="ep:alternative/ep:formats/ep:format = 'static'">
								<xsl:apply-templates select="ep:alternative[ep:formats/ep:format = 'static']/div"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if
									test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, 'mobile') = true()">
									<xsl:apply-templates
										select="$alternativeClassic/node()[self::div|self::ep:reference]"
									/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="h1[contains(parent::node()/@id, 'second_page') or contains(parent::node()/@id, 'about')]">
		<xsl:element name="h1" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="./span[@ep:role='title']"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="span[@ep:role='title' and parent::node()[@ep:role='module-header']]">
		<xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:apply-templates select="@*"/>
			<xsl:variable name="elem_module_pres_title" select="parent::node()/following-sibling::div[@ep:role='module-presentation-title']/node()"></xsl:variable>
			<xsl:choose>
				<xsl:when test="$elem_module_pres_title">
					<xsl:apply-templates select="$elem_module_pres_title"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="./text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="div[@ep:role='solution' 
		or @ep:role='commentary' 
		or @ep:role='commentary commentary-example']/@style">
		<xsl:attribute name="style">
			<xsl:text>display: none;</xsl:text>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="div[@ep:role='solution-toggles' or @ep:role='commentary-toggles']/@style">
		<xsl:attribute name="style">
			<xsl:text>display: block;</xsl:text>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="a[@ep:role='link']">
		<xsl:element name="a" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="href">
				<xsl:variable name="currModuleId" select="ancestor::div[last()]/@id"/>
				<xsl:variable name="tokens" select="tokenize(@href, '#')"/>
				<xsl:variable name="linkModuleId">
					<xsl:analyze-string select="$tokens[1]" regex="^\.\./(.+)$">
						<xsl:matching-substring>
							<xsl:value-of select="regex-group(1)"/>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:value-of select="."/>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				
				<xsl:variable name="linkData" select="ep:get_link_module_id_and_location($currModuleId, $linkModuleId, $tokens[2])"/>
				<xsl:if test="$linkData[1] != ''">
					<xsl:text>m_</xsl:text>
					<xsl:value-of select="$linkData[1]"/>
					<xsl:text>.html</xsl:text>
				</xsl:if>
				
				<xsl:if test="$linkData[2] != ''">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="$linkData[2]"/>
				</xsl:if>
			</xsl:attribute>
			
			<xsl:attribute name="class">
				<xsl:value-of select="ep:map_role2css(@ep:role)"/>
				<xsl:text> pagina-link</xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="text()|node()"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:function name="ep:get_link_module_id_and_location" as="node()+">
		<xsl:param name="currModuleId"/>
		<xsl:param name="linkModuleId"/>
		<xsl:param name="linkLocation"/>
		
		<xsl:choose>
			<xsl:when test="$linkModuleId = ''">
				<xsl:choose>
					<xsl:when test="$modules_epxhtml/div[@id=$currModuleId][1]/@data-pagination-id">
						<xsl:value-of select="ep:get_module_id_after_pagination_divide_module_process($currModuleId, $linkLocation)"/>
						<xsl:value-of select="$linkLocation"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="''"/>
						<xsl:value-of select="$linkLocation"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$modules_epxhtml/div[@id=$linkModuleId][1]/@data-pagination-id">
						<xsl:value-of select="ep:get_module_id_after_pagination_divide_module_process($linkModuleId, $linkLocation)"/>
						<xsl:value-of select="$linkLocation"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$linkModuleId"/>
						<xsl:value-of select="$linkLocation"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:function>
	
	<xsl:function name="ep:get_module_id_after_pagination_divide_module_process">
		<xsl:param name="moduleId"/>
		<xsl:param name="location"/>
		
		<xsl:choose>
			<xsl:when test="$location != ''">
				<xsl:value-of select="$modules_epxhtml/div[@id=$moduleId and .//span[@ep:role='bookmark']/@id = $location][1]/@data-pagination-id[1]"></xsl:value-of>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$modules_epxhtml/div[@id=$moduleId][1]/@data-pagination-id"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template match="a[@ep:link-type]">
		<xsl:variable name="source_id" select="substring-after(@href, '#')"/>
		<xsl:variable name="currTooltipType" select="@ep:tooltip-type"></xsl:variable>
		<xsl:variable name="elementCtx" select="$modules_epxhtml//node()[@id=$source_id]"/> 
		
		<xsl:element name="a" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:choose>
				<xsl:when test="$currTooltipType = 'tooltip'">
					<xsl:variable name="filename">
						<xsl:if test="not(starts-with($source_id, $currTooltipType))">
							<xsl:text>tooltip_</xsl:text>
						</xsl:if>
						<xsl:value-of select="$source_id"/>
					</xsl:variable>
					
					<xsl:attribute name="data-tooltip-file">
						<xsl:text>tooltips/</xsl:text>
						<xsl:value-of select="$filename"/>
						<xsl:text>.html</xsl:text>
					</xsl:attribute>
					<xsl:choose>
						<xsl:when test="@ep:local-reference='false'">
							<xsl:call-template name="createGlossaryFile">
								<xsl:with-param name="filename" select="$filename"/>
								<xsl:with-param name="ctx" select="$modules_epxhtml/node()[@id=tokenize($source_id,'_')[2]]//node()[@id=substring-after($source_id,'tooltip_')]"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="createGlossaryFile">
								<xsl:with-param name="filename" select="$filename"/>
								<xsl:with-param name="ctx" select="$elementCtx"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="starts-with($source_id, $currTooltipType)">
					<xsl:attribute name="data-tooltip-file">
						<xsl:value-of select="concat('tooltips/', $source_id, '.html')"/>
					</xsl:attribute>
					<xsl:call-template name="createGlossaryFile">
						<xsl:with-param name="filename" select="$source_id"/>
						<xsl:with-param name="ctx" select="$elementCtx"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$currTooltipType != ''">
					<xsl:variable name="filename">
						<xsl:if test="not(starts-with($source_id, $currTooltipType))">
							<xsl:value-of select="$currTooltipType"/>
							<xsl:text>_</xsl:text>
						</xsl:if>
						<xsl:value-of select="$source_id"/>
					</xsl:variable>
					<xsl:attribute name="data-tooltip-file">
						<xsl:text>tooltips/</xsl:text>
						<xsl:value-of select="$filename"/>
						<xsl:text>.html</xsl:text>
					</xsl:attribute>
					<xsl:call-template name="createGlossaryFile">
						<xsl:with-param name="filename" select="$filename"/>
						<xsl:with-param name="ctx" select="$elementCtx"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="data-tooltip-file">
						<xsl:value-of select="concat('tooltips/', $source_id, '.html')"/>
					</xsl:attribute>
					<xsl:call-template name="createGlossaryFile">
						<xsl:with-param name="filename" select="$source_id"/>
						<xsl:with-param name="ctx" select="$elementCtx"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates select="@*[name(.) != 'ep:local-reference']|node()"></xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="span[@ep:role='label' and parent::div[@ep:role='tooltip-header']]">
	</xsl:template>

	<xsl:template match="form">
		<xsl:element name="{local-name()}" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:apply-templates select="@*"/>

			<xsl:choose>
				<xsl:when test="(ancestor::node()[contains(@ep:role, 'exercise')][2]/@ep:role = 'exercise') and contains(./@id, 'single-response')">
					<xsl:for-each select="./div [not(@ep:role='exercise-buttons')]">
						<xsl:element name="{local-name()}">
							<xsl:apply-templates select="@*"/>
							<xsl:for-each select="node()">
								<xsl:choose>
									<xsl:when test="local-name() = 'input'">
										<xsl:element name="{local-name()}">
											<xsl:for-each select="@*">
												<xsl:if test="local-name()!='onclick'">
													<xsl:apply-templates select="."/>
												</xsl:if>
											</xsl:for-each>
										</xsl:element>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:element>
					</xsl:for-each>
					<xsl:apply-templates select="div[@ep:role='exercise-buttons']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="div[@ep:role='exercise-buttons']">
 		<xsl:element name="{local-name()}" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="class">
				<xsl:apply-templates select="@*"/>
			</xsl:attribute>

			<xsl:choose>
				<xsl:when test="contains(parent::node()/@id, 'single-response') and not(./node())">
					<xsl:variable name="exercise_content" select="ancestor::node()[@ep:role='exercise-contents']"/>		
					
					<xsl:call-template name="create_new_exercise_button_ans_div">
						<xsl:with-param name="ex_content_id" select="$exercise_content/div/@id"></xsl:with-param>
						<xsl:with-param name="ex_form_id" select="$exercise_content//form/@id"></xsl:with-param>
						<xsl:with-param name="ex_correct_answers" select="tokenize(preceding-sibling::node()[1]/input/@onclick, ',')[last()]"></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="btn_kinds">
						<xsl:for-each select="node()">
							<xsl:value-of select="concat(local-name(), ',')"/>

							<xsl:if test="local-name() = 'input'">
								<xsl:value-of select="concat('_', ./@value, ', ')"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>

					<xsl:choose>
						<xsl:when test="contains($btn_kinds, 'input')">
							<xsl:if test="not(contains($btn_kinds, $locales/locale[@key='CheckAnswer']))">
								<xsl:variable name="exercise_content" select="ancestor::node()[@ep:role='exercise-contents']"/>								
								<xsl:call-template name="create_new_exercise_button_ans_div">
									<xsl:with-param name="ex_content_id" select="$exercise_content/div/@id"></xsl:with-param>
									<xsl:with-param name="ex_form_id" select="$exercise_content//form/@id"></xsl:with-param>
									<xsl:with-param name="ex_correct_answers" select="tokenize($exercise_content//form/div[1]/input/@onclick, ',')[last()]"></xsl:with-param>
								</xsl:call-template>
							</xsl:if>

							<xsl:for-each select="./input">
								<xsl:element name="{local-name()}">
									<xsl:variable name="buttonType">
										<xsl:choose>
											<xsl:when test="./@value = $locales/locale[@key='CheckAnswer'] or contains(./@onclick, 'Answer')">
												<xsl:text>ex_check</xsl:text>
											</xsl:when>
											<xsl:when test="./@value = $locales/locale[@key='Hint'] or contains(./@onclick, 'Hint')">
												<xsl:text>ex_hint</xsl:text>
											</xsl:when>
										</xsl:choose>
									</xsl:variable>

									<xsl:for-each select="@*">
										<xsl:choose>
											<xsl:when test="local-name() = 'onclick'">
												<xsl:attribute name="onclick" select="translate(replace(., 'document.getElementById', ''), '[]', '')"/>
											</xsl:when>
											<xsl:when test="contains(local-name(), 'role')">
												<xsl:attribute name="class">
													<xsl:value-of select="ep:map_role2css('button')"/>
													<xsl:text> </xsl:text>
													<xsl:value-of select="$buttonType"/>
												</xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates select="."/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:element>
							</xsl:for-each>

						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="@*|node()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="create_new_exercise_button_ans_div">
		<xsl:param name="ex_content_id"></xsl:param>
		<xsl:param name="ex_form_id"></xsl:param>
		<xsl:param name="ex_correct_answers"></xsl:param>
		
		<xsl:element name="input" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="type" select="'button'"/>
			<xsl:attribute name="class">
				<xsl:value-of select="ep:map_role2css('button')"/>
				<xsl:text> ex_check</xsl:text>
			</xsl:attribute>
			
			<xsl:attribute name="value" select="$locales/locale[@key='CheckAnswer']"/>
			<xsl:attribute name="onclick">
				<xsl:text>showAnswer('</xsl:text>
				<xsl:value-of select="$ex_content_id"/>
				<xsl:text>', '</xsl:text>
				<xsl:value-of select="$ex_form_id"/>
				<xsl:text>', </xsl:text>
				<xsl:value-of select="$ex_correct_answers"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
	
	
	<xsl:template match="div[@ep:role='gallery-contents']/div[contains(@ep:role, 'content')]">
		<xsl:if test="@ep:role='content mobile'">
			<xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
				<xsl:apply-templates select="node()|@*"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="@ep:role">
		<xsl:attribute name="class">
			<xsl:value-of select="ep:map_role2css(.)" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="form/div/span[@ep:role = 'answer-prefix']">
	</xsl:template>
	
	<xsl:template match="@ep:interactivity|@ep:type">
	</xsl:template>
	
	<xsl:template match="@type[parent::div[contains(@ep:role, 'commentary')]]">
	</xsl:template>
	
	<xsl:template match="@ep:*[parent::div[contains(@ep:role,'gallery')] and local-name(.) != 'role']|@ep:name|@ep:link-type|@ep:tooltip-type|@ep:target-name">
		<xsl:attribute name="data-{local-name(.)}" select="."></xsl:attribute>
	</xsl:template>	
	
	<xsl:template match="@ep:*">
	</xsl:template>   
	
	<xsl:template name="create_link_to_solution_pdf"/>
	<xsl:template name="create_link_to_solution_epub">
		<xsl:param name="p_col_id"/>
	</xsl:template>
	
	<xsl:template match="br">
		<xsl:value-of disable-output-escaping="yes">&lt;br/&gt;</xsl:value-of>
	</xsl:template>
	
	<xsl:template match="ep:mathElement">
        <xsl:apply-templates/>
    </xsl:template>
	
	<xsl:template name="ep:save_all_womi_occur_in_gallery">
		<xsl:variable name="womiIds">
			<gallery_womi>
				<xsl:for-each select="$modules_epxhtml/div">
					<xsl:for-each select="distinct-values(.//ep:reference[ancestor::div[@ep:role='gallery-contents']]/@ep:id)">
						<xsl:if test="ep:getImageType(number(.), 'mobile_app', 'mobile') != ''">
							<womi_id>
								<xsl:value-of
									select="concat(number(.), '_thumbnail.', ep:getImageType(number(.), 'mobile_app', 'mobile'))"
								/>
							</womi_id>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</gallery_womi>
		</xsl:variable>
		
		<xsl:result-document omit-xml-declaration="yes" encoding="UTF-8" href="file:///{$resultDir}/gallery_womi.xml">
			<xsl:copy-of select="$womiIds"/>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="div[@ep:role='go-to-glossary' or @ep:role='go-back-from-glossary']">
		<div xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="style" select="'display:none;'"/>
			<xsl:apply-templates select="node()|@*"/>
		</div>
	</xsl:template>

	<xsl:template match="node()[@ep:role='module-header' 
		and not(contains(parent::div/@id, 'second_page')) and not(contains(parent::div/@id, 'about'))]">
		<xsl:element name="{local-name()}" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:choose>
				<xsl:when test="./following-sibling::div[@ep:role='module-header-caption']">
					<xsl:variable name="banerInfo" select="./following-sibling::div[@ep:role='module-header-caption']"/>
					<xsl:variable name="banerWomiId" select="$banerInfo/div/@baner-womi"/>
					<xsl:variable name="banerWomi" select="concat($banerWomiId,'.',ep:getImageType($banerWomiId, $outputFormat, 'mobile'))"/>
					<xsl:attribute name="class">
						<xsl:value-of select="@ep:role"/>
						<xsl:if test="$banerInfo/div[@baner-title-position]">
							<xsl:text> title-</xsl:text>
							<xsl:value-of select="$banerInfo/div/@baner-title-position"/>
						</xsl:if>
					</xsl:attribute>
					<div class="module-header-title">
						<xsl:apply-templates select="node()"/>
					</div>
					<div class="module-header-image" style="background-image: url(womi/{$banerWomi});">
						<div class="module-header-caption">
							<div class="title">
								<xsl:value-of
									select="ep:getDocumentContent(concat('file:///', $womiLocalPath, '/', number($banerWomiId), '-metadata2.xml'))/metadata/Tytul"
								/>
							</div>
							<div class="caption">
								<xsl:apply-templates
									select="$banerInfo/node()[not(local-name()='div' and @baner-womi)]"
								/>
							</div>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="span[@ep:role='warning-message']"/>
	
	<xsl:template match="node()[@ep:role='observation-header warning' or @ep:role='experiment-header warning']">
		<xsl:element name="{local-name()}" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:apply-templates select="@*|node()"/>
			<div class="warning-message" xmlns="http://www.w3.org/1999/xhtml">
				<xsl:value-of select="$locales/locale[@key='label_adult_supervision']"/>
			</div>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="div[@ep:role='module-header-caption']"/>
	<xsl:template match="div[@ep:role='module-presentation-title']"/>
	
	<xsl:template match="div[contains(@ep:role,'tooltip')]">
		<xsl:param name="glossary_mode" tunnel="yes"/>
		<xsl:if test="$glossary_mode = '1'">
			<div xmlns="http://www.w3.org/1999/xhtml">
				<xsl:apply-templates select="@*|node()"/>
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="div[@ep:role='strip-end' or @ep:role='strip-start']"/>
	
</xsl:stylesheet>