<?xml version="1.0" encoding="iso-8859-1"?><!-- -*- XML -*- -->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output
    method = "text"
    encoding = "utf-8"
    omit-xml-declaration = "yes"
    doctype-public = "-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system = "DTD/xhtml1-transitional.dtd"
    indent = "no" />

  <!-- FIXME -->
  <xsl:param name="readonly"/>

  <xsl:template match="exam_view">
    <xsl:text>% -*- mode:utf-8 -*-
\documentclass{arco-exam}

\arcoTopic{</xsl:text><xsl:value-of select="@course"/><xsl:text>}
\arcoExamDesc{</xsl:text><xsl:value-of select="@title"/><xsl:text>}
\arcoExamDate{</xsl:text><xsl:call-template name="date"/><xsl:text>}</xsl:text>

    <xsl:if test="@answers='1'">\printanswers</xsl:if>

    <xsl:text>&#10;&#10;\begin{document}</xsl:text>

    <xsl:if test="count(instructions)">
      <xsl:text>&#10;&#10;\arcoExamAdvice{%</xsl:text>
      <xsl:apply-templates select="instructions"/>
      <xsl:text>}&#10;</xsl:text>
    </xsl:if>

    <xsl:if test="count(identification)">
      <xsl:text>&#10;\arcoExamStudentForm&#10;&#10;</xsl:text>
    </xsl:if>

    <xsl:apply-templates select="hline"/>

    <xsl:text>\begin{questions} &#10;</xsl:text>
    <xsl:apply-templates select="question"/>
    <xsl:text>&#10;\end{questions} &#10;</xsl:text>

    <xsl:text>\end{document} &#10;</xsl:text>
  </xsl:template>

  <xsl:template name="date">
    <xsl:call-template name="parsedate">
      <xsl:with-param name="date" select="@from"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="numquestions">
    <xsl:text>\numquestions{}</xsl:text>
  </xsl:template>

  <xsl:template match="numpoints">
    <xsl:text>\numpoints{}</xsl:text>
  </xsl:template>

  <xsl:template match="title">
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template name="part-content">
    <xsl:apply-templates
	select="*[name()!='item' and
		name()!='freetext' and
		name()!='extra' and
		name()!='part']"/>

    <xsl:variable name="items" select="count(*[name()!='text'])"/>

    <xsl:variable name="multicol" select="$items &gt; 6 or @multicol='yes'"/>

    <xsl:choose>
      <xsl:when test="$multicol">
	<xsl:text>
	  \vspace{-0.2cm}
\begin{multicols}{2}
	</xsl:text>
      </xsl:when>
      <xsl:otherwise>

      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="item|freetext"/>

    <xsl:choose>
      <xsl:when test="$multicol">
	<xsl:text>\end{multicols}
	  \vspace{-12pt}
      </xsl:text>
      </xsl:when>
       <xsl:otherwise>
<!--
	<xsl:text>\vspace{-7pt} &#10;</xsl:text>
-->
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="part" name="part">
    <xsl:if test="name()='part'">
      <xsl:text>\part&#10;</xsl:text>
    </xsl:if>

<!--
    <xsl:if test="name()='part' and position()!=1">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
-->

    <xsl:call-template name="part-content"/>

    <xsl:apply-templates select="*[name()='extra']"/>

<!--     <xsl:text>\mbox{} \\[0.3cm] </xsl:text> -->
  </xsl:template>

  <xsl:template match="question">
    <xsl:text>&#10;\begin{arcoQuestion}{</xsl:text>
    <xsl:value-of select="@grade"/>
    <xsl:text>}&#10;    </xsl:text>

    <xsl:call-template name="part-content"/>

    <xsl:if test="count(part)>0">
      <xsl:text>\begin{parts}&#10;</xsl:text>
      <xsl:apply-templates select="part"/>
      <xsl:text>\end{parts}&#10;</xsl:text>
    </xsl:if>

    <xsl:text>\end{arcoQuestion}&#10;</xsl:text>

<!--
    <xsl:if test="position()!=last()">
      <xsl:text>\mbox{} \\[0.5cm] &#10;</xsl:text>
    </xsl:if>
