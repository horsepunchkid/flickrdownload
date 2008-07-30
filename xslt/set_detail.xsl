<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" version="1.0">
<xsl:include href="settings.xsl"/>
<xsl:output method="html"/>

<!--
  FlickrDownload - Copyright(C) 2007-2008 Brian Masney <masneyb@gftp.org>.
  If you have any questions, comments, or suggestions about this program, please
  feel free to email them to me. You can always find out the latest news about
  FlickrDownload from my website at http://www.gftp.org/FlickrDownload/

  FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING
  file. This is free software, and you are welcome to redistribute it under
  certain conditions; for details, see the COPYING file.

  Brian Masney <masneyb@gftp.org>
-->

<xsl:template match="/set">
  <html>
    <head>
      <link href="../photos.css" rel="stylesheet" type="text/css"/>
      <title>Detailed view of '<xsl:value-of select="title"/>'</title>
    </head>
    <body>
      <h1><xsl:value-of select="title"/></h1>
      <div class="set_description"><xsl:value-of select="description"/></div>

      <xsl:variable name="num_rows" select="ceiling (count (photo) div $detail_photos_per_row)"/>

      <center>
      <table cellspacing="0" cellpadding="0" class="set_detail">
        <xsl:call-template name="generate_row">
          <xsl:with-param name="pos"><xsl:value-of select="1"/></xsl:with-param>
          <xsl:with-param name="stop_pos"><xsl:value-of select="$num_rows"/></xsl:with-param>
          <xsl:with-param name="photos_per_row"><xsl:value-of select="$detail_photos_per_row"/></xsl:with-param>
        </xsl:call-template>
      </table>
      </center>

      <div class="back_to_main"><a href="../index.html">Back to sets</a></div>

      <xsl:if test="footerMessage">
        <div class="copyright"><xsl:copy-of select="footerMessage"/></div>
      </xsl:if>
    </body>
  </html>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="generate_row">
<xsl:param name="pos"/>
<xsl:param name="stop_pos"/>
<xsl:param name="photos_per_row"/>

<xsl:if test="$pos &lt;= $stop_pos">
  <tr>
    <xsl:variable name="colpos" select="($pos - 1) * $photos_per_row + 1"/>

    <xsl:call-template name="display_photos_on_row">
      <xsl:with-param name="pos"><xsl:value-of select="$colpos"/></xsl:with-param>
      <xsl:with-param name="stop_pos"><xsl:value-of select="$colpos + $photos_per_row"/></xsl:with-param>
    </xsl:call-template>
  </tr>

  <xsl:call-template name="generate_row">
    <xsl:with-param name="pos"><xsl:value-of select="$pos + 1"/></xsl:with-param>
    <xsl:with-param name="stop_pos"><xsl:value-of select="$stop_pos"/></xsl:with-param>
    <xsl:with-param name="photos_per_row"><xsl:value-of select="$photos_per_row"/></xsl:with-param>
  </xsl:call-template>
</xsl:if>

</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="display_photos_on_row">
<xsl:param name="pos"/>
<xsl:param name="stop_pos"/>

<xsl:if test="$pos &lt; $stop_pos">
  <xsl:if test="photo[$pos + 0]">
    <xsl:call-template name="display_photo">
      <xsl:with-param name="pos"><xsl:value-of select="$pos"/></xsl:with-param>
    </xsl:call-template>
  </xsl:if>

  <xsl:call-template name="display_photos_on_row">
    <xsl:with-param name="pos"><xsl:value-of select="$pos + 1"/></xsl:with-param>
    <xsl:with-param name="stop_pos"><xsl:value-of select="$stop_pos"/></xsl:with-param>
  </xsl:call-template>
</xsl:if>

</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="display_photo">
  <xsl:param name="pos"/>
  <xsl:variable name="filename" select="concat(photo[$pos + 0]/id,'.html')" />

  <td halign="center" valign="top" class="detail_photo">
    <center>
    <div class="detail_photo_title"><xsl:value-of select="photo[$pos + 0]/title"/></div>
    <a title="{photo[$pos + 0]/title}">
      <xsl:attribute name="href"><xsl:value-of select="$filename"/></xsl:attribute>
      <img class="thumbnail_photo" src="{photo[$pos + 0]/mediumFile}"/>
    </a>

    <div class="detail_photo_description"><xsl:value-of select="photo[$pos + 0]/description"/></div>
    </center>
  </td>
</xsl:template>

</xsl:stylesheet>
