<!-- An XSL style sheet for creating xsl style sheets for presenting 
     OpenMath Symbols from OMDoc presentation elements.
     Copyright (c) 2000, 2001 Michael Kohlhase, 
     This style sheet is released under the Gnu Public License
     Initial version 20000824 by Michael Kohlhase, 
     send bug-reports, patches, suggestions to omdoc@mathweb.org
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://icl.com/saxon" 
  extension-element-prefixes="saxon"
  xmlns:out="output.xsl"
  xmlns:xmlns="http://www.w3.org"
  xmlns:om="http://www.openmath.org/OpenMath"
  xmlns:dc="http://www.purl.org/DC" 
  xmlns:outns="outns.xsl"
  version="1.0">

<xsl:param name="baseuri"/>
<xsl:param name="format"/>

<xsl:output method="xml" version="1.0" indent="yes" standalone="yes"/>
<xsl:strip-space elements="*"/>

<xsl:namespace-alias stylesheet-prefix="out" result-prefix="xsl"/>
<xsl:namespace-alias stylesheet-prefix="outns" result-prefix="xmlns"/>


<!-- the top-level template prints the header of the XSL style sheet. -->

<xsl:template match="/">
  <xsl:comment>
    An XSL style sheet for presenting OpenMath Symbols used in the 
    OpenMath Document (OMDoc) <xsl:value-of select="omdoc/@id"/>.omdoc.
     
    This XSL style file is automatically generated from an OMDoc document, do not edit!
  </xsl:comment>
  <xsl:text>&#xA;&#xA;</xsl:text>
  <out:stylesheet version="1.0">
    <xsl:text>&#xA;</xsl:text>
    <out:strip-space elements="*"/>
    <xsl:text>&#xA;</xsl:text>
    <out:output method="html"/>
    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:apply-templates select="omdoc//presentation"/>
</out:stylesheet>
<xsl:text>&#xA;</xsl:text>
</xsl:template>


<!-- the template for the OMDoc presentation element produces an XSL 
     template in two parts: 
     - first it makes the pattern of the template depending on the 
       parent element, 
     - and then the body depending on fixity and brackets. -->
<xsl:template match="presentation">
  <xsl:param name="crossref"/>
  <xsl:param name="name" select="@for"/>
  <xsl:param name="cd">
    <xsl:choose>
      <xsl:when test="ancestor::theory/@id"><xsl:value-of select="ancestor::theory/@id"/> </xsl:when>
      <xsl:when test="@theory"><xsl:value-of select="@theory"/></xsl:when>
      <xsl:otherwise>
        <xsl:message>unable to infer theory of presentation element <xsl:value-of select="@id"/>!</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:variable name="xref" select="@xref"/>
  <xsl:variable name="file" select="substring-before($xref,'#')"/>
  <xsl:variable name="id" select="substring-after($xref,'#')"/>
  <xsl:variable name="req" select="@requires"/>
  <xsl:variable name="defs" select="//private[@id=$req]/data"/>
  <xsl:if test="$defs!=''">
    <out:text><xsl:value-of select="$defs"/><xsl:text>&#xA;</xsl:text></out:text>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="$xref!=''">
      <xsl:apply-templates 
        select="saxon:node-set(document($xref)//presentation[@id=$id])">
        <xsl:with-param name="crossref">
          <xsl:value-of select="$baseuri"/>
          <xsl:text>#</xsl:text>
          <xsl:value-of select="@for"/>
        </xsl:with-param>
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="cd" select="$cd"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:when test="@parent">
      <out:template priority="1" match="om:{@parent}[om:OMS[position()=1 and @name='{$name}' and @cd='{$cd}']]">
        <out:param name="prec" select="1000"/>
        <xsl:choose>
          <xsl:when test="$crossref=''">
            <out:variable name="crossref" select="'{$baseuri}#{$name}'"/>
          </xsl:when>
          <xsl:otherwise>
            <out:variable name="crossref" select="'{$crossref}'"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="do-inner"/>
      </out:template>
    </xsl:when>
    <xsl:otherwise>
      <out:template priority="1" match="om:OMS[@name='{$name}' and @cd='{$cd}']">
        <xsl:choose>
          <xsl:when test="$crossref=''">
            <out:variable name="crossref" select="'{$baseuri}#{$name}'"/>
          </xsl:when>
          <xsl:otherwise>
            <out:variable name="crossref" select="'{$crossref}'"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="do-inner"/>
      </out:template>
      <xsl:text>&#xA;&#xA;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="do-inner">
 <!-- the use elements that are relevant to this format -->
 <xsl:variable name="use-format" 
  select="use[@format=$format or 
          (@format='default' and not(../use[@format=$format]))]"/>
 <xsl:variable name="usef" select="saxon:node-set($use-format)"/>
 <!-- the set of languages given for this format as a whitespace-separated list -->
 <xsl:variable name="given">
  <xsl:text>'</xsl:text>
  <xsl:for-each select="$usef/@xml:lang">
   <xsl:value-of select="."/>
   <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
  </xsl:for-each>
  <xsl:text>'</xsl:text>
 </xsl:variable>
 <xsl:choose>
  <xsl:when test="count($usef) = 0"/>
  <xsl:when test="count($usef) = 1"><xsl:apply-templates select="$usef"/></xsl:when>
  <xsl:otherwise>
   <out:variable name="valid-lang">
    <out:call-template name="compute-valid-language">
     <out:with-param name="given"><xsl:value-of select="$given"/></out:with-param>
   </out:call-template>
   </out:variable>
   <out:choose>
    <xsl:for-each select="$usef">
     <out:when test="$valid-lang='{@xml:lang}'">
      <xsl:apply-templates select="."/>
     </out:when>
    </xsl:for-each>
    <out:otherwise>
     <out:message>would like to do fallback behavior here for <xsl:value-of select="@for"/>!</out:message>
    </out:otherwise>
   </out:choose>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="use[../@parent='OMA' or ../@parent='OMBIND']">
  <xsl:choose>
    <xsl:when test="@system='xsl'">
      <xsl:copy-of select="*"/>
    </xsl:when>
    <xsl:when test="../@fixity='prefix' or ../@fixity='postfix'">
      <xsl:call-template name="print-prepost"/>
    </xsl:when>
    <xsl:when test="../@fixity='infix'">
      <xsl:call-template name="print-infix"/>
    </xsl:when>
    <xsl:when test="../@fixity='assoc'">
      <xsl:call-template name="print-assoc"/>
    </xsl:when>
    <xsl:otherwise><xsl:message>Unrecognized fixity!</xsl:message></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="use[../@parent='OMATTR']">
  <xsl:call-template name="print-lbrack"/>
  <xsl:choose>
    <xsl:when test="../@fixity='prefix'">
      <xsl:call-template name="do-args">
        <xsl:with-param name="path" select="'om:OMATP/*[2]'"/>
      </xsl:call-template>
      <out:call-template name="print-separator">
        <out:with-param name="separator">
          <xsl:value-of select="@separator"/>
        </out:with-param>
      </out:call-template>
      <xsl:call-template name="do-args">
        <xsl:with-param name="path" select="'*[2]'"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="../@fixity='postfix'">
      <xsl:call-template name="do-args">
        <xsl:with-param name="path" select="'*[2]'"/>
      </xsl:call-template>
      <out:text disable-output-escaping="yes"><xsl:value-of select="@separator"/></out:text>
      <xsl:call-template name="do-args">
        <xsl:with-param name="path" select="'om:OMATP/*[2]'"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:message>Unrecognized fixity!</xsl:message></xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="print-rbrack"/>
