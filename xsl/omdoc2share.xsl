<?xml version="1.0" encoding="iso-8859-1"?>
<!-- An XSL style sheet for creating human-oriented output from 
     OMDoc (Open Mathematical Documents). It forms the basis for 
     the style sheets transforming OMDoc into html, mathml, TeX, 
     and Mathematica notebooks.
     URL: http://www.mathweb.org/omdoc/xsl/omdoc2share.dtd
     Copyright (c) 2001 Michael Kohlhase, 
     This style sheet is released under the Gnu Public License
     send bug-reports, patches, suggestions to omdoc@mathweb.org -->

<!-- Remarks: -->
<!-- 1.) Language-dependant elements are: 
         - CMP
         - commonname
         - dc:Title 
         - dc:Subject
         - dc:Description
         - dc:Translator
         - dc:Date
-->


<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:om="http://www.openmath.org/OpenMath"
  xmlns:dc="http://purl.org/DC"
  xmlns="http://www.mathweb.org/omdoc"
  version="1.0">  

<xsl:strip-space elements="*"/>

<!-- =============================== -->
<!-- declaration of input parameters -->
<!-- =============================== -->

<!-- 'TargetLanguage': default is en for xml:lang-attribute in 
     omdoc-output. It consists of whitespace separated, ordered list 
     of languages (example-call: TargetLanguage="en de fr")
     It is also valid in the imported stylesheets! 
     -->
<xsl:param name="TargetLanguage" select="'en'"/>

<!--<xsl:param name="locale" select="'http://www.mathweb.org/src/mathweb/omdoc/lib/locale-default.xml'"/>-->
<xsl:param name="locale" select="'locale.xml'"/>
<xsl:param name="report-errors" select="'no'"/> 


<!-- ============= omdoc basics ============= -->
<xsl:template match="*"/>

<!-- moved to omdoc2tex, which is the only one where it really matters
<xsl:template match="text()">
  <xsl:call-template name="safe">
    <xsl:with-param name="string" select="."/>
  </xsl:call-template>
</xsl:template> -->

<!-- ====================== Dublin Core Metadata ====================== -->

<xsl:template match="dc:Title|dc:Subject|dc:Description|dc:Date|dc:Translator">
  <xsl:variable name="valid_language">
    <xsl:call-template name="test-valid-language"/>
  </xsl:variable>
  <xsl:if test="$valid_language='true'">
    <xsl:apply-templates/>
  </xsl:if>
</xsl:template>



<!-- =========== Text Elements =========== -->


<xsl:template match="omtext">
  <xsl:variable name="type">
    <xsl:if test="@type!='general' and @type!='linkage'">
      <xsl:value-of select="@type"/>
    </xsl:if>
  </xsl:variable>
  <xsl:call-template name="do-begin-formenv">
    <xsl:with-param name="type" select="$type"/>
  </xsl:call-template>
  <xsl:call-template name="do-nl"/>
  <xsl:apply-templates select="CMP"/>
  <xsl:call-template name="do-end-formenv"/>
</xsl:template>


<xsl:template match="CMP">
  <xsl:variable name="valid_language">
    <xsl:call-template name="test-valid-language"/>
  </xsl:variable>
  <xsl:if test="$valid_language='true'"><xsl:apply-templates/></xsl:if>
</xsl:template>



<!-- now comes the presentation for the generic OpenMath elements,
     we begin with those that have share 'xref' attribute. Here the 
     algorithm is to process the xref in a template 'with-xref' and 
     then call the template in mode 'doit', if there is no xref -->

<xsl:template match="om:OMATTR|om:OMB|om:OMF|om:OMA|om:OMBIND|om:OMI|om:OMSTR|om:OMOBJ">
  <xsl:call-template name="with-xref"/>
</xsl:template>


<!-- for most, 'doit' is very simple -->
<xsl:template match="om:OMATTR|om:OMI|om:OMSTR" mode="doit">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="om:OMOBJ" mode="doit">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>

