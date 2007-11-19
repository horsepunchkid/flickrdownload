<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:include href="settings.xsl"/>
<xsl:output method="xml"/>

<!-- Brian Masney <masneyb@gftp.org> -->

<xsl:template match="/sets">
  <html>
    <head>
      <link href="photos.css" rel="stylesheet" type="text/css"/>
      <xsl:choose>
        <xsl:when test="title">
          <title><xsl:value-of select="title"/></title>
        </xsl:when>
        <xsl:otherwise>
          <title>Photos</title>
        </xsl:otherwise>
      </xsl:choose>
    </head>
    <body>
      <xsl:if test="title">
        <h1><xsl:value-of select="title"/></h1>
      </xsl:if>

      <xsl:if test="description">
        <div class="set_description"><xsl:copy-of select="description/node()"/></div>
      </xsl:if>

      <center>
      <table class="set_table">
        <xsl:variable name="num_rows" select="ceiling (count (set) div $sets_per_row)"/>

        <xsl:call-template name="generate_row">
          <xsl:with-param name="pos"><xsl:value-of select="1"/></xsl:with-param>
          <xsl:with-param name="stop_pos"><xsl:value-of select="$num_rows"/></xsl:with-param>
          <xsl:with-param name="sets_per_row"><xsl:value-of select="$sets_per_row"/></xsl:with-param>
        </xsl:call-template>
      </table>
      </center>

      <div class="copyright"><xsl:copy-of select="$copyright"/></div>
    </body>
  </html>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="generate_row">
<xsl:param name="pos"/>
<xsl:param name="stop_pos"/>
<xsl:param name="sets_per_row"/>

<xsl:if test="$pos &lt;= $stop_pos">
  <tr class="set_row">
    <xsl:variable name="colpos" select="($pos - 1) * $sets_per_row + 1"/>

    <xsl:call-template name="display_sets_on_row">
      <xsl:with-param name="pos"><xsl:value-of select="$colpos"/></xsl:with-param>
      <xsl:with-param name="stop_pos"><xsl:value-of select="$colpos + $sets_per_row"/></xsl:with-param>
    </xsl:call-template>
  </tr>

  <xsl:call-template name="generate_row">
    <xsl:with-param name="pos"><xsl:value-of select="$pos + 1"/></xsl:with-param>
    <xsl:with-param name="stop_pos"><xsl:value-of select="$stop_pos"/></xsl:with-param>
    <xsl:with-param name="sets_per_row"><xsl:value-of select="$sets_per_row"/></xsl:with-param>
  </xsl:call-template>
</xsl:if>

</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="display_sets_on_row">
<xsl:param name="pos"/>
<xsl:param name="stop_pos"/>

<xsl:if test="$pos &lt; $stop_pos">
  <xsl:call-template name="display_set">
    <xsl:with-param name="pos"><xsl:value-of select="$pos"/></xsl:with-param>
  </xsl:call-template>
  
  <xsl:call-template name="display_sets_on_row">
    <xsl:with-param name="pos"><xsl:value-of select="$pos + 1"/></xsl:with-param>
    <xsl:with-param name="stop_pos"><xsl:value-of select="$stop_pos"/></xsl:with-param>
  </xsl:call-template>
</xsl:if>

</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="display_set">
<xsl:param name="pos"/>

<xsl:if test="set[$pos + 0]">
  <td class="set_summary">
    <div class="set_thumb_div">
      <a>
        <xsl:attribute name="href"><xsl:value-of select="concat(set[$pos + 0]/directory,'/index.html')"/></xsl:attribute>
        <img class="set_thumb_photo" src="{set[$pos + 0]/thumbnailFile}"/>
      </a>
    </div>
    <a>
      <xsl:attribute name="href"><xsl:value-of select="concat(set[$pos + 0]/directory,'/index.html')"/></xsl:attribute>
      <xsl:value-of select="set[$pos + 0]/title"/>
    </a>
  </td>
</xsl:if>
</xsl:template>

</xsl:stylesheet>
