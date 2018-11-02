<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- This is the simple MIPS bus mapping gdbscript generator
-->

<xsl:stylesheet version="1.0" 
	xmlns:my="http://www.section5.ch/dclib/schema/devdesc"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

	<xsl:output method="text" encoding="ISO-8859-1"/>	

	<!-- Register definition prefix -->
	<xsl:param name="regprefix">Reg_</xsl:param>
	<!-- Index of desired device -->
	<xsl:param name="selectDevice">1</xsl:param>
	<!-- If set, convert bit fields -->
	<xsl:param name="convertBitfields">0</xsl:param>
	<!-- If 1, use parent register map's name as prefix -->
	<xsl:param name="useMapPrefix">0</xsl:param>
	<xsl:variable name="index" select="number($selectDevice)"></xsl:variable>

	<xsl:key name="regkey" match="my:register" use="@id"/>
	<xsl:key name="multi_inst_key" match="my:group[@name='INSTANCES']/my:array" use="@name"/>

	<!-- Register C type according to size field -->
	<xsl:template match="my:register" mode="ctype">
		<xsl:choose>
		<xsl:when test="@size = 1">
			<xsl:text> (unsigned char *) </xsl:text>
		</xsl:when>
		<xsl:when test="@size = 2">
			<xsl:text> (unsigned short *) </xsl:text>
		</xsl:when>
		<xsl:when test="@size = 4">
			<xsl:text> (unsigned long *) </xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text> (unsigned short *) </xsl:text>
		</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="my:item" mode="unit_map">
	<xsl:text>set $UNIT_</xsl:text>
	<xsl:value-of select="@name"/> = <xsl:value-of select="my:value"/>
	<xsl:text>
</xsl:text>
	</xsl:template>

	<xsl:template match="my:register" mode="reg_dump">
def dump_<xsl:if test="$useMapPrefix &gt; 0"><xsl:value-of select="../@name"/>_</xsl:if><xsl:value-of select="@id"/>
	<xsl:variable name="regname">$<xsl:value-of select="$regprefix"/><xsl:if test="$useMapPrefix &gt; 0"><xsl:value-of select="../@name"/>_</xsl:if><xsl:value-of select="@id"/></xsl:variable>

	<xsl:choose>
		<xsl:when test="key('multi_inst_key',../@id)">
	set $index = $arg0
		</xsl:when>
		<xsl:otherwise>
	set $index = 0
		</xsl:otherwise>
	</xsl:choose>
	_get_indexed_reg <xsl:value-of select="$regname"/> $index $MMR_SELECT_DEVINDEX_<xsl:value-of select="../@name"/>_SHFT
	printf "<xsl:value-of select="@id"/>:\t"
	<xsl:choose>
		<xsl:when test="./my:bitfield">
<xsl:apply-templates select=".//my:bitfield" mode="reg_dump"/>
	printf "\n"
		</xsl:when>
		<xsl:otherwise>
	_dump_reg($r)
		</xsl:otherwise>
	</xsl:choose>
end
	</xsl:template>

	<!-- Register definition/declaration and reference -->
	<xsl:template match="my:registermap" mode="init_shiftvals">
	<xsl:text>set $SELECT_DEVINDEX_</xsl:text>
	<xsl:value-of select="@name"/><xsl:text>_SHFT = 0
</xsl:text>	</xsl:template>

	<xsl:template match="my:registermap" mode="reg_decl">
##########################################################
#  Address segment '<xsl:value-of select="@name"/>'<xsl:if test="./my:info">
# 
#  <xsl:value-of select="./my:info"/></xsl:if>
##########################################################
		<xsl:choose>
		<xsl:when test="@offset">
set $<xsl:value-of select="@name"/>_Offset = $MMR_OFFSET_ADDRESS + <xsl:value-of select="@offset"/>
</xsl:when>
			<xsl:otherwise>
set $<xsl:value-of select="@name"/>
	<xsl:text>_Offset = $MMR_OFFSET_ADDRESS</xsl:text>
	<xsl:if test="@id">
	<xsl:text> + ($UNIT_</xsl:text>
	<xsl:value-of select="@id"/> &lt;&lt; $MMR_UNIT_SHIFT)
	</xsl:if>
	</xsl:otherwise>
		</xsl:choose>
<xsl:apply-templates select=".//my:register" mode="reg_decl"/>
	</xsl:template>

	<xsl:template match="my:register" mode="reg_decl">
