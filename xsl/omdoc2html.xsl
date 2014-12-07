<?xml version="1.0" encoding="iso-8859-1"?>
<!-- An XSL style sheet for creating html from OMDoc (Open 
     Mathematical Documents). 
     URL: http://www.mathweb.org/omdoc/xsl/omdoc2html.dtd
     Copyright (c) 2000, 2001 Michael Kohlhase, 
     This style sheet is released under the Gnu Public License
     send bug-reports, patches, suggestions to omdoc@mathweb.org -->

<!-- Assumptions:
     1.) The file $css_file exists, i.e. '..\lib\omdoc-default.css'.
     -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:om="http://www.openmath.org/OpenMath"
  xmlns:dc="http://purl.org/DC"
  xmlns="http://www.mathweb.org/omdoc"
  version="1.0">  
<xsl:import href="omdoc2share.xsl"/>
<xsl:variable name="format" select="'html'"/>

<xsl:output method="xml" 
            indent="yes" 
            doctype-public="'-//W3C//DTD XHTML 1.0 Strict//EN'"/>

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

<!-- 'css_file': determines the css-stylesheet to be connected
     with the html-output -->
<xsl:param name="css" select="'http://www.mathweb.org/src/mathweb/omdoc/lib/omdoc-default.css'"/>

<!-- =============================== -->
<!-- declaration of global variables -->
<!-- =============================== -->



<!-- ============= omdoc basics ============= -->

<!-- The root: Get the title and apply the omdoc-template -->
<xsl:template match="/">
  <xsl:comment>
    <xsl:call-template name="localize">
      <xsl:with-param name="key" select="'boilerplate'"/>
    </xsl:call-template>
  </xsl:comment>
  <xsl:text>&#xA;&#xA;</xsl:text>
  <html>
    <head>
      <link rel="stylesheet" type="text/css" href="{$css}"/>
      <title>
        <xsl:apply-templates select="omdoc/metadata/dc:Title"/>
      </title>
    </head>
    <body>
      <xsl:apply-templates select="omdoc"/>
    </body>
  </html>
<xsl:text>&#xA;</xsl:text>
</xsl:template>


<xsl:template match="omdoc">
  <!--  First the header (title, authors and date) -->
  <div>
    <xsl:if test="metadata/dc:Title">
      <h1><xsl:apply-templates select="metadata/dc:Title"/></h1>
    </xsl:if>
    <xsl:if test="metadata/dc:Creator">
      Author(s):
      <xsl:for-each select="metadata/dc:Creator">
        <xsl:apply-templates/>
      </xsl:for-each><br/>
    </xsl:if>
    <xsl:if test="metadata/dc:Date">
      <xsl:call-template name="localize">
        <xsl:with-param name="key" select="'date'"/>
      </xsl:call-template>
      <xsl:text>: </xsl:text>
      <xsl:apply-templates select="metadata/dc:Date"/>
    </xsl:if>
  </div>
  <br/>
  <!-- Then apply the templates on the following elements -->
  <xsl:apply-templates select="child::node()[not(self::metadata)]"/>
</xsl:template>

<xsl:template match="omgroup">
  <xsl:call-template name="do-id-label"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="omgroup[@type='sequence']">
  <xsl:call-template name="do-begin-list"/>
  <xsl:for-each select="omtext">
    <xsl:call-template name="do-begin-list"/>
    <xsl:value-of select="."/>
    <xsl:call-template name="do-end-list"/>
  </xsl:for-each>
  <xsl:call-template name="do-end-list"/>
</xsl:template>

<xsl:template match="ref">
  <xsl:choose>
    <!-- If content of the refnode is not empty,
         then we don't use it as a reference, but put it out. -->
    <xsl:when test="node()!=''">
      <xsl:apply-templates mode="omdocnode2html"/>
    </xsl:when>
    <xsl:otherwise>
      <a class='special'>
        <xsl:attribute name="href">
          <xsl:if test="//*[@id=current()/@xref]">#</xsl:if>
          <xsl:value-of select="@xref"/>
        </xsl:attribute>
        <xsl:apply-templates/>
      </a>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:template>

<!-- ref within omgroups show the structure of the text, right now we ignore them -->
<xsl:template match="ref[parent::omgroup]"/>
  



<xsl:template match="mc">
  <tr>
    <td><xsl:apply-templates select="symbol"/></td>
    <td><xsl:apply-templates select="choice"/></td>
    <td><xsl:apply-templates select="hint"/></td>
    <td><xsl:apply-templates select="answer"/></td>
  </tr>
