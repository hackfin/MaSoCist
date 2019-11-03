<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- (c) 2003-2019 section5.ch

This file is subject to the MaSoCist open source license.
Please respect OpenSource and contribute valuable changes!

-->

<xsl:stylesheet version="1.0" 
	xmlns:my="http://www.section5.ch/dclib/schema/devdesc"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

<xsl:import href="hexutils.xsl"/>	
<xsl:import href="map.xsl"/>	

<xsl:output method="xml" encoding="ISO-8859-1" indent="yes" doctype-system="/usr/share/xml/docbook/schema/dtd/4.5/docbookx.dtd" doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"/>	

<xsl:param name="mmr_base">0xff8000</xsl:param>
<xsl:param name="addr_string_len">6</xsl:param>

<xsl:key name="unitkey" match="my:group[@name='UNIT_MAP']/my:property/my:choice/my:item" use="@name"/>
<xsl:key name="devkey" match="my:group[@name='UNIT_MAP']/my:struct[@name='SelectDevice']/my:property" use="@name"/>

<xsl:template name="resolve_regref_lsb">
	<xsl:param name="which"/>
	<xsl:variable name="val" select="key('regkey',$which/@ref)/my:bitfield[@name=$which/@bits]/@lsb"/>
	<xsl:choose>
	<xsl:when test="$val">
		<xsl:value-of select="number($val)"/>
	</xsl:when>
	<xsl:otherwise>-1</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="resolve_address">
	<xsl:param name="entity"/>
	<xsl:param name="index"/>
	<xsl:variable name="base">
		<xsl:call-template name="shiftleft">
				<xsl:with-param name="i"> 
					<xsl:call-template name="resolve_regref_lsb">
						<xsl:with-param name="which" select="key('unitkey', $entity/@name)/../../my:regref"/>
					</xsl:call-template>
				</xsl:with-param>

				<xsl:with-param name="val" select="key('unitkey', $entity/@name)/my:value"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="offs">
		<xsl:call-template name="shiftleft">
				<xsl:with-param name="i"> 
					<xsl:call-template name="resolve_regref_lsb">
						<xsl:with-param name="which" select="key('devkey', $entity/@name)/my:regref"/>
					</xsl:call-template>
				</xsl:with-param>

				<xsl:with-param name="val" select="$index"/>
		  </xsl:call-template>
	</xsl:variable>
	<xsl:variable name="mmr_base_addr">
		<xsl:call-template name="hex2dec">
			<xsl:with-param name="num" select="substring($mmr_base, 3)"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="hexval">
		<xsl:call-template name="dec2hex">
			<xsl:with-param name="dec" select="$mmr_base_addr + $base + $offs" />
		</xsl:call-template>
	</xsl:variable>
	<systemitem>
	<xsl:text>0x</xsl:text>
	<xsl:call-template name="str-pad">
		<xsl:with-param name="string" select="$hexval"/>
		<xsl:with-param name="pad-char" select="0"/>
		<xsl:with-param name="str-length" select="$addr_string_len"/>
	</xsl:call-template>
	</systemitem>
</xsl:template>

<xsl:template name="gen_array">
	<xsl:param name="n"/>

	<xsl:if test="$n > 0">
		<xsl:call-template name="gen_array">
			<xsl:with-param name="n" select="$n - 1"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:variable name="regmap" select="key('mapkey', @name)"/>

	<row>
		<entry><xsl:value-of select="$regmap/@name"/><xsl:value-of select="number($n)"/></entry>
		<entry>

			<xsl:call-template name="resolve_address">
				<xsl:with-param name="entity" select="."/>
				<xsl:with-param name="index" select="$n"/>
			</xsl:call-template>

		</entry>
		<entry><xsl:value-of select="my:info"/></entry>
		<entry>
			<xref><xsl:attribute name="linkend">sec_<xsl:value-of select="@name"/></xsl:attribute></xref>
		</entry>
	</row>

</xsl:template>

<xsl:template match="my:array" mode="unit_list">
	<xsl:variable name="num" select="my:size/my:value"/>
	<xsl:variable name="regmap" select="key('mapkey', @name)"/>
	<xsl:choose>
	<xsl:when test="number($num)=number($num)">
		<xsl:call-template name="gen_array">
			<xsl:with-param name="n" select="$num - 1"/>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	<row>
		<entry><xsl:value-of select="$regmap/@name"/>
	<xsl:text>[0..</xsl:text><xsl:value-of select="$num"/>]</entry>
		<entry>
			<xsl:call-template name="resolve_address">
				<xsl:with-param name="entity" select="."/>
				<xsl:with-param name="index" select="0"/>
			</xsl:call-template>
	<xsl:text>, </xsl:text>
			<xsl:call-template name="resolve_address">
				<xsl:with-param name="entity" select="."/>
				<xsl:with-param name="index" select="1"/>
			</xsl:call-template>
	<xsl:text>, ..</xsl:text>

		</entry>
		<entry><xsl:value-of select="my:info"/></entry>
		<entry><xref><xsl:attribute name="linkend">sec_<xsl:value-of select="@name"/></xsl:attribute></xref></entry>
	</row>


	</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template match="my:property|my:struct" mode="unit_list">
	<xsl:variable name="regmap" select="key('mapkey', @name)"/>
	<row>
		<entry><xsl:value-of select="$regmap/@name"/></entry>
		<entry>
			<xsl:call-template name="resolve_address">
				<xsl:with-param name="entity" select="."/>
				<xsl:with-param name="index" select="0"/>
			</xsl:call-template>

		</entry>
		<entry><xsl:value-of select="my:info"/></entry>
		<entry><xref><xsl:attribute name="linkend">sec_<xsl:value-of select="@name"/></xsl:attribute></xref></entry>
	</row>
</xsl:template>


<xsl:template match="my:device">
	<section><title>Device I/O map</title>

	<table floatstyle="H">
		<xsl:choose>
			<xsl:when test="@id">
				<xsl:attribute name="id">tbl_devicemap_<xsl:value-of select="@id"/></xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="id">tbl_devicemap_<xsl:value-of select="generate-id()"/></xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>

		<title>Device map <xsl:value-of select="@name"/> 
		</title>

		<tgroup cols="4">
			<colspec align="left" colnum="1" colwidth="4*"></colspec>
			<colspec align="left" colnum="2" colwidth="2*"></colspec>
			<colspec align="justify" colnum="3" colwidth="4*"></colspec>
			<colspec align="left" colnum="4" colwidth="2*"></colspec>
			<thead>
				<row>
					<entry>Device id</entry>
					<entry>Address base</entry>
					<entry>Description</entry>
					<entry>Details</entry>
				</row>
			</thead>
			<tbody>
				<xsl:apply-templates select=".//my:group[@name='INSTANCES']/my:property|.//my:group[@name='INSTANCES']/my:struct|.//my:group[@name='INSTANCES']/my:array" mode="unit_list" />
			</tbody>
		</tgroup>
	</table>

	</section>

</xsl:template>

<xsl:template match="/">
	<chapter><title>Device hardware properties</title>
	<xsl:apply-templates select=".//my:device"/>
	</chapter>
</xsl:template>

</xsl:stylesheet>
