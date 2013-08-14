<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
<xsl:include href="settings.xsl"/>
<xsl:include href="common.xsl"/>
<xsl:include href="set_common.xsl"/>
<xsl:output name="photo-format" method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="no"/>

<xsl:param name="PHOTOS_BASE_DIR"/>

<!--
  FlickrDownload - Copyright(C) 2007,2010 Brian Masney <masneyb@onstation.org>.
  If you have any questions, comments, or suggestions about this program, please
  feel free to email them to me. You can always find out the latest news about
  FlickrDownload from my website at http://www.onstation.org/flickrdownload/

  FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING
  file. This is free software, and you are welcome to redistribute it under
  certain conditions; for details, see the COPYING file.
-->

<xsl:template match="/set">
  <html>
    <head>
      <link href="../photos.css" rel="stylesheet" type="text/css"/>
      <title><xsl:value-of select="title"/></title>
    </head>
    <body>
      <xsl:apply-templates select="user" mode="header">
        <xsl:with-param name="title"><xsl:value-of select="title"/></xsl:with-param>
        <xsl:with-param name="baseDir">..</xsl:with-param>
      </xsl:apply-templates>

      <center>
        <xsl:call-template name="generate_all_rows_images">
          <xsl:with-param name="num_items"><xsl:value-of select="count(media)"/></xsl:with-param>
          <xsl:with-param name="items_per_row">2</xsl:with-param>
        </xsl:call-template>
      </center>

      <xsl:apply-templates select="user" mode="footer"/>
    </body>
  </html>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="display_item">
  <xsl:param name="pos"/>

  <xsl:variable name="filename" select="concat(media[$pos + 0]/id,'.html')" />

  <td halign="center" valign="top" class="detail_photo">
    <center>
      <a title="{media[$pos + 0]/title}">
        <xsl:attribute name="href"><xsl:value-of select="$filename"/></xsl:attribute>
        <img class="thumbnail_photo" src="{media[$pos + 0]/image[@type='Medium']/@localFilename}"/>
      </a>

      <div class="photo_title"><xsl:value-of select="media[$pos + 0]/title"/></div>
      <div class="photo_description"><xsl:value-of select="media[$pos + 0]/description"/></div>
    </center>
  </td>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="show_extra_breadcrumbs">
  <span class="header_breadcrumb"><a href="index.html">Set Thumbnails</a></span>
  <span class="header_breadcrumb"><a href="detail.html">Set Details</a></span>
</xsl:template>

</xsl:stylesheet>
