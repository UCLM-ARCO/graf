<?xml version="1.0" encoding="iso-8859-1"?><!-- -*- XML -*- -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="latex_view.xsl"/>



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

      \geometry{margin=1.8cm,top=3cm,bottom=2cm}

      \graphicspath{{/home/david/repos/graf/images/} {images/} {./}}


      \definecolor{uclm}{cmyk}{0.2,1,0.6,0.5}
      \definecolor{uclm-light}{cmyk}{0,0.1,0.1,0}
      \definecolor{arco}{cmyk}{0.6,0.4,0,0.3}
      \definecolor{arco-light}{cmyk}{0.1,0,0,0}

      % PANTONE 7427. R:60 G:8 B:15
      \definecolor{uclmred}{rgb}{.60,.08,.15}

      % Cool Gray 5. R:72 G:70 B:68
      \definecolor{uclmgray}{rgb}{.72,.70,.68}

      \newcommand{\UCLMbgcolor}[1]{\color{uclm-light}#1}

\newcommand{\ESIname}{\textbf{\textsf{Escuela Superior de Informática}}}

\newcommand{\UCLMhead}[2]{
  \setlength{\unitlength}{1in}
  \begin{picture}(0,0)
    \put(-0.5,0){\includegraphics[width=4cm]{uclm.pdf}}
    \put(1.2,0.3){\makebox(0,0)[l]{\textsf{\textbf{\Large #1}}}}
    \put(1.2,0.055){\makebox(0,0)[l]{\textsf{\textbf{\large %
            \textcolor{uclmred}{\ESIname}}}}}
    \put(7.2,0.55){\makebox(0,0)[r]{%
        \parbox{0.7\textwidth}{
          \begin{flushright}
            #2
          \end{flushright}
      }}}
  \end{picture}
}
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


\header{%
	\UCLMhead{%
    </xsl:text>
    <xsl:call-template name="subject"/>
    <xsl:text>}{</xsl:text>
    <xsl:call-template name="title"/>
    <xsl:text>\\ </xsl:text>
    <xsl:call-template name="date"/>
    <xsl:text>}}{}{}
      \footer{}{Pág. \thepage{}/\numpages}{}

      % exam class
      \pointname{p}
      \addpoints

      % longitudes
      \newlength{\altolinea}
      \addtolength{\altolinea}{0.5cm}
      \setlength{\fboxsep}{.2cm}


      \begin{document}
      
\includegraphics{images/horizBar.jpg}

\pagestyle{headandfoot}

\renewcommand{\theenumi}{(\alph{enumi})}
    </xsl:text>

    <xsl:if test="count(instructions)">
      <xsltext>
	\begin{center}
	\parbox{16cm}{\emph{\noindent </xsltext>
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
	

	</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="newline"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="*[name()!='text' and name()!='extra']"/>

    <xsl:choose>
      <xsl:when test="$multicol">
	<xsl:text>
	  
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
  
  
    <xsl:template match="item">
    <xsl:text>{\fontsize{15pt}{15pt} \selectfont \includegraphics{images/casillaPregunta.jpg}  }</xsl:text>
    <xsl:call-template name="item" select="."/>
  </xsl:template>
  
  
</xsl:stylesheet>
