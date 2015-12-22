##|
##|  Very simple database in memory similar to how Firebase stores keys/values
##|  That is, every bit of data has a path, key, and value.   Within each key
##|  there can also be meta data such as data type.
##|

class DataGatewayConfig

    formatName    : ""
    formatOptions : ""
    width         : null
    editable      : false

class DataGateway

    data: {}
    config: {}

    constructor: () ->

    getPath: (keyName, keyValue) =>
        if !@data[keyName]?
            @data[keyName] = {}

        if !@data[keyName][keyValue]
            @data[keyName][keyValue] = {}

        return @data[keyName][keyValue]

    getPathConfig: (keyName, columnName) =>
        if !@config[keyName]?
            @config[keyName] = {}

        if !@config[keyName][columnName]?
            @config[keyName][columnName] = new DataGatewayConfig()

    setPathFormat: (keyName, columnName, typeName, options) =>

        config = @getPathConfig keyName, columnName
        config.formatName = typeName
        config.formatOptions = options









