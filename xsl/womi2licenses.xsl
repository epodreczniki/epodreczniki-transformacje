<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:col="http://cnx.rice.edu/collxml" xmlns:cn="http://cnx.rice.edu/cnxml" xmlns:ep="http://epodreczniki.pl/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:dlibra_avs="http://epodreczniki.pcss.pl/repo/" xmlns:q="http://cnx.rice.edu/qml/1.0" exclude-result-prefixes="xs" version="2.0">

    <xsl:param name="womiLocalPath" select="''"/>

    <xsl:variable name="womi_ids" as="node()*">
        <xsl:variable name="cover_id" select="//ep:cover"/>
        <xsl:for-each
            select="$modules/cn:documents/cn:document/cn:content//ep:reference[not(ancestor::*[self::cn:solution or self::cn:commentary[not(@type)] or self::q:answer[contains(../q:key/@answer, @id)] or q:feedback[not(ep:section)]])]">
            <xsl:variable name="generated_type" select="ancestor::cn:document/cn:metadata//ep:generated-type/text()"/>
            <xsl:variable name="main_womi_id" select="number(@ep:id)"/>
            <xsl:variable name="module_id">
                <xsl:choose>
                    <xsl:when test="ancestor::cn:document/cn:metadata//ep:generated-type">
                        <xsl:value-of select="ep:getModuleIdByGlossaryType($glossaryModule/element[@key=$generated_type])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ancestor::cn:document/@id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="main_subcollection_id" select="generate-id($collxml/col:collection/col:content/col:subcollection[descendant::col:module/@document=$module_id])"></xsl:variable>
            <xsl:if test="position() = 1 and $cover_id != ''">
                <xsl:element name="womi">
                    <xsl:attribute name="id" select="$cover_id"/>
                    <xsl:attribute name="module_id" select="($modules/cn:documents/cn:document)[1]/@id"/>
                    <xsl:attribute name="subcollection_id" select="$main_subcollection_id"/>
                    <xsl:attribute name="cover" select="'true'"/>
                </xsl:element>
            </xsl:if>
            <xsl:element name="womi">
                <xsl:attribute name="id" select="$main_womi_id"/>
                <xsl:attribute name="module_id" select="$module_id"/>
                <xsl:attribute name="subcollection_id" select="$main_subcollection_id"/>
            </xsl:element>
            <xsl:if test="doc-available(concat($womiLocalPath, '/', $main_womi_id, '-', 'pdf', '-content.html'))">
                <xsl:for-each select="document(concat($womiLocalPath, '/', $main_womi_id, '-', 'pdf', '-content.html'))//img">
                    <xsl:variable name="nested_img_id">
                        <xsl:choose>
                            <xsl:when test="@data-image-id">
                                <xsl:value-of select="concat($main_womi_id, '-', number(@data-image-id), '-pdf')"/>
                            </xsl:when>
                            <xsl:when test="@data-womi-id">
                                <xsl:value-of select="number(@data-womi-id)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="womi">
                        <xsl:attribute name="id" select="$nested_img_id"/>
                        <xsl:attribute name="module_id" select="$module_id"/>
                        <xsl:attribute name="format" select="'pdf'"/>
                        <xsl:attribute name="subcollection_id" select="$main_subcollection_id"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="doc-available(concat($womiLocalPath, '/', $main_womi_id, '-', 'ebook', '-content.html'))">
                <xsl:for-each select="document(concat($womiLocalPath, '/', $main_womi_id, '-', 'ebook', '-content.html'))//img">
                    <xsl:variable name="nested_img_id">
                        <xsl:choose>
                            <xsl:when test="@data-image-id">
                                <xsl:value-of select="concat($main_womi_id, '-', number(@data-image-id), '-ebook')"/>
                            </xsl:when>
                            <xsl:when test="@data-womi-id">
                                <xsl:value-of select="number(@data-womi-id)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="womi">
                        <xsl:attribute name="id" select="$nested_img_id"/>
                        <xsl:attribute name="module_id" select="$module_id"/>
                        <xsl:attribute name="format" select="'ebook'"/>
                        <xsl:attribute name="subcollection_id" select="$main_subcollection_id"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each
            select="$modules/cn:documents/cn:document/cn:content//ep:reference[ancestor::*[self::cn:solution or self::cn:commentary[not(@type)] or self::q:answer[contains(../q:key/@answer, @id)] or self::q:feedback[not(ep:section)]]
            or doc-available(concat($womiLocalPath, '/', number(@ep:id), '-', 'pdf', '-solution.html')) or doc-available(concat($womiLocalPath, '/', number(@ep:id), '-', 'ebook', '-solution.html')) ]">
            <xsl:variable name="main_womi_id" select="number(@ep:id)"/>
            <xsl:variable name="module_id" select="ancestor::cn:document/@id"/>
            <xsl:variable name="main_subcollection_id" select="generate-id($collxml/col:collection/col:content/col:subcollection[descendant::col:module/@document=$module_id])"></xsl:variable>
            <xsl:element name="womi">
                <xsl:attribute name="id" select="$main_womi_id"/>
                <xsl:attribute name="module_id" select="$module_id"/>
                <xsl:attribute name="solution" select="'true'"/>
                <xsl:attribute name="subcollection_id" select="$main_subcollection_id"/>
            </xsl:element>
            <xsl:if test="doc-available(concat($womiLocalPath, '/', $main_womi_id, '-', 'pdf', '-solution.html'))">
                <xsl:for-each select="document(concat($womiLocalPath, '/', $main_womi_id, '-', 'pdf', '-solution.html'))//img">
                    <xsl:variable name="nested_img_id">
                        <xsl:choose>
                            <xsl:when test="@data-image-id">
                                <xsl:value-of select="concat($main_womi_id, '-', number(@data-image-id), '-pdf')"/>
                            </xsl:when>
                            <xsl:when test="@data-womi-id">
                                <xsl:value-of select="number(@data-womi-id)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="womi">
                        <xsl:attribute name="id" select="$nested_img_id"/>
                        <xsl:attribute name="module_id" select="$module_id"/>
                        <xsl:attribute name="format" select="'pdf'"/>
                        <xsl:attribute name="solution" select="'true'"/>
                        <xsl:attribute name="subcollection_id" select="$main_subcollection_id"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="doc-available(concat($womiLocalPath, '/', $main_womi_id, '-', 'ebook', '-solution.html'))">
                <xsl:for-each select="document(concat($womiLocalPath, '/', $main_womi_id, '-', 'ebook', '-solution.html'))//img">
                    <xsl:variable name="nested_img_id">
                        <xsl:choose>
                            <xsl:when test="@data-image-id">
                                <xsl:value-of select="concat($main_womi_id, '-', number(@data-image-id), '-ebook')"/>
                            </xsl:when>
                            <xsl:when test="@data-womi-id">
                                <xsl:value-of select="number(@data-womi-id)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="womi">
                        <xsl:attribute name="id" select="$nested_img_id"/>
                        <xsl:attribute name="module_id" select="$module_id"/>
                        <xsl:attribute name="format" select="'ebook'"/>
                        <xsl:attribute name="solution" select="'true'"/>
                        <xsl:attribute name="subcollection_id" select="$main_subcollection_id"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
        
        <xsl:for-each
            select="$modules/cn:documents/cn:document/cn:content//ep:reference">
            <xsl:variable name="generated_type" select="ancestor::cn:document/cn:metadata//ep:generated-type/text()"/>
            <xsl:variable name="main_womi_id" select="number(@ep:id)"/>
            <xsl:variable name="module_id">
                <xsl:choose>
                    <xsl:when test="ancestor::cn:document/cn:metadata//ep:generated-type">
                        <xsl:value-of select="ep:getModuleIdByGlossaryType($glossaryModule/element[@key=$generated_type])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ancestor::cn:document/@id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="main_subcollection_id" select="generate-id($collxml/col:collection/col:content/col:subcollection[descendant::col:module/@document=$module_id])"></xsl:variable>
            <xsl:element name="womi">
                <xsl:attribute name="id" select="$main_womi_id"/>
                <xsl:attribute name="module_id" select="$module_id"/>
                <xsl:attribute name="subcollection_id" select="$main_subcollection_id"/>
                <xsl:attribute name="format" select="'mobile_app'"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="metadata_files">
        <xsl:for-each-group select="$womi_ids" group-by="@id">
            <xsl:copy-of select="document(concat($womiLocalPath, '/', @id, '-metadata2.xml'))/metadata"/>
        </xsl:for-each-group>
    </xsl:variable>
    
    <xsl:function name="ep:get_metadata_file_by_id">
        <xsl:param name="id"/>
        <xsl:copy-of select="document(concat($womiLocalPath, '/', $id, '-metadata2.xml'))/metadata"/>
    </xsl:function>

    <xsl:variable name="manifest_files">
        <xsl:for-each-group select="$womi_ids" group-by="@id">
            <xsl:variable name="womi_manifest_json" select="doc-available(concat($womiLocalPath, '/', @id, '-manifest.json.xml'))"></xsl:variable>
            
            <xsl:if test="$womi_manifest_json">
                <xsl:element name="manifest">
                    <xsl:variable name="womi_manifest" select="document(concat($womiLocalPath, '/', @id, '-manifest.json.xml'))"/>

                    <xsl:attribute name="id" select="@id"/>
                    <xsl:attribute name="engine" select="$womi_manifest//engine"/>

                    <xsl:if test="$womi_manifest//womiIds">
                        <womiIds>
                            <xsl:copy-of select="$womi_manifest//womiIds"/>
                        </womiIds>
                    </xsl:if>
                    
                    <xsl:if test="not(empty($womi_manifest//parameters/node()))">
                        <xsl:if
                            test="contains($womi_manifest//parameters/pdf/mimeType, 'image')
                        and contains($womi_manifest//parameters/ebook/mimeType, 'image')
                        and contains($womi_manifest//parameters/mobile/mimeType, 'image')">
                            <mimeType_all>image</mimeType_all>
                        </xsl:if>

                        <mimeType_pdf>
                            <xsl:value-of select="substring-before($womi_manifest//parameters/pdf/mimeType, '/')"/>
                        </mimeType_pdf>
                        <mimeType_ebook>
                            <xsl:value-of select="substring-before($womi_manifest//parameters/ebook/mimeType, '/')"/>
                        </mimeType_ebook>
                        <mimeType_mobile>
                            <xsl:value-of select="substring-before($womi_manifest//parameters/mobile/mimeType, '/')"/>
                        </mimeType_mobile>
                    </xsl:if>
                </xsl:element>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="womi_image_metadata_info">
        <xsl:if test="$womi_ids[1]/@cover = 'true'">
            <xsl:call-template name="createWomiElement">
                <xsl:with-param name="curr" select="$womi_ids[1]"/>
            </xsl:call-template>
            <xsl:call-template name="createWomiElement">
                <xsl:with-param name="curr" select="$womi_ids[1]"/>
                <xsl:with-param name="format" select="'mobile_app'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:for-each select="$womi_ids">
            <xsl:variable name="curr" select="."></xsl:variable>
            <xsl:variable name="womi_id" select="@id"/>
            <xsl:variable name="currManifest" select="$manifest_files/manifest[@id = $womi_id]"></xsl:variable>            
            <xsl:variable name="womiEngine" select="$currManifest/@engine"></xsl:variable>
            
            <xsl:if test="not(position() =1 and @cover = 'true') and $currManifest">
                <xsl:variable name="format" select="@format"></xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="@format='mobile_app'">
                        <xsl:if
                            test="($currManifest/mimeType_mobile='image' 
                            or (some $x in ('movie', 'sound','custom_womi', 'geogebra', 'womi_exercise_engine','custom_logic_exercise_womi', 'processingjs_animation') 
                            satisfies $womiEngine=$x))">
                            <xsl:call-template name="createWomiElement">
                                <xsl:with-param name="curr" select="."/>
                                <xsl:with-param name="format" select="'mobile_app'"/>
                            </xsl:call-template>

                            <xsl:if test="$currManifest/womiIds">
                                <xsl:variable name="moduleId" select="@module_id"/>
                                <xsl:for-each select="$currManifest/womiIds/item">
                                    <xsl:variable name="currWomiId" select="./text()"/>
                                    <xsl:variable name="metadata" select="ep:get_metadata_file_by_id($currWomiId)"/>
                                    <xsl:element name="womi">
                                        <xsl:attribute name="id" select="$currWomiId"/>
                                        <xsl:attribute name="module_id" select="$moduleId"/>
                                        <xsl:attribute name="title" select="$metadata/Tytul"/>
                                        <xsl:attribute name="authors" select="$metadata/Autor"/>
                                        <xsl:attribute name="licences" select="$metadata/Licencja"/>
                                        <xsl:attribute name="licenceAdditionalInfo" select="$metadata/LicencjaDodatkoweInfo"/>
                                        <xsl:attribute name="format" select="'mobile_app'"/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:if>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if
                            test="(($currManifest/mimeType_pdf='image' 
                            and $currManifest/mimeType_ebook='image')
                            and not(doc-available(concat($womiLocalPath, '/', $womi_id, '-', 'pdf', '-content.html')))
                            and not(doc-available(concat($womiLocalPath, '/', $womi_id, '-', 'ebook', '-content.html'))))">
                            <xsl:call-template name="createWomiElement">
                                <xsl:with-param name="curr" select="."/>
                                <xsl:with-param name="format" select="''"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template name="createWomiElement">
        <xsl:param name="curr"/>
        <xsl:param name="format"/>
        <xsl:variable name="womiId" select="$curr/@id"></xsl:variable>
        <xsl:variable name="metadata" select="$metadata_files/metadata[id = $womiId]"/>
        
        <xsl:element name="womi">
            <xsl:attribute name="id" select="$womiId"/>
            <xsl:attribute name="module_id" select="$curr/@module_id"/>
            <xsl:attribute name="title" select="$metadata/Tytul"/>
            <xsl:attribute name="authors" select="$metadata/Autor"/>
            <xsl:attribute name="licences" select="$metadata/Licencja"/>
            <xsl:attribute name="licenceAdditionalInfo" select="$metadata/LicencjaDodatkoweInfo"/>
            <xsl:attribute name="format" select="$format"></xsl:attribute>
            <xsl:copy-of select="$curr/@solution"/>
            <xsl:copy-of select="$curr/@subcollection_id"/>
            <xsl:copy-of select="$curr/@cover"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>