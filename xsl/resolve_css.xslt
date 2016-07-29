<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:ep="http://epodreczniki.pl/">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>

	<xsl:function name="ep:map_role2css" as="xs:string*">
		<xsl:param name="role" as="xs:string"/>
		<xsl:call-template name="map_role2css">
			<xsl:with-param name="role" select="$role"/>
		</xsl:call-template>
	</xsl:function>

	<xsl:template name="map_role2css">
		<xsl:param name="role"/>			
		<xsl:for-each select="tokenize($role, ' ')">
			<xsl:value-of select="$role2css-mappings/role2css-mappings/role[@key=current()]/@value"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:function name="ep:all_css_classes_details" as="node()">
		<xsl:call-template name="all_css_classes_details"/>
	</xsl:function>

	<xsl:template name="all_css_classes_details" as="node()">
		<xsl:element name="CSSclasses">
			<xsl:for-each-group select="$role2css-mappings/role2css-mappings/role" group-by="@value">
				<xsl:element name="CSSclass">
					<xsl:attribute name="name"><xsl:value-of select="current-grouping-key()"/></xsl:attribute>
					<xsl:for-each select="current-group()">
						<xsl:element name="role">
							<xsl:attribute name="name"><xsl:value-of select="@key"/></xsl:attribute>
							<xsl:value-of select="./text()"/>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>

	<xsl:variable name="role2css-mappings">
		<role2css-mappings>
			<role key="second_page_subtitle" value="subtitle">Subtitle on the second page of the e-book (all static formats)</role>
			<role key="last_page_subtitle" value="subtitle">Subtitle on the last page of the e-book (all static formats)</role>
                        <role key="book" value="book">PDF book content (div containing all modules after TOC)</role>
			<role key="cover-page" value="cover-page">Cover page of a book; contains img with the cover</role>
			<role key="chapter" value="chapter">A chapter of a book</role>
			<role key="chapter_answers" value="chapter answers_module">A chapter of a book</role>
			<role key="chapter_about" value="chapter about_module">A chapter of a book</role>
			<role key="reader-content" value="reader-content">A content of book in mobile format</role>
			
			<role key="recipient-teacher" value="recipient-teacher">Recipient teacher</role>
			<role key="recipient-student" value="recipient-student">Recipient student</role>
			<role key="content-status-canon" value="content-status-canon">Content status canon</role>
			<role key="content-status-expanding" value="content-status-expanding">Content status expanding</role>
			<role key="content-status-supplemental" value="content-status-supplemental">Content status supplemental</role>
			
			<role key="EP_technical_module_about" value="mt_EP_technical_module_about">Generated module EP-about</role>
			<role key="EP_technical_module_answers" value="mt_EP_technical_module_answers">Generated module EP-answers</role>
			<role key="EP_technical_module_bibliography" value="mt_EP_technical_module_bibliography">Generated module EP-bibliography</role>
			<role key="EP_technical_module_biography" value="mt_EP_technical_module_biography">Generated module EP-biography</role>
			<role key="EP_technical_module_event" value="mt_EP_technical_module_event">Generated module EP-event</role>
			<role key="EP_technical_module_glossary" value="mt_EP_technical_module_glossary">Generated module EP-glossary</role>
			<role key="EP_technical_module_concept" value="mt_EP_technical_module_concept">Generated module EP-concept</role>
			
			<role key="second_page" value="second_page">Main section in second page</role>
			<role key="second_page_title_header" value="title-header">Title header on the second page</role>
			<role key="second_page_subtitle_header" value="subtitle-header">Subtitle header on the second page</role>
			<role key="second_page_abstract" value="second_page_abstract">Abstract section on the second page</role>
			<role key="second_page_abstract_header" value="header">Abstract header on the second page</role>
			<role key="second_page_abstract_content" value="content">Abstract content on the second page</role>
			<role key="second_page_subject" value="second_page_subject">Subject section on the second page</role>
			<role key="second_page_subject_header" value="header">Subject header on the second page</role>
			<role key="second_page_subject_content" value="content">Subject content on the second page</role>
			<role key="second_page_authors" value="second_page_authors">Authors section on the second page</role>
			<role key="second_page_authors_header" value="header">Authors header on the second page</role>
			<role key="second_page_authors_content" value="content">Authors content on the second page</role>
			<role key="second_page_revised_date" value="second_page_revised_date">Revised date section on the second page</role>
			<role key="second_page_revision_date_header" value="header">Revised date header on the second page</role>
			<role key="second_page_revision_date_content" value="content">Revised date content on the second page</role>
			<role key="second_page_education_level" value="second_page_education_level">Education level section on the second page</role>
			<role key="second_page_education_level_header" value="header">Education level header on the second page</role>
			<role key="second_page_education_level_content" value="content">Education level content on the second page</role>
			<role key="second_page_signature" value="second_page_signature">Signature section on the second page</role>
			<role key="second_page_signature_header" value="second_page_signature_header">Signature section on the second page</role>
			<role key="second_page_signature_content" value="second_page_signature_content">Signature section on the second page</role>
			
			<role key="second_page_content_status_receipient" value="second_page_content_status_receipient">Content status receipient section on the second page</role>
			<role key="second_page_content_status_receipient_header" value="header">Content status receipient header on the second page</role>
			<role key="second_page_content_status_receipient_content" value="content">Content status receipient content on the second page</role>
			
			<role key="second_page_school_type" value="second_page_school_type">School type section on the second page</role>
			<role key="second_page_school_type_header" value="header">School type header on the second page</role>
			<role key="second_page_school_type_content" value="content">School type content on the second page</role>
			
			<role key="second_page_mark_tasks" value="second_page_mark_tasks">Mark tasks section on the second page</role>
			<role key="second_page_mark_tasks_header" value="header">Mark tasks header on the second page</role>
			<role key="second_page_mark_tasks_content" value="content">Mark tasks content on the second page</role>
			<role key="second_page_status_content" value="second_page_status_content">Status content section on the second page</role>
			<role key="second_page_status_content_header" value="header">Status content header on the second page</role>
			<role key="second_page_status_content_content" value="content">Status content element content on the second page</role>
			<role key="answers_exercise" value="answers_exercise">Exercise div in Solutions chapter</role>
			<role key="answers-exercise-set" value="answers-exercise-set">Exercise-set div in Solutions chapter</role>
			<role key="answers_subexercise" value="answers_subexercise">Subexercise div in exercise-set Solutions chapter</role>
			<role key="answers_exercise_title" value="answers_exercise_title">Exercise title in Solutions chapter</role>
			<role key="answers-exercise-set-title" value="answers-exercise-set-title">Exercise-set title in Solutions chapter</role>
			<role key="answers_subexercise_title" value="answers_subexercise_title">Subexercise title in exercise-set Solutions chapter</role>
			<role key="answers_solution" value="answers_solution">Solution to exercise div in Solutions chapter</role>
			<role key="answers_solution_title" value="answers_solution_title">Solution to exercise title in Solutions chapter</role>
			<role key="answers_commentary" value="answers_commentary">Commentary to exercise div in Solutions chapter</role>
			<role key="answers_commentary_title" value="answers_commentary_title">Commentary to exercise title in Solutions chapter</role>
			<role key="answers_tip" value="answers_tip">Tip to exercise div in Solutions chapter</role>
			<role key="answers_tip_title" value="answers_tip_title">Tip to exercise title in Solutions chapter</role>
			
			<role key="toc-list" value="toc-list">Table of content</role>
			
			<role key="table_of_mark_tasks" value="table-of-mark-tasks">Table of mark tasks</role>
			<role key="label_effect_of_education" value="label-effect-of-education">Effect of education for span label</role>
			<role key="label_effect_of_education_A" value="label-effect-of-education-A">Effect of education A label</role>
			<role key="desc_effect_of_education_A" value="desc-effect-of-education-A">Effect of education A description</role>
			<role key="label_effect_of_education_B" value="label-effect-of-education-B">Effect of education B label</role>
			<role key="desc_effect_of_education_B" value="desc-effect-of-education-B">Effect of education B description</role>
			<role key="label_effect_of_education_C" value="label-effect-of-education-C">Effect of education C label</role>
			<role key="desc_effect_of_education_C" value="desc-effect-of-education-C">Effect of education C description</role>
			<role key="label_effect_of_education_K" value="label-effect-of-education-K">Effect of education K label</role>
			<role key="desc_effect_of_education_K" value="desc-effect-of-education-K">Effect of education K description</role>
			
			<role key="label_exercise" value="label-exercise">Exercise for span label</role>
			<role key="label_exercise_on_paper" value="label-exercise-on-paper">Exercise on paper label</role>
			<role key="desc_exercise_on_paper" value="desc-exercise-on-paper">Exercise on paper description</role>
			<role key="label_exercise_expanding" value="label-exercise-expanding">Exercise expanding label</role>
			<role key="desc_exercise_expanding" value="desc-exercise-expanding">Exercise expanding description</role>
			<role key="label_exercise_pairwork" value="label-exercise-pairwork">Exercise pairwork label</role>
			<role key="desc_exercise_pairwork" value="desc-exercise-pairwork">Exercise pairwork description</role>
			<role key="label_exercise_groupwork" value="label-exercise-groupwork">Exercise groupwork label</role>
			<role key="desc_exercise_groupwork" value="desc-exercise-groupwork">Exercise groupwork description</role>
			
			
			<role key="table_of_status_content" value="table-of-status-content">Table of status content</role>
			<role key="label_status_content" value="label-status-content">Table row of status content</role>
			<role key="label_status_content_R" value="label-status-content-R">Status content R label</role>
			<role key="desc_status_content_R" value="desc-status-content-R">Status content R description</role>
			<role key="label_status_content_N" value="label-status-content-N">Status content N label</role>
			<role key="desc_status_content_N" value="desc-status-content-N">Status content N description</role>
			<role key="label_content_status_expanding" value="label-content-status-expanding"></role>
			<role key="label_content_status_teacher" value="label-content-status-teacher"></role>
			
			<role key="subcollection-title" value="subcollection-title">The H1 title of subcollection of modules</role>
			
			<role key="about" value="section">Main section in About page</role>
			<role key="about_title_header" value="header">Main title for the About page</role>
			<role key="about_module" value="about">Section for a module on About page</role>
			<role key="about_module_table" value="content">Table with content for a module on About page</role>
			
			<role key="label_module_title" value="content">Label for module title</role>
			<role key="label_module_author" value="content">Label for module author/s</role>
			<role key="label_module_license" value="content">Label for module license</role>
			<role key="label_module_contact" value="content">Label for module contact</role>
			<role key="label_module_www" value="content">Label for module www</role>
			<role key="label_module_core_curriculum" value="content">Label for module core curriculum</role>
			<role key="label_womi_licenses" value="womi-licenses">Label for licenses of WOMIs in module</role>
			<role key="license-womi-author" value="license-womi-author">Span with license womi author</role>
			<role key="license-womi-title" value="license-womi-title">Span with license womi title</role>
			<role key="license-type" value="license-type">Span with license type</role>
			<role key="license" value="license">Div with license url and additional info</role>
			<role key="license-contents" value="license-contents">Div content with license url and additional info</role>
			<role key="license-url" value="license-url">Span with license url</role>
			<role key="license-additional-info" value="license-additional-info">Span with license additional info</role>
			
			<role key="important" value="important">Important part div</role>
			<role key="code" value="code">Code div</role>
			<role key="code-header" value="code-header">Code title</role>
			<role key="codeblock" value="codeblock">Block of code in code div</role>
			<role key="code-caption" value="code-caption">Caption under code</role>
			<role key="code-contents" value="code-contents">code contents</role>
			
			<role key="note" value="note">Note div</role>
			<role key="note-header" value="note-header">Note header title</role>
			<role key="note-contents" value="note-contents">Note contents</role>
			<role key="note-tip" value="note-tip">Note div</role>
			<role key="note-concept-check" value="note-concept-check">Note div</role>
			<role key="note-important" value="note-important">Note div</role>
			<role key="note-warning" value="note-warning">Note div</role>
			<role key="note-curiosity" value="note-curiosity">Note div</role>
			<role key="note-good-to-know" value="note-good-to-know">Note div</role>
			<role key="note-remember" value="note-remember">Note div</role>
			<role key="note-consider" value="note-consider">Note div</role>
			<role key="note-see-also" value="note-see-also">Note div</role>
			<role key="note-for-interested" value="note-for-interested">Note div</role>
			<role key="note-time-capsule" value="note-time-capsule">Note div</role>
			<role key="note-no-label" value="note-no-label">Note div</role>
			<role key="foldable" value="foldable">Foldable element</role>
			<role key="foldable-header" value="foldable-header">Foldable header</role>
			<role key="foldable-contents" value="foldable-contents note-ignore">Foldable content</role>
			<role key="fold-point" value="fold-point">fold-point</role>
			
			<role key="strip-end" value="strip-end">strip-end</role>
			<role key="strip-start" value="strip-start">strip-start</role>
			<role key="zebra-module" value="zebra-module">zebra-module</role>
			<role key="science-module" value="science-module">science-module</role>
			
			<role key="note-toggle" value="note-toggle">Div to turn on/off the note</role>
			<role key="example" value="example">Example div</role>
			<role key="example-header" value="example-header">Example header title</role>
			<role key="example-contents" value="example-contents">Example content</role>
			<role key="definition" value="definition">Definition div</role>
			<role key="definition-header" value="definition-header">Definition header</role>
			<role key="definition-contents" value="definition-contents">Definition div contents</role>
			<role key="concept" value="concept">Concept div</role>
			<role key="concept-header" value="concept-header">Concept header</role>
			<role key="concept-contents" value="concept-contents">Concept div contents</role>
			<role key="term" value="term">Term div</role>
			<role key="seealso" value="seealso">Seealso div</role>
			<role key="cite" value="cite">Cite/quote div</role>
			<role key="cite-title" value="cite-title">Cite/quote title</role>
			<role key="meaning" value="meaning">Meaning div</role>
			<role key="rule" value="rule">Rule div</role>
			<role key="rule-header" value="rule-header">Rule header</role>
			<role key="rule-contents" value="rule-contents">Rule content</role>
			
			<role key="theorem" value="theorem">Theorem type of Rule div</role>
			<role key="lemma" value="lemma">Lemma type of Rule div</role>
			<role key="corollary" value="corollary">Corollary type of Rule div</role>
			<role key="law" value="law">Law type of Rule div</role>
			<role key="proposition" value="proposition">Proposition type of Rule div</role>
			
			<role key="statement" value="statement">Statement div</role>
			<role key="statement-header" value="statement-header">Statement header</role>
			<role key="statement-contents" value="statement-contents">Statement header</role>
			<role key="list" value="list">List div</role>
			<role key="list-header" value="list-header">List header</role>
			<role key="equation" value="equation">Equation div</role>
			<role key="equation-header" value="equation-header">Equation header</role>
			<role key="equation-contents" value="equation-contents">Equation contents</role>
			<role key="figure" value="figure">Figure div</role>figure-header
			<role key="figure-header" value="figure-header">Figure header</role>
			<role key="figure-content" value="figure-content">Figure content</role>
			<role key="exercise" value="exercise">Exercise div</role>
			<role key="dynamic" value="dynamic">Exercise dynamic div</role>
			<role key="on-paper" value="on-paper">Exercise to be done on paper</role>
			<role key="expanding" value="expanding">Exercise expanding</role>
			<role key="teacher" value="teacher">Note teacher</role>
			<role key="command" value="command">Exercise type: command</role>
			<role key="command-header" value="command-header">Exercise type: command</role>
			<role key="command-contents" value="command-contents">Exercise type: command</role>
			<role key="student-work" value="student-work">Student work container element</role>
			<role key="student-work-header" value="student-work-header">Student work container element</role>
			<role key="student-work-contents" value="student-work-contents">Student work container element</role>
			<role key="evaluation" value="evaluation">Student work type</role>
			<role key="homework" value="homework">Student work type - homework</role>
			<role key="project" value="project">Student work type - project</role>
			<role key="exercise-set" value="exercise-set">Student work type - exercise set</role>
			<role key="exposed" value="exposed">Specifies, that element should be exposed in module</role>
			
			<role key="JPOL3_simple" value="simple">Exercise type: simple</role>
			<role key="JPOL3_pairs" value="pairs">Exercise type: pairs</role>
			<role key="JPOL3_play" value="play">Exercise type: play</role>
			<role key="JPOL3_sorceress" value="sorceress">Exercise type: sorceress</role>
			<role key="JPOL3_imp" value="imp">Exercise type: imp</role>
			<role key="JPOL3_reading" value="reading">Exercise type: reading</role>
			<role key="JPOL3_challenge" value="challenge">Exercise type: challenge</role>
			<role key="JPOL3_interactive" value="interactive">Exercise type: interactive</role>
			<role key="pair-work" value="pair-work">Exercise type: pair-work</role>
			<role key="groupwork" value="groupwork">Exercise type: groupwork</role>
			<role key="game" value="game">Exercise type: game</role>
			<role key="witch" value="witch">Exercise type: witch</role>
			<role key="reading" value="reading">Exercise type: reading</role>
			<role key="challenge" value="challenge">Exercise type: challenge</role>
			<role key="interactive" value="interactive">Exercise type: interactive</role>
			
			<role key="exercise-header" value="exercise-header">Exercise header</role>
			<role key="exercise-contents" value="exercise-contents note-ignore">Exercise header</role>
			<role key="commentary" value="commentary">Commentary div</role>
			<role key="commentary-header" value="commentary-header">Commentary header</role>
			<role key="commentary-contents" value="commentary-contents">Commentary contents</role>
			<role key="commentary-example" value="commentary-example">Commentary example</role>
			<role key="commentary-example-header" value="commentary-example-header">Commentary example header</role>
			<role key="commentary-example-contents" value="commentary-example-contents">Commentary example contents</role>
			<role key="problem" value="problem">Problem div</role>
			<role key="problem-header" value="problem-header">Problem header</role>
			<role key="problem-contents" value="problem-contents">Problem contents</role>
			<role key="proof" value="proof">Proof div</role>
			<role key="proof-header" value="proof-header">Proof header</role>
			<role key="proof-contents" value="proof-contents">Proof contents</role>
			<role key="commentary-toggles" value="commentary-toggles">Div to turn on/off the commentary</role>
			<role key="commentary-toggle" value="commentary-toggle">Toggle button</role>
			<role key="answers" value="answers">Main div containing list of solution/answers in Solutions chapter</role>
			<role key="answer-prefix" value="answer-prefix">Prefix for answer list element (like "a)")</role>
			<role key="textarea-placeholder" value="textarea-placeholder">Replacement of textarea; div with the command "write down the answer in your notebook"</role>
			<role key="solution" value="solution">Solution div</role>
			<role key="solution-header" value="solution-header">Solution header</role>
			<role key="solution-contents" value="solution-contents">Solution contents</role>
			<role key="solution-toggles" value="solution-toggles">Div to turn on/off the solution</role>
			<role key="solution-toggle" value="solution-toggle">Toggle button</role>
			<role key="effect-of-education" value="effect-of-education">Effect of education div</role>
			<role key="effect-of-education-label" value="effect-of-education-label">Effect of education label div</role>
			<role key="effect-of-education-A" value="effect-of-education-A">Effect of education A div</role>
			<role key="effect-of-education-B" value="effect-of-education-B">Effect of education B div </role>
			<role key="effect-of-education-C" value="effect-of-education-C">Effect of education C div</role>
			<role key="effect-of-education-K" value="effect-of-education-K">Effect of education K div</role>
			<role key="effect-of-education-JPOL3_poziom1" value="effect-of-education-poziom1">Difficulty level for polish textbook</role>
			<role key="effect-of-education-JPOL3_poziom2" value="effect-of-education-poziom2">Difficulty level for polish textbook</role>
			
			
			<role key="section" value="section">Standard section div</role>
			<role key="section-header" value="section-header">Standard section div header with title</role>
			<role key="section-contents" value="section-contents">Standard section div content</role>
			
			<role key="columns" value="columns">Section with at least two columns</role>
			
			<role key="about_module_learning_objectives" value="content">Main element of learning objective</role>
			<role key="about_module_learning_objectives_table" value="content">Table with learning objective elements</role>
			<role key="about_module_learning_objectives_title_label" value="content">Label for learning objects title</role>
			<role key="about_module_learning_objectives_title" value="learning-objectives-title">Title of learning objective main element</role>
			<role key="learning_objective" value="content">Label of learning objective element</role>
			<role key="learning_objective_label" value="learning-objective-label">Label of learning objective element</role>
			<role key="learning_objective_label_key" value="learning-objective-label-key">Label key of learning objective element</role>
			<role key="learning_objective_label_name" value="learning-objective-label-name">Label name of learning objective element</role>
			<role key="learning_objective_text" value="learning-objective-text">Text of learning objective element</role>
			
			<role key="answers-module-section" value="answers-module-section">Main section with module title in answers</role>
			<role key="answers-module-section-title" value="answers-module-section-title">Section with module title in answers</role>
			<role key="answers-module-padding-title" value="answers-module-padding-title">Section with padding title in answers</role>
			
			<role key="level_1" value="level_1">Section level 1</role>
			<role key="level_2" value="level_2">Section level 2</role>
			<role key="level_3" value="level_3">Section level 3</role>
			<role key="level_4" value="level_4">Section level 4</role>
			
			<role key="title" value="title">Title of element (div, section, meaning, note, item)</role>	
			<role key="no-title" value="no-title">Special role for header of observation or experience without title</role>	
			<role key="label" value="label">Label item in list (div, section)</role>

			<role key="transcript" value="transcript">Movie transcript</role>
			
			<role key="para-header" value="para-header">Header div with title for para</role>
			<role key="para" value="para">Para div with content</role>
			<role key="link" value="link">Link</role>
			<role key="intercollection-link" value="link">Linkl między podręcznikowy</role>
			<role key="link-text" value="link-text">Link text</role>
			
			<role key="glossary-link" value="glossary-link">Link to glossary entry</role>
			<role key="biography-link" value="biography-link">Link to biography entry</role>
			<role key="event-link" value="event-link">Link to event entry</role>
			<role key="bibliography-link" value="bibliography-link">Link to bibliography entry</role>
			<role key="concept-link" value="concept-link">Link to concept entry</role>
			<role key="tooltip-link" value="tooltip-link">Link to tooltip entry</role>
			
			<role key="emphasis" value="emphasis">Link text</role>
			<role key="quote-header" value="quote-header">Div with title for quote</role>
			<role key="quote" value="quote">Div with quote</role>
			<role key="quote-contents" value="quote-contents">Div with quote content</role>
			<role key="quote-source" value="quote-source">Div with source for quote</role>
			<role key="source" value="source">Div with source</role>
			<role key="source-contents" value="source-contents">Div with source contents</role>
			<role key="sup" value="sup">Superscript</role>
			<role key="sub" value="sub">Subscript</role>
			<role key="foreign" value="foreign">Part with foreign language</role>
			<role key="preformat" value="preformat">Defines preformatted text</role>
			<role key="newline" value="newline">Span with br</role>
			<role key="space" value="space">Pre with spaces</role>
			<role key="footnote-reference" value="footnote-reference">Footnote reference</role>
			
			<role key="labeled-item" value="labeled-item">Labeled list</role>
			<role key="bullet" value="bullet">Bulleted list</role>
			<role key="open-circle" value="open-circle">Open cicrcle list</role>
			<role key="arabic" value="arabic">Arabic list</role>
			<role key="upper-alpha" value="upper-alpha">Upper-alpha list</role>
			<role key="lower-alpha" value="lower-alpha">Lower-alpha list</role>
			<role key="upper-roman" value="upper-roman">Upper-roman list</role>
			<role key="lower-roman" value="lower-roman">Lower-roman list</role>
			<role key="enumerated" value="enumerated">Enumerated list</role>
			<role key="enumerated-full-path" value="enumerated-full-path">Enumerated full path list</role>
			<role key="other" value="other">Other list</role>
			
			<role key="item" value="item">Item in list</role>
			<role key="item-decoration" value="item-decoration">Item in list prefix decoration</role>
			<role key="vertical-subfigure" value="vertical-subfigure">Subfigure</role>
			<role key="vertical-subfigure-header" value="figure-header">Subfigure header</role>
			<role key="vertical-subfigure-content" value="figure-content">Subfigure content</role>
			<role key="horizontal-subfigure" value="horizontal-subfigure">Subfigure</role>
			<role key="horizontal-subfigure-header" value="figure-header">Subfigure header</role>
			<role key="horizontal-subfigure-content" value="figure-content">Subfigure content</role>
			<role key="vertical-subfigure-caption" value="vertical-subfigure-caption">Subfigure caption</role>
			<role key="horizontal-subfigure-caption" value="horizontal-subfigure-caption">Subfigure caption</role>
			<role key="figure-caption" value="figure-content">Figure content</role>
			<role key="caption" value="caption">Caption</role>
			<role key="check-understanding" value="check-understanding">Exercise check understanding</role>
			<role key="answers-list" value="answers-list">Div with answers for exercise</role>
			
			<role key="problemset" value="problemset">Div with problem set</role>
			<role key="problemset-header" value="problemset-header">Header for problem set</role>
			<role key="qmlitem" value="qmlitem">Div with qmel exercise</role>
			<role key="qmlitem-header" value="qmlitem-header">Header to qml exercise</role>
			<role key="question" value="question">question</role>
			<role key="button" value="button">Button to answer questions</role>
			<role key="feedback" value="feedback">Div with feedback after answer</role>
			<role key="correct" value="correct">Div with feedback if answer was correct</role>
			<role key="incorrect" value="incorrect">Div with feedback if answer was incorrect</role>
			<role key="answer" value="answer">Div with one answer to qml exercise</role>
			<role key="radio" value="radio">Radio button input</role>
			<role key="checkbox" value="checkbox">Checkbox button input</role>
			<role key="hint" value="hint">Qml hint to exercise</role>
			
			<role key="hint-label" value="hint-label">Qml hint button normal label</role>
			<role key="next-hint-label" value="next-hint-label">Qml hint button next label</role>
			<role key="true-false" value="true-false">Type of dynamic exercise - ZW2</role>
			<role key="answer-set" value="answer-set">Set of answers in dynamic qml exercises</role>
			<role key="answers-container" value="answers-container">Container for all answers, without buttons</role>
			<role key="set-header" value="set-header">Header of set of answers</role>
			
			<role key="randomize" value="randomize">Behaviour of dynamic qml exercise</role>
			<role key="randomize-sets" value="randomize-sets">Behaviour of dynamic qml exercise</role>
			<role key="all-sets" value="all-sets">Behaviour of dynamic qml exercise</role>
			
			
			<role key="recreate" value="recreate">New example button</role>
			<role key="check" value="check">Check button</role>
			<role key="exercise-buttons" value="exercise-buttons">Div for all exercise buttons</role>
			<role key="answers-header" value="answers-header">Header with labels for ZW2 exercise</role>
			<role key="answers-label" value="answers-label">Label true/false for ZW2 exercise</role>
			<role key="response" value="response">Exercise response, inside answer</role>
			<role key="response-input" value="response-input">Exercise response radio button</role>
			<role key="hidden-text" value="hidden-text">Portal class to hide element</role>
			
			<role key="table" value="table">Html table</role>
			<role key="table-layout-auto" value="table-layout-auto">Html table auto layout</role>
			<role key="table-text" value="table-text">Html table header with caption</role>
			<role key="table-caption" value="table-caption">Html table caption</role>
			<role key="table-style-plain" value="table-plain">Html table style - no zebra on table data</role>
			<role key="table-style-zebra" value="table-zebra">Html table style - zebra on table data</role>
			<role key="entrytbl" value="entrytbl">Html table td</role>
			
			<role key="lead" value="lead">oznaczenie fragmentu treści, jako marketingowego opisu lekcji</role>
			<role key="intro" value="intro">pozwala na oznaczenie fragmentu treści, jako opisującego, co jest przedmiotem lekcji</role>
			<role key="revisal" value="revisal">pozwala na oznaczenie fragmentu treści, który opisuje wymagania, które musi spełnić uczeń przed przystąpieniem do lekcji</role>
			<role key="effect" value="effect">pozwala na oznaczenie fragmentu treści, który opisuje jakie umiejętności osiągnie uczeń po ukończeniu lekcji</role>
			<role key="knowledge" value="effect-knowledge">pozwala na oznaczenie fragmentu treści, który opisuje jakie umiejętności osiągnie uczeń po ukończeniu lekcji</role>
			<role key="skill" value="effect-skill">pozwala na oznaczenie fragmentu treści, który opisuje jakie umiejętności osiągnie uczeń po ukończeniu lekcji</role>
			<role key="understanding" value="effect-understanding">pozwala na oznaczenie fragmentu treści, który opisuje jakie umiejętności osiągnie uczeń po ukończeniu lekcji</role>
			<role key="prerequisite" value="prerequisite">pozwala na oznaczenie fragmentu treści, który opisuje, co uczeń powinien przygotować (fizycznie) przed lekcją, aby mógł przeprowadzić opisane w niej ćwiczenia/doświadczenia</role>
			<role key="writing" value="writing">pozwala oznaczyć fragmenty treści będące tytułami utworów literackich</role>
			<role key="bibliography-reference" value="bibliography-reference"> pozwala na powiązanie fragmentu tekstu z dowolnym, zdefiniowanym w module biblograficznym wpisem</role>
			
			<role key="experiment" value="experiment">pozwala na zdefiniowanie eksperymentu</role>
			<role key="observation" value="observation">pozwala na zdefiniowanie obserwacji</role>
			<role key="experiment-problem" value="experiment-problem">część eksperymentu</role>
			<role key="hypothesis" value="hypothesis">część eksperymentu</role>
			<role key="instruments" value="instruments">część eksperymentu</role>
			<role key="instructions" value="instructions">część eksperymentu</role>
			<role key="conclusions" value="conclusions">część eksperymentu</role>
			<role key="demonstration" value="demonstration">część eksperymentu</role>
			<role key="objective" value="objective">część obserwacji</role>
			<role key="warning" value="warning">naglowek elementu doświadczenie/obserwacja z potrzeba nadzoru osoby dorosłej</role>
			<role key="warning-message" value="warning-message">ostrzeżenie o potrzebie nadzoru osoby dorosłej podczas wykonywania doświadczenia/obserwacji</role>
			
			<role key="biography" value="biography">biogram</role>
			<role key="birth" value="birth">narodziny</role>
			<role key="death" value="death">śmierć</role>
			<role key="event-start" value="event-start">rozpoczęcie wydarzenia</role>
			<role key="event-end" value="event-end">zakończenie wydarzenia</role>
			<role key="start" value="event-start">rozpoczęcie wydarzenia</role>
			<role key="end" value="event-end">zakończenie wydarzenia</role>
			
			<role key="date" value="date">data</role>
			<role key="location" value="location">miejsce</role>
			<role key="gallery" value="womi-gallery">Galeria zdjęć</role>
			
			<role key="glossary" value="glossary">słowniczek pojęć</role>
			<role key="entry" value="entry">Wpis do słowniczka</role>
			<role key="name" value="name">Nazwa</role>
			<role key="name-inline" value="name-inline">Nazwa</role>
			<role key="content" value="content">Zawartość</role>
			<role key="author" value="author">Autor</role>
			<role key="event" value="event">Wydarzenie</role>
			<role key="event-name" value="event-name">Wydarzenie w treści</role>
			<role key="literary-work-description" value="literary-work-description">O dziele</role>
			<role key="literary-work-summary" value="literary-work-summary">Streszczenie</role>
			<role key="person" value="person">Autor w treści</role>
			<role key="tooltip" value="tooltip">Dymek</role>
			<role key="tooltip-reference" value="tooltip-reference">referencja dymeku</role>
			<role key="procedure-instructions" value="procedure-instructions">Instrukcja</role>
			<role key="comment" value="comment">Komentarz do cytatu</role>
			<role key="quote-line" value="quote-line">Jedna linia/wers cytatu</role>
			
			<role key="lead-header" value="lead-header">(header) oznaczenie fragmentu treści, jako marketingowego opisu lekcji</role>
			<role key="intro-header" value="intro-header">(header) pozwala na oznaczenie fragmentu treści, jako opisującego, co jest przedmiotem lekcji</role>
			<role key="revisal-header" value="revisal-header">(header) pozwala na oznaczenie fragmentu treści, który opisuje wymagania, które musi spełnić uczeń przed przystąpieniem do lekcji</role>
			<role key="effect-header" value="effect-header">(header) pozwala na oznaczenie fragmentu treści, który opisuje jakie umiejętności osiągnie uczeń po ukończeniu lekcji</role>
			<role key="prerequisite-header" value="prerequisite-header">(header) pozwala na oznaczenie fragmentu treści, który opisuje, co uczeń powinien przygotować (fizycznie) przed lekcją, aby mógł przeprowadzić opisane w niej ćwiczenia/doświadczenia</role>
			<role key="bibliography-reference" value="bibliography-reference">(header) pozwala na powiązanie fragmentu tekstu z dowolnym, zdefiniowanym w module biblograficznym wpisem</role>
			
			<role key="experiment-header" value="experiment-header">(header) pozwala na zdefiniowanie eksperymentu</role>
			<role key="observation-header" value="observation-header">(header) pozwala na zdefiniowanie obserwacji</role>
			<role key="experiment-problem-header" value="experiment-problem-header">(header) część eksperymentu</role>
			<role key="hypothesis-header" value="hypothesis-header">(header) część eksperymentu</role>
			<role key="instruments-header" value="instruments-header">(header) część eksperymentu</role>
			<role key="instructions-header" value="instructions-header">(header) część eksperymentu</role>
			<role key="conclusions-header" value="conclusions-header">(header) część eksperymentu</role>
			<role key="objective-header" value="objective-header">(header) część obserwacji</role>
			
			<role key="biography-header" value="biography-header">(header) biogram</role>
			<role key="birth-header" value="birth-header">(header) narodziny</role>
			<role key="death-header" value="death-header">(header) śmierć</role>
			<role key="event-start-header" value="event-start-header">(header) rozpoczecie</role>
			<role key="event-end-header" value="event-end-header">(header) zakonczenie</role>
			<role key="start-header" value="event-start-header">(header) rozpoczecie</role>
			<role key="end-header" value="event-end-header">(header) zakonczenie</role>
			
			<role key="date-header" value="date-header">(header) data</role>
			<role key="location-header" value="location-header">(header) miejsce</role>
			<role key="date-birth-header" value="date-header">(header) data</role>
			<role key="date-event-start-header" value="date-header">(header) data rozpoczęcia</role>
			<role key="date-event-occur-header" value="date-header">(header) data wystąpienia</role>
			<role key="date-start-header" value="date-header">(header) data rozpoczęcia</role>
			<role key="date-occur-header" value="date-header">(header) data wystąpienia</role>
			
			<role key="location-birth-header" value="location-header">(header) miejsce</role>
			<role key="location-event-start-header" value="location-header">(header) miejsce rozpoczęcia wydarzenia</role>
			<role key="location-event-occur-header" value="location-header">(header) miejsce rozpoczęcia wydarzenia</role>
			<role key="location-event-end-header" value="location-header">(header) miejsce zakończenie wydarzenia</role>
			<role key="location-start-header" value="location-header">(header) miejsce rozpoczęcia wydarzenia</role>
			<role key="location-occur-header" value="location-header">(header) miejsce rozpoczęcia wydarzenia</role>
			<role key="location-end-header" value="location-header">(header) miejsce zakończenie wydarzenia</role>
			
			<role key="date-death-header" value="date-header">(header) data</role>
			<role key="date-event-end-header" value="date-header">(header) data</role>
			<role key="date-end-header" value="date-header">(header) data</role>
			
			<role key="location-death-header" value="location-header">(header) miejsce</role>
			<role key="location-event-header" value="location-header">(header) miejsce</role>
			<role key="gallery-header" value="womi-gallery-header">(header) Galeria zdjęć</role>
			
			<role key="glossary-header" value="glossary-header">(header) słowniczek pojęć</role>
			<role key="entry-header" value="entry-header">(header) Wpis do słowniczka</role>
			<role key="author-header" value="author-header">(header) Autor</role>
			<role key="event-header" value="event-header">(header) Wydarzenie</role>
			<role key="literary-work-description-header" value="literary-work-description-header">(header) O dziele</role>
			<role key="literary-work-summary-header" value="literary-work-summary-header">(header) Streszczenie</role>
			<role key="tooltip-header" value="tooltip-header">(header) dymek</role>
			<role key="procedure-instructions-header" value="procedure-instructions-header">(header) instrukcja</role>
			<role key="step-header" value="step-header">(header) krok</role>
			<role key="comment-header" value="comment-header">(header) komentarz cytatu</role>
			
			<role key="lead-contents" value="lead-contents">(contents) oznaczenie fragmentu treści, jako marketingowego opisu lekcji</role>
			<role key="intro-contents" value="intro-contents">(contents) pozwala na oznaczenie fragmentu treści, jako opisującego, co jest przedmiotem lekcji</role>
			<role key="revisal-contents" value="revisal-contents">(contents) pozwala na oznaczenie fragmentu treści, który opisuje wymagania, które musi spełnić uczeń przed przystąpieniem do lekcji</role>
			<role key="effect-contents" value="effect-contents">(contents) pozwala na oznaczenie fragmentu treści, który opisuje jakie umiejętności osiągnie uczeń po ukończeniu lekcji</role>
			<role key="prerequisite-contents" value="prerequisite-contents">(contents) pozwala na oznaczenie fragmentu treści, który opisuje, co uczeń powinien przygotować (fizycznie) przed lekcją, aby mógł przeprowadzić opisane w niej ćwiczenia/doświadczenia</role>
			<role key="bibliography-reference" value="bibliography-reference">(contents) pozwala na powiązanie fragmentu tekstu z dowolnym, zdefiniowanym w module biblograficznym wpisem</role>
			
			<role key="experiment-contents" value="experiment-contents">(contents) pozwala na zdefiniowanie eksperymentu</role>
			<role key="observation-contents" value="observation-contents">(contents) pozwala na zdefiniowanie obserwacji</role>
			<role key="experiment-problem-contents" value="experiment-problem-contents">(contents) część eksperymentu</role>
			<role key="hypothesis-contents" value="hypothesis-contents">(contents) część eksperymentu</role>
			<role key="instruments-contents" value="instruments-contents">(contents) część eksperymentu</role>
			<role key="instructions-contents" value="instructions-contents">(contents) część eksperymentu</role>
			<role key="conclusions-contents" value="conclusions-contents">(contents) część eksperymentu</role>
			<role key="demonstration-contents" value="demonstration-contents">(contents) część eksperymentu</role>
			<role key="objective-contents" value="objective-contents">(contents) część obserwacji</role>
			
			<role key="biography-contents" value="biography-contents">(contents) biogram</role>
			<role key="birth-contents" value="birth-contents">(contents) narodziny</role>
			<role key="death-contents" value="death-contents">(contents) śmierć</role>
			<role key="event-start-contents" value="event-start-contents">(header) rozpoczecie</role>
			<role key="event-end-contents" value="event-end-contents">(header) zakonczenie</role>
			<role key="start-contents" value="event-start-contents">(header) rozpoczecie</role>
			<role key="end-contents" value="event-end-contents">(header) zakonczenie</role>
			
			<role key="date-contents" value="date-contents">(contents) data</role>
			<role key="location-contents" value="location-contents">(contents) miejsce</role>
			<role key="gallery-contents" value="womi-gallery-contents note-ignore">(contents) Galeria zdjęć</role>
			<role key="gallery-contents-others" value="womi-gallery-contents-others note-ignore">(contents-others) Galeria zdjęć do pdf</role>
			
			<role key="glossary-contents" value="glossary-contents">(contents) słowniczek pojęć</role>
			<role key="entry-contents" value="entry-contents">(contents) Wpis do słowniczka</role>
			<role key="author-contents" value="author-contents">(contents) Autor</role>
			<role key="event-contents" value="event-contents">(contents) Wydarzenie</role>
			<role key="event-info" value="event-info">(info) Wydarzenie</role>
			<role key="literary-work-description-contents" value="literary-work-description-contents">(contents) O dziele</role>
			<role key="literary-work-summary-contents" value="literary-work-summary-contents">(contents) Streszczenie</role>
			<role key="biography-info" value="biography-info">(info) biogram info</role>
			<role key="biography-metrics" value="biography-metrics">(metrics) biogram metrics</role>
			<role key="event-metrics" value="event-metrics">(metrics) event metrics</role>
			<role key="tooltip-contents" value="tooltip-contents">(contents) dymek</role>
			<role key="procedure-instructions-contents" value="procedure-instructions-contents">(contents) instrukcja</role>
			<role key="step-contents" value="step-contents">(contents) krok</role>
			<role key="comment-contents" value="comment-contents">(contents) komentarz cytatu</role>
			
			<role key="bold" value="bold">For emphasis: The text will be boldface</role>
			<role key="italics" value="italics">For emphasis: The text will be italicized</role>
			<role key="underline" value="bold">For emphasis: The text will be underlined (mapped to bold for now)</role>
			<role key="smallcaps" value="bold">For emphasis: The text will be capitalized using small capitals (mapped to bold for now)</role>
			<role key="bolditalics" value="bold italics">For emphasis</role>
			<role key="boldunderline" value="bold italics">For emphasis</role>
			<role key="boldsmallcaps" value="bold italics">For emphasis</role>
			<role key="italicsunderline" value="italics">For emphasis</role>
			<role key="italicssmallcaps" value="italics">For emphasis</role>

			<role key="numbering" value="numbering">Glogal element order number</role>
			<role key="numbering-prefix" value="numbering-prefix">Prefix for element order number</role>
			<role key="numbering-element" value="numbering-element">Specific element count number(exercise, example, etc.)</role>
			<role key="numbering-end-character" value="numbering-end-character">Character at the end of numbering</role>
			<role key="quote-separator" value="quote-separator">Separator after label</role>
			<role key="colon" value="colon">Separator in quote</role>
			<role key="coma" value="coma">Separator in quote</role>
			<role key="step" value="step">Step in instruction</role>
			<role key="classic" value="classic">format tekstu skojarzonego</role>
			<role key="mobile" value="mobile">format tekstu skojarzonego</role>
			<role key="static" value="static">format tekstu skojarzonego</role>
			<role key="static-mono" value="static-mono">format tekstu skojarzonego</role>
			<role key="bookmark" value="bookmark">target element of link</role>
			<role key="nowomi-image-container" value="nowomi-image-container">Container for img in alternative html for interactive WOMI exercise</role>
			<role key="nowomi-image-caption" value="nowomi-image-caption">Caption for img in alternative html for interactive WOMi exercise</role>
			<role key="nowomi-image-label" value="nowomi-image-label">Label for img in alternative html for interactive WOMi exercise</role>
			<role key="nowomi-image-title" value="nowomi-image-title">Title for img in alternative html for interactive WOMi exercise</role>
			<role key="module-header" value="module-header">Header with module title</role>
			<role key="module-header-caption" value="module-header-caption">Capion for header with module title</role>
			<role key="icon-header" value="icon-header">Span for icon</role>
			<role key="technical-remarks" value="technical-remarks">Komentarz techniczny</role>
			<role key="technical-remarks-contents" value="technical-remarks-contents">Komentarz techniczny - zawartość</role>
			
			
			<role key="JPOL_common" value="common">Quote type: common</role>
			<role key="JPOL_poetry" value="poetry">Quote type: poetry</role>
			<role key="JPOL_prose" value="prose">Quote type: prose</role>
			<role key="JPOL_drama" value="drama">Quote type: drama</role>
			<role key="JPOL_handwriting" value="handwriting">Quote type: handwriting</role>
			<role key="JPOL_computer" value="computer">Quote type: computer</role>
			<role key="JPOL_official" value="official">Quote type: official</role>
			<role key="JPOL_motto-author" value="motto-author">Quote type: motto-author</role>
			<role key="JPOL_motto-saying" value="motto-saying">Quote type: motto-saying</role>
			<role key="JPOL_gremlin" value="gremlin">Quote type: gremlin</role>
			<role key="HIST_historiography" value="historiography">Quote type: historiography</role>
			<role key="HIST_literature" value="literature">Quote type: literature</role>
			<role key="HIST_historical-prose" value="historical-prose">Quote type: historical-prose</role>
			<role key="HIST_historical-poetry" value="historical-poetry">Quote type: historical-poetry</role>
			<role key="readability-hard" value="readability-hard">Quote type: readability-hard</role>
			<role key="readability-medium" value="readability-medium">Quote type: readability-medium</role>
			<role key="readability-easy" value="readability-easy">Quote type: readability-easy</role>

			<role key="JPOL3_walking_encyclopedy" value="walking_encyclopedy">Tooltip type: common</role>
			<role key="JPOL3_miss_recipe" value="miss_recipe">Tooltip type: common</role>
			<role key="JPOL3_curiosity" value="curiosity">Tooltip type: common</role>
			<role key="JPOL3_laughter" value="laughter">Tooltip type: common</role>
			<role key="JPOL3_dont_forget" value="dont_forget">Tooltip type: common</role>
			<role key="JPOL_E3_E4_curiosity" value="curiosity">Tooltip type: common</role>
			<role key="JPOL_E3_E4_apposition" value="apposition">Tooltip type: common</role>
			<role key="JPOL_E3_E4_glossary" value="glossary">Tooltip type: common</role>
			<role key="disabled-alternative" value="disabled-alternative">Tooltip type: common</role>

			<role key="bibliography" value="bibliography">Main div bibliography</role>
			<role key="bibliography-header" value="bibliography-header">Header div bibliography</role>
			<role key="bib-entry" value="bib-entry"></role>
			<role key="bib-incollection" value="bib-incollection"></role>
			<role key="bib-incollectionFree" value="bib-incollection-free"></role>
			<role key="bib-article" value="bib-article"></role>
			<role key="bib-unpublished" value="bib-unpublished"></role>
			<role key="bib-manual" value="bib-manual"></role>
			<role key="bib-misc" value="bib-misc"></role>
			<role key="bib-author" value="bib-author"></role>
			<role key="bib-title" value="bib-title"></role>
			<role key="bib-booktitle" value="bib-booktitle"></role>
			<role key="bib-publisher" value="bib-publisher"></role>
			<role key="bib-year" value="bib-year"></role>
			<role key="bib-series" value="bib-series"></role>
			<role key="bib-address" value="bib-address"></role>
			<role key="bib-pages" value="bib-pages"></role>
			<role key="bib-editor" value="bib-editor"></role>
			<role key="bib-journal" value="bib-journal"></role>
			<role key="bib-note" value="bib-note"></role>
			<role key="bib-organization" value="bib-organization"></role>
			<role key="bib-edition" value="bib-edition"></role>
			<role key="bib-key" value="bib-key"></role>
			<role key="bib-howpublished" value="bib-howpublished"></role>
			<role key="bib-inline-only" value="bib-inline-only"></role>
			<role key="bib-bibliography-only" value="bib-bibliography-only"></role>
			<role key="bib-bibliography-and-module" value="bib-bibliography-and-module"></role>
			<role key="custom-bib" value="custom-bib"></role>
			
			<role key="after-text" value="after-text"></role>
			<role key="before-text" value="before-text"></role>
			<role key="after-block" value="after-block"></role>
			
			<role key="full-width" value="full-width"></role>
			<role key="extended-width" value="extended-width"></role>
			<role key="extended-shifted-width" value="extended-shifted-width"></role>
			<role key="extra-column" value="extra-column"/>
			
			<role key="go-to-glossary" value="go-to-glossary"/>
			<role key="go-back-from-glossary" value="go-back-from-glossary"/>
			
			<role key="debate" value="debate"/>
			
			<role key="work-area-container" value="work-area-container"/>
			<role key="work-area" value="work-area"/>
			<role key="open-question" value="open-question"/>
			<role key="note-ignore" value="note-ignore"/>
			<role key="polecenie-uzupelniajace" value="polecenie-uzupelniajace"/>
			
			<xsl:copy-of select="document('tile-role2css.xml')/roles/*"/>
			
		</role2css-mappings>
	</xsl:variable>
</xsl:stylesheet>
