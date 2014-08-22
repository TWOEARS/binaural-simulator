<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" encoding="utf-8"/>

<xsl:template match="xsd:schema">

	<xsl:variable name="Main" select="/"/>

	<xsl:for-each select="xsd:annotation/xsd:documentation">
		<p><xsl:value-of select="text()"/></p>
	</xsl:for-each>

	<xsl:if test="xsd:import">
		<p style="font-weight:bold">Imported schemata:</p>
		<ul>
			<xsl:for-each select="xsd:import">
				<li>
					<a href="{@schemaLocation}">
					<xsl:value-of select="@schemaLocation"/>
					</a>
					from namespace
					<span style="font-weight:bold;">
						<xsl:value-of select="@namespace"/>
					</span>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:if>

	<xsl:if test="xsd:include">
		<p style="font-weight:bold">Included schemata:</p>
		<ul>
			<xsl:for-each select="xsd:include">
				<li>
					<a href="{@schemaLocation}">
						<xsl:value-of select="@schemaLocation"/>
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:if>

	<xsl:if test="xsd:redefine">
		<p style="font-weight:bold">Schemata affected by redefine:</p>
		<ul>
			<xsl:for-each select="xsd:redefine">
				<li>
					<a href="{@schemaLocation}">
						<xsl:value-of select="@schemaLocation"/>
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:if>

	<xsl:if test="xsd:element">
		<p style="font-weight:bold">Global Elements in main module</p>
		<xsl:apply-templates select="xsd:element"/>
	</xsl:if>

	<xsl:for-each select="xsd:include | xsd:redefine">
		<xsl:variable name="emodule" select="document(@schemaLocation)"/>
		<xsl:if test="$emodule/xsd:schema/xsd:element">
			<p style="font-weight:bold">
				Global Elements from <a href="{@schemaLocation}"><xsl:value-of select="$emodule/xsd:schema/@id"/></a>
			</p>
			<xsl:apply-templates select="$emodule/xsd:schema/xsd:element">
				<xsl:with-param name="Main" select="$Main"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:for-each>

	<xsl:if test="xsd:attribute">
		<p style="font-weight:bold">Global Attributes in main module</p>
			<xsl:apply-templates select="xsd:attribute"/>
	</xsl:if>

	<xsl:for-each select="xsd:include | xsd:redefine">
		<xsl:variable name="amodule" select="document(@schemaLocation)"/>
		<xsl:if test="$amodule/xsd:schema/xsd:attribute">
			<p style="font-weight:bold">
				Global Attributes from <a href="{@schemaLocation}"><xsl:value-of select="$amodule/xsd:schema/@id"/></a>
			</p>
				<xsl:apply-templates select="$amodule/xsd:schema/xsd:attribute">
					<xsl:with-param name="Main" select="$Main"/>
				</xsl:apply-templates>
		</xsl:if>
	</xsl:for-each>

	<xsl:if test="xsd:complexType|xsd:simpleType">
		<p style="font-weight:bold">Global Types in main module</p>
			<xsl:apply-templates select="xsd:complexType | xsd:simpleType">
				<xsl:sort select="@name"/>
			</xsl:apply-templates>
	</xsl:if>

	<xsl:for-each select="xsd:include | xsd:redefine">
		<xsl:variable name="tmodule" select="document(@schemaLocation)"/>
		<xsl:if test="$tmodule/xsd:schema/xsd:complexType | $tmodule/xsd:schema/xsd:simpleType">
			<p style="font-weight:bold">Global Types from
				<a href="{@schemaLocation}"><xsl:value-of select="$tmodule/xsd:schema/@id"/></a>
			</p>
			<xsl:apply-templates select="$tmodule/xsd:schema/xsd:complexType | $tmodule/xsd:schema/xsd:simpleType">
				<xsl:with-param name="Main" select="$Main"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:for-each>

	<xsl:if test="xsd:group|xsd:attributeGroup">
		<p style="font-weight:bold">Useful groups in main module</p>
			<xsl:apply-templates select="xsd:group|xsd:attributeGroup">
				<xsl:sort select="@name"/>
			</xsl:apply-templates>
	</xsl:if>

	<xsl:for-each select="xsd:include | xsd:redefine">
		<xsl:variable name="agmodule" select="document(@schemaLocation)"/>
		<xsl:if test="$agmodule/xsd:schema/xsd:group | $agmodule/xsd:schema/xsd:attributeGroup">
			<p style="font-weight:bold">Useful groups from
				<a href="{@schemaLocation}"><xsl:value-of select="$agmodule/xsd:schema/@id"/></a>
			</p>
				<xsl:apply-templates select="$agmodule/xsd:schema/xsd:group | $agmodule/xsd:schema/xsd:attributeGroup">
					<xsl:with-param name="Main" select="$Main"/>
				</xsl:apply-templates>
		</xsl:if>
	</xsl:for-each>

