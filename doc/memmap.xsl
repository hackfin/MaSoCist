<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- (c) 2003-2019 section5.ch

This file is subject to the MaSoCist open source license.
Please respect OpenSource and contribute valuable changes!

-->

<xsl:stylesheet version="1.0" 
	xmlns:my="http://www.section5.ch/dclib/schema/devdesc"
	xmlns:memmap="http://www.section5.ch/dclib/schema/memmap"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >


	<xsl:output method="xml" encoding="ISO-8859-1" indent="yes" doctype-system="/usr/share/xml/docbook/schema/dtd/4.5/docbookx.dtd" doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"/>	


	<xsl:template match="my:memorymap">
		<row>
		  <entry><xsl:value-of select="@name"/></entry>
		  <entry><hardware><constant><xsl:value-of select="@offset"/></constant></hardware></entry>
		  <entry><hardware><constant><xsl:value-of select="@size"/></constant></hardware></entry>
		  <entry><xsl:value-of select="memmap:info"/></entry>
		</row>
	</xsl:template>


	<xsl:template match="my:device">


     <table>
		<xsl:attribute name="id">tbl_mmap_<xsl:value-of select="@id"/></xsl:attribute>
        <title>Address map for <emphasis><xsl:value-of select="@name"/></emphasis> platform</title>

        <tgroup cols="4">
          <thead>
            <row>
              <entry align="center">ID</entry>
              <entry align="center">Address [Size]</entry>
              <entry align="center">Size</entry>
              <entry align="center">Description</entry>
            </row>
          </thead>

          <tbody>
<xsl:apply-templates select=".//my:memorymap"/>
           </tbody>
        </tgroup>
      </table>


</xsl:template>

	<xsl:template match="/">
    <section id="sec_memory_maps">
		<title>Memory maps</title>
<xsl:apply-templates select=".//my:device"/>

    </section>

</xsl:template>

</xsl:stylesheet>

