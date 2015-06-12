<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
  <xsl:output method="html" indent="yes"/>
  <xsl:template match="/">
    <script language="JavaScript">
      function hve_display(t_id){
      var t_id;
      if (t_id.style.display == "none") {
      t_id.style.display="";
      }
      else{
      t_id.style.display="none";
      }
      }
    </script>
    <style type="text/css">
    </style>
    <table align="left" cellpadding="2" cellspacing="5">
      <tr>
        <td style="font-family: Verdana; font-size: 20px; font-weight: bold;">Test Run Log:</td>
      </tr>
      <xsl:for-each select="Root-Logger/Testcase">
        <tr>
          <td style="font-family: Verdana; font-size: 15px;">
            <table width="800px" align="left" cellpadding="2" cellspacing="0" style="font-family: Verdana; font-size: 15px; word-wrap:break-word; table-layout:fixed">
              <tr>
                <td bgcolor="#808080">
                  <font color="#FFFFFF">
                    <b>Testcase Name</b>
                  </font>
                </td>
                <td bgcolor="#808080">
                  <font color="#FFFFFF">
                    <b>Result</b>
                  </font>
                </td>
              </tr>
              <tr>
                <xsl:choose>
                  <xsl:when test="EndTest/@Result = 'Fail'">
                    <td style="border: 1px solid #808080">
                      <B>
                        <font>
                          <xsl:value-of select="EndTest/@msg"/>
                        </font>
                      </B>
                    </td>
                    <td style="border: 1px solid #808080">
                      <B>
                        <font color = "red">
                          <xsl:value-of select="EndTest/@Result"/>
                        </font>
                      </B>
                    </td>
                  </xsl:when>
                  <xsl:when test="EndTest">
                    <td style="border: 1px solid #808080">
                      <B>
                        <xsl:value-of select="EndTest/@msg"/>
                      </B>
                    </td>
                    <td style="border: 1px solid #808080">
                      <B>
                        <font color = "green">
                          <xsl:value-of select="EndTest/@Result"/>
                        </font>
                      </B>
                    </td>
                  </xsl:when>
                </xsl:choose>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="font-family: Verdana; font-size: 15px;">
            <table width="800px" align="left" cellpadding="2" cellspacing="0" style="font-family: Verdana; font-size: 12px; word-wrap:break-word; table-layout:fixed">
              <tr>
                <td bgcolor="#808080" colspan = "2" style="cursor: hand">
                  <xsl:attribute name="onClick">
                    <xsl:text>hve_display(</xsl:text>
                    <xsl:value-of select="@id"/>
                    <xsl:text>)</xsl:text>
                  </xsl:attribute>
                  <font color="#FFFFFF">
                    <b>Detailed Log (Click for folding/unfolding)</b>
                  </font>
                </td>
              </tr>
            </table>
            <tr>
              <td>
                <xsl:attribute name="id">
                  <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:attribute name="style">
                  <xsl:text>display: "none"</xsl:text>
                </xsl:attribute>
                <table width="800px" align="left" cellpadding="2" cellspacing="0" style="font-family: Verdana; font-size: 12px; word-wrap:break-word; table-layout:fixed;">
                  <xsl:for-each select="*">
                    <tr>
                      <xsl:choose>
                        <xsl:when test="name(.) = 'Error'">
                          <td style="border: 1px solid #808080" width="200px">
                            <B>
                              <font color = "red">
                                <xsl:value-of select="@t"/>
                              </font>
                            </B>
                          </td>
                          <td style="border: 1px solid #808080">
                            <B>
                              <font color = "red">
                                Error:  <xsl:value-of select="@msg"/>
                              </font>
                            </B>
                          </td>
                        </xsl:when>
                        <xsl:when test="name(.)">
                          <td style="border: 1px solid #808080" width="200px">
                            <xsl:value-of select="@t"/>
                          </td>
                          <td style="border: 1px solid #808080">
                            <xsl:value-of select="@msg"/>
                          </td>
                        </xsl:when>
                      </xsl:choose>
                    </tr>
                  </xsl:for-each>
                </table>
              </td>
            </tr>
          </td>
        </tr>
        <tr>
          <td>
            <br />
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
</xsl:stylesheet>