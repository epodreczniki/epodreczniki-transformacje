<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cnxml="http://cnx.rice.edu/cnxml" xmlns:md="http://cnx.rice.edu/mdml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:q="http://cnx.rice.edu/qml/1.0"
    xmlns:ep="http://epodreczniki.pl/" xmlns="http://cnx.rice.edu/cnxml" xmlns:col="http://cnx.rice.edu/collxml" xmlns:bib="http://bibtexml.sf.net/"
    xmlns:mml="http://www.w3.org/1998/Math/MathML" exclude-result-prefixes="md col" version="2.0">
    
    <xsl:import href="second_page.xslt"/>
    <xsl:import href="answers.xsl"/>
    <xsl:import href="about.xsl"/>
    <xsl:import href="common.xslt"/>
    <xsl:import href="womi2licenses.xsl"/>
    
    <xsl:param name="resultDir" select="'1'"/>
    <xsl:param name="doCopyModules" select="1"/>
    <xsl:param name="path_to_files_epxml_of_modules_in_col" select="'1'"/>
    <xsl:param name="womiLocalPath" select="'1'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>

    <xsl:variable name="ep:get_doc_id_sec_page">
        <xsl:value-of select="ep:generate_doc_id(/col:collection/col:metadata/md:content-id, '_second_page')"/>
    </xsl:variable>

    <xsl:variable name="ep:get_doc_id_answers">
        <xsl:value-of select="ep:generate_doc_id(/col:collection/col:metadata/md:content-id, '_answers_')"/>
    </xsl:variable>

    <xsl:variable name="ep:get_doc_id_about">
        <xsl:value-of select="ep:generate_doc_id(/col:collection/col:metadata/md:content-id, '_about_')"/>
    </xsl:variable>

    <xsl:variable name="ep:get_doc_id_answers_licenses">
        <xsl:value-of select="ep:generate_doc_id(/col:collection/col:metadata/md:content-id, '_answers_licenses')"/>
    </xsl:variable>

    <xsl:variable name="ep:get_doc_id_answers_licenses_pdf">
        <xsl:value-of select="ep:generate_doc_id(/col:collection/col:metadata/md:content-id, '_answers_licenses_pdf')"/>
    </xsl:variable>
    
    <xsl:variable name="ep:get_doc_id_answers_licenses_ebook">
        <xsl:value-of select="ep:generate_doc_id(/col:collection/col:metadata/md:content-id, '_answers_licenses_ebook')"/>
    </xsl:variable>
    
    <xsl:variable name="collxml">
        <xsl:apply-templates mode="epcollxml2epcollxml" select="/"/>
    </xsl:variable>

    <xsl:variable name="answers">
        <xsl:apply-templates mode="answers_page" select="$collxml"/>
    </xsl:variable>

    <xsl:variable name="answersLicenses">
        <xsl:apply-templates mode="answersLicenses" select="$collxml"/>
    </xsl:variable>
    
    <xsl:variable name="answerWOMIs-pdf" select="$womi_image_metadata_info/womi[@solution = 'true' and @format = 'pdf']"/>
    <xsl:variable name="answerWOMIs-ebook" select="$womi_image_metadata_info/womi[@solution = 'true' and @format = 'ebook']"/>
    <xsl:variable name="alternativesFound" select="$answerWOMIs-pdf or $answerWOMIs-ebook"/>
    
    <xsl:template match="/">
        <xsl:variable name="mergedModules">
            <documents xmlns="http://cnx.rice.edu/cnxml">
                <xsl:call-template name="ep:copyModules"/>
            </documents>
        </xsl:variable>
        
        <xsl:for-each select="$mergedModules//cnxml:document">
            <xsl:result-document href="file:///{$resultDir}/{@id}/index.epxml">
                <xsl:copy-of select="."></xsl:copy-of>
            </xsl:result-document>
        </xsl:for-each> 
        
        <xsl:variable name="about">
            <xsl:apply-templates mode="about_page" select="$collxml">
                <xsl:with-param name="mergedModules" select="$mergedModules" tunnel="yes"></xsl:with-param>
            </xsl:apply-templates>
        </xsl:variable>
        
        <xsl:call-template name="ep:addSecondPageModule"/>
        <xsl:call-template name="ep:addAnswersModules"/>
        <xsl:call-template name="ep:addAnswersLicensesModule"/>
        <xsl:call-template name="ep:addAboutEpoModules">
            <xsl:with-param name="about" select="$about" tunnel="yes"></xsl:with-param>
        </xsl:call-template>   
        <xsl:call-template name="ep:createModifiedCollxml">
            <xsl:with-param name="about" select="$about" tunnel="yes"></xsl:with-param>
        </xsl:call-template>
        
        <xsl:if test="$glossaryMapping/cnxml:item">
            <xsl:result-document href="file:///{$resultDir}/mappingGlossary.xml">
                <xsl:copy-of select="ep:createGlossatyMappingFileContent()"/>
            </xsl:result-document>
        </xsl:if>
        
     </xsl:template>

    <xsl:template name="ep:createModifiedCollxml">  
        
        <xsl:result-document href="file:///{$resultDir}/collection.xml">
            <xsl:apply-templates select="$collxml" mode="collxml">
                <xsl:with-param name="toPortal" select="0" tunnel="yes"></xsl:with-param>
            </xsl:apply-templates>
        </xsl:result-document>

        <xsl:result-document href="file:///{$resultDir}/collection_portal.xml">
            <xsl:apply-templates select="$collxml" mode="collxml">
                <xsl:with-param name="toPortal" select="1" tunnel="yes"></xsl:with-param>
            </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="@*|node()" mode="collxml epcollxml2epcollxml">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="col:metadata/md:subjectlist" mode="collxml">
        <xsl:param name="toPortal" tunnel="yes"/>
        <xsl:copy copy-namespaces="no">
            <xsl:choose>
                <xsl:when test="$toPortal = 0 
                    and (count(md:subject) = 0 or (count(md:subject) = 1 and empty(md:subject/text())))">
                    <xsl:element name="md:subject">historia</xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="//col:content" mode="collxml">
        <xsl:param name="toPortal" tunnel="yes"></xsl:param>
        
        <xsl:element name="col:content">
            <xsl:if test="$toPortal = 0">
                <xsl:element name="col:subcollection">
                    <xsl:attribute name="toc">skip</xsl:attribute>
                    <xsl:element name="col:content">
                        <xsl:call-template name="ep:define_second_page_information"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            <xsl:for-each select="/col:collection/col:content/col:subcollection">
                <xsl:choose>
                    <xsl:when test="$toPortal = 1 and count(./col:content/col:module) = 1 and not(exists(./md:title))">
                        <xsl:copy-of select="./col:content/col:module"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:attribute name="id" select="generate-id()"/>
                            <xsl:apply-templates select="@*|node()" />
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <xsl:if test="$toPortal = 0">
                <xsl:if test="$answers/cnxml:document">
                    <xsl:element name="col:subcollection">
                        <xsl:attribute name="id" select="concat(generate-id(), '-answers')"/>
                        <xsl:element name="md:title">
                            <xsl:value-of select="$locales/locale[@key='answers']/text()"/>
                        </xsl:element>
                        <xsl:element name="col:content">
                            <xsl:call-template name="ep:define_answers_information"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="col:subcollection">
                    <xsl:attribute name="id" select="concat(generate-id(), '-about')"/>
                    <xsl:element name="md:title">
                        <xsl:value-of select="$locales/locale[@key='about_etextbook']/text()"/>
                    </xsl:element>
                    <xsl:element name="col:content">
                        <xsl:call-template name="ep:define_about_information">
                        </xsl:call-template>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template name="ep:define_second_page_information">
        <xsl:element name="col:module">
            <xsl:attribute name="repository">https://epodreczniki.pcss.pl/transformacje/</xsl:attribute>
            <xsl:attribute name="document">
                <xsl:value-of select="$ep:get_doc_id_sec_page"/>
            </xsl:attribute>
            <xsl:element name="md:title">
                <xsl:value-of select="$locales/locale[@key='title_module_second_page']/text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="ep:define_answers_information">
        <xsl:for-each-group select="$answers/cnxml:document" group-by="@subcol_id">
            <xsl:element name="col:subcollection">
                <xsl:attribute name="id" select="current-grouping-key()"/>
                <xsl:attribute name="toc" select="'skip'"></xsl:attribute>
                <xsl:element name="col:content">
                    <xsl:for-each select="current-group()">
            <xsl:element name="col:module">
                <xsl:attribute name="toc">skip</xsl:attribute>
                <xsl:attribute name="repository">https://epodreczniki.pcss.pl/transformacje/</xsl:attribute>
                <xsl:attribute name="document">
                    <xsl:value-of select="./@id"/>
                </xsl:attribute>
                <xsl:element name="md:title">
                    <xsl:value-of select="./@id"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
                </xsl:element>
            </xsl:element>

        </xsl:for-each-group>
    </xsl:template>

    <xsl:template name="ep:define_answers_licenses_information">
               <xsl:element name="col:module">
                    <xsl:attribute name="toc">skip</xsl:attribute>
                    <xsl:attribute name="repository">https://epodreczniki.pcss.pl/transformacje</xsl:attribute>
                    <xsl:attribute name="document">
                        <xsl:value-of select="$ep:get_doc_id_answers_licenses"/>
                    </xsl:attribute>
                    <xsl:element name="md:title">
                        <xsl:value-of select="$ep:get_doc_id_answers_licenses"/>
                    </xsl:element>
                </xsl:element>
    </xsl:template>

    <xsl:template name="ep:define_about_information">
        <xsl:param name="about" tunnel="yes"></xsl:param>
        
        <xsl:for-each select="$about/cnxml:document">
            <xsl:if test="not(@data-format)">
                <xsl:element name="col:module">
                    <xsl:attribute name="toc">skip</xsl:attribute>
                    <xsl:attribute name="repository"
                        >https://epodreczniki.pcss.pl/transformacje</xsl:attribute>
                    <xsl:attribute name="document">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                    <xsl:element name="md:title">
                        <xsl:value-of select="./@id"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>

    <xsl:template name="ep:addSecondPageModule">
        <xsl:result-document href="file:///{$resultDir}/{$ep:get_doc_id_sec_page}/index.epxml">
            <xsl:apply-templates mode="second_page"/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="ep:addAnswersModules">
        <xsl:for-each select="$answers/cnxml:document">
             <xsl:result-document href="file:///{$resultDir}/{./@id}/index.epxml">
                <xsl:copy-of select="."/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="ep:addAboutEpoModules">
        <xsl:param name="about" tunnel="yes"></xsl:param>
        
        <xsl:for-each select="$about/cnxml:document">
            <xsl:choose>
                <xsl:when test="./@data-format = 'mobile_app'">
                    <xsl:result-document href="file:///{$resultDir}/{./@id}_mobile_app/index.epxml">
                        <xsl:copy-of select="."/>
                    </xsl:result-document>    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:result-document href="file:///{$resultDir}/{./@id}/index.epxml">
                        <xsl:copy-of select="."/>
                    </xsl:result-document>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="ep:addAnswersLicensesModule">
        <xsl:variable name="answerWOMIs" select="$womi_image_metadata_info/womi[@solution = 'true']"/>
        <xsl:if test="$answerWOMIs">
            <xsl:call-template name="ep:define_answers_licenses_information"/>
        </xsl:if>        
    </xsl:template>
    
    <xsl:template name="ep:copyModules">
        <xsl:if test="$doCopyModules > 0">
            <xsl:choose>
                <xsl:when test="count($glossaryMapping/cnxml:item) = 0">
                    <xsl:for-each select="$modules/cnxml:documents/cnxml:document">
                            <xsl:apply-templates mode="epcollxml2epcollxml" select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$modules/cnxml:documents/cnxml:document">
                        <xsl:variable name="curr_module_id" select="./@module-id"></xsl:variable>
                        <xsl:variable name="curr_module_type" select="./cnxml:metadata//ep:generated-type/text()"/>
                        
                        <xsl:choose>
                            <xsl:when test="$curr_module_type and ($glossaryMapping/cnxml:item[@module_id=$curr_module_id]/@merge_id != '')">
                                <xsl:if test="$glossaryMapping/cnxml:item[@module_id=$curr_module_id]/@merge_type = $curr_module_type">
                                    <xsl:apply-templates mode="epcollxml2epcollxml" select=".">
                                        <xsl:with-param name="mergeElement" select="$curr_module_type" tunnel="yes"/>
                                    </xsl:apply-templates>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates mode="epcollxml2epcollxml" select="."/> 
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="cnxml:content[ancestor::node()[local-name() = 'document']] | bib:file[ancestor::node()[local-name() = 'document']]" mode="epcollxml2epcollxml">
        <xsl:param name="mergeElement" tunnel="yes"/>
        
        <xsl:if test="not(local-name() = 'file' and $mergeElement = 'bibliography')">
            <xsl:variable name="modulesTypeToMerge" select="string-join($glossaryMapping/cnxml:item[@merge_type=$mergeElement]/@module_type,',')"/>
            
            <xsl:copy>               
                <xsl:choose>
                    <xsl:when test="$mergeElement and $mergeElement != 'bibliography'">
                        <section>
                            <xsl:copy-of select="./cnxml:section/@*"/>
                            <xsl:call-template name="generateAgregateModules">
                                <xsl:with-param name="local_name" select="'section'"/>
                                <xsl:with-param name="namespace" select="namespace-uri()"/>
                                <xsl:with-param name="modulesTypeToMerge" select="$modulesTypeToMerge"/>
                            </xsl:call-template>
                        </section>
                    </xsl:when>
                    <xsl:when test="not($mergeElement)">
                        <xsl:apply-templates mode="epcollxml2epcollxml" select="./node()"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:copy>

            <xsl:if test="$mergeElement and contains($modulesTypeToMerge, 'bibliography')">
                <xsl:variable name="bibData">
                    <xsl:call-template name="generateAgregateModules">
                        <xsl:with-param name="local_name" select="'file'"/>
                        <xsl:with-param name="namespace" select="'http://bibtexml.sf.net/'"/>
                        <xsl:with-param name="modulesTypeToMerge" select="$modulesTypeToMerge"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:if test="$bibData/node()">
                    <xsl:element name="bib:file">
                        <xsl:copy-of select="$bibData"></xsl:copy-of>
                    </xsl:element>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ep:biography|ep:concept|cnxml:definition|ep:event|bib:entry" mode="epcollxml2epcollxml">
        <xsl:copy copy-namespaces="no">
            <xsl:if test="(@ep:glossary and @ep:glossary='true') or local-name()='entry'">
                <xsl:attribute name="ep:glossary-merge-type">
                    <xsl:choose>
                        <xsl:when test="local-name() = 'biography'">
                            <xsl:value-of select="$glossaryMapping//node()[@module_type='biography']/@merge_type"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'concept'">
                            <xsl:value-of select="$glossaryMapping//node()[@module_type='concept']/@merge_type"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'definition' or local-name() = 'rule'">
                            <xsl:value-of select="$glossaryMapping//node()[@module_type='glossary']/@merge_type"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'event'">
                            <xsl:value-of select="$glossaryMapping//node()[@module_type='event']/@merge_type"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'entry'">
                            <xsl:value-of select="$glossaryMapping//node()[@module_type='bibliography']/@merge_type"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|node()" mode="epcollxml2epcollxml"/>
        </xsl:copy>
    </xsl:template>
	
	<xsl:template name="generateAgregateModules">
	    <xsl:param name="local_name"></xsl:param>
	    <xsl:param name="namespace"></xsl:param>
	    <xsl:param name="modulesTypeToMerge"></xsl:param>
	    
	    <xsl:variable name="data" as="element()*">
	        <xsl:for-each select="tokenize($modulesTypeToMerge, ',')">
	            <xsl:variable name="token" select="."/>
	            <xsl:if test="$token != ''">
	                <xsl:apply-templates mode="epcollxml2epcollxml" select="$modules//cnxml:document[./cnxml:metadata//ep:generated-type=$token]
	                    //node()[local-name() = $local_name and namespace-uri() = $namespace]/child::node()[normalize-space(.)]"/>
	            </xsl:if>
	        </xsl:for-each>
	    </xsl:variable>
	    
	    <xsl:for-each select="$data">
	        <xsl:sort
	            select="string-join((descendant::ep:sorting-key//text(),
	            string-join(descendant::cnxml:term//text(),''),
	            string-join(descendant::cnxml:title//text(),''), 
	            string-join(descendant::ep:name//text(),''), 
	            string-join(descendant::bib:booktitle//text(),''),
	            string-join(descendant::bib:title//text(),'')),'')"
	            lang="pl"/>
	        
	        <xsl:if test="not(empty(text()))">
	            <xsl:copy-of select="."/>
	        </xsl:if>
	    </xsl:for-each>	    
	</xsl:template>
	
    <xsl:template match="q:item" mode="epcollxml2epcollxml">
        <xsl:copy-of select="ep:shuffle_qml_answers(.)"/>
    </xsl:template>

    <xsl:template match="@id" mode="epcollxml2epcollxml">
        <xsl:attribute name="id">
            <xsl:choose>
                <xsl:when test="some $x in ('bibliography', 'biography', 'event', 'glossary', 'concept') satisfies contains(., $x)
				or parent::node()/local-name() = 'mathElement'">
                    <xsl:value-of select="."></xsl:value-of>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ep:generateNewIdWithModuleId(., ancestor::node()/@module-id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="col:collection/col:content" mode="epcollxml2epcollxml">
        <xsl:element name="col:content">
            <xsl:apply-templates mode="epcollxml2epcollxml"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="col:content/col:subcollection" mode="epcollxml2epcollxml">
        <xsl:variable name="dataToCopy">
            <xsl:for-each select="./col:content/child::node()">
                <xsl:if test=". != text()">
                    <xsl:call-template name="processModule">
                        <xsl:with-param name="ctx" select="."/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="count($dataToCopy/col:module) > 0 or count($dataToCopy/col:subcollection) > 0">
            <xsl:element name="col:subcollection">
                <xsl:copy-of select="*[local-name() != 'content']"/>
                <xsl:element name="col:content">
                    <xsl:copy-of select="$dataToCopy"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="processModule">
        <xsl:param name="ctx"></xsl:param>
        <xsl:choose>
            <xsl:when test="local-name() = 'module'">    
                <xsl:variable name="module2remove" select="tokenize(normalize-space($glossaryModuleIdToRemoveFromCollXML),' ')"/>
                <xsl:if test="empty(index-of($module2remove, ./@document))">
                    <xsl:call-template name="createOrChangeModule"></xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:when test="local-name() = 'subcollection'">
                <xsl:variable name="subcollectionModules">
                    <xsl:for-each select="./col:content/child::node()">
                        <xsl:if test=". != text()">
                            <xsl:call-template name="processModule">
                                <xsl:with-param name="ctx" select="."/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:if test="count($subcollectionModules/col:module) > 0 or count($subcollectionModules/col:subcollection) > 0">
                    <xsl:element name="col:subcollection">
                        <xsl:copy-of select="$ctx/*[local-name() != 'content']"/>
                        <xsl:element name="col:content">
                            <xsl:copy-of select="$subcollectionModules"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."></xsl:copy-of>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template match="col:content/col:module" mode="epcollxml2epcollxml">
		<xsl:variable name="module2remove" select="tokenize(normalize-space($glossaryModuleIdToRemoveFromCollXML),' ')"/>
		<xsl:if test="empty(index-of($module2remove, ./@document))">
            <xsl:element name="col:subcollection">
                <xsl:variable name="moduleId" select="./@document"></xsl:variable>
                <xsl:element name="col:content">
                    <xsl:call-template name="createOrChangeModule">
                        <xsl:with-param name="generatedModuleType">
                            <xsl:value-of select="$glossaryMapping/cnxml:item[@module_id=$moduleId]/@module_type"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="createOrChangeModule">
        <xsl:param name="generatedModuleType"></xsl:param>
        
        <xsl:variable name="loc_module_id" select="./@document"></xsl:variable>
        <xsl:variable name="prop_numbering" select="$modules//cnxml:document[@module-id=$loc_module_id]/cnxml:metadata//ep:presentation/ep:numbering"></xsl:variable>
        
        <xsl:choose>
            <xsl:when test="exists($prop_numbering)">
                <xsl:element name="col:module">
                    <xsl:attribute name="ep:numbering" select="$prop_numbering"></xsl:attribute>
                    <xsl:copy-of select="@*"></xsl:copy-of>
                    <xsl:element name="md:title">
                        <xsl:choose>
                            <xsl:when test="$generatedModuleType != ''">
                                <xsl:value-of select="$locales/locale[@key=concat('gen_', $generatedModuleType/text())]/text()"></xsl:value-of>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./md:title/text()"></xsl:value-of>
                            </xsl:otherwise>
                        </xsl:choose> 
                </xsl:element>
                    <xsl:copy-of select="node()[not(local-name()='title')]"></xsl:copy-of>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="cnxml:document/cnxml:title/text()|cnxml:document/cnxml:metadata/md:title/text()" mode="epcollxml2epcollxml">
        <xsl:variable name="generatedType" select="ancestor::node()[local-name() = 'document']/cnxml:metadata/ep:e-textbook-module/ep:generated-type"></xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$generatedType">
                <xsl:value-of select="$locales/locale[@key=concat('gen_', $generatedType/text())]/text()"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."></xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
     <xsl:variable name="glossaryMapping">
        <xsl:copy-of select="ep:createMappingGlossaryElement('bibliography')"/>
        <xsl:copy-of select="ep:createMappingGlossaryElement('biography')"/>
        <xsl:copy-of select="ep:createMappingGlossaryElement('event')"/>
        <xsl:copy-of select="ep:createMappingGlossaryElement('glossary')"/>
        <xsl:copy-of select="ep:createMappingGlossaryElement('concept')"/>
    </xsl:variable>
    
    <xsl:variable name="glossaryModuleIdToRemoveFromCollXML">
        <xsl:value-of select="ep:getGlossaryModulesIdToRemoveByValue('glossary')"></xsl:value-of>
        <xsl:value-of select="ep:getGlossaryModulesIdToRemoveByValue('bibliography')"></xsl:value-of>
        <xsl:value-of select="ep:getGlossaryModulesIdToRemoveByValue('biography')"></xsl:value-of>
        <xsl:value-of select="ep:getGlossaryModulesIdToRemoveByValue('event')"/>
        <xsl:value-of select="ep:getGlossaryModulesIdToRemoveByValue('concept')"/>
    </xsl:variable>
    
    <xsl:function name="ep:getModuleIdByGlossaryType" as="xs:string">
        <xsl:param name="type"/>
        <xsl:value-of select="$modules/cnxml:documents/cnxml:document[./cnxml:metadata//ep:generated-type/text() = $type]/@id"/>
    </xsl:function>
    
    <xsl:function name="ep:checkIfModuleHasAnyElementContent" as="xs:boolean">
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type = 'bibliography'">
                <xsl:value-of select="count($modules/cnxml:documents/cnxml:document[./cnxml:metadata//ep:generated-type/text() = $type]/bib:file/bib:entry) = 0"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count($modules/cnxml:documents/cnxml:document[./cnxml:metadata//ep:generated-type/text() = $type]/cnxml:content/cnxml:section/child::node()) = 0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ep:createMappingGlossaryElement" as="node()*">
        <xsl:param name="currModuleType"/>
        <xsl:variable name="curr_module_id" select="ep:getModuleIdByGlossaryType($currModuleType)"/>
        <xsl:if test="$curr_module_id">
            <xsl:element name="item">
                <xsl:attribute name="module_id" select="$curr_module_id"/>
                <xsl:attribute name="module_type" select="$currModuleType"/>
                <xsl:attribute name="merge_id" select="ep:getModuleIdByGlossaryType($glossaryModule/element[@key=$currModuleType])"/>
                <xsl:attribute name="merge_type" select="$glossaryModule/element[@key=$currModuleType]"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="ep:getGlossaryModulesIdToRemoveByValue">
        <xsl:param name="type"/>
	    <xsl:if test="ep:checkIfModuleHasAnyElementContent($type) = true()">
            <xsl:choose>
                <xsl:when test="$glossaryMapping//@merge_type != $type">
                    <xsl:value-of select="$glossaryMapping/cnxml:item[@module_type=$type]/@module_id"/>
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="matchItems">
                        <xsl:for-each
                            select="$glossaryMapping//node()[@merge_type = $type]/@module_type">
                            <xsl:if test="ep:checkIfModuleHasAnyElementContent(.) = true()">
                                <xsl:text>1</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="string-length($matchItems) = count($glossaryMapping//node()[@merge_type = $type]/@module_type)">
                        <xsl:value-of select="$glossaryMapping/cnxml:item[@module_type=$type]/@module_id"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
		<xsl:value-of select="$glossaryMapping/cnxml:item[@merge_type=$type and @module_type != $type]/@module_id"/>
		<xsl:text> </xsl:text>
    </xsl:function>
    
    <xsl:function name="ep:createGlossatyMappingFileContent" as="node()*">
        <xsl:element name="glossaryMapping" xmlns="http://cnx.rice.edu/cnxml" extension-element-prefixes="xs q ep bib mml">
            <xsl:for-each select="$glossaryMapping/cnxml:item">
                <xsl:element name="item">
                    <xsl:attribute name="type" select="@module_type"/>
                    <xsl:attribute name="module_id">
                        <xsl:choose>
                            <xsl:when test="@merge_id != ''">
                                <xsl:value-of select="@merge_id"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@module_id"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:function>
</xsl:stylesheet>