</xsl:template>

<xsl:template match="code">
  <xsl:choose>
    <xsl:when test="@type='js'">
      <SCRIPT LANGUAGE="JavaScript">
	<xsl:if test="data[@href]">
	  <xsl:attribute name="src">
	    <xsl:value-of select="data/@href"/>
	  </xsl:attribute>
	</xsl:if>
	<xsl:comment>
	  <xsl:apply-templates select="data"/>
	  //
	</xsl:comment>
      </SCRIPT>
    </xsl:when>
  </xsl:choose>
  <xsl:apply-templates/>
</xsl:template>

<!-- finally, here come the stuff that has to be overdefined by the 
     individual formats, this one is for html -->

<xsl:template name="do-id-label">
  <a name="{@id}"/>
</xsl:template>


<xsl:template match="om:OMOBJ" mode="format">
  <em><xsl:apply-templates/></em>
</xsl:template>

<xsl:template match="requation" mode="format">
  <em><xsl:apply-templates select="." mode="inner"/></em>
</xsl:template>

<xsl:template match="om:OMSTR" mode="doit">
  <em><xsl:apply-templates/></em>
</xsl:template>

<xsl:template name="do-begin-list">
  <xsl:text disable-output-escaping="yes">&#xA;&lt;ol&gt;</xsl:text>
</xsl:template>

<xsl:template name="do-end-list">
  <xsl:text disable-output-escaping="yes">&#xA;&lt;/ol&gt;&#xA;</xsl:text>
</xsl:template>

<xsl:template name="do-begin-item">
  <xsl:text disable-output-escaping="yes">&#xA;&lt;li&gt;&#xA;</xsl:text>
</xsl:template>

<xsl:template name="do-end-item">
  <xsl:text disable-output-escaping="yes">&#xA;&lt;/li&gt;&#xA;</xsl:text>
</xsl:template>

<xsl:template name="do-begin-bold">
  <xsl:text disable-output-escaping="yes">&lt;b&gt;</xsl:text>
</xsl:template>

<xsl:template name="do-end-bold">
  <xsl:text disable-output-escaping="yes">&lt;/b&gt;</xsl:text>
</xsl:template>

<xsl:template name="do-begin-crossref">
  <xsl:param name="uri"/>
  <xsl:text disable-output-escaping="yes">&lt;a href="</xsl:text>
  <xsl:value-of select="$uri"/>
  <xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
</xsl:template>

<xsl:template name="do-end-crossref">
  <xsl:text disable-output-escaping="yes">&lt;/a&gt;</xsl:text>
</xsl:template>

<xsl:template name="do-nl">
  <xsl:text disable-output-escaping="yes">&lt;br&gt;&#xA;</xsl:text>
</xsl:template>


<xsl:template name="do-begin-omdocenv">
  <xsl:param name="type"/>
  <xsl:text disable-output-escaping="yes">&lt;div class="</xsl:text>
  <xsl:choose>
    <xsl:when test="local-name()='omtext' and not($type='')">
      <xsl:value-of select='$type'/>
    </xsl:when>
    <xsl:when test="local-name()='omtext'">
      <xsl:text>normaltext</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="local-name()"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text disable-output-escaping="yes">"&gt;&#xA;</xsl:text>
</xsl:template>

<xsl:template name="do-end-omdocenv">
  <xsl:text disable-output-escaping="yes">&#xA;&lt;/div&gt;&#xA;</xsl:text>
</xsl:template>

<xsl:template name="do-begin-mcgroup">
  <xsl:text disable-output-escaping="yes">&#xA;&lt;table border="1"&gt;&#xA;</xsl:text>
</xsl:template>

<xsl:template name="do-end-mcgroup">
  <xsl:text disable-output-escaping="yes">&#xA;&lt;/table&gt;&#xA;</xsl:text>
</xsl:template>


<xsl:template name="do-crossref">
  <xsl:param name="uri"/>
  <xsl:param name="print-form"/>
  <a href="{$uri}"><xsl:copy-of select="$print-form"/></a>
</xsl:template>

<xsl:template name="do-print-symbol">
  <b><xsl:value-of select="@name"/></b>
</xsl:template>

<xsl:template name="do-print-variable">
  <em><xsl:value-of select="@name"/></em>
</xsl:template>


</xsl:stylesheet>




