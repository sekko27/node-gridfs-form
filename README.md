# Introduction

Module aims to provide easy way to bind multipart forms using MongoDB GridFS feature for storing uploaded files.
It does not write any temporary files, piping uploaded parts directly into gridfs instead (using gridfs-stream).

# Implementation

For multipart request parsing it has a busboy-based implementation. Other implementations are welcome.

# Usage

The module exports:

* BusboyParser - busboy-based parser implementation
* Form - Form binding implementation

## A basic scenario

For the details, see tests.

```coffeescroipt
// connection is a mongo connection, driver is the mongoose module
Grid = require 'gridfs-stream'
{BusboyParser, Form} = require 'gridfs-form'

grid = new Grid connection.db, driver.mongo

// app is an express instance

app.post '/upload', (req, res) ->
    form = new Form new Parser(), grid
    form.bind req, (err, bind) ->
        return res.status(500).send(err) if err
        res.status(200).json(bind);
```