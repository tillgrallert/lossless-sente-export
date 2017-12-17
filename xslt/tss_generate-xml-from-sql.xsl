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
    
    <xsl:variable name="v_input-folder" select="replace(base-uri(),'(.+/).+?\.xml','$1')"/>
    
    <xsl:template match="/">
        <!-- group by PrimaryReferenceUUID in  -->
        <tss:senteContainer>
            <tss:library>
                <tss:references>
        <xsl:for-each-group select="table/rows/row" group-by="value[@column='0']">
            <tss:reference xml:id="{concat('uuid_',current-grouping-key())}">
                <tss:publicationType name="{value[@column='3']}"/>
                <!-- authors -->
                <xsl:call-template name="t_generate-authors">
                    <xsl:with-param name="p_reference-uuid" select="current-grouping-key()"/>
                </xsl:call-template>
                <tss:dates>
                    <tss:date type="Publication" year="" month="" day=""/>
                    <tss:date type="Entry" year="" month="" day=""/>
                    <tss:date type="Modification" year="" month="" day=""/>
                    <tss:date type="Retrieval" year="" month="" day=""/>
                </tss:dates>
                
                <tss:characteristics>
                    <!-- add all fields -->
                </tss:characteristics>
                <xsl:call-template name="t_generate-keywords">
                    <xsl:with-param name="p_reference-uuid" select="current-grouping-key()"/>
                </xsl:call-template>
                <xsl:call-template name="t_generate-notes">
                    <xsl:with-param name="p_reference-uuid" select="current-grouping-key()"/>
                </xsl:call-template>
            <xsl:call-template name="t_generate-attachments">
                <xsl:with-param name="p_reference-uuid" select="current-grouping-key()"/>
            </xsl:call-template>
            </tss:reference>
        </xsl:for-each-group>
                </tss:references>
            </tss:library>
        </tss:senteContainer>
    </xsl:template>
    
    <xsl:template name="t_generate-notes">
        <!-- the template takes a reference UUID as input and queries the Note.xml file for any rows relating to this reference -->
         <xsl:param name="p_reference-uuid"/>
        <xsl:param name="p_input" select="document(concat($v_input-folder,'Note.xml'))/table/rows/row[value[@column='1']=$p_reference-uuid]"/>
        <tss:notes>
            <!-- Sente does not ultimately delete any note. Therefore one has to actively check for the status of a row in column 10: IsDeleted. -->
            <!-- In addition, the Note.xml file also contains all notes attached to references long since deleted, which, however, will not be marked as having been deleted themselves -->
            <xsl:for-each select="$p_input/descendant-or-self::row[value[@column='10']='N']">
                <tss:note 
                    xml:id="{concat('uuid_',value[@column='0'])}"  
                    correspReference="{concat('#uuid_',$p_reference-uuid)}" 
                    correspAttachment="{concat('#uuid_',value[@column='7'])}"
                    editor="{concat('Sente User ',value[@column='14'])}">
                    <xsl:attribute name="when-iso">
                        <xsl:call-template name="t_iso-timestamp">
                            <xsl:with-param name="p_input" select="value[@column='11']"/>
                        </xsl:call-template>
                    </xsl:attribute>
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
        <xsl:param name="p_input" select="document(concat($v_input-folder,'Attachment.xml'))/table/rows/row[value[@column='0']=$p_reference-uuid]"/>
        <tss:attachments>
            <!-- Sente does not ultimately delete any attachment reference from Attachment.xml. Therefore one has to actively check for the status of a row in column 6: IsDeleted. -->
            <xsl:for-each select="$p_input/descendant-or-self::row[value[@column='6']='N']">
                <xsl:variable name="v_attachment-uuid" select="value[@column='1']"/>
                <xsl:variable name="v_attachment-location" select="document(concat($v_input-folder,'AttachmentLocation.xml'))/table/rows/row[value[@column='1']=$v_attachment-uuid]"/>
                <tss:attachmentReference
                xml:id="{concat('uuid_',$v_attachment-uuid)}"
                correspReference="{concat('#uuid_',$p_reference-uuid)}"
                type="{value[@column='4']}"
                editor="{concat('Sente User ',value[@column='13'])}">
                    <xsl:attribute name="when-iso">
                        <xsl:call-template name="t_iso-timestamp">
                            <xsl:with-param name="p_input" select="value[@column='8']"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <name><xsl:value-of select="value[@column='2']"/></name>
                    <!-- if attachments are kept in a synced folder Sente prefixes a private URI scheme "syncii:" that needs to be dereferenced at some point -->
                    <URL><xsl:value-of select="$v_attachment-location/descendant-or-self::row/value[@column='4']"/></URL>
            </tss:attachmentReference>
<!--            <tss:attachmentReference type="Portable Document Format (PDF)"/>-->
            </xsl:for-each>
        </tss:attachments>
    </xsl:template>
    
    <xsl:template name="t_generate-authors">
        <!-- the template takes a reference UUID as input and queries the Author.xml file for any rows relating to this reference -->
        <xsl:param name="p_reference-uuid"/>
        <xsl:param name="p_input" select="document(concat($v_input-folder,'Author.xml'))/table/rows/row[value[@column='0']=$p_reference-uuid]"/>
        <tss:authors>
            <xsl:for-each select="$p_input/descendant-or-self::row">
                <tss:author role="{value[@column='5']}">
                    <tss:surname><xsl:value-of select="value[@column='2']"/></tss:surname>
                    <tss:forenames><xsl:value-of select="value[@column='3']"/></tss:forenames>
                    <tss:initials><xsl:value-of select="value[@column='4']"/></tss:initials>
                </tss:author>
            </xsl:for-each>
        </tss:authors>
    </xsl:template>
    
    <xsl:template name="t_generate-keywords">
        <!-- the template takes a reference UUID as input and queries the Note.xml file for any rows relating to this reference -->
        <xsl:param name="p_reference-uuid"/>
        <xsl:param name="p_input" select="document(concat($v_input-folder,'Keyword.xml'))/table/rows/row[value[@column='0']=$p_reference-uuid]"/>
        <tss:keywords>
            <xsl:for-each select="$p_input/descendant-or-self::row">
                <tss:keyword
                    assigner="{value[@column='2']}"
                    correspReference="{concat('#uuid_',$p_reference-uuid)}">
                   <xsl:value-of select="value[@column='1']"/>
                </tss:keyword>
            </xsl:for-each>
        </tss:keywords>
    </xsl:template>
    
    <xsl:template name="t_iso-timestamp">
        <xsl:param name="p_input"/>
        <xsl:value-of select="replace($p_input,'(\d+-\d+-\d+)\s(\d+:\d+:\d+)\s(.+)$','$1T$2$3')"/>
    </xsl:template>
    
</xsl:stylesheet>