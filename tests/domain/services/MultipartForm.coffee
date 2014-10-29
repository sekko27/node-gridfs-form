_ = require 'lodash'
request = require 'supertest'

{Runner} = require 'wire-context-helper'
{assert} = require 'chai'

describe 'MultipartForm', ->
  app = null
  r = -> request(app).post('/busboy').type('form')

  before (done) ->
    spec = require './../../../test-lib/contexts/tests'
    Runner spec, (err, context) ->
      app = context?.app
      done(err)

  describe 'busboy forms', ->
    it 'should bind field-only forms', (done) ->
      r()
        .field('field1', 'value1')
        .field('field2', 'value2')
        .end (err, res) ->
          assert.isNull err
          assert.equal res?.body?.field1, 'value1'
          assert.equal res?.body?.field2, 'value2'
          done()

    it 'should bind file-only forms', (done) ->
      r()
        .attach('source', "#{__dirname}/MultipartForm.coffee")
        .end (err, res) ->
          assert.isNull err
          assert.isTrue ( _.isString(res.body?.source) and /^[0-9a-f]{24}$/i.test(res.body.source) )
          done()

    it 'should bind mixed forms', (done) ->
      r()
        .field('field1', 'value1')
        .field('field2', 'value2')
        .attach("source", "#{__dirname}/MultipartForm.coffee")
        .end (err, res) ->
          assert.isNull err
          assert.equal res?.body?.field1, 'value1'
          assert.equal res?.body?.field2, 'value2'
          assert.isTrue ( _.isString(res.body?.source) and /^[0-9a-f]{24}$/i.test(res.body.source) )
          done()

