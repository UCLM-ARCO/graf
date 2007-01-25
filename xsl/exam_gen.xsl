<?xml version="1.0" encoding="iso-8859-1"?><!-- -*- XML -*- -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"                
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl">

  <xsl:output 
    method = "xml"
    encoding = "iso-8859-1"
    omit-xml-declaration = "no"
    indent = "yes" />


  <!-- pass through -->
  <xsl:template match="instructions|instructions/*|identification|
                       part|
                       text|option|option/@*|option/*|item|
                       extra|
                       number|number/@*|
                       ul|li|p|code|code/@*|
                       em|b|tt|
                       screen|
                       figure|figure/@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!--
<xsl:template match="code"/>
-->

  <xsl:param name="rootdir"/>
  <xsl:param name="setuser"/>
  <xsl:param name="setpass"/>
  <xsl:param name="setcourse"/>
  <xsl:param name="setexam"/>
  <xsl:param name="solution"/>
  <xsl:param name="part"/>    

  
  <xsl:template match="exam">
    <xsl:for-each select="part">
      <xsl:if test="position()=number($part)">
        <xsl:call-template name="gen_exam"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
    

  <xsl:template name="gen_exam">
    <exam_view 
      id="{$setexam}" 
      user="{$setuser}" pass="{$setpass}"
      from="{/exam/@from}" 
      >

      <xsl:if test="count(/exam/@show_points)">
        <xsl:attribute name="show_points" select="/exam/@show_points"/>
      </xsl:if>

      <xsl:variable name="part_name">
        <xsl:if test="@name!=''">
          <xsl:value-of select="concat(' (', @name, ')')"/>
        </xsl:if>
      </xsl:variable>

      <xsl:attribute name="title">
        <xsl:value-of select="concat(/exam/@title, $part_name)"/>
      </xsl:attribute>

      <xsl:attribute name="course">
<!--
	<xsl:value-of select="document(concat($rootdir, '/',
	$setcourse,'/','data.xml'))/subject/@name"/>
-->
        <xsl:value-of select="document(concat($rootdir, '/','data.xml'))/subject/@name"/>

      </xsl:attribute>
      <xsl:apply-templates/>
    </exam_view>
  </xsl:template>


  <xsl:template match="question">
    <xsl:variable name="ref" select="@id"/>
    <xsl:element name="question">
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="document(concat($rootdir, ./@topic,'.xml'))/qset/question[@id=$ref]/@*"/>
      <xsl:apply-templates select="document(concat($rootdir,
      ./@topic,'.xml'))/qset/question[@id=$ref]/*"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="answer/item">
    Error: hoja exam_gen.xsl, plantilla answer/item
  </xsl:template>

  <xsl:template match="item/@*">
    <xsl:if test="name()='answer' and $solution">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="freetext">
    <xsl:element name="freetext">
      <xsl:copy-of select="@*"/>
      <xsl:if test="$solution">
        <xsl:copy-of select="answer"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="freecode">
    <xsl:choose>
      <xsl:when test="$solution">
        <xsl:copy-of select="answer"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="freetext">
          <xsl:copy-of select="@*"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="answer">
    <xsl:if test="$solution">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>