</xsl:template>

<xsl:template name="link2">
<xsl:param name="Main" select="/"/>
<xsl:param name="type"/>
<xsl:choose>
	<xsl:when test="document($Main/xsd:schema/xsd:include/@schemaLocation)">
		<xsl:for-each select="document($Main/xsd:schema/xsd:include/@schemaLocation)">
			<xsl:if test="key('type',$type)">
			<xsl:text> </xsl:text>
			<a href="#{generate-id(key('type',$type))}"><xsl:value-of select="$type"/></a>
			</xsl:if>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:for-each select="$Main">
			<xsl:if test="key('type',$type)">
			<xsl:text> </xsl:text>
			<a href="#{generate-id(key('type',$type))}"><xsl:value-of select="$type"/></a>
			</xsl:if>
		</xsl:for-each>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="xsd:element">
<xsl:param name="Main" select="/"/>
<ul>
	<li>
	<xsl:choose>
		<xsl:when test="@name">
				<span style="font-weight:bold; color:darkred;">&lt;<a name="{generate-id()}"><xsl:value-of select="@name"/>&gt;</a></span>
					<xsl:call-template name="howmany"/>
					<span style="font-weight:normal; color:darkblue">
						<xsl:choose>
							<xsl:when test="@type">
								<xsl:choose>
									<xsl:when test="contains(@type,':')"><xsl:value-of select="@type"/></xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="link2">
											<xsl:with-param name="Main" select="$Main"/>
											<xsl:with-param name="type" select="@type"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="@ref">
								<xsl:choose>
									<xsl:when test="contains(@ref,':')"><xsl:value-of select="@ref"/></xsl:when>
									<xsl:otherwise>
									<xsl:call-template name="link2">
										<xsl:with-param name="Main" select="$Main"/>
										<xsl:with-param name="type" select="@ref"/>
									</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<!--default -->
						</xsl:choose>
					</span>
					<xsl:if test="xsd:annotation">
						<span style="font-weight:normal; color:black;"><xsl:apply-templates  select="xsd:annotation"/></span>
					</xsl:if>
		</xsl:when>
		<xsl:otherwise>	<!--only @ref-->
					<xsl:choose>
						<xsl:when test="contains(@ref,':')"><xsl:value-of select="@ref"/></xsl:when>
						<xsl:otherwise>
							<span style="font-weight:normal; color:darkred;">
								&lt;
								<xsl:call-template name="link2">
									<xsl:with-param name="Main" select="$Main"/>
									<xsl:with-param name="type" select="@ref"/>
								</xsl:call-template>
								&gt;
							</span>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="xsd:annotation">
						<span style="font-weight:normal; color:black;"><xsl:apply-templates  select="xsd:annotation"/></span>
					</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="xsd:complexType | xsd:simpleType">
		<xsl:apply-templates select="xsd:complexType | xsd:simpleType">
			<xsl:with-param name="Main" select="$Main"/>
		</xsl:apply-templates>
	</xsl:if>
	<xsl:apply-templates select="xsd:unique | xsd:key | xsd:keyref">
		<xsl:with-param name="Main" select="$Main"/>
	</xsl:apply-templates>
	</li>
</ul>
</xsl:template>

<xsl:template match="xsd:complexType">
<xsl:param name="Main" select="/"/>
	<xsl:choose>
		<xsl:when test="@name">
<ul>
	<li>
			<p style="font-weight:bold; color:darkblue;">
				<a name="{generate-id()}"><xsl:value-of select="@name"/></a> :
				<xsl:if test="@mixed='true'">
					<span> {free text}</span>
				</xsl:if>
				<xsl:if test="xsd:annotation">
					<span style="font-weight:normal; color:black;"><xsl:apply-templates  select="xsd:annotation"/></span>
				</xsl:if>
			</p>
			<xsl:apply-templates select="xsd:complexContent | xsd:simpleContent | xsd:sequence | xsd:choice  | xsd:all | xsd:group ">
				<xsl:with-param name="Main" select="$Main"/>
			</xsl:apply-templates>
			<xsl:if test="xsd:attributeGroup | xsd:anyAttribute | xsd:attribute">
				<xsl:apply-templates select="xsd:attributeGroup | xsd:anyAttribute | xsd:attribute">
					<xsl:with-param name="Main" select="$Main"/>
				</xsl:apply-templates>
			</xsl:if>
	</li>
