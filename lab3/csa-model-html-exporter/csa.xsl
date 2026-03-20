<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tns="ProfileDataSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>









<xsl:template name="node" >
	<xsl:value-of select="@name"/>
</xsl:template>

<xsl:template name="link">
	<xsl:value-of select="@name"/>
{
	<xsl:value-of select="@probability"/>
,
	<xsl:value-of select="@intensity"/>
},
</xsl:template>




<xsl:template match="/">
<body>
Tops = {
<xsl:for-each select="model/node">
    <xsl:call-template name="node"/>
,
</xsl:for-each>
}

<br/>
<br/>

Arcs = {
<br/>
<xsl:for-each select="model/link">
    <xsl:call-template name="link"/>
<br/>
</xsl:for-each>
}

</body>
</xsl:template>

</xsl:stylesheet>


<!-- =========================  -->
