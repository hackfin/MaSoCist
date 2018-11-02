<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- Stylesheet for SoC configuration filter
(c) 2011-2015 Martin Strubel <hackfin@section5.ch>

This file is part of the MaSoCist opensource distribution.

-->

<xsl:stylesheet version="1.0" 
	xmlns="http://www.section5.ch/dclib/schema/devdesc"
	xmlns:my="http://www.section5.ch/dclib/schema/devdesc"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
	<xsl:output method="xml" encoding="ISO-8859-1" indent="yes" />	

	<xsl:key name="configkey" match="my:config" use="@id"/>

	<xsl:template match="my:devdesc">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="my:config">
		<xsl:text>	</xsl:text>
		<xsl:value-of select="@id"/> = <xsl:value-of select="."/>
		<xsl:text>
</xsl:text>
	</xsl:template>

	<!-- Copy all with a config processing instruction equal 'y' or missing -->

	<xsl:template match="node()|@*">
		<xsl:choose>
			<xsl:when test="./processing-instruction('config') and not(key('configkey',./processing-instruction('config'))='y')">
				<xsl:comment>Not emitting '<xsl:value-of select="@name"/>' </xsl:comment>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates/>
				</xsl:copy>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/">
		<xsl:comment>This is a GENERATED file. Editing may be void.</xsl:comment>

		<xsl:comment>
		<xsl:text> Configuration:
</xsl:text>
		<xsl:apply-templates select=".//my:config"/>
		<xsl:text>
</xsl:text>
		</xsl:comment>
		<devdesc>
		<xsl:apply-templates select=".//my:devdesc"/>
		</devdesc>
	</xsl:template>


</xsl:stylesheet>
