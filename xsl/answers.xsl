<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:col="http://cnx.rice.edu/collxml"
    xmlns:md="http://cnx.rice.edu/mdml"
    xmlns:ep="http://epodreczniki.pl/"
    xmlns:cn="http://cnx.rice.edu/cnxml"
    xmlns:q="http://cnx.rice.edu/qml/1.0"
    xmlns="http://cnx.rice.edu/cnxml"
    exclude-result-prefixes="xs"
    version="2.0">
        
    <xsl:output method="xml" indent="no"/>
        
    <xsl:template match="/">
        <xsl:apply-templates mode="answers_page"/>
    </xsl:template>
    
    <xsl:template match="col:collection" mode="answers_page">
        <xsl:for-each select="col:content/col:subcollection">
            <xsl:call-template name="ep:createAnswersContent">
                <xsl:with-param name="chapter_title" select="md:title"/>
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="ep:createAnswersContent">
        <xsl:param name="chapter_title"/>
        <xsl:param name="context"/>
        
        <xsl:for-each select="$context/col:content/node()">            
            <xsl:choose>
                <xsl:when test="local-name() = 'subcollection'">
                    <xsl:call-template name="ep:createAnswersContent">
                        <xsl:with-param name="chapter_title" select="concat($chapter_title, ' / ', md:title)"/>
                        <xsl:with-param name="context" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="local-name() = 'module'">
                    <xsl:variable name="mod" select="."/>
                    <xsl:variable name="modContent" select="$modules/cn:documents/cn:document[@id=$mod/@document]"/>
                    
                    <xsl:if test="ep:check_if_modules_have_answers($mod/@document) = '1'">
                        <xsl:variable name="doc_id">
                            <xsl:value-of select="$mod/@document"/>
                            <xsl:text>_answers</xsl:text>
                        </xsl:variable>
                        <document id="{$doc_id}" module-id="{$doc_id}" subcol_id="{generate-id(ancestor::col:subcollection[last()])}">
							<xsl:copy-of select="$modContent/@cnxml-version"></xsl:copy-of>
                            <xsl:element name="title">
                                <xsl:value-of select="$locales/locale[@key='answers']/text()"/>
                            </xsl:element>
                            <metadata>
                                <xsl:copy-of select="$modContent/cn:metadata/@*"/>
                                <ep:e-textbook-module>
                                    <xsl:copy-of select="$modContent/cn:metadata/ep:e-textbook-module/@*"/>
                                    <ep:presentation>
                                        <ep:type>EP_technical_module_answers</ep:type>
                                    </ep:presentation>
                                </ep:e-textbook-module>
                            </metadata>
                            <content>
                                <section id="{$mod/@document}-answers-module-section" 
                                    ep:role="answers-module-section">
                                    <label ep:role="answers-module-section-title">
                                        <xsl:if test="$chapter_title">
                                            <xsl:value-of select="$chapter_title"/>
                                            <xsl:text> / </xsl:text>
                                        </xsl:if>
                                        
                                        <xsl:value-of select="$mod/md:title"/>
                                    </label>
                                    
                                    <xsl:variable name="prefix" select="ep:get_number_prefix_for_answers($mod)"/>
                                    <xsl:apply-templates mode="content_answers" 
                                        select="$modContent/cn:content/descendant::node()[(local-name()='exercise' and not(@type='command')) 
                                        or (local-name()='student-work' and @ep:type='exercise-set')]|$modContent//cn:section[ep:parameters/ep:start-new-page='true' and exists(cn:title)]">
                                        <xsl:with-param name="mod" select="$mod" tunnel="yes"></xsl:with-param>
                                        <xsl:with-param name="prefix" select="$prefix" tunnel="yes"></xsl:with-param>
                                        <xsl:with-param name="moduleTitle">
                                            <xsl:if test="$chapter_title">
                                                <xsl:value-of select="$chapter_title"/>
                                                <xsl:text> / </xsl:text>
                                            </xsl:if>
                                            <xsl:value-of select="$mod/md:title"></xsl:value-of>
                                        </xsl:with-param>
                                    </xsl:apply-templates>
                                </section>
                            </content>
                        </document>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cn:section[ep:parameters/ep:start-new-page='true' and exists(cn:title)]" mode="content_answers">
        <xsl:param name="moduleTitle"></xsl:param>
        
        <xsl:if test="count(descendant::node()[
            ((local-name()='exercise' and not(@type='command')) 
            or (local-name()='student-work' and @ep:type='exercise-set'))
            and (local-name() = 'solution' 
            or (local-name() = 'commentary' and not(@type))
            or (local-name() = 'note' and @type='tip' and parent::node()[local-name()='exercise']) 
            or descendant::node()/q:key/@answer)]) > 0">
            <span ep:role="answers-module-padding-title">
                <xsl:if test="$moduleTitle">
                    <xsl:value-of select="$moduleTitle"/>
                    <xsl:text> / </xsl:text>
                </xsl:if>
                
                <xsl:value-of select="cn:title"/>
            </span>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="cn:exercise[not(@type='command')]" mode="content_answers">
        <xsl:param name="is_student_work_child" tunnel="yes"></xsl:param>
        <xsl:variable name="parent_node_type" select="parent::node()/@ep:type"></xsl:variable>
        
        <xsl:if
            test="(not($is_student_work_child) and not($parent_node_type)) or $is_student_work_child">
            <xsl:if
                test="exists(descendant::node()[local-name() = 'solution' or (local-name() = 'commentary' and not(@type)) 
                or (local-name() = 'note' and @type='tip' and parent::node()[local-name()='exercise'])]) or descendant::node()/q:key/@answer">
                <section
                    id="{ep:generateNewIdWithModuleId(@id, ancestor::cn:document/@module-id)}-solution"
                    ep:role="answers_exercise">
                    <xsl:if test="not(ancestor::ep:student-work) or (ancestor::ep:student-work and (count(following-sibling::cn:exercise) > 0 or count(preceding-sibling::cn:exercise) > 0))">
                        <label ep:role="answers_exercise_title">
                            <xsl:choose>
                                <xsl:when test="parent::node()[local-name()='student-work' and @ep:type='exercise-set']">
                                    <xsl:value-of select="$locales/locale[@key='SubExercise']"/>
                                </xsl:when>
                                <xsl:when test="@type">
                                    <xsl:value-of select="$locales/locale[@key=current()/@type]/text()"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$locales/locale[@key='exercise']/text()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="create_numbering_span_elements">
                                <xsl:with-param name="type" select="@type"/>
                                <xsl:with-param name="parent_node_type" select="$parent_node_type"></xsl:with-param>
                            </xsl:call-template>
                            <span>
                                <link document="{ancestor::cn:document/@module-id}"
                                    target-id="{ep:generateNewIdWithModuleId(@id, ancestor::cn:document/@module-id)}">
                                    <xsl:value-of
                                        select="$locales/locale[@key='back_to_exercise']/text()"/>
                                </link>
                            </span>
                        </label>
                    </xsl:if>
                    <xsl:apply-templates
                        select="cn:solution|cn:commentary|q:item|ep:alternatives|cn:note[@type='tip' and parent::node()[local-name()='exercise']]"/>
                </section>
            </xsl:if>
        </xsl:if>
    </xsl:template>    
    
    <xsl:template match="ep:student-work[@ep:type='exercise-set']" mode="content_answers">
        <xsl:param name="mod" tunnel="yes"></xsl:param>
        
        <section id="{ep:generateNewIdWithModuleId(@id, ancestor::cn:document/@module-id)}-solution-exercise-set" ep:role="answers-exercise-set">
            <label ep:role="answers-exercise-set-title">
                <xsl:variable name="student-work-type" select="@ep:type"></xsl:variable>
                <xsl:value-of select="$locales/locale[@key=$student-work-type]"/>
                <xsl:text> </xsl:text>                
                <xsl:call-template name="create_numbering_span_elements">
                    <xsl:with-param name="type" select="child::cn:exercise[1]/@type"></xsl:with-param>
                    <xsl:with-param name="mod" select="$mod"></xsl:with-param>
                </xsl:call-template>
            </label>
            
            <xsl:apply-templates select="cn:exercise[not(@type='command')]" mode="content_answers">
                <xsl:with-param name="is_student_work_child" select="true()" tunnel="yes"></xsl:with-param>
            </xsl:apply-templates>
        </section>
    </xsl:template>
    
    <xsl:template name="create_numbering_span_elements">
        <xsl:param name="type"></xsl:param>
        <xsl:param name="mod" tunnel="yes"></xsl:param>
        <xsl:param name="prefix" tunnel="yes"></xsl:param>
        <xsl:param name="parent_node_type"></xsl:param>
        <xsl:param name="is_student_work_child" tunnel="yes"></xsl:param>
        
        <span ep:role="numbering">
            <span ep:role="numbering-prefix">
                <xsl:if test="not($is_student_work_child)">
                <xsl:value-of select="$prefix"/>
                </xsl:if>
            </span>
            <span ep:role="numbering-element">
                <xsl:choose>
                    <xsl:when test="$parent_node_type">
                        <xsl:variable name="exercise_position">
                            <xsl:number format="A" count="cn:exercise"/>
                        </xsl:variable>
                        <xsl:value-of select="$exercise_position"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="exists(@type|@ep:type)">
                                <xsl:value-of
                                    select="count(preceding::cn:exercise[ancestor::cn:document[@id=$mod/@document] 
                            and (@type=$type)
                            and not(parent::node()/@ep:type or parent::node()/@ep:type != 'exercise-set')]) + 1 
                            + count(preceding::ep:student-work[@ep:type='exercise-set' and ancestor::cn:document[@id=$mod/@document]])
                            + ep:get_prev_modules_exercise_count(substring-before(@id, '_'), @type)
                            + ep:get_associated_exercise_type_count(., $mod/@document)"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="count(preceding::cn:exercise[ancestor::cn:document[@id=$mod/@document] and not(@type)]) + 1 
                                    + ep:get_prev_modules_exercise_count(substring-before(@id, '_'), '')
                                    + ep:get_associated_exercise_type_count(., $mod/@document)"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
        </span>
    </xsl:template>
    
    <xsl:function name="ep:check_if_modules_have_answers" as="text()">
        <xsl:param name="ids_in_subcollection"/>
        <xsl:variable name="counter">
            <xsl:for-each select="$modules/cn:documents/cn:document[some $x in $ids_in_subcollection satisfies @id=$x]">
                <xsl:if test="count(.//cn:solution | .//cn:commentary[not(@type)] | .//cn:note[@type='tip' and parent::node()[local-name()='exercise']] | .//q:item)">
                    <xsl:text>1 </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
       <xsl:choose>
           <xsl:when test="contains($counter, '1')">
                <xsl:value-of>1</xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of>0</xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ep:extract_module_ids_from_module_elements_with_condition" as="xs:string*">
        <xsl:param name="context" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$context/col:content">
                <xsl:for-each select="$context/col:content//col:module/@document">
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$context/col:module/@document">
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:for-each select="$context/@document">
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template match="ep:alternatives">
        <xsl:apply-templates select="ep:alternative[ep:formats/ep:format = 'static']/*[self::cn:solution|self::cn:commentary|self::q:item]"></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="cn:solution">
        <xsl:variable name="module_id" select="ancestor::cn:document/@id"/>
        <section id="{concat($module_id, '-', ep:generate-id(.))}" ep:role="answers_solution">
            <xsl:if test="not(preceding-sibling::cn:solution)">
                <title ep:role="answers_solution_title">
                    <xsl:value-of select="$locales/locale[@key='solution']/text()"/>
                </title>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="./cn:para">
                    <xsl:for-each select="./cn:para">
                        <para id="{concat($module_id, '-', ep:generate-id(.))}p">
                            <xsl:apply-templates select="./node()"></xsl:apply-templates>
                        </para>
                    </xsl:for-each>                    
                </xsl:when>
                <xsl:when test="not(./cn:para)">
                    <para id="{concat($module_id, '-', ep:generate-id(.))}p">
                        <xsl:apply-templates select="./node()"></xsl:apply-templates>
                    </para>
                </xsl:when>
            </xsl:choose>
        </section>
    </xsl:template>
    
    <xsl:template match="q:item">
        <xsl:variable name="module_id" select="ancestor::cn:document/@id"/>
        <section id="{concat($module_id, '-', ep:generate-id(.))}" ep:role="answers_solution">
            <title ep:role="answers_solution_title">
                <xsl:value-of select="$locales/locale[@key='solution']/text()"/>
            </title>
            <xsl:choose>
                <xsl:when test="''!=q:key/@answer">
                    <xsl:for-each select="q:answer[contains(../q:key/@answer, @id)]">
                        <para id="{concat($module_id, '-', ep:generate-id(./q:response/cn:section/cn:para))}p">
                            <xsl:apply-templates select="./q:response/cn:section/cn:para/node()"></xsl:apply-templates>
                        </para>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <para id="{concat($module_id, '-', ep:generate-id(q:key))}p">
                        <xsl:value-of select="$locales/locale[@key='no-correct-answer']/text()"></xsl:value-of>
                    </para>
                </xsl:otherwise>
            </xsl:choose>
        </section>
    </xsl:template>
    
    <xsl:template match="q:feedback">
        <xsl:variable name="module_id" select="ancestor::cn:document/@id"/>
        <section id="{concat($module_id, '-', ep:generate-id(.))}" ep:role="answers_commentary">
            <title ep:role="answers_commentary_title">
                <xsl:value-of select="$locales/locale[@key='commentary']/text()"/>
            </title>
            <para id="{concat($module_id, '-', ep:generate-id(.))}p">
                <xsl:apply-templates select="cn:section/cn:para/*"></xsl:apply-templates>
            </para>
        </section>
    </xsl:template>
    
    <xsl:template match="cn:commentary[not(@type)]">
        <xsl:variable name="module_id" select="ancestor::cn:document/@id"/>
        <section id="{concat($module_id, '-', ep:generate-id(.))}" ep:role="answers_commentary">
            <xsl:if test="not(preceding-sibling::cn:commentary)">
                <title ep:role="answers_commentary_title">
                    <xsl:value-of select="$locales/locale[@key='commentary']/text()"/>
                </title>
            </xsl:if>
                <para id="{concat($module_id, '-', ep:generate-id(.))}p">
                    <xsl:apply-templates select="./node()"></xsl:apply-templates>
                </para>
        </section>
    </xsl:template>
    
    <xsl:template match="cn:note[@type='tip' and parent::node()[local-name()='exercise']]">
        <xsl:variable name="module_id" select="ancestor::cn:document/@id"/>
        <section id="{concat($module_id, '-', ep:generate-id(.))}" ep:role="answers_tip">
            <xsl:if test="not(preceding-sibling::cn:note)">
                <title ep:role="answers_tip_title">
                    <xsl:value-of select="$locales/locale[@key='tip']/text()"/>
                </title>
            </xsl:if>
            <para id="{concat($module_id, '-', ep:generate-id(.))}p">
                <xsl:apply-templates select="./node()"></xsl:apply-templates>
            </para>
        </section>
    </xsl:template>
    
    <xsl:template match="cn:commentary[@type]">
    </xsl:template>
    
    <xsl:template match="cn:list/@id">
        <xsl:attribute name="id" select="concat(., '_', ancestor::cn:document/@id)"></xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
