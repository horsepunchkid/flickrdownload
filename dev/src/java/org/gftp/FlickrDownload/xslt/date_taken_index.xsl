<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:include href="common.xsl"/>
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="no"/>

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

      <table>
        <xsl:for-each select="by_date_taken/years/year">
          <tr class="year_row">
            <td class="year_col"><xsl:value-of select="@value"/></td>

            <td class="month_col">
              <xsl:for-each select="month">
                <xsl:variable name="raw" select="@raw"/>

                <a>
                  <xsl:attribute name="href">
                    <xsl:text>photos-taken-on-</xsl:text>
                    <xsl:value-of select="@raw"/>
                    <xsl:text>.html</xsl:text>
                  </xsl:attribute>
      
                  <div class="month">
                    <xsl:value-of select="@month"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="count(/index/by_date_taken/date[@raw=$raw]/media)"/>
                    <xsl:text>)</xsl:text>
                  </div>
                </a>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:for-each>
      </table>
    </body>
  </html>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="show_extra_breadcrumbs">
</xsl:template>

</xsl:stylesheet>