</ul>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="xsd:complexContent | xsd:simpleContent | xsd:sequence | xsd:choice  | xsd:all | xsd:group | 		xsd:attributeGroup | xsd:anyAttribute">
			<xsl:with-param name="Main" select="$Main"/>
		</xsl:apply-templates>
			<xsl:if test="xsd:attribute">
				<xsl:apply-templates select="xsd:attribute">
					<xsl:with-param name="Main" select="$Main"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xsd:simpleType">
<xsl:param name="Main" select="/"/>
	<xsl:choose>
		<xsl:when test="@name">
<ul>
	<li>
			<p>
				<span style="font-weight:bold; color:darkblue;">
					<a name="{generate-id()}"><xsl:value-of select="@name"/></a>
				</span> :
				<xsl:if test="xsd:annotation"><xsl:apply-templates select="xsd:annotation"/></xsl:if>
			</p>
			<xsl:if test="xsd:restriction | xsd:list | xsd:union">
				<xsl:apply-templates select="xsd:restriction | xsd:list | xsd:union">
						<xsl:with-param name="Main" select="$Main"/>
				</xsl:apply-templates>
			</xsl:if>
	</li>
</ul>
		</xsl:when>
		<xsl:otherwise>
				<xsl:apply-templates select="xsd:restriction | xsd:list | xsd:union">
					<xsl:with-param name="Main" select="$Main"/>
				</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xsd:list">
<xsl:param name="Main" select="/"/>
List of
	<xsl:choose>
		<xsl:when test="contains(@itemType,':')">
			<span style="font-weight:bold; color:darkblue;">
				{<xsl:value-of select="@itemType"/>}
			</span>
		</xsl:when>
		<xsl:otherwise>
		<xsl:call-template name="link2">
				<xsl:with-param name="Main" select="$Main"/>
				<xsl:with-param name="type" select="@itemType"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xsd:group">
<xsl:param name="Main" select="/"/>
<ul>
	<li>
	<xsl:choose>
		<xsl:when test="@name">
		<p style="font-weight:normal; color:darkblue;">
			<a name="{generate-id()}"><xsl:value-of select="@name"/></a> :
		</p>
				<xsl:if test="xsd:all | xsd:choice | xsd:sequence">
						<xsl:apply-templates select="xsd:all | xsd:choice | xsd:sequence">
							<xsl:with-param name="Main" select="$Main"/>
						</xsl:apply-templates>
				</xsl:if>
		</xsl:when>
		<xsl:otherwise>
		<xsl:choose>
			<xsl:when test="contains(@ref,':')">
				<span style="font-weight:bold; color:darkblue;">
					{<xsl:value-of select="@ref"/>}
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="link2">
					<xsl:with-param name="Main" select="$Main"/>
					<xsl:with-param name="type" select="@ref"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
	</li>
</ul>
</xsl:template>

<xsl:template match="xsd:attributeGroup">
<xsl:param name="Main" select="/"/>
	<ul>
		<li>
	<xsl:choose>
		<xsl:when test="@name">
			<p style="font-weight:normal; color:darkblue;">
				<a name="{generate-id()}"><xsl:value-of select="@name"/></a> :
			</p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="link2">
				<xsl:with-param name="Main" select="$Main"/>
				<xsl:with-param name="type" select="@ref"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="xsd:attribute | xsd:attributeGroup | xsd:anyAttribute">
		<xsl:apply-templates select="xsd:attribute | xsd:attributeGroup | xsd:anyAttribute">
			<xsl:with-param name="Main" select="$Main"/>
		</xsl:apply-templates>
	</xsl:if>
		</li>
	</ul>
</xsl:template>

<xsl:template match="xsd:any">
	<span style="font-weight:bold;">any</span>
</xsl:template>

