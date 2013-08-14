<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:include href="settings.xsl"/>
<xsl:include href="common.xsl"/>
<xsl:include href="set_common.xsl"/>
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

<xsl:template match="/flickr">
  <html>
    <head>
      <link href="photos.css" rel="stylesheet" type="text/css"/>
      <title>
        <xsl:text>Collections from </xsl:text>
        <xsl:value-of select="user/realname"/>
      </title>
    </head>
    <body>
      <xsl:apply-templates select="user" mode="header">
        <xsl:with-param name="title">
          <xsl:text>Collections from </xsl:text>
          <xsl:value-of select="user/realname"/>
        </xsl:with-param>
        <xsl:with-param name="baseDir">.</xsl:with-param>
      </xsl:apply-templates>

      <xsl:for-each select="collections/collection">
        <h1><xsl:value-of select="title"/></h1>

        <center>
          <xsl:call-template name="generate_all_rows_images">
            <xsl:with-param name="num_items"><xsl:value-of select="count(sets/set)"/></xsl:with-param>
            <xsl:with-param name="items_per_row">6</xsl:with-param>
          </xsl:call-template>
        </center>
      </xsl:for-each>

      <xsl:apply-templates select="user" mode="footer"/>
    </body>
  </html>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="display_item">
<xsl:param name="pos"/>

<xsl:variable name="id"><xsl:value-of select="sets/set[$pos + 0]/@id"/></xsl:variable>
<xsl:apply-templates select="/flickr/sets/set[id=$id]" mode="set_summary"/>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="show_extra_breadcrumbs">
</xsl:template>

</xsl:stylesheet>
