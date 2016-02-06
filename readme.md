---
title: "Lossless-sente-export: read me"
author: Till Grallert
date: 2016-02-06 13:24:58
---

The academic reference manager Sente for OSX and iOS has become abandonware as of late 2015. Sync servers are still running, but the forum was deleted without any warning to the community and without any attempt at preserving this huge knowledge base. Thus, we have to prepare for the worst and conceive of ways to export absolutely everything from Sente into an open format.

## Problem: incomplete export

Sente supports XML export following its own schema, but for the notes attached to PDFs some important information is missing from this export, namely:

- colour of the note
- the UUID of the PDF this note is pointing to (important in the case of more than one attachment to a reference)
- exact location of the note in the PDF

## Solution

Sente is built on the open SQLite database and thus the necessary information can be retrieved using appropriate SQL queries. This requires in-depth knowledge of the underlying database's structure, which some people in the community have already acquired and, for instance, demonstrated in writing the immensely helpful "Sente Assistant".