</xsl:template>

<xsl:template match="use[not(../@parent)]">
  <xsl:call-template name="print-crossref-symbol"/>
</xsl:template>

<!-- This template composes the treatment for an argument of a
     function. It basically takes care of the argument bracketing
     specified in larg-group and rarg-group. -->
<xsl:template name="do-args">
  <xsl:param name="path"/>
  <!-- just to be safe, in TeX, we add another brace-->
  <xsl:if test="$format='TeX'"><out:text>{</out:text></xsl:if>
  <xsl:choose>
    <xsl:when test="@larg-group">
      <out:text disable-output-escaping="yes"><xsl:value-of select="@larg-group"/></out:text>
    </xsl:when>
    <xsl:when test="../@larg-group">
      <out:text disable-output-escaping="yes"><xsl:value-of select="../@larg-group"/></out:text>
    </xsl:when>
  </xsl:choose>
  <out:apply-templates select="{$path}">
    <xsl:if test="../@precedence">
      <out:with-param name="prec" select="{../@precedence}"/>
    </xsl:if>
  </out:apply-templates>
  <xsl:choose>
    <xsl:when test="@rarg-brack">
      <out:text disable-output-escaping="yes"><xsl:value-of select="@rarg-brack"/></out:text>
    </xsl:when>
    <xsl:when test="../@rarg-brack">
      <out:text disable-output-escaping="yes"><xsl:value-of select="../@rarg-brack"/></out:text>
    </xsl:when>
  </xsl:choose>
  <!-- just to be safe, in TeX, we add another brace-->
  <xsl:if test="$format='TeX'"><out:text>}</out:text></xsl:if>
</xsl:template>


<!-- the next set of templates prints the crossref-symbol, i.e. if the 
     crossref-symbol switch is 't', then it constructs the crossref, 
     whereever possible, (depending on the format).
     It calls the template 'print-symbol' with the right format, so that this
     can be overwritten by another style sheet  -->

<xsl:template name="print-crossref-symbol">
  <xsl:variable name="cd" select="../../@id"/>
  <xsl:variable name="name" select="../@for"/>
  <out:call-template name="print-symbol">
    <out:with-param name="print-form">
      <xsl:choose>
        <xsl:when test="@system='xsl'">
          <xsl:copy-of select="*"/>
        </xsl:when>
        <xsl:otherwise>
          <out:text disable-output-escaping="yes">
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
            <xsl:value-of select="." disable-output-escaping="yes"/>
            <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
          </out:text>
        </xsl:otherwise>
      </xsl:choose>
    </out:with-param>
    <out:with-param name="crossref-symbol">
     <xsl:choose>
      <xsl:when test="@crossref-symbol">
       <xsl:value-of select="@crossref-symbol"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="../@crossref-symbol"/>
      </xsl:otherwise>
     </xsl:choose>
    </out:with-param>
    <out:with-param name="uri" select="$crossref"/>
  </out:call-template>