<xsl:template match="xsd:sequence">
<xsl:param name="Main" select="/"/>
		<ul>
			<li>
			<div style="font-weight:bold; color:darkblue">(<xsl:call-template name="howmany"/></div>
			<xsl:apply-templates>
				<xsl:with-param name="Main" select="$Main"/>
			</xsl:apply-templates>
			<div style="font-weight:bold; color:darkblue">)</div>
			</li>
		</ul>
</xsl:template>

<xsl:template match="xsd:choice">
<xsl:param name="Main" select="/"/>
		<ul>
			<li>
			<div style="font-weight:bold; color:darkblue">[<xsl:call-template name="howmany"/></div>
			<xsl:apply-templates>
				<xsl:with-param name="Main" select="$Main"/>
			</xsl:apply-templates>
			<div style="font-weight:bold; color:darkblue">]</div>
			</li>
		</ul>
</xsl:template>

<xsl:template match="xsd:all">
<xsl:param name="Main" select="/"/>
		<ul>
			<li>
			<div style="font-weight:bold; color:darkblue">([<xsl:call-template name="howmany"/></div>
			<xsl:apply-templates>
				<xsl:with-param name="Main" select="$Main"/>
			</xsl:apply-templates>
			<div style="font-weight:bold; color:darkblue">])</div>
			</li>
		</ul>
</xsl:template>


<xsl:template match="xsd:attribute">
<xsl:param name="Main" select="/"/>
<ul>
	<li>
		<xsl:if test="@name">
			<span style="font-weight:bold; color:darkgreen;">
				<xsl:value-of select="@name"/>
		    <xsl:if test="@use">
					<span style="font-weight:normal;">
						(<xsl:value-of select="@use"/>)
			    </span>
		    </xsl:if>
        :
			</span>
		</xsl:if>
		<span style="font-weight:normal; color:darkblue">
			<xsl:choose>
				<xsl:when test="@type">
					<xsl:choose>
						<xsl:when test="contains(@type,':')"><xsl:value-of select="@type"/></xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="link2">
								<xsl:with-param name="Main" select="$Main"/>
								<xsl:with-param name="type" select="@type"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</span>
    <xsl:if test="@default">
	    <span style="font-family:Courier; color:black"> = <xsl:value-of select="@default"/></span>
    </xsl:if>
		<xsl:apply-templates select="xsd:annotation"/>
		<xsl:apply-templates select="xsd:simpleType">
			<xsl:with-param name="Main" select="$Main"/>
		</xsl:apply-templates>
	</li>
</ul>
</xsl:template>

<xsl:template match="xsd:extension">
<xsl:param name="Main" select="/"/>
<ul>
	<li>
		<span style="font-weight:normal; color:darkred">Inherited from
		<xsl:choose>
			<xsl:when test="contains(@base,':')">{<xsl:value-of select="@base"/>}</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="link2">
					<xsl:with-param name="Main" select="$Main"/>
					<xsl:with-param name="type" select="@base"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		with extensions:</span><br></br>
		<xsl:apply-templates>
			<xsl:with-param name="Main" select="$Main"/>
			<xsl:sort  select="@value" order="ascending"/>
		</xsl:apply-templates>
	</li>
</ul>
</xsl:template>

<xsl:template match="xsd:restriction">
<xsl:param name="Main" select="/"/>
<ul>
	<li>
		<span style="font-weight:normal; color:darkred">Inherited from
		<xsl:choose>
			<xsl:when test="contains(@base,':')">
				<span style="font-weight:normal; color:darkblue">
					<xsl:value-of select="@base"/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="link2">
					<xsl:with-param name="Main" select="$Main"/>
					<xsl:with-param name="type" select="@base"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
    with restrictions:</span><br></br>
		<xsl:apply-templates>
			<xsl:with-param name="Main" select="$Main"/>
			<xsl:sort  select="@value" order="ascending"/>
		</xsl:apply-templates>
	</li>
</ul>
</xsl:template>

<xsl:template match="xsd:pattern">
	<div>
pattern:<span style="font-weight:normal; color:blue">&#9;
			<xsl:value-of select="@value"/>
		</span>
	</div>
	</xsl:template>

<xsl:template match="xsd:simpleContent">
<xsl:param name="Main" select="/"/>
	<xsl:apply-templates>
		<xsl:with-param name="Main" select="$Main"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:complexContent">
<xsl:param name="Main" select="/"/>
	<xsl:apply-templates>
		<xsl:with-param name="Main" select="$Main"/>
	</xsl:apply-templates>
