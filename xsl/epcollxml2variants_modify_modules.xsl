<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cnxsi="http://cnx.rice.edu/system-info"
    xmlns:col="http://cnx.rice.edu/collxml" xmlns:ep="http://epodreczniki.pl/"
    xmlns:cnxml="http://cnx.rice.edu/cnxml" xmlns:md="http://cnx.rice.edu/mdml" 
    xmlns:epe="http://epodreczniki.pl/editor" xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs ep epe" version="2.0">
    
    <xsl:import href="common.xslt"/>
    
    <xsl:param name="resultDir" select="'1'"/>
    <xsl:param name="path_to_files_epxml_of_modules_in_col" select="'1'"/>
    <xsl:param name="variants" select="'sc:se:ss:tc:te:ts'"/>
    
    <xsl:template match="/">
        <xsl:variable name="variantsInCurrColl">
            <xsl:call-template name="ep:getAllVariants">
                <xsl:with-param name="p_modules" select="$modules"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:message>
            <xsl:text>[xslt] Transforming module to passed variants </xsl:text>
        </xsl:message>
        <xsl:for-each select="$modules/cnxml:documents/cnxml:document">
            <xsl:variable name="moduleId" select=".//@module-id"/>
            
            <xsl:variable name="g_recipient" select=".//ep:e-textbook-module/@ep:recipient"/>
            <xsl:variable name="g_content_status"
                select=".//ep:e-textbook-module/@ep:content-status"/>
            
            <xsl:if test="(matches($variants, '(^|:)t.($|:+)') and contains($variantsInCurrColl, 'teacher-'))">
                <xsl:if
                    test="(contains($variants, 'tc') 
                    and $g_content_status = 'canon'
                    and contains($variantsInCurrColl, 'teacher-canon'))">
                    <xsl:result-document href="file:///{$resultDir}/teacher-canon/{$moduleId}/index.epxml" indent="no">
                        <xsl:apply-templates select="." mode="variants">
                            <xsl:with-param name="p_recipient" select="'teacher'"/>
                            <xsl:with-param name="p_content-status" select="'canon'"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
                <xsl:if
                    test="(contains($variants, 'te')
                    and $g_content_status != 'supplemental'
                    and contains($variantsInCurrColl, 'teacher-expanding'))">
                    <xsl:result-document
                        href="file:///{$resultDir}/teacher-expanding/{$moduleId}/index.epxml" indent="no">
                        <xsl:apply-templates select="." mode="variants">
                            <xsl:with-param name="p_recipient" select="'teacher'"/>
                            <xsl:with-param name="p_content-status" select="'expanding'"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
                <xsl:if
                    test="(contains($variants, 'ts')
                    and $g_content_status != 'expanding'
                    and contains($variantsInCurrColl, 'teacher-supplemental'))">
                    <xsl:result-document
                        href="file:///{$resultDir}/teacher-supplemental/{$moduleId}/index.epxml" indent="no">
                        <xsl:apply-templates select="." mode="variants">
                            <xsl:with-param name="p_recipient" select="'teacher'"/>
                            <xsl:with-param name="p_content-status" select="'supplemental'"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
            </xsl:if>
            
            <xsl:if test="(matches($variants, '(^|:)s.($|:+)')
                and $g_recipient = 'student')">
                <xsl:if test="(contains($variants, 'sc')
                    and $g_content_status = 'canon')">
                    <xsl:result-document href="file:///{$resultDir}/student-canon/{$moduleId}/index.epxml" indent="no">
                        <xsl:apply-templates select="." mode="variants">
                            <xsl:with-param name="p_recipient" select="'student'"/>
                            <xsl:with-param name="p_content-status" select="'canon'"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
                <xsl:if
                    test="(contains($variants, 'se')
                    and $g_content_status != 'supplemental'
                    and contains($variantsInCurrColl, 'student-expanding'))">
                    <xsl:result-document
                        href="file:///{$resultDir}/student-expanding/{$moduleId}/index.epxml" indent="no">
                        <xsl:apply-templates select="." mode="variants">
                            <xsl:with-param name="p_recipient" select="'student'"/>
                            <xsl:with-param name="p_content-status" select="'expanding'"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
                <xsl:if
                    test="(contains($variants, 'ss')
                    and $g_content_status != 'expanding'
                    and contains($variantsInCurrColl, 'student-supplemental'))">
                    <xsl:result-document
                        href="file:///{$resultDir}/student-supplemental/{$moduleId}/index.epxml" indent="no">
                        <xsl:apply-templates select="." mode="variants">
                            <xsl:with-param name="p_recipient" select="'student'"/>
                            <xsl:with-param name="p_content-status" select="'supplemental'"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="variants">
        <xsl:param name="p_recipient"/>
        <xsl:param name="p_content-status"/>
        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="variants">
                <xsl:with-param name="p_recipient" select="$p_recipient"/>
                <xsl:with-param name="p_content-status" select="$p_content-status"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[(@ep:content-status or @ep:recipient) and not(self::ep:e-textbook-module)]" mode="variants">
        <xsl:param name="p_recipient"/>
        <xsl:param name="p_content-status"/>
        
        <xsl:variable name="ctx" select="."/>
        <xsl:variable name="g_recipient" select="ancestor::node()//ep:e-textbook-module/@ep:recipient"></xsl:variable>
        <xsl:variable name="g_content_status" select="ancestor::node()//ep:e-textbook-module/@ep:content-status"></xsl:variable>
        
        <xsl:variable name="curr_receipient">
            <xsl:choose>
                <xsl:when test="./@ep:recipient">
                    <xsl:value-of select="./@ep:recipient"></xsl:value-of>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$g_recipient"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="curr_content_status">
            <xsl:choose>
                <xsl:when test="./@ep:content-status">
                    <xsl:value-of select="./@ep:content-status"></xsl:value-of>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$g_content_status"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="($p_recipient = 'teacher' and $p_content-status = 'canon') 
                and ($curr_content_status='expanding' or $curr_content_status='supplemental')"></xsl:when>
            <xsl:when test="($p_recipient = 'teacher' and $p_content-status = 'expanding') 
                and ($curr_content_status='supplemental')"></xsl:when>
            <xsl:when test="($p_recipient = 'teacher' and $p_content-status = 'supplemental') 
                and ($curr_content_status='expanding')"></xsl:when>
            
            <xsl:when test="($p_recipient = 'student' and $p_content-status = 'canon') 
                and ($curr_receipient='teacher' or $curr_content_status='expanding' or $curr_content_status='supplemental')"></xsl:when>
            <xsl:when test="($p_recipient = 'student' and $p_content-status = 'expanding') 
                and ($curr_receipient='teacher' or $curr_content_status='supplemental')"></xsl:when>
            <xsl:when test="($p_recipient = 'student' and $p_content-status = 'supplemental') 
                and ($curr_receipient='teacher' or $curr_content_status='expanding')"></xsl:when>
            
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*" mode="variants">
                        <xsl:with-param name="p_recipient" select="$p_recipient"/>
                        <xsl:with-param name="p_content-status" select="$p_content-status"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="ep:getAllVariants">
        <xsl:param name="p_modules"/>

        <xsl:variable name="variantsInModules">
            <xsl:call-template name="ep:getVariantsInCurrColl">
                <xsl:with-param name="p_modules" select="$p_modules"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="returnAllPossibleVariants">
            <xsl:if test="contains($variantsInModules, 'student-expanding') 
                and contains($variantsInModules, 'teacher-canon') 
                and not(contains($variantsInModules, 'teacher-expanding'))">
                <xsl:text>teacher-expanding,</xsl:text>
            </xsl:if>
            
            <xsl:if test="contains($variantsInModules, 'student-supplemental') 
                and contains($variantsInModules, 'teacher-canon') 
                and not(contains($variantsInModules, 'teacher-supplemental'))">
                <xsl:text>teacher-supplemental,</xsl:text>
            </xsl:if>
            
            <xsl:value-of select="$variantsInModules"></xsl:value-of>
        </xsl:variable>
        
        <xsl:value-of select="$returnAllPossibleVariants"></xsl:value-of>

    </xsl:template>
    
    <xsl:template name="ep:getVariantsInCurrColl">
        <xsl:param name="p_modules"></xsl:param>
        
        <xsl:for-each-group select="$p_modules//*" group-by="@ep:recipient,@ep:content-status">
            <xsl:for-each select="current-group()">
                <xsl:choose>
                    <xsl:when
                        test="local-name(.) != 'e-textbook-module' 
                        and ((./@ep:content-status = 'expanding' 
                        and preceding::*[name() = 'ep:e-textbook-module'][1]/@ep:content-status = 'supplemental')
                        or 
                        (./@ep:content-status = 'supplemental' 
                        and preceding::*[name() = 'ep:e-textbook-module'][1]/@ep:content-status = 'expanding'))">
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="./@ep:recipient">
                                <xsl:value-of select="./@ep:recipient"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="preceding::*[name() = 'ep:e-textbook-module'][1]/@ep:recipient"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="'-'"/>
                        <xsl:choose>
                            <xsl:when test="./@ep:content-status">
                                <xsl:value-of select="./@ep:content-status"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="preceding::*[name() = 'ep:e-textbook-module'][1]/@ep:content-status"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="','"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each-group>
    </xsl:template>
    
</xsl:stylesheet>