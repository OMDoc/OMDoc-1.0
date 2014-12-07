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

<!-- the format of presentation it uses -->
<xsl:param name="format"/>
<xsl:param name="basename"/>
<xsl:variable name="self" select="substring-before(saxon:system-id(),'.omdoc')"/>

<xsl:variable name="formats" select="saxon:tokenize($format,'|')"/>

<xsl:output method="xml" version="1.0" indent="yes" standalone="yes"/>
<xsl:strip-space elements="*"/>

<xsl:namespace-alias stylesheet-prefix="out" result-prefix="xsl"/>
<xsl:namespace-alias stylesheet-prefix="outns" result-prefix="xmlns"/>

<!-- we will first find a set $cdus of symbols, whose cd attributes are unique -->
<xsl:variable name="cdus" select="saxon:distinct(//om:OMS/@cd)/.."/>
<!-- fallback <xsl:variable name="cdus" select="//om:OMS[not(@cd=preceding::om:OMS/@cd)]"/>-->
<!-- then we build the local catalogue and put it in  a variable -->
<xsl:variable name="tree">
  <catalogue>
    <xsl:copy-of select="omdoc/catalogue/*"/>
    <xsl:call-template name="make-external">
      <!-- call it on those symbols whose symbol definition is not in this document, and that are not mentioned 
           in the local catalogue -->
      <xsl:with-param name="externals" select="$cdus[not(@cd=//theory/@id) and not(@cd=omdoc/catalogue/loc/@theory)]"/>
      <xsl:with-param name="document" select="/"/>
    </xsl:call-template>
  </catalogue>
</xsl:variable>
<xsl:variable name="href-cat" select="saxon:node-set($tree)"/> 

<xsl:variable name="here" select="/"/>

<!-- the top-level template prints the header of the XSL style sheet. -->
<xsl:template match="/">
  <xsl:for-each select="$formats">
    <xsl:variable name="form" select="."/>
    <saxon:output file="{$basename}I{$form}.xsl">
      <xsl:text>&#xA;&#xA;</xsl:text>
      <xsl:comment>
        An XSL style sheet for presenting OpenMath Symbols used in the 
        OpenMath Document (OMDoc) <xsl:value-of select="/omdoc/@id"/>.omdoc.
      
        This XSL style file is automatically generated from the OpenMath Document
      "<xsl:value-of select="/omdoc/metadata/dc:Title"/>", do not edit!
      </xsl:comment>
      <xsl:text>&#xA;&#xA;</xsl:text>
      <out:stylesheet 
        outns:saxon="http://icl.com/saxon" 
        version="1.0" 
        extension-element-prefixes="saxon">
        <xsl:text>&#xA;</xsl:text>
        <out:strip-space elements="*"/>
        <xsl:text>&#xA;</xsl:text>
        <out:output method="html"/>
        <xsl:text>&#xA;&#xA;</xsl:text>
        <out:include href="{$self}4{$form}.xsl"/>
        <xsl:for-each 
          select="saxon:distinct($href-cat/catalogue/loc[@theory!='']/@omdoc)">
          <out:include href="{substring-before(.,'.omdoc')}4{$form}.xsl"/>
        </xsl:for-each>
      </out:stylesheet>
      <xsl:text>&#xA;</xsl:text>
    </saxon:output>
  </xsl:for-each>
</xsl:template>

<xsl:template match="*"/>

<xsl:template name="make-external">
  <xsl:param name="externals"/>
  <xsl:param name="document"/>
  <xsl:variable name="incat" 
    select="$externals[@cd=$document/omdoc/catalogue/loc/@theory]"/>
  <xsl:variable name="rest" select="saxon:difference($externals,$incat)"/>    
  <xsl:for-each select="$incat">
    <xsl:variable name="cd" select="@cd"/>
    <xsl:variable name="uri">
      <xsl:variable name="omdoc" select="$document/omdoc/catalogue/loc[@theory=$cd]/@omdoc"/>
      <xsl:value-of select="substring-before($omdoc,'.omdoc')"/>
    </xsl:variable>
    <xsl:if test="$uri!=''">
      <loc theory="{$cd}" omdoc="{$uri}.omdoc"/>
    </xsl:if>
  </xsl:for-each>
  <xsl:if test="$rest">
    <xsl:choose>
      <!-- if there is a catalogue specified in the <omdoc> element -->
      <xsl:when test="$document/omdoc/@catalogue!=''">
        <xsl:call-template name="make-external">
          <xsl:with-param name="externals" select="$rest"/>
          <xsl:with-param name="document"
            select="document($document/omdoc/@catalogue,$document)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Cannot find locations for the theories 
        <xsl:for-each select="$rest">
          <xsl:value-of select="@cd"/>
          <xsl:if test="position()!=last()">,</xsl:if>
        </xsl:for-each>!</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>


</xsl:stylesheet>




