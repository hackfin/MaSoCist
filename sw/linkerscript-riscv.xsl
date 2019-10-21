<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" 
	xmlns:my="http://www.section5.ch/dclib/schema/devdesc"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

	<xsl:output method="text" encoding="ISO-8859-1"/>	

	<xsl:template match="my:header">
	<xsl:if test="@language = 'LINKERSCRIPT'">
<xsl:value-of select="."/>
	</xsl:if>
	</xsl:template>

	<xsl:template match="my:memorymap">
<xsl:text>	</xsl:text>
	<xsl:value-of select="@name"/>(<xsl:value-of select="@access"/>)  : ORIGIN =  <xsl:value-of select="@offset"/>, LENGTH = <xsl:value-of select="@size"/>
<xsl:text>
</xsl:text>
	</xsl:template>

	<xsl:template match="my:section">
<xsl:text>	</xsl:text>
<xsl:value-of select="@name"/>
<xsl:text> :
	{
</xsl:text>
	<xsl:value-of select="my:linkerscript"/>
<xsl:text>
	} > </xsl:text>
<xsl:value-of select="@target"/>
<xsl:text>

</xsl:text>
	</xsl:template>

<xsl:template match="/">
<xsl:text>/* Generated linker script
 *
 * Only modify this file when it has a XSL extension.
 *
 * 2004-2018, Martin Strubel &lt;hackfin@section5.ch&gt;
 *
 */

</xsl:text>

<xsl:apply-templates select=".//my:header"/>

MEMORY
{
<xsl:apply-templates select=".//my:memorymap"/>
}

SECTIONS
{
<xsl:apply-templates select=".//my:section"/>

<xsl:text>/* Extra stuff */

	/* Set the start of the stack to the top of RAM: */
	__stack_top = 0x00018000-4;

	/DISCARD/ :
	{
		*(.comment)
	}

}
</xsl:text>

</xsl:template>

</xsl:stylesheet>