<xsl:template match="om:OMA" mode="doit">
  <xsl:apply-templates select="*[1]"/>
  <xsl:text>(</xsl:text>
  <xsl:for-each select="*[position()!=1]">
    <xsl:apply-templates select="."/>
    <xsl:if test="position()!=last()"><xsl:text>,</xsl:text></xsl:if>
  </xsl:for-each>
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="om:OMBIND" mode="doit">
  <xsl:text>(</xsl:text><xsl:apply-templates/><xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="om:OMF" mode="doit">
  <xsl:choose>
    <xsl:when test="@dec"><xsl:value-of select="format-number(@dec,'#')"/></xsl:when>
    <xsl:when test="@hex"><xsl:value-of select="format-number(@hex,'#')"/></xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="warning">
        <xsl:with-param name="string"
          select="'Must have xref, dec, or hex attribute to present an OMF'"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- generally, we disregard attribuitions, only if we want to process 
     them we have to declare that in a specialized template -->
<xsl:template match="om:OMATP" mode="doit">
  <xsl:call-template name="warning">
    <xsl:with-param name="string">
      <xsl:call-template name="warning">
        <xsl:with-param name="string" select="'Disregarding attributes'"/>
      </xsl:call-template>
      <!-- wait until we can determine even positions
           <xsl:for-each select="om:OMATP/om:OMS[position() is even]">
             <xsl:apply-templates select="."/>
           </xsl:for-each> -->
    </xsl:with-param>
  </xsl:call-template>  
</xsl:template>

<xsl:template match="om:OMB" mode="doit">
  <xsl:call-template name="warning">
    <xsl:with-param name="string" select="'Not formatting OM Byte Array element!'"/>
  </xsl:call-template>
</xsl:template>



<!-- ================= mode "locale" ========================== -->
<xsl:template match="key/value" mode="locale">
  <xsl:variable name="valid_language">
    <xsl:call-template name="test-valid-language"/>
  </xsl:variable>
  <xsl:if test="$valid_language='true'">
    <xsl:apply-templates mode="locale"/>
  </xsl:if>
</xsl:template>


<!-- now come the elements that do not have an 'xref' attribute -->
<xsl:template match="om:OMS">
  <xsl:variable name="uri">
    <xsl:text>#</xsl:text><xsl:value-of select="@name"/>
  </xsl:variable>
  <xsl:call-template name="print-symbol">
    <xsl:with-param name="print-form">
      <xsl:call-template name="do-print-symbol"/>
    </xsl:with-param>
    <xsl:with-param name="cd" select="@cd"/>
    <xsl:with-param name="name" select="@name"/>
    <xsl:with-param name="uri">
      <xsl:value-of select="$uri"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="om:OMV">
  <xsl:call-template name="do-print-variable"/>
</xsl:template>

<xsl:template match="om:OMBVAR">[<xsl:apply-templates/>]</xsl:template>

<xsl:template match="om:OME">
  <xsl:text>OM Error</xsl:text>
  <xsl:call-template name="warning">
    <xsl:with-param name="string" select="'Not formatting OM Error element'"/>
  </xsl:call-template>
</xsl:template>


<!-- =========== Math Elements =========== -->

<xsl:template match="assumption|conclusion">
  <xsl:call-template name="localize-self-br"/>
</xsl:template>

<xsl:template match="FMP">
  <xsl:choose>
    <xsl:when test="om:OMOBJ"><xsl:call-template name="localize-self-br"/></xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="do-nl"/>
      <xsl:call-template name="localize">
        <xsl:with-param name="key" select="'FMP'"/>
      </xsl:call-template><xsl:text>: </xsl:text>
      <xsl:for-each select="assumption">
        <xsl:call-template name="do-id-label"/>
        <xsl:apply-templates select="om:OMOBJ"/>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>|-</xsl:text>
      <xsl:apply-templates select="conclusion/om:OMOBJ"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="assertion">
  <xsl:call-template name="do-begin-formenv">
    <xsl:with-param name="type" select="@type"/>
   </xsl:call-template>
   <xsl:call-template name="do-nl"/>
   <xsl:apply-templates/>
   <xsl:call-template name="do-end-formenv"/>
</xsl:template>

<xsl:template match="proof">
  <xsl:call-template name="do-begin-formenv"/>
  <xsl:call-template name="do-nl"/>
  <xsl:apply-templates select="CMP"/>
  <xsl:call-template name="do-begin-list"/>
  <xsl:apply-templates select="child::node()[not(self::CMP)]"/>
  <xsl:call-template name="do-end-list"/>
  <xsl:call-template name="do-end-formenv"/>
</xsl:template>

<xsl:template match="proofobject">
  <xsl:call-template name="warning">
    <xsl:with-param name="string" select="'Not presenting proofobject'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="metacomment">
  <xsl:call-template name="do-begin-item"/>
  <xsl:apply-templates/>
  <xsl:call-template name="do-end-item"/>
</xsl:template>

<xsl:template match="derive|conclude|hypothesis">
  <!-- proofstep -->
  <xsl:call-template name="do-id-label"/>
  <xsl:call-template name="do-begin-item"/>
  <xsl:call-template name="do-begin-bold"/>
  <xsl:call-template name="localize">
    <xsl:with-param name="key" select="local-name()"/>
  </xsl:call-template>
  <xsl:call-template name="do-end-bold"/>
  <xsl:choose>
    <xsl:when test="local-name()='conclude' or local-name()='derive'">
      <xsl:apply-templates select="CMP" mode="omdocnode2html"/>
      <xsl:apply-templates select="FMP" mode="omdocnode2html"/>
      <xsl:text> </xsl:text>
      <!-- justification -->
      <xsl:if test="method">
        <xsl:call-template name="localize">
          <xsl:with-param name="key" select="'proven-by'"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="method" mode="omdocnode2html"/>
      </xsl:if>
      <xsl:if test="premise">
        <xsl:call-template name="localize">
          <xsl:with-param name="key" select="'from-premises'"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="premise"/>
      </xsl:if>
      <xsl:if test="proof">
        <xsl:apply-templates select="proof"/>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="do-end-item"/>
</xsl:template>

<xsl:template match="method">
  <xsl:apply-templates select="om:OMSTR|ref"/>
  <xsl:if test="parameter">
    <xsl:text>(</xsl:text>
    <xsl:call-template name="localize">
      <xsl:with-param name="key" select="'on-parameters'"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:for-each  select="parameter">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="parameter"><xsl:apply-templates/></xsl:template>

<xsl:template match="premise">
  <xsl:variable name="href" select="@href"/>
  <xsl:variable name="local" select="//*[@id=$href]"/>
  <xsl:call-template name="do-begin-crossref">
    <xsl:with-param name="uri">
      <xsl:text>#</xsl:text><xsl:value-of select="@href"/>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:choose>
    <xsl:when test="$local/@id!=''"><xsl:value-of select="$local/@id"/></xsl:when>
    <xsl:otherwise>
      <xsl:variable name="external" select="document(@href)//*[@id=$href]"/>
      <xsl:choose>
        <xsl:when test="$external!=''">
          <xsl:value-of select="$external"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="do-end-crossref"/>
</xsl:template>

<xsl:template match="example">
  <xsl:call-template name="do-begin-formenv"/>
  <xsl:apply-templates/>
  <xsl:call-template name="do-end-formenv"/>
</xsl:template>

<!--  =================== Theory elements ======================== -->
<xsl:template match="theory">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="symbol">
  <xsl:call-template name="do-begin-formenv"/>
  <xsl:variable name="id" select="@id"/>
  <xsl:for-each select="../definition[@for=$id]">
    <xsl:call-template name="cr-def"/>
  </xsl:for-each>
  <xsl:for-each select="//alternative-def[@for=$id]">
    <xsl:call-template name="cr-def"/>
  </xsl:for-each>
  <xsl:apply-templates select="child::node()[not(self::CMP or self::commonname)]"/>
  <xsl:call-template name="do-nl"/>
  <xsl:apply-templates select="CMP"/>
  <xsl:call-template name="do-end-formenv"/>
</xsl:template>
<xsl:template match="proof/symbol"/>

<xsl:template match="commonname">
  <xsl:param name="simple" select="'no'"/>
  <xsl:variable name="valid_language">
    <xsl:call-template name="test-valid-language"/>
  </xsl:variable>
  <xsl:if test="$valid_language='true'">
    <xsl:choose>
      <xsl:when test="$simple='yes'">
        <xsl:call-template name="safe">
          <xsl:with-param name="string" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="localize-self-br"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="signature"/>

<xsl:template match="type">
  <xsl:call-template name="do-nl"/>
  <xsl:call-template name="localize">
    <xsl:with-param name="key" select="'type'"/>
  </xsl:call-template>
  <xsl:text> (</xsl:text><xsl:value-of select="@system"/><xsl:text>): </xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="axiom">
  <xsl:call-template name="do-begin-formenv"/>
  <xsl:call-template name="do-nl"/>
  <xsl:apply-templates/>
  <xsl:call-template name="do-end-formenv"/>
</xsl:template>

<xsl:template match="definition|alternative-def">
  <xsl:call-template name="do-begin-formenv"/>
  <xsl:apply-templates/>
  <xsl:call-template name="do-end-formenv"/>
</xsl:template>

<xsl:template match="requation">
  <xsl:call-template name="do-nl"/>
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>

<xsl:template match="requation" mode="inner">
  <xsl:apply-templates select="pattern"/>
  <xsl:text>=</xsl:text>
  <xsl:apply-templates select="value"/>
</xsl:template>

<xsl:template match="pattern|value"><xsl:apply-templates/></xsl:template>


<!-- ================== Theory structure ========================= -->

<xsl:template match="axiom-inclusion|theory-inclusion|path-just|assertion-just|decomposition"/>

<!-- ================== abstract datatypes ======================= -->

<xsl:template match="adt|sortdef|constructor|argument|insort|selector"/>

<!-- =================== inheritance ============================= -->

<xsl:template match="imports|morphism|inclusion"/>

<!--  ================== Auxiliary elements ====================== -->

<xsl:template match="exercise">
  <xsl:call-template name="do-begin-formenv"/>
  <xsl:call-template name="do-nl"/>
  <xsl:apply-templates select="child::node()[not(self::mc)]"/>
  <xsl:if test="mc">
    <xsl:call-template name="do-begin-mcgroup"/>
    <xsl:apply-templates select="mc"/>
    <xsl:call-template name="do-end-mcgroup"/>
  </xsl:if>
  <xsl:call-template name="do-end-formenv"/>
</xsl:template>

<xsl:template match="hint">
  <xsl:call-template name="localize-self"/>
  <!-- <input type=button value="Hint!" name="onClick"/> -->
</xsl:template>

<xsl:template match="solution">
  <xsl:call-template name="localize-self"/>
</xsl:template>


<xsl:template match="choice">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="answer">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="omlet[@type='java']">
 <xsl:value-of select="text()" disable-output-escaping="yes"/>
</xsl:template>

<xsl:template match="omlet[@type='js']">
 <xsl:variable name="function" select="attribute::function"/>
 <xsl:apply-templates/>
</xsl:template>

<xsl:template match="omlet[@type='oz']">
  <xsl:call-template name="do-begin-crossref">
    <xsl:with-param name="uri" select="//code[@id=current()/@function]/data/@href"/>
  </xsl:call-template>
  <xsl:apply-templates/>
  <xsl:call-template name="do-end-crossref"/>
</xsl:template>

<xsl:template match="private">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="output|effect|output">
  <xsl:call-template name="localize-self-br"/>
</xsl:template>

<xsl:template match="presentation"/>

<!-- ===== here come the named templates ===== -->

  <!-- this computes the valid language from a set of given languages
       it is the first among those in $TargetLanguage that is also in 
       $given -->
  <xsl:template name="compute-valid-language">
   <!-- given is a whitespace-separated list of ISO637 language codes -->
   <xsl:param name="given"/>
   <xsl:param name="langs" select="$TargetLanguage"/>
   <xsl:choose>
    <xsl:when test="$langs=''"/>
    <xsl:otherwise>
     <xsl:variable name="first">
      <xsl:choose>
       <xsl:when test="contains($langs,' ')">
        <xsl:value-of select="substring-before($langs,' ')"/>
       </xsl:when>
       <xsl:otherwise><xsl:value-of select="$langs"/></xsl:otherwise>
      </xsl:choose>
     </xsl:variable>
     <xsl:variable name="rest">
      <xsl:choose>
       <xsl:when test="contains($langs,' ')">
        <xsl:value-of select="substring-after($langs,' ')"/>
       </xsl:when>
       <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
      </xsl:choose>
     </xsl:variable>
     <xsl:choose>
      <xsl:when test="contains($given,$first)"><xsl:value-of select="$first"/></xsl:when>
      <xsl:otherwise>
       <xsl:call-template name="compute-valid-language">
        <xsl:with-param name="given" select="$given"/>
        <xsl:with-param name="langs" select="$rest"/>
       </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>

<xsl:template name="test-valid-language">
  <xsl:variable name="nodename"><xsl:value-of  select="local-name()"/></xsl:variable>
  <xsl:variable name="language"><xsl:value-of  select="@xml:lang"/></xsl:variable>
  <xsl:variable name="siblings-nodeset" select="preceding-sibling::node()[local-name()=$nodename]|following-sibling::node()[local-name()=$nodename]"/>
  <!-- Test, whether this node is among the wanted ones (in terms of language). -->
  <xsl:if test="contains($TargetLanguage,$language)">
    <!-- Test, whether other nodes don't have higher priority language-values -->
    <xsl:if test="not($siblings-nodeset[contains(substring-before($TargetLanguage,$language),@xml:lang)])">
      <!-- Test, whether this node is the only valid one (in terms 
           of language). If not, it is nevertheless a valid one and will 
           be written to the result-tree-->
      <xsl:if test="$language=$siblings-nodeset/@xml:lang">
        <xsl:call-template name="localized-error">
          <xsl:with-param name="key" select="'two-cmp-error'"/>
          <xsl:with-param name="id" select="../@id"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:value-of select="true()"/>
    </xsl:if> 
  </xsl:if>
</xsl:template>


<xsl:template name="with-xref">
  <xsl:choose>
    <!-- If there is an xref attribute, we apply the templates 
         on the orgininal, otherwise we apply the templates in 
         mode 'doit', which do the actual presentation. -->
    <xsl:when test="@xref">
      <xsl:variable name="ref" select="@xref"/>
      <xsl:apply-templates select="//*[@id=$ref]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="doit"/>
      </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="localized-error">
  <xsl:param name="key"/>
  <xsl:param name="id"/>
  <xsl:if test="$report-errors!='no'">
    <xsl:message>
      <xsl:variable name="error_message">
        <xsl:call-template name="localize">
          <xsl:with-param name="key" select="$key"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$error_message=''">
          <xsl:call-template name="warning">
            <xsl:with-param name="string">
              <xsl:text>Could not find the localized error message for </xsl:text>
              <xsl:value-of select="$key"/>
              <xsl:text>.&#xA;Tried languages:'</xsl:text>
              <xsl:value-of select="$TargetLanguage"/>
              <xsl:text>'.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$error_message"/>
          <xsl:value-of select="$id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:message>
  </xsl:if>
</xsl:template>

<xsl:template name="error">
  <xsl:param name="string"/>
  <xsl:if test="$report-errors!='no'">
    <xsl:message>Error: <xsl-value-of select="$string"/></xsl:message>
  </xsl:if>
</xsl:template>

<xsl:template name="warning">
  <xsl:param name="string"/>
  <xsl:if test="$report-errors!='no'">
    <xsl:message>Warning: <xsl-value-of select="$string"/></xsl:message>
  </xsl:if>
</xsl:template>


<xsl:template name="localize-self-br">
  <xsl:call-template name="do-nl"/>
  <xsl:if test="@id">
    <xsl:call-template name="do-id-label"/>
  </xsl:if>
  <xsl:call-template name="localize">
    <xsl:with-param name="key" select="local-name()"/>
  </xsl:call-template>
  <xsl:text> </xsl:text>
  <xsl:apply-templates/>
  <xsl:text>&#xA;</xsl:text>
</xsl:template>


<xsl:template name="localize-self">
  <xsl:if test="@id"><xsl:call-template name="do-id-label"/></xsl:if>
  <xsl:call-template name="localize">
    <xsl:with-param name="key" select="local-name()"/>
  </xsl:call-template>
  <xsl:text> </xsl:text>
  <xsl:apply-templates/>
</xsl:template>


<xsl:template name="do-begin-formenv">
  <xsl:param name="type" select="local-name()"/>
  <xsl:variable name="ffor">
    <xsl:if test="//*[@id=current()/@for]">#</xsl:if>
    <xsl:call-template name="safe">
      <xsl:with-param name="string" select="@for"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="do-id-label"/>
  <xsl:call-template name="do-begin-omdocenv">
    <xsl:with-param name='type'>
      <xsl:if test="local-name()='omtext'">
	<xsl:value-of select="$type"/>
      </xsl:if>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:if test="$type!=''">
    <xsl:call-template name="do-begin-bold"/>
    <xsl:call-template name="localize">
      <xsl:with-param name="key" select="$type"/>
    </xsl:call-template>
    <xsl:call-template name="do-end-bold"/>
  </xsl:if>
  <xsl:if test="$ffor!=''">
    <xsl:text> </xsl:text>
    <xsl:call-template name="localize">
      <xsl:with-param name="key" select="'for'"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:call-template name="do-begin-crossref">
      <xsl:with-param name="uri" select="$ffor"/>
    </xsl:call-template>
    <xsl:call-template name="safe">
      <xsl:with-param name="string" select="@for"/>
    </xsl:call-template>
    <xsl:call-template name="do-end-crossref"/>
    <xsl:text> </xsl:text>
  </xsl:if>
  <!-- Remark: Since the metadata are language-dependant, 
       this named template contains "apply-templates" -->
  <xsl:call-template name="insert-simple-metadata"/>
</xsl:template>

<xsl:template name="do-end-formenv">
  <xsl:call-template name="do-end-omdocenv"/>
</xsl:template>


<xsl:template name="cr-def">
  <xsl:text>(</xsl:text>
  <xsl:call-template name="do-begin-crossref">
    <xsl:with-param name="uri">
      <xsl:text>#</xsl:text><xsl:value-of select="@id"/>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="localize">
    <xsl:with-param name="key" select="'definition'"/>
  </xsl:call-template>
  <!--  <xsl:text> </xsl:text><xsl:value-of select="position()"/> -->
  <xsl:call-template name="do-end-crossref"/>
  <xsl:text>)</xsl:text>
</xsl:template>


<xsl:template name="insert-simple-metadata">
  <xsl:text> (</xsl:text>
  <xsl:choose>
    <xsl:when test="metadata/dc:Title">
      <xsl:apply-templates select="metadata/dc:Title"/>
    </xsl:when>
    <xsl:when test="commonname">
      <xsl:apply-templates select="commonname">
        <xsl:with-param name="simple" select="'yes'"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="safe">
        <xsl:with-param name="string" select="@id"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>) </xsl:text>
  <xsl:if test="metadata/dc:Creator">
    <xsl:text> [</xsl:text>
    <xsl:apply-templates select="metadata/dc:Creator"/>
    <xsl:text>] </xsl:text>
  </xsl:if>
</xsl:template>

<!-- This template will print a symbol based on the specification given by
     the parameters 'print-form', 'cd', 'name', and 'crossref-symbol'.
     It facilitates printing symbols with crossreferences to their definitions.
     If 'crossref-symbol' has the value 't', then it will look up the URL of the 
     presentation of the defining OMDoc (as specified by the catalogue mechanism 
     for the theory 'cd'), and print the value of 'print-form' with a hyperlink 
     (if the format permits) to the determined URL. -->
<xsl:template name="print-symbol">
 <xsl:param name="print-form"/>
 <xsl:param name="crossref-symbol" select="'yes'"/>
 <xsl:param name="uri"/>
 <xsl:choose>
  <xsl:when test="$uri!=''">
   <xsl:if test="$crossref-symbol='yes' or $crossref-symbol='all'">
    <xsl:call-template name="do-begin-crossref">
     <xsl:with-param name="uri" select="$uri"/>
    </xsl:call-template>
   </xsl:if>
   <xsl:copy-of select="$print-form"/>
   <xsl:if test="$crossref-symbol='yes' or $crossref-symbol='all'">
    <xsl:call-template name="do-end-crossref"/>
   </xsl:if>
  </xsl:when>
  <xsl:otherwise><xsl:copy-of select="$print-form"/></xsl:otherwise>
 </xsl:choose>
</xsl:template>



<xsl:variable name="loc" select="document($locale)"/>
<!-- this template looks up the value of the 'key' parameter for the given 
     $TargetLanguage-list, otherwise it gives a localized error message -->
<xsl:template name="localize">
 <xsl:param name="key" select="'no-value-error'"/>
 <xsl:variable name="result">
  <xsl:apply-templates select="$loc/locale/key[@name=$key]/value" mode="locale"/>
 </xsl:variable>
 <xsl:choose>
  <xsl:when test="not($result='')">
   <xsl:value-of select="$result"/>
  </xsl:when>
  <xsl:when test="$result=''">
   <xsl:call-template name="localized-error">
    <xsl:with-param name="key" select="'no-value-error'"/>
    <xsl:with-param name="id" select="$key"/>
   </xsl:call-template>
  </xsl:when>
 </xsl:choose>
</xsl:template>


<!-- %%%%%%%%%%%%%%%%%%%%%%%% to be specialized %%%%%%%%%%%%%%%%%%%%%%%%%
     the following template are just a generic one that should be defined
     in the style sheets that inherit form this one. -->

<!-- 'do-nl' does a format-specific newline -->
<xsl:template name="do-nl"/>

<!--  'safe' escapes any offending charaters in a safe way -->
<xsl:template name="safe">
 <xsl:param name="string"/>
 <xsl:value-of select="$string"/>
</xsl:template>

<xsl:template name="print-fence">
 <xsl:param name="fence"/>
 <xsl:value-of select="$fence"/>
</xsl:template>

<xsl:template name="print-separator">
 <xsl:param name="separator"/>
 <xsl:value-of select="$separator"/>
</xsl:template>

</xsl:stylesheet>



