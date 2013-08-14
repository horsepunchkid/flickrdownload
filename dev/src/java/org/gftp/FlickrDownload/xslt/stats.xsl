<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:include href="common.xsl"/>
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="no"/>

<!--
  FlickrDownload - Copyright(C) 2010 Brian Masney <masneyb@onstation.org>.
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
        <xsl:text>Stats for </xsl:text>
        <xsl:value-of select="user/realname"/>
      </title>
    </head>
    <body>
      <xsl:apply-templates select="user" mode="header">
        <xsl:with-param name="title">
          <xsl:text>Stats for </xsl:text>
          <xsl:value-of select="user/realname"/>
        </xsl:with-param>
        <xsl:with-param name="baseDir">.</xsl:with-param>
      </xsl:apply-templates>

      <xsl:variable name="num_cols" select="count(media_stats/media)"/>

      <table width="100%" cellpadding="10">
        <tr>
          <xsl:for-each select="media_stats/media">
            <td valign="top" width="{100 div $num_cols}%">
              <table class="stats_table" width="100%" border="1">
                <tr class="title"><th colspan="2"><xsl:value-of select="@type"/> Privacy</th></tr>
                <tr class="odd"><td class="label">Public</td><td class="value"><xsl:value-of select="format-number(photo_counts/public, '###,###')"/></td></tr>
                <tr class="even"><td class="label">Friends/Family</td><td class="value"><xsl:value-of select="format-number(photo_counts/friendsAndFamily, '###,###')"/></td></tr>
                <tr class="odd"><td class="label">Friends Only</td><td class="value"><xsl:value-of select="format-number(photo_counts/friendsOnly, '###,###')"/></td></tr>
                <tr class="even"><td class="label">Family Only</td><td class="value"><xsl:value-of select="format-number(photo_counts/familyOnly, '###,###')"/></td></tr>
                <tr class="odd"><td class="label">Private</td><td class="value"><xsl:value-of select="format-number(photo_counts/private, '###,###')"/></td></tr>
                <tr class="total"><td class="label">Total</td><td class="value"><xsl:value-of select="format-number(photo_counts/@total, '###,###')"/></td></tr>
              </table>
            </td>
          </xsl:for-each>
        </tr>
        <tr>
          <xsl:for-each select="media_stats/media">
            <td valign="top" width="{100 div $num_cols}%">
              <table class="stats_table" width="100%" border="1">
                <tr><th class="title" colspan="2"><xsl:value-of select="@type"/>s Tagged</th></tr>
                <tr class="odd"><td class="label">Yes</td><td class="value"><xsl:value-of select="format-number(tagged/yes, '###,###')"/></td></tr>
                <tr class="even"><td class="label">No</td><td class="value"><xsl:value-of select="format-number(tagged/no, '###,###')"/></td></tr>
              </table>
            </td>
          </xsl:for-each>
        </tr>
        <tr>
          <xsl:for-each select="media_stats/media">
            <td valign="top" width="{100 div $num_cols}%">
              <table class="stats_table" width="100%" border="1">
                <tr><th class="title" colspan="2"><xsl:value-of select="@type"/>s Geotagged</th></tr>
                <tr class="odd"><td class="label">Yes</td><td class="value"><xsl:value-of select="format-number(geoTagged/yes, '###,###')"/></td></tr>
                <tr class="even"><td class="label">No</td><td class="value"><xsl:value-of select="format-number(geoTagged/no, '###,###')"/></td></tr>
              </table>
            </td>
          </xsl:for-each>
        </tr>
        <tr>
          <xsl:for-each select="media_stats/media">
            <td valign="top" width="{100 div $num_cols}%">
              <table class="stats_table" width="100%" border="1">
                <tr><th class="title" colspan="2"><xsl:value-of select="@type"/> Disk Space Usage</th></tr>
                <xsl:for-each select="disk_space/image">
                  <tr>
                    <xsl:attribute name="class">
                      <xsl:choose>
                        <xsl:when test="position() mod 2 = 0">
                          <xsl:text>even</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>odd</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>

                    <td class="label"><xsl:value-of select="@type"/></td>
                    <td class="value">
                      <xsl:call-template name="pretty_file_size">
                        <xsl:with-param name="size" select="."/>
                      </xsl:call-template>
                    </td>
                  </tr>
                </xsl:for-each>
                <tr class="total">
                  <td class="label">Total</td>
                  <td class="value">
                    <xsl:call-template name="pretty_file_size">
                      <xsl:with-param name="size" select="sum(disk_space/image)"/>
                    </xsl:call-template>
                  </td>
                </tr>
              </table>
            </td>
          </xsl:for-each>
        </tr>
        <tr>
          <xsl:for-each select="media_stats/media">
            <td valign="top" width="{100 div $num_cols}%">
              <table class="stats_table" width="100%" border="1">
                <tr><th class="title" colspan="2"><xsl:value-of select="@type"/> Licenses</th></tr>
                <xsl:for-each select="licenses/license">
                  <tr>
                    <xsl:attribute name="class">
                      <xsl:choose>
                        <xsl:when test="position() mod 2 = 0">
                          <xsl:text>even</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>odd</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>

                    <td class="label"><xsl:value-of select="@type"/></td>
                    <td class="value"><xsl:value-of select="format-number(., '###,###')"/></td>
                  </tr>
                </xsl:for-each>
              </table>
            </td>
          </xsl:for-each>
        </tr>
        <tr>
          <xsl:for-each select="media_stats/media">
            <td valign="top" width="{100 div $num_cols}%">
              <table class="stats_table" width="100%" border="1">
                <tr><th class="title" colspan="2">Duplicate <xsl:value-of select="@type"/>s</th></tr>
                <xsl:for-each select="duplicates/duplicate">
                  <tr>
                    <xsl:attribute name="class">
                      <xsl:choose>
                        <xsl:when test="position() mod 2 = 0">
                          <xsl:text>even</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>odd</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>

                    <td colspan="2" class="duplicate_images">
                      <xsl:for-each select="photo_id">
                        <xsl:if test="position() > 1">
                          <xsl:text> </xsl:text>
                        </xsl:if>
  
                        <a href="{/flickr/user/flickrUrls/@photos}{.}"><xsl:value-of select="."/></a>
                      </xsl:for-each>
                    </td>
                  </tr>
                </xsl:for-each>
              </table>
            </td>
          </xsl:for-each>
        </tr>
      </table>

      <table class="stats_table" width="100%" border="1">
        <tr class="title"><th colspan="10">Set Stats</th></tr>
        <tr><th></th><th>Title</th><th>ID</th><th># Public</th><th># Private</th><th># Friends Only</th><th># Family Only</th><th># Friends / Family</th><th>Storage Used</th><th>Storage Used (Cumulative)</th></tr>

        <xsl:for-each select="sets/set">
          <tr>
            <xsl:attribute name="class">
              <xsl:choose>
                <xsl:when test="position() mod 2 = 0">
                  <xsl:text>even</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>odd</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>

            <td><img src="{thumbnailFile/@localFilename}"/></td>
            <td class="title_col"><a href="{id}/index.html"><xsl:value-of select="title"/></a></td>
            <td class="id_col" ><xsl:value-of select="id"/></td>
            <td class="num_photos_col"><xsl:value-of select="format-number(sum(media_stats/media/photo_counts/public), '###,###')"/></td>
            <td class="num_photos_col"><xsl:value-of select="format-number(sum(media_stats/media/photo_counts/private), '###,###')"/></td>
            <td class="num_photos_col"><xsl:value-of select="format-number(sum(media_stats/media/photo_counts/friendsOnly), '###,###')"/></td>
            <td class="num_photos_col"><xsl:value-of select="format-number(sum(media_stats/media/photo_counts/familyOnly), '###,###')"/></td>
            <td class="num_photos_col"><xsl:value-of select="format-number(sum(media_stats/media/photo_counts/friendsAndFamily), '###,###')"/></td>
            <td class="storage_used_col">
              <xsl:call-template name="pretty_file_size">
                <xsl:with-param name="size" select="sum(media_stats/media/disk_space/image)"/>
              </xsl:call-template>
            </td>
            <td class="commulative_storage_used_col">
              <xsl:call-template name="pretty_file_size">
                <xsl:with-param name="size" select="sum(preceding-sibling::*/media_stats/media/disk_space/image) + sum(media_stats/media/disk_space/image)"/>
              </xsl:call-template>
            </td>
          </tr>
        </xsl:for-each>
      </table>

      <xsl:apply-templates select="user" mode="footer"/>
    </body>
  </html>
</xsl:template>

<!-- ********************************************************************** -->

<xsl:template name="show_extra_breadcrumbs">
</xsl:template>

</xsl:stylesheet>
