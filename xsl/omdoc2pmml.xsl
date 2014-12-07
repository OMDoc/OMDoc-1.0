<?xml version="1.0" encoding="iso-8859-1"?>
<!-- An XSL style sheet for creating html from OMDoc (Open 
     Mathematical Documents). 
     URL: http://www.mathweb.org/omdoc/xsl/omdoc2html.dtd
     Copyright (c) 2000 Michael Kohlhase, 
     This style sheet is released under the Gnu Public License
     send bug-reports, patches, suggestions to omdoc@mathweb.org -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:om="http://www.openmath.org/OpenMath"
  xmlns:dc="http://purl.org/DC"
  version="1.0">  

<xsl:import href="omdoc2html.xsl"/>

<xsl:output method="xml" 
            indent="yes" 
            doctype-public="'-//W3C//DTD XHTML 1.0 Strict//EN' 'mathml.dtd'"/>

<xsl:strip-space elements="*"/>


<xsl:template match="om:OMOBJ">
 <math xmlns="http://www.w3.org/1998/Math/MathML" mode="inline">
  <xsl:apply-templates/>
 </math>
</xsl:template>

<xsl:template match="om:OMA" mode="doit">
  <mrow>
    <xsl:apply-templates select="*[1]"/>
    <mo><xsl:text disable-output-escaping="yes">&lt;mchar name="&amp;ApplyFunction;"/&gt;</xsl:text></mo>
    <mrow>
      <mo fence="true">(</mo><mrow>
      <xsl:for-each select="*[position()!=1]">
        <xsl:apply-templates select="."/>
        <xsl:if test="position()!=last()"><mo separator="true">,</mo></xsl:if>
      </xsl:for-each>
      </mrow><mo fence="true">)</mo>
    </mrow>
  </mrow>
</xsl:template>

<xsl:template match="om:OMBVAR">
  <mrow>
    <xsl:for-each select="*">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position()=last())"><mo seaparator="true">,</mo></xsl:if>
    </xsl:for-each>
  </mrow>
</xsl:template>

<xsl:template match="om:OMSTR" mode="doit">
  <mtext><xsl:apply-templates/></mtext>
</xsl:template>

<xsl:template match="om:OMI" mode="doit">
 <mn><xsl:apply-templates/></mn>
</xsl:template>

<xsl:template match="om:OMF" mode="doit">
  <mn>
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
  </mn>
</xsl:template>

<xsl:template match="requation" mode="format">
 <math xmlns="http://www.w3.org/1998/Math/MathML" mode="inline">
   <xsl:apply-templates select="." mode="inner"/>
 </math>

</xsl:template>


<xsl:template name="do-print-symbol">
  <mi><xsl:value-of select="@name"/></mi>
</xsl:template>

<xsl:template name="do-print-variable">
  <mi><xsl:value-of select="@name"/></mi>
</xsl:template>


<xsl:template name="print-fence">
  <xsl:param name="fence"/>
  <mo fence="true"><xsl:value-of select="$fence"/></mo>
</xsl:template>

<xsl:template name="print-separator">
  <xsl:param name="separator"/>
  <mo separator="true"><xsl:value-of select="$separator"/></mo>
</xsl:template>

</xsl:stylesheet>



