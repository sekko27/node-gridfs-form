Grid = require 'gridfs-stream'

module.exports = (connection, driver) ->
  Grid.mongo = driver
  new Grid connection.db, driver.mongo
