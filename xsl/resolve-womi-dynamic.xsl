<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ep="http://epodreczniki.pl/"
    exclude-result-prefixes="xs ep" version="2.0">

    <xsl:import href="resolve-womi.xsl"/>

    <xsl:param name="outputFormat" select="''"/>
    <xsl:param name="womiLocalPath" select="''"/>

    <xsl:template match="ep:context|ep:reading-room|ep:hide-caption|ep:embedded|ep:autoplay|ep:transparent|ep:avatar">
        <xsl:if test=". = 'true' or . = 'all'">
            <xsl:value-of select="local-name()"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ep:zoomable">
        <xsl:choose>
            <xsl:when test=". = 'true' or . = 'zoom'">zoomable</xsl:when>
            <xsl:when test=". = 'magnifier'">magnifier</xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="heightRatio" mode="json-parameters">
        <xsl:attribute name="data-height-ratio">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="ep:content">
        <div>
            <xsl:attribute name="class">
                <xsl:text>womi-text-content</xsl:text>                
                <xsl:if test="descendant::node()[local-name()='math']">
                    <xsl:text> math-included</xsl:text>
                </xsl:if>
                <xsl:if test="descendant::node()[local-name()='entry' and namespace-uri() = 'http://bibtexml.sf.net/']">
                    <xsl:text> bib-included</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:attribute name="style" select="'display:none'"/>
            
            <xsl:apply-templates select="node()">
                <xsl:with-param name="copied_reference" tunnel="yes">html</xsl:with-param>
            </xsl:apply-templates>
        </div>
    </xsl:template>
    
    <xsl:template match="newline">
        <xsl:text>&#60;br/&#62;</xsl:text>
    </xsl:template>
    
    <xsl:template match="ep:width|@ep:width">
        <xsl:attribute name="data-width" select="concat(., '%')"/>
    </xsl:template>
    
    <xsl:template match="ep:described-by">
        <xsl:attribute name="data-described-by" select="."/>
    </xsl:template>
    
    <xsl:template match="ep:disabled-alternative-reference">
        <xsl:attribute name="data-disabled-alternative" select="@ep:id"/>
    </xsl:template>
    
    <xsl:template match="ep:reference">
        <xsl:variable name="womiId" select="ep:getWomiId(.)"/>
        <xsl:variable name="imageType" select="ep:getImageType($womiId, 'html', 'classic')"/>
        <xsl:variable name="metadataAlternativeText" select="ep:getMetadataAlternativeText($womiId)"/>
        <xsl:variable name="womi-title" select="ep:getMetadataTitle($womiId)"/>
        <xsl:variable name="womiType" select="ep:getMetadataWomiType($womiId)"/>
        
        <xsl:variable name="womiRemoteUrl">
            <xsl:value-of select="concat('/content/womi/', $womiId, '/', $outputFormat, '.', $imageType)"/>
        </xsl:variable>
        <xsl:variable name="womiMobRemoteUrl">
            <xsl:value-of select="concat('/content/womi/', $womiId, '/', 'mobile', '.', $imageType)"/>
        </xsl:variable>
        <xsl:variable name="womi-roles-list" as="xs:string*">
            <xsl:apply-templates select="ep:context|ep:reading-room|ep:hide-caption|ep:embedded|ep:zoomable|ep:autoplay|ep:transparent|ep:avatar"></xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="womi-roles" select="string-join($womi-roles-list, ',')"/>
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
        <xsl:variable name="womi-numbering-prefix">
            <xsl:value-of select="ep:get_number_prefix(ancestor::div[@id][last()]/@id)"/>
            <xsl:if test="ancestor::node()[@ep:role='gallery']">
                <xsl:text>.</xsl:text>
                <xsl:value-of select="ancestor::node()[@ep:role='gallery']//node()[@ep:role='numbering-element']"></xsl:value-of>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="womi-title-concat">
            <xsl:if test="not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all')">
                <xsl:if test="(not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')) and ep:hide-caption != 'number'">
                    <xsl:value-of select="$womi-label"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$womi-numbering"/>
                    <xsl:text>. </xsl:text>
                </xsl:if>
                <xsl:if test="$womi-title and (not(ep:hide-caption) or ep:hide-caption != 'title')">
                    <xsl:value-of select="$womi-title"></xsl:value-of>
                </xsl:if>
            </xsl:if>
        </xsl:variable>

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
            <xsl:apply-templates select="@ep:instance-id|@ep:id|ep:disabled-alternative-reference"></xsl:apply-templates>
            <xsl:if test="not(ep:hide-caption) or (ep:hide-caption != 'true'  and ep:hide-caption != 'all')">
                <xsl:if test="(not(ep:context) or ep:context != 'true' or (ep:context = 'true' and ep:embedded = 'true')) and ep:hide-caption != 'number'">
                    <xsl:attribute name="data-part-label" select="$womi-label"/>
                    <xsl:attribute name="data-part-numbering-prefix" select="$womi-numbering-prefix"/>
                    <xsl:attribute name="data-part-numbering" select="$womi-numbering"/>
                </xsl:if>
                <xsl:if test="$womi-title and (not(ep:hide-caption) or ep:hide-caption != 'title')">
                    <xsl:attribute name="data-part-title" select="$womi-title"/>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$womi-title-concat != ''">
                <xsl:attribute name="data-title" select="$womi-title-concat"/>
            </xsl:if>
            <xsl:if test="$womi-roles != ''">
                <xsl:attribute name="data-roles" select="$womi-roles"/>
            </xsl:if>
            <xsl:if test="ep:aside">
                <xsl:attribute name="data-aside" select="ep:aside"/>
            </xsl:if>
            <div class="classic">
                <xsl:apply-templates select="ep:content[@ep:format = 'classic']"/>
                <xsl:choose>
                    <xsl:when test="$womiType='GRAPHICS'">
                        <xsl:call-template name="create_image_container">
                            <xsl:with-param name="womiRemoteUrl" select="$womiRemoteUrl"/>
                            <xsl:with-param name="altText" select="$metadataAlternativeText"/>
                        </xsl:call-template>
                        <xsl:if test="$womiType='3D'">
                            <xsl:variable name="womiRemoteUrl3D">
                                <xsl:value-of select="concat($womiId, '/', $outputFormat, '-3d-anaglyph', '.', $imageType)"/>
                            </xsl:variable>
                            <xsl:call-template name="create_image_container">
                                <xsl:with-param name="womiRemoteUrl" select="$womiRemoteUrl3D"/>
                                <xsl:with-param name="altText" select="$metadataAlternativeText"/>
                                <xsl:with-param name="displayMode" select="'3d-anaglyph'"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="$womiType='INTERACTIVE'">
                        <xsl:variable name="geogebraFile" select="concat($womiLocalPath, '/', $womiId, '-geogebra.html')"/>
                        <xsl:variable name="swiffyFile" select="concat($womiLocalPath, '/', $womiId, '-swiffy-preprocessed.html')"/>
                        <xsl:variable name="manifest_node" select="ep:getManifestById($womiId)"></xsl:variable>
                        <xsl:variable name="engineVersion" select="$manifest_node/version"></xsl:variable>
                        <xsl:choose>
                            <xsl:when test="doc-available($geogebraFile)">
                                <div class="interactive-object-container" data-alt="{$metadataAlternativeText}">
                                    <xsl:apply-templates select="ep:width|@ep:width"></xsl:apply-templates>
                                    <div class="resource-included-interactive-object" data-object-engine="geogebra" data-object-engine-version="{$engineVersion}">
                                        <xsl:copy-of select="document($geogebraFile)"/>
                                    </div>
                                    <xsl:call-template name="create_image_container">
                                        <xsl:with-param name="womiRemoteUrl" select="$womiRemoteUrl"/>
                                        <xsl:with-param name="altText" select="$metadataAlternativeText"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:when>
                            <xsl:when test="doc-available($swiffyFile)">
                                <xsl:variable name="w" select="number(substring-before(substring-after(document(concat('file:///', $swiffyFile))/html/body/div[@id = 'swiffycontainer']/@style, 'width: '), 'px'))"/>
                                <xsl:variable name="h" select="number(substring-before(substring-after(document(concat('file:///', $swiffyFile))/html/body/div[@id = 'swiffycontainer']/@style, 'height: '), 'px'))"/>
                                <xsl:variable name="data-height-ratio" select="$h div $w"/>
                                    <div class="interactive-object-container" data-alt="{$metadataAlternativeText}" data-height-ratio="{$data-height-ratio}">
                                        <xsl:apply-templates select="ep:width|@ep:width"></xsl:apply-templates>
                                        <div class="standard-interactive-object" data-object-src="/content/womi/{$womiId}/swiffy.html" 
                                            data-object-engine="swiffy" data-object-engine-version="{$engineVersion}"></div>
                                        <xsl:call-template name="create_image_container">
                                            <xsl:with-param name="womiRemoteUrl" select="$womiRemoteUrl"/>
                                            <xsl:with-param name="altText" select="$metadataAlternativeText"/>
                                        </xsl:call-template>
                                    </div>
                            </xsl:when>
                            <xsl:when test="$manifest_node/engine = 'womi_attachment'">
                                <xsl:variable name="mainFile" select="$manifest_node/mainFile"></xsl:variable>
                                <div class="attachment-container" data-src="/content/womi/{$womiId}/{$mainFile}" data-alt="{$metadataAlternativeText}"></div>
                            </xsl:when>
                            <xsl:when test="$manifest_node">
                                <xsl:variable name="engine" select="$manifest_node/engine"></xsl:variable>
                                <xsl:variable name="mainFile" select="$manifest_node/mainFile"></xsl:variable>
                                <div class="interactive-object-container" data-alt="{$metadataAlternativeText}">
                                    <xsl:apply-templates select="ep:width|@ep:width"></xsl:apply-templates>
                                    <xsl:apply-templates select="$manifest_node/parameters/object/*" mode="json-parameters"></xsl:apply-templates>
                                    <div class="standard-interactive-object" data-object-src="/content/womi/{$womiId}/{$mainFile}" 
                                        data-object-engine="{$engine}" data-object-engine-version="{$engineVersion}"></div>
                                    <xsl:call-template name="create_image_container">
                                        <xsl:with-param name="womiRemoteUrl" select="$womiRemoteUrl"/>
                                        <xsl:with-param name="altText" select="$metadataAlternativeText"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>[xslt] Warning: No content files for INTERACTIVE WOMI: <xsl:value-of select="$womiId"></xsl:value-of></xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$womiType='MOVIE'">
                        <div class="movie-container" data-alt="{$metadataAlternativeText}" data-movie-id="{$womiId}" data-display-mode="2d" data-aspect-ratio="{ep:getMetadataAspectRatio($womiId)}">
                                <xsl:apply-templates select="ep:width|@ep:width"/>
                                <xsl:apply-templates select="ep:described-by"/>
                                <xsl:if test="false()">
                                    <div class="audio-tracks">
                                        <xsl:for-each select=".">
                                            <div data-text="track{position()}" data-value="{position()}"></div>
                                        </xsl:for-each>
                                    </div>
                                </xsl:if>
                                <div class="keyframe" data-src="{$womiRemoteUrl}">
                                    <div data-resolution="480"></div>
                                    <div data-resolution="980"></div>
                                    <div data-resolution="1440"></div>
                                    <div data-resolution="1920"></div>
                                </div>
                            </div>
                    </xsl:when>
                    <xsl:when test="$womiType='ICON'">
                        <xsl:call-template name="create_image_container">
                            <xsl:with-param name="womiRemoteUrl" select="concat('/content/womi/', $womiId, '/icon.', $imageType)"/>
                            <xsl:with-param name="altText" select="$metadataAlternativeText"/>
                            <xsl:with-param name="noscriptRes" select="''"/>
                            <xsl:with-param name="containerType" select="'icon'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$womiType='SOUND'">
                        <div class="audio-container" data-alt="{$metadataAlternativeText}" data-audio-id="{$womiId}"></div>
                    </xsl:when>
                </xsl:choose>
            </div>
            
            <div class="mobile" data-auto="true">
                <xsl:apply-templates select="ep:content[@ep:format = 'mobile']"/>
                <xsl:choose>
                    <xsl:when test="$womiType='INTERACTIVE' and
                                    ep:getManifestById($womiId)/engine = 'womi_attachment'">
                        <xsl:variable name="mainFile" select="ep:getManifestById($womiId)/mainFile"></xsl:variable>
                        <div class="attachment-container" data-src="/content/womi/{$womiId}/{$mainFile}" data-alt="{$metadataAlternativeText}"></div>
                    </xsl:when>
                    <xsl:when test="some $x in ('GRAPHICS','INTERACTIVE','MOVIE') satisfies $womiType=$x">
                        <xsl:call-template name="create_image_container">
                            <xsl:with-param name="womiRemoteUrl" select="$womiMobRemoteUrl"/>
                            <xsl:with-param name="altText" select="$metadataAlternativeText"/>
                            <xsl:with-param name="noscriptRes" select="'480'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$womiType='ICON'">
                        <xsl:call-template name="create_image_container">
                            <xsl:with-param name="womiRemoteUrl" select="concat('/content/womi/', $womiId, '/icon.', $imageType)"/>
                            <xsl:with-param name="altText" select="$metadataAlternativeText"/>
                            <xsl:with-param name="noscriptRes" select="''"/>
                            <xsl:with-param name="containerType" select="'icon'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$womiType='SOUND'">
                        <div class="audio-container" data-alt="{$metadataAlternativeText}" data-audio-id="{$womiId}"></div>
                    </xsl:when>
                </xsl:choose>
            </div>
                
            <xsl:apply-templates select="ep:related"/>
            
        </div>
    </xsl:template>

    <xsl:template name="create_image_container">
        <xsl:param name="womiRemoteUrl"/>
        <xsl:param name="altText"/>
        <xsl:param name="displayMode" select="'2d'"/>
        <xsl:param name="noscriptRes" select="'980'"/>
        <xsl:param name="containerType" select="'image'"/>
        <div class="{$containerType}-container" data-alt="{$altText}" data-display-mode="{$displayMode}">
            <xsl:attribute name="data-src">
                <xsl:choose>
                    <xsl:when test="substring-after($womiRemoteUrl, '.') = '' and contains($womiRemoteUrl, 'classic')">
                        <xsl:value-of select="'/global/libraries/epo/img/splashscreen/classic.svg'"/>
                    </xsl:when>
                    <xsl:when test="substring-after($womiRemoteUrl, '.') = '' and contains($womiRemoteUrl, 'mobile')">
                        <xsl:value-of select="'/global/libraries/epo/img/splashscreen/mobile.svg'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$womiRemoteUrl"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="ep:width|@ep:width"></xsl:apply-templates>
            <xsl:choose>
                <xsl:when test="$noscriptRes = ''">
                    <noscript>
                        <img src="{concat(substring-before($womiRemoteUrl, '.'), '.', substring-after($womiRemoteUrl, '.'))}"
                            alt="{$altText}"/>
                    </noscript>
                </xsl:when>
                <xsl:when test="parent::node()[@ep:role='biography-info' or @ep:role='event-info']">
                    <div data-resolution="480"/>
                    <noscript>
                        <img src="{concat(substring-before($womiRemoteUrl, '.'), '-', '480', '.', substring-after($womiRemoteUrl, '.'))}" alt="{$altText}"/>
                    </noscript>
                </xsl:when>
                <xsl:otherwise>
                    <div data-resolution="480"/>
                    <div data-resolution="980"/>
                    <div data-resolution="1440"/>
                    <div data-resolution="1920"/>
                    <noscript>
                        <img src="{concat(substring-before($womiRemoteUrl, '.'), '-', $noscriptRes, '.', substring-after($womiRemoteUrl, '.'))}"
                             alt="{$altText}"/>
                    </noscript>
                </xsl:otherwise>
            </xsl:choose>

        </div>
    </xsl:template>

</xsl:stylesheet>
