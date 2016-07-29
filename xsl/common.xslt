<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	xmlns:tmp="tmp" 
	xmlns:ep="http://epodreczniki.pl/" 
	xmlns:col="http://cnx.rice.edu/collxml"
	xmlns:md="http://cnx.rice.edu/mdml"
	xmlns:q="http://cnx.rice.edu/qml/1.0"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:dlibra_avs="https://epodreczniki.pcss.pl/repo/"
	xmlns:cn="http://cnx.rice.edu/cnxml"
	exclude-result-prefixes="fn tmp col md">
	
	<xsl:param name="path_to_files_epxml_of_modules_in_col" select="1"/>
	<xsl:param name="www_link">http://www.epodreczniki.pl/reader/c/</xsl:param>
	<xsl:param name="womiLocalPath" select="''"/>	
	
	<xsl:variable name="coll">
		<xsl:choose>
			<xsl:when test="/col:collection">
				<xsl:copy-of select="/col:collection"></xsl:copy-of>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="document(concat($path_to_files_epxml_of_modules_in_col,'/collection.xml'))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="modules">
		<documents xmlns="http://cnx.rice.edu/cnxml">
			<xsl:for-each select="$coll//col:module">
				<xsl:copy-of select="document(concat($path_to_files_epxml_of_modules_in_col, '/', ./@document, '/index.epxml'))"/>
			</xsl:for-each>
		</documents>
	</xsl:variable>
	 
	<xsl:variable name="subject">
		<xsl:for-each select="$coll/col:collection/col:metadata/md:subjectlist/md:subject">
			<xsl:value-of select="."/>
			<xsl:if test="position() != last()">
				<xsl:text>;</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="education_level">
		<xsl:value-of select="$coll/col:collection/col:metadata/md:education-levellist/md:education-level"></xsl:value-of>
	</xsl:variable>
	 
	<xsl:variable name="months" select="'stycznia,lutego,marca,kwietnia,maja,czerwca,lipca,sierpnia,września,października,listopada,grudnia'" as="xs:string"/>
		
	<xsl:template match="tmp:authors">
		<xsl:for-each select="tmp:author">
			<xsl:choose>
				<xsl:when test="position()=1"></xsl:when>
				<xsl:when test="position()=last()"> i </xsl:when>
				<xsl:when test="position()>1">, </xsl:when>
			</xsl:choose>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:function name="ep:generate-id" as="node()">
		<xsl:param name="context"/>
		<xsl:value-of select="generate-id($context)"/>
	</xsl:function>
	
	<xsl:function name="ep:generate_doc_id" as="text()">
		<xsl:param name="node_id"/>
		<xsl:param name="node_type"/>
		<xsl:value-of select="concat('i', $node_id, $node_type)"/>
	</xsl:function>
	
	<xsl:function name="ep:get_authors_from_modules" as="node()">
		<xsl:param name="context" as="node()*"/>
		<tmp:authors sort="1">
			<xsl:for-each-group select="$context//md:fullname" group-by="text()">
				<tmp:author>
					<xsl:value-of select="current-grouping-key()"/>
				</tmp:author>
			</xsl:for-each-group>
		</tmp:authors>
	</xsl:function>
	
	<xsl:function name="ep:extract_module_ids_from_module_elements" as="xs:string*">
		<xsl:param name="context" as="element()*"/>
		<xsl:for-each select="$context/@document">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:function>
	
	<xsl:function name="ep:generateNewIdWithModuleId" as="xs:string">
		<xsl:param name="old_id"></xsl:param>
		<xsl:param name="module_id"></xsl:param>
		<xsl:choose>
			<xsl:when test="contains($old_id, $module_id)">
				<xsl:value-of select="$old_id"></xsl:value-of>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($module_id, '_', $old_id)"/>
			</xsl:otherwise>
		</xsl:choose>        
	</xsl:function>
	
	<xsl:function name="ep:getVariant" as="xs:string">
		<xsl:param name="ctx"></xsl:param>
		
		<xsl:value-of select="concat($ctx//ep:e-textbook/@ep:recipient, '-canon')"></xsl:value-of>
	</xsl:function>
	
	<xsl:function name="ep:getVariantFromModule" as="xs:string">
		<xsl:param name="ctx"></xsl:param>
		
		<xsl:value-of select="concat($ctx//ep:e-textbook-module/@ep:recipient, '-canon')"></xsl:value-of>
	</xsl:function>

	<xsl:variable name="locales">
		<locale key="month_1">stycznia</locale>
		<locale key="month_2">lutego</locale>
		<locale key="month_3">marca</locale>
		<locale key="month_4">kwietnia</locale>
		<locale key="month_5">maja</locale>
		<locale key="month_6">czerwca</locale>
		<locale key="month_7">lipca</locale>
		<locale key="month_8">sierpnia</locale>
		<locale key="month_9">września</locale>
		<locale key="month_10">października</locale>
		<locale key="month_11">listopada</locale>
		<locale key="month_12">grudnia</locale>

		<locale key="label_description">Opis: </locale>
		<locale key="label_revision_date">Data&#160;wydania: </locale>
		<locale key="label_book_title">Tytuł: </locale>
		<locale key="label_book_subtitle">Podtytuł: </locale>
		<locale key="license_list_title">Lista&#160;licencji</locale>
		<locale key="button_zoom_img">Powiększ</locale>
		<locale key="button_zoom_in_out_img">Powiększ / Pomniejsz</locale>
		<locale key="button_close">Zamknij</locale>
		<locale key="button_show_author_license">Pokaż autora i licencje</locale>
		<locale key="button_hide_author_license">Ukryj autora i licencje</locale>
		<locale key="womi_cover_title">Okładka</locale>
		<locale key="womi_title">Tytuł: </locale>
		<locale key="womi_author">Autor: </locale>
		<locale key="womi_license">Licencja: </locale>
		<locale key="womi_license_additional_info">Dodatkowe informacje o licencji: </locale>
		<locale key="womi_information_undefined">Informacja niezdefiniowana</locale>
		<locale key="label_womi_answers_licenses">Informacje o licencjach osadzonych obiektów w odpowiedziach (w kolejności występowania w treści e-podręcznika)</locale>
		
		<locale key="label_author_of_book_1">Autor podręcznika: </locale>
		<locale key="label_author_of_book_x">Autorzy podręcznika: </locale>
		<locale key="label_education_level_1">Etap edukacyjny: </locale>
		<locale key="label_education_level_x">Etapy edukacyjne: </locale>
		<locale key="label_school_type_1">Typ szkoły: </locale>
		<locale key="label_school_type_x">Typy szkoły: </locale>
		<locale key="label_module_title">Moduł: </locale>
		<locale key="label_module_author_1">Autor: </locale>
		<locale key="label_module_author_x">Autorzy: </locale>
		<locale key="label_module_license">Licencja: </locale>
		<locale key="label_module_contact">Kontakt: </locale>
		<locale key="label_module_www">Wersja WWW: </locale>
		<locale key="label_module_core_curriculum">Hasła podstawy programowej: </locale>
		<locale key="learning_objectives_label">Cele kształcenia - wymagania ogólne: </locale>
		<locale key="text_hpp_outside_ability">Treść spoza podstawy programowej.</locale>
		<locale key="label_about_author_generatedType">Moduł wygenerowany przez platformę</locale>
		
		<locale key="label_second_page_content_status_receipient">Format treści: </locale>
		<locale key="label_second_page_content_status_student">E-podręcznik dla ucznia</locale>
		<locale key="label_second_page_content_status_teacher">E-podręcznik dla nauczyciela</locale>
		
		<locale key="school_type_primary">szkoła podstawowa</locale>
		<locale key="school_type_high">gimnazjum</locale>
		<locale key="school_type_secondary">szkoła ponadgimnazjalna</locale>
		
		<locale key="subject_mathematics">matematyka</locale>
		<locale key="subject_polishLanguage">język polski</locale> 
		<locale key="subject_physics">fizyka</locale> 
		<locale key="subject_chemistry">chemia</locale> 
		<locale key="subject_biology">biologia</locale> 
		<locale key="subject_geography">geografia</locale> 
		<locale key="subject_natureScience">przyroda</locale> 
		<locale key="subject_earlySchoolEducation">edukacja wczesnoszkolna</locale> 
		<locale key="subject_historyAndSociety">historia i społeczeństwo</locale> 
		<locale key="subject_history">historia</locale> 
		<locale key="subject_computerScience">informatyka</locale> 
		<locale key="subject_computerClasses">zajęcia komputerowe</locale> 
		<locale key="subject_civicsEducation">wiedza o społeczeństwie</locale> 
		<locale key="subject_educationForSafety">edukacja dla bezpieczeństwa</locale> 
		
		<locale key="label_mark_tasks">Oznaczenia&#160;zadań: </locale>
		<locale key="mark_taks_table_desc">Tabela zawierająca oznaczenia zadań.</locale>
		<locale key="mark_taks_label_level_min">A</locale>
		<locale key="mark_taks_label_level_general">B</locale>
		<locale key="mark_taks_label_level_creative">C</locale>
		<locale key="mark_taks_label_level_competence">K</locale>
		<locale key="mark_taks_label_exercise_on_paper">Z</locale>
		<locale key="mark_taks_label_exercise_expanding">R</locale>
		<locale key="mark_taks_label_exercise_pairwork">P</locale>
		<locale key="mark_taks_label_exercise_groupwork">G</locale>
		<locale key="mark_taks_desc_level_min"> - zadanie z minimalnego poziomu osiągnięcia efektu kształcenia</locale>
		<locale key="mark_taks_desc_level_general"> - zadanie z ogólnego poziomu osiągnięcia efektu kształcenia</locale>
		<locale key="mark_taks_desc_level_creative"> - zadania z kreatywnego osiągnięcia efektu kształcenia</locale>
		<locale key="mark_taks_desc_level_competence"> - zadanie do osiągnięcia kompetencji</locale>
		<locale key="mark_taks_desc_exercise_on_paper"> - zadanie do wykonania w zeszycie</locale>
		<locale key="mark_taks_desc_exercise_expanding">zadanie na poziomie rozszerzonym</locale>
		<locale key="mark_taks_desc_exercise_pairwork">zadanie do wykonania w parze</locale>
		<locale key="mark_taks_desc_exercise_groupwork">zadanie do wykonania w grupie</locale>
		
		<locale key="label_status_content">Oznaczenia&#160;treści: </locale>
		<locale key="label_signature"> </locale>
		<locale key="label_status_content_table_desc">Tabela zawierająca oznaczenia treści.</locale>
		<locale key="label_content_status_teacher">oprawa metodyczna</locale>
		<locale key="label_content_status_expanding">treści rozszerzające</locale>
		<locale key="shortcut_content_status_teacher"></locale>
		<locale key="shortcut_content_status_expanding"></locale>
		
		<locale key="about_etextbook">O e-podręczniku</locale>
		<locale key="about_description_table">Tabela z informacjami o epodręczniku</locale>
		<locale key="about_learning_objectives_table">Tabela z celami kształcenia - wymagania ogólne</locale>
		<locale key="second_page">Strona tytułowa</locale>
		<locale key="title_second_page">Tytuł strony drugiej</locale>
		<locale key="title_module_second_page">Informacje szczegółowe</locale>
		<locale key="title_module_answers_licenses">Informacje o licencjach osadzonych obiektów (w kolejności występowania w treści modułu):</locale>
		<locale key="answers">Odpowiedzi</locale>
		<locale key="problem">Problem</locale>
		<locale key="solution">Odpowiedź</locale>
		<locale key="commentary">Rozwiązanie</locale>
		<locale key="back_to_exercise">(Wróć&#160;do&#160;zadania)</locale>
		<locale key="student-work">Do&#160;zrobienia</locale>
		<locale key="evaluation">Test&#160;sprawdzający</locale>
		<locale key="homework">Praca&#160;domowa</locale>
		<locale key="project">Projekt</locale>
		<locale key="exercise-set">Zadanie</locale>
		
		<locale key="Footnotes">Przypisy</locale>
		<locale key="Glossary">Glosariusz</locale>
		<locale key="TableofContents">Spis treści</locale>
		<locale key="chapterPrev">Poprzedni rozdział</locale>
		<locale key="chapterNext">Następny rozdział</locale>
		<locale key="fontBigger">Większa czcionka</locale>
		<locale key="fontSmaller">Mniejsza czcionka</locale>
		<locale key="Strength">Siła</locale>
		<locale key="Figure">Figura</locale>
		<locale key="Reference">Referencja</locale>
		<locale key="Listing">Listing</locale>
		<locale key="ShowNoteTip">Pokaż wskazówkę</locale>
		<locale key="HideNoteTip">Ukryj wskazówkę</locale>
		<locale key="aside">Obok</locale>
		<locale key="remember">Zapamiętaj</locale>
		<locale key="Note">Notka</locale>
		<locale key="Remember">Zapamiętaj</locale>
		<locale key="Example">Przykład</locale>
		<locale key="GlossSeeAlso">Zobacz&#160;również</locale>
		<locale key="Citelink">Odsyłacz</locale>
		<locale key="theorem">Twierdzenie:</locale>
		<locale key="lemma">Lemat:</locale>
		<locale key="corollary">Wynik</locale>
		<locale key="law">Prawo:</locale>
		<locale key="property">Własność:</locale>
		<locale key="proposition">Propozycja</locale>
		<locale key="Rule">Reguła:</locale>
		<locale key="Proof">Dowód</locale>
		<locale key="Step">Krok</locale>
		<locale key="Diagnosis">Diagnoza</locale>
		<locale key="Answer">Odpowiedź</locale>
		<locale key="ShowSolution">Pokaż odpowiedź</locale> 
		<locale key="HideSolution">Ukryj odpowiedź</locale>
		<locale key="DifficultyLevel">Poziom trudności</locale>
		<locale key="ProblemSet">Zbiór&#160;zadań</locale>
		<locale key="ShowAnswer">Pokaż odpowiedź</locale> 
		<locale key="HideAnswer">Ukryj odpowiedź</locale>
		<locale key="CheckAnswer">Sprawdź</locale>
		<locale key="Correct">Prawidłowo</locale>
		<locale key="Incorrect">Nieprawidłowo</locale>
		<locale key="Hint">Wskazówka</locale>
		<locale key="NextHint">Następna wskazówka</locale>
		<locale key="Recreate">Nowy przykład</locale>
		<locale key="Truth">Prawda</locale>
		<locale key="False">Fałsz</locale>
		
		<locale key="empty-para-tag">pusty tag para</locale>
		<locale key="empty-code-tag">pusty tag code</locale>
		<locale key="empty-label-element">pusty tag label</locale>
		<locale key="section-header">section-header</locale>
		<locale key="para-header">para-header</locale>
		<locale key="div-header">div-header</locale>
		<locale key="quote-header">quote-header</locale>
		<locale key="code-header">code-header</locale>
		<locale key="note-header">note-header</locale>
		<locale key="note-toggles">note-toggles</locale>
		<locale key="example-header">example-header</locale>
		<locale key="example-contents">example-contents</locale>
		<locale key="rule-header">rule-header</locale>
		<locale key="rule-contents">rule-contents</locale>
		<locale key="statement">statement</locale>
		<locale key="statement-header"> statement-header</locale>
		<locale key="proof-header">proof-header</locale>
		<locale key="list-header">list-header</locale>
		<locale key="equation-header">equation-header</locale>
		<locale key="equation-contents">equation-contents</locale>
		<locale key="exercise-header">exercise-header</locale>
		<locale key="exercise-contents">exercise-contents</locale>
		<locale key="commentary-header">commentary-header</locale>
		<locale key="commentary-contents">commentary-contents</locale>
		<locale key="commentary-toggles">commentary-toggles</locale>
		<locale key="problem-header">problem-header</locale>
		<locale key="problem-contents">problem-contents</locale>
		<locale key="solution-header">solution-header</locale>
		<locale key="solution-contents">solution-contents</locale>
		<locale key="solution-toggles">solution-toggles</locale>
		<locale key="effect-of-education">effect-of-education</locale>
		
		<locale key="table_of_content">Spis treści</locale>
		<locale key="table_of_content_back">Powróć do spisu treści</locale>
		<locale key="chapter">Rozdział</locale>

		<locale key="title_page">Strona tytułowa</locale>		
		<locale key="cover_title">Okładka</locale>
		<locale key="Table">Tabela</locale>
		
		<locale key="lead"></locale>
		<locale key="intro">Przedmiot&#160;lekcji</locale>
		<locale key="prerequisite">Przygotuj&#160;przed&#160;lekcją:</locale>
		<locale key="knowledge">Co&#160;wiem?</locale>
		<locale key="skill">Co&#160;potrafię?</locale>
		<locale key="understanding">Co&#160;rozumiem?</locale>
		<locale key="command">Polecenie</locale>
		<locale key="debate">Debata</locale>
		<locale key="experiment">Doświadczenie</locale>
		<locale key="observation">Obserwacja</locale>
		<locale key="experiment-problem">Problem&#160;badawczy:</locale>
		<locale key="hypothesis">Hipoteza:</locale>
		<locale key="instruments">Co&#160;będzie&#160;potrzebne:</locale>
		<locale key="instructions">Instrukcja:</locale>
		<locale key="conclusions">Podsumowanie:</locale>
		<locale key="demonstration">Demonstracja:</locale>
		<locale key="objective">Cel:</locale>
		<locale key="biography">Biogram</locale>
		<locale key="name">Nazwa</locale>
		<locale key="birth"></locale>
		<locale key="date">Data</locale>
		<locale key="date-birth">Data urodzenia</locale>
		<locale key="date-death">Data śmierci</locale>
		
		<locale key="date-event-start">Data rozpoczęcia</locale>
		<locale key="date-start">Data rozpoczęcia</locale>
		<locale key="date-event-occur">Data</locale>
		<locale key="date-occur">Data</locale>
		<locale key="date-event-end">Data zakończenia</locale>
		<locale key="date-end">Data zakończenia</locale>
		
		<locale key="location">Miejsce</locale>
		<locale key="location-event">Miejsce</locale>
		<locale key="location-birth">Miejsce urodzenia</locale>
		<locale key="location-death">Miejsce śmierci</locale>
		<locale key="location-event-start">Miejsce rozpoczęcia</locale>
		<locale key="location-event-occur">Miejsce</locale>
		<locale key="location-event-end">Miejsce zakończenia</locale>
		<locale key="location-start">Miejsce rozpoczęcia</locale>
		<locale key="location-occur">Miejsce</locale>
		<locale key="location-end">Miejsce zakończenia</locale>
		
		<locale key="death"></locale>
		<locale key="gallery">Galeria</locale>
		<locale key="gallery-legend-title">Opisy&#160;ilustracji: </locale>
		<locale key="glossary">Słowniczek</locale>
		<locale key="entry">Wpis</locale>
		<locale key="content">Treść</locale>
		<locale key="author">Autor</locale>
		<locale key="event">Wydarzenie</locale>
		<locale key="literary-work-summary">Streszczenie</locale>
		<locale key="literary-work-description">O&#160;dziele</locale>
		<locale key="womi-title-label">Obiekt multimedialny</locale>
		<locale key="womi-multimedia-warning">Treść multimedialna - odtwarzanie wymaga połączenia z Internetem.</locale>
		<locale key="womi-attachment-label">Załącznik</locale>
		<locale key="procedure-instructions">Instrukcja</locale>
		<locale key="tooltip">Dymek</locale>
		<locale key="step">Krok</locale>
		<locale key="comment"></locale>
		
		
		<locale key="BC"> p.n.e.</locale>
		<locale key="AD">n.e.</locale>
		<locale key="short-century">w.</locale>
		<locale key="and">i</locale>
		<locale key="beginning-of-century">początek</locale>
		<locale key="end-of-century">koniec</locale>
		<locale key="middle-of-century">połowa</locale>
		<locale key="turn-of-century">przełom</locale>
		<locale key="around-year">ok.</locale>
		
		<locale key="interactive_exercise_title_label">Zadanie interaktywne</locale>
		<locale key="default_image_alt_text">Domyślny obrazek</locale>
		
		<locale key="interactive_exercise_link_label">Aplikacja na epodreczniki.pl</locale>
		<locale key="audio_womi_link_label">Nagranie na epodreczniki.pl</locale>
		<locale key="movie_womi_link_label">Film na epodreczniki.pl</locale>
		<locale key="attachment_womi_link_label">Załącznik na epodreczniki.pl</locale>
		<locale key="gallery_link_label">Pełna galeria  na epodreczniki.pl</locale>
		<locale key="womi-gallery-element-label">Element</locale>
		<locale key="womi-image-label">Ilustracja</locale>
		<locale key="womi-interactive-label">Aplikacja</locale>
		<locale key="womi-movie-label">Nagranie wideo</locale>
		<locale key="womi-sound-label">Nagranie audio</locale>
		
		<locale key="A">A</locale>
		<locale key="B">B</locale>
		<locale key="C">C</locale>
		<locale key="K">K</locale>
		
		<locale key="JPOL3_poziom1"></locale>
		<locale key="JPOL3_poziom2"></locale>
		<locale key="JPOL3_simple">Zadanie</locale>
		<locale key="JPOL3_pairs">Praca w parach</locale>
		<locale key="JPOL3_play">Zabawa / gra</locale>
		<locale key="JPOL3_sorceress">Czarownica</locale>
		<locale key="JPOL3_imp">Chochlik</locale>
		<locale key="JPOL3_reading">Czytanie&#160;ze&#160;zrozumieniem</locale>
		<locale key="JPOL3_challenge">Wyzwanie</locale>
		<locale key="JPOL3_interactive">Ćwiczenie&#160;interaktywne</locale>
		
		<locale key="textarea_text_static_format">Odpowiedź zapisz w zeszycie.</locale>
		<locale key="no-correct-answer">Żadna z odpowiedzi nie jest poprawna.</locale>
		<locale key="Bibliography">Bibliografia</locale>
		<locale key="no-alternative-reason">Element niedostępny: </locale>
		
		<locale key="bib-text-available-in-the-internet">dostępne w Internecie: </locale>
		<locale key="bib-shortcut-t-dot">T. </locale>
		<locale key="bib-shortcut-no-dot">nr </locale>
		<locale key="bib-shortcut-page-dot">s. </locale>
		<locale key="bib-shortcut-translate-dot">[przeł.] </locale>
		<locale key="bib-shortcut-redaction-dot">[red.] </locale>
		<locale key="bib-text-available">dostęp: </locale>
		<locale key="bib-text-online"> [online]</locale>
		<locale key="bib-text-from-day">z dnia </locale> 
		<locale key="bib-text-in">w: </locale> 
		<locale key="bib-year-dot">r. </locale> 
		
		<locale key="label_adult_supervision"> [DO WYKONANIA POD NADZOREM OSOBY DOROSŁEJ]</locale>
		
		<locale key="label-go-to-glossary-bibliography">Przejdź do bibliografii</locale>
		<locale key="label-go-to-glossary-biography">Przejdź do słownika</locale>
		<locale key="label-go-to-glossary-event">Przejdź do słownika</locale>
		<locale key="label-go-to-glossary-glossary">Przejdź do słownika</locale>
		<locale key="label-go-to-glossary-concept">Przejdź do słownika</locale>
		<locale key="go-back-from-glossary">Przejdź do źródła</locale>
		
		<locale key="stretch-full-width">full-width</locale>
		<locale key="stretch-extended-width">extended-width</locale>
		<locale key="stretch-extended-shifted-width">extended-shifted-width</locale>
		
		<locale key="label_source">Źródło: </locale>
		
		<locale key="pair-work">Ćwiczenie</locale>
		<locale key="groupwork">Ćwiczenie</locale>
		<locale key="class">klasa</locale>
		
		<locale key="label-expand">więcej...</locale>
		<locale key="label-collapse">zwiń...</locale>
		
		<locale key="label-subject">Przedmiot: </locale>
		<locale key="label-subjects">Przedmioty: </locale>
		
		<xsl:choose>
			<xsl:when test="some $x in ('biologia', 'chemia', 'edukacja dla bezpieczeństwa', 'geografia', 'przyroda') satisfies contains($subject,$x)">
				<xsl:choose>
					<xsl:when test="some $x in ('wpisz tu etapy edukacyjne') satisfies $subject=$x"></xsl:when>
					<xsl:otherwise>
						<locale key="exercise">Ćwiczenie</locale>
						<locale key="Exercise">Ćwiczenie</locale>
						<locale key="SubExercise">Podzadanie</locale>
						<locale key="WOMI">Zadanie</locale>
						<locale key="ShowCommentary">Pokaż wyjaśnienie</locale>
						<locale key="HideCommentary">Ukryj wyjaśnienie</locale>
						<locale key="ShowCommentaryExample">Pokaż przykład wyjaśnienia</locale>
						<locale key="HideCommentaryExample">Ukryj przykład wyjaśnienia</locale>
						<locale key="revisal">Już&#160;wiesz:</locale>
						<locale key="effect">Nauczysz&#160;się:</locale>
						<locale key="to-be-read">Do&#160;przeczytania</locale>
						<locale key="Definition">Definicja</locale>
						<locale key="curiosity">Ciekawostka</locale>
						<locale key="good-to-know">Warto&#160;wiedzieć</locale>
						<locale key="tip">Wskazówka</locale>
						<locale key="warning">Uwaga</locale>
						<locale key="important">Ważne</locale>
						<locale key="consider">Zastanów&#160;się</locale>
						<locale key="see-also">Zobacz&#160;także</locale>
						<locale key="gen_bibliography">Bibliografia</locale>
						<locale key="gen_biography">Biogramy</locale>
						<locale key="gen_event">Wydarzenia</locale>
						<locale key="gen_glossary">Słowniczek</locale>
						<locale key="gen_concept">Pojęcia</locale>
						<locale key="short-year"> r.</locale>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="some $x in ('fizyka') satisfies contains($subject,$x)">
				<xsl:choose>
					<xsl:when test="some $x in ('wpisz tu etapy edukacyjne') satisfies $subject=$x"></xsl:when>
					<xsl:otherwise>
						<locale key="exercise">Ćwiczenie</locale>
						<locale key="Exercise">Ćwiczenie</locale>
						<locale key="SubExercise">Podzadanie</locale>
						<locale key="WOMI">Zadanie</locale>
						<locale key="ShowCommentary">Pokaż wyjaśnienie</locale>
						<locale key="HideCommentary">Ukryj wyjaśnienie</locale>
						<locale key="ShowCommentaryExample">Pokaż przykład wyjaśnienia</locale>
						<locale key="HideCommentaryExample">Ukryj przykład wyjaśnienia</locale>
						<locale key="revisal">Już&#160;potrafisz:</locale>
						<locale key="effect">Nauczysz&#160;się:</locale>
						<locale key="to-be-read">Do&#160;przeczytania</locale>
						<locale key="Definition">Definicja</locale>
						<locale key="curiosity">Ciekawostka</locale>
						<locale key="good-to-know">Warto&#160;wiedzieć</locale>
						<locale key="tip">Wskazówka</locale>
						<locale key="warning">Uwaga</locale>
						<locale key="important">Ważne</locale>
						<locale key="consider">Zastanów&#160;się</locale>
						<locale key="see-also">Zobacz&#160;także</locale>
						<locale key="gen_bibliography">Bibliografia</locale>
						<locale key="gen_biography">Biogramy</locale>
						<locale key="gen_event">Wydarzenia</locale>
						<locale key="gen_glossary">Definicje</locale>
						<locale key="gen_concept">Pojęcia</locale>
						<locale key="short-year"> r.</locale>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="some $x in ('język polski', 'wiedza o społeczeństwie') satisfies contains($subject,$x)">
				<xsl:choose>
					<xsl:when test="some $x in ('wpisz tu etapy edukacyjne') satisfies $subject=$x"></xsl:when>
					<xsl:otherwise>
						<locale key="exercise">Ćwiczenie</locale>
						<locale key="Exercise">Ćwiczenie</locale>
						<locale key="SubExercise">Ćwiczenie</locale>
						<locale key="WOMI">Ćwiczenie</locale>
						<locale key="ShowCommentary">Pokaż rozwiązanie</locale>
						<locale key="HideCommentary">Ukryj rozwiązanie</locale>
						<locale key="ShowCommentaryExample">Pokaż przykład rozwiązania</locale>
						<locale key="HideCommentaryExample">Ukryj przykład rozwiązania</locale>
						<locale key="revisal">Przed&#160;lekcją</locale>
						<locale key="effect">Nauczysz&#160;się</locale>
						<locale key="to-be-read">Do&#160;przeczytania</locale>
						<locale key="Definition">Definicja</locale>
						<locale key="curiosity">Ciekawostka</locale>
						<locale key="good-to-know">Warto&#160;wiedzieć</locale>
						<locale key="tip">Wskazówka</locale>
						<locale key="warning">Uwaga</locale>
						<locale key="important">Ważne</locale>
						<locale key="consider">Zastanów&#160;się</locale>
						<locale key="see-also">Zobacz&#160;także</locale>
						<locale key="for-interested">Dla&#160;zainteresowanych</locale>
						<locale key="time-capsule">Kapsuła&#160;czasu</locale>
						<locale key="gen_bibliography">Bibliografia</locale>
						<locale key="gen_biography">Biogramy</locale>
						<locale key="gen_event">Wydarzenia</locale>
						<locale key="gen_glossary">Słowniczek</locale>
						<locale key="gen_concept">Pojęcia</locale>
						<locale key="short-year"></locale>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="some $x in ('historia', 'historia i społeczeństwo') satisfies contains($subject,$x)">
				<xsl:choose>
					<xsl:when test="some $x in ('wpisz tu etapy edukacyjne') satisfies $subject=$x"></xsl:when>
					<xsl:otherwise>
						<locale key="exercise">Ćwiczenie</locale>
						<locale key="Exercise">Ćwiczenie</locale>
						<locale key="SubExercise">Ćwiczenie</locale>
						<locale key="WOMI">Ćwiczenie</locale>
						<locale key="ShowCommentary">Pokaż rozwiązanie</locale>
						<locale key="HideCommentary">Ukryj rozwiązanie</locale>
						<locale key="ShowCommentaryExample">Pokaż przykład rozwiązania</locale>
						<locale key="HideCommentaryExample">Ukryj przykład rozwiązania</locale>
						<locale key="revisal">Przed&#160;lekcją</locale>
						<locale key="effect">Nauczysz&#160;się</locale>
						<locale key="to-be-read">Tekst&#160;źródłowy</locale>
						<locale key="Definition">Definicja</locale>
						<locale key="curiosity">Ciekawostka</locale>
						<locale key="good-to-know">Warto&#160;wiedzieć</locale>
						<locale key="tip">Wskazówka</locale>
						<locale key="warning">Uwaga</locale>
						<locale key="important">Ważne</locale>
						<locale key="consider">Zastanów&#160;się</locale>
						<locale key="see-also">Zobacz&#160;także</locale>
						<locale key="for-interested">Dla&#160;zainteresowanych</locale>
						<locale key="time-capsule">Kapsuła&#160;czasu</locale>
						<locale key="gen_bibliography">Bibliografia</locale>
						<locale key="gen_biography">Biogramy</locale>
						<locale key="gen_event">Wydarzenia</locale>
						<locale key="gen_glossary">Słowniczek</locale>
						<locale key="gen_concept">Pojęcia</locale>
						<locale key="short-year"></locale>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="some $x in ('matematyka') satisfies contains($subject,$x)">
				<xsl:choose>
					<xsl:when test="some $x in ('wpisz tu etapy edukacyjne') satisfies $subject=$x"></xsl:when>
					<xsl:otherwise>
						<locale key="exercise">Zadanie</locale>
						<locale key="Exercise">Zadanie</locale>
						<locale key="SubExercise">Podzadanie</locale>
						<locale key="WOMI">Zadanie</locale>
						<locale key="ShowCommentary">Pokaż rozwiązanie</locale>
						<locale key="HideCommentary">Ukryj rozwiązanie</locale>
						<locale key="ShowCommentaryExample">Pokaż przykład rozwiązania</locale>
						<locale key="HideCommentaryExample">Ukryj przykład rozwiązania</locale>
						<locale key="revisal">Już&#160;wiesz:</locale>
						<locale key="effect">Tego&#160;się&#160;nauczysz:</locale>
						<locale key="to-be-read">Do&#160;przeczytania</locale>
						<locale key="Definition">Definicja</locale>
						<locale key="curiosity">Ciekawostka</locale>
						<locale key="good-to-know">Warto&#160;wiedzieć</locale>
						<locale key="tip">Wskazówka</locale>
						<locale key="warning">Uwaga</locale>
						<locale key="important">Ważne</locale>
						<locale key="consider">Zastanów&#160;się</locale>
						<locale key="see-also">Zobacz&#160;także</locale>
						<locale key="gen_bibliography">Bibliografia</locale>
						<locale key="gen_biography">Biogramy</locale>
						<locale key="gen_event">Wydarzenia</locale>
						<locale key="gen_glossary">Słowniczek</locale>
						<locale key="gen_concept">Pojęcia</locale>
						<locale key="short-year"> r.</locale>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="some $x in ('informatyka', 'zajęcia komputerowe') satisfies contains($subject,$x)">
				<xsl:choose>
					<xsl:when test="some $x in ('wpisz tu etapy edukacyjne') satisfies $subject=$x"></xsl:when>
					<xsl:otherwise>
						<locale key="exercise">Zadanie</locale>
						<locale key="Exercise">Zadanie</locale>
						<locale key="SubExercise">Podzadanie</locale>
						<locale key="WOMI">Zadanie</locale>
						<locale key="ShowCommentary">Pokaż rozwiązanie</locale>
						<locale key="HideCommentary">Ukryj rozwiązanie</locale>
						<locale key="ShowCommentaryExample">Pokaż przykład rozwiązania</locale>
						<locale key="HideCommentaryExample">Ukryj przykład rozwiązania</locale>
						<locale key="revisal">Już&#160;umiesz:</locale>
						<locale key="effect">Nauczysz&#160;się:</locale>
						<locale key="to-be-read">Do&#160;przeczytania</locale>
						<locale key="Definition">Definicja</locale>
						<locale key="curiosity">Ciekawostka</locale>
						<locale key="good-to-know">Warto&#160;wiedzieć</locale>
						<locale key="tip">Wskazówka</locale>
						<locale key="warning">Uwaga</locale>
						<locale key="important">Ważne</locale>
						<locale key="consider">Zastanów&#160;się</locale>
						<locale key="see-also">Zobacz&#160;także</locale>
						<locale key="gen_bibliography">Bibliografia</locale>
						<locale key="gen_biography">Biogramy</locale>
						<locale key="gen_event">Wydarzenia</locale>
						<locale key="gen_glossary">Słowniczek</locale>
						<locale key="gen_concept">Pojęcia</locale>
						<locale key="short-year"> r.</locale>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="some $x in ('wpisz tu etapy edukacyjne') satisfies $subject=$x"></xsl:when>
					<xsl:otherwise>
						<locale key="exercise">Zadanie</locale>
						<locale key="Exercise">Zadanie</locale>
						<locale key="SubExercise">Podzadanie</locale>
						<locale key="WOMI">Zadanie</locale>
						<locale key="ShowCommentary">Pokaż rozwiązanie</locale>
						<locale key="HideCommentary">Ukryj rozwiązanie</locale>
						<locale key="ShowCommentaryExample">Pokaż przykład rozwiązania</locale>
						<locale key="HideCommentaryExample">Ukryj przykład rozwiązania</locale>
						<locale key="revisal">Już&#160;wiesz:</locale>
						<locale key="effect">Tego&#160;się&#160;nauczysz:</locale>
						<locale key="to-be-read">Do&#160;przeczytania</locale>
						<locale key="Definition">Definicja</locale>
						<locale key="curiosity">Ciekawostka</locale>
						<locale key="good-to-know">Warto&#160;wiedzieć</locale>
						<locale key="tip">Wskazówka</locale>
						<locale key="warning">Uwaga</locale>
						<locale key="important">Ważne</locale>
						<locale key="consider">Zastanów&#160;się</locale>
						<locale key="see-also">Zobacz&#160;także</locale>
						<locale key="for-interested">Dla&#160;zainteresowanych</locale>
						<locale key="time-capsule">Kapsuła&#160;czasu</locale>
						<locale key="gen_bibliography">Bibliografia</locale>
						<locale key="gen_biography">Biogramy</locale>
						<locale key="gen_event">Wydarzenia</locale>
						<locale key="gen_glossary">Słowniczek</locale>
						<locale key="gen_concept">Pojęcia</locale>
						<locale key="short-year"> r.</locale>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="glossaryModule">
		<xsl:variable name="key">
			<xsl:for-each select="col:collection/col:metadata/md:subjectlist/md:subject">
				<xsl:value-of select="."/>
				<xsl:text>;</xsl:text>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="some $x in ('biologia', 'chemia', 'edukacja dla bezpieczeństwa', 'geografia', 'przyroda') satisfies contains($key,$x)">
				<element key="bibliography">glossary</element>
				<element key="biography">glossary</element>
				<element key="event">glossary</element>
				<element key="glossary">glossary</element>
				<element key="concept">glossary</element>
			</xsl:when>
			<xsl:when test="some $x in ('fizyka') satisfies contains($key,$x)">
				<element key="bibliography">bibliography</element>
				<element key="biography">biography</element>
				<element key="event">biography</element>
				<element key="glossary">glossary</element>
				<element key="concept">concept</element>
			</xsl:when>
			<xsl:otherwise>
				<element key="bibliography">bibliography</element>
				<element key="biography">biography</element>
				<element key="event">event</element>
				<element key="glossary">glossary</element>
				<element key="concept">concept</element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


	<xsl:function name="ep:get_qml_answer_prefix_for_qml">
		<xsl:param name="qml" as="node()"/>
		<xsl:param name="id" as="xs:string"/>
		<xsl:if test="$qml//q:answer[@id=$id]">
			<xsl:value-of select="ep:get_qml_answer_prefix_for_number(count($qml//q:answer[@id=$id]/preceding-sibling::q:answer)+1)"/>				
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="ep:get_qml_answer_prefix_for_number" as="xs:string">
		<xsl:param name="number" as="xs:integer"/>
		<xsl:value-of select="concat(fn:substring($qml_answer_alphabet, $number, 1), ')')"/>
	</xsl:function>
	
	<xsl:variable name="qml_answer_alphabet">abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

	<xsl:function name="ep:shuffle_qml_answers" as="node()">
		<xsl:param name="qml" as="node()"/>
		<xsl:variable name="answer_count" select="count($qml/q:answer)"/>
		<xsl:for-each select="$qml">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:copy-of select="./q:answer[1]/preceding-sibling::node()" />
				<xsl:copy-of select="ep:shuffle(fn:reverse(./q:answer), ep:random_get_next(count(preceding::node())), 1)"/>
				<xsl:copy-of select="./q:answer[$answer_count]/following-sibling::node()" />
			</xsl:copy>
		</xsl:for-each>
	</xsl:function>
	
	<xsl:function name="ep:shuffle" as="node()*">
		<xsl:param name="list" as="node()*"/>
		<xsl:param name="seed" as="xs:integer"/>
		<xsl:param name="next" as="xs:integer" />
		<xsl:variable name="limit" select="count($list) * count($list)"/>
		<xsl:if test="$next &lt; $limit">
			<xsl:variable name="list2" select="ep:randomly_swap($list, $seed, $next)"/>
			<xsl:copy-of select="ep:shuffle($list2, $seed, $next+2)"/>
		</xsl:if>
		<xsl:if test="$next &gt;= $limit">
			<xsl:copy-of select="$list"/>
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="ep:randomly_swap" as="node()*">
		<xsl:param name="list" as="node()*"/>
		<xsl:param name="seed" as="xs:integer"/>
		<xsl:param name="next" as="xs:integer"/>
		<xsl:variable name="a" select="ep:random($seed, $next) mod count($list) + 1"/>
		<xsl:variable name="b" select="ep:random($seed, $next+1) mod count($list) + 1"/>
		<xsl:for-each select="$list">
			<xsl:if test="position()=$a">
				<xsl:copy-of select="$list[$b]"/>
			</xsl:if>
			<xsl:if test="position()=$b and $b!=$a">
				
				<xsl:copy-of select="$list[$a]"/>
			</xsl:if>
			<xsl:if test="position()!=$a and position()!=$b">
				<xsl:copy-of select="."/>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
    
    <xsl:function name="ep:random" as="xs:integer">
		<xsl:param name="given_seed" as="xs:integer"/>
		<xsl:param name="next" as="xs:integer"/>
		<xsl:variable name="seed" as="xs:integer" select="1"/>
		<xsl:value-of select="ep:random_next($seed, $next, 1)"/>
    </xsl:function>
    
   <xsl:function name="ep:random_next" as="xs:integer">
		<xsl:param name="seed" as="xs:integer"/>
		<xsl:param name="next" as="xs:integer"/>
		<xsl:param name="step" as="xs:integer"/>
		<xsl:if test="$step &gt;= $next">
			<xsl:value-of select="ep:random_get_next($seed)"/>
		</xsl:if>
		<xsl:if test="$step &lt; $next">
			<xsl:value-of select="ep:random_next(ep:random_get_next($seed), $next, $step+1)"/>
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="ep:random_get_next" as="xs:integer">
		<xsl:param name="seed" as="xs:integer"/>
		<xsl:value-of select="($seed*25173+13849) mod 65536"/>
	</xsl:function>
	
	<xsl:function name="ep:get_date" as="xs:string*">
		<xsl:param name="date" as="node()"/>
		<xsl:if test="$date/ep:start">
			<xsl:if test="$date/ep:start/ep:day">
				<xsl:value-of select="concat($date/ep:start/ep:day, '.')"/>
			</xsl:if>
			<xsl:if test="$date/ep:start/ep:month">
				<xsl:value-of select="concat($date/ep:start/ep:month, '.')"/>
			</xsl:if>
			<xsl:if test="$date/ep:start/ep:year">
				<xsl:value-of select="$date/ep:start/ep:year"/>
			</xsl:if>
			<xsl:if test="number($date/ep:start/ep:year) &lt; 0">
				<xsl:value-of select="-number($date/ep:start/ep:year)"/>
				<xsl:value-of select="$locales/locale[@key='BC']"/>
			</xsl:if>
			<xsl:if test="number($date/ep:start/ep:year) &gt; 0">
				<xsl:value-of select="number($date/ep:start/ep:year)"/>
			</xsl:if>
		</xsl:if>
		<xsl:if test="$date/ep:start and ($date/ep:end and $date/ep:end/ep:year != 0)"><xsl:text> — </xsl:text></xsl:if>
		<xsl:if test="$date/ep:end and $date/ep:end/ep:year != 0">
			<xsl:if test="$date/ep:end/ep:day">
				<xsl:value-of select="concat($date/ep:end/ep:day, '.')"/>
			</xsl:if>
			<xsl:if test="$date/ep:end/ep:month">
				<xsl:value-of select="concat($date/ep:end/ep:month, '.')"/>
			</xsl:if>
			<xsl:if test="number($date/ep:end/ep:year) &lt; 0">
				<xsl:value-of select="-number($date/ep:end/ep:year)"/>
				<xsl:value-of select="$locales/locale[@key='BC']"/>
			</xsl:if>
			<xsl:if test="number($date/ep:end/ep:year) &gt; 0">
				<xsl:value-of select="number($date/ep:end/ep:year)"/>
			</xsl:if>
		</xsl:if>
		
		<xsl:if test="$date/ep:date-start">
			<xsl:if test="$date/ep:date-start/ep:day">
				<xsl:value-of select="concat($date/ep:date-start/ep:day, '.')"/>
			</xsl:if>
			<xsl:if test="$date/ep:date-start/ep:month">
				<xsl:value-of select="concat($date/ep:date-start/ep:month, '.')"/>
			</xsl:if>
			<xsl:if test="number($date/ep:date-start/ep:year) &lt; 0">
				<xsl:value-of select="-number($date/ep:date-start/ep:year)"/>
				<xsl:value-of select="$locales/locale[@key='BC']"/>
			</xsl:if>
			<xsl:if test="number($date/ep:date-start/ep:year) &gt; 0">
				<xsl:value-of select="number($date/ep:date-start/ep:year)"/>
			</xsl:if>
		</xsl:if>
		<xsl:if test="$date/ep:date-start and $date/ep:date-end and $date/ep:date-end != '0' and $date/ep:end/ep:year != 0"><xsl:text> — </xsl:text></xsl:if>
		<xsl:if test="$date/ep:date-end and $date/ep:date-end != '0' and $date/ep:end/ep:year != 0">
			<xsl:if test="$date/ep:date-end/ep:day">
				<xsl:value-of select="concat($date/ep:date-end/ep:day, '.')"/>
			</xsl:if>
			<xsl:if test="$date/ep:date-end/ep:month">
				<xsl:value-of select="concat($date/ep:date-end/ep:month, '.')"/>
			</xsl:if>
			<xsl:if test="number($date/ep:date-end/ep:year) &lt; 0">
				<xsl:value-of select="-number($date/ep:date-end/ep:year)"/>
				<xsl:value-of select="$locales/locale[@key='BC']"/>
			</xsl:if>
			<xsl:if test="number($date/ep:date-end/ep:year) &gt; 0">
				<xsl:value-of select="number($date/ep:date-end/ep:year)"/>
			</xsl:if>
		</xsl:if>
		

		
	</xsl:function>
	
	<xsl:function name="ep:get_year" as="xs:string">
		<xsl:param name="date" as="node()"/>
		<xsl:variable name="start-year">
			<xsl:if test="$date/ep:start">
				<xsl:copy-of select="number($date/ep:start/ep:year)"></xsl:copy-of>
			</xsl:if>
			<xsl:if test="$date/ep:date-start">
				<xsl:copy-of select="number($date/ep:date-start/ep:year)"></xsl:copy-of>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="output">
			<xsl:if test="$date/@ep:type='around-year'">
				<xsl:value-of select="$locales/locale[@key='around-year']"/>
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$start-year > 0">
					<xsl:value-of select="$start-year"/>
					<xsl:value-of select="$locales/locale[@key='short-year']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="-($start-year)"/>
					<xsl:value-of select="$locales/locale[@key='short-year']"/>
					<xsl:value-of select="$locales/locale[@key='BC']"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$output"></xsl:value-of>
	</xsl:function>
	
	<xsl:function name="ep:get_date_from_epoch" as="xs:string">
		<xsl:param name="date" as="node()"/>
		<xsl:if test="$date/ep:start">
			<xsl:value-of select="format-date(
				$date/ep:start/ep:year,
				'[Y0001][M01][D01][H01][M01][S01]')"/>
		</xsl:if>
		<xsl:if test="$date/ep:start and $date/ep:end"><xsl:text>-</xsl:text></xsl:if>
		<xsl:if test="$date/ep:end">
			<xsl:value-of select="format-date(
				$date/ep:end/ep:year,
				'[Y0001][M01][D01][H01][M01][S01]')"/>
			
		</xsl:if>
		
		<xsl:if test="$date/ep:date-start">
			<xsl:value-of select="format-date(
				$date/ep:date-start/ep:year,
				'[Y0001][M01][D01][H01][M01][S01]')"/>
		</xsl:if>
		<xsl:if test="$date/ep:date-start and $date/ep:date-end and $date/ep:date-end != '0'"><xsl:text>-</xsl:text></xsl:if>
		<xsl:if test="$date/ep:date-end and $date/ep:date-end != '0'">
			<xsl:value-of select="format-date(
				$date/ep:date-end/ep:year,
				'[Y0001][M01][D01][H01][M01][S01]')"/>
			
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="ep:get_century" as="xs:string">
		<xsl:param name="date" as="node()"/>
		<xsl:variable name="type" select="$date/@ep:type"/>
		<xsl:variable name="start-year">
			<xsl:if test="$date/ep:start">
				<xsl:copy-of select="number($date/ep:start/ep:year)"></xsl:copy-of>
			</xsl:if>
			<xsl:if test="$date/ep:date-start">
				<xsl:copy-of select="number($date/ep:date-start/ep:year)"></xsl:copy-of>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="century">
			<xsl:choose>
				<xsl:when test="$start-year > 0">
					<xsl:variable name="year" select="$start-year -1"></xsl:variable>
					<xsl:variable name="century" select="($year - ($year  mod 100)) div 100 + 1"></xsl:variable>
					<xsl:choose>
						<xsl:when test="$type='beginning-of-century'">
							<xsl:value-of select="$locales/locale[@key='beginning-of-century']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='AD']"/>
						</xsl:when>
						<xsl:when test="$type='end-of-century'">
							<xsl:value-of select="$locales/locale[@key='end-of-century']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='AD']"/>
						</xsl:when>
						<xsl:when test="$type='middle-of-century'">
							<xsl:value-of select="$locales/locale[@key='middle-of-century']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='AD']"/>
						</xsl:when>
						<xsl:when test="$type='turn-of-century'">
							<xsl:value-of select="$locales/locale[@key='turn-of-century']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='and']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century+1" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='AD']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='AD']"/>
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="year" select="$start-year +1"></xsl:variable>
					<xsl:variable name="century" select="((-$year) - ((-$year) mod 100)) div 100 + 1"></xsl:variable>
					<xsl:choose>
						<xsl:when test="$type='beginning-of-century'">
							<xsl:value-of select="$locales/locale[@key='beginning-of-century']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:value-of select="$locales/locale[@key='BC']"/>
						</xsl:when>
						<xsl:when test="$type='end-of-century'">
							<xsl:value-of select="$locales/locale[@key='end-of-century']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:value-of select="$locales/locale[@key='BC']"/>
						</xsl:when>
						<xsl:when test="$type='middle-of-century'">
							<xsl:value-of select="$locales/locale[@key='middle-of-century']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:value-of select="$locales/locale[@key='BC']"/>
						</xsl:when>
						<xsl:when test="$type='turn-of-century'">
							<xsl:value-of select="$locales/locale[@key='turn-of-century']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='and']"/>
							<xsl:text> </xsl:text>
							<xsl:number value="$century+1" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:value-of select="$locales/locale[@key='BC']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:number value="$century" format="I"></xsl:number>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$locales/locale[@key='short-century']"/>
							<xsl:value-of select="$locales/locale[@key='BC']"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$century"></xsl:value-of>
	</xsl:function>
	
	<xsl:function name="ep:get_date_word_month" as="xs:string">
		<xsl:param name="date" as="node()"/>
		<xsl:analyze-string select="$date" regex="([0-9]{{1,2}})/([0-9]{{1,2}})/([0-9]{{4}})">
			<xsl:matching-substring>
				<xsl:value-of select="concat(regex-group(1), ' ', tokenize($months, ',')[number(regex-group(2))], ' ', regex-group(3))"/>          
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:message terminate="yes">[XSLT_ERR] Problem with date format: <xsl:value-of select="$date"/></xsl:message>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:function>
	
	<xsl:function name="ep:get_associated_exercise_type_count" as="xs:integer">
		<xsl:param name="exercise" as="node()"/>
		<xsl:param name="module_id" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="some $x in ('biologia', 'chemia', 'edukacja dla bezpieczeństwa', 'geografia', 'przyroda', 'fizyka') satisfies contains($subject,$x)">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="some $x in ('język polski', 'polish') satisfies contains($subject,$x)">
				<xsl:choose>
					<xsl:when test="$exercise[not(@type)] ">
						<xsl:value-of select="count($exercise/preceding::cn:exercise[@type='WOMI' and ancestor::cn:document[@id=$module_id]])"/>
					</xsl:when>
					<xsl:when test="$exercise/@type = 'WOMI'">
						<xsl:value-of select="count($exercise/preceding::cn:exercise[not(@type) and ancestor::cn:document[@id=$module_id]])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="some $x in ('historia', 'historia i społeczeństwo') satisfies contains($subject,$x)">
				<xsl:choose>
					<xsl:when test="$exercise[not(@type)] ">
						<xsl:value-of select="count($exercise/preceding::cn:exercise[@type='WOMI' and ancestor::cn:document[@id=$module_id]])"/>
					</xsl:when>
					<xsl:when test="$exercise/@type = 'WOMI'">
						<xsl:value-of select="count($exercise/preceding::cn:exercise[not(@type) and ancestor::cn:document[@id=$module_id]])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="some $x in ('matematyka') satisfies contains($subject,$x)">
				<xsl:choose>
					<xsl:when test="$exercise[not(@type)] ">
						<xsl:value-of select="count($exercise/preceding::cn:exercise[@type='WOMI' and ancestor::cn:document[@id=$module_id]])"/>
					</xsl:when>
					<xsl:when test="$exercise/@type = 'WOMI'">
						<xsl:value-of select="count($exercise/preceding::cn:exercise[not(@type) and ancestor::cn:document[@id=$module_id]])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$exercise[not(@type)] ">
						<xsl:value-of select="count($exercise/preceding::cn:exercise[@type='WOMI' and ancestor::cn:document[@id=$module_id]])"/>
					</xsl:when>
					<xsl:when test="$exercise/@type = 'WOMI'">
						<xsl:value-of select="count($exercise/preceding::cn:exercise[not(@type) and ancestor::cn:document[@id=$module_id]])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ep:get_prev_modules_exercise_count" as="xs:integer">
		<xsl:param name="moduleId" as="xs:string"/>
		<xsl:param name="exerciseType" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="some $x in ('biologia', 'chemia', 'edukacja dla bezpieczeństwa', 'geografia', 'przyroda', 'fizyka') satisfies contains($subject,$x)">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="some $x in ('język polski') satisfies contains($subject,$x)">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="some $x in ('historia', 'historia i społeczeństwo') satisfies contains($subject,$x)">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="some $x in ('matematyka') satisfies contains($subject,$x)">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ep:get_number_prefix" as="xs:string">
		<xsl:param name="moduleId" as="xs:string"/>
		<xsl:variable name="module" select="$coll//col:module[@document=$moduleId]"/>
		<xsl:choose>
			<xsl:when test="$module/@ep:numbering">
				<xsl:text></xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$module" mode="numbering">
					<xsl:with-param name="modifier" select="0" tunnel="yes"></xsl:with-param>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ep:get_number_prefix_for_answers" as="xs:string">
		<xsl:param name="module" as="node()"/>
		<xsl:choose>
			<xsl:when test="$module/@ep:numbering">
				<xsl:text></xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$module" mode="numbering"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:template match="col:*" mode="numbering">
		<xsl:param name="part"></xsl:param>
		<xsl:variable name="count" select="count(preceding-sibling::col:module[not(@toc) and not(@ep:numbering)]|preceding-sibling::col:subcollection[not(@toc) and not(@ep:numbering)])+1"></xsl:variable>
		<xsl:if test="not(exists(ancestor::col:subcollection[1]))">			
			<xsl:choose>
				<xsl:when test="$part != '' and ./md:title">
					<xsl:value-of select="concat($count, '.', $part)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($count, '.')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:variable name="newpart">
			<xsl:choose>
				<xsl:when test="$part = ''"><xsl:value-of select="concat($count, '.')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="concat($count, '.', $part)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:apply-templates select="ancestor::col:subcollection[1]" mode="numbering">
			<xsl:with-param name="part" select="$newpart"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:function name="ep:show_technical_remarks" as="xs:string">
		<xsl:variable name="str" select="$coll//ep:show-technical-remarks"></xsl:variable>
		<xsl:choose>
			<xsl:when test="$str != 'false' or empty($str)">
				<xsl:value-of select="'true'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ep:getMappingGlossaryModuleIdByType" as="text()">
		<xsl:param name="genType"/>
		<xsl:variable name="filepath" select="concat($path_to_files_epxml_of_modules_in_col, '/mappingGlossary.xml')"></xsl:variable>
		<xsl:choose>
			<xsl:when test="doc-available($filepath)">
				<xsl:value-of select="document($filepath)/*:glossaryMapping/*:item[@type=$genType]/@module_id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>[XSLT_ERR] Missing a required file: mappingGlossary.xml</xsl:text>
				</xsl:message>
				<xsl:text>-1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ep:getDocumentContent">
		<xsl:param name="docPath"/>
		<xsl:choose>
			<xsl:when test="not(doc-available($docPath))">
				<xsl:message terminate="yes">
					<xsl:text>[XSLT_ERR] Missing a required file: '</xsl:text>
					<xsl:value-of select="$docPath"/>
					<xsl:text>' </xsl:text>
				</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="document($docPath)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
		
	<xsl:variable name="womiExerciseEngineTypeMap" as="element()+">
		<item type="ZJ-1" name=" (jednokrotnego wyboru)"/>
		<item type="ZW-1" name=" (wielokrotnego wyboru)"/>
		<item type="ZW-2" name=" (wielokrotnego wyboru prawda / fałsz)"/>
		<item type="UT-1" name=" (uzupełnij tekst)"/>
		<item type="UT-2" name=" (uzupełnij tekst)"/>
		<item type="DGT-1" name=" (przeciągnij i upuść)"/>
		<item type="DGL-1" name=" (przeciągnij i upuść)"/>
		<item type="DGD-1" name=" (przeciągnij i upuść)"/>
		<item type="DGU-1" name=" (przeciągnij i upuść)"/>
		<item type="DGS-1" name=" (przeciągnij i upuść)"/>
		<item type="DGS-2" name=" (przeciągnij i upuść)"/>
		<item type="CW-1" name=" krzyżówka"/>
		<item type="MEM-1" name=" memory"/>
		<item type="TMW-1" name=" tabela macierz wielokrotnego wyboru"/>
	</xsl:variable>
	
	<xsl:function name="ep:getwomiExerciseEngineByType" as="xs:string">
		<xsl:param name="type"></xsl:param>
		<xsl:value-of select="$womiExerciseEngineTypeMap[@type=$type]/@name"></xsl:value-of>
	</xsl:function>
	
	<xsl:template name="create_go_back_link_from_glossary">
		<xsl:param name="href"/>
		<xsl:element name="div">
			<xsl:attribute name="ep:role">go-back-from-glossary</xsl:attribute>
			<xsl:element name="a">
				<xsl:attribute name="href" select="$href"/>
				<xsl:value-of select="$locales/locale[@key='go-back-from-glossary']"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="ep:show_school_type">
		<xsl:param name="school_type"/>
		<xsl:choose>
			<xsl:when test="$school_type = 'I'">
				<xsl:value-of select="$locales/locale[@key='school_type_primary']/text()"/>
			</xsl:when>
			<xsl:when test="$school_type = 'II'">
				<xsl:value-of select="$locales/locale[@key='school_type_primary']/text()"/>
			</xsl:when>
			<xsl:when test="$school_type = 'III'">
				<xsl:value-of select="$locales/locale[@key='school_type_high']/text()"/>
			</xsl:when>
			<xsl:when test="$school_type = 'IV'">
				<xsl:value-of select="$locales/locale[@key='school_type_secondary']/text()"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:function name="ep:getLicenseLinkByName" as="xs:string">
		<xsl:param name="name"></xsl:param>
		<xsl:value-of select="$licenseMap[@name=$name]/@link"></xsl:value-of>
	</xsl:function>
	
	<xsl:function name="ep:getLicenseNameByLink" as="xs:string">
		<xsl:param name="link"></xsl:param>
		<xsl:value-of select="$licenseMap[@link=$link]/@name"></xsl:value-of>
	</xsl:function>   
	
	<xsl:variable name="licenseMap" as="element()+">
		<item name="E-podręczniki 1.0" link="http://www.epodreczniki.pl/licenses/e-podreczniki/1.0"/>
		<item name="domena publiczna" link="http://www.epodreczniki.pl/licenses/domena-publiczna/1.0"/>
		<item name="tylko do użytku edukacyjnego" link="http://www.epodreczniki.pl/licenses/tylko-do-uzytku-edukacyjnego/1.0"/>
		<item name="tylko do użytku edukacyjnego na epodreczniki.pl" link="http://www.epodreczniki.pl/licenses/tylko-do-uzytku-edukacyjnego-na-epodreczniki_pl/1.0"/>
		<item name="tylko do użytku niekomercyjnego" link="http://www.epodreczniki.pl/licenses/tylko-do-uzytku-niekomercyjnego/1.0"/>
		<item name="CC 0 1.0" link="http://creativecommons.org/publicdomain/zero/1.0/legalcode"/>
		<item name="CC BY 1.0" link="https://creativecommons.org/licenses/by/1.0/legalcode"/>
		<item name="CC BY 2.0" link="https://creativecommons.org/licenses/by/2.0/pl/legalcode"/>
		<item name="CC BY 2.5" link="https://creativecommons.org/licenses/by/2.5/pl/legalcode"/>
		<item name="CC BY 3.0" link="http://creativecommons.org/licenses/by/3.0/pl/legalcode"/>
		<item name="CC BY 4.0" link="https://creativecommons.org/licenses/by/4.0/legalcode"/>
		<item name="CC BY SA 1.0" link="https://creativecommons.org/licenses/by-sa/1.0/legalcode"/>
		<item name="CC BY SA 2.0" link="https://creativecommons.org/licenses/by-sa/2.0/pl/legalcode"/>
		<item name="CC BY SA 2.5" link="https://creativecommons.org/licenses/by-sa/2.5/pl/legalcode"/>
		<item name="CC BY SA 3.0" link="https://creativecommons.org/licenses/by-sa/3.0/pl/legalcode"/>
		<item name="CC BY SA 4.0" link="https://creativecommons.org/licenses/by-sa/4.0/legalcode"/>
		<item name="CC BY ND 1.0" link="https://creativecommons.org/licenses/by-nd/1.0/legalcode"/>
		<item name="CC BY ND 2.0" link="https://creativecommons.org/licenses/by-nd/2.0/pl/legalcode"/>
		<item name="CC BY ND 2.5" link="https://creativecommons.org/licenses/by-nd/2.5/pl/legalcode"/>
		<item name="CC BY ND 3.0" link="https://creativecommons.org/licenses/by-nd/3.0/pl/legalcode"/>
		<item name="CC BY ND 4.0" link="https://creativecommons.org/licenses/by-nd/4.0/legalcode"/>
		<item name="CC BY NC 1.0" link="https://creativecommons.org/licenses/by-nc/1.0/legalcode"/>
		<item name="CC BY NC 2.0" link="https://creativecommons.org/licenses/by-nc/2.0/pl/legalcode"/>
		<item name="CC BY NC 2.5" link="https://creativecommons.org/licenses/by-nc/2.5/pl/legalcode"/>
		<item name="CC BY NC 3.0" link="https://creativecommons.org/licenses/by-nc/3.0/pl/legalcode"/>
		<item name="CC BY NC 4.0" link="https://creativecommons.org/licenses/by-nc/4.0/legalcode"/>
		<item name="CC BY NC ND 2.0" link="https://creativecommons.org/licenses/by-nc-nd/2.0/pl/legalcode"/>
		<item name="CC BY NC ND 2.5" link="https://creativecommons.org/licenses/by-nc-nd/2.5/pl/legalcode"/>
		<item name="CC BY NC ND 3.0" link="https://creativecommons.org/licenses/by-nc-nd/3.0/pl/legalcode"/>
		<item name="CC BY NC ND 4.0" link="https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode"/>
		<item name="CC BY NC SA 1.0" link="https://creativecommons.org/licenses/by-nc-sa/1.0/legalcode"/>
		<item name="CC BY NC SA 2.0" link="https://creativecommons.org/licenses/by-nc-sa/2.0/pl/legalcode"/>
		<item name="CC BY NC SA 2.5" link="https://creativecommons.org/licenses/by-nc-sa/2.5/pl/legalcode"/>
		<item name="CC BY NC SA 3.0" link="https://creativecommons.org/licenses/by-nc-sa/3.0/pl/legalcode"/>
		<item name="CC BY NC SA 4.0" link="https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode"/>
	</xsl:variable>
	
	<xsl:function name="ep:getGoToGlossaryLabel">
		<xsl:param name="mergeType"/>
		<xsl:value-of select="$locales/locale[@key=concat('label-go-to-glossary-',$mergeType)]"/>
	</xsl:function>
	
</xsl:stylesheet>
