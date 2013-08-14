<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="no"/>

<!--
  FlickrDownload - Copyright(C) 2007,2010 Brian Masney <masneyb@onstation.org>.
  If you have any questions, comments, or suggestions about this program, please
  feel free to email them to me. You can always find out the latest news about
  FlickrDownload from my website at http://www.onstation.org/flickrdownload/

  FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING
  file. This is free software, and you are welcome to redistribute it under
  certain conditions; for details, see the COPYING file.
-->


<xsl:template name="generate_all_rows_images">
 <xsl:param name="num_items"/>
 <xsl:param name="items_per_row"/>
 <xsl:param name="item_width"/>

 <xsl:variable name="num_rows" select="ceiling ($num_items div $items_per_row)"/>

 <table cellspacing="0" cellpadding="0">
   <xsl:if test="$item_width != ''">
     <xsl:attribute name="width"><xsl:value-of select="$item_width * $items_per_row"/></xsl:attribute>
     <xsl:attribute name="width"><xsl:value-of select="$item_width * $items_per_row"/></xsl:attribute>
   </xsl:if>

   <xsl:call-template name="generate_row_images">
     <xsl:with-param name="pos"><xsl:value-of select="1"/></xsl:with-param>
     <xsl:with-param name="stop_pos"><xsl:value-of select="$num_rows"/></xsl:with-param>
     <xsl:with-param name="items_per_row"><xsl:value-of select="$items_per_row"/></xsl:with-param>
     <xsl:with-param name="num_items"><xsl:value-of select="$num_items"/></xsl:with-param>
   </xsl:call-template>
 </table>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="generate_row_images">
  <xsl:param name="pos"/>
  <xsl:param name="stop_pos"/>
  <xsl:param name="items_per_row"/>
  <xsl:param name="num_items"/>

  <xsl:if test="($pos + 0) &lt;= ($stop_pos + 0)">
    <tr>
      <xsl:variable name="colpos" select="(($pos - 1) * ($items_per_row + 0)) + 1"/>

      <xsl:call-template name="display_all_items_on_row">
        <xsl:with-param name="pos"><xsl:value-of select="$colpos"/></xsl:with-param>
        <xsl:with-param name="stop_pos"><xsl:value-of select="$colpos + $items_per_row"/></xsl:with-param>
        <xsl:with-param name="num_items"><xsl:value-of select="$num_items"/></xsl:with-param>
      </xsl:call-template>
    </tr>

    <xsl:call-template name="generate_row_images">
      <xsl:with-param name="pos"><xsl:value-of select="$pos + 1"/></xsl:with-param>
      <xsl:with-param name="stop_pos"><xsl:value-of select="$stop_pos"/></xsl:with-param>
      <xsl:with-param name="items_per_row"><xsl:value-of select="$items_per_row"/></xsl:with-param>
      <xsl:with-param name="num_items"><xsl:value-of select="$num_items"/></xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="display_all_items_on_row">
  <xsl:param name="pos"/>
  <xsl:param name="stop_pos"/>
  <xsl:param name="num_items"/>

  <xsl:if test="($pos + 0) &lt; ($stop_pos + 0) and ($pos + 0) &lt;= ($num_items + 0)">
    <xsl:call-template name="display_item">
      <xsl:with-param name="pos"><xsl:value-of select="$pos"/></xsl:with-param>
    </xsl:call-template>
  
    <xsl:call-template name="display_all_items_on_row">
      <xsl:with-param name="pos"><xsl:value-of select="$pos + 1"/></xsl:with-param>
      <xsl:with-param name="stop_pos"><xsl:value-of select="$stop_pos"/></xsl:with-param>
      <xsl:with-param name="num_items"><xsl:value-of select="$num_items"/></xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template match="/flickr/sets/set" mode="set_summary">
  <td class="set_summary">
    <div class="set_thumb_div">
      <a>
        <xsl:attribute name="href"><xsl:value-of select="concat(id,'/index.html')"/></xsl:attribute>
        <img class="set_thumb_photo" src="{thumbnailFile/@localFilename}"/>
      </a>
    </div>

    <div>
      <a>
        <xsl:attribute name="href"><xsl:value-of select="concat(id,'/index.html')"/></xsl:attribute>
        <xsl:value-of select="title"/>
      </a>
    </div>

    <xsl:choose>
      <xsl:when test="media_stats/media[@type='Photo']/photo_counts/@total > 0">
        <div class="set_summary_num_photos">
          <xsl:value-of select="media_stats/media[@type='Photo']/photo_counts/@total"/>
          <xsl:text> photos</xsl:text>
  
          <xsl:if test="media_stats/media[@type='Video']/photo_counts/@total > 0">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="media_stats/media[@type='Video']/photo_counts/@total"/>
            <xsl:text> videos</xsl:text>
          </xsl:if>
        </div>
      </xsl:when>
      <xsl:when test="media_stats/media[@type='Video']/photo_counts/@total > 0">
        <div class="set_summary_num_photos">
          <xsl:value-of select="media_stats/media[@type='Video']/photo_counts/@total"/>
          <xsl:text> videos</xsl:text>
        </div>
      </xsl:when>
    </xsl:choose>
  </td>
</xsl:template>

</xsl:stylesheet>
