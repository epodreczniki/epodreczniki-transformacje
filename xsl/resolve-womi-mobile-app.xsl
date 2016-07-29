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
		<xsl:attribute name="style" select="concat('width:', ., '%;')"/>
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
		<xsl:param name="glossary_mode" tunnel="yes"/>

		<xsl:variable name="womiId" select="ep:getWomiId(.)"/>
		<xsl:variable name="womiEngine" select="ep:getManifestById($womiId)/engine"/>
		<xsl:variable name="womiType" select="ep:getMetadataWomiType($womiId)"/>
		<xsl:variable name="href">
			<xsl:call-template name="getHref"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')">
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
					</xsl:attribute>
					<xsl:apply-templates select="@ep:instance-id|@ep:id"/>
					<div class="{$outputFormat}">
						<div class="image-container">
							<xsl:choose>
								<xsl:when test="$womiType='GRAPHICS'">
									<xsl:call-template name="create_static_image">
										<xsl:with-param name="epub_format" select="$epub_format"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$womiType='ICON'">
									<xsl:call-template name="create_static_image">
										<xsl:with-param name="epub_format" select="$epub_format"/>
										<xsl:with-param name="set_width" select="'false'"/>
										<xsl:with-param name="with_class" select="'icon'"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$womiType='INTERACTIVE'">
									<xsl:variable name="mainFile" select="ep:getManifestById($womiId)/mainFile"/>
									
									<xsl:choose>
										<xsl:when test="$womiEngine='womi_exercise_engine'">
											<xsl:variable name="jsonFile"
												select="unparsed-text(concat('file:///',$womiLocalPath, '/mobile-app/womi_engine/', $womiId, '/',$mainFile))"/>

											<div class="standard-interactive-object momi" 
												data-object-src="{concat('womi/',$womiId,'/',$mainFile)}"
												data-object-engine="womi_exercise_engine" 
												data-object-engine-name="{tokenize(substring-after(substring-after($jsonFile, 'config'), 'type&quot;:'), '&quot;')[2]}"
												data-object-engine-version="{ep:getManifestById($womiId)/version}"
												data-womi-id="{$womiId}">
												<div class="womi-object-title">
													<xsl:value-of select="$locales/locale[@key='interactive_exercise_title_label']/text()"/>
													<xsl:text>"</xsl:text>
													<xsl:value-of
														select="ep:getwomiExerciseEngineByType(tokenize(substring-after(substring-after($jsonFile, 'config'), 'type&quot;:'), '&quot;')[2])"/>
													<xsl:text>".</xsl:text>
												</div>
												<div class="womi-object-desc">
													<xsl:copy-of select="ep:getWomiObjectDesc($jsonFile,$womiId,$mainFile)"/>
												</div>
												<div class="womi-object-status"/>
												<div style="position: relative;" class="play-div">
													<button class="play-button play-button-interactive-exercise"/>
													<xsl:choose>
														<xsl:when test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, 'mobile')=true()">
															<xsl:call-template name="create_static_image"/>
														</xsl:when>
														<xsl:otherwise>
															<img src="womi/womi_placeholder.svg" alt="{$locales/locale[@key='default_image_alt_text']/text()}"
																id="{concat('img_womi-', @ep:instance-id)}"/>
														</xsl:otherwise>
													</xsl:choose>
												</div>
											</div>
										</xsl:when>
										<xsl:when test="$womiEngine='custom_logic_exercise_womi'">
											<div class="standard-interactive-object momi" data-object-src="womi/{$womiId}/index.html" data-womi-id="{$womiId}" data-object-engine="custom_logic_exercise_womi"
												data-object-engine-version="{ep:getManifestById($womiId)/version}">
												<div class="womi-object-title">
													<xsl:value-of select="$locales/locale[@key='interactive_exercise_title_label']/text()"/>
													<xsl:text>"zadanie generatorowe".</xsl:text>
												</div>
												<div class="womi-object-desc">
													<xsl:value-of select="ep:getManifestById(number($womiId))/offlineTitle"></xsl:value-of>
												</div>
												<div class="womi-object-status"/>
												<div style="position: relative;" class="play-div">
													<button class="play-button play-button-interactive-exercise"/>
													<xsl:choose>
														<xsl:when test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, 'mobile')=true()">
															<xsl:call-template name="create_static_image"/>
														</xsl:when>
														<xsl:otherwise>
															<img src="womi/womi_placeholder.svg" alt="{$locales/locale[@key='default_image_alt_text']/text()}"
																id="{concat('img_womi-', @ep:instance-id)}"/>
														</xsl:otherwise>
													</xsl:choose>
												</div>
											</div>
											<xsl:call-template name="createCustomLogicExWomiIndexFile">
												<xsl:with-param name="womiId" select="$womiId"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="$womiEngine='geogebra'">
											<xsl:variable name="geogebraFile" select="concat($womiLocalPath, '/', $womiId, '-geogebra.html')"/>
											<xsl:if test="doc-available($geogebraFile)">
												<div class="standard-interactive-object momi ge" data-alt="{ep:getMetadataAlternativeText($womiId)}"
													data-object-src="{concat('womi/',$womiId,'/index.html')}" data-object-engine="geogebra"
													data-object-engine-version="{ep:getManifestById($womiId)/version}" data-womi-id="{$womiId}">
													<div class="womi-object-title">
														<xsl:value-of select="$locales/locale[@key='interactive_exercise_title_label']/text()"/>
														<xsl:text>"geogebra".</xsl:text>
													</div>
													<div class="womi-object-desc"/>
													<div class="womi-object-status"/>
													<div style="position: relative;" class="play-div">
														<button class="play-button play-button-interactive-exercise"/>
														<xsl:choose>
															<xsl:when test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, 'mobile')=true()">
																<xsl:call-template name="create_static_image"/>
															</xsl:when>
															<xsl:otherwise>
																<img src="womi/womi_placeholder.svg" alt="{$locales/locale[@key='default_image_alt_text']/text()}"
																	id="{concat('img_womi-', @ep:instance-id)}"/>
															</xsl:otherwise>
														</xsl:choose>
													</div>
												</div>

												<xsl:call-template name="createWomiGeogebraMainFile">
													<xsl:with-param name="geogebraFile" select="$geogebraFile"/>
													<xsl:with-param name="womiId" select="$womiId"/>
												</xsl:call-template>
											</xsl:if>
										</xsl:when>
										<xsl:when test="$womiEngine='custom_womi'">
											<xsl:choose>
												<xsl:when test="not(unparsed-text-available(concat($womiLocalPath,'/mobile-app/womi_engine/',$womiId,'/index.html')))">
													<xsl:message>[XSLT_ERR] BRAK PLIKU INDEX.HTML DLA WOMI: <xsl:value-of select="$womiId"/></xsl:message>
													<xsl:choose>
														<xsl:when test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, 'mobile')=true()">
															<xsl:call-template name="create_static_image"/>
														</xsl:when>
														<xsl:otherwise>
															<span class="womi-link">
																<xsl:call-template name="create_womi_link_content">
																	<xsl:with-param name="href" select="$href"/>
																	<xsl:with-param name="womiEngine" select="$womiEngine"/>
																</xsl:call-template>
															</span>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													<div class="standard-interactive-object momi" data-object-src="womi/{$womiId}/index2.html" data-object-engine="custom_womi"
													data-object-engine-version="{ep:getManifestById($womiId)/version}" data-womi-id="{$womiId}">
														<div class="womi-object-title">
															<xsl:value-of select="$locales/locale[@key='interactive_exercise_title_label']/text()"/>
															<xsl:text>.</xsl:text>
														</div>
														<div class="womi-object-desc">
														</div>
														<div class="womi-object-status"/>
														<div style="position: relative;" class="play-div">
															<button class="play-button play-button-interactive-exercise"/>
															<xsl:choose>
																<xsl:when test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, 'mobile')=true()">
																	<xsl:call-template name="create_static_image"/>
																</xsl:when>
																<xsl:otherwise>
																	<img src="womi/womi_placeholder.svg" alt="{$locales/locale[@key='default_image_alt_text']/text()}"
																		id="{concat('img_womi-', @ep:instance-id)}"/>
																</xsl:otherwise>
															</xsl:choose>
														</div>
													</div>
													<xsl:call-template name="createWomiCustomMainFile">
														<xsl:with-param name="womiId" select="$womiId"/>
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:when test="$womiEngine='processingjs_animation'">
											<div class="standard-interactive-object momi" data-object-src="womi/{$womiId}/main.html" data-object-engine="{$womiEngine}" data-object-engine-version="{ep:getManifestById($womiId)/version}" data-womi-id="{$womiId}">
												<div class="womi-object-title">
													<xsl:value-of select="$locales/locale[@key='interactive_exercise_title_label']/text()"/>
													<xsl:text>"OEIiZK".</xsl:text>
												</div>
												<div class="womi-object-desc">
												</div>
												<div class="womi-object-status"></div>
												<div style="position: relative;" class="play-div">
													<button class="play-button play-button-interactive-exercise"></button>
													<xsl:choose>
														<xsl:when test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, 'mobile')=true()">
															<xsl:call-template name="create_static_image"/>
														</xsl:when>
														<xsl:otherwise>
															<img src="womi/womi_placeholder.svg" alt="{$locales/locale[@key='default_image_alt_text']/text()}"
																id="{concat('img_womi-', @ep:instance-id)}"/>
														</xsl:otherwise>
													</xsl:choose>
												</div>
											</div>
											<xsl:call-template name="createWomiOezikMainFile">
												<xsl:with-param name="womiId" select="$womiId"/>
												<xsl:with-param name="mainFile" select="$mainFile"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, 'mobile') = true()">
											<xsl:choose>
												<xsl:when test="every $x in ('womi_exercise_engine','custom_logic_exercise_womi', 'geogebra','custom_womi','processingjs_animation') 
													satisfies $womiEngine!=$x">
													<xsl:call-template name="create_static_image"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:element name="a">
														<xsl:attribute name="href" select="$href"/>
														<xsl:call-template name="create_static_image">
															<xsl:with-param name="epub_format" select="$epub_format"/>
														</xsl:call-template>
													</xsl:element>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="$womiType='MOVIE'">
									<span class="womi-multimedia-warning">
										<xsl:value-of select="$locales/locale[@key='womi-multimedia-warning']/text()"/>
									</span>
									<div class="media-player" id="movie-{generate-id(.)}" data-mediatype="video" data-mid="{$womiId}"
										data-aspectratio="{ep:getMetadataAspectRatio($womiId)}">
										<xsl:attribute name="data-poster">
											<xsl:choose>
												<xsl:when test="ep:getImageType($womiId, $outputFormat, 'mobile') != ''">
													<xsl:value-of select="concat('womi/', $womiId, '.', ep:getImageType($womiId, $outputFormat, 'mobile'))"/>		
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="'womi/womi_placeholder.svg'"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
									</div>
								</xsl:when>
								<xsl:when test="$womiType='SOUND'">
									<span class="womi-multimedia-warning">
										<xsl:value-of select="$locales/locale[@key='womi-multimedia-warning']/text()"/>
									</span>
									<img class="media-player" src="womi/icon-womi-sound.svg" id="sound-{generate-id(.)}" data-mediatype="simple-audio" data-mid="{$womiId}"/>
								</xsl:when>
							</xsl:choose>
						</div>

						<xsl:if
							test="(ep:checkIfWomiHasStaticAlternativeByWomiId($womiId, 'mobile') = true()
									or $womiType='ICON') 
								and not($glossary_mode) 
								and (not(exists($womiEngine)) or (every $x in ('womi_exercise_engine','custom_logic_exercise_womi', 'womi_attachment', 'geogebra', 'custom_womi', 'processingjs_animation') satisfies not(contains($womiEngine,$x))))  
								and (every $x in ('MOVIE', 'SOUND') satisfies $womiType!=$x)">
							<div class="womi-details">
								<button class="button zoom-img" title="{$locales/locale[@key='button_zoom_img']}">
									<xsl:attribute name="onclick">
										<xsl:text>openImage(</xsl:text>
										<xsl:text>event, '</xsl:text>
										<xsl:value-of select="concat('womi/',$womiId, '.', ep:getImageType($womiId, $outputFormat, 'mobile'))"/>
										<xsl:text>', '</xsl:text>
										<xsl:value-of select="concat('img_womi-', @ep:instance-id)"/>
										<xsl:text>')</xsl:text>
									</xsl:attribute>
									<xsl:attribute name="type" select="'button'"/>
								</button>
							</div>
						</xsl:if>

						<xsl:call-template name="createWomiCapitonAndAltermativeText">
							<xsl:with-param name="womiId" select="$womiId"/>
							<xsl:with-param name="womiType" select="$womiType"/>
						</xsl:call-template>

						<xsl:apply-templates select="ep:related"/>
					</div>
				</div>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="ep:removeHtmlEntities">
		<xsl:param name="data"/>
		<xsl:choose>
			<xsl:when test="contains($data,'&lt;')">
				<xsl:value-of select="substring-before($data,'&lt;')"/>
				<xsl:call-template name="ep:removeHtmlEntities">
					<xsl:with-param name="data" select="substring-after($data,'&gt;')"></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$data"></xsl:value-of>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:function name="ep:getWomiObjectDesc">
		<xsl:param name="jsonFile"/>
		<xsl:param name="womiId"/>
		<xsl:param name="mainFile"/>
		
		<xsl:variable name="tmp">
			<xsl:value-of select="replace($jsonFile,'(&lt;br/&gt;)|(&lt;img).*(/&gt;)', '')"></xsl:value-of>
		</xsl:variable>
		<xsl:variable name="sourceDesc" select="tokenize(substring-after(substring-after(replace($tmp,'(\s){2,}', ' '), 'description'), 'content&quot;:'), '&quot;')[2]"></xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($sourceDesc, '&lt;math')">
				<xsl:variable name="jsonFileMathAsImg"
					select="unparsed-text(concat('file:///',$womiLocalPath_modifyWomi,'/', $womiId, '/',$mainFile))"/>
				<xsl:variable name="sourceDesc2" select="tokenize(substring-after(substring-after($jsonFileMathAsImg, '&quot;description&quot;'),'&quot;content&quot;: &quot;'), '&quot;,')[1]"/>
				<xsl:variable name="sourceToRemoveHtml">
					<xsl:for-each select="tokenize($sourceDesc2,'&lt;img class=\\&quot;ex-')">
						<xsl:choose> 
							<xsl:when test="position()=1">
								<xsl:value-of select="."/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>var_img_mathml</xsl:text>
								<xsl:value-of select="substring-after(.,'pt\&quot;/>')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				
				<xsl:variable name="mathmlData">
					<xsl:for-each select="tokenize($sourceDesc2,'&lt;img class=\\&quot;ex-')">
						<xsl:if test="position()>1">
							<xsl:value-of select="'class=\\&quot;ex-'"/>
							<xsl:value-of select="substring-before(.,'pt\&quot;/>')"/>
							<xsl:value-of select="'pt\&quot;'"/>
							<xsl:text>_;_</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="mathDataTokens" select="tokenize($mathmlData, '_;_')"/>
				
				<xsl:variable name="descTmp" select="ep:getDescWithoutHtml($sourceToRemoveHtml)"/>
				<xsl:for-each select="tokenize($descTmp, 'var_img_mathml')">
					<xsl:choose> 
						<xsl:when test="position()=1">
							<xsl:value-of select="."/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="img">
								<xsl:variable name="imgPosition" select="position()-1"></xsl:variable>
								<xsl:for-each select="tokenize(replace($mathDataTokens[$imgPosition], '\\',''), '&quot; ')">
									<xsl:variable name="tokItem" select="tokenize(.,'=&quot;')"/>
									<xsl:attribute name="{$tokItem[1]}" select="$tokItem[2]"/>
								</xsl:for-each>
							</xsl:element>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="ep:getDescWithoutHtml($sourceDesc)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ep:getDescWithoutHtml">
		<xsl:param name="sourceDesc"/>
		
		<xsl:variable name="desc">
			<xsl:call-template name="ep:removeHtmlEntities">
				<xsl:with-param name="data" select="$sourceDesc"></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="descAfterMathFilter">
			<xsl:choose>
				<xsl:when test="contains($desc, '&lt;math')">
					<xsl:variable name="desc_cutMath" select="substring-before($desc,'&lt;math')"/>
					<xsl:variable name="desc_cutSpecCharAtTheEnd" select="replace($desc_cutMath,'\s*[(\[]$',' ')"/>
					<xsl:variable name="apos" select='"&apos;"'/>
					<xsl:choose>
						<xsl:when test="contains($desc_cutSpecCharAtTheEnd,$apos)">
							<xsl:value-of select="concat(substring-before($desc_cutSpecCharAtTheEnd,$apos),'...')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($desc_cutSpecCharAtTheEnd,'...')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$desc"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:value-of select="replace($descAfterMathFilter,'\s*&lt;[a-z]+>(.*&lt;/[a-z]+>)*\s*',' ')"></xsl:value-of>
	</xsl:function>

	<xsl:template name="createWomiCapitonAndAltermativeText">
		<xsl:param name="womiId"/>
		<xsl:param name="womiType"/>
		<xsl:param name="isGalleryElement" tunnel="yes" as="xs:integer" select="0"/>
		<xsl:variable name="womiEngine" select="ep:getManifestById($womiId)/engine"/>

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

		<xsl:variable name="href">
			<xsl:call-template name="getHref"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when
				test="(not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all'))">
				<div class="womi-caption">
					<xsl:call-template name="set_womi_label_numbering_title">
						<xsl:with-param name="womiId" select="$womiId"/>
						<xsl:with-param name="womi-label" select="$womi-label"/>
						<xsl:with-param name="womi-numbering" select="$womi-numbering"></xsl:with-param>
					</xsl:call-template>

					<xsl:if
						test="$womiType='INTERACTIVE' and (every $x in ('womi_exercise_engine','custom_logic_exercise_womi', 'geogebra', 'custom_womi','processingjs_animation') satisfies $womiEngine!=$x)">
						<span class="newline">
							<br/>
						</span>
						<span class="womi-link">
							<xsl:text> (</xsl:text>
							<xsl:call-template name="create_womi_link_content">
								<xsl:with-param name="href" select="$href"/>
								<xsl:with-param name="womiEngine" select="$womiEngine"/>
							</xsl:call-template>
							<xsl:text>)</xsl:text>
						</span>
					</xsl:if>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if
					test="$womiType='INTERACTIVE' and (every $x in ('womi_exercise_engine','custom_logic_exercise_womi', 'geogebra', 'custom_womi','processingjs_animation') satisfies $womiEngine!=$x)">
					<span class="womi-link">
						<xsl:call-template name="create_womi_link_content">
							<xsl:with-param name="href" select="$href"/>
							<xsl:with-param name="womiEngine" select="$womiEngine"/>
						</xsl:call-template>
					</span>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates select="ep:content[@ep:format = 'mobile']"/>
	</xsl:template>
	
	<xsl:template name="create_womi_link_content">
		<xsl:param name="href"/>
		<xsl:param name="womiEngine"/>
		
		<xsl:element name="a">
			<xsl:attribute name="href" select="$href"/>
			<xsl:attribute name="target" select="'_blank'"/>
			<xsl:choose>
				<xsl:when test="$womiEngine = 'womi_attachment'">
					<xsl:value-of select="$locales/locale[@key='attachment_womi_link_label']/text()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$locales/locale[@key='interactive_exercise_link_label']/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template name="create_static_image">
		<xsl:param name="epub_format"/>
		<xsl:param name="set_width" select="'true'"/>
		<xsl:param name="with_class" select="''"/>
		<xsl:param name="isGalleryElement" tunnel="yes" as="xs:integer" select="0"/>

		<xsl:variable name="womiId" select="ep:getWomiId(.)"/>
		<xsl:variable name="womiUrl">
			<xsl:choose>
				<xsl:when test="$outputFormat = 'mobile_app'">
					<xsl:value-of select="concat('womi/', $womiId, '.', ep:getImageType($womiId, $outputFormat, 'mobile'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes" select="concat('[XSLT_ERR] ',$outputFormat, ' is unknown')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<img alt="{ep:getMetadataAlternativeText($womiId)}" id="{concat('img_womi-', @ep:instance-id)}">
			<xsl:if test="$with_class != ''">
				<xsl:attribute name="class" select="$with_class"/>
			</xsl:if>
			<xsl:if test="./ep:width and $set_width = 'true'">
				<xsl:apply-templates select="./ep:width"/>
			</xsl:if>
			<xsl:if test="$isGalleryElement = 1">
				<xsl:attribute name="data-heightRatio" select="ep:getManifestById($womiId)/parameters/pdf/heightRatio"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="ancestor::node()[local-name()= 'div' and @ep:role='gallery-contents']">
					<xsl:attribute name="data-src" select="$womiUrl"></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="src" select="$womiUrl"></xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</img>
	</xsl:template>
	
	<xsl:template name="createWomiGeogebraMainFile">
		<xsl:param name="geogebraFile"/>
		<xsl:param name="womiId"/>
		
		<xsl:variable name="pathFileIndex" select="concat('file:///',$resultDir,'/womi/',$womiId,'/index.html')"/>
		<xsl:if test="not(unparsed-text-available($pathFileIndex))">
			<xsl:variable name="geoData" select="document($geogebraFile)"/>
			<xsl:result-document method="html" version="5.0" encoding="UTF-8" indent="no" href="{$pathFileIndex}">
				<xsl:element name="html" xmlns="http://www.w3.org/1999/xhtml">
						<head>
							<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
							<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
							<script type="text/javascript" src="./../../js/device/device.js"/>
							<script type="text/javascript">
							window.require =
							{ baseUrl: "./../../js" }
						</script>
							<script data-main="configs/geogebra_launcher_config.js" src="./../../js/libs/require.js"/>
							<style>
								html,
								body
								{
								    height:100%;
								    width:100%;
								    margin:0;
								    padding:0;
								    overflow:hidden;
								}
								iframe
								{
								    width:100%;
								    height:100%;
								    border:none;
								    transform-origin:0 0;
								    -webkit-transform-origin:0 0;
								    -ms-transform-origin:0 0;
								    overflow:hidden;
								}</style>
						</head>
						<body>
							<script type="text/javascript">var parameters =
							{<xsl:text>"width":</xsl:text>
							<xsl:value-of select="$geoData/article/@data-param-width"/>
							<xsl:text>,"height":</xsl:text>
							<xsl:value-of select="$geoData/article/@data-param-height"/>
							}
							;</script>
							<iframe src=""/>
						</body>
				</xsl:element>
			</xsl:result-document>
			
			
			<xsl:variable name="pathFileGeogebra" select="concat('file:///',$resultDir,'/womi/',$womiId,'/geogebra.html')"/>
			<xsl:if test="not(unparsed-text-available($pathFileGeogebra))">
				<xsl:result-document method="html" version="5.0" encoding="UTF-8" indent="no" href="{$pathFileGeogebra}">
					<xsl:element name="html" xmlns="http://www.w3.org/1999/xhtml">
						<head>
							<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
							<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
							<script type="text/javascript" src="./../../js/3rdparty/geogebra/deployggb.js"/>
							<script type="text/javascript" src="./../../js/device/device.js"/>
							<script type="text/javascript">
							window.require =
							{ baseUrl: "./../../js" }
						</script>
							<script data-main="configs/geogebra_config.js" src="./../../js/libs/require.js"/>
							<style>
								html,
								body
								{
								    overflow:hidden;
								    margin:0;
								    -ms-touch-action:none;
								    touch-action:none;
								}
								article
								{
								    -ms-touch-action:none;
								    touch-action:none;
								}
								#applet_container
								{
								    -ms-touch-action:none;
								    touch-action:none;
								}</style>
						</head>
						<body>
							<div class="geogebra_display">
								<script type="text/javascript">
								<xsl:text>var parameters = {"width":</xsl:text>
								<xsl:value-of select="$geoData/article/@data-param-width"/>
								<xsl:text>,"height":</xsl:text>
								<xsl:value-of select="$geoData/article/@data-param-height"/>
								<xsl:text>,"showToolBar":false,"showMenuBar":false,"showAlgebraInput":false,"showResetIcon":false,"enableLabelDrags":false,"enableShiftDragZoom":true,"enableRightClick":false,"showToolBarHelp":false,"errorDialogsActive":true,"useBrowserForJS":false,"ggbBase64":"</xsl:text>
								<xsl:value-of select="$geoData/article/@data-param-ggbbase64"/>
								<xsl:text>","language":"en","isPreloader":false,"screenshotGenerator":false,"preventFocus":false,"fixApplet":false,"borderColor":"#FFFFFF"};</xsl:text>
							</script>

								<div id="applet_container"/>
							</div>
						</body>
					</xsl:element>
				</xsl:result-document>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="createWomiOezikMainFile">
		<xsl:param name="womiId"/>
		<xsl:param name="mainFile"/>
		<xsl:variable name="filePath" select="concat('file:///',$resultDir,'/womi/',$womiId,'/main.html')"/>
		<xsl:if test="not(unparsed-text-available($filePath))">
			<xsl:result-document method="html" version="5.0" encoding="UTF-8" indent="no" href="{$filePath}">
				<xsl:element name="html" xmlns="http://www.w3.org/1999/xhtml">
					<head>
						<meta name="viewport" content="user-scalable=no, initial-scale=1,maximum-scale=1"/>
						<style>
							body{
							    touch-action:none;
							    margin:0px;
							}</style>
						<script src="./../../js/libs/jquery-1.11.1.min.js" type="text/javascript"/>
						<script type="text/javascript">
							var cWidth;
							var CHeight;
							var resize = function(){
							$("#oezik_frame").width(cWidth);
							$("#oezik_frame").height(cHeight);
							var wWidth = $(window).width();
							var wHeight = $(window).height();
							var scaleX = wWidth/cWidth;
							var scaleY = wHeight/cHeight;
							var scale = Math.min(scaleX,scaleY);
							$("#oezik_frame").css("transform-origin","0 0");
							$("#oezik_frame").css("transform","scale("+scale+")");
							};
							
							$(window).on("message",function(e){
							cWidth = e.originalEvent.data[0];
							cHeight = e.originalEvent.data[1];
							resize();
							$(window).on("resize",resize); 
							});
						</script>
					</head>
					<body>
						<iframe id="oezik_frame" src="{$mainFile}"/>
					</body>
				</xsl:element>
			</xsl:result-document>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="createWomiCustomMainFile">
		<xsl:param name="womiId"/>
		<xsl:variable name="filePath" select="concat('file:///',$resultDir,'/womi/',$womiId,'/index2.html')"/>
		<xsl:if test="not(unparsed-text-available($filePath))">
			<xsl:result-document method="html" version="5.0" encoding="UTF-8" indent="no" href="{$filePath}" doctype-public="DOCTYPE html">
				<html>
					<xsl:attribute name="lang" select="'pl'"/>
					<xsl:attribute name="class" select="'cp-game'"/>
					<head>
						<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
						<meta name="format-detection" content="telephone=no"/>
						<meta name="viewport" content="user-scalable=yes, initial-scale=1, minimum-scale=1"/>
						<meta name="apple-mobile-web-app-capable" content="yes"/>
						<meta name="viewport" content="initial-scale=1,maximum-scale=1,minimum-scale=1,user-scalable=no"/>
						<title/>

						<script type="text/javascript">
						if (window.require === undefined) {
						window.require = {
						baseUrl: "../../js"
						}
						}
					</script>
						<script data-main="configs/custom_womi_config.js" src="../../js/libs/require.js"> </script>
						<script>
						
					</script>
					</head>
					<body/>
				</html>
			</xsl:result-document>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="createCustomLogicExWomiIndexFile">
		<xsl:param name="womiId"/>
		<xsl:variable name="filePath" select="concat('file:///',$resultDir,'/womi/',$womiId,'/index.html')"/>
		<xsl:if test="not(unparsed-text-available($filePath))">
			<xsl:result-document method="html" version="5.0" encoding="UTF-8" indent="no" href="{$filePath}" doctype-public="DOCTYPE html">
				<html>
					<head>
						<title>Generatorowe</title>
						<meta charset="UTF-8"/>
						<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
						<script type="text/javascript" src="../../js/device/device.js"/>
						<script type="text/javascript"> 
								window.require = { baseUrl: "./../../js" } 
							</script>
						<script data-main="configs/generator_config.js" src="../../js/libs/require.js"/>
						<link rel="stylesheet" type="text/css" href="../../mobile_app.css"/>
					</head>
					<body>
						<div class="standard-interactive-object momi" data-object-src="womi/{$womiId}/offline_womi" data-womi-id="{$womiId}" data-object-engine="custom_logic_exercise_womi_run"
							data-object-engine-version="0.1"/>
					</body>
				</html>
			</xsl:result-document>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
