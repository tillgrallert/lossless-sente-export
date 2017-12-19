---
title: "Lossless-sente-export: read me"
author: Till Grallert
date: 2017-12-19 21:59:15 +0100
---

The academic reference manager [Sente for OSX and iOS](http://www.thirdstreetsoftware.com) has become abandonware. The [forum](http://sente.tenderapp.com) was deleted in late 2015 without any warning to the community and without any attempt at preserving this huge knowledge base. In Fall 2017, sync servers were suddenly shut down.
Sente natively supports a number of export options of bibliographic data as well as annotated PDFs, but these are either somewhat incomplete or cannot be used in batch mode. Thus, we have to conceive of ways to export absolutely everything from Sente into an open format.

# Problem 1: incomplete XML export

Sente supports XML export following its own schema; but some important information is missing from this export, particularly for the notes attached to PDFs:

- colour of the note
- the UUID of the PDF this note is pointing to (important in the case of more than one attachment to a reference)
- exact location of the note in the PDF

## Solution

Sente is built on the open SQLite database and thus the necessary information can be retrieved using appropriate SQL queries. This requires in-depth knowledge of the underlying database's structure, which some people in the community have already acquired. [*Mrobe*](https://github.com/mrobe), for instance, built his immensely helpful and popular "[Sente Assistant](https://github.com/mrobe/senteAssistant)" on direct queries to the underlying database.

After some poking around, I settled on using the free, multi-platform [SQLiteStudio](http://sqlitestudio.pl) to export all tables as generic XML. This export is then be transformed into standard Sente XML with a few custom additions using the XSLT stylesheet [`tss_generate-xml-from-sql.xsl`](xslt/tss_generate-xml-from-sql.xsl) in this repository..

- currently implemented templates
    + main template for all `<tss:reference>`s, including all custom fields
    + generating `<tss:notes>`
        * only some parts of the JSON serialisation of position in file, location on page, color, etc. have been translated into CSS styling attributes
        * The entire JSON serialisation is kept for further processing in a new custom child of `<tss:note>` named `<tss:annotationDetails>`
    + generating `<tss:attachments>`
    + generating `<tss:keywords>`

## Workflow

1. Download and install [SQLiteStudio](http://sqlitestudio.pl)
2. Open your Sente library with SQLiteStudio
3. Export all tables emphasised in bold in the documentation below to XML using the table names as file names.
4. Manually remove the trailing `<index>` nodes from every XML file as those prevent the files from being well-formed XML.
5. Run the stylesheet [`tss_generate-xml-from-sql.xsl`](xslt/tss_generate-xml-from-sql.xsl) on `Reference.xml`. The output file `compiled.TSS.xml` contains all information available in the SQLite database and will be saved in the `_output/` folder and can be used for further processing.

# Problem 2: no batch export of annotated PDFs

Sente does not allow for bulk export of annotated PDFs. One idea would to write a script using macOS' GUI scripting to perform manual clicks and let it run for days on end. Another option would be to somehow use XSL-FO to add notes to PDFs using the information in the "Note" table.

# Documentation
## Database structure: tables

1. **Attachment**
2. **AttachmentLocation**
3. **Author**
4. Collection: empty
5. CollectionReference
6. **Keyword**
7. Library: empty
8. LibraryProperty
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