</xsl:template>


	<xsl:template match="xsd:enumeration">
		<div style="font-weight:normal; color:blue">
			<xsl:value-of select="@value"/>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="xsd:documentation">
		<ul style="position:relative; left:-2.5em; margin-bottom:0.5em">
			<xsl:choose>
				<xsl:when test="@xml:lang='short'">
					<span style="font-variant:small-caps; font-weight:bold; color:black;">
						<xsl:value-of select="text()"/>
					</span>
				</xsl:when>
				<xsl:when test="@xml:lang='matlab'">
					<xsl:text>MATLAB example: </xsl:text>
					<span style="font-family:Courier; color:black;">
						<xsl:value-of select="text()"/>
					</span>
				</xsl:when>
				<xsl:when test="@xml:lang='see'">
					<xsl:text>See also: </xsl:text>
					<span style="font-weight:normal; color:darkred;">
						<xsl:value-of select="text()"/>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<span style="font-weight:normal; color:black;">
						<i><xsl:value-of select="text()"/></i>
					</span>
				</xsl:otherwise>
			</xsl:choose>
		</ul>
	</xsl:template>

	<xsl:template name="howmany">
		<xsl:choose>
			<xsl:when test="@minOccurs='0' and @maxOccurs='unbounded'">*</xsl:when>
			<xsl:when test="@minOccurs='0' and (not(@maxOccurs) or @maxOccurs='1')">?</xsl:when>
			<xsl:when test="(not(@minOccurs) or @minOccurs='1') and @maxOccurs='unbounded'">+	</xsl:when>
			<xsl:otherwise>
				<xsl:if test="@minOccurs and @maxOccurs!='1'">
					<xsl:value-of select="@minOccurs"/>
					<xsl:if test="@maxOccurs='unbounded'">+</xsl:if>
					<xsl:if test="@maxOccurs!='unbounded'">-<xsl:value-of select="@maxOccurs"/>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xsd:minExclusive">
		larger than <xsl:value-of select="@value"/>
	</xsl:template>

	<xsl:template match="xsd:maxExclusive">
		smaller than <xsl:value-of select="@value"/>
	</xsl:template>

	<xsl:template match="xsd:minInclusive">
		smaller equal <xsl:value-of select="@value"/>
	</xsl:template>

	<xsl:template match="xsd:maxInclusive">
		larger equal <xsl:value-of select="@value"/>
	</xsl:template>

	<xsl:template match="xsd:length">
		Length=<xsl:value-of select="@value"/>
	</xsl:template>

<xsl:key name="type" match="xsd:schema/xsd:element | xsd:schema/xsd:attribute | xsd:schema/xsd:complexType | xsd:schema/xsd:simpleType | xsd:schema/xsd:group | xsd:schema/xsd:attributeGroup" use="@name"/>

<xsl:template match="/">
<html>
	<head>
		<title>
			<xsl:value-of select="xsd:schema/@id"/> Two!Ears Fileformat XMLSchema <xsl:value-of select="xsd:schema/@version"/>
		</title>
	</head>
	<body style="font:sans-serif;">
	<h3><xsl:value-of select="xsd:schema/@id"/> Two!Ears Fileformat XMLSchema <xsl:value-of select="xsd:schema/@version"/></h3>
	<xsl:apply-templates/>
		<p style="font-weight:normal;text-align:right">Schema viewer developed by <a href="http://romeo.roua.org">Romeo Anghelache</a>, copyleft <a href="http://www.gnu.org">GNU</a><xsl:text> </xsl:text><a href="http://www.gnu.org/licenses/gpl.html">GPL</a>, 2001, version 1.01
		<br></br>
		Minor modifications for the <a href="http://twoears.eu" style="font-variant:small-caps" >Two!Ears</a> project by <a href="http://www.int.uni-rostock.de/Staff-Info.23+B6JmNIYXNoPTYwMDg5ZDU4MDhjMjQ2NzExZDIxYjI2YWI1N2ViYmFiJnR4X2pwc3RhZmZfcGkxJTVCYmFja0lkJTVEPTMmdHhfanBzdGFmZl9waTElNUJzaG93VWlkJTVEPTExOA__.0.html">Fiete Winter</a>, copyleft <a href="http://www.gnu.org">GNU</a><xsl:text> </xsl:text><a href="http://www.gnu.org/licenses/gpl.html">GPLv3</a>, 2014
  </p>
	</body>
</html>
</xsl:template>

</xsl:stylesheet>