</xsl:template>

<!-- the next template makes style sheet stuff for printing a 
     function of on n arguments, depending on the fixity, bracket-style,
     and separator attributes:
     prefix and lisp:  (f 1 2 3)
     postfix and lisp: (1 2 3 f)
     prefix and math:  f(1,2,3)
     postfix and math: (1,2,3)f -->

<xsl:template name="print-prepost">
  <xsl:if test="../@fixity='prefix'">
    <xsl:if test="../@bracket-style='lisp'">
      <xsl:call-template name="print-lbrack"/>
    </xsl:if>
    <xsl:call-template name="print-crossref-symbol"/>
  </xsl:if>
  <xsl:if test="../@bracket-style='math' or ../@fixity='postfix'">
    <xsl:call-template name="print-lbrack"/>
  </xsl:if>
  <out:for-each select="*[position()!=1]">
    <xsl:call-template name="do-args">
      <xsl:with-param name="path" select="'.'"/>
    </xsl:call-template>
    <out:if test="position()!=last()">
      <out:text disable-output-escaping="yes"><xsl:value-of select="../@separator"/></out:text>
    </out:if>
  </out:for-each>
  <xsl:if test="../@bracket-style='math' or ../@fixity='prefix'">
    <xsl:call-template name="print-rbrack"/>
  </xsl:if>
  <xsl:if test="../@fixity='postfix'">
    <xsl:call-template name="print-crossref-symbol"/>
    <xsl:if test="../@bracket-style='lisp'">
      <xsl:call-template name="print-rbrack"/>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template name="print-assoc">
  <xsl:call-template name="print-lbrack"/>
  <out:for-each select="*[position()!=1]">
    <xsl:call-template name="do-args">
      <xsl:with-param name="path" select="'.'"/>
    </xsl:call-template>
    <out:if test="position()!=last()">
      <xsl:call-template name="print-crossref-symbol"/>
    </out:if>
  </out:for-each>
  <xsl:call-template name="print-rbrack"/>
</xsl:template>


<xsl:template name="print-infix">
  <xsl:call-template name="print-lbrack"/>
  <xsl:call-template name="do-args">
    <xsl:with-param name="path" select="'*[2]'"/>
  </xsl:call-template>
  <xsl:call-template name="print-crossref-symbol"/>
  <xsl:call-template name="do-args">
    <xsl:with-param name="path" select="'*[3]'"/>
  </xsl:call-template>
  <xsl:call-template name="print-rbrack"/>
</xsl:template>

<!-- the next templates make style sheet stuff for printing a bracket 
     depending on the object-level bracket-hints. -->
<xsl:template name="print-rbrack">
  <xsl:choose>
    <xsl:when test="../@precedence">
      <out:if test="$prec &lt;={../@precedence}">
        <xsl:call-template name="print-rbrack-inner"/>
      </out:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="print-rbrack-inner"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="@element">
    <out:text disable-output-escaping="yes">
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="@element"/>
      <xsl:text>&gt;</xsl:text>
    </out:text>
  </xsl:if>
</xsl:template>

<xsl:template name="print-lbrack">
  <xsl:if test="@element">
    <out:text disable-output-escaping="yes">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="@element"/>
      <xsl:if test="@attributes">
        <xsl:text> </xsl:text>
        <xsl:value-of select="@attributes" disable-output-escaping="yes"/>
      </xsl:if>
      <xsl:text>&gt;</xsl:text>
    </out:text>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="../@precedence">
      <out:if test="$prec &lt;={../@precedence}">
        <xsl:call-template name="print-lbrack-inner"/>
      </out:if>
    </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="print-lbrack-inner"/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="print-lbrack-inner">
  <xsl:variable name="open">
    <xsl:choose>
      <xsl:when test="@lbrack=''"><xsl:value-of select="''"/></xsl:when>
      <xsl:when test="not(@lbrack)"><xsl:value-of select="../@lbrack"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="@lbrack"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:if test="$open!=''">
    <out:call-template name="print-fence">
      <out:with-param name="fence">
        <xsl:value-of select="$open"/>
      </out:with-param>
    </out:call-template>
  </xsl:if>
</xsl:template>


<xsl:template name="print-rbrack-inner">
  <xsl:variable name="close">
    <xsl:choose>
      <xsl:when test="@rbrack=''"><xsl:value-of select="''"/></xsl:when>
      <xsl:when test="not(@rbrack)"><xsl:value-of select="../@rbrack"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="@rbrack"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:if test="$close!=''">
    <out:call-template name="print-fence">
      <out:with-param name="fence">
        <xsl:value-of select="$close"/>
      </out:with-param>
    </out:call-template>
  </xsl:if>
</xsl:template>



</xsl:stylesheet>




