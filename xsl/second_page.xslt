<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:col="http://cnx.rice.edu/collxml" xmlns:tmp="tmp" xmlns:cnxml="http://cnx.rice.edu/cnxml"
	xmlns:md="http://cnx.rice.edu/mdml" xmlns:q="http://cnx.rice.edu/qml/1.0"
	xmlns:ep="http://epodreczniki.pl/" xmlns:mml="http://www.w3.org/1998/Math/MathML" 
	xmlns:cnxsi="http://cnx.rice.edu/system-info" xmlns="http://cnx.rice.edu/cnxml"
	exclude-result-prefixes="xs fn">

	<xsl:variable name="module_id">
		<xsl:value-of select="ep:generate_doc_id(/col:collection/col:metadata/md:content-id, '_second_page')"/>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates mode="second_page"/>
	</xsl:template>

	<xsl:template match="col:collection" mode="second_page">
		<document id="{$module_id}" module-id="{$module_id}" cnxml-version="0.7">
			<xsl:element name="title">
				<xsl:value-of select="//col:metadata/md:title/text()"/>
			</xsl:element>
			<xsl:call-template name="second_page_content"/>
		</document>
	</xsl:template>
	
	<xsl:template name="second_page_content">
		<xsl:variable name="ctx_metadata" select="//col:metadata"></xsl:variable>
		<content>
			<section id="{concat($module_id, '-', ep:generate-id($ctx_metadata))}" ep:role="second_page">
				<xsl:if test="$ctx_metadata/md:subtitle != ''">
					<section id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:subtitle))}_subtitle" ep:role="second_page_subtitle">
						<title ep:role="second_page_subtitle_header">
							<xsl:value-of select="$locales/locale[@key='label_book_subtitle']/text()"/>
						</title>
						<para ep:role="second_page_subtitle_content" id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:subtitle),'p')}">
							<xsl:value-of select="$ctx_metadata/md:subtitle/text()"/>
						</para>
					</section>
				</xsl:if>
				<xsl:if test="$ctx_metadata/md:abstract != ''">
					<section id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:abstract))}" ep:role="second_page_abstract">
						<title ep:role="second_page_abstract_header">
							<xsl:value-of select="$locales/locale[@key='label_description']/text()"/>
						</title>
						<p ep:role="second_page_abstract_content" id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:abstract),'p')}">
							<xsl:value-of select="$ctx_metadata/md:abstract/text()"/>
						</p>
					</section>
				</xsl:if>
				
				<xsl:if test="$ctx_metadata/md:subjectlist/md:subject != ''">
					<section id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:subjectlist))}" ep:role="second_page_subject">
						<title ep:role="second_page_subject_header">
					<xsl:choose>
						<xsl:when test="count($ctx_metadata/md:subjectlist/md:subject) =1">
							<xsl:value-of select="$locales/locale[@key='label-subject']/text()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$locales/locale[@key='label-subjects']/text()"/>
						</xsl:otherwise>
					</xsl:choose>
						</title>
						<p ep:role="second_page_subject_content" id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:subjectlist),'p')}">
							<xsl:for-each select="$ctx_metadata/md:subjectlist/md:subject">
								<xsl:value-of select="."/>
								<xsl:if test="position() != last()">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</p>
					</section>
				</xsl:if>
				
				<xsl:variable name="uniqueRoles" select="distinct-values($ctx_metadata//md:roles/md:role/@type)" as="xs:string*"/>
				<xsl:for-each select="$uniqueRoles">
					<xsl:variable name="currType" select="."/>
					<section id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:actors),position())}" ep:role="second_page_authors">
						<title ep:role="second_page_authors_header">
							<xsl:choose>
								<xsl:when test=". = 'author'">
									<xsl:choose>
										<xsl:when test="count($ctx_metadata//md:roles/md:role[@type='author']) > 1">
											<xsl:value-of select="$locales/locale[@key='label_author_of_book_x']/text()"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$locales/locale[@key='label_author_of_book_1']/text()"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$currType"/>
									<xsl:text>: </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</title>

						<p ep:role="second_page_authors_content" id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:actors),position(),'p')}">
							<xsl:choose>
								<xsl:when test=". = 'author'">
									<xsl:for-each select="$ctx_metadata//md:roles/md:role[@type=$currType]">
										<xsl:variable name="currUserid" select="./text()"/>
										<xsl:choose>
											<xsl:when test="position()=1"/>
											<xsl:when test="position()=last()"> i </xsl:when>
											<xsl:when test="position()>1">, </xsl:when>
										</xsl:choose>
										<xsl:value-of select="$ctx_metadata//md:actors/node()[@userid=$currUserid]/md:fullname"/>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="tokenize(string-join($ctx_metadata//md:roles/md:role[@type=$currType],' '),'[ ,]+')">
										<xsl:variable name="currUserid" select="."/>
										<xsl:choose>
											<xsl:when test="position()=1"/>
											<xsl:when test="position()=last()"> i </xsl:when>
											<xsl:when test="position()>1">, </xsl:when>
										</xsl:choose>
										<xsl:value-of select="$ctx_metadata//md:actors/node()[@userid=$currUserid]/md:fullname"/>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</p>
					</section>
				</xsl:for-each>
	
				<section id="{concat($module_id, '-', ep:generate-id($ctx_metadata/ep:e-textbook))}" ep:role="second_page_content_status_receipient">
					<title ep:role="second_page_content_status_receipient_header">
						<xsl:value-of select="$locales/locale[@key='label_second_page_content_status_receipient']/text()"/>
					</title>
					<p ep:role="second_page_content_status_receipient_content" id="{concat($module_id, '-', ep:generate-id($ctx_metadata/ep:e-textbook),'p')}">
						<xsl:choose>
							<xsl:when test="$ctx_metadata/ep:e-textbook/@ep:recipient = 'student'">
								<xsl:value-of select="$locales/locale[@key='label_second_page_content_status_student']/text()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$locales/locale[@key='label_second_page_content_status_teacher']/text()"/>
							</xsl:otherwise>
						</xsl:choose>
					</p>
				</section>
				<section id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:revised))}" ep:role="second_page_revised_date">
					<title ep:role="second_page_revision_date_header">
						<xsl:value-of select="$locales/locale[@key='label_revision_date']/text()"/>
					</title>
					<p ep:role="second_page_revision_date_content" id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:revised),'p')}">
						<xsl:choose>
							<xsl:when test="$ctx_metadata/ep:e-textbook/ep:publication-date">
								<xsl:call-template name="ep:generate_format_date">
									<xsl:with-param name="date" select="$ctx_metadata/ep:e-textbook/ep:publication-date/text()"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="ep:generate_format_date">
									<xsl:with-param name="date" select="$ctx_metadata/md:revised/text()"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</p>
				</section>
				<xsl:if test="$ctx_metadata/md:education-levellist/md:education-level != ''">
					<section id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:education-levellist),'2')}" ep:role="second_page_school_type">
						<title ep:role="second_page_school_type_header">
							<xsl:choose>
								<xsl:when test="count($ctx_metadata/md:education-levellist/md:education-level) > 1">
									<xsl:value-of select="$locales/locale[@key='label_school_type_x']/text()"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$locales/locale[@key='label_school_type_1']/text()"/>
								</xsl:otherwise>
							</xsl:choose>
						</title>

						<p ep:role="second_page_school_type_content" id="{concat($module_id, '-', ep:generate-id($ctx_metadata/md:education-levellist),'2p')}">
							<xsl:for-each select="$ctx_metadata/md:education-levellist/md:education-level">
								<xsl:if test="position() > 1">
									<xsl:text>, </xsl:text>
								</xsl:if>
								<xsl:call-template name="ep:show_school_type">
									<xsl:with-param name="school_type" select="."/>
								</xsl:call-template>
							</xsl:for-each>
						</p>
					</section>
				</xsl:if>
				<xsl:for-each select="$ctx_metadata/md:subjectlist/md:subject">
					<xsl:if test="some $x in ($locales/locale[@key='subject_mathematics'], 
						$locales/locale[@key='subject_polishLanguage'],
						$locales/locale[@key='subject_historyAndSociety'],
						$locales/locale[@key='subject_history'],
						$locales/locale[@key='subject_civicsEducation']) satisfies contains(./text(),$x)">
						<section id="{concat($module_id, '-', ep:generate-id(.))}" ep:role="second_page_mark_tasks">
							<title ep:role="second_page_mark_tasks_header">
								<xsl:value-of select="$locales/locale[@key='label_mark_tasks']/text()"/>
							</title>

							<section ep:role="second_page_mark_tasks_content" id="{concat($module_id, '-', ep:generate-id(.),'p')}">
								<xsl:choose>
									<xsl:when test="./text() = $locales/locale[@key='subject_mathematics']/text()">
										<xsl:call-template name="ep:show_mark_tasks_mat">
											<xsl:with-param name="ctx" select="."/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="ep:show_mark_tasks_uwr">
											<xsl:with-param name="ctx" select="."/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
								
							</section>
						</section>
					</xsl:if>
				</xsl:for-each>

				<section id="{concat($module_id, '-', ep:generate-id(.))}" ep:role="second_page_status_content">
					<title ep:role="second_page_status_content_header">
						<xsl:value-of select="$locales/locale[@key='label_status_content']/text()"/>
					</title>

					<section ep:role="second_page_status_content_content" id="{concat($module_id, '-', ep:generate-id(.),'p')}">
						<xsl:call-template name="ep:show_status_content">
							<xsl:with-param name="ctx" select="."/>
						</xsl:call-template>
					</section>
				</section>

				<xsl:if test="$ctx_metadata/ep:e-textbook/ep:signature !=''">
					<section id="{concat($module_id, '-', ep:generate-id(.))}" ep:role="second_page_signature">
						<section ep:role="second_page_signature_content" id="{concat($module_id, '-', ep:generate-id(.),'p')}">
							<xsl:copy-of select="$ctx_metadata/ep:e-textbook/ep:signature/node()"></xsl:copy-of>
						</section>
					</section>
				</xsl:if>
			</section>
		</content>
	</xsl:template>

	<xsl:function name="ep:getContentStatusReceipient">
		<xsl:param name="ctx"></xsl:param>
		
		<xsl:choose>
			<xsl:when test="$ctx/@ep:recipient = 'student'">
				<xsl:choose>
					<xsl:when test="$ctx/@ep:content-status = 'canon'">
						<xsl:value-of select="$locales/locale[@key='label_content_status_sc']/text()"/>
					</xsl:when>
					<xsl:when test="$ctx/@ep:content-status = 'expanding'">
						<xsl:value-of select="$locales/locale[@key='label_content_status_se']/text()"/>
					</xsl:when>
					<xsl:when test="$ctx/@ep:content-status = 'supplemental'">
						<xsl:value-of select="$locales/locale[@key='label_content_status_ss']/text()"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$ctx/@ep:recipient = 'teacher'">
				<xsl:choose>
					<xsl:when test="$ctx/@ep:content-status = 'canon'">
						<xsl:value-of select="$locales/locale[@key='label_content_status_tc']/text()"/>
					</xsl:when>
					<xsl:when test="$ctx/@ep:content-status = 'expanding'">
						<xsl:value-of select="$locales/locale[@key='label_content_status_te']/text()"/>
					</xsl:when>
					<xsl:when test="$ctx/@ep:content-status = 'supplemental'">
						<xsl:value-of select="$locales/locale[@key='label_content_status_ts']/text()"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="ep:generate_format_date">
		<xsl:param name="date"/>
		<xsl:analyze-string select="$date" regex="^(\d{{4}})-(\d{{2}})-(\d{{2}})">
			<xsl:matching-substring>
				<xsl:value-of select="number(regex-group(3))"/>
				<xsl:text> </xsl:text>
				<xsl:value-of
					select="$locales/locale[@key=concat('month_',number(regex-group(2)))]/text()"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="regex-group(1)"/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<xsl:template name="ep:show_mark_tasks_mat">
		<xsl:param name="ctx"></xsl:param>
		<table id="{concat($module_id, '-', ep:generate-id($ctx),'_table')}"
			ep:role="table_of_mark_tasks"
			summary="{$locales/locale[@key='mark_taks_table_desc']/text()}">
			<title/>
			<tgroup cols="2">
				<colspec colnum="1" colname="c1"/>
				<colspec colnum="2" colname="c2"/>
				<tbody>
					<row>
						<entry ep:role="label_effect_of_education_A">
									<span ep:role="label_effect_of_education">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_label_level_min']/text()"/>
						</span>
						</entry>
						<entry ep:role="desc_effect_of_education_A">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_desc_level_min']/text()"/>
						</entry>
					</row>
					<row>
						<entry ep:role="label_effect_of_education_B">
						<span ep:role="label_effect_of_education">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_label_level_general']/text()"
							/>
							</span>
						</entry>
						<entry ep:role="desc_effect_of_education_B">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_desc_level_general']/text()"
							/>
						</entry>
					</row>
					<row>
						<entry ep:role="label_effect_of_education_C">
						<span ep:role="label_effect_of_education">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_label_level_creative']/text()"
							/>
							</span>
						</entry>
						<entry ep:role="desc_effect_of_education_C">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_desc_level_creative']/text()"
							/>
						</entry>
					</row>
					<row>
						<entry ep:role="label_effect_of_education_K">
							<span ep:role="label_effect_of_education">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_label_level_competence']/text()"
							/>
							</span>
						</entry>
						<entry ep:role="desc_effect_of_education_K">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_desc_level_competence']/text()"
							/>
						</entry>
					</row>
					<row>
						<entry ep:role="label_exercise_on_paper">
							<span ep:role="label_exercise">
								<xsl:value-of
									select="$locales/locale[@key='mark_taks_label_exercise_on_paper']/text()"
								/>
							</span>
						</entry>
						<entry ep:role="desc_exercise_on_paper">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_desc_exercise_on_paper']/text()"
							/>
						</entry>
					</row>
				</tbody>
			</tgroup>
		</table>
	</xsl:template>
	
	<xsl:template name="ep:show_mark_tasks_uwr">
		<xsl:param name="ctx"></xsl:param>
		<table id="{concat($module_id, '-', ep:generate-id($ctx),'_table')}"
			ep:role="table_of_mark_tasks"
			summary="{$locales/locale[@key='mark_taks_table_desc']/text()}">
			<title/>
			<tgroup cols="2">
				<colspec colnum="1" colname="c1"/>
				<colspec colnum="2" colname="c2"/>
				<tbody>
					<row>
						<entry ep:role="label_exercise_expanding">
							<span ep:role="label_exercise">
								<xsl:value-of
									select="$locales/locale[@key='mark_taks_label_exercise_expanding']/text()"/>
							</span>
						</entry>
						<entry ep:role="desc_exercise_expanding">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_desc_exercise_expanding']/text()"/>
						</entry>
					</row>
					<row>
						<entry ep:role="label_exercise_groupwork">
							<span ep:role="label_exercise">
								<xsl:value-of
									select="$locales/locale[@key='mark_taks_label_exercise_groupwork']/text()"/>
							</span>
						</entry>
						<entry ep:role="desc_exercise_groupwork">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_desc_exercise_groupwork']/text()"/>
						</entry>
					</row>
					<row>
						<entry ep:role="label_exercise_pairwork">
							<span ep:role="label_exercise">
								<xsl:value-of
									select="$locales/locale[@key='mark_taks_label_exercise_pairwork']/text()"/>
							</span>
						</entry>
						<entry ep:role="desc_exercise_pairwork">
							<xsl:value-of
								select="$locales/locale[@key='mark_taks_desc_exercise_pairwork']/text()"/>
						</entry>
					</row>
				</tbody>
			</tgroup>
		</table>
	</xsl:template>
	
	<xsl:template name="ep:show_status_content">
		<xsl:param name="ctx"></xsl:param>
		<table id="{concat($module_id, '-', ep:generate-id($ctx),'_table')}"
			ep:role="table_of_status_content"
			summary="{$locales/locale[@key='label_status_content_table_desc']/text()}">
			<title/>
			<tgroup cols="2">
				<colspec colnum="1" colname="c1"/>
				<colspec colnum="2" colname="c2"/>
				<tbody>
					<row>
						<entry ep:role="label_status_content">
							<span ep:role="label_status_content_R">
								<xsl:value-of
									select="$locales/locale[@key='shortcut_content_status_expanding']/text()"/>
							</span>
						</entry>
						<entry ep:role="desc_status_content_R">
							<xsl:value-of
								select="$locales/locale[@key='label_content_status_expanding']/text()"/>
						</entry>
					</row>
					<row>
						<entry ep:role="label_status_content">
							<span ep:role="label_status_content_N">
								<xsl:value-of
									select="$locales/locale[@key='shortcut_content_status_teacher']/text()"
								/>
							</span>
						</entry>
						<entry ep:role="desc_status_content_N">
							<xsl:value-of
								select="$locales/locale[@key='label_content_status_teacher']/text()"
							/>
						</entry>
					</row>
				</tbody>
			</tgroup>
		</table>
		
	</xsl:template>

</xsl:stylesheet>
