Helper = require('wire-context-helper').Helper('tests-lib')

module.exports =
  helper:
    module: 'wire-context-helper'

  ################################
  # Persistence
  mongoose:
    module: 'mongoose'

  connection:
    sub:
      module: 'helper#beans.MongooseConnectionFactory'
      args: [
        Helper.ref 'mongoose'
        connection:
          url: 'mongodb://localhost:29017/node-gridfs-form-test'
      ]

  grid:
    create:
      module: Helper.persistence 'GridFSConnectionFactory'
      args: [
        Helper.ref 'connection'
        Helper.ref 'mongoose'
      ]

  ##############################
  # Server
  express:
    create:
      module: 'express'
      args: []

  app:
    sub:
      module: 'helper#beans.ConfigurableFactory'
      args: [
        Helper.ref 'express'
        Helper.refs [
          'applicationMiddlewareConfigurator'
          'applicationRouterConfigurator'
        ]
      ]

  applicationMiddlewareConfigurator:
    create:
      module: Helper.ApplicationConfigurator('Middleware')
      args: []

  applicationRouterConfigurator:
    create:
      module: Helper.ApplicationConfigurator('Router')
      args: [
        Helper.ref 'bbForm'
      ]

  bbForm:
    create:
      module: Helper.path('lib/domain/services/MultipartForm')
      args: [
        Helper.ref 'bb'
        Helper.ref 'grid'
        fileFilter: (name) -> name != 'source2'
      ]

  bb:
    create:
      module: Helper.path('lib/domain/services/parsers/BusboyParser')