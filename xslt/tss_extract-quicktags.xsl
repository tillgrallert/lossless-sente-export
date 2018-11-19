<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fnxpath="http://www.w3.org/2005/xpath-functions"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    exclude-result-prefixes="xs fnxpath"
    version="3.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:variable name="v_quicktag-list" select="json-to-xml(table/rows/row[value[@column = 0] = 'QuickTag List']/value[@column = 1])"/>
    <xsl:variable name="v_tag" select="'2016 EUHA'"/>
    
    <xsl:template match="/">
<!--        <xsl:apply-templates select="table/rows/row[value[@column = 0] = 'QuickTag List']/value[@column = 1]"/>-->
<!--        <xsl:copy-of select="$v_quicktag-list//fnxpath:map[fnxpath:array[@key='children']/fnxpath:map/fnxpath:string[@key='keyword'] = $v_tag]/fnxpath:string[@key='keyword']"/>-->
        
        <!--<xsl:for-each select="$v_quicktag-list/descendant::fnxpath:string[@key='keyword'][text() = $v_tag]/ancestor::fnxpath:map/fnxpath:string[@key='keyword']">
            <xsl:value-of select="."/>
                <xsl:text>|</xsl:text>
        </xsl:for-each>-->
        <tss:keywords>
            <xsl:apply-templates select="$v_quicktag-list/descendant::fnxpath:string[@key='keyword']">
                <xsl:sort select="."/>
            </xsl:apply-templates>
        </tss:keywords>
    </xsl:template>
    
    <xsl:template match="fnxpath:string[@key='keyword']">
        <tss:keyword>
             <xsl:attribute name="quickTagHierarchy">
                            <xsl:for-each select="ancestor::fnxpath:map/fnxpath:string[@key='keyword']">
            <xsl:value-of select="."/>
                <xsl:text>|</xsl:text>
        </xsl:for-each>
                        </xsl:attribute>
            <xsl:value-of select="."/>
        </tss:keyword>
    </xsl:template>
    
</xsl:stylesheet>