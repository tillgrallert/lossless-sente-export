---
title: "Lossless-sente-export: read me"
author: Till Grallert
date: 2017-12-17 16:46:35 +0100
---

The academic reference manager [Sente for OSX and iOS](http://www.thirdstreetsoftware.com) has become abandonware as of late 2015. Sync servers are still running, but the [forum](http://sente.tenderapp.com) was deleted without any warning to the community and without any attempt at preserving this huge knowledge base. Thus, we have to prepare for the worst and conceive of ways to export absolutely everything from Sente into an open format.

## Problem: incomplete export

Sente supports XML export following its own schema; but some important information is missing from this export, particularly for the notes attached to PDFs:

- colour of the note
- the UUID of the PDF this note is pointing to (important in the case of more than one attachment to a reference)
- exact location of the note in the PDF

## Solution

Sente is built on the open SQLite database and thus the necessary information can be retrieved using appropriate SQL queries. This requires in-depth knowledge of the underlying database's structure, which some people in the community have already acquired. [*Mrobe*](https://github.com/mrobe), for instance, built his immensely helpful and popular "[Sente Assistant](https://github.com/mrobe/senteAssistant)" on direct queries to the underlying database.

After some poking around, I settled on using the free, multi-platform [SQLiteStudio](http://sqlitestudio.pl) to export all tables as generic XML. This will then be transformed into standard Sente XML with custom additions using the XSLT stylesheet [`tss_generate-xml-from-sql.xsl`](xslt/tss_generate-xml-from-sql.xsl).

