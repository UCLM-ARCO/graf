<?xml version="1.0" encoding="iso-8859-1"?><!-- -*- XML -*- -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
  xmlns:commodity="http://arco.esi.uclm.es/commodity"
  xsl:exclude-result-prefixes="commodity">



  <xsl:output
    method = "xml"
    encoding = "iso-8859-1"
    omit-xml-declaration = "no"
    indent = "yes" />


  <!-- pass through -->
  <xsl:template match="instructions|instructions/*/*|identification|
                       part|
                       item|item/@*|
                       number|number/@*|
		       freetext|freetext/@*|
		       p|
		       ul|li|enumerate|
                       em|b|tt|
		       listing|listing/@*|screen|pre|
                       figure|figure/@*|
		       figurequestion|figurequestion/@*|
		       answer|
		       placeholder|
		       subquestion|subquestion/@*|
		       multicol|multicol/@*|
		       text()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:param name="rootdir"/>
  <xsl:param name="answers"/>
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
      id=""
      from="{/exam/@from}"
      lang="{/exam/@lang}"
      answers="{$answers}"
      plain-question-counter="{count(/exam/plain-question-counter)}"
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

      <xsl:attribute name="subject">
	<xsl:choose>
          <xsl:when test="commodity:file-exists(concat($rootdir,'/','data.xml'))">
            <xsl:value-of select="document(concat($rootdir,'/','data.xml'))/subject/@name"/>
          </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="/exam/subject/@name"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>

      <xsl:apply-templates/>
    </exam_view>
  </xsl:template>


  <xsl:template match="question">
    <xsl:variable name="ref" select="@id"/>
    <xsl:variable name="topic" select="concat($rootdir, ./@topic,'.xml')"/>

    <xsl:choose>
      <xsl:when test="count(document($topic)/qset/question[@id=$ref]) = 1">
	<xsl:element name="question">
	  <xsl:call-template name="copy_question">
	    <xsl:with-param name="question" select="document($topic)/qset/question[@id=$ref]"/>
	  </xsl:call-template>
	</xsl:element>
      </xsl:when>

      <xsl:otherwise>
	<xsl:message terminate="yes">
	  ERROR: The question <xsl:value-of select="concat(./@topic,'.xml:', $ref)"/> not exist or is duplicated.
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="copy_question">
    <xsl:param name="question"/>

    <xsl:attribute name="order">
      <xsl:value-of select="commodity:random()"/>
    </xsl:attribute>
    <xsl:copy-of select="@*"/>

    <xsl:copy-of select="$question/@*"/>
    <xsl:apply-templates select="$question/*"/>

  </xsl:template>

<!--
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
-->

</xsl:stylesheet>


<!-- Local Variables: -->
<!-- mode: xml -->
<!-- fill-column: 90 -->
<!-- End: -->
