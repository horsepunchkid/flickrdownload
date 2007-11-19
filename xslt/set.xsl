<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" version="1.0">
<xsl:include href="settings.xsl"/>
<xsl:output method="html"/>

<!--
  FlickrDownload - Copyright(C) 2007 Brian Masney <masneyb@gftp.org>.
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
      <title><xsl:value-of select="title"/></title>
    </head>
    <body>
      <h1><xsl:value-of select="title"/></h1>
      <div class="set_description"><xsl:value-of select="description"/></div>

      <xsl:variable name="num_rows" select="ceiling (count (photo) div $photos_per_row)"/>

      <center>
      <table cellspacing="0" cellpadding="0">
        <xsl:attribute name="width">
          <xsl:choose>
            <xsl:when test="count (photo) &lt; $photos_per_row">
              <xsl:value-of select="$thumbnail_width * count (photo)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$thumbnail_width * $photos_per_row"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>

        <xsl:call-template name="generate_row">
          <xsl:with-param name="pos"><xsl:value-of select="1"/></xsl:with-param>
          <xsl:with-param name="stop_pos"><xsl:value-of select="$num_rows"/></xsl:with-param>
          <xsl:with-param name="photos_per_row"><xsl:value-of select="$photos_per_row"/></xsl:with-param>
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

  <exsl:document href="{$filename}" method="html">
    <html>
      <head>
        <link href="../photos.css" rel="stylesheet" type="text/css"/>
        <title><xsl:value-of select="photo[$pos + 0]/title"/></title>
      </head>
      <body>
        <table class="photo_table">
          <td class="photo_side">
            <div class="photo_title"><xsl:value-of select="photo[$pos + 0]/title"/></div>
            <a href="{originalFile}"><img class="medium_photo" src="{photo[$pos + 0]/mediumFile}"/></a>
            <div class="photo_description"><xsl:value-of select="photo[$pos + 0]/description"/></div>
          </td>
          <td class="info_side">
            <table class="photo_nav">
              <tr>
                <td colspan="2" class="photo_nav_header">Photo Navigation</td>
              </tr>
              <tr>
              <td align="center" class="photo">
                <xsl:if test="$pos > 1">
                  <a title="{photo[$pos - 1]/title}">
                    <xsl:attribute name="href"><xsl:value-of select="concat(photo[$pos - 1]/id,'.html')"/></xsl:attribute>
                    <img class="thumb_photo" src="{photo[$pos - 1]/thumbnailFile}"/>
                  </a>
                </xsl:if>
              </td>
              <td align="center" class="photo">
                <xsl:if test="photo[$pos + 1]">
                  <a title="{photo[$pos + 1]/title}">
                    <xsl:attribute name="href"><xsl:value-of select="concat(photo[$pos + 1]/id,'.html')"/></xsl:attribute>
                    <img class="thumb_photo" src="{photo[$pos + 1]/thumbnailFile}"/>
                  </a>
                </xsl:if>
              </td>
              </tr>
              <tr>
                <td colspan="2" class="back_to_main"><a href="index.html">Back to Index</a></td>
              </tr>
            </table>

            <div class="date_taken">Date Taken: <xsl:value-of select="photo[$pos + 0]/dateTaken"/></div>
            <div class="download_links">Download Image: <a href="{photo[$pos + 0]/originalFile}">Large</a>, <a href="{photo[$pos + 0]/mediumFile}">Medium</a> or <a href="{photo[$pos + 0]/thumbnailFile}">Small</a></div>

            <xsl:if test="photo[$pos + 0]/privacy">
              <div class="privacy">Privacy: <xsl:value-of select="photo[$pos + 0]/privacy"/></div>
            </xsl:if>
          </td>
        </table>

        <xsl:if test="footerMessage">
          <div class="copyright"><xsl:copy-of select="footerMessage"/></div>
        </xsl:if>
      </body>
    </html>
  </exsl:document>

  <td align="center" class="photo">
    <a title="{photo[$pos + 0]/title}">
      <xsl:attribute name="href"><xsl:value-of select="$filename"/></xsl:attribute>
      <img class="thumbnail_photo" width="{$thumbnail_width}" height="{$thumbnail_height}" src="{photo[$pos + 0]/thumbnailFile}"/>
    </a>
  </td>
</xsl:template>

</xsl:stylesheet>
