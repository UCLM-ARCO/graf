<!--
    <xsl:if test="position()!=last()">
      <xsl:text>\mbox{} \\[0.5cm] &#10;</xsl:text>
    </xsl:if>

    <xsl:apply-templates
	select="*[name()!='item' and name()!='freetext']"/>

    <xsl:text>{\fontsize{8pt}{8pt} \selectfont&#10;</xsl:text>

    <xsl:if test="name()='part' and position()!=1">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:text>\mbox{} \\[0.3cm] </xsl:text>


  <xsl:template match="hline">
    <xsl:text>
    \hbox to \textwidth{\enspace\hrulefill}
    \bigskip
    </xsl:text>
  </xsl:template>


-->
