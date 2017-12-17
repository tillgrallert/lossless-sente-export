<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    >
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"  />
    
    <!-- input is Reference.xml -->
    
    <xsl:template match="/">
        <!-- group by PrimaryReferenceUUID in  -->
        <xsl:for-each-group select="table/rows/row" group-by="value[@column='1']">
            <xsl:call-template name="t_generate-notes">
                <xsl:with-param name="p_reference-uuid" select="current-grouping-key()"/>
            </xsl:call-template>
            <xsl:call-template name="t_generate-attachments">
                <xsl:with-param name="p_reference-uuid" select="current-grouping-key()"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="t_generate-notes">
        <!-- the template takes a reference UUID as input and queries the Note.xml file for any rows relating to this reference -->
         <xsl:param name="p_reference-uuid"/>
        <xsl:param name="p_input" select="document(concat(replace(base-uri(),'(.+/).+?\.xml','$1'),'Note.xml'))/table/rows/row[value[@column='1']=$p_reference-uuid]"/>
        <tss:notes>
            <!-- Sente does not ultimately delete any note. Therefore one has to actively check for the status of a row in column 10: IsDeleted. -->
            <!-- In addition, the Note.xml file also contains all notes attached to references long since deleted, which, however, will not be marked as having been deleted themselves -->
            <xsl:for-each select="$p_input/descendant-or-self::row[value[@column='10']='N']">
                <tss:note 
                    xml:id="{concat('uuid_',value[@column='0'])}"  
                    correspReference="{concat('#uuid_',$p_reference-uuid)}" 
                    correspAttachment="{concat('#uuid_',value[@column='7'])}">
                    <title><xsl:value-of select="value[@column='2']"/></title>
                    <comment><xsl:value-of select="value[@column='5']"/></comment>
                    <quotation><xsl:value-of select="value[@column='4']"/></quotation>
                    <pages><xsl:value-of select="value[@column='3']"/></pages>
                    <!-- column 8: position in attached file -->
                    <!-- column 9: annotation details; JSON including geometry, position on page, colour, strike etc. -->
                </tss:note>
            </xsl:for-each>
        </tss:notes>
    </xsl:template>
    
    <xsl:template name="t_generate-attachments">
        <!-- the template takes a reference UUID as input and queries the Attachment.xml file for any rows relating to this reference -->
        <xsl:param name="p_reference-uuid"/>
        <xsl:param name="p_input" select="document(concat(replace(base-uri(),'(.+/).+?\.xml','$1'),'Attachment.xml'))/table/rows/row[value[@column='0']=$p_reference-uuid]"/>
        <tss:attachments>
            <!-- Sente does not ultimately delete any note. Therefore one has to actively check for the status of a row in column 6: IsDeleted. -->
            <xsl:for-each select="$p_input/descendant-or-self::row[value[@column='6']='N']">
                <tss:attachmentReference
                xml:id="{concat('uuid_',value[@column='1'])}"
                correspReference="{concat('#uuid_',$p_reference-uuid)}"
                type="{value[@column='4']}">
                    <name><xsl:value-of select="value[@column='2']"/></name>
                    <URL><xsl:value-of select="value[@column='3']"/></URL>
            </tss:attachmentReference>
<!--            <tss:attachmentReference type="Portable Document Format (PDF)"/>-->
            </xsl:for-each>
        </tss:attachments>
    </xsl:template>
    
</xsl:stylesheet>