<?xml version="1.0" encoding="iso-8859-1"?><!-- -*- XML -*- -->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:commodity="http://arco.esi.uclm.es/commodity"
		xsl:exclude-result-prefixes="commodity">

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
\documentclass[</xsl:text><xsl:value-of select="@lang"/><xsl:text>]{arco-exam}

\usepackage{inconsolata}

\arcoTopic{</xsl:text><xsl:value-of select="@subject"/><xsl:text>}
\arcoExamDesc{</xsl:text><xsl:value-of select="@title"/><xsl:text>}
\arcoExamCourse{</xsl:text><xsl:call-template name="course"/> <xsl:text>}
\arcoExamDate{</xsl:text><xsl:call-template name="date"/><xsl:text>}</xsl:text>

    <xsl:if test="@is_solution='1'">\printanswers</xsl:if>
    <xsl:if test="@plain-question-counter='1'">\usePlainQuestionCounter</xsl:if>

    <xsl:text>&#10;&#10;\begin{document}</xsl:text>

    <xsl:if test="count(instructions)">
      <xsl:text>&#10;&#10;\arcoExamAdvice{</xsl:text>
      <xsl:apply-templates select="instructions"/>
      <xsl:text>}&#10;</xsl:text>
    </xsl:if>

    <xsl:if test="count(identification)">
      <xsl:text>&#10;\arcoExamStudentForm&#10;&#10;</xsl:text>
    </xsl:if>

    <xsl:text>\begin{questions} &#10;</xsl:text>
    <xsl:apply-templates select="question"/>
    <xsl:text>&#10;\end{questions}&#10;</xsl:text>

    <xsl:text>\end{document} &#10;</xsl:text>
  </xsl:template>

  <xsl:template name="date">
    <xsl:call-template name="parsedate">
      <xsl:with-param name="date" select="@from"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="course">
    <xsl:call-template name="parsecourse">
      <xsl:with-param name="date" select="@from"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="numquestions">
    <xsl:text> \numquestions{} </xsl:text>
  </xsl:template>

  <xsl:template match="numpoints">
    <xsl:text> \numpoints{} </xsl:text>
  </xsl:template>

  <xsl:template match="title">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template name="render-question-statement">
    <xsl:choose>
      <xsl:when test="
      (count(freetext) or
      count(solution) or
      count(subquestion/freetext) or
      count(subquestion/solution)) and
      /exam_view/@is_solution='1' and
      count(p) > 1">
        <xsl:apply-templates select="p[1]"/>
        <xsl:text>
          {\bf[Este enunciado ha sido omitido parcialmente por falta de espacio. Consulte el examen para verlo completo.]}
        </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="p|
				 multicol[not(child::item)]|
				 enumerate|ul|
				 figure|figurequestion|
				 listing|screen|pre|
				 text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="calc-longest-item">
    <xsl:for-each select="item">
      <xsl:sort select="string-length(.)" data-type="number" order="descending"/>
      <xsl:if test="position() = 1">
	<xsl:value-of select="string-length(normalize-space(.))"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="render-question-body">
    <xsl:variable name="longest-item"><xsl:call-template name="calc-longest-item"/></xsl:variable>
    <xsl:variable name="multicol">
      <xsl:choose>
	<xsl:when test="@multicol=4 or $longest-item &lt; 13">4</xsl:when>
	<xsl:when test="@multicol='yes' or @multicol=2 or $longest-item &lt; 42">2</xsl:when>
	<xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$multicol != ''">
<xsl:text>
\begin{multicols}{</xsl:text><xsl:value-of select="$multicol"/><xsl:text>}
</xsl:text>
    <xsl:apply-templates select="item"/>
    <xsl:text>\end{multicols}&#10;</xsl:text>
    <xsl:apply-templates select="freetext|solution|text()"/>
      </xsl:when>
      <xsl:otherwise>
<xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="item|freetext|solution|text()"/>
<xsl:text>\vspace{-5pt} &#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="part" name="part">
    <xsl:if test="name()='part'">
      <xsl:text>\part&#10;</xsl:text>
    </xsl:if>

    <xsl:call-template name="question-body"/>

  </xsl:template>

  <xsl:template match="question">
    <xsl:if test="contains(@grade, '.')">
      <xsl:message>ERROR: Decimal grades are forbidden!!</xsl:message>
    </xsl:if>

    <xsl:text>&#10;\begin{simpleQuestion}[</xsl:text>
    <xsl:value-of select="@grade"/>
    <xsl:text>]&#10;</xsl:text>

    <xsl:call-template name="render-question-statement"/>
    <xsl:call-template name="render-question-body"/>

    <xsl:text>\end{simpleQuestion}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="question[subquestion]">
    <xsl:text>&#10;\begin{multiQuestion}[</xsl:text>
    <xsl:value-of select="@grade"/>
    <xsl:text>]</xsl:text>

    <xsl:call-template name="render-question-statement"/>

    <xsl:text>\begin{parts}&#10;</xsl:text>
      <xsl:apply-templates select="subquestion"/>
    <xsl:text>\end{parts}&#10;</xsl:text>

    <xsl:text>\end{multiQuestion}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="subquestion">
    <xsl:text>&#10;\subQuestion </xsl:text>
    <xsl:call-template name="render-question-statement"/>
    <xsl:call-template name="render-question-body"/>
  </xsl:template>


  <xsl:template name="par">
    <xsl:text>&#10;</xsl:text>
<!--     <xsl:text>\vspace{2pt}</xsl:text>  -->
  </xsl:template>

  <xsl:template match="option">
    <xsl:message>ERROR: El elemento "option" es obsoleto, use "item"</xsl:message>
  </xsl:template>

  <xsl:template match="@answer">
    <xsl:message>ERROR: El atributo "answer" es obsoleto, use "value"</xsl:message>
  </xsl:template>

  <xsl:template name="first-item">
    <xsl:if test="position()=1">
      <xsl:text>\vspace{1mm plus 1mm}&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="item">
    <xsl:call-template name="first-item"/>
    <xsl:text>\mbox{\choice{\mbox{}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="item[@value]">
    <xsl:call-template name="first-item"/>
    <xsl:text>\mbox{\correctChoice{\mbox{}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}}&#10;</xsl:text>
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
    \arcoSolutionorbox{</xsl:text><xsl:value-of select="./@rows"/><xsl:text>}{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- format elements -->
  <xsl:template match="p">
    <xsl:if test="position()!=1">
      <xsl:call-template name="par"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="ul">
    <xsl:text>\begin{itemize}&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{itemize}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="enumerate">
    <xsl:text>\begin{enumerate}[label=\alph*)]&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{enumerate}</xsl:text>
  </xsl:template>

  <xsl:template match="ul/li|enumerate/li">
    <xsl:text>\item </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#10;</xsl:text>
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

  <xsl:template name="parsecourse">
    <xsl:param name="date"/>
    <xsl:variable name="month" select="substring($date,5,2)"/>
    <xsl:variable name="year" select="substring($date,3,2)"/>

    <xsl:choose>
      <xsl:when test="$month>8">
	<xsl:value-of select="$year"/>/<xsl:value-of select="$year + 1"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$year - 1"/>/<xsl:value-of select="$year"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="listing">
<xsl:text>\begin{listing}[language=</xsl:text>
<xsl:value-of select="@language"/>
<xsl:text>]&#10;</xsl:text>
<xsl:value-of select="substring-after(text(), '&#xa;')"/>
<xsl:text>\end{listing}&#10;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="screen">
<xsl:text>\begin{console}</xsl:text>
<xsl:value-of select="substring-after(text(), '&#xa;')"/>
<xsl:text>\end{console}&#10;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="pre">
<xsl:text>&#10;\begin{listing}[style=pre,numbers=none]&#10;</xsl:text>
<xsl:value-of select="substring-after(text(), '&#xa;')"/>
<xsl:text>\end{listing}&#10;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="figure">
\begin{center}
\includegraphics[width=<xsl:value-of select="@width"/>\textwidth]{<xsl:value-of select="@src"/>}
\end{center}
  </xsl:template>

  <xsl:template match="figurequestion">
    \arcoFigureWithAnswer{<xsl:value-of select="@width"/>}{<xsl:value-of select="@question"/>}{<xsl:value-of select="@solution"/>}
  </xsl:template>

  <xsl:template match="solution">
    <xsl:if test="/exam_view/@is_solution=1">
      <xsl:text>{\color{blue}\small </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="placeholder">
    <xsl:text>~\_\_\_\_\_\_</xsl:text>
  </xsl:template>

  <!--
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  -->

  <xsl:template match="multicol">
    <xsl:variable name="cols">
      <xsl:choose>
	<xsl:when test="@cols">
	  <xsl:value-of select="@cols"/>
	</xsl:when>
	<xsl:otherwise>2</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:text>
\begin{multicols}{</xsl:text><xsl:value-of select="$cols"/><xsl:text>}
</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{multicols}&#10;</xsl:text>
  </xsl:template>


</xsl:stylesheet>
