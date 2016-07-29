<?xml version="1.0"?>

<xsl:stylesheet version="2.0"
  xmlns:bibtex="http://bibtexml.sf.net/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ep="http://epodreczniki.pl/"
  xmlns:cn="http://cnx.rice.edu/cnxml"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="ep bibtex cn xhtml">

  <xsl:variable name="period">.</xsl:variable>
  <xsl:variable name="exclamation">!</xsl:variable>
  <xsl:variable name="question">?</xsl:variable>
  <xsl:variable name="comma">,</xsl:variable>
  <xsl:variable name="ampersand">&amp;</xsl:variable>
  <xsl:variable name="semicolon">;</xsl:variable>

  <xsl:template match="bibtex:file">
    <xsl:variable name="is_added_bib_div">
      <xsl:choose>
        <xsl:when test="preceding::cn:metadata/ep:e-textbook-module/ep:generated-type">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="bibtex:entry">
            <xsl:if test="not(./@ep:show-in) or ./@ep:show-in = 'bibliography-and-module'">
              <xsl:text>1</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>
    
    <xsl:if test="contains($is_added_bib_div,'1')">
      <div ep:role="bibliography">
        <h2 ep:role="bibliography-header">
          <span ep:role="title">
            <xsl:value-of select="$locales/locale[@key='Bibliography']"/>
          </span>
        </h2>
        <ol>
          <xsl:apply-templates select="bibtex:entry"/>
        </ol>
      </div>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="bibtex:entry">
    <xsl:param name="copied_reference" tunnel="yes"/>
	<xsl:param name="word_before" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$copied_reference = 'html'">
        <xsl:element name="div" namespace="{$namespace}">
          <xsl:attribute name="id" select="@id"/>
          <xsl:attribute name="class">
            <xsl:value-of select="concat('bib-entry', concat(' bib-', local-name(bibtex:*)), concat(' bib-', @ep:show-in))"/>
          </xsl:attribute>
          <xsl:element name="span" namespace="{$namespace}">
            <xsl:attribute name="class" select="'label'"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$locales/locale[@key='label_source']"/>
          </xsl:element>

          <xsl:apply-templates>
            <xsl:with-param name="attr_css_class_name" tunnel="yes">class</xsl:with-param>
            <xsl:with-param name="namespace" select="$namespace" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$copied_reference = 'true'">
        <div id="{@id}" ep:role="bib-entry {concat('bib-', local-name(bibtex:*))} {concat('bib-', @ep:show-in)}">
          <xsl:if test="$word_before">
            <span ep:role="label">
              <xsl:value-of select="$locales/locale[@key='label_source']"/>
            </span>
          </xsl:if>	
          <xsl:apply-templates>
            <xsl:with-param name="attr_css_class_name" tunnel="yes">ep:role</xsl:with-param>
          </xsl:apply-templates>
          
          <xsl:if test="ep:link[@ep:role='go-back-from-glossary']">
            <xsl:variable name="elem_id" select="substring-after(@ep:id|@id, '_')"/>
            <xsl:variable name="href" select="concat('../',substring-before($elem_id,'_'),'#',$elem_id)"/>
            
            <xsl:call-template name="create_go_back_link_from_glossary">
              <xsl:with-param name="href" select="$href"/>
            </xsl:call-template>
          </xsl:if>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <li>
          <xsl:attribute name="ep:role" select="concat('bib-entry bib-', local-name(bibtex:*), ' bib-', @ep:show-in , ' ', parent::*/@ep:format)"/>
          <xsl:apply-templates select="@id|@ep:glossary-merge-type"/>
          <xsl:if test="$word_before">
            <span ep:role="label"><xsl:value-of select="$locales/locale[@key='label_source']"/></span>
          </xsl:if>
          <xsl:apply-templates>
            <xsl:with-param name="attr_css_class_name" tunnel="yes">ep:role</xsl:with-param>
          </xsl:apply-templates>
          <xsl:variable name="biblio_module_id" select="ep:getMappingGlossaryModuleIdByType('bibliography')"/>
          
          <xsl:if test="@ep:show-in != 'inline-only'">
            <xsl:element name="div">
              <xsl:attribute name="ep:role">go-to-glossary</xsl:attribute>
              <xsl:element name="a">
                <xsl:attribute name="href" select="concat('#', @id)"/>
                <xsl:value-of select="ep:getGoToGlossaryLabel(@ep:glossary-merge-type)"/>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          
          <xsl:if test="ep:link[@ep:role='go-back-from-glossary']">
            <xsl:variable name="elem_id" select="substring-after(@ep:id|@id, '_')"/>
            <xsl:variable name="href" select="concat('../',substring-before($elem_id,'_'),'#',$elem_id)"/>
            
            <xsl:call-template name="create_go_back_link_from_glossary">
              <xsl:with-param name="href" select="$href"/>
            </xsl:call-template>
          </xsl:if>
          
        </li>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:template match="bibtex:incollectionFree[ep:bibliographyPattern]|bibtex:incollection[ep:bibliographyPattern]|bibtex:article[ep:bibliographyPattern]
    |bibtex:unpublished[ep:bibliographyPattern]|bibtex:manual[ep:bibliographyPattern]|bibtex:misc[ep:bibliographyPattern]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="'custom-bib'"/>
      <xsl:for-each select="ep:bibliographyPattern/node()">
        <xsl:variable name="currNodeLocalName" select="./local-name()"/>
        <xsl:choose>
          <xsl:when test="string(.)">
            <xsl:value-of select="."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="span"  namespace="{$namespace}">
              <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',$currNodeLocalName)"/>
              <xsl:value-of select="parent::node()/preceding-sibling::node()[local-name() = $currNodeLocalName]"/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:incollection">
    <xsl:call-template name="convert_bib_element">
      <xsl:with-param name="ctx" select="."/>
      <xsl:with-param name="bib_elems" select="'author;title;booktitle;series;edition;editor;address;year;pages'"/>
    </xsl:call-template>
  </xsl:template>
  
  
  <xsl:template match="bibtex:incollectionFree">
    <xsl:call-template name="convert_bib_element">
      <xsl:with-param name="ctx" select="."/>
      <xsl:with-param name="bib_elems" select="'author;booktitle;title;series;edition;editor;address;year;pages'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="bibtex:article">
    <xsl:call-template name="convert_bib_element">
      <xsl:with-param name="ctx" select="."/>
      <xsl:with-param name="bib_elems" select="'author;title;journal;year;number'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="bibtex:unpublished">
    <xsl:call-template name="convert_bib_element">
      <xsl:with-param name="ctx" select="."/>
      <xsl:with-param name="bib_elems" select="'author;title;year'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="bibtex:manual">
    <xsl:choose>
      <xsl:when test="some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], 
        $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], 
        $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) 
        satisfies contains($subject,$x)">
        <xsl:apply-templates select="bibtex:title"/>
        <xsl:apply-templates select="bibtex:key">
          <xsl:with-param name="isLastElem" select="'1'"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="convert_bib_element">
          <xsl:with-param name="ctx" select="."/>
          <xsl:with-param name="bib_elems" select="'organization;edition;title;key'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="bibtex:misc">
    <xsl:call-template name="convert_bib_element">
      <xsl:with-param name="ctx" select="."/>
      <xsl:with-param name="bib_elems" select="'author;title;note;howpublished'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="bibtex:author[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:title[string-length(normalize-space(text()))>0 and . != ../bibtex:booktitle]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:if test="ep:check_if_string_ends_in_punction(.) = true()">
        <xsl:value-of select="ep:addLastChar($isLastElem,'')"/>
      </xsl:if>
      <xsl:text> </xsl:text>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:booktitle[string-length(normalize-space(text()))>0]|bibtex:title[string-length(normalize-space(text()))>0 and not(../bibtex:booktitle)]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:if test="(local-name() = 'booktitle' and ./parent::node()/bibtex:title/text() != '')
        and (normalize-space(.) != normalize-space(./parent::node()/bibtex:title/text()))">
        <xsl:value-of select="$locales/locale[@key='bib-text-in']"/>
      </xsl:if>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:if test="ep:check_if_string_ends_in_punction(.) = true()">
        <xsl:value-of select="ep:addLastChar($isLastElem,'')"/>
      </xsl:if>
      <xsl:text> </xsl:text>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:edition[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:choose>
      <xsl:when test="parent::bibtex:manual">      
        <xsl:element name="span" namespace="{$namespace}">
          <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
          <xsl:value-of select="$locales/locale[@key='bib-text-from-day']"/>
          <xsl:value-of select="ep:get_date_word_month(.)"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$locales/locale[@key='bib-year-dot']"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="span" namespace="{$namespace}">
          <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
          <xsl:value-of select="$locales/locale[@key='bib-shortcut-redaction-dot']"/>
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="bibtex:editor[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="$locales/locale[@key='bib-shortcut-translate-dot']"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:address[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text> </xsl:text>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:series[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:year[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:choose>
        <xsl:when test="parent::bibtex:article and parent::node()/child::bibtex:number">
          <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:pages[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="$locales/locale[@key='bib-shortcut-page-dot']"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:number[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="$locales/locale[@key='bib-shortcut-no-dot']"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:journal[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="concat('&quot;',normalize-space(.),'&quot;')"/>
      <xsl:text> </xsl:text>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:organization[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text> </xsl:text>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:key[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:note[parent::bibtex:misc and string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="ep:get_date_word_month(.)"/>
      <xsl:value-of select="ep:addLastChar($isLastElem,' ')"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:note[parent::bibtex:unpublished and string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="bibtex:howpublished[string-length(normalize-space(text()))>0]">
    <xsl:param name="attr_css_class_name" tunnel="yes"/>
    <xsl:param name="namespace" tunnel="yes"/>
    <xsl:param name="isLastElem"/>
    <xsl:element name="span" namespace="{$namespace}">
      <xsl:attribute name="{$attr_css_class_name}" select="concat('bib-',local-name())"/>
      <xsl:value-of select="$locales/locale[@key='bib-text-available-in-the-internet']"/>
      <xsl:variable name="hrefData" select="normalize-space(.)"/>
      <xsl:choose>
        <xsl:when test="some $x in ($locales/locale[@key='subject_biology'], $locales/locale[@key='subject_chemistry'], 
          $locales/locale[@key='subject_educationForSafety'], $locales/locale[@key='subject_physics'], 
          $locales/locale[@key='subject_geography'], $locales/locale[@key='subject_natureScience']) 
          satisfies contains($subject,$x)">
          <xsl:value-of select="$hrefData"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="a">
            <xsl:attribute name="href" select="$hrefData"/>
            <xsl:attribute name="target" select="'_blank'"/>
            <xsl:value-of select="$hrefData"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:function name="ep:check_if_string_ends_in_punction">
    <xsl:param name="data"/>
    <xsl:variable name="last-character" select="substring(string(normalize-space($data)),string-length(normalize-space($data)),1)"/>
    <xsl:choose>
      <xsl:when test="every $x in ($period, $exclamation, $question, $semicolon, $period) satisfies $x != $last-character">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="ep:find_last_element_to_put_dot">
    <xsl:param name="ctx"/>
    <xsl:param name="param_bib_elements"/>
    <xsl:variable name="existsElems">
      <xsl:for-each select="tokenize($param_bib_elements,';')">
        <xsl:variable name="elemName" select="."/>
        <xsl:if test="not(empty($ctx/node()[local-name()= $elemName and namespace-uri() = 'http://bibtexml.sf.net/']))">
          <xsl:text>;</xsl:text>
          <xsl:value-of select="$elemName"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="tokenize($existsElems,';')[last()]"/>
  </xsl:function>
  
  <xsl:template name="convert_bib_element">
    <xsl:param name="ctx"/>
    <xsl:param name="bib_elems"/>
    <xsl:variable name="isLastElementWithDot" select="ep:find_last_element_to_put_dot($ctx,$bib_elems)"/>
    <xsl:for-each select="tokenize($bib_elems,';')">
      <xsl:variable name="elemName" select="."/>
      <xsl:apply-templates select="$ctx/node()[local-name()= $elemName and namespace-uri() = 'http://bibtexml.sf.net/']">
        <xsl:with-param name="isLastElem">
          <xsl:if test="$elemName = $isLastElementWithDot">
            <xsl:value-of select="'1'"/>
          </xsl:if>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:function name="ep:addLastChar">
    <xsl:param name="isLastElem"/>
    <xsl:param name="nextChar"/>
    <xsl:choose>
      <xsl:when test="$isLastElem = '1'">
        <xsl:text>.</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>,</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$nextChar"/>
  </xsl:function>
  
  <xsl:template match="bibtex:*"></xsl:template>  
</xsl:stylesheet>
