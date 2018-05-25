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

\arcoTopic{</xsl:text><xsl:value-of select="@subject"/><xsl:text>}
\arcoExamDesc{</xsl:text><xsl:value-of select="@title"/><xsl:text>}
\arcoExamCourse{</xsl:text><xsl:call-template name="course"/> <xsl:text>}
\arcoExamDate{</xsl:text><xsl:call-template name="date"/><xsl:text>}</xsl:text>

    <xsl:if test="@answers='1'">\printanswers</xsl:if>
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

    <!-- FIXME: deprecated? -->
    <xsl:apply-templates select="hline"/>

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
    <xsl:apply-templates select="p|
				 multicol|
				 enumerate|ul|
				 figure|figurequestion|
				 listing|screen|pre|
				 text()"/>
  </xsl:template>

  <xsl:template name="render-question-body">
    <xsl:variable name="items" select="count(*[name()='item'])"/>
    <xsl:variable name="multicol" select="$items &gt; 6 or @multicol='yes'"/>

    <xsl:choose>
      <xsl:when test="$multicol">
	<xsl:text>
\begin{multicols}{2}
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>&#10;\vspace{4pt}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="item|freetext|text()"/>

    <xsl:choose>
      <xsl:when test="$multicol">
	<xsl:text>\end{multicols}&#10;</xsl:text>
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

    <xsl:call-template name="question-body"/>

    <xsl:apply-templates select="*[name()='extra']"/>

<!--     <xsl:text>\mbox{} \\[0.3cm] </xsl:text> -->
  </xsl:template>

  <xsl:template match="question">
    <xsl:if test="contains(@grade, '.')">
      <xsl:message>ERROR: Decimal grades are forbidden!!</xsl:message>
    </xsl:if>

    <xsl:text>&#10;\begin{simpleQuestion}[</xsl:text>
    <xsl:value-of select="@grade"/>
    <xsl:text>]</xsl:text>

    <xsl:call-template name="render-question-statement"/>
    <xsl:call-template name="render-question-body"/>

    <xsl:text>\end{simpleQuestion}&#10;</xsl:text>
  </xsl:template>

  <!-- FIXME: rename "multiquestion" elements to "question" when is tested -->
  <xsl:template match="multiquestion|question[subquestion]">
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
    <xsl:text>&#10;\subQuestion</xsl:text>
    <xsl:call-template name="render-question-statement"/>
    <xsl:call-template name="render-question-body"/>
  </xsl:template>


  <xsl:template name="par">
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="option">
    <xsl:message>ERROR: El elemento "option" está obsoleto, use "item"</xsl:message>
  </xsl:template>

  <xsl:template name="first-item">
    <xsl:if test="position()=1">
      <xsl:text>\vspace{1mm plus 1mm}&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="item">
    <xsl:call-template name="first-item"/>
    <xsl:text>\choice{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\mbox{}}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="item[@answer]|item[@value]">
    <xsl:call-template name="first-item"/>
    <xsl:text>&#10;\correctChoice{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\mbox{}}&#10;</xsl:text>
  </xsl:template>

  <!-- FIXME: deprecated? -->
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

  <!-- format elements -->
  <!-- FIXME: replace "text" by "p" -->
  <xsl:template match="text|p">
    <xsl:if test="position()!=1">
      <xsl:call-template name="par"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="ul">
    <xsl:text>\begin{itemize} </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{itemize} </xsl:text>
  </xsl:template>

  <xsl:template match="enumerate">
    <xsl:text>\begin{enumerate}[label=\alph*)]&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{enumerate}</xsl:text>
  </xsl:template>

  <xsl:template match="ul/li|enumerate/li">
    <xsl:text>\item</xsl:text>
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
    <!--
	<xsl:text>{\fontsize{8pt}{8pt} \selectfont&#10;</xsl:text>
    -->
<xsl:text>\begin{listing}[language=</xsl:text>
<xsl:value-of select="@language"/>
<xsl:text>]&#10;</xsl:text>
<xsl:value-of select="."/>
<xsl:text>\end{listing}&#10;&#10;</xsl:text>
<!--
    <xsl:text>}</xsl:text>
-->
  </xsl:template>

  <xsl:template match="screen">
    <!--
	<xsl:text>{\fontsize{8pt}{8pt} \selectfont&#10;</xsl:text>
    -->
<xsl:text>\begin{console}</xsl:text>
<xsl:value-of select="."/>
<xsl:text>\end{console}&#10;&#10;</xsl:text>
<!--
    <xsl:text>}</xsl:text>
-->
  </xsl:template>

  <xsl:template match="pre">
    <!--
	<xsl:text>{\fontsize{8pt}{8pt} \selectfont&#10;</xsl:text>
    -->
<xsl:text>&#10;\begin{listing}[style=pre]&#10;</xsl:text>
<xsl:value-of select="substring-after(text(), '&#xa;')"/>
<xsl:text>\end{listing}&#10;&#10;</xsl:text>
<!--
    <xsl:text>}&#10;</xsl:text>
-->
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

  <xsl:template match="figurequestion">
    \arcoFigureWithAnswer{<xsl:value-of select="@width"/>}{<xsl:value-of select="@question"/>}{<xsl:value-of select="@answer"/>}
  </xsl:template>

  <xsl:template match="answer">
    <xsl:text>\arcoAnswer{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="placeholder">
    <xsl:text>\_\_\_\_\_\_</xsl:text>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="multicol">
    <xsl:text>
\begin{multicols}{2}
</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{multicols}&#10;</xsl:text>
  </xsl:template>


</xsl:stylesheet>