-->
  </xsl:template>

  <xsl:template name="par">
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="option">
    <xsl:text>ERROR: El elemento \textbf{option} está obsoleto, use
      \textbf{item}\\ </xsl:text>
  </xsl:template>

  <xsl:template name="first-item">
    <xsl:if test="position()=1">
      <xsl:text>\vspace{1mm plus 1mm}&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="item">
    <xsl:call-template name="first-item"/>
    <xsl:text>    \choice{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\mbox{}}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="item[@answer]|item[@value]">
    <xsl:call-template name="first-item"/>
    <xsl:text>    \correctChoice{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="extra">
    <xsl:text>\vspace{6pt}</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="number">
    <xsl:variable name="valor">
      <xsl:choose>
        <xsl:when test="node() != ''">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>\LARGE\phantom{88} </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:text>\null \vspace{-0.3cm}\hspace{0.5cm} \framebox[</xsl:text>
    <xsl:value-of select="./@size"/>

    <xsl:text>\width]{\arcoAnswer{</xsl:text>
    <xsl:value-of select="$valor"/>
    <xsl:text>}}\hspace{0.2cm}</xsl:text>

    <xsl:variable name="unit">
      <xsl:choose>
        <xsl:when test="./@unit='%'">
          <xsl:value-of select="'\%'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="./@unit"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="$unit"/>
    <xsl:text>\medskip\par&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="freetext">
    <xsl:text>
    \vspace{0.5mm plus 0.5mm}
    \arcoSolutionorbox{</xsl:text><xsl:value-of select="./@rows"/>
    <xsl:text>}{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>
    }
    \vspace{0.5mm plus 1.5mm minus 1.5mm}
    </xsl:text>
  </xsl:template>

  <!-- elementos de formato -->
  <xsl:template match="text|p">
    <xsl:if test="position()!=1">
      <xsl:call-template name="par"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="ul">
    <xsl:text>\begin{itemize} </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{itemize} </xsl:text>
  </xsl:template>

  <xsl:template match="ul/li">
    <xsl:text>\item </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="em">
    <xsl:text>\emph{</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="b">
    <xsl:text>\textbf{</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="tt">
    <xsl:text>\texttt{</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>}</xsl:text>
  </xsl:template>


  <xsl:template name="parsedate">
    <xsl:param name="date"/>
    <xsl:value-of select="substring($date,7)"/>
    <xsl:text> de </xsl:text>
    <xsl:variable name="month" select="substring($date,5,2)"/>
    <xsl:choose>
      <xsl:when test="$month=01">enero</xsl:when>
      <xsl:when test="$month=02">febrero</xsl:when>
      <xsl:when test="$month=03">marzo</xsl:when>
      <xsl:when test="$month=04">abril</xsl:when>
      <xsl:when test="$month=05">mayo</xsl:when>
      <xsl:when test="$month=06">junio</xsl:when>
      <xsl:when test="$month=07">julio</xsl:when>
      <xsl:when test="$month=08">agosto</xsl:when>
      <xsl:when test="$month=09">septiembre</xsl:when>
      <xsl:when test="$month=10">octubre</xsl:when>
      <xsl:when test="$month=11">noviembre</xsl:when>
      <xsl:when test="$month=12">diciembre</xsl:when>
      <xsl:otherwise><xsl:value-of select="$month"/></xsl:otherwise>
    </xsl:choose>
    <xsl:text> de </xsl:text>
    <xsl:value-of select="substring($date,1,4)"/>
  </xsl:template>

  <xsl:template match="listing">
    <xsl:text>{\fontsize{8pt}{8pt} \selectfont&#10;</xsl:text>
<xsl:text>\begin{listing}[language=</xsl:text>
<xsl:value-of select="@language"/>
<xsl:text>]</xsl:text>
<xsl:value-of select="."/>
<xsl:text>\end{listing}  &#10;</xsl:text>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="screen">
    <xsl:text>{\fontsize{8pt}{8pt} \selectfont&#10;</xsl:text>
<xsl:text>\begin{console}</xsl:text>
<xsl:value-of select="."/>
<xsl:text>\end{console}  &#10;</xsl:text>
    <xsl:text>}</xsl:text>
  </xsl:template>


  <xsl:template match="hline">
    <xsl:text>
    \hbox to \textwidth{\enspace\hrulefill}
    \bigskip
    </xsl:text>
  </xsl:template>

  <xsl:template match="figure">
\begin{center}
\includegraphics[width=<xsl:value-of select="@width"/>\textwidth]{<xsl:value-of select="@src"/>}
\end{center}
  </xsl:template>

  <xsl:template match="answer">
    <xsl:text>\arcoAnswer{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>


</xsl:stylesheet>
