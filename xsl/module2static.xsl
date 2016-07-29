<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ep="http://epodreczniki.pl/"
    xmlns:col="http://cnx.rice.edu/collxml"
    xmlns:md="http://cnx.rice.edu/mdml"
    exclude-result-prefixes="xs ep col md"
    version="2.0">
    
    <xsl:param name="outputFormat"/>
    
    <xsl:template match="div[starts-with(@ep:role, 'feedback')]">
        <xsl:param name="col_id" tunnel="yes"/>
        <xsl:param name="module_id" tunnel="yes"/>
        <xsl:if test="ends-with(@ep:role, ' correct')">
            <xsl:choose>
                <xsl:when test="$outputFormat = 'pdf'">
                    <xsl:call-template name="create_link_to_solution_pdf"/>
                </xsl:when>
                <xsl:when test="$outputFormat = 'ebook'">
                    <xsl:call-template name="create_link_to_solution_epub">
                        <xsl:with-param name="p_col_id" select="$module_id"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="div[@ep:role = 'solution']">
        <xsl:param name="col_id" tunnel="yes"/>
        <xsl:param name="module_id" tunnel="yes"/>
        <xsl:if test="ancestor::div[contains(@ep:role, 'exercise') and (not(@ep:interactivity) or @ep:interactivity != 'interactive')] and count(preceding-sibling::div[@ep:role = 'solution']) = 0">
            <xsl:choose>
                <xsl:when test="$outputFormat = 'pdf'">
                    <xsl:call-template name="create_link_to_solution_pdf"/>
                </xsl:when>
                <xsl:when test="$outputFormat = 'ebook'">
                    <xsl:call-template name="create_link_to_solution_epub">
                        <xsl:with-param name="p_col_id" select="$module_id"/>
                    </xsl:call-template> 
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="div[@ep:role = 'commentary' and not(@type)]">
        <xsl:param name="col_id" tunnel="yes"/>
        <xsl:param name="module_id" tunnel="yes"/>
        <xsl:if test="not(preceding-sibling::div[@ep:role = 'solution']) and ancestor::div[contains(@ep:role, 'exercise') and @ep:interactivity != 'interactive']">
            <xsl:choose>
                <xsl:when test="$outputFormat = 'pdf'">
                    <xsl:call-template name="create_link_to_solution_pdf"/>
                </xsl:when>
                <xsl:when test="$outputFormat = 'ebook'">
                    <xsl:call-template name="create_link_to_solution_epub">
                       <xsl:with-param name="p_col_id" select="$module_id"/>
                    </xsl:call-template> 
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="div[@ep:role = 'note-tip' and ancestor::div[contains(@ep:role, 'exercise')]]">
        <xsl:param name="col_id" tunnel="yes"/>
        <xsl:param name="module_id" tunnel="yes"/>
        <xsl:if test="not(following-sibling::div[@ep:role = 'solution']) and not(following-sibling::div[@ep:role = 'commentary' and not(@type)]) and ancestor::div[contains(@ep:role, 'exercise') and @ep:interactivity != 'interactive']">
            <xsl:choose>
                <xsl:when test="$outputFormat = 'pdf'">
                    <xsl:call-template name="create_link_to_solution_pdf"/>
                </xsl:when>
                <xsl:when test="$outputFormat = 'ebook'">
                    <xsl:call-template name="create_link_to_solution_epub">
                        <xsl:with-param name="p_col_id" select="$module_id"/>
                    </xsl:call-template> 
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="div[@ep:role = 'commentary' and @type='example']">
        <xsl:element name="div">
            <xsl:attribute name="class" select="'commentary-example'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="div[@ep:role = 'solution-toggles']">
    </xsl:template>
    
    <xsl:template match="div[@ep:role = 'note-toggle']">
    </xsl:template>
    
    <xsl:template match="span[@ep:role = 'effect-of-education']">
        <xsl:choose>
            <xsl:when test="$outputFormat = 'pdf'">
                <xsl:element name="span">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$outputFormat = 'ebook'"></xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="form">
        <xsl:element name="div">
            <xsl:attribute name="class" select="ep:map_role2css('answers-list')" />
            <xsl:element name="ul">
                <xsl:attribute name="class" select="ep:map_role2css('answers-list')" />
                <xsl:for-each select="div[@ep:role='answer']">
                    <xsl:element name="li">
                        <xsl:apply-templates select="node()|@*" />
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="//input" />
    
    <xsl:template match="div[@class='answer']//textarea">
        <div>
            <xsl:attribute name="class" select="ep:map_role2css('textarea-placeholder')" />
            <xsl:text>Odpowiedź zapisz w zeszycie.</xsl:text>
        </div>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='answer']/div[@ep:role = 'section']">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='answer']/div[@ep:role = 'section']/div[@ep:role = 'section-contents']">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="label">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="@ep:role">
        <xsl:attribute name="class">
            <xsl:value-of select="ep:map_role2css(.)" />
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@ep:*">
    </xsl:template>    

    <xsl:template match="a[contains(@ep:role, 'link')]">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:variable name="tokens" select="tokenize(@href, '#')"/>
                <xsl:analyze-string select="$tokens[1]" regex="^\.\./(.+)$">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="$outputFormat = 'ebook'">
                                <xsl:text>m_</xsl:text>
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:text>.html</xsl:text>
                            </xsl:when>
                            <xsl:when test="$outputFormat = 'pdf' and not(exists($tokens[2]))">
                                <xsl:text>#</xsl:text>
                                <xsl:value-of select="regex-group(1)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                
                <xsl:if test="./@ep:link-type and $outputFormat='ebook' and not($tokens[1])">
                    <xsl:text>m_</xsl:text>
                    <xsl:value-of select="substring-before($tokens[2],'_')"/>
                    <xsl:text>.html</xsl:text>
                </xsl:if>
                
                <xsl:if test="exists($tokens[2])">
                    <xsl:text>#</xsl:text>
                    <xsl:value-of select="$tokens[2]"></xsl:value-of>
                </xsl:if>
                
            </xsl:attribute>
            
            <xsl:if test="./@ep:link-type">
                <xsl:attribute name="data-link-type" select="./@ep:link-type"/>
            </xsl:if>
            
            <xsl:apply-templates select="text()|node()"></xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="h1|h2|h3|h4|h5|h6">
        <xsl:param name="counter_subcoll_ancestor" tunnel="yes" select="0"></xsl:param>
        <xsl:variable name="h_index">
            <xsl:choose>
                <xsl:when
                    test="number(substring(local-name(),2, 1))+number($counter_subcoll_ancestor) > 6">
                    <xsl:value-of select="6"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="number(substring(local-name(),2, 1))+number($counter_subcoll_ancestor)"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:element name="h{$h_index}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy></xsl:copy>
    </xsl:template>
    
    <xsl:template match="ep:alternatives">
        <xsl:choose>
            <xsl:when test="$outputFormat = 'pdf'">
                <xsl:apply-templates select="ep:alternative[ep:formats/ep:format = 'static']/*[not(self::ep:formats)]"></xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$outputFormat = 'ebook'">
                <xsl:apply-templates select="ep:alternative[ep:formats/ep:format = 'static-mono']/*[not(self::ep:formats)]"></xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='problem']">
        <xsl:param name="col_id" tunnel="yes"></xsl:param>
        <xsl:param name="col_md_version" tunnel="yes"></xsl:param>
        <xsl:param name="col_variant" tunnel="yes"></xsl:param>
        
        <xsl:choose>
            <xsl:when test="ancestor::div[contains(@ep:role, 'exercise') and @ep:interactivity = 'static']">
                <xsl:element name="div">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ancestor::div[contains(@ep:role, 'exercise') and @ep:interactivity = 'random']">
                <xsl:element name="div">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ancestor::div[contains(@ep:role, 'exercise') and @ep:interactivity = 'interactive']">
                <xsl:variable name="mod_id" select="preceding::h1[1]/parent::div/@id"></xsl:variable>
                <xsl:variable name="href" select="concat($www_link, $col_id, '/v/', $col_md_version, '/t/', $col_variant,'/m/', $mod_id, '#', ancestor::div[@ep:role='exercise']/@id)"/>
                <xsl:element name="div">
                    <xsl:apply-templates select="@ep:role"/>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$href"/>
                        </xsl:attribute>
                        <xsl:value-of select="$locales/locale[@key='interactive_exercise_link_label']/text()"/>
                    </xsl:element>
                </xsl:element>
                <xsl:if test="$outputFormat = 'pdf'">
                    <xsl:element name="div">
                        <xsl:attribute name="class" select="'qr-code'"/>
                        <xsl:call-template name="create_qr_image">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="div">
                    <xsl:apply-templates select="node()|@*"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[@ep:role='gallery-contents']/div[contains(@ep:role, 'content')]">
        <xsl:if test="($outputFormat = 'ebook' and @ep:role='content static-mono')
                      or ($outputFormat = 'pdf' and @ep:role='content static')">
          <xsl:element name="div">
              <xsl:apply-templates select="node()|@*"/>
          </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="create_link_to_solution_epub">
        <xsl:param name="p_col_id"></xsl:param>
        <xsl:param name="chapter_number" tunnel="yes"></xsl:param>
        <xsl:element name="div">
            <xsl:attribute name="class">
                <xsl:text>show-answer</xsl:text>
            </xsl:attribute>
            <xsl:text>(</xsl:text>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:text>m_</xsl:text>
                    <xsl:value-of select="$p_col_id"></xsl:value-of>
                    <xsl:text>_</xsl:text>
                    <xsl:text>answers</xsl:text>
                    <xsl:text>.html#</xsl:text>
                    <xsl:value-of select="ancestor::div[contains(@ep:role, 'exercise')][last()]/@id"></xsl:value-of>
                    <xsl:text>-solution</xsl:text>
                </xsl:attribute>
                <xsl:text>Pokaż odpowiedź</xsl:text>
            </xsl:element>
            <xsl:text>)</xsl:text>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="create_link_to_solution_pdf">
        <xsl:element name="div">
            <xsl:attribute name="class">
                <xsl:text>show-answer</xsl:text>
            </xsl:attribute>
            <xsl:text>(</xsl:text>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:value-of select="ancestor::div[contains(@ep:role, 'exercise')][last()]/@id"></xsl:value-of>
                    <xsl:text>-solution</xsl:text>
                </xsl:attribute>
                <xsl:text>Pokaż odpowiedź</xsl:text>
            </xsl:element>
            <xsl:text>)</xsl:text>
        </xsl:element>	
    </xsl:template>
    
    <xsl:template match="div[@ep:role='date' or @ep:role='location' or @ep:role='author']/div">
        <xsl:element name="span">
            <xsl:attribute name="class" select="ep:map_role2css(@ep:role)"/>
            <xsl:apply-templates select="node()"></xsl:apply-templates>            
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="span[ancestor::div[@ep:role='date' or @ep:role='location' or @ep:role='author']]/text()">
        <xsl:value-of select="concat(translate(., '&#160;', ''), ': ')"></xsl:value-of>
    </xsl:template>
    
    <xsl:template match="node()[@ep:role='command-header' and ancestor::div[@ep:role='student-work homework']]"/>
    <xsl:template match="node()[@ep:role='command-header' and ancestor::div[@ep:role='student-work project']]"/>
    
    <xsl:template match="span[@ep:role='numbering-element']/text()">
        <xsl:choose>
            <xsl:when test="ancestor::node()[4]/@ep:role = 'step-header' 
                or (ancestor::node()[@ep:role='problem-header'])">
                <xsl:value-of select="."></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."></xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="span[@ep:role='numbering']/text()">
        <xsl:choose>
            <xsl:when test="ancestor::node()[3]/@ep:role = 'step-header' or ancestor::node()[2]/@ep:role='quote-line'">
                <xsl:value-of select="."></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."></xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="span[@ep:role='numbering-end-character']/text()"/>
    
    <xsl:template match="h1[@ep:role = 'module-header']">
        <xsl:variable name="moduleId" select="parent::div/@id"/>
        <xsl:variable name="mod" select="$coll//col:module[@document=$moduleId]"></xsl:variable>
        
        <xsl:if test="$outputFormat='pdf'">
            <xsl:if
                test="count($mod/preceding-sibling::col:module) = 0
                and count($mod/preceding-sibling::col:subcollection) = 0
                and count($mod/ancestor::col:subcollection[1][@toc='skip']/preceding-sibling::col:subcollection[@toc='skip']) = 0
                and not(contains($moduleId,'second_page'))">
                    
                <xsl:call-template name="createTitleHierarchyForFirstElementInSubcollection">
                    <xsl:with-param name="module_id" select="$moduleId"></xsl:with-param>
                </xsl:call-template>
            </xsl:if>             
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="contains(parent::node()/@id, 'second_page')">
                <xsl:element name="h1">
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="./span[@ep:role='title']"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains(parent::node()/@id, 'about') or contains(parent::node()/@id, 'answers')">
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not(exists($mod/ancestor::node()[local-name()='subcollection'][1]/md:title))
                        and (count($mod/preceding-sibling::col:module) = 0)"></xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="beforeSubColl" select="count($mod/ancestor::col:subcollection)+1"></xsl:variable>
                        <xsl:element name="h{$beforeSubColl}">
                            <xsl:apply-templates select="@*"></xsl:apply-templates>
                            <xsl:choose>
                                <xsl:when test="following-sibling::div[@ep:role='module-header-caption']">
                                    <xsl:variable name="banerWomi" select="following-sibling::div[@ep:role='module-header-caption']"/>
                                    <xsl:variable name="bannerWomiId" select="number($banerWomi/div/@baner-womi)"/>
                                    <img>
                                        <xsl:attribute name="class" select="'header-image'"/>
                                        <xsl:attribute name="src"
                                            select="concat('womi/',$bannerWomiId,'-pdf.',ep:getImageType($bannerWomiId,$outputFormat,$outputFormat))"/>
                                    </img>
                                    <div>
                                        <xsl:attribute name="class" select="'module-caption'"/>
                                        <span>
                                            <xsl:attribute name="class" select="'module-caption-content'"/>
                                            <xsl:apply-templates/>
                                        </span>
                                    </div>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="h1[@ep:role = 'module-header']/span[@ep:role = 'title']">
        <span>
            <xsl:attribute name="class" select="'title'"/>
            <xsl:choose>
                <xsl:when test="parent::*/parent::*//div[@ep:role='module-presentation-title']">
                    <xsl:apply-templates select="parent::*/parent::*//div[@ep:role='module-presentation-title']/node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    <xsl:template name="createTitleHierarchyForFirstElementInSubcollection">
        <xsl:param name="module_id"/>
        
        <xsl:variable name="prefix">
            <xsl:for-each
                select="$coll//col:subcollection[.//col:module[1][@document=$module_id]]">
                <xsl:value-of
                    select="count(preceding-sibling::node()[
                    (not(@toc) or @toc = 'include')
                    and (not(@ep:numbering) or @numbering = 'include')
                    and (local-name() = 'module'
                    or (local-name() = 'subcollection'
                    and (contains(./descendant::node()[local-name() = 'module'][1]/@document, 'answers')
                    or (count(./descendant::node()[local-name() = 'module'
                    and (((not(@ep:numbering) or @ep:numbering != 'skip') and (not(@toc) or @toc='include')))])) > 0)))
                    ])+1"/>
                <xsl:text>.</xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="token" select="tokenize($prefix, '\.')"/>
        <xsl:variable name="maxChapterNuber">
            <xsl:call-template name="for_loop_down_counter">
                <xsl:with-param name="count" select="count($token)"/>
                <xsl:with-param name="data" select="$token" tunnel="yes"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:for-each
            select="$coll//col:subcollection[.//col:module[1][@document=$module_id] and (not(@toc) or @toc!='skip')]">
                        
            <xsl:if test="not(position() &lt; number($maxChapterNuber))">
                <xsl:variable name="pos_for" select="position()"/>
                <xsl:variable name="h_index">
                    <xsl:value-of select="count(./ancestor::col:subcollection)+1"></xsl:value-of>
                </xsl:variable>
                
                <xsl:element name="{concat('h', $h_index)}">
                    <xsl:attribute name="class">subcollection-title</xsl:attribute>
                    <xsl:if test="$outputFormat != 'ebook'">
                        <xsl:attribute name="id" select="concat('toc_', $module_id)"/>
                    </xsl:if>
                    
                    <xsl:if test="count(descendant::node()[local-name() = 'module' and (not(@ep:numbering) or @ep:numbering != 'skip')]) > 0">
                        <span class='chapter-label'>
                            <xsl:if test="$pos_for = 1">
                                    <xsl:value-of select="$locales/locale[@key='chapter']/text()"/>
                                    <xsl:text> </xsl:text>
                                
                            </xsl:if>
                            
                            <xsl:for-each select="$token">
                                <xsl:if test="not(position() > $pos_for)">
                                    <xsl:value-of select="."/>
                                    <xsl:text>.</xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            
                            <xsl:text> </xsl:text>
                        </span>
                    </xsl:if>
                    
                    <span class='title'>                      
                        <xsl:choose>
                            <xsl:when test="./md:title">
                                <xsl:value-of select="./md:title"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select=".//col:module[1]/md:title"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="for_loop_down_counter">
        <xsl:param name="count" select="10"/>
        <xsl:param name="data" tunnel="yes"></xsl:param>
        
        <xsl:if test="$count > 0">
            <xsl:choose>
                <xsl:when test="number($data[$count]) and number($data[$count]) &gt; 1">
                    <xsl:value-of select="$count"></xsl:value-of>
                    <xsl:call-template name="for_loop_down_counter">
                        <xsl:with-param name="count" select="0"/>
                    </xsl:call-template>        
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$count = 1">
                        <xsl:value-of select="$count"></xsl:value-of>
                    </xsl:if>
                    
                    <xsl:call-template name="for_loop_down_counter">
                        <xsl:with-param name="count" select="$count - 1"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="span[@ep:role='title' and parent::*[@ep:role='exercise-header']]">
        <xsl:variable name="alternativeContentWomi" select="../../*[@ep:role='exercise-contents']/ep:reference |
                                                ../../*[@ep:role='exercise-contents']/ep:alternatives/ep:alternative[
                                                (ep:formats/ep:format = 'static' and $outputFormat='pdf') or 
                                                (ep:formats/ep:format = 'static-mono' and $outputFormat='ebook')
                                                ]/ep:reference"/>
        <xsl:variable name="alternativeContent" select="concat($womiLocalPath, '/', number($alternativeContentWomi/@ep:id), '-', $outputFormat, '-content.html')"/>
        <xsl:choose>
            <xsl:when test="doc-available($alternativeContent)">
                <xsl:element name="span">
                    <xsl:apply-templates select="@*"/>
                    <xsl:value-of select="document($alternativeContent)/*/@data-title"></xsl:value-of>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="span">
                    <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xsl:template match="span[@ep:role='label' and parent::*[@ep:role='exercise-header']]">
        <xsl:element name="span">
            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
        </xsl:element>
        
        <xsl:variable name="alternativeContentWomi" select="../../*[@ep:role='exercise-contents']/ep:reference |
                                            ../../*[@ep:role='exercise-contents']/ep:alternatives/ep:alternative[
                                            (ep:formats/ep:format = 'static' and $outputFormat='pdf') or 
                                            (ep:formats/ep:format = 'static-mono' and $outputFormat='ebook')
                                            ]/ep:reference"/>
        <xsl:variable name="alternativeContent" select="concat($womiLocalPath, '/', number($alternativeContentWomi/@ep:id), '-', $outputFormat, '-content.html')"/>
        <xsl:if test="not(following-sibling::span[@ep:role='title']) and doc-available($alternativeContent)">
            <xsl:element name="span">
                <xsl:apply-templates select="@*"/>
                <xsl:value-of select="document($alternativeContent)/*/@data-title"></xsl:value-of>
            </xsl:element>
        </xsl:if>

        
            
    </xsl:template>
    
    <xsl:template match="span[@ep:role='label' and parent::div[@ep:role='tooltip-header']]">
    </xsl:template>
    
    <xsl:template match="span[@ep:role='numbering' and ancestor::div[contains(@ep:role, 'exercise') and @ep:interactivity='womi_with_alternatives']]">
        <xsl:apply-templates/>
        <xsl:variable name="exercise" select="ancestor::div[contains(@ep:role, 'exercise') and position()=1]"/>
        <xsl:variable name="following" select="$exercise/following-sibling::div[@ep:role!='strip-start' and @ep:role!='strip-end']"/>
        <xsl:variable name="following-exercise" select="$following[contains(@ep:role, 'exercise') and @ep:interactivity='womi_with_alternatives' and position()=1]"/>
        <xsl:apply-templates select="$following-exercise" mode="search"/>
    </xsl:template>
    
    
    <xsl:template match="*" mode="search">
        <xsl:variable name="following" select="following-sibling::div[@ep:role!='strip-start' and @ep:role!='strip-end']"/>
        <xsl:variable name="following-exercise" select="$following[contains(@ep:role, 'exercise') and @ep:interactivity='womi_with_alternatives' and position()=1]"/>
        <xsl:choose>
            <xsl:when test="$following-exercise">
                <xsl:apply-templates select="$following-exercise" mode="search"></xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <span class="numbering-exercise-separator">-</span>
                <span class="numbering-last-exercise">
                    <xsl:choose>
                        <xsl:when test="parent::div/parent::div[contains(@ep:role, 'exercise-set')]">
                            <xsl:value-of select="substring-after(.//span[@ep:role='numbering-element'], '.')"></xsl:value-of>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select=".//span[@ep:role='numbering-element']"></xsl:value-of>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[contains(@ep:role, 'exercise') and @ep:interactivity='womi_with_alternatives' 
        and preceding-sibling::div[@ep:role!='strip-start' and @ep:role!='strip-end'][contains(@ep:role, 'exercise') and @ep:interactivity='womi_with_alternatives' and position()=1]]">
    </xsl:template>
    
</xsl:stylesheet>
