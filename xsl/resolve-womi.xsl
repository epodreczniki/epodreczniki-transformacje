<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ep="http://epodreczniki.pl/" xmlns:dlibra_avs="http://epodreczniki.pcss.pl/repo/"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:col="http://cnx.rice.edu/collxml"
	xmlns:tmp="tmp"
	exclude-result-prefixes="ep dlibra_avs oai ep xs tmp col">
	
	<xsl:import href="bibtexml.xsl"/>

	<xsl:param name="womiLocalPath" select="''"/>	

	<xsl:variable name="manifestFiles">
		<xsl:for-each-group select="$modules_epxhtml//ep:reference" group-by="number(@ep:id)">
			<xsl:variable name="currWomiId" select="number(@ep:id)"/>
			<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $currWomiId, '-manifest.json.xml'))">
				<tmp:manifest>
					<xsl:attribute name="id" select="$currWomiId"/>
					<xsl:copy-of select="document(concat('file:///', $womiLocalPath, '/', $currWomiId, '-manifest.json.xml'))/manifest/*"/>
				</tmp:manifest>
			</xsl:if>
			<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $currWomiId, '-pdf-content.html'))">
				<xsl:for-each select="document(concat('file:///', $womiLocalPath, '/', $currWomiId, '-pdf-content.html'))//img">
					<xsl:variable name="nested_img_id">
						<xsl:choose>
							<xsl:when test="@data-image-id">
								<xsl:value-of select="concat($currWomiId, '-', number(@data-image-id), '-pdf')"/>
							</xsl:when>
							<xsl:when test="@data-womi-id">
								<xsl:value-of select="number(@data-womi-id)"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>					
					<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $nested_img_id, '-manifest.json.xml'))">
						<tmp:metadata>
							<xsl:copy-of select="document(concat('file:///', $womiLocalPath, '/', $nested_img_id, '-manifest.json.xml'))/manifest/*"/>
						</tmp:metadata>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:for-each-group>
		<xsl:for-each select="$modules_epxhtml//div[@ep:role='module-header-caption']/div[@baner-womi]/@baner-womi">
			<xsl:variable name="currWomiId" select="number(.)"/>
			<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $currWomiId, '-manifest.json.xml'))">
				<tmp:manifest>
					<xsl:attribute name="id" select="$currWomiId"/>
					<xsl:copy-of select="document(concat('file:///', $womiLocalPath, '/', $currWomiId, '-manifest.json.xml'))/manifest/*"/>
				</tmp:manifest>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$coll//col:metadata/ep:e-textbook/ep:references/ep:collection-header/ep:reference">
			<xsl:variable name="currWomiId" select="number(@ep:id)"/>
			<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $currWomiId, '-manifest.json.xml'))">
				<tmp:manifest>
					<xsl:attribute name="id" select="$currWomiId"/>
					<xsl:copy-of select="document(concat('file:///', $womiLocalPath, '/', $currWomiId, '-manifest.json.xml'))/manifest/*"/>
				</tmp:manifest>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="metadataFiles">
		<xsl:for-each-group select="$modules_epxhtml//ep:reference" group-by="number(@ep:id)">
			<xsl:variable name="currWomiId" select="number(@ep:id)"/>
			<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $currWomiId, '-metadata2.xml'))">
				<tmp:metadata>
					<xsl:copy-of select="document(concat('file:///', $womiLocalPath, '/', $currWomiId, '-metadata2.xml'))/metadata/*"/>
				</tmp:metadata>
			</xsl:if>
			<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $currWomiId, '-pdf-content.html'))">
				<xsl:for-each select="document(concat('file:///', $womiLocalPath, '/', $currWomiId, '-pdf-content.html'))//img">
					<xsl:variable name="nested_img_id">
						<xsl:choose>
							<xsl:when test="@data-image-id">
								<xsl:value-of select="concat($currWomiId, '-', number(@data-image-id), '-pdf')"/>
							</xsl:when>
							<xsl:when test="@data-womi-id">
								<xsl:value-of select="number(@data-womi-id)"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $nested_img_id, '-metadata2.xml'))">
						<tmp:metadata>
							<xsl:copy-of select="document(concat('file:///', $womiLocalPath, '/', $nested_img_id, '-metadata2.xml'))/metadata/*"/>
						</tmp:metadata>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:for-each-group>
		<xsl:for-each select="$modules_epxhtml//div[@baner-womi]/@baner-womi">
			<xsl:variable name="currWomiId" select="number(.)"/>
			<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $currWomiId, '-metadata2.xml'))">
				<tmp:metadata>
					<xsl:copy-of select="document(concat('file:///', $womiLocalPath, '/', $currWomiId, '-metadata2.xml'))/metadata/*"/>
				</tmp:metadata>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$coll//col:metadata/ep:e-textbook/ep:references/ep:collection-header/ep:reference">
			<xsl:variable name="currWomiId" select="number(@ep:id)"/>
			<xsl:if test="doc-available(concat('file:///', $womiLocalPath, '/', $currWomiId, '-metadata2.xml'))">
				<tmp:metadata>
					<xsl:copy-of select="document(concat('file:///', $womiLocalPath, '/', $currWomiId, '-metadata2.xml'))/metadata/*"/>
				</tmp:metadata>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:function name="ep:getManifestById" as="node()*">
		<xsl:param name="id"/>
		<xsl:copy-of select="$manifestFiles/tmp:manifest[@id= $id][1]"></xsl:copy-of>
	</xsl:function>
	
	<xsl:function name="ep:getMetadataById" as="node()*">
		<xsl:param name="id"/>
		<xsl:copy-of select="$metadataFiles/tmp:metadata[id= $id][1]"></xsl:copy-of>
	</xsl:function>

	<xsl:function name="ep:getWomiWidth" as="xs:string">
		<xsl:param name="context"/>
		<xsl:value-of select="$context/ep:width"/>
	</xsl:function>
	
	<xsl:function name="ep:getWomiId" as="xs:string">
		<xsl:param name="context"/>
		<xsl:value-of select="format-number($context/@ep:id, '#')"/>
	</xsl:function>
	
	<xsl:function name="ep:getMetadataAlternativeText" as="xs:string">
		<xsl:param name="womiReferenceId"/>
		<xsl:value-of select="ep:getMetadataById($womiReferenceId)/TekstAlternatywny/text()"/>
	</xsl:function>
	
	<xsl:function name="ep:getMetadataAuthor" as="xs:string">
		<xsl:param name="womiReferenceId"/>
		<xsl:value-of select="ep:getMetadataById($womiReferenceId)/Autor/text()"/>
	</xsl:function>
	
	<xsl:function name="ep:getMetadataLicense" as="xs:string">
		<xsl:param name="womiReferenceId"/>
		<xsl:value-of select="ep:getMetadataById($womiReferenceId)/Licencja/text()"/>
	</xsl:function>
	
	<xsl:function name="ep:getMetadataNotes" as="node()*">
		<xsl:param name="womiReferenceId"/>
		<xsl:value-of select="ep:getMetadataById($womiReferenceId)/Notatki"/>
	</xsl:function>
	
	<xsl:function name="ep:getMetadataAspectRatio" as="node()*">
		<xsl:param name="womiReferenceId"/>
		<xsl:value-of select="ep:getMetadataById($womiReferenceId)/aspectRatio"/>
	</xsl:function>
	
	<xsl:function name="ep:getMetadataTitle" as="xs:string">
		<xsl:param name="womiReferenceId"/>
		<xsl:value-of select="ep:getMetadataById($womiReferenceId)/Tytul"/>
	</xsl:function>
	
	<xsl:function name="ep:getMetadataWomiType" as="xs:string">
		<xsl:param name="womiReferenceId"/>
		<xsl:value-of select="ep:getMetadataById($womiReferenceId)/typWOMI"/>
	</xsl:function>
	
	<xsl:function name="ep:checkIfWomiHasStaticAlternativeByWomiId" as="xs:boolean">
		<xsl:param name="womiReferenceId"/>
		<xsl:param name="format"/>	
		
		<xsl:choose>
			<xsl:when test="contains(ep:getManifestById($womiReferenceId)/parameters/node()[local-name()=$format]/mimeType, 'image')">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ep:getImageType" as="text()">
		<xsl:param name="womiReferenceId"/>
		<xsl:param name="outputFormat"/>
		<xsl:param name="format"/>

		<xsl:variable name="originalExt">
			<xsl:choose>
				<xsl:when test="ep:getManifestById($womiReferenceId)">
					<xsl:value-of select="substring-after(ep:getManifestById($womiReferenceId)//parameters/node()[local-name()=$format]/mimeType, '/')"></xsl:value-of>
				</xsl:when>
				<xsl:when test="doc-available(concat('file:///', $womiLocalPath, '/', $womiReferenceId, '-formats.xml'))">
					<xsl:choose>
						<xsl:when test="document(concat('file:///', $womiLocalPath, '/', $womiReferenceId, '-formats.xml'))//format[contains(@id, 'PDF')][1]">
							<xsl:value-of select="substring-after(document(concat('file:///', $womiLocalPath, '/', $womiReferenceId, '-formats.xml'))//format[contains(@id, 'PDF')][1]/@mainFile, '.')"></xsl:value-of>
						</xsl:when>
						<xsl:when test="document(concat('file:///', $womiLocalPath, '/', $womiReferenceId, '-formats.xml'))//format[contains(@id, 'CLASSIC')][1]">
							<xsl:value-of select="substring-after(document(concat('file:///', $womiLocalPath, '/', $womiReferenceId, '-formats.xml'))//format[contains(@id, 'CLASSIC')][1]/@mainFile, '.')"></xsl:value-of>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="ext" select="lower-case($originalExt)"/>
		<xsl:choose>
			<xsl:when test="contains($ext, 'svg') and ($outputFormat = 'ebook' or $outputFormat = 'mobile_app' or $outputFormat = 'pdf')">
				<xsl:text>png</xsl:text>
			</xsl:when>
			<xsl:when test="contains($ext, 'jpeg')">
				<xsl:text>jpg</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="tokenize($ext,'\+')[1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ep:getWomiContext" as="xs:boolean">
		<xsl:param name="node"/>
		<xsl:value-of select="$node/ep:context"/>
	</xsl:function>
	
	<xsl:function name="ep:getReadingRoom" as="xs:boolean">
		<xsl:param name="node"/>
		<xsl:value-of select="$node/ep:reading-room"/>
	</xsl:function>

	<xsl:function name="ep:getEmbedded" as="xs:boolean">
		<xsl:param name="node"/>
		<xsl:value-of select="$node/ep:embedded"/>
	</xsl:function>
	
	<xsl:function name="ep:getAssociatedText" as="xs:string">
		<xsl:param name="node"/>
		<xsl:param name="format"/>
		<xsl:value-of select="normalize-space($node/ep:content[@ep:format = $format])"/>
	</xsl:function>
	
	<xsl:template name="getWomiLabel">
		<xsl:param name="womiId"/>
		<xsl:param name="womiType"/>
		
		<xsl:choose>
			<xsl:when test="ancestor::node()[@ep:role='gallery']">
				<xsl:value-of select="$locales/locale[@key='womi-gallery-element-label']"/>
			</xsl:when>
			<xsl:when test="ep:getManifestById($womiId)/engine = 'womi_attachment'">
				<xsl:value-of select="$locales/locale[@key='womi-attachment-label']"/>
			</xsl:when>
			<xsl:when test="some $x in ('GRAPHICS', 'ICON') satisfies $womiType=$x">
				<xsl:value-of select="$locales/locale[@key='womi-image-label']"/>
			</xsl:when>
			<xsl:when test="$womiType='INTERACTIVE'">
				<xsl:value-of select="$locales/locale[@key='womi-interactive-label']"/>
			</xsl:when>
			<xsl:when test="$womiType='MOVIE'">
				<xsl:value-of select="$locales/locale[@key='womi-movie-label']"/>
			</xsl:when>
			<xsl:when test="$womiType='SOUND'">
				<xsl:value-of select="$locales/locale[@key='womi-sound-label']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$locales/locale[@key='womi-title-label']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@ep:id">
		<xsl:attribute name="data-womi-id" select="number(.)"/>
	</xsl:template>

	<xsl:template match="@ep:instance-id">
		<xsl:attribute name="id" select="."/>
	</xsl:template>
	
	<xsl:template match="ep:related">
		<div class="related">
			<xsl:apply-templates select="ep:reference"/>
		</div>
	</xsl:template>
	
	<xsl:template name="getWomiNumbering">
		<xsl:param name="womiId"/>
		<xsl:param name="womiType"/>
		<xsl:variable name="module_node_id" select="generate-id(ancestor::div[h1|div[contains(@ep:role,'answers')]][last()])"/>
		
		<xsl:choose>
			<xsl:when test="ancestor::node()[@ep:role='gallery']">
				<xsl:value-of select="count(../preceding-sibling::node())+1"/>
			</xsl:when>
			<xsl:when test="ep:getManifestById(number(@ep:id))/engine = 'womi_attachment'">
				<xsl:value-of select="count((preceding::ep:reference|ancestor::ep:reference)
					[generate-id(ancestor::div[h1|div[contains(@ep:role,'answers')]][last()]) = $module_node_id and 
					(not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all' and ep:hide-caption != 'number')) and
					(not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')) and
					ep:getManifestById(number(@ep:id))/engine = 'womi_attachment'])+1"/>
			</xsl:when>
			<xsl:when test="some $x in ('GRAPHICS', 'ICON') satisfies $womiType=$x">
				<xsl:value-of select="count((preceding::ep:reference|ancestor::ep:reference)
					[generate-id(ancestor::div[h1|div[contains(@ep:role,'answers')]][last()]) = $module_node_id and 
					(not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all' and ep:hide-caption != 'number')) and
					(not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')) and
					(some $x in ('GRAPHICS', 'ICON') satisfies ep:getMetadataWomiType(number(@ep:id))=$x) and
					not(ancestor::div[@ep:role='gallery'])
					])+1"/>
			</xsl:when>
			<xsl:when test="$womiType='INTERACTIVE'">
				<xsl:value-of select="count((preceding::ep:reference|ancestor::ep:reference)
					[generate-id(ancestor::div[h1|div[contains(@ep:role,'answers')]][last()]) = $module_node_id and 
					(not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all' and ep:hide-caption != 'number')) and
					(not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')) and
					ep:getMetadataWomiType(number(@ep:id)) = 'INTERACTIVE' and
					(not(ep:getManifestById(number(@ep:id))/engine) or ep:getManifestById(number(@ep:id))/engine != 'womi_attachment') and
					not(ancestor::div[@ep:role='gallery'])
					])+1"/>
			</xsl:when>
			<xsl:when test="$womiType='MOVIE'">
				<xsl:value-of select="count((preceding::ep:reference|ancestor::ep:reference)
					[generate-id(ancestor::div[h1|div[contains(@ep:role,'answers')]][last()]) = $module_node_id and 
					(not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all' and ep:hide-caption != 'number')) and
					(not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')) and
					ep:getMetadataWomiType(number(@ep:id)) = 'MOVIE' and
					not(ancestor::div[@ep:role='gallery'])
					])+1"/>
			</xsl:when>
			<xsl:when test="$womiType='SOUND'">
				<xsl:value-of select="count((preceding::ep:reference|ancestor::ep:reference)
					[generate-id(ancestor::div[h1|div[contains(@ep:role,'answers')]][last()]) = $module_node_id and 
					(not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all' and ep:hide-caption != 'number')) and
					(not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')) and
					ep:getMetadataWomiType(number(@ep:id)) = 'SOUND' and
					not(ancestor::div[@ep:role='gallery'])
					])+1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="count((preceding::ep:reference|ancestor::ep:reference)
					[generate-id(ancestor::div[h1|div[contains(@ep:role,'answers')]][last()]) = $module_node_id and 
					(not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all' and ep:hide-caption != 'number')) and
					(not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')) and
					(not(ep:getManifestById(number(@ep:id))/engine) or ep:getManifestById(number(@ep:id))/engine != 'womi_attachment')])+1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="getModuleId">
		<xsl:variable name="moduleActualId" select="ancestor::div[last()]/@id"/>
		
		<xsl:choose>
			<xsl:when test="contains($moduleActualId, '_answers')">
				<xsl:value-of select="substring-before($moduleActualId,'_answers')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$moduleActualId"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="getHref">
		<xsl:param name="col_id" tunnel="yes"/>
		<xsl:param name="col_md_version" tunnel="yes"/>
		<xsl:param name="col_variant" tunnel="yes"/>
		<xsl:value-of select="concat($www_link, $col_id, '/v/', $col_md_version, '/t/', $col_variant,'/m/')"/>
		<xsl:call-template name="getModuleId"/>
		<xsl:text>#</xsl:text>
		<xsl:value-of select="(ancestor-or-self::element()/(@ep:instance-id|@id))[last()]"/>
	</xsl:template>
	
	<xsl:template name="create_ep_content_static_mobile_app">
		<xsl:if test=".">
			<xsl:element name="div" xmlns="http://www.w3.org/1999/xhtml">
				<xsl:attribute name="class">
					<xsl:text>womi-associated-text</xsl:text>
					<xsl:if test="descendant::node()[local-name()='math' or local-name()='img']">
						<xsl:text> math-included</xsl:text>
					</xsl:if>
					<xsl:if test="descendant::node()[local-name()='entry' and namespace-uri() = 'http://bibtexml.sf.net/']">
						<xsl:text> bib-included</xsl:text>
					</xsl:if>
				</xsl:attribute>				
				<xsl:apply-templates select="node()">
					<xsl:with-param name="copied_reference" tunnel="yes">html</xsl:with-param>
					<xsl:with-param name="namespace" select="'http://www.w3.org/1999/xhtml'" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="set_womi_label_numbering_title">
		<xsl:param name="womiId"/>
		<xsl:param name="womi-label"/>
		<xsl:param name="womi-numbering"/>
		
		<span class="womi-full-title" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:if test="(not(ep:hide-caption) or ep:hide-caption != 'label') and ep:hide-caption != 'title'">
				<span class="womi-label" xmlns="http://www.w3.org/1999/xhtml">
					<xsl:value-of select="$womi-label"/>
					<xsl:choose>
						<xsl:when test="(not(ep:nested or (ep:hide-caption = 'number'))) and ep:hide-caption != 'title'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</span>
			</xsl:if>
			<xsl:if test="(not(ep:nested or (ep:hide-caption = 'number'))) and ep:hide-caption != 'title'">
				<span class="womi-numbering" xmlns="http://www.w3.org/1999/xhtml">
					<xsl:value-of select="$womi-numbering"/>
					<xsl:text>. </xsl:text>
				</span>
			</xsl:if>
			<xsl:if test="ep:getMetadataTitle($womiId) and (not(ep:hide-caption) or ep:hide-caption != 'title')">
				<span class="womi-title" xmlns="http://www.w3.org/1999/xhtml">
					<xsl:value-of select="ep:getMetadataTitle($womiId)"/>
				</span>
			</xsl:if>
		</span>
	</xsl:template>
	
	<xsl:function name="ep:getCoverExtension" as="text()">
		<xsl:param name="womiReferenceId"/>
		<xsl:param name="outputFormat"/>
		
		<xsl:variable name="originalExt" select="substring-after(document(concat('file:///', $womiLocalPath, '/', number($womiReferenceId), '-manifest.json.xml'))//parameters/node()[local-name()=$outputFormat]/mimeType, '/')"/>
		<xsl:variable name="ext" select="lower-case($originalExt)"/>
		<xsl:choose>
			<xsl:when test="contains($ext, 'svg') and ($outputFormat = 'ebook')">
				<xsl:text>png</xsl:text>
			</xsl:when>
			<xsl:when test="contains($ext, 'jpeg')">
				<xsl:text>jpg</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="tokenize($ext,'\+')[1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:template match="ep:nbsp">
		<xsl:text>&#160;</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>
