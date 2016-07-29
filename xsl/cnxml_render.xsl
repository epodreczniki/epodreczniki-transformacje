<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cnx="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:ep="http://epodreczniki.pl/"
  xmlns:col="http://cnx.rice.edu/collxml"
  exclude-result-prefixes="xsl">
  
  <xsl:import href="ident.xsl"/>
  <xsl:include href="bibtexml.xsl"/>
  <xsl:include href="qml.xsl"/>
  <xsl:include href="table.xsl"/>
  <xsl:include href="common.xslt"/>
  
  <xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>
  <xsl:strip-space  elements="ep:presentation ep:parameters"/>
  
  <xsl:param name="resultDir"/>

  <xsl:variable name="version">
    <xsl:choose>
      <xsl:when test="//cnx:document/@cnxml-version">
        <xsl:value-of select="//cnx:document/@cnxml-version"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyzäëïöüáéíóúàèìòùâêîôûåøãõæœçłñ'"/>
  <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÄËÏÖÜÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÅØÃÕÆŒÇŁÑ'"/>
 
  
  <xsl:template match="/col:collection">
    <xsl:message>
      <xsl:text>[XSLT] Transforming modules</xsl:text>
    </xsl:message>
    <xsl:for-each select="$modules//cnx:documents/cnx:document">
      <xsl:apply-templates select="."></xsl:apply-templates>
    </xsl:for-each>
    
    <xsl:for-each select="ep:extract_module_ids_from_module_elements(//col:module[contains(@document, '_about_') and not(contains(@document, '_about_licenses'))])">
      <xsl:apply-templates select="document(concat($path_to_files_epxml_of_modules_in_col, '/', concat(., '_mobile_app'), '/index.epxml'))/cnx:document"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="IdCheck">
    <xsl:if test="@id">
      <xsl:attribute name="id">
	<xsl:value-of select="@id"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
    
  <xsl:template name="level-count">
    <xsl:variable name="level-number">
      <xsl:call-template name="level-count-ancestors"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$level-number &lt; 4">
        <xsl:value-of select="$level-number + 2"/>
      </xsl:when>
      <xsl:otherwise>6</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="level-count-ancestors">
    <xsl:value-of select="count(ancestor::cnx:section[cnx:title or cnx:label or ep:parameters/ep:role/@ep:generate-title]|
                                ancestor::cnx:example[cnx:name or cnx:title or not(cnx:label[not(node())])]|
                                ancestor::cnx:definition|
                                ancestor::ep:concept|
                                ancestor::cnx:quote|
                                ancestor::cnx:rule[cnx:name or cnx:title or not(cnx:label[not(node())])]|
                                ancestor::cnx:exercise[cnx:name or cnx:title or not(cnx:label[not(node())])]|
                                ancestor::cnx:note[not(@display='inline')][cnx:title or cnx:label[node()] or ((@type!='' or not(@type)) and not(cnx:label))]|
                                ancestor::ep:lead|
                                ancestor::ep:intro|
                                ancestor::ep:revisal|
                                ancestor::ep:effect|
                                ancestor::ep:prerequisite|
                                ancestor::ep:experiment|
                                ancestor::ep:observation|
                                ancestor::ep:biography|
                                ancestor::ep:event|
                                ancestor::ep:literary-work-description|
                                ancestor::ep:literary-work-summary|
                                ancestor::ep:procedure-instructions|
                                ancestor::ep:gallery
                                )"/>
  </xsl:template>

  <xsl:key name="id" match="*" use="@id"/>

  <xsl:template match="@ep:grid-width|@ep:grid-height|@ep:fixed-tile-layout|@grid-width|@grid-height|@fixed-tile-layout">
    <xsl:attribute name="data-{local-name()}">
      <xsl:value-of select="."></xsl:value-of>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="cnx:module|cnx:document">
    <xsl:variable name="module_filename">
      <xsl:choose>
        <xsl:when test="@data-format and @data-format = 'mobile_app'">
          <xsl:value-of select="concat(@module-id, '_mobile_app')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@module-id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:result-document href="file:///{$resultDir}/{$module_filename}.xhtml">
      <div id="{@module-id}">
        <xsl:if
          test="exists(cnx:metadata/ep:e-textbook-module) or cnx:metadata/ep:e-textbook-module/ep:presentation/ep:type">
          <xsl:attribute name="ep:role">
            <xsl:if test="cnx:metadata/ep:e-textbook-module/@ep:recipient">
              <xsl:text>recipient-</xsl:text>
              <xsl:value-of select="cnx:metadata/ep:e-textbook-module/@ep:recipient"/>
            </xsl:if>
            
            <xsl:if test="cnx:metadata/ep:e-textbook-module/@ep:content-status">
              <xsl:text> content-status-</xsl:text>
              <xsl:value-of select="cnx:metadata/ep:e-textbook-module/@ep:content-status"/>
            </xsl:if>

            <xsl:if test="cnx:metadata/ep:e-textbook-module/ep:presentation/ep:type">
              <xsl:text> </xsl:text>
              <xsl:value-of
                select="cnx:metadata/ep:e-textbook-module/ep:presentation/ep:type"/>
            </xsl:if>
            
            <xsl:if test="descendant-or-self::ep:zebra-point">
              <xsl:text> zebra-module</xsl:text>
            </xsl:if>
            
            <xsl:if test="some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x)">
              <xsl:text> science-module</xsl:text>
            </xsl:if>
            
            <xsl:if test="ep:parameters/ep:role">
              <xsl:text> </xsl:text>
              <xsl:value-of select="ep:parameters/ep:role"/>
            </xsl:if>
            
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="cnx:metadata/ep:e-textbook-module/ep:presentation|cnx:metadata/ep:e-textbook-module/ep:generated-type"></xsl:apply-templates>
		  <xsl:apply-templates select="*[not(self::cnx:glossary|self::bib:file)]"/>

		  <xsl:if test="bib:file">
			   <xsl:apply-templates select="bib:file"/>
		  </xsl:if>
        
        <xsl:if test="./cnx:metadata/ep:e-textbook-module/ep:references/ep:module-header/ep:reference/ep:content">
          <xsl:variable name="banerInfo" select="./cnx:metadata/ep:e-textbook-module/ep:references/ep:module-header"></xsl:variable>
          <div ep:role="module-header-caption">
            <div>
              <xsl:attribute name="baner-womi" select="$banerInfo/ep:reference/@ep:id"/>
              <xsl:attribute name="style" select="'display:none'"/>
              <xsl:if test="$banerInfo/@ep:title-position">
                <xsl:attribute name="baner-title-position" select="$banerInfo/@ep:title-position"/>
              </xsl:if>
            </div>
            <xsl:apply-templates select="$banerInfo/ep:reference/ep:content/node()"/>
          </div>
        </xsl:if>
        
        <xsl:if test="./cnx:metadata/md:presentationTitle">
          <div ep:role="module-presentation-title">
            <xsl:apply-templates select="./cnx:metadata/md:presentationTitle/node()"/>
          </div>
        </xsl:if>
      </div>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="cnx:metadata|cnx:authorlist|cnx:maintainerlist|cnx:keywordlist|cnx:abstract|cnx:objectives|cnx:featured-links|cnx:link-group|ep:numbering"/>
  
  <xsl:template match="ep:parameters|ep:presentation">
    <xsl:apply-templates></xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="ep:name[parent::ep:parameters]|ep:title[parent::ep:parameters]|ep:role[parent::ep:parameters]|ep:tile|
                       ep:left|ep:top|ep:width[parent::ep:parameters]|ep:height[parent::ep:parameters]|ep:grid-width|ep:grid-height|
											 ep:margin-left|ep:margin-right|ep:margin-top|ep:margin-bottom|
											 ep:type[parent::ep:parameters or parent::ep:presentation]|ep:fixed-tile-layout|ep:columns|ep:start-new-page|ep:foldable|ep:stretch|ep:stretch-title">
    <xsl:if test="every $x in ('foldable', 'stretch', 'stretch-title') satisfies local-name() != $x">
      <xsl:attribute name="data-{local-name()}">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ep:generated-type[parent::ep:e-textbook-module]">
    <xsl:attribute name="data-type">
      <xsl:value-of select="."></xsl:value-of>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="ep:width[parent::ep:presentation]|ep:height[parent::ep:presentation]">
    <xsl:attribute name="data-grid-{local-name()}">
      <xsl:value-of select="."></xsl:value-of>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="ep:template[parent::ep:presentation or parent::ep:parameters]">
    <xsl:attribute name="data-{local-name()}">
      <xsl:choose>
        <xsl:when test="text() = 'linear'">linear</xsl:when>
        <xsl:otherwise>tiled</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="parameter">
    <xsl:attribute name="{@name}">
      <xsl:value-of select="@value"></xsl:value-of>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="cnx:section">
    <xsl:if test="parent::node()/local-name()='content'
      and ((preceding-sibling::node()[local-name() != ''][1]/local-name() ='zebra-point'
      or child::node()[local-name() != 'parameters'][local-name() != ''][1]/local-name() ='zebra-point')
      and (not(./ep:parameters/ep:start-new-page) or (./ep:parameters/ep:start-new-page = 'false'))
      and preceding-sibling::cnx:section[1])">
      <div ep:role="section level_1 strip-end"/>
      <div ep:role="section level_1 strip-start"/>
    </xsl:if>
    
    <xsl:variable name="isFirstLevelSection" select="parent::cnx:content"/>
    <xsl:variable name="isColumnsSection" select="ep:parameters/ep:columns and number(ep:parameters/ep:columns) > 1"/>
    
    <div>
      <xsl:attribute name="ep:role">
        <xsl:text>section</xsl:text>
        <xsl:if test="ep:parameters/ep:role">
          <xsl:text> </xsl:text>
          <xsl:value-of select="ep:parameters/ep:role"/>
        </xsl:if>
        
        <xsl:if test="@ep:role">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ep:role"/>
        </xsl:if>
        
        <xsl:value-of
          select="concat(' level_', count(ancestor::node()[local-name() = 'section'])+1)"/>
        
        <xsl:if test="@ep:recipient">
          <xsl:text> recipient-</xsl:text>
          <xsl:value-of select="@ep:recipient"></xsl:value-of>
        </xsl:if>
        
        <xsl:if test="@ep:content-status">
          <xsl:text> content-status-</xsl:text>
          <xsl:value-of select="@ep:content-status"></xsl:value-of>
        </xsl:if>
        
        <xsl:if test="(ep:parameters/ep:foldable/text() = 'true') or ((@ep:content-status = 'expanding') and (some $x in ($locales/locale[@key='subject_computerClasses'], $locales/locale[@key='subject_computerScience'],$locales/locale[@key='subject_polishLanguage'],$locales/locale[@key='subject_historyAndSociety'],$locales/locale[@key='subject_history'],$locales/locale[@key='subject_civicsEducation']) satisfies contains($subject,$x)))">
          <xsl:text> foldable</xsl:text>
        </xsl:if>
        
        <xsl:if test="$isColumnsSection">
          <xsl:text> columns</xsl:text>         
        </xsl:if>
        
          <xsl:choose>
            <xsl:when test="ep:parameters/ep:stretch or ep:parameters/ep:stretch-title">
              <xsl:choose>
                <xsl:when test="ep:parameters/ep:stretch = $locales/locale[@key='stretch-extended-shifted-width']">
                  <xsl:if test="$isColumnsSection">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$locales/locale[@key='stretch-full-width']"/>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$locales/locale[@key='stretch-full-width']"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="not($isColumnsSection)">
                <xsl:if test="descendant::cnx:para[@ep:stretch != $locales/locale[@key='stretch-extended-shifted-width']] 
                  or descendant::cnx:exercise[@ep:stretch != $locales/locale[@key='stretch-extended-shifted-width']]">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$locales/locale[@key='stretch-full-width']"/>
                </xsl:if>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        
        
      </xsl:attribute>
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@*[name() != 'ep:role']"></xsl:apply-templates>
      <xsl:apply-templates select="ep:parameters"></xsl:apply-templates>
      <xsl:variable name="role" select="ep:parameters/ep:role/text()"/>
      <xsl:apply-templates select="document('tile-role2css.xml')/roles/role[@key=$role]/parameter"></xsl:apply-templates>
      <xsl:variable name="level-number">
        <xsl:call-template name="level-count"/>
      </xsl:variable>
      <xsl:if test="cnx:title != '' or cnx:label != '' or ep:parameters/ep:role/@ep:generate-title">
        <xsl:element name="h{$level-number}">
          <xsl:attribute name="ep:role">
            <xsl:choose>
              <xsl:when test="@ep:role='answers_exercise'">exercise-header</xsl:when>
              <xsl:when test="@ep:role='answers_solution'">solution-header</xsl:when>
              <xsl:when test="@ep:role='answers_commentary'">commentary-header</xsl:when>
              <xsl:when test="cnx:*[@ep:role='second_page_title_header']"><xsl:value-of select="cnx:title/@ep:role"></xsl:value-of></xsl:when>
              <xsl:when test="cnx:*[@ep:role='second_page_subtitle_header']"><xsl:value-of select="cnx:title/@ep:role"></xsl:value-of></xsl:when>
              <xsl:otherwise>
                <xsl:text>section-header</xsl:text>
                <xsl:if test="(ep:parameters/ep:foldable/text() = 'true') or ((@ep:content-status = 'expanding') and (some $x in ($locales/locale[@key='subject_computerClasses'], $locales/locale[@key='subject_computerScience'],$locales/locale[@key='subject_polishLanguage'],$locales/locale[@key='subject_historyAndSociety'],$locales/locale[@key='subject_history'],$locales/locale[@key='subject_civicsEducation']) satisfies contains($subject,$x)))">
                  <xsl:text> foldable-header</xsl:text>
                </xsl:if>
                
                <xsl:if test="ep:parameters/ep:stretch-title">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="ep:parameters/ep:stretch-title"/>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="labeled-exercise" select="(parent::cnx:problem or parent::cnx:solution) and                                                        not(cnx:label[not(node())])"/>
          <xsl:if test="cnx:label[node()] or $labeled-exercise">
              <xsl:apply-templates select="cnx:label"/>
              <xsl:if test="cnx:label[node()] and (cnx:title[node()] and not($labeled-exercise))">
                <xsl:text>: </xsl:text>
              </xsl:if>
        	    <xsl:if test="$labeled-exercise">
        	      <xsl:number level="any" count="cnx:exercise" format="1."/>
                      <xsl:number level="single" format="a) "/>
        	    </xsl:if>
          </xsl:if>
          <xsl:if test="@name">
            <div>
              <xsl:attribute name="ep:role">
                <xsl:text>section-header</xsl:text>
                <xsl:if test="(ep:parameters/ep:foldable/text() = 'true') or ((@ep:content-status = 'expanding') and (some $x in ($locales/locale[@key='subject_computerClasses'], $locales/locale[@key='subject_computerScience'],$locales/locale[@key='subject_polishLanguage'],$locales/locale[@key='subject_historyAndSociety'],$locales/locale[@key='subject_history'],$locales/locale[@key='subject_civicsEducation']) satisfies contains($subject,$x)))">
                  <xsl:text> foldable-header</xsl:text>
                </xsl:if>
                
                <xsl:if test="ep:parameters/ep:stretch-title">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="ep:parameters/ep:stretch-title"/>
                </xsl:if>
              </xsl:attribute>
              <xsl:value-of select="@name"/>
              <xsl:if test="@name=''">
                <xsl:text> </xsl:text>
              </xsl:if>
            </div>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="ep:parameters/ep:role/@ep:generate-title = 'true'">
              <span>
                <xsl:attribute name="ep:role">
                  <xsl:text>title</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$locales/locale[@key=$role]"/>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="cnx:name|cnx:title"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="not(cnx:name|cnx:title)">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:element>
      </xsl:if>
      
      <div>
        <xsl:attribute name="ep:role">
          <xsl:text>section-contents</xsl:text>
          <xsl:if test="(ep:parameters/ep:foldable/text() = 'true') or ((@ep:content-status = 'expanding') and (some $x in ($locales/locale[@key='subject_computerClasses'], $locales/locale[@key='subject_computerScience'],$locales/locale[@key='subject_polishLanguage'],$locales/locale[@key='subject_historyAndSociety'],$locales/locale[@key='subject_history'],$locales/locale[@key='subject_civicsEducation']) satisfies contains($subject,$x)))">
            <xsl:text> foldable-contents</xsl:text>
          </xsl:if>
          
            <xsl:choose>
              <xsl:when test="$isColumnsSection">
                <xsl:if test="ep:parameters/ep:stretch">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="ep:parameters/ep:stretch"/>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="descendant::cnx:para[@ep:stretch != $locales/locale[@key='stretch-extended-shifted-width']] 
                  or descendant::cnx:exercise[@ep:stretch != $locales/locale[@key='stretch-extended-shifted-width']]">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$locales/locale[@key='stretch-full-width']"/>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          
        </xsl:attribute>
        <xsl:apply-templates select="*[not(self::cnx:label|self::cnx:name|self::cnx:title|self::ep:parameters)]|text()"/>
      </div>
    </div>
    
    <xsl:if test="parent::node()/local-name() = 'content' 
      and child::node()[last()]/local-name() ='zebra-point'
      and following-sibling::node()[1][
          (child::node()[local-name() != 'parameters'][1]/local-name() != 'zebra-point') 
          and (not(./ep:parameters/ep:start-new-page) or ./ep:parameters/ep:start-new-page = 'false')]">
      <div ep:role="section level_1 strip-end"/>
      <div ep:role="section level_1 strip-start"/>
    </xsl:if>
    
  </xsl:template>

  <xsl:template match="cnx:content">
    <xsl:apply-templates select="node()[not(self::ep:parameters)]"></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="cnx:name[not(node())]|
                       cnx:title[not(node())]|
                       cnx:link[@src or @url][not(node())]|
                       cnx:emphasis[not(node())]|
                       cnx:important[not(node())]|
                       cnx:quote[not(node())]|
                       cnx:foreign[not(node())]|
                       cnx:codeline[not(node())]|
                       cnx:code[(@display='inline' or @type='inline') and not(node())]|
                       cnx:codeblock[not(node())]|
                       cnx:term[not(node())]|
                       cnx:meaning[not(node())]|
                       cnx:div[not(node())]|
                       cnx:preformat[not(node())]|
                       cnx:sup[not(node())]|
                       cnx:sub[not(node())]">
  </xsl:template>

  <xsl:template match="cnx:name|cnx:title">
    <xsl:if test="not(parent::*[self::cnx:module|self::cnx:document] or empty(.))">
      <span>
        <xsl:attribute name="ep:role">
          <xsl:text>title</xsl:text>
          
          <xsl:if test="@ep:stretch">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@ep:stretch"/>
          </xsl:if>
        </xsl:attribute>
        <xsl:call-template name="IdCheck"/>
	      <xsl:apply-templates/>
        <xsl:if test="parent::cnx:meaning|cnx:note|cnx:item[parent::cnx:list[not(@type='named-item')]]|cnx:list[(@type='inline' and $version='0.5') or @display='inline']">
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:if test="parent::cnx:item[parent::cnx:list[@type='named-item' and $version='0.5']]">
          <xsl:choose>
            <xsl:when test="parent::cnx:item[parent::cnx:list/processing-instruction('mark')[string-length(normalize-space(.)) &gt; 0]]">
              <xsl:value-of select="parent::cnx:item/parent::cnx:list/processing-instruction('mark')"/>
            </xsl:when>
            <xsl:when test="parent::cnx:item[parent::cnx:list/processing-instruction('mark')]"/>
            <xsl:otherwise>
              <xsl:text>:</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:call-template name="setElementsSpanForContentStatus">
          <xsl:with-param name="ctx" select="parent::node()"></xsl:with-param>
        </xsl:call-template>
      </span>
    </xsl:if>
    <xsl:if test="parent::*[self::cnx:module|self::cnx:document]">
      <xsl:element name="h1">
        <xsl:attribute name="ep:role" select="'module-header'"/>
        <span ep:role="label">
          <xsl:element name="span">
            <xsl:attribute name="ep:role">numbering</xsl:attribute>
            <xsl:text> </xsl:text>
            <xsl:element name="span">
              <xsl:attribute name="ep:role">numbering-prefix</xsl:attribute>
              <xsl:variable name="prefix_number">
                <xsl:value-of select="ep:get_number_prefix(ancestor::cnx:document/@module-id)"/>
              </xsl:variable>
              <xsl:value-of select="$prefix_number"/>
              <xsl:if test="$prefix_number != ''">
                <xsl:text>&#160;</xsl:text>
              </xsl:if>
            </xsl:element>
          </xsl:element>
        </span>
        <span ep:role="title">
          <xsl:call-template name="IdCheck"/>
          <xsl:value-of select="."/>
          <xsl:call-template name="setElementsSpanForContentStatus">
            <xsl:with-param name="ctx" select="parent::node()/cnx:metadata/ep:e-textbook-module"></xsl:with-param>
          </xsl:call-template>
        </span>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="setElementsSpanForContentStatus">
    <xsl:param name="ctx"></xsl:param>
    
    <xsl:if test="contains($ctx/@ep:recipient, 'teacher')">
      <xsl:text> </xsl:text>
      <span>
        <xsl:attribute name="ep:role">
          <xsl:text>recipient-teacher</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="$locales/locale[@key='shortcut_content_status_teacher']/text()"></xsl:value-of>
      </span>
    </xsl:if>
    
    <xsl:if test="contains($ctx/@ep:content-status, 'expanding')">
      <xsl:text> </xsl:text>
      <span>
        <xsl:attribute name="ep:role">
          <xsl:text>content-status-expanding</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="$locales/locale[@key='shortcut_content_status_expanding']/text()"></xsl:value-of>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cnx:label">
    <span>
      <xsl:attribute name="ep:role">
        <xsl:text>label</xsl:text>
        
        <xsl:if test="exists(@ep:role)">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ep:role"/>
        </xsl:if>
        
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="cnx:label[parent::cnx:item[parent::cnx:list[not(@list-type='labeled-item')]]][node()]">
    <span ep:role="label">
      <xsl:apply-templates/>
      <xsl:text>: </xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="cnx:para">
    <xsl:if test="cnx:name[node()] or cnx:title[node()]">
      <xsl:variable name="level-number">
        <xsl:call-template name="level-count"/>
      </xsl:variable>
      <xsl:element name="div">
        <xsl:attribute name="ep:role">para-header</xsl:attribute>
        <xsl:apply-templates select="cnx:name|cnx:title"/>
      </xsl:element>
    </xsl:if>
    <div>
      <xsl:attribute name="ep:role">
        <xsl:text>para</xsl:text>
        
        <xsl:if test="parent::cnx:section and @ep:stretch != $locales/locale[@key='stretch-extended-shifted-width']">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ep:stretch"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title)]|text()|@*"/>
    </div>
  </xsl:template>
  
  <xsl:template match="cnx:div">
    <div>
      <xsl:call-template name="IdCheck"/>
      <xsl:if test="cnx:title[node()]">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:element name="div">
          <xsl:attribute name="ep:role">title</xsl:attribute>
          <xsl:apply-templates select="cnx:title"/>
        </xsl:element>
      </xsl:if>
      <xsl:apply-templates select="*[not(self::cnx:title)]|text()|@*"/>
    </div>
  </xsl:template>

  <xsl:template match="cnx:link|cnx:cnxn">
    <a>
      <xsl:call-template name="IdCheck"/>
      <xsl:call-template name="link-attributes"/>
      <xsl:call-template name="link-text"/>
    </a>
  </xsl:template>

  <xsl:template name="link-attributes">
    <xsl:if test="@strength">
      <xsl:attribute name="title">
        <xsl:value-of select="$locales/locale[@key='Strength']"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@strength"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@window='new'">
      <xsl:attribute name="target">_blank</xsl:attribute>
    </xsl:if>
    <xsl:attribute name="ep:role">
      <xsl:text>link</xsl:text>
      <xsl:choose>
        <xsl:when test="@ep:collection-id">
          <xsl:text> intercollection-link</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="href">
      <xsl:call-template name="make-href"/>
    </xsl:attribute>
    <xsl:apply-templates select="@ep:collection-id|@ep:collection-version|@ep:collection-recipient"/>
  </xsl:template>
  
  <xsl:template match="@ep:collection-id|@ep:collection-version|@ep:collection-recipient">
    <xsl:attribute name="data-{local-name()}">
      <xsl:value-of select="."></xsl:value-of>
    </xsl:attribute>
  </xsl:template>
     
  <xsl:template name="make-href">
    <xsl:choose>
      <xsl:when test="@url[normalize-space()!=''] or @src[normalize-space()!='']">
        <xsl:value-of select="@url|@src"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="target" select="@target[normalize-space()!='']|@target-id[normalize-space()!='']"/>
        <xsl:variable name="document" select="normalize-space(@document|@document-refGlossary[normalize-space()!=''])"/>
        <xsl:variable name="module" select="normalize-space(@module[normalize-space()!=''])"/>
        <xsl:variable name="doc-version" select="normalize-space(@version[normalize-space()!=''])"/>
        <xsl:choose>
          <xsl:when test="not($document) and not($module) and not($doc-version)"/>
          <xsl:when test="not($document) and not($module) and $doc-version">
            <xsl:text>../</xsl:text>
            <xsl:value-of select="$doc-version"/>
            <xsl:text>/</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>../</xsl:text>
            <xsl:value-of select="$document"/>
            <xsl:value-of select="$module"/>
            <xsl:choose>
              <xsl:when test="$doc-version">
                <xsl:value-of select="$doc-version"/>
              </xsl:when>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="normalize-space(@resource)"/>
        <xsl:if test="$target">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="normalize-space($target)"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="link-text">
    <xsl:variable name="target" select="@target[normalize-space()!='']|@target-id[normalize-space()!='']"/>
    <xsl:choose>
      <xsl:when test="node()">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="key('id',normalize-space($target)) and not(@document[normalize-space()!=''] or                                                                   @module[normalize-space()!=''] or                                                                   @version[normalize-space()!='']                                                                 )">
        <span ep:role="link-text">
          <xsl:for-each select="key('id', normalize-space($target))">
            <xsl:variable name="type" select="translate(@type,$upper,$lower)"/>
            <xsl:choose>
              <xsl:when test="self::bib:entry" />
              <xsl:when test="cnx:label[node()]">
                <xsl:apply-templates select="cnx:label"/>
              </xsl:when>
              <xsl:when test="(self::cnx:note[@type!=''] or self::cnx:rule[@type!='']) and $version='0.5'">
                <xsl:value-of select="@type"/>
              </xsl:when>
              <xsl:when test="(self::cnx:note and ($type='note' or                                                     $type='warning' or                                                     $type='important' or                                                     $type='aside' or                                                     $type='tip')) or                                (self::cnx:rule and ($type='rule' or                                                     $type='theorem' or                                                     $type='lemma' or                                                     $type='corollary' or                                                     $type='law' or                                                     $type='proposition'))">
                <xsl:value-of select="$locales/locale[@key=$type]"/>
              </xsl:when>
              <xsl:when test="self::cnx:exercise[ancestor::cnx:example or qml:item] or self::qml:item">
                <xsl:value-of select="$locales/locale[@key='Problem']"/>
              </xsl:when>
              <xsl:when test="self::cnx:problem[not(parent::cnx:exercise[ancestor::cnx:example])]">
                <xsl:value-of select="$locales/locale[@key='Exercise']"/>
              </xsl:when>
              <xsl:when test="self::cnx:subfigure">
                <xsl:value-of select="$locales/locale[@key='Figure']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$locales/locale[@key=local-name()]"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(self::cnx:example[ancestor::cnx:definition or ancestor::ep:concept or ancestor::cnx:rule or ancestor::cnx:exercise or ancestor::cnx:entry or ancestor::cnx:footnote or ancestor::cnx:text or ancestor::cnx:longdesc])">
            <xsl:choose>
              <xsl:when test="self::bib:entry">[</xsl:when>
              <xsl:otherwise>
                <xsl:text> </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="self::cnx:note and ($type='note' or not(@type))">
                <xsl:number level="any" count="cnx:note[translate(@type,$upper,$lower)='note' or not(@type)]"/>
              </xsl:when>
              <xsl:when test="self::cnx:rule[@type='rule' or not(@type)]">
                <xsl:number level="any" count="cnx:rule[translate(@type,$upper,$lower)='rule' or not(@type)]"/>
              </xsl:when>
              <xsl:when test="self::qml:item">
                <xsl:number level="any" count="qml:item"/>
              </xsl:when>
              <xsl:when test="@type=local-name()">
                <xsl:variable name="element" select="name()"/>
                <xsl:number level="any" count="*[name()=$element][translate(@type,$upper,$lower)=$type or not(@type)]"/>
              </xsl:when>
              <xsl:when test="@type and (not($version='0.5') or self::cnx:rule or self::cnx:note)">
                <xsl:variable name="element" select="name()"/>
                <xsl:number level="any" count="*[name()=$element][translate(@type,$upper,$lower)=$type]"/>
              </xsl:when>
              <xsl:when test="self::cnx:subfigure">
                <xsl:variable name="figure-type" select="translate(parent::cnx:figure/@type,$upper,$lower)"/>
                <xsl:choose>
                  <xsl:when test="parent::cnx:figure/@type and $figure-type!='figure'">
                    <xsl:number level="any" count="cnx:figure[translate(@type,$upper,$lower)=$figure-type]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:number level="any" count="cnx:figure[not(@type) or translate(@type,$upper,$lower)=$figure-type]"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:number format="(a)" count="cnx:subfigure[not(@type) or translate(@type,$upper,$lower)='subfigure']"/>
              </xsl:when>
              <xsl:when test="self::cnx:solution or self::cnx:problem">
                <xsl:variable name="exercise-type" select="translate(parent::cnx:exercise/@type,$upper,$lower)"/>
                <xsl:choose>
                  <xsl:when test="parent::cnx:exercise/@type and $exercise-type!='exercise'">
                    <xsl:number level="any" count="cnx:exercise[translate(@type,$upper,$lower)=$exercise-type]"/>
                  </xsl:when>
                  <xsl:when test="parent::cnx:exercise[ancestor::cnx:example]">
                    <xsl:number level="any" from="cnx:example" count="cnx:exercise[not(@type) or translate(@type,$upper,$lower)='exercise']"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:number level="any" count="cnx:exercise[not(ancestor::cnx:example|qml:item)][not(@type) or translate(@type,$upper,$lower)='exercise']"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="self::cnx:solution and count(parent::cnx:exercise/cnx:solution) &gt; 1">
                  <xsl:text>.</xsl:text>
                  <xsl:number format="A" count="cnx:solution[not(@type) or translate(@type,$upper,$lower)='solution']"/>
                </xsl:if>
              </xsl:when>
              <xsl:when test="self::cnx:exercise">
                <xsl:choose>
                  <xsl:when test="ancestor::cnx:example">
                    <xsl:number level="any" from="cnx:example" count="cnx:exercise[not(@type) or translate(@type,$upper,$lower)='exercise']"/>
                  </xsl:when>
                  <xsl:when test="qml:item">
                    <xsl:number level="any" count="cnx:exercise[qml:item]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:number level="any" count="cnx:exercise[not(ancestor::cnx:example|qml:item)][not(@type) or translate(@type,$upper,$lower)='exercise']"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="self::cnx:example">
                <xsl:number level="any" count="cnx:example[not(ancestor::cnx:definition or ancestor::ep:concept or ancestor::cnx:rule or ancestor::cnx:exercise or ancestor::cnx:entry or ancestor::cnx:footnote or ancestor::cnx:text or ancestor::cnx:longdesc) and (not(@type) or translate(@type,$upper,$lower)='example')]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="element" select="name()"/>
                <xsl:choose>
                  <xsl:when test="$version='0.5'">
                    <xsl:number level="any" count="*[name()=$element]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:number level="any" count="*[name()=$element][not(@type) or translate(@type,$upper,$lower)=$element]"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="self::bib:entry">]</xsl:if>
            </xsl:if>
          </xsl:for-each>
        </span>
      </xsl:when>
      <xsl:otherwise>  
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="solution-test">
    <xsl:if test="self::cnx:solution">
      <xsl:if test="count(parent::cnx:exercise/cnx:solution) &gt; 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="$locales/locale[@key='Solution']"/>
      <xsl:if test="count(parent::cnx:exercise/cnx:solution) &gt; 1">
         <xsl:text> </xsl:text>
         <xsl:number format="A"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cnx:span">
    <xsl:variable name="span-element">
      <xsl:choose>
        <xsl:when test="@effect='bold'">b</xsl:when>
        <xsl:when test="@effect='italics'">i</xsl:when>
        <xsl:when test="@effect='underline'">u</xsl:when>
        <xsl:otherwise>span</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$span-element}">
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="node()|@ep:*"/>      
    </xsl:element>
  </xsl:template>

  <xsl:template match="cnx:emphasis">
    <xsl:variable name="emphasis-element">
      <xsl:choose>
        <xsl:when test="@effect='bold'">b</xsl:when>
        <xsl:when test="@effect='italics'">i</xsl:when>
        <xsl:when test="@effect='underline'">u</xsl:when>
        <xsl:when test="@effect='normal' or @effect='smallcaps'">span</xsl:when>
        <xsl:otherwise>em</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="em">
      <xsl:call-template name="IdCheck"/>
      <xsl:attribute name="ep:role" select="@effect"></xsl:attribute>
      <xsl:apply-templates select="node()|text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="cnx:important">
    <div ep:role="important">
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@*|node()|text()"/>
    </div>
  </xsl:template>

  <xsl:template match="cnx:quote">
    <xsl:call-template name="make-quote">
      <xsl:with-param name="display">
        <xsl:choose>
          <xsl:when test="@display='inline'">inline</xsl:when>
          <xsl:otherwise>block</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="make-quote">
    <xsl:param name="display">block</xsl:param>
    <xsl:variable name="element-name">
      <xsl:choose>
        <xsl:when test="$display='block'">blockquote</xsl:when>
        <xsl:otherwise>span</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element-name}">
      <xsl:apply-templates select="@ep:id"/>
      <xsl:call-template name="IdCheck"/>
      <xsl:attribute name="ep:role">
        <xsl:text>quote</xsl:text>
        <xsl:if test="@type">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@type"></xsl:value-of>
        </xsl:if>
        <xsl:if test="@ep:readability">
          <xsl:text> </xsl:text>
          <xsl:value-of select="concat(local-name(@ep:readability), '-', @ep:readability)"></xsl:value-of>
        </xsl:if>
        
        <xsl:if test="@ep:foldable='true'">
          <xsl:text> foldable</xsl:text>
        </xsl:if>
        <xsl:if test="@ep:content-status='expanding'">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ep:content-status"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:if test="@display='none'">
        <xsl:attribute name="style">display: none</xsl:attribute>
      </xsl:if>
      
      <xsl:choose>
        <xsl:when test="$display='block'">
          <xsl:variable name="level-number">
            <xsl:call-template name="level-count"/>
          </xsl:variable>
          
            <xsl:choose>
              <xsl:when test="some $x in ($locales/locale[@key='subject_polishLanguage'], $locales/locale[@key='subject_historyAndSociety'], $locales/locale[@key='subject_history'], $locales/locale[@key='subject_civicsEducation']) satisfies contains($subject,$x)">
                <xsl:if test="ep:author or cnx:label">
                  <xsl:element name="h{$level-number}">
                    <xsl:attribute name="ep:role">
                      <xsl:text>quote-header</xsl:text>
                      
                      <xsl:if test="@ep:foldable='true'">
                        <xsl:text> foldable-header</xsl:text>
                      </xsl:if>
                    </xsl:attribute>
                    <span ep:role="author">
                      <xsl:apply-templates select="ep:author"/>
                    </span>
  
                    <xsl:if test="cnx:label">
                      <span ep:role="title">
                        <xsl:value-of select="cnx:label"/>
                      </span>
                    </xsl:if>
                  </xsl:element>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:element name="h{$level-number}">
                  <xsl:attribute name="ep:role">
                    <xsl:text>quote-header</xsl:text>
                    
                    <xsl:if test="@ep:foldable='true'">
                      <xsl:text> foldable-header</xsl:text>
                    </xsl:if>
                  </xsl:attribute>
                  <span ep:role="label">
                    <xsl:value-of select="$locales/locale[@key='to-be-read']"/>
                  </span>
                  <span ep:role="quote-separator colon">
                    <xsl:text>: </xsl:text>
                  </span>
                  <xsl:if test="ep:author/text() != ''">
                    <span ep:role="author">
                      <xsl:apply-templates select="ep:author"/>
                    </span>
                  </xsl:if>
                  <xsl:if test="cnx:label/text() != ''">
                    <xsl:if test="ep:author/text() != ''">
                      <span ep:role="quote-separator coma">
                        <xsl:text>, </xsl:text>
                      </span>
                    </xsl:if>
                    <span ep:role="title">
                      <xsl:value-of select="cnx:label"/>
                    </span>
                  </xsl:if>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          
          <xsl:element name="div">
            <xsl:attribute name="ep:role">
              <xsl:text>quote-contents</xsl:text>
              <xsl:if test="@ep:foldable='true'">
                <xsl:text> foldable-contents</xsl:text>
              </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates select="*[not(self::cnx:title|self::cnx:label|self::ep:comment|self::ep:source|self::ep:author)]|text()"/>
            
            <xsl:apply-templates select="ep:comment"/>
            <xsl:apply-templates select="ep:source"/>
            
            <xsl:if test="ep:license|ep:license-additional-info">
              <xsl:element name="div">
                <xsl:attribute name="ep:role">license</xsl:attribute>
                <xsl:apply-templates select="@ep:id"/>
                <xsl:call-template name="ep-header">
                  <xsl:with-param name="element-name" select="'license'"/>
                </xsl:call-template>
                <xsl:element name="div">
                  <xsl:attribute name="ep:role">
                    <xsl:text>license-contents</xsl:text>
                  </xsl:attribute>
                  <xsl:if test="ep:license/@ep:url">
                    <xsl:element name="span">
                      <xsl:attribute name="ep:role" select="'license-url'"></xsl:attribute>
                      <xsl:value-of select="ep:license/@ep:url"/>
                    </xsl:element>
                  </xsl:if>
                  <xsl:if test="ep:license-additional-info">
                    <xsl:element name="span">
                      <xsl:attribute name="ep:role" select="'license-additional-info'"></xsl:attribute>
                      <xsl:value-of select="ep:license-additional-info"/>
                    </xsl:element>
                  </xsl:if>
                </xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*[not(self::cnx:title|self::cnx:label|self::ep:comment|self::ep:author)]|text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="cnx:quote/ep:license|cnx:quote/ep:license-additional-info"></xsl:template>

  <xsl:template match="cnx:para[parent::cnx:quote]">
    <xsl:variable name="type" select="parent::cnx:quote/@type"></xsl:variable>
    <xsl:variable name="numbering-range">
      <xsl:choose>
        <xsl:when test="$type = 'JPOL_prose'">1</xsl:when>
        <xsl:when test="$type = 'JPOL_poetry'">5</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="start-numbering">
      <xsl:choose>
        <xsl:when test="parent::cnx:quote/@ep:start-numbering and parent::cnx:quote/@ep:start-numbering != ''"><xsl:value-of select="parent::cnx:quote/@ep:start-numbering"></xsl:value-of></xsl:when>
        <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div ep:role="para">
      <xsl:apply-templates select="@id"></xsl:apply-templates>
      <xsl:for-each-group select="node()" group-ending-with="cnx:newline">
        <div ep:role="quote-line">
          <xsl:if test="$numbering-range > 0 and (position() mod $numbering-range = 0)">
            <span ep:role="numbering"><xsl:value-of select="concat(position() + $start-numbering, '')"></xsl:value-of></span>
          </xsl:if>
          <xsl:apply-templates select="current-group()"></xsl:apply-templates>
        </div>
      </xsl:for-each-group>
    </div>
  </xsl:template>

  <xsl:template match="cnx:sup|cnx:sub">
    <xsl:element name="{local-name()}">
      <xsl:call-template name="IdCheck"/>
      <xsl:attribute name="ep:role">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="cnx:foreign">
    <span ep:role="foreign">
      <xsl:call-template name="IdCheck"/>
      <xsl:choose>
        <xsl:when test="@url[normalize-space()!=''] or
                        @document[normalize-space()!=''] or
                        @version[normalize-space()!=''] or
                        @resource[normalize-space()!=''] or
                        @target-id[normalize-space()!='']">
          <a>
            <xsl:call-template name="link-attributes"/>
            <xsl:apply-templates/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template match="cnx:code">
    <xsl:choose>
      <xsl:when test="$version ='0.5'">
        <xsl:choose>
          <xsl:when test="@type='block'">
            <xsl:call-template name="codeblock"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="codeline"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@display='block'">
        <xsl:call-template name="codeblock"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="codeline"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:codeline">
    <xsl:call-template name="codeline"/>
  </xsl:template>

  <xsl:template match="cnx:codeblock">
    <xsl:call-template name="codeblock"/>
  </xsl:template>

  <xsl:template name="codeline">
    <code ep:role="code">
      <xsl:apply-templates select="@*"></xsl:apply-templates>
      <xsl:if test="@display='none'">
        <xsl:attribute name="style">display: none</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="IdCheck"/>
      <xsl:if test="@lang">
        <span ep:role="label">
          [<xsl:value-of select="@lang"/>]
        </span>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="node() | text()"/>
    </code>
  </xsl:template>

  <xsl:template name="codeblock">
    <div ep:role="code">
      <xsl:call-template name="IdCheck"/>
      <xsl:if test="cnx:title or cnx:label[node()]">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:element name="div">
          <xsl:attribute name="ep:role">code-header</xsl:attribute>
          <xsl:if test="@lang">
            <span ep:role="label">
              [<xsl:value-of select="@lang"/>]
            </span>
            <xsl:if test="cnx:title">
              <xsl:text>: </xsl:text>
            </xsl:if>
          </xsl:if>
          <xsl:apply-templates select="cnx:title"/>
        </xsl:element>
      </xsl:if>
      <pre ep:role="code-contents">
        <code>
          <xsl:apply-templates select="*[not(self::cnx:title|self::cnx:label|self::cnx:caption)]|text()"/>
        </code>
      </pre>
      <xsl:if test="cnx:caption">
        <p ep:role="code-caption">
          <xsl:if test="cnx:caption[@id]">
            <xsl:attribute name="id">
              <xsl:value-of select="cnx:caption/@id"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="cnx:caption"/>
        </p>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="cnx:code[@class='listing']">
    <div ep:role="code">
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@*"/>
      <table border="0" cellpadding="0" cellspacing="0" align="center" width="50%">
        <xsl:if test="cnx:caption or not(cnx:label[not(node())])">
          <caption align="bottom" ep:role="code-caption">
            <xsl:if test="cnx:caption[@id]">
              <xsl:attribute name="id">
                <xsl:value-of select="cnx:caption/@id"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(cnx:label[not(node())])">
              <div ep:role="label">
                <xsl:choose>
                  <xsl:when test="cnx:label">
                    <xsl:apply-templates select="cnx:label"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$locales/locale[@key='Listing']"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
                <xsl:variable name="type" select="translate(@type,$upper,$lower)"/>
                <xsl:choose>
                  <xsl:when test="@type and $type!='code'">
                    <xsl:number level="any" count="cnx:code[@class='listing'][translate(@type,$upper,$lower)=$type]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:number level="any" count="cnx:code[@class='listing'][not(@type) or translate(@type,$upper,$lower)='code']"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="cnx:caption">
                  <xsl:text>: </xsl:text>
                </xsl:if>
              </div>
            </xsl:if>
            <xsl:apply-templates select="cnx:caption"/>
          </caption>
        </xsl:if>
        <xsl:if test="cnx:title[node()]">
          <thead>
            <tr>
              <th ep:role="code-header">
                <xsl:apply-templates select="cnx:title"/>
              </th>
            </tr>
          </thead>
        </xsl:if>
        <tbody>
          <tr>
            <td>
              <pre ep:role="codeblock">
                <code>
                  <xsl:apply-templates select="*[not(self::cnx:caption|self::cnx:title|self::cnx:label)]|text()"/>
                </code>
              </pre>
	          </td>
          </tr>
        </tbody>
      </table>
    </div>
  </xsl:template>
  
  <xsl:template match="cnx:preformat">
    <xsl:choose>
      <xsl:when test="@display='inline'">
        <span ep:role="preformat">
          <xsl:call-template name="IdCheck"/>
          <xsl:apply-templates select="node() | text() | @*"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <div ep:role="preformat">
          <xsl:call-template name="IdCheck"/>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates select="cnx:title"/>
          <pre>
            <xsl:if test="@display='none'">
              <xsl:attribute name="style">display: none</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="*[not(self::cnx:title)]|text()"/>
          </pre>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:newline|cnx:space">
    <xsl:variable name="blank-element">
      <xsl:choose>
        <xsl:when test="self::cnx:space">pre</xsl:when>
        <xsl:otherwise>span</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$blank-element}">
      <xsl:call-template name="IdCheck"/>
      <xsl:attribute name="ep:role">
        <xsl:value-of select="local-name()"/>
        <xsl:if test="@effect='underline'">
          <xsl:text> underline</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:call-template name="loop">
        <xsl:with-param name="name">
          <xsl:value-of select="local-name()"/>
          <xsl:if test="@effect='underline'">
            <xsl:text>underline</xsl:text>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="count">
          <xsl:choose>
            <xsl:when test="@count">
              <xsl:value-of select="@count"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template name="loop">
    <xsl:param name="name">newline</xsl:param>
    <xsl:param name="count">1</xsl:param>
    <xsl:choose>
      <xsl:when test="$count = 0"/>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$name='newline'"><br/></xsl:when>
          <xsl:when test="$name='newlineunderline'"><hr/></xsl:when>
          <xsl:when test="contains($name,'space')"><xsl:text> </xsl:text></xsl:when>
        </xsl:choose>
        <xsl:call-template name="loop">
          <xsl:with-param name="name" select="$name"/>
          <xsl:with-param name="count" select="$count - 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:note">
    <xsl:choose>
      <xsl:when test="$version='0.5'">
        <xsl:choose>
          <xsl:when test="translate(@type,$upper,$lower)='footnote'">
            <xsl:call-template name="make-footnote"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="make-block-note"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@display='inline'">
        <xsl:call-template name="make-inline-note"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-block-note"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:footnote">
    <xsl:call-template name="make-footnote"/>
  </xsl:template>

  <xsl:template name="make-footnote">
    <xsl:variable name="footnote-number">
      <xsl:number level="any" count="//cnx:note[translate(@type,$upper,$lower)='footnote']|//cnx:footnote" format="1"/>
    </xsl:variable>
    <a ep:role="footnote-reference" href="#footnote{$footnote-number}">
      <xsl:value-of select="$footnote-number"/>
    </a>
    <xsl:if test="following-sibling::node()[normalize-space()!=''][1][self::cnx:note[translate(@type,$upper,$lower)='footnote'] or self::cnx:footnote]">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make-block-note">
    <xsl:variable name="type" select="translate(@type,$upper,$lower)"/>
    <xsl:variable name="note-number">
      <xsl:number count="cnx:note"/>
    </xsl:variable>
    <xsl:variable name="javascriptpresent" select="/module/display/javascriptpresent"/>
    
    <xsl:if test="parent::node()[local-name() != 'exercise']">
      <xsl:call-template name="block-note-content">
        <xsl:with-param name="type" select="$type"></xsl:with-param>        
        <xsl:with-param name="javascriptpresent" select="$javascriptpresent"></xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    
    <xsl:if test="$type = 'tip' and parent::node()[local-name() = 'exercise']">
      <div ep:role="note-toggle">
        <xsl:attribute name="id" select="concat(@id, '_toggle')"></xsl:attribute>
        <xsl:apply-templates select="@ep:role"/>
        <xsl:attribute name="style">display: none;</xsl:attribute>
        <xsl:variable name="show-note">
            <xsl:value-of select="$locales/locale[@key='ShowNoteTip']"/>
        </xsl:variable>
        <xsl:variable name="hide-note">
          <xsl:value-of select="$locales/locale[@key='HideNoteTip']"/>
        </xsl:variable>
        <input type="button" ep:role="note-toggle" value="{$show-note}" onclick="toggleNote('{@id}',{$note-number}); return false;"></input>
        <input type="button" ep:role="note-toggle" value="{$hide-note}" onclick="toggleNote('{@id}',{$note-number}); return false;" style="display: none;"></input> 
      </div>
      
      <xsl:call-template name="block-note-content">
        <xsl:with-param name="type" select="$type"></xsl:with-param>
        <xsl:with-param name="isNoteInExercise" select="1"></xsl:with-param>
        <xsl:with-param name="javascriptpresent" select="$javascriptpresent"></xsl:with-param>
      </xsl:call-template>      
    </xsl:if>
  </xsl:template>

  <xsl:template name="block-note-content">
    <xsl:param name="type"></xsl:param>
    <xsl:param name="isNoteInExercise" select="0"></xsl:param>
    <xsl:param name="javascriptpresent"></xsl:param>
    
    <div>
    <xsl:attribute name="ep:role">
      <xsl:text>note</xsl:text>
      <xsl:if test="$type">
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$type"/>
        <xsl:if test="((((not(@ep:foldable) or @ep:foldable='true') and $type = 'curiosity') 
          or (some $x in ('experiment','observation') satisfies (ancestor::node()/local-name()=$x)))
          and (some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x)))
          or (@ep:foldable and @ep:foldable='true')">
          <xsl:text> foldable</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@ep:recipient='teacher'">
        <xsl:value-of select="concat(' ', @ep:recipient)"></xsl:value-of>
      </xsl:if>
      <xsl:if test="@ep:content-status='expanding'">
        <xsl:value-of select="concat(' ', @ep:content-status)"></xsl:value-of>
      </xsl:if>
      <xsl:apply-templates select="@ep:presentation-variant"/>
    </xsl:attribute>      
    <xsl:if test="@display='none'">
      <xsl:attribute name="style">display: none</xsl:attribute>
    </xsl:if>
      <xsl:if test="$type = 'tip' and $isNoteInExercise = 1">
      <xsl:attribute name="style">
          <xsl:choose>
            <xsl:when test="$javascriptpresent='true'">
              <xsl:text>display: none;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>display: block;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
    </xsl:if>
    <xsl:call-template name="IdCheck"/>
    <xsl:apply-templates select="@id|@ep:role"></xsl:apply-templates>
      <xsl:if test="cnx:title or cnx:label[node()] or ((@type!='' or not(@type)) and not(cnx:label))">
        <xsl:choose>
          <xsl:when test="$type = 'consider'">
            <xsl:call-template name="note-label"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="level-number">
              <xsl:call-template name="level-count"/>
            </xsl:variable>
            <xsl:if test="@type != 'no-label'">
              <xsl:element name="h{$level-number}">
                <xsl:attribute name="ep:role">
                  <xsl:text>note-header</xsl:text>
                  <xsl:if
                    test="((((not(@ep:foldable) or @ep:foldable='true') and $type = 'curiosity')
                  or (some $x in ('experiment','observation') satisfies (ancestor::node()/local-name()=$x)))
                  and (some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x)))
                  or (@ep:foldable and @ep:foldable='true')">
                    <xsl:text> foldable-header</xsl:text>
                  </xsl:if>
                </xsl:attribute>
                <xsl:call-template name="note-label"/>
              </xsl:element>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$type = 'consider'">
          <span ep:role="content">
            <xsl:apply-templates select="*[not(self::cnx:label|self::cnx:title)]|text()"/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <div>
            <xsl:attribute name="ep:role">
              <xsl:text>note-contents</xsl:text>
              <xsl:if
                test="((((not(@ep:foldable) or @ep:foldable='true') and $type = 'curiosity')
                or (some $x in ('experiment','observation') satisfies (ancestor::node()/local-name()=$x)))
                and (some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x)))
                or (@ep:foldable and @ep:foldable='true')">
                <xsl:text> foldable-contents</xsl:text>
              </xsl:if>
            </xsl:attribute>

            <xsl:apply-templates select="*[not(self::cnx:label|self::cnx:title)]|text()"/>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="make-inline-note">
    <span>
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@display"/>
      <xsl:attribute name="ep:role">
        <xsl:text>note</xsl:text>
        <xsl:if test="@type">
          <xsl:text>-</xsl:text>
          <xsl:value-of select="@type"/>
          
          <xsl:if test="(not(@ep:foldable) or @ep:foldable='true') and @type = 'curiosity' and (some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x))">
            <xsl:text> foldable</xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:attribute>
      <xsl:if test="@type != 'no-label'">
        <xsl:call-template name="note-label"/>
      </xsl:if>
      <xsl:apply-templates select="*[not(self::cnx:label|self::cnx:title)]|text()"/>
    </span>
  </xsl:template>

  <xsl:template name="note-label">
    <xsl:if test="cnx:label[node()] or ((@type!='' or not(@type)) and not(cnx:label))">
      <span ep:role="label">
        <xsl:variable name="type" select="translate(@type,$upper,$lower)"/>
        <xsl:choose>
          <xsl:when test="cnx:label">
            <xsl:apply-templates select="cnx:label"/>
          </xsl:when>
          <xsl:when test="$type">
            <xsl:value-of select="$locales/locale[@key=$type]"/>
          </xsl:when>
          <xsl:when test="$version='0.5' and @type">
            <xsl:value-of select="@type"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$locales/locale[@key='Note']"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </xsl:if>
    <xsl:if test="cnx:title">
      <xsl:text>: </xsl:text>
      <xsl:apply-templates select="cnx:title"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cnx:example">
    <div ep:role="example">
      <xsl:variable name="level-number">
        <xsl:call-template name="level-count"/>
      </xsl:variable>
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="cnx:name or cnx:title or not(cnx:label[not(node())])">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:element name="h{$level-number}">
          <xsl:attribute name="ep:role">example-header</xsl:attribute>
          <xsl:choose>
            <xsl:when test="not(ancestor::cnx:definition|ancestor::ep:concept|ancestor::cnx:rule|ancestor::cnx:exercise|ancestor::cnx:entry)">
                <xsl:call-template name="example-label"></xsl:call-template>
                <xsl:apply-templates select="cnx:name|cnx:title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="example-label"></xsl:call-template>
                <xsl:apply-templates select="cnx:name|cnx:title"/>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:element>
      </xsl:if>
      <div>
        <xsl:attribute name="ep:role">example-contents</xsl:attribute>
        <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title|self::cnx:label)]"/>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template name="example-label">
    <xsl:if test="not(cnx:label[not(node())])">
      <span ep:role="label">
        <xsl:choose>
          <xsl:when test="cnx:label">
            <xsl:apply-templates select="cnx:label"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$locales/locale[@key='Example']"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:if test="not(ancestor::cnx:definition|ancestor::ep:concept|ancestor::cnx:rule|ancestor::cnx:exercise|ancestor::cnx:entry|ancestor::cnx:footnote|ancestor::cnx:text|ancestor::cnx:longdesc)">
          <xsl:element name="span">
            <xsl:attribute name="ep:role">numbering</xsl:attribute>
            <xsl:text> </xsl:text>
            <xsl:variable name="type" select="translate(@type,$upper,$lower)"/>
            <xsl:variable name="module_id" select="ancestor::cnx:document/@module-id"/>
            <xsl:element name="span">
              <xsl:attribute name="ep:role">numbering-prefix</xsl:attribute>
              <xsl:value-of select="ep:get_number_prefix(ancestor::cnx:document/@module-id)"/>
            </xsl:element>
            <xsl:element name="span">
              <xsl:attribute name="ep:role">numbering-element</xsl:attribute>
              <xsl:choose>
                <xsl:when test="@type and $type!='example'">
                  <xsl:variable name="example_position">
                    <xsl:number level="any" count="cnx:example[not(ancestor::cnx:definition|ep:concept|cnx:rule|cnx:exercise|cnx:entry|cnx:footnote|cnx:text|cnx:longdesc) and ancestor::cnx:document[@module-id=$module_id]]
                      [translate(@type,$upper,$lower)=$type]"/>
                  </xsl:variable>
                  <xsl:value-of select="$example_position"></xsl:value-of>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="example_position">
                    <xsl:number level="any" count="cnx:example[not(ancestor::cnx:definition|ep:concept|cnx:rule|cnx:exercise|cnx:entry|cnx:footnote|cnx:text|cnx:longdesc) and ancestor::cnx:document[@module-id=$module_id]]
                      [not(@type) or translate(@type,$upper,$lower)='example']"/>
                  </xsl:variable>
                  <xsl:value-of select="$example_position"></xsl:value-of>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
            <xsl:text>.</xsl:text>
          </xsl:element>
        </xsl:if>
        <xsl:if test="cnx:name or cnx:title or ancestor::cnx:glossary">&#160;</xsl:if>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cnx:definition|ep:concept">
    <xsl:variable name="elementName" select="local-name(.)"></xsl:variable>    
    
    <xsl:variable name="level-number">
      <xsl:call-template name="level-count"/>
    </xsl:variable>
    <div>
      <xsl:attribute name="ep:role">
        <xsl:value-of select="$elementName"/>
        <xsl:apply-templates select="@ep:presentation-variant"/>
      </xsl:attribute>
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@*[local-name() != 'presentation-variant']"/>
      <xsl:element name="h{$level-number}">
        <xsl:attribute name="ep:role">
          <xsl:value-of select="$elementName"/>
          <xsl:text>-header</xsl:text>
        </xsl:attribute>
        <xsl:if test="not(parent::cnx:glossary) and not(cnx:label[not(node())]) and contains($elementName, 'definition')">
            <span>
                <xsl:attribute name="ep:role">label</xsl:attribute>
                <xsl:choose>
                  <xsl:when test="cnx:label">
                    <xsl:apply-templates select="cnx:label"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$locales/locale[@key='Definition']"/>
                  </xsl:otherwise>
                </xsl:choose>
              <xsl:if test="cnx:term != '' 
                and (every $x in ($locales/locale[@key='subject_polishLanguage'], $locales/locale[@key='subject_historyAndSociety'], 
                $locales/locale[@key='subject_history'], $locales/locale[@key='subject_civicsEducation'],
                $locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], 
                $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) 
                satisfies not(contains($subject,$x)))">
                <xsl:text>: </xsl:text>
              </xsl:if>
            </span>
          </xsl:if>
        <xsl:if test="cnx:term != '' 
          and (every $x in ($locales/locale[@key='subject_polishLanguage'], $locales/locale[@key='subject_historyAndSociety'], 
          $locales/locale[@key='subject_history'], $locales/locale[@key='subject_civicsEducation'],
          $locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], 
          $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies not(contains($subject,$x)))
          or (some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], 
          $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) 
          satisfies contains($subject,$x) and $elementName = 'concept')">
            <span>
              <xsl:attribute name="ep:role">title</xsl:attribute>
              <xsl:apply-templates select="cnx:term/node()"/>
            </span>
          </xsl:if>

      </xsl:element>
      <xsl:for-each select="cnx:meaning">
        <div>
          <xsl:attribute name="ep:role">
            <xsl:value-of select="$elementName"/>
            <xsl:text>-contents</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates select=".|../cnx:example[generate-id(preceding-sibling::cnx:meaning[1]) = generate-id(current())]"/>
          <xsl:if test="position() = last()">
            <xsl:apply-templates select="parent::node()/ep:source"/>
            <xsl:element name="div">
              <xsl:attribute name="ep:role">go-to-glossary</xsl:attribute>
              <xsl:element name="a">
                <xsl:attribute name="href" select="concat('#', parent::node()/@*[local-name()='id'])"/>
                <xsl:value-of select="ep:getGoToGlossaryLabel(parent::node()/@ep:glossary-merge-type)"/>
              </xsl:element>
            </xsl:element>
            
            <xsl:if test="../ep:link[@ep:role='go-back-from-glossary']">
              <xsl:call-template name="create_go_back_link_from_glossary">
                <xsl:with-param name="href" select="../ep:link/@href"/>
              </xsl:call-template>
            </xsl:if> 
          </xsl:if>
        </div>
      </xsl:for-each>
      <xsl:apply-templates select="cnx:seealso"/>   
    </div>
  </xsl:template>
  
  <xsl:template match="cnx:term">
    <xsl:variable name="elementName">
      <xsl:choose>
        <xsl:when test="contains(local-name(parent::node()), 'definition')">
          <xsl:text>Definition</xsl:text>
        </xsl:when>
        <xsl:when test="contains(local-name(parent::node()), 'concept')">
          <xsl:text>Concept</xsl:text>
        </xsl:when>
      </xsl:choose>  
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="(ancestor::cnx:document/cnx:glossary/cnx:definition[@id=substring(current()/@src,2) or @id=current()/@target-id])
        or (ancestor::cnx:document/cnx:glossary/ep:concept[@id=substring(current()/@src,2) or @id=current()/@target-id])">
          <dfn ep:role="term">
            <xsl:call-template name="IdCheck"/>
            <a>
              <xsl:attribute name="onmouseover">
                <xsl:text>create</xsl:text>
                <xsl:value-of select="$elementName"/>
                <xsl:text>(this)</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="onmouseout">
                <xsl:text>remove</xsl:text>
                <xsl:value-of select="$elementName"/>
                <xsl:text>(this)</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="@src">
                    <xsl:value-of select="@src"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>#</xsl:text>
                    <xsl:value-of select="@target-id"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:apply-templates/>
            </a>
          </dfn>
      </xsl:when>
      <xsl:otherwise>
        <dfn ep:role="term">
          <xsl:call-template name="IdCheck"/>
          <xsl:choose>
            <xsl:when test="@src">
              <a href="{@src}">
                <xsl:apply-templates/>
              </a>
            </xsl:when>
            <xsl:when test="@url[normalize-space()!=''] or
                            @document[normalize-space()!=''] or
                            @version[normalize-space()!=''] or
                            @resource[normalize-space()!=''] or
                            @target-id[normalize-space()!='']">
              <a>
                <xsl:call-template name="link-attributes"/>
                <xsl:apply-templates/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates  select="node()|text()|@*"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="ancestor::cnx:glossary and (parent::cnx:definition or parent::ep:concept)">
            <xsl:text>:</xsl:text>
          </xsl:if>
        </dfn>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:seealso">
    <dd ep:role="seealso">
      <xsl:call-template name="IdCheck"/>
      <xsl:if test="not(cnx:label[not(node())])">
        <span ep:role="label">
          <xsl:choose>
            <xsl:when test="cnx:label">
              <xsl:apply-templates select="cnx:label"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$locales/locale[@key='GlossSeeAlso']"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>: </xsl:text>
        </span>
      </xsl:if>
      <xsl:for-each select="cnx:term">
        <xsl:apply-templates select="."/>
        <xsl:if test="position()!=last()">, </xsl:if>
      </xsl:for-each>
    </dd>
  </xsl:template>
  
  <xsl:template match="cnx:cite">
    <xsl:variable name="href">
      <xsl:call-template name="make-href"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$href='' and not(node())">
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="src" select="@src[normalize-space()!='']"/>
        <xsl:variable name="target-id" select="@target-id[normalize-space()!='']"/>
        <xsl:variable name="target" select="concat(substring-after($src,'#'),$target-id)"/>
        <xsl:variable name="url" select="@url[normalize-space()!='']"/>
        <xsl:variable name="bibentry" select="(starts-with($src,'#') or (concat('#',$target-id) = $href)) and                                               name(key('id',$target))='bib:entry'"/>
        <cite ep:role="cite">
          <xsl:call-template name="IdCheck"/>
          <xsl:if test="not($bibentry)">
            <xsl:choose>
              <xsl:when test="$version='0.5'">
                <span ep:role="cite-title">
                  <i>
                    <xsl:apply-templates/>
                  </i>
                </span>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="node()|text()|@*"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$href!=''">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:if>
          <xsl:if test="$href!='' and not($bibentry and node())">
            <xsl:text>[</xsl:text>
          </xsl:if>
          <xsl:if test="$href!=''">
            <a>
              <xsl:call-template name="link-attributes"/>
              <xsl:choose>
                <xsl:when test="$bibentry">
                  <xsl:choose>
                    <xsl:when test="node()">
                      <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="key('id',$target)">
                        <xsl:number level="any" count="//bib:entry"/>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$locales/locale[@key='Citelink']"/>
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:if>
          <xsl:if test="$href!='' and not($bibentry and node())">
            <xsl:text>]</xsl:text>
          </xsl:if>
        </cite>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:cite-title">
    <span ep:role="cite-title">
      <xsl:choose>
        <xsl:when test="@pub-type='article' or
                        @pub-type='inbook' or
                        @pub-type='incollection' or
                        @pub-type='inproceedings' or
                        @pub-type='misc' or
                        @pub-type='unpublished'">
          "<xsl:apply-templates/>"
        </xsl:when>
        <xsl:otherwise>
          <i><xsl:apply-templates/></i>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

 <xsl:template match="cnx:meaning">
    <div ep:role="meaning">
      <xsl:call-template name="IdCheck"/>
      <xsl:if test="(count(parent::cnx:definition/cnx:meaning) &gt; 1) or (count(parent::ep:concept/cnx:meaning) &gt; 1)"> 
        <span ep:role="label">
          <xsl:number level="single"/>
          <xsl:if test="(every $x in ($locales/locale[@key='subject_polishLanguage'], $locales/locale[@key='subject_historyAndSociety'], $locales/locale[@key='subject_history'], $locales/locale[@key='subject_civicsEducation']) satisfies not(contains($subject,$x)))">
            <xsl:text>. </xsl:text> 
          </xsl:if>
        </span>
      </xsl:if>
      
      <xsl:if test="(some $x in ($locales/locale[@key='subject_polishLanguage'], $locales/locale[@key='subject_historyAndSociety'], 
        $locales/locale[@key='subject_history'], $locales/locale[@key='subject_civicsEducation']) 
        satisfies contains($subject,$x))
        and ../cnx:term != ''">
        <span>
          <xsl:attribute name="ep:role">title</xsl:attribute>
          <xsl:apply-templates select="../cnx:term/node()"></xsl:apply-templates>
          <xsl:text> </xsl:text>
        </span>
      </xsl:if>
      
      <xsl:if test="some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], 
        $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], 
        $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x)
        and ../cnx:term != '' and parent::node()[local-name()='definition']">
        <div>
          <xsl:attribute name="ep:role">title</xsl:attribute>
          <xsl:apply-templates select="../cnx:term/node()"></xsl:apply-templates>
          <xsl:text> &#150; </xsl:text>
        </div>
      </xsl:if>
      
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="cnx:rule">
    <xsl:element name="div">
      <xsl:attribute name="ep:role">
        <xsl:text>rule</xsl:text>
        <xsl:if test="@type">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@type"/>
        </xsl:if>
        <xsl:apply-templates select="@ep:presentation-variant"/>
      </xsl:attribute>
      <xsl:call-template name="IdCheck"/>
      <xsl:variable name="level-number">
        <xsl:call-template name="level-count"/>
      </xsl:variable>
      <xsl:variable name="module_id" select="ancestor::cnx:document/@module-id"/>
      <xsl:if test="cnx:name or cnx:title or not(cnx:label[not(node())])">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:element name="h{$level-number}">
          <xsl:attribute name="ep:role">rule-header</xsl:attribute>
            <xsl:if test="not(cnx:label[not(node())])">
              <span ep:role="label">
                <xsl:variable name="type" select="translate(@type,$upper,$lower)"/>
                <xsl:choose>
                  <xsl:when test="cnx:label">
                    <xsl:apply-templates select="cnx:label"/>
                  </xsl:when>
                  <xsl:when test="$type='theorem' or $type='lemma' or $type='corollary' or $type='law' or $type='proposition' or $type='property'">
                    <xsl:value-of select="$locales/locale[@key=$type]"/>
                  </xsl:when>
                  <xsl:when test="$version='0.5'">
                    <xsl:value-of select="@type"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$locales/locale[@key='Rule']"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
                <xsl:element name="span">
                  <xsl:attribute name="ep:role">numbering</xsl:attribute>
                  <xsl:element name="span">
                    <xsl:attribute name="ep:role">numbering-prefix</xsl:attribute>
                    <xsl:value-of select="ep:get_number_prefix(ancestor::cnx:document/@module-id)"/>
                  </xsl:element>
                  <xsl:element name="span">
                    <xsl:attribute name="ep:role">numbering-element</xsl:attribute>
                    <xsl:choose>
                      <xsl:when test="$type='rule' or not(@type)">
                        <xsl:number level="any" count="cnx:rule[translate(@type,$upper,$lower)='rule' or not(@type) and ancestor::cnx:document[@module-id=$module_id]]"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:number level="any" count="cnx:rule[translate(@type,$upper,$lower)=$type and ancestor::cnx:document[@module-id=$module_id]]"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:element>
                  <xsl:text>.</xsl:text>
                  <xsl:if test="cnx:name or cnx:title">
                    <xsl:text>&#160;</xsl:text>
                  </xsl:if>
                </xsl:element>
              </span>
            </xsl:if>
            <xsl:apply-templates select="cnx:name|cnx:title"/>
        </xsl:element>
      </xsl:if>
      <div>
        <xsl:attribute name="ep:role">rule-contents</xsl:attribute>
        <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title|self::cnx:label)]"/>
        <xsl:element name="div">
          <xsl:attribute name="ep:role">go-to-glossary</xsl:attribute>
          <xsl:element name="a">
            <xsl:attribute name="href" select="concat('#', @id)"/>
            <xsl:value-of select="ep:getGoToGlossaryLabel(@ep:glossary-merge-type)"/>
          </xsl:element>
        </xsl:element>
        
        <xsl:if test="ep:link[@ep:role='go-back-from-glossary']">
          <xsl:call-template name="create_go_back_link_from_glossary">
            <xsl:with-param name="href" select="ep:link/@href"/>
          </xsl:call-template>
        </xsl:if>  
      </div>
    </xsl:element>
  </xsl:template>

  <xsl:template match="cnx:statement">
    <div ep:role="statement">
      <xsl:call-template name="IdCheck"/>
      <xsl:if test="cnx:name or cnx:title or cnx:label[node()]">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:element name="div">
          <xsl:attribute name="ep:role">statement-header</xsl:attribute>
          <xsl:if test="cnx:label[node()]">
            <span ep:role="label">
              <xsl:apply-templates select="cnx:label"/>
              <xsl:if test="cnx:name or cnx:title">: </xsl:if>
            </span>
          </xsl:if>
          <xsl:apply-templates select="cnx:name|cnx:title"/>
        </xsl:element>
      </xsl:if>
      <div ep:role="statement-contents">
        <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title|self::cnx:label)]"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="cnx:proof">
    <div ep:role="proof">
      <xsl:call-template name="IdCheck"/>
      <xsl:if test="cnx:name or cnx:title or not(cnx:label[not(node())])">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:element name="div">
          <xsl:attribute name="ep:role">proof-header</xsl:attribute>
          <xsl:if test="not(cnx:label[not(node())])">
            <span ep:role="label">
              <xsl:choose>
                <xsl:when test="cnx:label">
                  <xsl:apply-templates select="cnx:label"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$locales/locale[@key='Proof']"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="cnx:name or cnx:title">: </xsl:if>
            </span>
          </xsl:if>
          <xsl:apply-templates select="cnx:name|cnx:title"/>
        </xsl:element>
      </xsl:if>
      <div ep:role="proof-contents">
        <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title|self::cnx:label)]"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="cnx:list">
    <xsl:variable name="list_fullItemPath">
      <xsl:if test="@list-type='enumerated-full-path'">
        <xsl:for-each select="ancestor-or-self::cnx:list[ancestor::cnx:item]">
          <xsl:call-template name="get_item_list_prefix">
            <xsl:with-param name="itemPosition" select="count(ancestor::cnx:item[1]/preceding-sibling::cnx:item)+1"/>
            <xsl:with-param name="listProperties" select="ancestor::cnx:list[1]"/>
          </xsl:call-template>
          <xsl:value-of select="ancestor::cnx:list[1]/@mark-suffix"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$version='0.5'">
        <xsl:choose>
          <xsl:when test="@type='inline'">
            <xsl:call-template name="make-inline-list">
              <xsl:with-param name="list_fullItemPath" select="$list_fullItemPath" tunnel="yes"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="make-block-list">
              <xsl:with-param name="list_fullItemPath" select="$list_fullItemPath" tunnel="yes"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@display='inline'">
        <xsl:call-template name="make-inline-list">
          <xsl:with-param name="list_fullItemPath" select="$list_fullItemPath" tunnel="yes"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-block-list">
          <xsl:with-param name="list_fullItemPath" select="$list_fullItemPath" tunnel="yes"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="make-block-list">
    <div>
      <xsl:attribute name="ep:role">
        <xsl:text>list</xsl:text>
        <xsl:if test="ep:add_additional_class_for_block_elements(.) != ''">
          <xsl:attribute name="ep:role">
            <xsl:value-of select="ep:add_additional_class_for_block_elements(.)"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:attribute>
      <xsl:if test="@display='none'">
        <xsl:attribute name="style">display: none</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@id"/>
      <xsl:if test="cnx:name[node()] or cnx:title[node()] or cnx:label[node()]">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:element name="div">
          <xsl:attribute name="ep:role">list-header</xsl:attribute>
          <xsl:if test="cnx:label[node()]">
            <span ep:role="label">
              <xsl:apply-templates select="cnx:label"/>
              <xsl:if test="cnx:title">
                <xsl:text>: </xsl:text>
              </xsl:if>
            </span>
          </xsl:if>
	  <xsl:apply-templates select="cnx:name|cnx:title"/>
        </xsl:element>
      </xsl:if>
      <xsl:variable name="stepwise">
        <xsl:call-template name="class-test">
          <xsl:with-param name="provided-class" select="normalize-space(@class)"/>
          <xsl:with-param name="wanted-class">stepwise</xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="list-element">
        <xsl:choose>
          <xsl:when test="contains(@list-type,'enumerated') or (@type='enumerated' and $version='0.5')">ol</xsl:when>
          <xsl:otherwise>ul</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:element name="{$list-element}">
        <xsl:attribute name="ep:role">
          <xsl:choose>
            <xsl:when test="@list-type='enumerated-full-path'">enumerated enumerated-full-path</xsl:when>
            <xsl:when test="@list-type='labeled-item' or (@type='named-item' and $version='0.5')">labeled-item</xsl:when>
            <xsl:when test="@bullet-style='bullet' or (@list-type='bulleted' and not(@bullet-style)) or (not(@list-type) and not(@bullet-style))">bullet</xsl:when>
            <xsl:when test="@bullet-style='open-circle'">open-circle</xsl:when>
            <xsl:when test="@number-style='arabic' or (@list-type='enumerated' and not(@number-style))">enumerated</xsl:when>
            <xsl:when test="@number-style='upper-alpha'">upper-alpha</xsl:when>
            <xsl:when test="@number-style='lower-alpha'">lower-alpha</xsl:when>
            <xsl:when test="@number-style='upper-roman'">upper-roman</xsl:when>
            <xsl:when test="@number-style='lower-roman'">lower-roman</xsl:when>
            <xsl:otherwise>other</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:for-each select="cnx:item">
          <li ep:role="item">
            <xsl:call-template name="IdCheck"/>
            <xsl:if test="parent::cnx:list[@start-value] and position() = 1">
              <xsl:attribute name="value">
                <xsl:value-of select="parent::cnx:list/@start-value"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="parent::cnx:list[(@bullet-style!='bullet' and @bullet-style!='open-circle' and @bullet-style!='none') or
                                            @list-type='labeled-item' or
                                            @mark-prefix or
                                            @mark-suffix or
                                            @list-type='enumerated' or
                                            @list-type='enumerated-full-path']">
              <xsl:call-template name="item-decoration"/>
            </xsl:if>
            <xsl:call-template name="item-contents"/>
          </li>
        </xsl:for-each>
      </xsl:element>
    </div>
  </xsl:template>
  
  <xsl:template name="make-inline-list">
    <xsl:text> </xsl:text>
    <span>
      <xsl:attribute name="ep:role">
        <xsl:text>list</xsl:text>
        <xsl:if test="ep:add_additional_class_for_block_elements(.) != ''">
          <xsl:attribute name="ep:role">
            <xsl:value-of select="ep:add_additional_class_for_block_elements(.)"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:attribute>
      
      <xsl:call-template name="IdCheck"/>
      <xsl:if test="cnx:label[node()]">
        <span ep:role="label">
          <xsl:apply-templates select="cnx:label"/>
          <xsl:text>: </xsl:text>
        </span>
      </xsl:if>
      <xsl:apply-templates select="cnx:name|cnx:title"/>
      <xsl:for-each select="cnx:item">
        <span ep:role="item">
          <xsl:call-template name="IdCheck"/>
          <xsl:call-template name="item-decoration"/>
          <xsl:call-template name="item-contents"/>
        </span>
      </xsl:for-each>
    </span>
  </xsl:template>
  
  <xsl:template name="get_item_list_prefix">
    <xsl:param name="listProperties"/>
    <xsl:param name="itemPosition"/>
    
    <xsl:variable name="start-value">
      <xsl:choose>
        <xsl:when test="$listProperties[@start-value]">
          <xsl:value-of select="$listProperties/@start-value"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$listProperties[@number-style='upper-alpha']">
        <xsl:number format="A" value="$itemPosition + $start-value - 1"/>
      </xsl:when>
      <xsl:when test="$listProperties[@number-style='lower-alpha']">
        <xsl:number format="a" value="$itemPosition + $start-value - 1"/>
      </xsl:when>
      <xsl:when test="$listProperties[@number-style='upper-roman']">
        <xsl:number format="I" value="$itemPosition + $start-value - 1"/>
      </xsl:when>
      <xsl:when test="$listProperties[@number-style='lower-roman']">
        <xsl:number format="i" value="$itemPosition + $start-value - 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number format="1" value="$itemPosition + $start-value - 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="item-decoration">
    <xsl:param name="list_fullItemPath" tunnel="yes"/>
    
    <xsl:variable name="stepwise">
      <xsl:call-template name="class-test">
        <xsl:with-param name="provided-class" select="normalize-space(parent::cnx:list/@class)"/>
        <xsl:with-param name="wanted-class">stepwise</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="item-decoration-element">
      <xsl:choose>
        <xsl:when test="parent::cnx:list[@list-type='labeled-item']">strong</xsl:when>
        <xsl:otherwise>span</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$item-decoration-element}">
      <xsl:attribute name="ep:role">item-decoration</xsl:attribute>
      <xsl:choose>
        <xsl:when test="parent::cnx:list[@list-type='enumerated-full-path']">
          <xsl:value-of select="$list_fullItemPath"></xsl:value-of>
          
          <xsl:call-template name="get_item_list_prefix">
            <xsl:with-param name="itemPosition" select="position()"/>
            <xsl:with-param name="listProperties" select="parent::cnx:list"/>
          </xsl:call-template>
          <xsl:value-of select="parent::cnx:list/@mark-suffix"/>
            
        </xsl:when>
        <xsl:otherwise>
      <xsl:if test="parent::cnx:list[$stepwise='1' and @list-type='enumerated']">
        <xsl:value-of select="$locales/locale[@key='Step']"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:if test="not(parent::cnx:list[@list-type='labeled-item'] and (not(cnx:label) or cnx:label[not(node())]))">
        <xsl:value-of select="parent::cnx:list/@mark-prefix"/>
      </xsl:if>
      <xsl:if test="parent::cnx:list[not(@list-type='labeled-item' or @list-type='enumerated' or @bullet-style)]">
        <xsl:text>•</xsl:text>
      </xsl:if>
      <xsl:if test="parent::cnx:list[@bullet-style]">
        <xsl:choose>
          <xsl:when test="parent::cnx:list[@bullet-style='bullet']">•</xsl:when>
          <xsl:when test="parent::cnx:list[@bullet-style='open-circle']">○</xsl:when>
          <xsl:when test="parent::cnx:list[@bullet-style='pilcrow']">¶</xsl:when>
          <xsl:when test="parent::cnx:list[@bullet-style='rpilcrow']">⁋</xsl:when>
          <xsl:when test="parent::cnx:list[@bullet-style='asterisk']">*</xsl:when>
          <xsl:when test="parent::cnx:list[@bullet-style='dash']">–</xsl:when>
          <xsl:when test="parent::cnx:list[@bullet-style='section']">§</xsl:when>
          <xsl:when test="parent::cnx:list[@bullet-style='none']"/>
          <xsl:otherwise>
            <xsl:value-of select="parent::cnx:list/@bullet-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="parent::cnx:list[@list-type='enumerated']">
        <xsl:call-template name="get_item_list_prefix">
          <xsl:with-param name="itemPosition" select="position()"/>
          <xsl:with-param name="listProperties" select="parent::cnx:list"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="parent::cnx:list[@list-type='labeled-item']">
        <xsl:apply-templates select="cnx:label"/>
        <xsl:if test="not(cnx:label) or cnx:label[not(node())]">
        </xsl:if>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="parent::cnx:list[@list-type='labeled-item'] and not(cnx:label[node()])"/>
        <xsl:when test="parent::cnx:list[@mark-suffix]">
          <xsl:value-of select="parent::cnx:list/@mark-suffix"/>
        </xsl:when>
        <xsl:when test="parent::cnx:list[@list-type='enumerated']">
          <xsl:text>.</xsl:text>
        </xsl:when>
        <xsl:when test="parent::cnx:list[@list-type='labeled-item']">
          <xsl:text>:</xsl:text>
        </xsl:when>
      </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:if test="not(parent::cnx:list[@list-type='labeled-item'] and not(cnx:label[node()]))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="item-contents">
    <xsl:choose>
      <xsl:when test="parent::cnx:list[@list-type='labeled-item']">
        <xsl:apply-templates select="*[not(self::cnx:label)]|text()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="position()!=last()">
      <xsl:choose>
        <xsl:when test="parent::cnx:list[@item-sep]">
          <xsl:value-of select="parent::cnx:list/@item-sep"/>
        </xsl:when>
        <xsl:when test="parent::cnx:list[(@type='inline' and $version='0.5') or @display='inline']">
          <xsl:text>;</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="class-test">
    <xsl:param name="provided-class"/>
    <xsl:param name="wanted-class"/>
    <xsl:if test="$provided-class = $wanted-class or
                  starts-with($provided-class, concat($wanted-class, ' ')) or
                  contains($provided-class, concat(' ', $wanted-class, ' ')) or
                  substring($provided-class, string-length($provided-class) - string-length($wanted-class)) = concat(' ', $wanted-class)">
      1
    </xsl:if>
  </xsl:template>

  <xsl:template match="cnx:equation">
    <div>
      <xsl:attribute name="ep:role">
        <xsl:text>equation</xsl:text>
        <xsl:if test="ep:add_additional_class_for_block_elements(.) != ''">
          <xsl:attribute name="ep:role">
            <xsl:value-of select="ep:add_additional_class_for_block_elements(.)"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:attribute>
      <xsl:call-template name="IdCheck"/> 
      <xsl:apply-templates select="@*"/>
      <xsl:if test="cnx:name[node()] or cnx:title[node()] or @name or cnx:label[node()]">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:element name="div">
          <xsl:attribute name="ep:role">equation-header</xsl:attribute>
          <xsl:if test="cnx:label[node()]">
            <span ep:role="label">
              <xsl:apply-templates select="cnx:label"/>
              <xsl:if test="cnx:title">
                <xsl:text>: </xsl:text>
              </xsl:if>
            </span>
          </xsl:if>
    <xsl:value-of select="@name"/>
          <xsl:apply-templates select="cnx:name|cnx:title"/>
        </xsl:element>
      </xsl:if>
      <div>
        <xsl:attribute name="ep:role">equation-contents</xsl:attribute>
        <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title|self::cnx:label)]|text()"/>
      </div>
      <xsl:choose>
        <xsl:when test="cnx:label[not(node())]"/>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="cnx:figure">
    <xsl:call-template name="figure"/>
  </xsl:template>

  <xsl:template name="figure">
    <div ep:role="figure">
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@*"/>
      <table border="0" cellpadding="0" cellspacing="0" align="center" width="50%">
        <xsl:call-template name="caption"/>
        <xsl:if test="cnx:name[node()] or cnx:title[node()] or @name">
          <thead>
            <tr>
              <th ep:role="figure-header">
                <xsl:value-of select="@name"/>
                <xsl:apply-templates select="cnx:name|cnx:title"/>
              </th>
            </tr>
          </thead>
        </xsl:if>
        <tbody>
          <tr>
            <td ep:role="figure-content">
              <xsl:choose>
                <xsl:when test="cnx:subfigure">
                  <xsl:choose>
                    <xsl:when test="@orient='vertical'">
                      <xsl:apply-templates select="cnx:subfigure"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="horizontal"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="*[not(self::cnx:caption|self::cnx:name|self::cnx:title|self::cnx:label)]"/>
                </xsl:otherwise>
              </xsl:choose>
	           </td>
          </tr>
        </tbody>
      </table>
    </div>
  </xsl:template>
  
  <xsl:template match="cnx:subfigure[parent::cnx:figure[@orient='vertical']]">
    <table ep:role="vertical-subfigure">
      <xsl:call-template name="IdCheck"/>
      <xsl:if test="cnx:name or cnx:title">
        <thead>
          <tr>
            <th ep:role="vertical-subfigure-header">
              <xsl:apply-templates select="cnx:name|cnx:title"/>
            </th>
          </tr>
        </thead>
      </xsl:if>
      <tfoot>
        <tr>
          <xsl:call-template name="caption"/>
        </tr>
      </tfoot>
      <tbody>
        <tr>
          <td ep:role="vertical-subfigure-content">
            <xsl:apply-templates select="*[not(self::cnx:caption|self::cnx:name|self::cnx:title|self::cnx:label)]"/>
         </td>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="horizontal">
    <table ep:role="horizontal-subfigure">
      <xsl:if test="cnx:subfigure/cnx:name or cnx:subfigure/cnx:title">
        <thead valign="bottom">
          <tr>
            <xsl:for-each select="cnx:subfigure">
              <th ep:role="horizontal-subfigure-header">
                <xsl:apply-templates select="cnx:name|cnx:title"/>
              </th>
            </xsl:for-each>
          </tr>
        </thead>
      </xsl:if>
      <tfoot>
        <tr>
          <xsl:for-each select="cnx:subfigure">
            <xsl:call-template name="caption"/>
          </xsl:for-each>
        </tr>
      </tfoot>
      <tbody>
        <tr>
          <xsl:for-each select="cnx:subfigure">
            <td ep:role="horizontal-subfigure-content">
              <xsl:call-template name="IdCheck"/>
              <xsl:apply-templates select="*[not(self::cnx:caption|self::cnx:name|self::cnx:title|self::cnx:label)]"/>
            </td>
          </xsl:for-each>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="caption">
    <xsl:param name="captionelement">
      <xsl:choose>
        <xsl:when test="parent::cnx:figure">th</xsl:when>
        <xsl:otherwise>caption</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:element name="{$captionelement}">
      <xsl:apply-templates select="@*"/>
      <xsl:if test="cnx:caption[@id]">
        <xsl:attribute name="id">
          <xsl:value-of select="cnx:caption/@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="ep:role">
        <xsl:choose>
          <xsl:when test="parent::cnx:figure[@orient='vertical']">vertical-subfigure-caption</xsl:when>
          <xsl:when test="parent::cnx:figure">horizontal-subfigure-caption</xsl:when>
          <xsl:otherwise>figure-caption</xsl:otherwise>
        </xsl:choose>
        <xsl:text> caption</xsl:text>
      </xsl:attribute>
      <xsl:if test="$captionelement='caption'">
        <xsl:attribute name="align">bottom</xsl:attribute>
      </xsl:if>
      <strong ep:role="label">
        <xsl:choose>
          <xsl:when test="self::cnx:subfigure and not(cnx:label[not(node())])">
            <xsl:if test="cnx:label">
              <xsl:apply-templates select="cnx:label"/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:variable name="type" select="translate(@type,$upper,$lower)"/>
            <xsl:choose>
              <xsl:when test="@type and $type!='subfigure'">
                <xsl:number level="any" count="cnx:subfigure[translate(@type,$upper,$lower)=$type]"/>
                <xsl:if test="cnx:caption">
                  <xsl:text>:</xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:number format="(a)" count="cnx:subfigure[not(@type) or translate(@type,$upper,$lower)='subfigure']"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text> </xsl:text>
	        </xsl:when>
          <xsl:otherwise>
            <xsl:if test="not(cnx:label[not(node())])">
              <xsl:choose>
                <xsl:when test="cnx:label[node()]">
                  <xsl:apply-templates select="cnx:label"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$locales/locale[@key='Figure']"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text> </xsl:text>
              <xsl:variable name="type" select="translate(@type,$upper,$lower)"/>
              <xsl:choose>
                <xsl:when test="@type and $type!='figure'">
                  <xsl:number level="any" count="cnx:figure[translate(@type,$upper,$lower)=$type]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:number level="any" count="cnx:figure[not(@type) or translate(@type,$upper,$lower)='figure']"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="cnx:caption">
                <xsl:text>: </xsl:text>
              </xsl:if>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </strong>
      <xsl:apply-templates select="cnx:caption"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="cnx:caption">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="cnx:exercise">
    <div>
      <xsl:attribute name="ep:role">
        <xsl:text>exercise</xsl:text>
        <xsl:if test="descendant::ep:config">
          <xsl:text> </xsl:text>
          <xsl:text>dynamic</xsl:text>
        </xsl:if>
        <xsl:if test="@type">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@type"></xsl:value-of>
        </xsl:if>
        <xsl:if test="@ep:on-paper = 'true'">
          <xsl:text> on-paper</xsl:text>
        </xsl:if>
        <xsl:apply-templates select="@ep:presentation-variant"/>
        
        <xsl:if test="parent::cnx:section and @ep:stretch != $locales/locale[@key='stretch-extended-shifted-width']">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ep:stretch"/>
        </xsl:if>
        
        <xsl:if test="@ep:foldable='true'">
          <xsl:text> foldable</xsl:text>
        </xsl:if>
        <xsl:if test="@ep:content-status='expanding'">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ep:content-status"/>
        </xsl:if>
        
        <xsl:if test="child::ep:work-area">
          <xsl:text> open-question</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:call-template name="IdCheck"/>
      <xsl:variable name="level-number">
        <xsl:call-template name="level-count"/>
      </xsl:variable>
      <xsl:apply-templates select="@ep:id|@ep:interactivity"/>
      <xsl:if test="cnx:name or cnx:title or not(cnx:label[not(node())])">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:if test="not(ancestor::ep:student-work) or (ancestor::ep:student-work and count(following-sibling::cnx:exercise) > 0 or count(preceding-sibling::cnx:exercise) > 0)">
          <xsl:element name="h{$level-number}">
            <xsl:attribute name="ep:role">
              <xsl:text>exercise-header</xsl:text>
              <xsl:if test="@ep:foldable='true'">
                <xsl:text> foldable-header</xsl:text>
              </xsl:if>
            </xsl:attribute>
              <xsl:if test="not(cnx:label[not(node())])">
                <xsl:variable name="type" select="translate(@type|@ep:type,$upper,$lower)"/>
                <span ep:role="label">
                  <xsl:choose>
                    <xsl:when test="cnx:label">
                      <xsl:apply-templates select="cnx:label"/>
                    </xsl:when>
                    <xsl:when test="parent::node()[local-name()='student-work' and @ep:type='exercise-set']">
                      <xsl:value-of select="$locales/locale[@key='SubExercise']"/>
                    </xsl:when>
                    <xsl:when test="@type">
                      <xsl:value-of select="$locales/locale[@key=current()/@type]"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$locales/locale[@key='Exercise']"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text> </xsl:text>
                  <xsl:if test="parent::node()[local-name()!='student-work']">
                    <xsl:call-template name="create_numbering_span_elements">
                      <xsl:with-param name="type" select="$type"></xsl:with-param>
                    </xsl:call-template>
                  </xsl:if>
                </span>
                
                <xsl:if test="parent::node()[local-name()='student-work' and @ep:type='exercise-set']">
                  <xsl:call-template name="create_numbering_span_elements">
                    <xsl:with-param name="type" select="$type"></xsl:with-param>
                  </xsl:call-template>
                </xsl:if>
                
              </xsl:if>
              <xsl:apply-templates select="cnx:name|cnx:title"/>
            <xsl:if test="ep:effect-of-education">
              <xsl:element name="span">
                <xsl:attribute name="ep:role" select="'effect-of-education'"/>
                <xsl:element name="span">
                  <xsl:attribute name="ep:role" select="'effect-of-education-label'"/>
                  <xsl:value-of select="$locales/locale[@key='DifficultyLevel']"/>
                  <xsl:text>:</xsl:text> 
                </xsl:element>
                <xsl:element name="span">
                  <xsl:attribute name="ep:role">
                    <xsl:text>effect-of-education</xsl:text>
                    <xsl:text>-</xsl:text> 
                    <xsl:value-of select="ep:effect-of-education"/>
                  </xsl:attribute>
                  <xsl:variable name="effect-of-education-text" select="ep:effect-of-education/text()"></xsl:variable>
                  <xsl:value-of select="$locales/locale[@key=$effect-of-education-text]"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:if>
      </xsl:if>

      <div>
        <xsl:attribute name="ep:role">
          <xsl:text>exercise-contents</xsl:text>
          <xsl:if test="@ep:foldable='true'">
            <xsl:text> foldable-contents</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title|self::cnx:label|self::ep:effect-of-education|self::ep:config)]"/>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="ep:work-area">
    <div>
      <xsl:attribute name="ep:role">
        <xsl:text>work-area-container</xsl:text>
        <xsl:if test="parent::ep:command">
          <xsl:text> note-ignore</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <textarea ep:role="work-area"/>
    </div>
  </xsl:template>
  
  <xsl:template name="create_numbering_span_elements">
    <xsl:param name="type"></xsl:param>
    
    <xsl:element name="span">
      <xsl:attribute name="ep:role">numbering</xsl:attribute>
      <xsl:text> </xsl:text>
      <xsl:element name="span">
        <xsl:attribute name="ep:role">numbering-prefix</xsl:attribute>
          <xsl:value-of select="ep:get_number_prefix(ancestor::cnx:document/@module-id)"/>        
      </xsl:element>
      <xsl:element name="span">
        <xsl:attribute name="ep:role">numbering-element</xsl:attribute>
        <xsl:variable name="module_id" select="substring-before(@id|@ep:id, '_')"/>
        <xsl:choose>
          <xsl:when test="parent::node()/@ep:type = 'exercise-set'">
            <xsl:choose>
              <xsl:when test="some $x in ($locales/locale[@key='subject_polishLanguage'], 
                $locales/locale[@key='subject_historyAndSociety'], 
                $locales/locale[@key='subject_history'], 
                $locales/locale[@key='subject_civicsEducation']) 
                satisfies contains($subject,$x)">
                <xsl:variable name="exercise_position_prefix">
                  <xsl:number level="any"
                    count="cnx:exercise[not(parent::node()/@ep:type or parent::node()/@ep:type != 'exercise-set') and ancestor::cnx:document[@module-id=$module_id]]
                    | ep:student-work[@ep:type='exercise-set' and ancestor::cnx:document[@module-id=$module_id]]"
                  />
                </xsl:variable>
                <xsl:variable name="exercise_position_element">
                  <xsl:number format="1" count="cnx:exercise"/>
                </xsl:variable>
                <xsl:value-of select="concat($exercise_position_prefix,'.',$exercise_position_element)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="exercise_position">
                  <xsl:number format="A" count="cnx:exercise"/>
                </xsl:variable>
                <xsl:value-of select="$exercise_position"/>
              </xsl:otherwise>
            </xsl:choose>            
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when
                test="some $x in ($locales/locale[@key='subject_polishLanguage'], 
                                          $locales/locale[@key='subject_historyAndSociety'], 
                                          $locales/locale[@key='subject_history'], 
                                          $locales/locale[@key='subject_civicsEducation']) 
                                   satisfies contains($subject,$x)">
                <xsl:variable name="exercise_position">
                  <xsl:number level="any"
                    count="cnx:exercise[not(parent::node()/@ep:type or parent::node()/@ep:type != 'exercise-set') and ancestor::cnx:document[@module-id=$module_id]]
                    | ep:student-work[@ep:type='exercise-set' and ancestor::cnx:document[@module-id=$module_id]]"
                  />
                </xsl:variable>
                <xsl:value-of select="$exercise_position + ep:get_associated_exercise_type_count(., $module_id) + ep:get_prev_modules_exercise_count($module_id, '')"/>
              </xsl:when>
              <xsl:when test="@type|@ep:type">
                <xsl:variable name="exercise_position">
                  <xsl:number level="any"
                    count="cnx:exercise[translate(@type,$upper,$lower)=$type and not(parent::node()/@ep:type or parent::node()/@ep:type != 'exercise-set') and ancestor::cnx:document[@module-id=$module_id]]
                    | ep:student-work[@ep:type='exercise-set' and ancestor::cnx:document[@module-id=$module_id]]"
                  />
                </xsl:variable>
                <xsl:value-of
                  select="$exercise_position + ep:get_associated_exercise_type_count(., $module_id) + ep:get_prev_modules_exercise_count($module_id, @type|@ep:type)"
                /> 
              </xsl:when>
              <xsl:when test="ancestor::cnx:example">
                <xsl:number level="any" from="cnx:example" count="cnx:exercise[not(parent::node()/@ep:type or parent::node()/@ep:type != 'exercise-set') and ancestor::cnx:document[@module-id=$module_id]]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="exercise_position">
                  <xsl:number level="any"
                    count="cnx:exercise[not(ancestor::cnx:example) and (not(@type|@ep:type) or translate(@type|@ep:type,$upper,$lower)='exercise') 
                          and not(parent::node()/@ep:type or parent::node()/@ep:type != 'exercise-set') and ancestor::cnx:document[@module-id=$module_id]]"/>
                </xsl:variable>
                <xsl:value-of
                  select="$exercise_position + ep:get_associated_exercise_type_count(., $module_id) + ep:get_prev_modules_exercise_count($module_id, '')"
                />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:element>
      <xsl:element name="span">
        <xsl:attribute name="ep:role">numbering-end-character</xsl:attribute>
        <xsl:if
          test="not(parent::node()/@ep:type or parent::node()/@ep:type != 'exercise-set') or 
          (some $x in ($locales/locale[@key='subject_polishLanguage'], 
          $locales/locale[@key='subject_historyAndSociety'], 
          $locales/locale[@key='subject_history'], 
          $locales/locale[@key='subject_civicsEducation']) 
          satisfies contains($subject,$x))">
          <xsl:text>.</xsl:text>
          <xsl:if test="(cnx:name or cnx:title) and (cnx:name != '' or cnx:title != '')">
            <xsl:text>&#160;</xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="ep:alternatives|ep:alternative|ep:formats|ep:format">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="cnx:problem|cnx:commentary">
    <xsl:variable name="javascriptpresent" select="/module/display/javascriptpresent"/>
    <xsl:variable name="local-name" select="local-name()"></xsl:variable>
    <xsl:if test="$local-name = 'commentary'">    
      <xsl:variable name="commentary-number">
        <xsl:number count="cnx:commentary"/>
      </xsl:variable>
      <div ep:role="commentary-toggles">
        <xsl:attribute name="style">
          <xsl:choose>
            <xsl:when test="$javascriptpresent='true'">
              <xsl:text>display: block;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>display: none;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:variable name="show-commentary">
          <xsl:choose>
            <xsl:when test="@type = 'example'">
              <xsl:value-of select="$locales/locale[@key='ShowCommentaryExample']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$locales/locale[@key='ShowCommentary']"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="hide-commentary">
          <xsl:choose>
            <xsl:when test="@type = 'example'">
              <xsl:value-of select="$locales/locale[@key='HideCommentaryExample']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$locales/locale[@key='HideCommentary']"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <input type="button" ep:role="commentary-toggle" value="{$show-commentary}" onclick="toggleCommentary('{../@id}',{$commentary-number}); return false;"></input>
        <input type="button" ep:role="commentary-toggle" value="{$hide-commentary}" onclick="toggleCommentary('{../@id}',{$commentary-number}); return false;" style="display: none;"></input>
      </div>
    </xsl:if>
    <div>
      <xsl:attribute name="ep:role">
        <xsl:value-of select="$local-name"></xsl:value-of>
        <xsl:if test="@type">
          <xsl:text> </xsl:text>
          <xsl:value-of select="concat('commentary-', @type)"></xsl:value-of>
        </xsl:if>
      </xsl:attribute>
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@ep:*"/>
      <xsl:attribute name="style">
        <xsl:choose>
          <xsl:when test="$javascriptpresent='true'">
            <xsl:text>display: none;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>display: block;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="cnx:label[node()] or cnx:name or cnx:title or parent::ep:command">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:if test="not(parent::ep:command) or (parent::ep:command and count(parent::ep:command/child::cnx:problem) > 1)">
        <xsl:element name="div">
          <xsl:attribute name="ep:role" select="concat($local-name, '-header')"></xsl:attribute>
          <xsl:if test="cnx:label[node()]">
            <span ep:role="label">
              <xsl:apply-templates select="cnx:label"/>
              <xsl:if test="cnx:name or cnx:title">: </xsl:if>
            </span>
          </xsl:if>
          <xsl:if test="parent::ep:command">
            <span ep:role="label">
              <xsl:value-of select="$locales/locale[@key=$local-name]"/>
              <xsl:text> </xsl:text>
              
              <xsl:if test="every $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies not(contains($subject,$x))">
                <xsl:element name="span">
                  <xsl:attribute name="ep:role">numbering</xsl:attribute>
                  <xsl:text> </xsl:text>
                  <xsl:element name="span">
                    <xsl:attribute name="ep:role">numbering-element</xsl:attribute>
                    <xsl:number level="single"/>
                  </xsl:element>
                  <xsl:element name="span">
                    <xsl:attribute name="ep:role">numbering-end-character</xsl:attribute>
                    <xsl:text>.</xsl:text>
                    <xsl:if test="(cnx:name or cnx:title) and (cnx:name != '' or cnx:title != '')">
                      <xsl:text>&#160;</xsl:text>
                    </xsl:if>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
            </span>
            <xsl:if test="some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x)">
              <xsl:element name="span">
                <xsl:attribute name="ep:role">numbering</xsl:attribute>
                <xsl:text> </xsl:text>
                <xsl:element name="span">
                  <xsl:attribute name="ep:role">numbering-element</xsl:attribute>
                  <xsl:number level="single"/>  
                </xsl:element>
                <xsl:element name="span">
                  <xsl:attribute name="ep:role">numbering-end-character</xsl:attribute>
                  <xsl:text>.</xsl:text>
                  <xsl:if test="(cnx:name or cnx:title) and (cnx:name != '' or cnx:title != '')">
                    <xsl:text>&#160;</xsl:text>
                  </xsl:if>
                </xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:if>
          <xsl:apply-templates select="cnx:name|cnx:title"/>
        </xsl:element>
      </xsl:if>
      </xsl:if>
      <div>
        <xsl:attribute name="ep:role" select="concat($local-name, '-contents')"></xsl:attribute>
        <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title|self::cnx:label)]|text()"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="cnx:solution">
    <xsl:variable name="solution-number">
      <xsl:number count="cnx:solution"/>
    </xsl:variable>
    <xsl:variable name="solution-type" select="translate(@type,$upper,$lower)"/>
    <xsl:variable name="solution-letter">
      <xsl:choose>
        <xsl:when test="count(parent::cnx:exercise/cnx:solution[translate(@type,$upper,$lower) = $solution-type]) &gt; 1">
          <xsl:number count="cnx:solution[translate(@type,$upper,$lower) = $solution-type]" format=" A"/>
        </xsl:when>
        <xsl:when test="count(parent::cnx:exercise/cnx:solution[translate(@type,$upper,$lower) = 'solution' or not(@type)]) &gt; 1">
          <xsl:number count="cnx:solution[translate(@type,$upper,$lower) = 'solution' or not(@type)]" format=" A"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="solution-string">Answer</xsl:variable>
    <xsl:variable name="javascriptpresent" select="/module/display/javascriptpresent"/>
    <div ep:role="solution-toggles">
      <xsl:attribute name="style">
        <xsl:choose>
          <xsl:when test="$javascriptpresent='true'">
            <xsl:text>display: block;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>display: none;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:variable name="show-solution">
        <xsl:value-of select="$locales/locale[@key='ShowSolution']"/>
      </xsl:variable>
      <xsl:variable name="hide-solution">
        <xsl:value-of select="$locales/locale[@key='HideSolution']"/>
      </xsl:variable>
      <input type="button" ep:role="solution-toggle" value="{$show-solution}" onclick="toggleSolution('{ancestor::cnx:exercise/@id}',{$solution-number}); return false;"></input>
      <input type="button" ep:role="solution-toggle" value="{$hide-solution}" onclick="toggleSolution('{ancestor::cnx:exercise/@id}',{$solution-number}); return false;" style="display: none;"></input> 
    </div>
    <div ep:role="solution">
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="style">
        <xsl:choose>
          <xsl:when test="$javascriptpresent='true'">
            <xsl:text>display: none;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>display: block;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="cnx:name or cnx:title or not(cnx:label[not(node())])">
        <xsl:variable name="level-number">
          <xsl:call-template name="level-count"/>
        </xsl:variable>
        <xsl:element name="div">
          <xsl:attribute name="ep:role">solution-header</xsl:attribute>
          <xsl:if test="not(cnx:label[not(node())])">
            <span ep:role="label">
              <xsl:choose>
                <xsl:when test="cnx:label">
                  <xsl:apply-templates select="cnx:label"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$locales/locale[@key=$solution-string]"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="$solution-letter"/>
              <xsl:if test="cnx:name or cnx:title">: </xsl:if>
            </span>
          </xsl:if>
          <xsl:apply-templates select="cnx:name|cnx:title"/>
        </xsl:element>
      </xsl:if>
      <div ep:role="solution-contents">
        <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title|self::cnx:label)]"/>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="ep:reference">
    <xsl:copy copy-namespaces="no">
      <xsl:if test="ep:add_additional_class_for_block_elements(.) != ''">
        <xsl:attribute name="ep:role">
          <xsl:value-of select="ep:add_additional_class_for_block_elements(.)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="node()|@*" copy-namespaces="no"></xsl:copy-of>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@ep:recipient">
  </xsl:template>
  
  <xsl:template match="@ep:content-status">
  </xsl:template>
  
  <xsl:template match="@ep:id">
    <xsl:attribute name="id" select="."/>
  </xsl:template>
  
  <xsl:template match="@ep:presentation-variant">
    <xsl:value-of select="concat(' ', .)"></xsl:value-of>
  </xsl:template>
  
  <xsl:template match="ep:*">
    <xsl:element name="div">
      <xsl:attribute name="ep:role">
        <xsl:value-of select="local-name()"></xsl:value-of>
        <xsl:if test="@ep:type">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ep:type"></xsl:value-of>
        </xsl:if>
        <xsl:apply-templates select="@ep:presentation-variant"/>
        <xsl:if test="(some $x in ('observation', 'experiment') satisfies local-name()=$x) 
          and empty(cnx:title/text())">
          <xsl:text> no-title</xsl:text>
        </xsl:if>
        
        <xsl:if test="(some $x in ('hypothesis','instruments','instructions','conclusions','demonstration','revisal','effect') satisfies (local-name()=$x)) 
          and (some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x))">
            <xsl:text> foldable</xsl:text>
        </xsl:if>
        <xsl:if test="local-name() = 'command' and child::ep:work-area">
          <xsl:text> open-question</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates select="@ep:id"/>
      <xsl:if test="not(local-name() = 'student-work' 
        and (some $x in ($locales/locale[@key='subject_polishLanguage'], $locales/locale[@key='subject_historyAndSociety'], $locales/locale[@key='subject_history'], $locales/locale[@key='subject_civicsEducation']) satisfies contains($subject,$x)))">
        <xsl:call-template name="ep-header">
          <xsl:with-param name="element-name" select="local-name()"></xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:element name="div">
        <xsl:attribute name="ep:role">
          <xsl:value-of select="concat(local-name(), '-contents')"/>
          <xsl:if test="(some $x in ('hypothesis','instruments','instructions','conclusions','demonstration','revisal','effect') satisfies (local-name()=$x)) 
            and (some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x))">
            <xsl:text> foldable-contents</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:apply-templates select="*[not(self::cnx:name|self::cnx:title|self::cnx:label)]|text()"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="ep-header">
    <xsl:param name="element-name"></xsl:param>
    <xsl:variable name="level-number">
      <xsl:call-template name="level-count"/>
    </xsl:variable>
    <xsl:variable name="header-element">
      <xsl:choose>
        <xsl:when test="self::ep:lead|
                        self::ep:intro|
                        self::ep:revisal|
                        self::ep:effect|
                        self::ep:prerequisite|
                        self::ep:experiment|
                        self::ep:observation|
                        self::ep:biography|
                        self::ep:event|
                        self::ep:literary-work-description|
                        self::ep:literary-work-summary|
                        self::ep:procedure-instructions|
                        self::ep:gallery|
                        self::ep:command|
                        self::ep:student-work">
            <xsl:value-of select="concat('h', $level-number)"></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>div</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$locales/locale[@key=$element-name]/text()">
      <xsl:element name="{$header-element}">
        <xsl:attribute name="ep:role">
          <xsl:value-of select="concat($element-name, '-header')"/>
          <xsl:if test="@ep:supervised='true'">
            <xsl:text> warning</xsl:text>
          </xsl:if>
          <xsl:if test="(some $x in ('hypothesis','instruments','instructions','conclusions','demonstration','revisal','effect') satisfies (local-name()=$x)) 
            and (some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x))">
            <xsl:text> foldable-header</xsl:text>
          </xsl:if>
        </xsl:attribute>

        <xsl:if test="(some $x in ('observation', 'experiment') satisfies $element-name=$x) 
          and empty(cnx:title/text())">
          <xsl:if test="@ep:supervised='true'">
            <xsl:element name="span">
              <xsl:attribute name="ep:role">warning-message</xsl:attribute>
              <xsl:value-of select="$locales/locale[@key='label_adult_supervision']"></xsl:value-of>
            </xsl:element>
          </xsl:if>
        </xsl:if>

        <span ep:role="label">
          <xsl:variable name="type" select="@ep:type"></xsl:variable>
          
          <xsl:choose>
            <xsl:when test="self::ep:student-work">
              <xsl:value-of select="$locales/locale[@key=$type]"/>
              
              <xsl:if test="$type = 'exercise-set'">
                <xsl:text> </xsl:text>
                <xsl:call-template name="create_numbering_span_elements">
                  <xsl:with-param name="type" select="'womi'"></xsl:with-param>
                </xsl:call-template>
              </xsl:if>
            </xsl:when>
            <xsl:when test="$type = 'debate'">
              <xsl:value-of select="$locales/locale[@key='debate']"/>
            </xsl:when>
            <xsl:when test="self::ep:effect and @ep:type">
              <xsl:value-of select="$locales/locale[@key=$type]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$locales/locale[@key=$element-name]"/>
            </xsl:otherwise>
          </xsl:choose>
            <xsl:call-template name="element_numbering"></xsl:call-template>
          <xsl:if test="@ep:supervised='true' and cnx:title/text() != ''">
              <xsl:element name="span">
                <xsl:attribute name="ep:role">warning-message</xsl:attribute>
                <xsl:value-of select="$locales/locale[@key='label_adult_supervision']"></xsl:value-of>
              </xsl:element>
            </xsl:if>
        </span>
        <xsl:if test="self::ep:problem">
          <xsl:call-template name="element_numbering"></xsl:call-template>
        </xsl:if>
        
        <xsl:if test="cnx:title/text() != ''">
          <xsl:apply-templates select="cnx:title"/>
        </xsl:if>
        
        <xsl:if test="(some $x in ('observation', 'experiment') satisfies $element-name=$x) 
          and empty(cnx:title/text())">
          <span ep:role="title"/>
        </xsl:if>
        
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="element_numbering">
    <xsl:variable name="module_id" select="ancestor::cnx:document/@module-id"/>
    <xsl:variable name="element_name" select="local-name()"/>
    <xsl:variable name="element_type" select="@ep:type"/>
    <xsl:choose>
      <xsl:when test="self::ep:experiment|self::ep:observation|self::ep:tooltip|self::ep:gallery|self::ep:command">
        <xsl:text> </xsl:text>
        <xsl:element name="span">
          <xsl:attribute name="ep:role">numbering</xsl:attribute>
          <xsl:text> </xsl:text>
          <xsl:element name="span">
            <xsl:attribute name="ep:role">numbering-prefix</xsl:attribute>
            <xsl:value-of select="ep:get_number_prefix($module_id)"/>
          </xsl:element>
          <xsl:element name="span">
            <xsl:attribute name="ep:role">numbering-element</xsl:attribute>
            <xsl:choose>
              <xsl:when test="@ep:type=$element_type">
                <xsl:number level="any" count="*[local-name() = $element_name and @ep:type=$element_type 
                  and ancestor::cnx:document[@module-id=$module_id]]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:number level="any" count="*[local-name() = $element_name and not(@ep:type) and ancestor::cnx:document[@module-id=$module_id]]"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          <xsl:element name="span">
            <xsl:attribute name="ep:role">numbering-end-character</xsl:attribute>
            <xsl:text>.</xsl:text>
          </xsl:element>
          <xsl:if test="cnx:title/text() != ''">
            <xsl:text>&#160;</xsl:text>
          </xsl:if>
        </xsl:element>
      </xsl:when>
      <xsl:when test="self::ep:step">
        <xsl:text> </xsl:text>
        <xsl:element name="span">
          <xsl:attribute name="ep:role">numbering</xsl:attribute>
          <xsl:text> </xsl:text>
          <xsl:element name="span">
            <xsl:attribute name="ep:role">numbering-element</xsl:attribute>
            <xsl:number level="single"/>  
          </xsl:element>
          <xsl:text>.</xsl:text>
          <xsl:text>&#160;</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="self::ep:event or self::ep:student-work or (self::ep:procedure-instructions 
        and (every $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], 
        $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) 
        satisfies not(contains($subject,$x))))">
        <xsl:if test="cnx:title/text() != ''">
          <xsl:text>:&#160;</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="ep:biography">
    <xsl:choose>
      <xsl:when test="some $x in ($locales/locale[@key='subject_polishLanguage'], $locales/locale[@key='subject_historyAndSociety'], $locales/locale[@key='subject_history'], $locales/locale[@key='subject_civicsEducation']) satisfies contains($subject,$x)">
        <xsl:call-template name="create_ep_biography_event_uwr"></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="div">
          <xsl:attribute name="ep:role" select="local-name()"/>
          <xsl:apply-templates select="@ep:id|@ep:glossary-merge-type"/>
          <xsl:call-template name="ep-header">
            <xsl:with-param name="element-name" select="local-name()"></xsl:with-param>
          </xsl:call-template>
          <xsl:element name="div">
            <xsl:attribute name="ep:role" select="concat(local-name(), '-contents')"/>
            <xsl:element name="div">
              <xsl:attribute name="ep:role" select="concat(local-name(), '-info')"/>
              <xsl:apply-templates select="ep:name"/>
              <xsl:apply-templates select="ep:reference"/>
              <xsl:element name="div">
                <xsl:attribute name="ep:role" select="concat(local-name(), '-metrics')"/>
                <xsl:apply-templates select="ep:birth|ep:death"/>
              </xsl:element>
              <xsl:apply-templates select="ep:gallery"/>
            </xsl:element>
            <xsl:apply-templates select="ep:content"/>
            <xsl:element name="div">
              <xsl:attribute name="ep:role">go-to-glossary</xsl:attribute>
              <xsl:element name="a">
                <xsl:attribute name="href" select="concat('#', @ep:id)"/>
                <xsl:value-of select="ep:getGoToGlossaryLabel(@ep:glossary-merge-type)"/>
              </xsl:element>
            </xsl:element>
            
            <xsl:if test="ep:link[@ep:role='go-back-from-glossary']">
              <xsl:call-template name="create_go_back_link_from_glossary">
                <xsl:with-param name="href" select="ep:link/@href"/>
              </xsl:call-template>
            </xsl:if>  
          </xsl:element>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="create_ep_biography_event_uwr">
    <xsl:element name="div">
      <xsl:attribute name="ep:role" select="local-name()"/>
      <xsl:apply-templates select="@ep:id"></xsl:apply-templates>
      <xsl:element name="div">
        <xsl:attribute name="ep:role" select="concat(local-name(), '-contents')"/>
        <xsl:apply-templates select="ep:reference"/>
        <xsl:element name="div">
          <xsl:attribute name="ep:role" select="concat(local-name(), '-info')"/>
          <xsl:apply-templates select="ep:name">
            <xsl:with-param name="new_class_name" select="'name-inline'"></xsl:with-param>
          </xsl:apply-templates>
          <xsl:if test="ep:birth|ep:death|ep:event-start|ep:event-end|ep:start|ep:end">
            <xsl:element name="div">
              <xsl:attribute name="ep:role" select="concat(local-name(), '-metrics')"/>
              <xsl:element name="div">
                <xsl:attribute name="ep:role" select="'date-contents'"/>
                <xsl:if test="ep:birth|ep:event-start|ep:start">
                <xsl:call-template name="get_date_by_format">
                  <xsl:with-param name="element" select="ep:birth/ep:date|ep:event-start/ep:date|ep:start/ep:date"/>
                </xsl:call-template>
                </xsl:if>
                <xsl:text>–</xsl:text>
                <xsl:if test="ep:death|ep:event-end|ep:end">
                  <xsl:call-template name="get_date_by_format">
                    <xsl:with-param name="element" select="ep:death/ep:date|ep:event-end/ep:date|ep:end/ep:date"/>
                  </xsl:call-template>
                </xsl:if>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:apply-templates select="ep:content"/>
        </xsl:element>
        <xsl:if test="ep:gallery">
          <xsl:apply-templates select="ep:gallery"/>
        </xsl:if>        
        <xsl:element name="div">
          <xsl:attribute name="ep:role">go-to-glossary</xsl:attribute>
          <xsl:element name="a">
            <xsl:attribute name="href" select="concat('#', @ep:id)"/>
            <xsl:value-of select="ep:getGoToGlossaryLabel(@ep:glossary-merge-type)"/>
          </xsl:element>
        </xsl:element>
        <xsl:if test="ep:link[@ep:role='go-back-from-glossary']">
          <xsl:call-template name="create_go_back_link_from_glossary">
            <xsl:with-param name="href" select="ep:link/@href"/>
          </xsl:call-template>
        </xsl:if>  
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="get_date_by_format">
    <xsl:param name="element" select="''"></xsl:param>
    <xsl:choose>
      <xsl:when test="$element/@ep:type = 'date'">
        <xsl:value-of select="string-join(ep:get_date($element), '')"/>
      </xsl:when>
      <xsl:when test="$element/@ep:type = 'year'">
        <xsl:value-of select="ep:get_year($element)"/>
      </xsl:when>
      <xsl:when test="$element/@ep:type = 'century'">
        <xsl:value-of select="ep:get_century($element)"/>
      </xsl:when>
      <xsl:when test="$element/@ep:type = 'around-year'">
        <xsl:value-of select="ep:get_year($element)"/>
      </xsl:when>
      <xsl:when test="$element/@ep:type = 'beginning-of-century'">
        <xsl:value-of select="ep:get_century($element)"/>
      </xsl:when>
      <xsl:when test="$element/@ep:type = 'end-of-century'">
        <xsl:value-of select="ep:get_century($element)"/>
      </xsl:when>
      <xsl:when test="$element/@ep:type = 'turn-of-century'">
        <xsl:value-of select="ep:get_century($element)"/>
      </xsl:when>
      <xsl:when test="$element/@ep:type = 'middle-of-century'">
        <xsl:value-of select="ep:get_century($element)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string-join(ep:get_date($element), '')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="ep:event">
    <xsl:choose>
      <xsl:when test="some $x in ($locales/locale[@key='subject_polishLanguage'], $locales/locale[@key='subject_historyAndSociety'], $locales/locale[@key='subject_history'], $locales/locale[@key='subject_civicsEducation']) satisfies contains($subject,$x)">
        <xsl:call-template name="create_ep_biography_event_uwr"></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="div">
          <xsl:attribute name="ep:role" select="local-name()"/>
          <xsl:apply-templates select="@ep:id|@ep:glossary-merge-type"/>
          <xsl:call-template name="ep-header">
            <xsl:with-param name="element-name" select="local-name()"/>
          </xsl:call-template>
          <xsl:element name="div">
            <xsl:attribute name="ep:role" select="concat(local-name(), '-contents')"/>
            <xsl:element name="div">
              <xsl:attribute name="ep:role" select="concat(local-name(), '-info')"/>
              <xsl:apply-templates select="ep:name"/>
              <xsl:apply-templates select="ep:reference"/>
              <xsl:element name="div">
                <xsl:attribute name="ep:role" select="concat(local-name(), '-metrics')"/>
                <xsl:apply-templates select="ep:event-start|ep:event-end|ep:start|ep:end"/>
              </xsl:element>
              <xsl:apply-templates select="ep:gallery"/>
            </xsl:element>
            <xsl:apply-templates select="ep:content"/>
            <xsl:element name="div">
              <xsl:attribute name="ep:role">go-to-glossary</xsl:attribute>
              <xsl:element name="a">
                <xsl:attribute name="href" select="concat('#', @ep:id)"/>
                <xsl:value-of select="ep:getGoToGlossaryLabel(@ep:glossary-merge-type)"/>
              </xsl:element>
            </xsl:element>
            <xsl:if test="ep:link[@ep:role='go-back-from-glossary']">
              <xsl:call-template name="create_go_back_link_from_glossary">
                <xsl:with-param name="href" select="ep:link/@href"/>
              </xsl:call-template>
            </xsl:if>  
          </xsl:element>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="ep:problem">
    <xsl:element name="div">
      <xsl:attribute name="ep:role" select="concat('experiment-', local-name())"/>
      <xsl:apply-templates select="@ep:id"></xsl:apply-templates>
      <xsl:call-template name="ep-header">
        <xsl:with-param name="element-name" select="concat('experiment-', local-name())"></xsl:with-param>
      </xsl:call-template>
      <xsl:element name="div">
        <xsl:attribute name="ep:role" select="concat('experiment-', local-name(), '-contents')"></xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="ep:effect">
    <xsl:element name="div">
      <xsl:attribute name="ep:role">
        <xsl:value-of select="local-name()"></xsl:value-of>
        <xsl:if test="@ep:type">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ep:type"></xsl:value-of>
        </xsl:if>
		
		<xsl:if test="some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x)">
			<xsl:text> foldable</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates select="@ep:id"></xsl:apply-templates>
      <xsl:call-template name="ep-header">
        <xsl:with-param name="element-name">
              <xsl:value-of select="local-name()"></xsl:value-of>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:element name="div">
        <xsl:attribute name="ep:role">
          <xsl:value-of select="concat(local-name(), '-contents')"/>
          <xsl:if
            test="some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) satisfies contains($subject,$x)">
            <xsl:text> foldable-contents</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="ep:content|ep:name">
    <xsl:param name="new_class_name"></xsl:param>
    
    <xsl:element name="div">
      <xsl:attribute name="ep:role">
        <xsl:choose>
          <xsl:when test="$new_class_name">
            <xsl:value-of select="$new_class_name"></xsl:value-of>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="local-name()"></xsl:value-of>
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:if test="@ep:format">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ep:format"></xsl:value-of>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates select="node()|@ep:id"/>
    </xsl:element>
  </xsl:template>
    
  
  <xsl:template match="ep:writing|ep:person|ep:event-name">
    <xsl:element name="span">
      <xsl:attribute name="ep:role" select="local-name()"/>
      <xsl:apply-templates select="@ep:*|node()"></xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="ep:canonical">
  </xsl:template>
  
  <xsl:template match="ep:tooltip-reference|ep:event-reference|ep:glossary-reference|ep:biography-reference|ep:bibliography-reference|ep:concept-reference">
    <xsl:variable name="tooltipType" select="substring-before(local-name(), '-reference')"></xsl:variable>
    <xsl:variable name="ref-id" select="@ep:id"/>
    <xsl:variable name="if_add_word_source" select="parent::node()/local-name() = 'source' 
      and ancestor::node()[local-name() = 'definition' or local-name() = 'quote']"></xsl:variable>
    <xsl:choose>
      <xsl:when test="@ep:inline='true' and @ep:local-reference='false'">
        <xsl:variable name="currId">
          <xsl:choose>
            <xsl:when test="starts-with($ref-id, $tooltipType)">
              <xsl:value-of select="$ref-id"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat($tooltipType,'_',$ref-id)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ref_module_id" select="ep:getMappingGlossaryModuleIdByType($tooltipType)"/>
          <xsl:choose>
            <xsl:when test="ep:checkIfExistsHrefGlossaryReference($tooltipType,@ep:target-name, concat('../',$ref_module_id,'#',$currId), $ref-id, .) = false()">
              <xsl:if test="not(unparsed-text-available(concat($resultDir,'/err_missing_glossary_ref')))">
                <xsl:result-document href="file:///{$resultDir}/err_missing_glossary_ref"/>
              </xsl:if>  
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$modules//cnx:document[@id=$ref_module_id]//node()[@id = $currId or @ep:id = $currId]">
                <xsl:with-param name="copied_reference" tunnel="yes">true</xsl:with-param>
                <xsl:with-param name="word_before" tunnel="yes" select="$if_add_word_source"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
      </xsl:when>
      <xsl:when test="@ep:inline='true' and (not(@ep:local-reference) or @ep:local-reference='true')">
        <xsl:choose>
          <xsl:when test="ep:checkIfExistsHrefGlossaryReference($tooltipType,@ep:target-name,concat('#',$ref-id),$ref-id, .) = false()">
            <xsl:if test="not(unparsed-text-available(concat($resultDir,'/err_missing_glossary_ref')))">
              <xsl:result-document href="file:///{$resultDir}/err_missing_glossary_ref"/>
            </xsl:if>  
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="//node()[(@id = $ref-id or @ep:id = $ref-id) and not(contains(local-name(), 'reference'))]">
              <xsl:with-param name="copied_reference" tunnel="yes">true</xsl:with-param>
              <xsl:with-param name="word_before" tunnel="yes" select="$if_add_word_source"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        
        <xsl:variable name="refInElementNameInGeneratedModule">
          <xsl:choose>
            <xsl:when test="ancestor::cnx:document[1]//ep:e-textbook-module/ep:generated-type">
              <xsl:variable name="mappingFileName" select="ep:getMappingGlossaryModuleIdByType($tooltipType)"/>
              <xsl:if test="$mappingFileName != '-1'">
                <xsl:choose>
                  <xsl:when test="contains($mappingFileName,ancestor::cnx:document[1]//ep:e-textbook-module/ep:generated-type)">
                    <xsl:text>OPTION_1</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('../', $mappingFileName, '#')"/>
                    <xsl:if test="not(starts-with(@ep:id,$tooltipType))">
                      <xsl:value-of select="$tooltipType"/>
                      <xsl:text>_</xsl:text>
                    </xsl:if>
                      <xsl:value-of select="@ep:id"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>OPTION_-1</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="hrefData">
          <xsl:choose>
            <xsl:when test="(not(@ep:local-reference) or @ep:local-reference = 'true')
              or ($refInElementNameInGeneratedModule='OPTION_1')">
              <xsl:value-of select="concat('#', @ep:id)"/>
            </xsl:when>
            <xsl:when test="not(starts-with($refInElementNameInGeneratedModule,'OPTION_'))">
              <xsl:value-of select="$refInElementNameInGeneratedModule"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="mappingFileName" select="ep:getMappingGlossaryModuleIdByType($tooltipType)"/>
              <xsl:if test="$mappingFileName != '-1'">
                <xsl:value-of select="concat('../', $mappingFileName, '#')"/>
                <xsl:if test="@ep:local-reference = 'false' and not(starts-with($ref-id,$tooltipType))">
                  <xsl:value-of select="concat($tooltipType,'_')"/>
                </xsl:if>
                <xsl:value-of select="@ep:id"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
    
        <xsl:choose>
          <xsl:when test="ep:checkIfExistsHrefGlossaryReference($tooltipType,@ep:target-name, $hrefData,$ref-id, .) = false()">
            <xsl:if test="not(unparsed-text-available(concat($resultDir,'/err_missing_glossary_ref')))">
              <xsl:result-document href="file:///{$resultDir}/err_missing_glossary_ref"/>
            </xsl:if>  
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="a">
              <xsl:attribute name="ep:role" select="concat('link ', $tooltipType, '-link')"></xsl:attribute>
              <xsl:attribute name="ep:link-type" select="'tooltip'"/>
              <xsl:attribute name="ep:tooltip-type" select="$tooltipType"/>
              <xsl:attribute name="href" select="$hrefData"/>
              
              <xsl:choose>
                <xsl:when test="$refInElementNameInGeneratedModule = 'OPTION_1'">
                  <xsl:attribute name="ep:local-reference" select="'true'"/>
                </xsl:when>
                <xsl:when test="$refInElementNameInGeneratedModule = 'OPTION_-1'">
                  <xsl:apply-templates select="@ep:local-reference"></xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="ep:local-reference" select="'false'"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:apply-templates select="@ep:target-name"></xsl:apply-templates>
              <xsl:apply-templates/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="ep:checkIfExistsHrefGlossaryReference">
    <xsl:param name="tooltipType"/>
    <xsl:param name="targetName"/>
    <xsl:param name="href"/>
    <xsl:param name="idRefInContent"/>
    <xsl:param name="ctx"/>
    
    <xsl:variable name="tokens" select="tokenize($href, '#')"/>
    <xsl:variable name="hrefFile" select="substring-after($tokens[1],'../')"/>
    <xsl:variable name="hrefLoc" select="$tokens[2]"/>
    <xsl:choose>
      <!-- remote href -->
      <xsl:when test="$hrefFile != ''">
        <xsl:if test="not($modules//cnx:document[@id=$hrefFile]//node()[@id = $hrefLoc or @ep:id = $hrefLoc])">
          <xsl:value-of select="ep:printMissingGlossaryElementError($ctx, $idRefInContent, 'remote',$tooltipType,$targetName)"/>
        </xsl:if>
      </xsl:when>
      <!-- local href -->
      <xsl:otherwise>
        <xsl:if test="not($ctx/ancestor::cnx:document//node()[@id = $hrefLoc or @ep:id = $hrefLoc])">
          <xsl:value-of select="ep:printMissingGlossaryElementError($ctx, $idRefInContent, 'local',$tooltipType,$targetName)"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="true()"/>
  </xsl:function>
  
  <xsl:function name="ep:printMissingGlossaryElementError">
    <xsl:param name="ctx"/>
    <xsl:param name="idRefInContent"/>
    <xsl:param name="isLocalRemoteRef"/>
    <xsl:param name="tooltipType"/>
    <xsl:param name="targetName"/>
    <xsl:variable name="currModule" select="$ctx/ancestor::cnx:document"/>
    <xsl:message>
      <xsl:text>[XSLT_ERR] Missing_reference=[</xsl:text>
      <xsl:value-of select="$isLocalRemoteRef"/>
      <xsl:text>|-|</xsl:text>
      <xsl:value-of select="$tooltipType"/>
      <xsl:text>|-|</xsl:text>
      <xsl:value-of select="$idRefInContent"/>
      <xsl:text>|-|</xsl:text>
      <xsl:value-of select="$targetName"/>
      <xsl:text>|-|</xsl:text>
      <xsl:value-of select="$ctx//text()"/>
      <xsl:text>|-|</xsl:text>
      <xsl:value-of select="$currModule/@id"/>
      <xsl:text>|-|</xsl:text>
      <xsl:value-of select="$currModule/cnx:metadata/md:version"/>
      <xsl:text>]</xsl:text>
    </xsl:message>
    <xsl:value-of select="false()"/>
  </xsl:function>

  <!-- specjalna obsluga ep:date  -->
  <xsl:template match="ep:date">
    <xsl:element name="div">
      <xsl:attribute name="ep:role" select="local-name()"/>
      <xsl:variable name="element-name">
        <xsl:choose>
          <xsl:when test="(parent::ep:event-start|parent::ep:start) and not(../(following-sibling::ep:event-end|following-sibling::ep:end))">
            <xsl:value-of select="concat(local-name(), '-occur')"></xsl:value-of>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(local-name(), '-', parent::*/local-name())"></xsl:value-of>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="ep-header">
        <xsl:with-param name="element-name" select="$element-name"></xsl:with-param>
      </xsl:call-template>
      <xsl:element name="div">
        <xsl:attribute name="ep:role" select="concat(local-name(), '-contents')"></xsl:attribute>
        <xsl:choose>
          <xsl:when test="@ep:type = 'date'">
            <xsl:value-of select="string-join(ep:get_date(.), '')"/>
          </xsl:when>
          <xsl:when test="@ep:type = 'year'">
            <xsl:value-of select="ep:get_year(.)"/>
          </xsl:when>
          <xsl:when test="@ep:type = 'century'">
            <xsl:value-of select="ep:get_century(.)"/>
          </xsl:when>
          <xsl:when test="@ep:type = 'around-year'">
            <xsl:value-of select="ep:get_year(.)"/>
          </xsl:when>
          <xsl:when test="@ep:type = 'beginning-of-century'">
            <xsl:value-of select="ep:get_century(.)"/>
          </xsl:when>
          <xsl:when test="@ep:type = 'end-of-century'">
            <xsl:value-of select="ep:get_century(.)"/>
          </xsl:when>
          <xsl:when test="@ep:type = 'turn-of-century'">
            <xsl:value-of select="ep:get_century(.)"/>
          </xsl:when>
          <xsl:when test="@ep:type = 'middle-of-century'">
            <xsl:value-of select="ep:get_century(.)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="string-join(ep:get_date(.), '')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="ep:location">
    <xsl:element name="div">
      <xsl:attribute name="ep:role" select="local-name()"/>
      <xsl:apply-templates select="@ep:id"></xsl:apply-templates>
      <xsl:variable name="element-name">
        <xsl:choose>
          <xsl:when test="(parent::ep:event-start|parent::ep:start) and not(../(following-sibling::ep:event-end|following-sibling::ep:end))">
            <xsl:value-of select="concat(local-name(), '-occur')"></xsl:value-of>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(local-name(), '-', parent::*/local-name())"></xsl:value-of>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="ep-header">
        <xsl:with-param name="element-name" select="$element-name"></xsl:with-param>
      </xsl:call-template>
      <xsl:element name="div">
        <xsl:attribute name="ep:role" select="concat(local-name(), '-contents')"/>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="ep:gallery">
    <xsl:element name="div">
      <xsl:attribute name="ep:role">
        <xsl:value-of select="local-name()"/>

        <xsl:value-of select="ep:add_additional_class_for_block_elements(.)"/>
      </xsl:attribute> 
      <xsl:apply-templates select="@ep:*"/>
      <xsl:call-template name="ep-header">
        <xsl:with-param name="element-name" select="local-name()"></xsl:with-param>
      </xsl:call-template>
      <xsl:element name="div">
        <xsl:attribute name="ep:role" select="concat(local-name(), '-contents')"/>
        <xsl:apply-templates select="ep:content"></xsl:apply-templates>
        <xsl:element name="ol">
          <xsl:for-each select="ep:reference">
            <xsl:element name="li">
              <xsl:apply-templates select="."></xsl:apply-templates>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="ep:bookmark">
    <xsl:element name="span">
      <xsl:attribute name="ep:role" select="local-name()"/>
      <xsl:apply-templates select="@*"></xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="ep:author">
    <xsl:choose>
      <xsl:when test="count(preceding-sibling::ep:author)=0"></xsl:when>
      <xsl:when test="count(preceding-sibling::ep:author)>0">, </xsl:when>
    </xsl:choose>
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="ep:technical-remarks">
      <xsl:element name="div">
        <xsl:attribute name="ep:role" select="local-name()"/>
        <xsl:apply-templates select="@ep:id"></xsl:apply-templates>
        <xsl:element name="div">
          <xsl:attribute name="ep:role" select="concat(local-name(), '-contents')"/>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:element>
  </xsl:template>
  
  <xsl:template match="ep:fold-point">
    <span ep:role="fold-point"/>
  </xsl:template>
  
  <xsl:template match="ep:zebra-point">
    <xsl:if test="ancestor::node()[2]/local-name()='content'
      and (preceding-sibling::node()[local-name() != '' and local-name() !='parameters'][1]/local-name() != 'zebra-point')
      and following-sibling::node()[local-name() != ''][1]
      and parent::node()[not(ep:parameters/ep:columns) or (ep:parameters/ep:columns/text()='1')]">
      <div ep:role="strip-end"/>
      <div ep:role="strip-start"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="ep:mathElement" priority="1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="ep:nbsp">
    <xsl:text>&#160;</xsl:text>
  </xsl:template>
  
  <xsl:template match="ep:tab">
    <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
  </xsl:template>
  
  <xsl:template match="cnx:para/@ep:stretch"></xsl:template>
  
  <xsl:function name="ep:add_additional_class_for_block_elements">
    <xsl:param name="ctx"/>
    <xsl:variable name="isExistAtLeastElementBefore" select="count($ctx/preceding-sibling::node()[local-name() != '' or string-length(normalize-space(self::text()))>0])>0"/>
    <xsl:variable name="preFirstSibling" select="$ctx/preceding-sibling::node()[local-name() != '' or string-length(normalize-space(self::text()))>0][1]"/>
    <xsl:variable name="nextFirstSibling" select="$ctx/following-sibling::node()[local-name() != '' or string-length(normalize-space(self::text()))>0][1]"></xsl:variable>
    
    <xsl:if test="$isExistAtLeastElementBefore 
      and (some $x in ('gallery','reference','table','list','equation') satisfies $preFirstSibling/local-name() = $x)">
      <xsl:text> after-block</xsl:text>
    </xsl:if>
    
    <xsl:if test="$isExistAtLeastElementBefore and ($preFirstSibling[string-length(normalize-space(self::text()))>0]
      or (every $x in ('gallery','reference','table','list','equation') satisfies $preFirstSibling/local-name() != $x))">
      <xsl:if test="not($ctx/local-name() = 'list' and $ctx/ancestor::node()/local-name()= 'list')">
        <xsl:text> after-text</xsl:text>
      </xsl:if>
    </xsl:if>
    
    <xsl:if test="count($ctx/following-sibling::node()[local-name() != '' or string-length(text())>0])>0 and ($nextFirstSibling[string-length(normalize-space(self::text()))>0]
      or (every $x in ('gallery','reference','table','list','equation') satisfies $nextFirstSibling/local-name() != $x))">
      <xsl:if test="not($ctx/local-name() = 'list' and $ctx/ancestor::node()/local-name()= 'list')">
        <xsl:text> before-text</xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:function>
  
</xsl:stylesheet>
