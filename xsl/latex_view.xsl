<?xml version="1.0" encoding="iso-8859-1"?><!-- -*- XML -*- -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output 
    method = "text"
    encoding = "iso-8859-1"
    omit-xml-declaration = "yes"
    doctype-public = "-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system = "DTD/xhtml1-transitional.dtd"
    indent = "no" />

  <xsl:param name="readonly"/>
  
  <xsl:template match="exam_view">

<!--
	    <td><xsl:text>Usuario: </xsl:text></td>
	    <td><xsl:value-of select="@user"/></td>
-->

    <xsl:text>
      \documentclass[pdftex,10pt,a4paper,spanish,color]{exam}
      \usepackage{times}

      \global\let\lhead\undefined
      \global\let\chead\undefined
      \global\let\rhead\undefined
      \global\let\lfoot\undefined
      \global\let\cfoot\undefined
      \global\let\rfoot\undefined

      %\usepackage{poppy}
      \usepackage{color}
      \usepackage{graphicx}
      \usepackage{tabularx}
      \usepackage{verbatim}
      \usepackage{pifont}
      \usepackage{rotating}
      \usepackage{latexsym}
      \usepackage{multicol}
      \usepackage{babel}
      \usepackage{fancyhdr}
      \usepackage{afterpage}
      \usepackage{geometry}

      \usepackage{amssymb}


      \usepackage[latin1]{inputenc}
      \usepackage[T1]{fontenc}

      \usepackage{listings}
      \lstloadlanguages{}
      \definecolor{Gris}{gray}{0.5}
      \lstdefinestyle{code}{basicstyle=\scriptsize\ttfamily,%
                         commentstyle=\color{Gris},%
                         keywordstyle=\bfseries,%
                         showstringspaces=false,%
                         extendedchars=true,%
                         numbers=left,
                         numberstyle=\tiny,
                         stepnumber=2,
                         numbersep=8pt,
                         xleftmargin=15pt,
                         frame=single}

      \lstdefinestyle{screen}{basicstyle=\scriptsize\ttfamily,%
                         commentstyle=\color{Gris},%
                         keywordstyle=\bfseries,%
                         showstringspaces=false,%
                         extendedchars=true,%
                         xleftmargin=15pt}


      \newcommand{\ifcolor}[1]{#1}

      \usepackage[bf,small]{caption2}
      \setlength{\captionmargin}{0.2cm}

      \geometry{margin=1.8cm,top=2.5cm,bottom=2.5cm}

      \graphicspath{{/home/david/repos/graf/images/} {images/} {./}}

		
      \definecolor{uclm}{cmyk}{0.2,1,0.6,0.5}
      \definecolor{uclm-light}{cmyk}{0,0.1,0.1,0}
      \definecolor{arco}{cmyk}{0.6,0.4,0,0.3}
      \definecolor{arco-light}{cmyk}{0.1,0,0,0}
      
      \newcommand{\UCLMcolor}[1]{\textcolor{uclm}{#1}}
      \newcommand{\UCLMbgcolor}[1]{\textcolor{uclm-light}{#1}}

\newcommand{\UCLMlogo}[1][height=1.3cm]{\UCLMcolor{\includegraphics[#1]{uclm.pdf}}}

\newcommand{\UCLM}{{UCLM}}
\newcommand{\UCLMname}{{\includegraphics[width=.4\textwidth]{uclmtext.pdf}}}

\newcommand{\CSname}{\textbf{\textsf{Departamento de Imformática}}}
\newcommand{\ESIname}{\textbf{\textsf{Escuela Superior de Informática}}}

\newcommand{\ESIhead}{\UCLMcolor{%
  \UCLMlogo[height=0.8cm]%
  \begin{tabular}[b]{l}
    {\large\UCLMname}\\
    {\normalsize\ESIname}
  \end{tabular}}}

\newcommand{\UCLMbglogo}{\ifcolor{%
  \begin{picture}(0,0)
    \put(0,0){\centerline{%
      \begin{tabular}[t]{c}
        \\
        \rule{0pt}{0.20\textheight}\\
        \UCLMbgcolor{\includegraphics[width=0.7\textwidth]{uclm.pdf}}\\
        \rule{0pt}{0.10\textheight}\\
        %\UCLMbgcolor{\fontsize{120}{150pt}\UCLM}
      \end{tabular}}}
  \end{picture}}}

% Eliminar la marca de agua del escudo
\renewcommand{\UCLMbglogo}{}



      \newcommand{\headframe}{%
         \setlength{\fboxsep}{0mm}%
         \setlength{\fboxrule}{1pt}%
         \setlength{\unitlength}{1pt}%
         \begin{picture}(0,0)(0,0)
            \centerline{%
            \raisebox{-2mm}{%
            \UCLMcolor{\fbox{\UCLMbgcolor{%
            \rule{4mm}{1.2cm}%
              \rule{\textwidth}{1.2cm}}}}}}
         \end{picture}}



      \header{\UCLMbglogo\headframe\UCLMcolor{\ESIhead}}{}{%
    </xsl:text>
    <xsl:call-template name="subject"/>
    <xsl:text>{</xsl:text>
    <xsl:call-template name="title"/>
    <xsl:text>, </xsl:text>
    <xsl:call-template name="date"/>
    <xsl:text>}}
      \footer{}{Pág. \thepage{}/\numpages}{}

      % exam class
      \pointname{p}
      \addpoints

      % longitudes
      \newlength{\altolinea}
      \addtolength{\altolinea}{0.5cm}
      \setlength{\fboxsep}{.2cm}

<!--      
      \title{%
      \textbf{Arquitectura e Ingeniería de Computadores}\\
      Examen Final (Prácticas)}
      \author{\UCLM{}\LaTeX{} package}
      \date{8 de julio de 2003}
-->




      \begin{document}

\pagestyle{headandfoot}

\renewcommand{\theenumi}{(\alph{enumi})}
    </xsl:text>

    <xsl:if test="count(instructions)">
      <xsltext>
	\begin{center} 
	\parbox{14cm}{\emph{ </xsltext>
      <xsl:apply-templates select="instructions"/>
      <xsl:text>}}
	\end{center}
      </xsl:text>
    </xsl:if>

    <xsl:if test="count(identification)">
      <xsl:text>
        \bigskip
        \noindent
        Apellidos: \enspace\rule{0.44\textwidth}{.5pt}\enspace Nombre: \enspace\rule{0.23\textwidth}{.5pt}\enspace Grupo:\enspace\hrulefill
        \bigskip
<!--
	\hbox to \textwidth{Nombre y grupo:\enspace\hrulefill}
-->
      </xsl:text>
    </xsl:if>

    <xsl:apply-templates select="hline"/>

    <xsl:text>\begin{questions} &#10;</xsl:text>
    <xsl:apply-templates select="question"/> 
    <xsl:text>&#10; \end{questions} &#10;</xsl:text>

    <xsl:text>\end{document} &#10;</xsl:text>
  </xsl:template>

  <!-- el nombre de la asignatura -->
  <xsl:template name="subject">
    <xsl:text>\textbf{\large </xsl:text>
    <xsl:value-of select="@course"/>
    <xsl:text> }\\ </xsl:text>
  </xsl:template>

  <!-- el motivo del examen -->
  <xsl:template name="title">
    <xsl:text>\small </xsl:text>
    <xsl:value-of select="@title"/>
  </xsl:template>

  <!-- La fecha -->
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


  <xsl:template match="part" name="part">
    <xsl:if test="name()='part' and position()!=1">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="text"/>
    <xsl:text>\vspace{5pt}</xsl:text>

    <xsl:variable name="items" select="count(*[name()!='text'])"/>

    <xsl:variable name="multicol" select="$items &gt; 6 or @multicol='yes'"/>

    <xsl:choose>
      <xsl:when test="$multicol">
	<xsl:text>
	  \vspace{-12pt}
\begin{multicols}{2}
	</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="newline"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="*[name()!='text' and name()!='extra']"/>
    
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

    <xsl:apply-templates select="*[name()='extra']"/>

<!--
    <xsl:choose>
      <xsl:when test="count(option)">
	<xsl:text>\begin{enumerate} &#10;</xsl:text>
      </xsl:when>
      <xsl:when test="count(item)">
	<xsl:text>\begin{list}{\fbox{\mbox{\phantom{V}}}}{} &#10;</xsl:text>
      </xsl:when>
    </xsl:choose>

    <xsl:apply-templates select="*[name()!='text']"/>

    <xsl:choose>
      <xsl:when test="count(option)">
	<xsl:text>\end{enumerate} &#10;</xsl:text>
      </xsl:when>
      <xsl:when test="count(item)">
	<xsl:text>\end{list} &#10;</xsl:text>
      </xsl:when>
    </xsl:choose>
-->

<!--     <xsl:text>\mbox{} \\[0.3cm] </xsl:text> -->
  </xsl:template>

  <xsl:template match="question">
    <xsl:text>\begin{minipage}{.95\textwidth} &#10;</xsl:text>
    <xsl:text>\question</xsl:text>

    <xsl:if test="count(/exam_view/@show_points)=0 or /exam_view/@show_points='yes'">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="@grade"/>
      <xsl:text>] </xsl:text>
    </xsl:if>

    <xsl:text> &#10;</xsl:text>    
    <xsl:apply-templates select="part"/>
    
    <xsl:if test="count(part)=0">
      <xsl:call-template name="part"/>
    </xsl:if>

    <xsl:text>\end{minipage} &#10;</xsl:text>

    <xsl:if test="position()!=last()">
      <xsl:text>\mbox{} \\[0.5cm] &#10;</xsl:text>
    </xsl:if>
    
<!--
    <xsl:apply-templates select="*[name()!='text']">
      <xsl:with-param name="id" select="concat(@topic,':',@id)"/>
    </xsl:apply-templates>
-->

  </xsl:template>


  <xsl:template name="newline">
    <xsl:text>

    </xsl:text>
  </xsl:template>

  <xsl:template match="option">
    <xsl:text>ERROR: El elemento \textbf{option} está obsoleto, use
      \textbf{item}\\ </xsl:text>
<!--    <xsl:text>\fbox{\mbox{\phantom{V}}} \hspace{4pt} </xsl:text>
    <xsl:apply-templates/>
    <xsl:call-template name="newline"/>
-->
  </xsl:template>

  <xsl:template match="item">
    <xsl:text>{\fontsize{15pt}{15pt} \selectfont $\square$}</xsl:text>
    <xsl:call-template name="item" select="."/>
  </xsl:template>

  <xsl:template match="item[@answer]">
    <xsl:text>{\fontsize{15pt}{15pt} \selectfont $\blacksquare$}</xsl:text>
    <xsl:call-template name="item" select="."/>
  </xsl:template>

  <xsl:template name="item">
    <xsl:text>\hspace{2pt} \textbf{</xsl:text>
    <xsl:number value="position()" format="a"/>
    <xsl:text>})\hspace{4pt}</xsl:text>
    <xsl:text>\parbox[t]{.9\textwidth}{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\\[-.3cm]</xsl:text>
    <xsl:text>}</xsl:text>
    <xsl:call-template name="newline"/>
  </xsl:template>

  <xsl:template match="extra">
    <xsl:text>\vspace{6pt}</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="ul/li">
    <xsl:text>\item </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="number">
    <xsl:variable name="valor">
      <xsl:choose>
        <xsl:when test="@answer != ''">
          <xsl:value-of select="@answer"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>\LARGE\phantom{88} </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:text>\null \hspace{1cm} \framebox[</xsl:text>
    <xsl:value-of select="./@size"/>

    <xsl:text>\width]{{</xsl:text>
    <xsl:value-of select="$valor"/>
    <xsl:text>}} </xsl:text>

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
    <xsl:text>\medskip\par </xsl:text>
  </xsl:template>

  <xsl:template match="freetext">
    <xsl:text>\begin{center}
      \fbox{\rule{0mm}{</xsl:text>
    <xsl:value-of select="./@rows"/>
    <xsl:text>\altolinea}
      \rule{.9\textwidth}{0mm}
      }
      \end{center}
    </xsl:text>

  </xsl:template>

  <xsl:template match="freetext[answer]">
   <xsl:text>\begin{center}
      \fbox{\parbox{.9\textwidth}{</xsl:text>
    <xsl:apply-templates select="answer"/>
    <xsl:text> 
      }}
      \end{center}
    </xsl:text>
  </xsl:template>

  
  <!-- elementos de formato -->
  <xsl:template match="ul">
    <xsl:text>\begin{itemize} </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{itemize} </xsl:text>
  </xsl:template>

  <xsl:template match="p">
    <xsl:apply-templates/>
    <xsl:text>\mbox{} \\[0.1cm] </xsl:text>
<!--
    <xsl:text>\mbox{} \\newline</xsl:text>      
-->
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


<!--
  <xsl:template match="question/number">
  <xsl:param name="id"/>
    <tr>
      <td>&#160;</td>
      <td>
        <xsl:element name="input">
          <xsl:attribute name="type">
            <xsl:text>text</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="name">
            <xsl:value-of select="$id"/>
          </xsl:attribute>
          <xsl:attribute name="size">
            <xsl:value-of select="@size"/>
          </xsl:attribute>
          <xsl:attribute name="maxlength">
            <xsl:value-of select="@size"/>
          </xsl:attribute>
      <xsl:attribute name="align">
            <xsl:text>right</xsl:text>
          </xsl:attribute>

	  <xsl:if test="$readonly">
	    <xsl:attribute name="readonly">
	      <xsl:text>readonly</xsl:text>
	    </xsl:attribute>
	  </xsl:if>
          <xsl:attribute name="value">
<xsl:value-of select="../answer/@value"/>
</xsl:attribute>
        </xsl:element>
      </td>
    </tr>
  </xsl:template>


  


  <xsl:template match="question/item">
    <xsl:param name="id"/>  
    <xsl:variable name="pos">
      <xsl:number value="position()" format="a" />
    </xsl:variable>
 
    <xsl:variable name="correct" select="count(../answer/item[@value=$pos])"/>

    <tr>
      <td>&#160;</td>
      <td>
	<xsl:element name="input">
	  <xsl:attribute name="type">checkbox</xsl:attribute>
	  <xsl:attribute name="name">
	    <xsl:value-of select="$id"/>
	  </xsl:attribute>
	  <xsl:attribute name="value">
            <xsl:value-of select="$pos"/>
          </xsl:attribute>
	  <xsl:if test="$readonly">
	    <xsl:attribute name="disabled">
	      <xsl:text>disabled</xsl:text>
	    </xsl:attribute>
	  </xsl:if>
         <xsl:if test="$correct">
           <xsl:attribute name="checked">
             <xsl:text>checked</xsl:text>
           </xsl:attribute>
        </xsl:if>

	</xsl:element>
	  <font class="optionNumber">
	    <xsl:number value="position()" format="a"/><xsl:text>. </xsl:text>
	  </font>

	  <xsl:value-of select="."/>

      </td>
    </tr>
  </xsl:template>

  <xsl:template match="question/freetext">
    <xsl:param name="id"/> 
    <tr>
      <td>&#160;</td>
      <td>
        <xsl:element name="textarea">
	  <xsl:attribute name="name">
	    <xsl:value-of select="$id"/>
	  </xsl:attribute>
	  <xsl:attribute name="rows">
	    <xsl:value-of select="@rows"/>
	  </xsl:attribute>
	  <xsl:attribute name="cols">
	    <xsl:value-of select="@cols"/>
	  </xsl:attribute>
	  <xsl:if test="$readonly">
	    <xsl:attribute name="readonly">
	      <xsl:text>readonly</xsl:text>
	    </xsl:attribute>
	  </xsl:if>
           <xsl:value-of select="../answer"/>
        </xsl:element>

	<textarea name="{$id}" rows="{@rows}" cols="{@cols}">
	  <xsl:text>&#160;</xsl:text>
	</textarea>

      </td>
    </tr>
  </xsl:template>

-->

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

  <xsl:template match="code">
    <xsl:text>{\fontsize{8pt}{8pt} \selectfont</xsl:text>
    <xsl:text>\begin{lstlisting}[style=code, language=</xsl:text>
    <xsl:value-of select="@language"/>
    <xsl:text>]</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>\end{lstlisting}  &#10;</xsl:text>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="screen">
    <xsl:text>{\fontsize{8pt}{8pt} \selectfont</xsl:text>
    <xsl:text>\begin{lstlisting}[style=screen]</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>\end{lstlisting}  &#10;</xsl:text>
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
\includegraphics[scale=<xsl:value-of select="@scale"/>]{<xsl:value-of select="@src"/>}
\end{center}
  </xsl:template>


<!--
  <xsl:template match="texto">
    <xsl:value-of select="."/>
  </xsl:template>
-->

</xsl:stylesheet>

