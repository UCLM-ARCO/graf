<?xml version="1.0" encoding="iso-8859-1"?><!-- -*- XML -*- -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output 
    method = "xml"
    encoding = "iso-8859-1"
    omit-xml-declaration = "no"
    doctype-public = "-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system = "DTD/xhtml1-transitional.dtd"
    indent = "yes" />

  <!-- pass through -->
  <xsl:template match="a|a/@*|b|em|it|tt|p|p/@*|form|form/@*|
                       img|img/@*|br|br/@*|table|table/@*|tr|tr/@*|td|td/@*|
                       center|img|img/@*|ul|li">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template name="css">
    <style type="text/css">
      H1 {
      color: #000000;
      font-family: helvetica,MS Sans Serif;
      font-weight: bold;
      font-size: 26px;
      }
      H2 {
      font-family: helvetica,MS Sans Serif;
      font-weight: bold;
      font-size: 20px; 
      text-decoration: none
      }
      
      a:link {
      text-decoration : none;
      color: #0000DD;
      } 
      
      a:visited {
      text-decoration : none;
      color: #0000DD;
      } 
      
      a:hover {
      text-decoration : underline; 
      } 
      
      .questionNumber {
      font-weight : bold;
      font-size : 16px;
      }
      
      .questionText {
      font-weight : bold;
      }

      .grade {}
      
      .optionNumber {
      font-weight : bold;
      font-size : 16px;
      }

      .markAnswer {
      background: #cccccc;
      }
      
      body { 
      background: url(pic/bg.jpg) fixed; 
      margin-top : 10px; 
      margin-right : 20px; 
      margin-bottom : 20px; 
      margin-left : 20px; 
      font-weight : normal;
      font-size : 14px;
      }

    </style>
  </xsl:template>

  <xsl:param name="readonly"/>
  
  <xsl:template match="exam_view">
    <html>
      <head>
	<xsl:call-template name="css"/>
	<title><xsl:value-of select="@title"/></title>
      </head>

      <body bgcolor="#FFFFFF" text="#000000">

	<table>
	  <tr>
	    <td><xsl:text>Asignatura: </xsl:text></td>
	    <td><xsl:value-of select="@course"/></td>
	  </tr>
	  <tr>
	    <td><xsl:text>Fecha: </xsl:text></td>
	    <td>
	      <xsl:call-template name="parsedate">
		<xsl:with-param name="date" select="@from"/>
	      </xsl:call-template>
	    </td>
	  </tr>
	  <tr>
	    <td><xsl:text>Asunto: </xsl:text></td>
	    <td><xsl:value-of select="@title"/></td>
	  </tr>
	  <tr>
	    <td><xsl:text>Usuario: </xsl:text></td>
	    <td><xsl:value-of select="@user"/></td>
	  </tr>	  
	</table>

	<br/>

	<form ACTION="http://arco.inf-cr.uclm.es/cgi/sate_main.py" METHOD="POST">
	  <xsl:apply-templates select="question"/> 

          <xsl:if test="not($readonly)">
            <input type="hidden" name="sate:phase" value="answer"/>
            <input type="hidden" name="sate:user" value="{@user}"/>
            <input type="hidden" name="sate:pass" value="{@pass}"/>
	    <input type="hidden" name="sate:course" value="{@course}"/>
	    <input type="hidden" name="sate:exam" value="{@id}"/>

	    <input TYPE="submit" Value="Aceptar"/>
          </xsl:if>
	</form>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="title">
    <h3>&#160;<xsl:value-of select="."/></h3>
  </xsl:template>


  <xsl:template match="question">

    <table cellpadding="0" cellspacing="0">
      <tr>
	<td class="questionNumber">
          <xsl:number value="position()" format="1" /><xsl:text>.&#160;</xsl:text>
	</td>
	<td>
          <font class="grade">(<xsl:value-of select="@grade"/>p)&#160;</font>
          <font class="questionText"><xsl:value-of select="text"/></font>
	</td>
      </tr>

      <xsl:apply-templates select="*[name()!='text']">
	<xsl:with-param name="id" select="concat(@topic,':',@id)"/>
      </xsl:apply-templates>

    </table>
    <br/>
  </xsl:template>


  <xsl:template match="question/option">
    <xsl:param name="id"/>
    <xsl:variable name="pos">
      <xsl:number value="position()" format="a" />
    </xsl:variable>
    <xsl:variable name="correct" select="$pos=../answer/@value"/>

    <tr>
      <td>&#160;</td>
      <xsl:element name="td">

	<xsl:if test="$correct">
	  <xsl:attribute name="class">
	    <xsl:text>markAnswer</xsl:text>
	  </xsl:attribute>
        </xsl:if>

	<xsl:element name="input">
	  <xsl:attribute name="type">radio</xsl:attribute>
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
	    <xsl:value-of select="$pos"/><xsl:text>. </xsl:text>
	</font>
	<xsl:value-of select="."/>
      </xsl:element>
    </tr>
  </xsl:template>


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
<!--	<input type="text" name="{$id}" size="{@size}" maxlength="{@size}"/> -->
<!--	<input type="hidden" name="{$id}.type" value="number"/> -->
      </td>
    </tr>
  </xsl:template>


<xsl:template match="answer"/>


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
<!--
	<textarea name="{$id}" rows="{@rows}" cols="{@cols}">
	  <xsl:text>&#160;</xsl:text>
	</textarea>
-->
      </td>
    </tr>
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

</xsl:stylesheet>

