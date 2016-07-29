<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ep="http://epodreczniki.pl/"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs ep"
    version="2.0">

	<xsl:import href="resolve-womi.xsl"/>

	<xsl:output method="xhtml" omit-xml-declaration="yes" indent="no"/>

	<xsl:param name="outputFormat" select="''"/>
	<xsl:param name="isPreview" select="false()"/>  

	<xsl:template match="ep:width">
		<xsl:choose>
			<xsl:when test="$outputFormat = 'pdf'">
				<xsl:attribute name="style" select="concat('max-width:', ., ';')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="style" select="concat('width:', ., ';')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ep:content">
		<xsl:call-template name="create_ep_content_static_mobile_app"/>
	</xsl:template>
	
	<xsl:template match="newline">
		<span class="newline">
			<br/>
		</span>
	</xsl:template>

	<xsl:template match="ep:reference">
		<xsl:param name="epub_format" tunnel="yes"/>
		<xsl:param name="col_id" tunnel="yes"/>
		<xsl:param name="col_md_version" tunnel="yes"/>
		<xsl:param name="col_variant" tunnel="yes"/>
		<xsl:param name="isGalleryOneElem" tunnel="yes" as="xs:integer" select="0"/>
		<xsl:param name="isGalleryElement" tunnel="yes" as="xs:integer" select="0"/>

		<xsl:variable name="womiId" select="ep:getWomiId(.)"/>
		<xsl:variable name="womiEngine" select="ep:getManifestById($womiId)/engine"/>
		<xsl:variable name="womiType" select="ep:getMetadataWomiType($womiId)"/>
		<xsl:variable name="alternativeContent">
			<xsl:call-template name="getAlternativeContent">
				<xsl:with-param name="womiId" select="$womiId"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="href">
			<xsl:call-template name="getHref"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="doc-available($alternativeContent) and document($alternativeContent)/*[local-name() = 'alternative-metadata']">
				<xsl:value-of select="$locales/locale[@key='no-alternative-reason']/text()"/>
				<xsl:value-of select="document($alternativeContent)/*/*/text()"/>
			</xsl:when>
			<xsl:when test="doc-available($alternativeContent)">
				<xsl:call-template name="insert_static_html">
					<xsl:with-param name="col_id">
						<xsl:call-template name="getModuleId"/>
					</xsl:with-param>
					<xsl:with-param name="epub_format" select="$epub_format" tunnel="yes"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')">
				<xsl:if test="not(preceding-sibling::node()[normalize-space(local-name())
					and local-name()='span' and @ep:role='newline'])">
					<span class="newline"><br/></span>
				</xsl:if>
				<div>
					<xsl:attribute name="class">
						<xsl:text>womi-container note-ignore</xsl:text>
						<xsl:value-of select="@ep:role"/>
						<xsl:if test="ep:aside">
							<xsl:text> womi-aside</xsl:text>
						</xsl:if>
						<xsl:if test="$womiType='SOUND'">
							<xsl:text> womi-audio</xsl:text>
						</xsl:if>
						<xsl:if test="$womiType='MOVIE'">
							<xsl:text> womi-movie</xsl:text>
						</xsl:if>
						<xsl:if test="$womiType='INTERACTIVE'">
							<xsl:text> womi-interactive</xsl:text>
						</xsl:if>
						<xsl:if test="ep:getManifestById($womiId)/engine = 'womi_attachment'">
							<xsl:text> womi-attachment</xsl:text>
						</xsl:if>
					</xsl:attribute>
					<xsl:apply-templates select="@ep:instance-id|@ep:id"/>
					<div class="{$outputFormat}">
						<xsl:variable name="womi-label">
							<xsl:call-template name="getWomiLabel">
								<xsl:with-param name="womiId" select="$womiId"/>
								<xsl:with-param name="womiType" select="$womiType"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="womi-numbering">
							<xsl:call-template name="getWomiNumbering">
								<xsl:with-param name="womiId" select="$womiId"/>
								<xsl:with-param name="womiType" select="$womiType"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:if test="(not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all')) and not(doc-available($alternativeContent))">
							<xsl:call-template name="set_womi_label_numbering_title">
								<xsl:with-param name="womiId" select="$womiId"/>
								<xsl:with-param name="womi-label" select="$womi-label"/>
								<xsl:with-param name="womi-numbering" select="$womi-numbering"></xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<div class="image-container">
							<xsl:choose>
								<xsl:when test="$womiType='GRAPHICS'">
									<xsl:call-template name="create_static_image">
										<xsl:with-param name="womiId" select="$womiId"/>
										<xsl:with-param name="epub_format" select="$epub_format"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$womiType='ICON'">
									<xsl:call-template name="create_static_image">
										<xsl:with-param name="womiId" select="$womiId"/>
										<xsl:with-param name="epub_format" select="$epub_format"/>
										<xsl:with-param name="set_width" select="'false'"/>
										<xsl:with-param name="with_class" select="'icon'"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$womiType='INTERACTIVE'">
									<xsl:if test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, $outputFormat)=true()">
										<xsl:call-template name="create_static_image">
											<xsl:with-param name="womiId" select="$womiId"/>
											<xsl:with-param name="epub_format" select="$epub_format"/>
										</xsl:call-template>
									</xsl:if>
								</xsl:when>
								<xsl:when test="$womiType='MOVIE'">
									<xsl:if test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, $outputFormat)=true()">
										<xsl:call-template name="create_static_image">
											<xsl:with-param name="womiId" select="$womiId"/>
											<xsl:with-param name="epub_format" select="$epub_format"/>
										</xsl:call-template>
									</xsl:if>
								</xsl:when>
							</xsl:choose>
						</div>
						<xsl:call-template name="createWomiCapitonAndAltermativeText">
							<xsl:with-param name="womiId" select="$womiId"/>
							<xsl:with-param name="womiType" select="$womiType"/>
							<xsl:with-param name="womi-label" select="$womi-label"/>
							<xsl:with-param name="womi-numbering" select="$womi-numbering"></xsl:with-param>
						</xsl:call-template>

						<xsl:if test="$isGalleryOneElem = 1 and $isGalleryElement = 0">
							<span class="womi-link">
								<xsl:element name="a">
									<xsl:attribute name="href" select="$href"/>
									<xsl:attribute name="target" select="'_blank'"/>
									<xsl:value-of select="$locales/locale[@key='gallery_link_label']/text()"/>
								</xsl:element>
							</span>
						</xsl:if>

						<xsl:apply-templates select="ep:related"/>
					</div>
				</div>
				
				<xsl:if test="((some $format in ('INTERACTIVE', 'SOUND', 'MOVIE') satisfies $womiType=$format) 
					or (ep:getManifestById($womiId)/engine = 'womi_attachment') or ($isGalleryOneElem = 1 and $isGalleryElement = 0)) and $outputFormat = 'pdf'">
					<xsl:element name="div">
						<xsl:attribute name="class">
							<xsl:value-of select="'qr-code'"/>
							<xsl:if test="$isGalleryOneElem = 1">
								<xsl:text>-gallery</xsl:text>
							</xsl:if>
						</xsl:attribute> 
						<xsl:call-template name="create_qr_image">
							<xsl:with-param name="href" select="$href"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="createWomiCapitonAndAltermativeText">
		<xsl:param name="womiId"/>
		<xsl:param name="womiType"/>
		<xsl:param name="womi-label"/>
		<xsl:param name="womi-numbering"/>
		<xsl:param name="isGalleryElement" tunnel="yes" as="xs:integer" select="0"/>
		<xsl:variable name="womiEngine" select="ep:getManifestById($womiId)/engine"/>

		<xsl:variable name="alternativeContent">
			<xsl:call-template name="getAlternativeContent">
				<xsl:with-param name="womiId" select="$womiId"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="href">
			<xsl:call-template name="getHref"/>
		</xsl:variable>
		<div class="womi-caption">
			<xsl:choose>
				<xsl:when test="(not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all')) and not(doc-available($alternativeContent))">
						<xsl:call-template name="set_womi_label_numbering_title">
							<xsl:with-param name="womiId" select="$womiId"/>
							<xsl:with-param name="womi-label" select="$womi-label"/>
							<xsl:with-param name="womi-numbering" select="$womi-numbering"></xsl:with-param>
						</xsl:call-template>
						<xsl:if test="ancestor::div[contains(@ep:role, 'gallery')] and ep:content/@ep:format='static'">
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:call-template name="addWomiContent"/>
						<xsl:if test="some $format in ('INTERACTIVE', 'SOUND', 'MOVIE') satisfies $womiType=$format">
							<span class="newline">
								<br/>
							</span>
							<span class="womi-link">
								<xsl:call-template name="create_womi_link_content">
									<xsl:with-param name="href" select="$href"/>
									<xsl:with-param name="womiEngine" select="$womiEngine"/>
									<xsl:with-param name="womiType" select="$womiType"/>
								</xsl:call-template>
							</span>
						</xsl:if>
					
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="addWomiContent"/>
					<xsl:if test="(some $x in ('INTERACTIVE', 'MOVIE', 'SOUND') satisfies $womiType=$x)">
						<span class="womi-link">
							<xsl:call-template name="create_womi_link_content">
								<xsl:with-param name="href" select="$href"/>
								<xsl:with-param name="womiEngine" select="$womiEngine"/>
								<xsl:with-param name="womiType" select="$womiType"/>
							</xsl:call-template>
						</span>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="addWomiContent">
		<xsl:choose>
			<xsl:when test="$outputFormat = 'ebook'">
				<xsl:apply-templates select="ep:content[@ep:format = 'static-mono']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="ep:content[@ep:format = 'static']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="create_womi_link_content">
		<xsl:param name="href"/>
		<xsl:param name="womiEngine"/>
		<xsl:param name="womiType"/>

		<xsl:element name="a">
			<xsl:attribute name="href" select="$href"/>
			<xsl:attribute name="target" select="'_blank'"/>

			<xsl:choose>
				<xsl:when test="$womiEngine = 'womi_attachment'">
					<xsl:value-of select="$locales/locale[@key='attachment_womi_link_label']/text()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$womiType='INTERACTIVE'">
							<xsl:value-of select="$locales/locale[@key='interactive_exercise_link_label']/text()"/>
						</xsl:when>
						<xsl:when test="$womiType='MOVIE'">
							<xsl:value-of select="$locales/locale[@key='movie_womi_link_label']/text()"/>
						</xsl:when>
						<xsl:when test="$womiType='SOUND'">
							<xsl:value-of select="$locales/locale[@key='audio_womi_link_label']/text()"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>

	</xsl:template>

	<xsl:template name="create_static_image">
		<xsl:param name="womiId"/>
		<xsl:param name="epub_format"/>
		<xsl:param name="set_width" select="'true'"/>
		<xsl:param name="with_class" select="''"/>
		<xsl:param name="isGalleryElement" tunnel="yes" as="xs:integer" select="0"/>

		<xsl:variable name="womiUrl">
			<xsl:choose>
				<xsl:when test="$outputFormat = 'ebook' and $epub_format = 'mono'">
					<xsl:value-of select="concat('i/', $womiId, '-epub', '.', ep:getImageType($womiId, $outputFormat, $outputFormat))"/>
				</xsl:when>
				<xsl:when test="$outputFormat = 'ebook' and $epub_format = 'color'">
					<xsl:value-of select="concat('i/', $womiId, '-pdf', '.', ep:getImageType($womiId, $outputFormat, $outputFormat))"/>
				</xsl:when>
				<xsl:when test="$outputFormat = 'pdf'">
					<xsl:value-of select="concat('womi/', $womiId, '-pdf', '.', ep:getImageType($womiId, $outputFormat, $outputFormat))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes" select="concat('[XSLT_ERR] ',$outputFormat, ' is unknown')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<img src="{$womiUrl}" alt="{ep:getMetadataAlternativeText($womiId)}" id="{concat('img_womi-', @ep:instance-id)}">
			<xsl:if test="$with_class != ''">
				<xsl:attribute name="class" select="$with_class"/>
			</xsl:if>
			<xsl:if test="./ep:width and $set_width = 'true'">
				<xsl:apply-templates select="./ep:width"/>
			</xsl:if>
			<xsl:if test="$isGalleryElement = 1">
				<xsl:attribute name="data-heightRatio" select="ep:getManifestById($womiId)/parameters/pdf/heightRatio"/>
			</xsl:if>
		</img>
	</xsl:template>    

	<xsl:template name="create_qr_image">
		<xsl:param name="href"/>
		<xsl:variable name="href-id" select="(ancestor-or-self::element()/(@ep:instance-id|@id))[last()]"/>
		<xsl:variable name="womiUrl">
			<xsl:choose>
				<xsl:when test="$outputFormat = 'ebook'">
					<xsl:value-of select="concat('i/',$href-id, '-qr', '.png')"/>
				</xsl:when>
				<xsl:when test="$outputFormat = 'pdf'">
					<xsl:value-of select="concat('womi/',$href-id, '-qr', '.png')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<img src="{$womiUrl}" data-href="{$href}"/>
	</xsl:template>
	
	<xsl:template name="getAlternativeContent">
		<xsl:param name="womiId"/>
		<xsl:param name="epub_format" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="$outputFormat = 'ebook' and doc-available(concat($womiLocalPath, '/', $womiId, '-', 'epub', '-no-alt.xml'))">
				<xsl:value-of select="concat($womiLocalPath, '/', $womiId, '-', 'epub', '-no-alt.xml')"/>
			</xsl:when>
			<xsl:when test="doc-available(concat($womiLocalPath, '/', $womiId, '-', $outputFormat, '-no-alt.xml'))">
				<xsl:value-of select="concat($womiLocalPath, '/', $womiId, '-', $outputFormat, '-no-alt.xml')"/>
			</xsl:when>
			<xsl:when test="$outputFormat = 'ebook' and $epub_format = 'mono'">
				<xsl:value-of select="concat($womiLocalPath, '/', $womiId, '-', 'epub', '-content.html')"/>
			</xsl:when>
			<xsl:when test="$outputFormat = 'ebook' and $epub_format = 'color'">
				<xsl:value-of select="concat($womiLocalPath, '/', $womiId, '-', 'pdf', '-content.html')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($womiLocalPath, '/', $womiId, '-', $outputFormat, '-content.html')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="insert_static_html">
		<xsl:param name="col_id" />
		<xsl:param name="epub_format" tunnel="yes"/>
		<xsl:variable name="womiId" select="ep:getWomiId(.)"/>
		<xsl:variable name="currOutputFormat">
			<xsl:choose>
				<xsl:when test="$outputFormat = 'ebook'">
					<xsl:value-of select="'epub'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$outputFormat"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="alternativeContent">
			<xsl:choose>
				<xsl:when test="ancestor::div[@ep:role='answers_exercise']">
					<xsl:value-of select="concat('file:///', $womiLocalPath, '/', $womiId, '-', $currOutputFormat, '-solution.html')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('file:///', $womiLocalPath, '/', $womiId, '-', $currOutputFormat, '-content.html')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select="document($alternativeContent)/div/*">
			<xsl:choose>
				<xsl:when test="@ep:role = 'solution'">
					<div class="answers_solution" id="{ep:generate-id(.)}">
						<xsl:if test="not(preceding-sibling::div[@ep:role = 'solution'])">
							<h2 class="solution-header">
								<span class="title">
									<xsl:value-of select="$locales/locale[@key='solution']/text()"/>
								</span>
							</h2>
						</xsl:if>
						<div class="section-contents">
							<xsl:apply-templates select="node()">
								<xsl:with-param name="outerWomiId" tunnel="yes" select="$womiId"/>
							</xsl:apply-templates>
						</div>
					</div>
				</xsl:when>
				<xsl:when test="@ep:role = 'commentary'">
					<div class="answers_commentary" id="{ep:generate-id(.)}">
						<xsl:if test="not(preceding-sibling::div[@ep:role = 'commentary'])">
							<h2 class="commantery-header">
								<span class="title">
									<xsl:value-of select="$locales/locale[@key='commentary']/text()"/>
								</span>
							</h2>
						</xsl:if>
						<div class="section-contents">
							<xsl:apply-templates select="node()">
								<xsl:with-param name="outerWomiId" tunnel="yes" select="$womiId"/>
							</xsl:apply-templates>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select=".">
						<xsl:with-param name="outerWomiId" tunnel="yes" select="$womiId"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="ancestor::div[@ep:role='answers_exercise'] or not(ancestor::div[@ep:role='exercise-contents'])">
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$currOutputFormat = 'pdf'">
						<xsl:call-template name="create_link_to_solution_pdf"/>
					</xsl:when>
					<xsl:when test="$currOutputFormat = 'epub'">
						<xsl:call-template name="create_link_to_solution_epub">
							<xsl:with-param name="p_col_id" select="$col_id"/>
						</xsl:call-template> 
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="img[@data-womi-id]">
		<xsl:variable name="reference">
			<ep:reference ep:id="{@data-womi-id}" ep:instance-id="{concat(generate-id(.), count(preceding::img))}">
				<xsl:if test="@data-hide-caption">
					<ep:hide-caption>
						<xsl:value-of select="@data-hide-caption"/>
					</ep:hide-caption>
				</xsl:if>
				<xsl:if test="@data-width">
					<ep:width>
						<xsl:value-of select="@data-width"/>
					</ep:width>
				</xsl:if>
				<ep:nested>true</ep:nested>
			</ep:reference>
		</xsl:variable>
		<xsl:apply-templates select="$reference/ep:reference"/>
	</xsl:template>

	<xsl:template match="@data-image-id">
		<xsl:param name="outerWomiId" tunnel="yes"/>
		<xsl:param name="epub_format" tunnel="yes"/>
		<xsl:attribute name="src">
			<xsl:choose>
				<xsl:when test="$outputFormat = 'ebook' and $epub_format = 'mono'">
					<xsl:value-of select="concat('i/',$outerWomiId, '-', ., '-', 'epub', '.', ep:getImageType(concat($outerWomiId, '-', ., '-', 'epub'), $outputFormat, $outputFormat))"/>
				</xsl:when>
				<xsl:when test="$outputFormat = 'ebook' and $epub_format = 'color'">
					<xsl:value-of select="concat('i/',$outerWomiId, '-', ., '-', 'pdf', '.', ep:getImageType(concat($outerWomiId, '-', ., '-', 'pdf'), $outputFormat, $outputFormat))"/>
				</xsl:when>
				<xsl:when test="$outputFormat = 'pdf'">
					<xsl:value-of select="concat('womi/',$outerWomiId, '-', ., '-', $outputFormat, '.', ep:getImageType(concat($outerWomiId, '-', ., '-', $outputFormat), $outputFormat, $outputFormat))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message select="concat($outputFormat, ' is unknown')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="span[@ep:role = 'nowomi-image-label']">
		<xsl:element name="span">
			<xsl:apply-templates select="@*"/>
			<xsl:value-of select="$locales/locale[@key='womi-title-label']"/>
			<xsl:text>. </xsl:text>
		</xsl:element>  
	</xsl:template>
	
</xsl:stylesheet>
