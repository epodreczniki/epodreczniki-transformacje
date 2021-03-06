<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns:cnx="http://cnx.rice.edu/cnxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:ep="http://epodreczniki.pl/"
  exclude-result-prefixes="qml cnx md ">

  <xsl:template match="qml:problemset">
    <div ep:role="problemset">
      <h2 ep:role="problemset-header">
        <span ep:role="label">
          <xsl:value-of select="$locales/locale[@key='ProblemSet']"/>
        </span>
      </h2>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="qml:item[preceding-sibling::ep:config]">
    <xsl:variable name="config" select="preceding-sibling::ep:config"></xsl:variable>
    <div id="{@id}" ep:name='item'>
      <xsl:attribute name="ep:role">
        <xsl:text>qmlitem</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="$config/(ep:behaviour|ep:presentation-style)|@type"></xsl:apply-templates>
      <xsl:if test="parent::qml:problemset">
        <div ep:role="qmlitem-header">
          <span ep:role="label">
            <xsl:value-of select="$locales/locale[@key='Problem']"/>
            <xsl:text> </xsl:text>
            <xsl:number level="any" count="qml:item"/>
          </span>
        </div>
      </xsl:if>
      
      <xsl:apply-templates select="qml:question" />
      
      <xsl:if test='qml:answer'>
        <form id="{@type}_{@id}">
          <xsl:attribute name="ep:role">
            <xsl:value-of select="$config/ep:behaviour"></xsl:value-of>
            <xsl:if test="$config/ep:presentation-style = 'true-false'">
                <xsl:text> true-false</xsl:text>
            </xsl:if>
          </xsl:attribute>
          <xsl:apply-templates select="$config/(ep:presented-answers|ep:correct-in-set)"/>
          <xsl:element name="div">
            <xsl:attribute name="ep:role" select="'answers-container'"></xsl:attribute>
            <xsl:choose>
              <xsl:when test="preceding-sibling::ep:config/ep:presentation-style = 'true-false'">
                <xsl:choose>
                  <xsl:when test="ends-with($config/ep:behaviour,'-sets')">
                    <xsl:for-each-group select="qml:answer" group-by="@ep:in-set">
                        <xsl:element name="div">
                          <xsl:attribute name="ep:role" select="'set-header'"></xsl:attribute>
                          <xsl:apply-templates select="@ep:in-set"></xsl:apply-templates>
                          <xsl:element name="span">
                            <xsl:attribute name="ep:role" select="'answers-label'"></xsl:attribute>
                          </xsl:element>
                          <xsl:element name="span">
                            <xsl:attribute name="ep:role" select="'answers-label'"></xsl:attribute>
                            <xsl:value-of select="$locales/locale[@key='Truth']"/>
                          </xsl:element>
                          <xsl:element name="span">
                            <xsl:attribute name="ep:role" select="'answers-label'"></xsl:attribute>
                            <xsl:value-of select="$locales/locale[@key='False']"/>
                          </xsl:element>
                        </xsl:element>
                        <xsl:for-each select="current-group()">
                          <xsl:apply-templates select="." mode="zw2"/>
                        </xsl:for-each>
                    </xsl:for-each-group>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:element name="div">
                      <xsl:attribute name="ep:role" select="'set-header'"></xsl:attribute>
                      <xsl:apply-templates select="@ep:in-set"></xsl:apply-templates>
                      <xsl:element name="span">
                        <xsl:attribute name="ep:role" select="'answers-label'"></xsl:attribute>
                      </xsl:element>
                      <xsl:element name="span">
                        <xsl:attribute name="ep:role" select="'answers-label'"></xsl:attribute>
                        <xsl:value-of select="$locales/locale[@key='Truth']"/>
                      </xsl:element>
                      <xsl:element name="span">
                        <xsl:attribute name="ep:role" select="'answers-label'"></xsl:attribute>
                        <xsl:value-of select="$locales/locale[@key='False']"/>
                      </xsl:element>
                    </xsl:element>
                    <xsl:apply-templates select="qml:answer" mode="zw2"/>
                  </xsl:otherwise>
                </xsl:choose>
                
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="ends-with($config/ep:behaviour,'-sets')">
                    <xsl:for-each-group select="qml:answer" group-by="@ep:in-set">
                        <xsl:element name="div">
                          <xsl:attribute name="ep:role" select="'set-header'"></xsl:attribute>
                          <xsl:apply-templates select="@ep:in-set"></xsl:apply-templates>
                        </xsl:element>
                        <xsl:for-each select="current-group()">
                          <xsl:apply-templates select="." mode="zj1zw1"/>
                        </xsl:for-each>
                    </xsl:for-each-group>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="qml:answer" mode="zj1zw1"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          
          <xsl:element name="div">
            <xsl:attribute name="ep:role" select="'exercise-buttons'"/>
            <xsl:element name="button">
              <xsl:attribute name="ep:role" select="'check'"/>
              <xsl:choose>
                <xsl:when test="@type='text-response'"><xsl:value-of select="$locales/locale[@key='ShowAnswer']"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$locales/locale[@key='CheckAnswer']"/></xsl:otherwise>
              </xsl:choose>
            </xsl:element>
            <xsl:if test="qml:hint">
              <xsl:element name="button">
                <xsl:attribute name="ep:role" select="'hint'"/>
                <xsl:element name="span">
                  <xsl:attribute name="ep:role" select="'hint-label'"/>
                  <xsl:value-of select="$locales/locale[@key='Hint']"/>
                </xsl:element>
                <xsl:element name="span">
                  <xsl:attribute name="ep:role" select="'next-hint-label'"/>
                  <xsl:attribute name="style" select="'display:none;'"></xsl:attribute>
                  <xsl:value-of select="$locales/locale[@key='NextHint']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="$config/ep:behaviour != 'all-sets'">
              <xsl:element name="button">
                <xsl:attribute name="ep:role" select="'recreate'"/>
                <xsl:value-of select="$locales/locale[@key='Recreate']"/>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </form>
      </xsl:if>
      
      <div ep:role="feedback correct" id='correct_{@id}'>
        <xsl:choose>
          <xsl:when test="qml:key/qml:feedback[@correct = 'yes']">
            <xsl:value-of select="qml:key/qml:feedback[@correct = 'yes']"></xsl:value-of>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$locales/locale[@key='Correct']"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      
      <div ep:role="feedback incorrect" id='incorrect_{@id}'>
        <xsl:choose>
          <xsl:when test="qml:key/qml:feedback[@correct = 'no']">
            <xsl:value-of select="qml:key/qml:feedback[@correct = 'no']"></xsl:value-of>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$locales/locale[@key='Incorrect']"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      
      <xsl:if test="qml:feedback">
        <div ep:role="feedback" id='general_{@id}'>
          <xsl:apply-templates select="qml:feedback/*|qml:feedback/text()" />
        </div>
      </xsl:if>
      
      <xsl:apply-templates select="qml:hint" />
    </div>
  </xsl:template>
  
  <xsl:template match="qml:item">
    <div id="{@id}" ep:name='item' ep:role="qmlitem">
      <xsl:if test="parent::qml:problemset">
        <div ep:role="qmlitem-header">
          <span ep:role="label">
            <xsl:value-of select="$locales/locale[@key='Problem']"/>
            <xsl:text> </xsl:text>
            <xsl:number level="any" count="qml:item"/>
          </span>
        </div>
      </xsl:if>

      <xsl:apply-templates select="qml:question" />
      
      <xsl:if test='qml:answer'>
      <form id="{@type}_{@id}">
	       <xsl:apply-templates select="qml:answer" />
          <xsl:element name="div">
             <xsl:attribute name="ep:role" select="'exercise-buttons'"/>
             <xsl:if test="not(@type='single-response') or ../ep:config">
               <input type="button" ep:role="button">
                 <xsl:attribute name="value">
                   <xsl:choose>
                     <xsl:when test="@type='text-response'"><xsl:value-of select="$locales/locale[@key='ShowAnswer']"/></xsl:when>
                     <xsl:otherwise><xsl:value-of select="$locales/locale[@key='CheckAnswer']"/></xsl:otherwise>
                   </xsl:choose>
                 </xsl:attribute>
                 <xsl:if test="qml:key">
                   <xsl:attribute name="onclick">showAnswer('<xsl:value-of select="@id" />', document.getElementById['<xsl:value-of select="@type"/>_<xsl:value-of select="@id"/>'], '<xsl:value-of select="qml:key/@answer" />')</xsl:attribute>
                 </xsl:if>
                 <xsl:if test="not(qml:key)">
                   <xsl:attribute name="onclick">showAnswer('<xsl:value-of select="@id" />', document.getElementById['<xsl:value-of select="../@type"/>_<xsl:value-of select="@id"/>'], 'no-key-present')</xsl:attribute>
                 </xsl:if>
               </input>
             </xsl:if>
             <xsl:if test="qml:hint">
               <input type="button" ep:role="button" onclick="showHint('{@id}')">
                  <xsl:attribute name="value">
                    <xsl:value-of select="$locales/locale[@key='Hint']"/>
                  </xsl:attribute>
                </input>
             </xsl:if>
          </xsl:element>
      </form>
      </xsl:if>

      <div ep:role="feedback correct" id='correct_{@id}'>
        <xsl:choose>
          <xsl:when test="qml:key/qml:feedback[@correct = 'yes']">
            <xsl:value-of select="qml:key/qml:feedback[@correct = 'yes']"></xsl:value-of>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$locales/locale[@key='Correct']"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      
      <div ep:role="feedback incorrect" id='incorrect_{@id}'>
        <xsl:choose>
          <xsl:when test="qml:key/qml:feedback[@correct = 'no']">
            <xsl:value-of select="qml:key/qml:feedback[@correct = 'no']"></xsl:value-of>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$locales/locale[@key='Incorrect']"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      
      <xsl:for-each select="qml:answer">
      	<xsl:if test="count(qml:feedback) = 1">
      	  <xsl:choose>
      	    <xsl:when test="qml:feedback/@correct='yes'">
      	      <div id='feedbaq_{@id}_{../@id}' ep:role="feedback correct">
      		      <xsl:apply-templates select="qml:feedback/*|qml:feedback/text()" />
      	      </div>
      	    </xsl:when>
      	    <xsl:when test="qml:feedback/@correct='no'">
      	      <div id='feedbaq_{@id}_{../@id}' ep:role="feedback incorrect">
      	        <xsl:apply-templates select="qml:feedback/*|qml:feedback/text()" />
      	      </div> 
      	    </xsl:when>
      	    <xsl:otherwise>
      	      <div id='feedbaq_{@id}_{../@id}' ep:role="feedback">
      	        <xsl:apply-templates select="qml:feedback/*|qml:feedback/text()" />
      	      </div> 
      	    </xsl:otherwise>
      	  </xsl:choose>
      	</xsl:if>
      	<xsl:if test="count(qml:feedback) = 2">
      	  <xsl:for-each select="qml:feedback">
      	    <xsl:choose>
      	      <xsl:when test="@correct='yes'">
      	        <div id='feedbaq_{@correct}_{../../@id}' ep:role="feedback correct">
            		  <xsl:apply-templates />
            		</div>
      	      </xsl:when>
      	      <xsl:when test="@correct='no'">
      	        <div id='feedbaq_{@correct}_{../../@id}' ep:role="feedback incorrect">
            		  <xsl:apply-templates />
            		</div>
      	      </xsl:when>
      	      <xsl:otherwise>
      	        <div id='feedbaq_{@correct}_{../../@id}' ep:role="feedback">
            		   <xsl:apply-templates />
            		</div>
      	      </xsl:otherwise>
      	    </xsl:choose>
      	  </xsl:for-each>
      	</xsl:if>
      </xsl:for-each>

      <xsl:if test="qml:feedback">
        <div ep:role="feedback" id='general_{@id}'>
      	  <xsl:apply-templates select="qml:feedback/*|qml:feedback/text()" />
      	</div>
      </xsl:if>
      
      <xsl:apply-templates select="qml:hint" />
      
    </div>
  </xsl:template>
  
  <xsl:template match="qml:answer" mode="zw2">
    <div ep:role="answer">
      <xsl:variable name="answer_id" select="@id"></xsl:variable>
      <xsl:apply-templates select="@ep:*"></xsl:apply-templates>
      <xsl:attribute name="data-correct" select="exists(tokenize(../qml:key/@answer, ',')[. = $answer_id])"></xsl:attribute>
      <xsl:apply-templates select="qml:response" mode="zw2"/>
      
      <xsl:element name="span">
        <xsl:attribute name="ep:role" select="'response-input'"/>
        <xsl:element name="input">
          <xsl:attribute name="id" select="concat(@id, '-true')"/>
          <xsl:attribute name="value" select="'true'"/>
          <xsl:attribute name="name" select="concat(../@id, @ep:in-set, count(preceding-sibling::qml:answer)+1)"/>
          <xsl:attribute name="type">radio</xsl:attribute>
          <xsl:attribute name="ep:role">radio</xsl:attribute>
        </xsl:element>
        <xsl:element name="label">
          <xsl:attribute name="for" select="concat(@id, '-true')"/>
          <xsl:attribute name="ep:role" select="'hidden-text'"></xsl:attribute>
          <xsl:value-of select="$locales/locale[@key='Truth']"/>
        </xsl:element>
      </xsl:element>
      <xsl:element name="span">
        <xsl:attribute name="ep:role" select="'response-input'"/>
        <xsl:element name="input">
          <xsl:attribute name="id" select="concat(@id, '-false')"/>
          <xsl:attribute name="value" select="'false'"/>
          <xsl:attribute name="name" select="concat(../@id, @ep:in-set, count(preceding-sibling::qml:answer)+1)"/>
          <xsl:attribute name="type">radio</xsl:attribute>
          <xsl:attribute name="ep:role">radio</xsl:attribute>
        </xsl:element>
        <xsl:element name="label">
          <xsl:attribute name="for" select="concat(@id, '-false')"/>
          <xsl:attribute name="ep:role" select="'hidden-text'"></xsl:attribute>
          <xsl:value-of select="$locales/locale[@key='False']"/>
        </xsl:element>
      </xsl:element>
    </div>
  </xsl:template>
  
  <xsl:template match="qml:answer" mode="zj1zw1">
    <div ep:role="answer">
      <xsl:variable name="answer_id" select="@id"></xsl:variable>
      <xsl:apply-templates select="@ep:*"></xsl:apply-templates>
      <xsl:attribute name="data-correct" select="exists(tokenize(../qml:key/@answer, ',')[. = $answer_id])"></xsl:attribute>
      <input id="{@id}-id" value="{@id}" name="{../@id}{@ep:in-set}">
        <xsl:choose>
          <xsl:when test="parent::qml:item[@type='single-response']">
            <xsl:attribute name="type">radio</xsl:attribute>
            <xsl:attribute name="ep:role">radio</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="type">checkbox</xsl:attribute>
            <xsl:attribute name="ep:role">checkbox</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </input>
      <xsl:apply-templates select="qml:response|qml:hint"/>
    </div>
  </xsl:template>
  
  <xsl:template match="qml:answer">
    <div ep:role="answer">
      <xsl:element name="span">
        <xsl:attribute name="ep:role">answer-prefix</xsl:attribute>
        <xsl:value-of select="ep:get_qml_answer_prefix_for_qml(ancestor::qml:item, @id)"></xsl:value-of>
      </xsl:element>
      <xsl:choose>
      	<xsl:when test="parent::qml:item[@type='text-response']">
      	  <textarea id="{@id}-id" cols='30' rows='3'><xsl:text> </xsl:text></textarea> 
      	</xsl:when>
      	<xsl:otherwise>
      	  <input id="{@id}-id" value="{@id}" name="{../@id}">
      	    <xsl:choose>
      	      <xsl:when test="parent::qml:item[@type='single-response']">
            		<xsl:attribute name="type">radio</xsl:attribute>
      	        <xsl:attribute name="ep:role">radio</xsl:attribute>
            		<xsl:if test="../qml:key">
            		  <xsl:attribute name="onclick">showAnswer('<xsl:value-of select="../@id" />', '<xsl:value-of select="@id"/>', '<xsl:value-of select="../qml:key/@answer" />')</xsl:attribute>
            		</xsl:if>
            		<xsl:if test="not(../qml:key)">
            		  <xsl:attribute name="onclick">showAnswer('<xsl:value-of select="../@id" />', '<xsl:value-of select="@id"/>', 'no-key-present')</xsl:attribute>
            		</xsl:if>
      	      </xsl:when>
      	      <xsl:otherwise>
            		<xsl:attribute name="type">checkbox</xsl:attribute>
      	        <xsl:attribute name="ep:role">checkbox</xsl:attribute>
            		<xsl:attribute name="onclick">addMe('<xsl:value-of select="../@id"/>', this)</xsl:attribute>
      	      </xsl:otherwise>
      	    </xsl:choose>
      	  </input>
      	</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="qml:response|qml:hint" />
    </div>
  </xsl:template>

  <xsl:template match="qml:question">
    <xsl:element name="div">
      <xsl:attribute name="ep:role" select="local-name()"></xsl:attribute>
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template match="qml:response">
    <label for="{ancestor::qml:answer/@id}-id">
      <xsl:apply-templates/>
    </label>
  </xsl:template>
  
  <xsl:template match="qml:response" mode="zw2">
    <xsl:element name="span">
      <xsl:attribute name="ep:role" select="'response'"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="qml:response/cnx:section|qml:response/cnx:section/cnx:para">
    <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="qml:hint">
    <div ep:role="hint">
      <xsl:attribute name="id">hint<xsl:number level="single" count="qml:hint" format="0"/>_<xsl:value-of select="../@id" /></xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="qml:feedback|qml:key|qml:resource" />

  <xsl:template match="ep:config">
  </xsl:template>
  
  <xsl:template match="ep:behaviour|ep:presented-answers|ep:correct-in-set|ep:presentation-style|@type[parent::qml:item]|@ep:in-set">
    <xsl:attribute name="data-{local-name()}" select="."></xsl:attribute>
  </xsl:template>
  

</xsl:stylesheet>