set $<xsl:value-of select="$regprefix"/><xsl:if test="$useMapPrefix &gt; 0"><xsl:value-of select="../@name"/>_</xsl:if><xsl:value-of select="substring(concat(@id, '                    '), 1, 20)"/><xsl:text> = </xsl:text><xsl:apply-templates select="." mode="ctype"/> ($<xsl:value-of select="../@name"/>_Offset + <xsl:value-of select="@addr"/>)<xsl:if test="$convertBitfields = 1">
<xsl:apply-templates select=".//my:bitfield" mode="reg_decl"/></xsl:if></xsl:template>

	<xsl:template match="my:bitfield" mode="reg_dump">
	<xsl:choose>
		<xsl:when test="@lsb = @msb">
	if $r &amp; $<xsl:value-of select="@name"/>
		printf "[<xsl:value-of select="@name"/>] "
	end</xsl:when>
	<xsl:otherwise>
	printf "[<xsl:value-of select="@name"/> : %d] ", ($r &amp; $<xsl:value-of select="@name"/>) &gt;&gt; $<xsl:value-of select="@name"/>_SHFT</xsl:otherwise>
	</xsl:choose>

	</xsl:template>

	<xsl:template match="my:bitfield" mode="reg_decl">
	<xsl:variable name="lsb" select="number(@lsb)"/>
	<xsl:variable name="msb" select="number(@msb)"/>
set $<xsl:value-of select="substring(concat(@name, '                            '), 1, 28)"/> 
	<xsl:text> = </xsl:text>
	<xsl:choose>
		<xsl:when test="@lsb = @msb">
			<xsl:text>(1 &lt;&lt; (</xsl:text>
			<xsl:if test="string($lsb) = 'NaN'">$</xsl:if>
			<xsl:value-of select="@lsb"/>))</xsl:when>
		<xsl:otherwise>
			<xsl:text>( (-1 &lt;&lt; (</xsl:text>
				<xsl:if test="string($msb) = 'NaN'">$</xsl:if>
				<xsl:value-of select="@msb"/>
				<xsl:text> + 1)) ^ (-1 &lt;&lt;</xsl:text>
				<xsl:if test="string($lsb) = 'NaN'">$</xsl:if>
				<xsl:value-of select="@lsb"/>))
</xsl:otherwise>
	</xsl:choose>
set $<xsl:value-of select="@name"/>
			<xsl:text>_SHFT = </xsl:text>
			<xsl:if test="string($msb) = 'NaN'">$</xsl:if>
			<xsl:value-of select="@lsb"/>

	<!--xsl:if test="./my:info"><xsl:text>     </xsl:text>/* <xsl:value-of select="my:info"/> */</xsl:if--></xsl:template>

<!-- Emit header content if language not defined, or if set to "C" -->
<xsl:template match="my:header">
	<xsl:choose>
		<xsl:when test="@language = 'GDBSCRIPT'">
			<xsl:value-of select="."/>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="resolve_regref_lsb">
<xsl:param name="which"/>
<xsl:value-of select="key('regkey',$which/@ref)/my:bitfield[@name=$which/@bits]/@lsb"/>
</xsl:template>

<xsl:template match="/">#################################################################
#  <xsl:value-of select="my:devdesc/my:device[$index]/my:info"/>
# 
#  This file was generated by dclib/netpp. Modifications to
#  this file will be lost.
#  Stylesheet: gdbscript.xsl  v0.3-mips  (c) 2010-2015 section5.ch
# 
#  Device description version:
#  v<xsl:value-of select="my:devdesc/my:device[$index]/my:revision/my:major"/>.<xsl:value-of select="my:devdesc/my:device[$index]/my:revision/my:minor"/><xsl:value-of select="my:devdesc/my:device[$index]/my:revision/my:extension"/>
#################################################################

<xsl:apply-templates select=".//my:header"/>


def _get_indexed_reg
	set $a = &amp;$arg0[($arg1 &lt;&lt; $arg2) / sizeof(*$arg0)]
	set $r = *$a
	printf "Address: %08x ", $a
end


def _dump_reg
	if sizeof($arg0) == 4
		printf "%08x", $arg0
	end
	if sizeof($arg0) == 2
		printf "    %04x", $arg0 
	end
	if sizeof($arg0) == 1
		printf "      %02x", $arg0
	end
	printf "\n"
end

<xsl:text>set $MMR_UNIT_SHIFT = </xsl:text>
<xsl:call-template name="resolve_regref_lsb">
	<xsl:with-param name="which" select=".//my:device[$index]/my:group[@name='UNIT_MAP']/my:property/my:regref"/>
</xsl:call-template>

# Unit defines:
<xsl:apply-templates select=".//my:device[$index]/my:group[@name='UNIT_MAP']/my:property/my:choice/my:item" mode="unit_map" />

# Initialize defaults:
<xsl:apply-templates select=".//my:device[$index]/my:registermap[not(@nodecode='true')]" mode="init_shiftvals"/>

<xsl:apply-templates select=".//my:device[$index]/my:registermap[not(@hidden='true')]" mode="reg_decl"/>


#################################################################

<xsl:apply-templates select=".//my:device[$index]/my:registermap[not(@nodecode='true')]/my:register" mode="reg_dump"/>

<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="processing-instruction('config')">
# ifdef CONFIG_<xsl:value-of select="."/>
#
</xsl:template>

</xsl:stylesheet>

