---
title: "Lossless-sente-export: read me"
author: Till Grallert
date: 2017-12-19 21:59:15 +0100
---

The academic reference manager [Sente for OSX and iOS](http://www.thirdstreetsoftware.com) has become abandonware. The [forum](http://sente.tenderapp.com) was deleted in late 2015 without any warning to the community and without any attempt at preserving this huge knowledge base. In Fall 2017, sync servers were suddenly shut down.
Sente natively supports a number of export options of bibliographic data as well as annotated PDFs, but these are either somewhat incomplete or cannot be used in batch mode. Thus, we have to conceive of ways to export absolutely everything from Sente into an open format.

# Problem 1: incomplete XML export

Sente supports XML export following its own schema; but some important information is missing from this export, 

- particularly for the notes attached to PDFs:
    - colour of the note;
    - the UUID of the PDF this note is pointing to (important in the case of more than one attachment to a reference);
    - exact location of the note in the PDF.
- other information missing:
    + the collections a reference is part of;[^1]

## Solution

Sente stores all data in an open-source SQLite database and thus all necessary information can be retrieved using appropriate SQL queries. This requires in-depth knowledge of the underlying database's structure, which some people in the community have already acquired. [*Mrobe*](https://github.com/mrobe), for instance, built his immensely helpful and popular "[Sente Assistant](https://github.com/mrobe/senteAssistant)" on direct queries to the underlying database.

After some poking around, I settled on using the free, multi-platform [SQLiteStudio](http://sqlitestudio.pl) to export all tables as generic XML. This export is then be transformed into standard Sente XML with a few custom additions using the XSLT stylesheet [`tss_generate-xml-from-sql.xsl`](xslt/tss_generate-xml-from-sql.xsl) in this repository.

- to do:
    + write/adopt the XML schema for Sente XML in order for processing tools to know what to expect when presented with our XML output.
- currently implemented templates
    + main template for all `<tss:reference>`s, including all custom fields
    + generating `<tss:notes>`
        * only some parts of the JSON serialisation of position in file, location on page, color, etc. have been translated into CSS styling attributes
        * The entire JSON serialisation is kept for further processing in a new custom child of `<tss:note>` named `<tss:annotationDetails>`
        
    ~~~{.xml}
    <tss:note 
     xml:id="uuid_0B3368F6-BF56-49BE-94B5-396D0B7F50BC"
     correspReference="#uuid_21D0D0DC-FFFE-4DF7-B588-EF192D1427B9"
     correspAttachment="#uuid_CFF6C9A0-BCCD-47FC-8359-B8BDAD3FE4B1"
     editor="Sente User Sebastian"
     when-iso="2017-12-17T09:18:22+0000"
     style="display:block; border-style:solid; border-radius: 3px; border-width: 4px; border-color: rgba(1,0.3137255,0.3137255,0.2);">
        <title>test note</title>
        <comment>Some comment</comment>
        <quotation>ḥawādith al-wilāya</quotation>
        <pages>1</pages>
        <locationInAttachedFile>{"Encoding":"V1","X":559.4985,"Page":1,"Y":641.07}</locationInAttachedFile>
        <annotationDetails>{"Encoding":"V1","Selection Original Ending Point":"{551.498474,504.381134}","Type":"Highlighted Text","Original Selection Mode":"Region","Selection Target Zone":"{{430.897891,504.381134},{120.600583,136.688866}}","Rectangles":[{"Stroke RGBA":[1,0.3137255,0.3137255,0.2],"Bounds":"{{430.897891,504.381134},{120.600583,136.688866}}","Stroke Width":4,"Corner Radius":3}],"Selection Original Starting Point":"{430.897891,641.070000}"}</annotationDetails>
    </tss:note>
    ~~~

    + generating `<tss:attachments>`
        * Problem: local paths are stored as alphanumerical strings using Base64. There are numerous implementations to convert `xs:base64Binary` to `xs:string` but none of the available extensions ([saxon's `saxon:base64Binary-to-string`]() and [EXPath's `bin:decode-string()`](http://expath.org/spec/binary#decode-string)) and [stylesheets](https://github.com/ilyakharlamov/xslt_base64) is both free to use and can deal with unicode. Thus, I decided to leave base64 binary data as it is.
        * example XML:
    
    ~~~{.xml}
    <tss:attachmentReference 
     xml:id="uuid_9F730A80-E794-4726-8141-D37EEF4B51F5"
     correspReference="#uuid_9ED5D922-8984-4EBB-951B-11919769814A"
     type=""
     editor="Sente User Sebastian"
     when-iso="2017-11-07T11:11:42+0000">
        <name/>
        <URL>(null):images/pdfs/oclc_792755216-i_1.pdf</URL>
    </tss:attachmentReference>
    ~~~

    + generating `<tss:keywords>`

    ~~~{.xml}
    <tss:keyword 
     assigner="Sente User Sebastian"
     correspReference="#uuid_21D0D0DC-FFFE-4DF7-B588-EF192D1427B9">Source</tss:keyword>
    ~~~

## Workflow

1. Download and install [SQLiteStudio](http://sqlitestudio.pl)
2. Open your Sente library with SQLiteStudio
    - on macOS do the following: 
        + In the Finder, right-click on your Sente library and select `Show Package Contents`.
        + The actual SQLite database is then located at `Contents/primaryLibrary.sente601`
3. Export all tables emphasised in bold in the documentation below to XML using the table names as file names.
4. Open all XML files in a text editor and manually remove the trailing `<index>` nodes from every XML file as these prevent the files from being well-formed XML.
5. Run the stylesheet [`tss_generate-xml-from-sql.xsl`](xslt/tss_generate-xml-from-sql.xsl) on `Reference.xml`. The output file `compiled.TSS.xml` contains all information available in the SQLite database. It will be saved in the `_output/` folder and can be used for further processing. 

    Options to apply the transformation include:

    + running [Saxon-HE](http://saxon.sourceforge.net/#F9.8HE) for Java in the terminal:

    ~~~
    $ java -jar "path/to/saxon9he.jar" -s:"path/to/Reference.xml" -xsl:"path/to/tss_generate-xml-from-sql.xsl"
    ~~~

    + using one of the XML editors that include an XSLT processor, such as oXygen (30 days trial licences available)
        * In this case, you should set the parameter `$p_limited-to-saxon-he` to `false()` in order to translate base64 binary data to proper file paths to attachments.

# Problem 2: no batch export of annotated PDFs

Sente does not allow for bulk export of annotated PDFs. One idea would to write a script using macOS' GUI scripting to perform manual clicks and let it run for days on end. Another option would be to somehow use XSL-FO to add notes to PDFs using the information in the "Note" table.

# Documentation
## Database structure: tables

1. **Attachment**
2. **AttachmentLocation**
3. **Author**
4. Collection: one row for every collection
5. CollectionReference: empty
    - this table was clearly planned to contain information on which references is part of which collection, but this information was never stored here.
6. **Keyword**
7. Library: empty
8. **LibraryProperty**: stores basic settings, including the path to the Sente library and thus attachments. If you have access to Saxon PE or Saxon EE, export this table as XML
9. **Note**:
    - This is the most important table to improve the generic XML export
    - contains information otherwise missing as JSON:
        + color
        + the file this note is attached to
        + location on the page
        + size
        + date edited
10. NoteKeyword: empty, was never implemented
11. QLP_SchemaTable: not necessary
12. RDFTuple
    - logs PDF reading posistions
14. **Reference**
15. ReferenceAllSearchableFields
    - replicates the content of "References"; fields are separated by pipe characters
17. ReferenceFilter
18. ReferenceSignature
19. ReferenceSignatureDefinition
20. SenteQuery: empty
21. **SparseAttribute**
    - contains all custom fields
23. Thumbnail
24. VersionedLibraryProperty


[^1]: It is unclear where this information is kept in the SQLite data base
