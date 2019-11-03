<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- EXPERIMENTAL I/O address decoder style sheet
  (c) 2013, Martin Strubel <hackfin@section5.ch>
-->

<xsl:stylesheet version="1.0" 
	xmlns:my="http://www.section5.ch/dclib/schema/devdesc"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

<!-- Key for register map reference -->
<xsl:key name="mapkey" match="my:registermap" use="@id"/>

<!-- Key for register reference -->
<xsl:key name="regkey" match="my:register" use="@id"/>

<xsl:variable name="lcase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="ucase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<xsl:template match="my:header">
<xsl:if test="@language = 'VHDL'">
<xsl:value-of select="."/>
</xsl:if>
</xsl:template>

</xsl:stylesheet>
