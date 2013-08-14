<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:include href="settings.xsl"/>
<xsl:include href="common.xsl"/>
<xsl:include href="set_common.xsl"/>
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="no"/>

<xsl:param name="date"/>

<!--
  FlickrDownload - Copyright(C) 2011 Brian Masney <masneyb@onstation.org>.
  If you have any questions, comments, or suggestions about this program, please
  feel free to email them to me. You can always find out the latest news about
  FlickrDownload from my website at http://www.onstation.org/flickrdownload/

  FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING
  file. This is free software, and you are welcome to redistribute it under
  certain conditions; for details, see the COPYING file.
-->

<xsl:template match="/index">
  <html>
    <head>
      <link href="photos.css" rel="stylesheet" type="text/css"/>
      <title>
        <xsl:text>Archive for </xsl:text>
        <xsl:value-of select="user/realname"/>
      </title>
    </head>
    <body>
      <xsl:apply-templates select="user" mode="header">
        <xsl:with-param name="title">
          <xsl:text>Archive for </xsl:text>
          <xsl:value-of select="user/realname"/>
        </xsl:with-param>
        <xsl:with-param name="baseDir">.</xsl:with-param>
      </xsl:apply-templates>

      <table class="archive">
        <tr class="archive_title_bar">
          <td class="archive_current_month">
            <xsl:value-of select="/index/by_date_taken/date[@raw=$date]/@month"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="/index/by_date_taken/date[@raw=$date]/@year"/>
          </td>
        </tr>
        <tr>
          <td class="archive_photos">
            <xsl:call-template name="generate_all_rows_images">
              <xsl:with-param name="num_items"><xsl:value-of select="count(/index/by_date_taken/date[@raw=$date]/media)"/></xsl:with-param>
              <xsl:with-param name="items_per_row">6</xsl:with-param>
              <xsl:with-param name="item_width">75</xsl:with-param>
            </xsl:call-template>
          </td>
        </tr>
      </table>
    </body>
  </html>
</xsl:template>


<!-- ********************************************************************** -->

<xsl:template name="display_item">
  <xsl:param name="pos"/>

  <td align="center" class="photo">
    <xsl:variable name="media_id" select="/index/by_date_taken/date[@raw=$date]/media[$pos + 0]/@id"/>
    <xsl:apply-templates select="/index/all_media/media[id=$media_id]"/>
  </td>
</xsl:template>


<xsl:template match="/index/all_media/media">
  <xsl:variable name="baseFilename" select="concat(id,'.html')" />

  <a title="{title}" href="{sets/set[1]/@id}/{$baseFilename}">
    <xsl:if test="@type='video'">
      <xsl:attribute name="class">video_thumbnail</xsl:attribute>
    </xsl:if>

    <img class="thumbnail_photo" width="{$thumbnail_width}" height="{$thumbnail_height}" src="{sets/set[1]/@id}/{image[@type='Small Square']/@localFilename}"/>

    <xsl:if test="@type='video'">
      <span class="play_icon"><img src="../play_icon.png" width="{$thumbnail_width}" height="{$thumbnail_height}" alt="Play"/></span>
    </xsl:if>
  </a>
</xsl:template>



<!-- ********************************************************************** -->

<xsl:template name="show_extra_breadcrumbs">
</xsl:template>

</xsl:stylesheet>
