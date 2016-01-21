###

This class represents one set of data which means

    a)  Columns or a definition of the data
    b)  A source for the data

###

root = exports ? this
root.DataSet = class DataSet

    ##|
    ##|  Create a new data set
    ##|  param @baseName - The name for this data set, used to map the set to a database
    ##|  param columnData - A supported list of columns
    ##|     a DataTypeCollection
    constructor : (@baseName, columnData)->

        @columns = {}
        @data    = {}

        if columnData? and columnData instanceof DataTypeCollection
            ##|
            ##|  Initialize the data set with a list of columns
            ##|  based on the DataTypeCollection from data_formatter
            ##|
            @columns = columnData.colList


    setAjaxSource: (url, @subElement, @keyElement) =>

        @dataSourceType = "ajax"
        @dataSourceUrl  = url
        true


    ##|
    ##|  Returns a promise that loads the data
    doLoadData: () =>

        new Promise (resolve, reject) =>

            if @dataSourceType == "ajax"

                ##|
                ##|  Load Ajax Data
                $.ajax

                    url: @dataSourceUrl

                .done (rawData) =>

                    if @subElement? and @subElement
                        rawData = rawData[@subElement]

                    for i, o of rawData

                        if @keyElement?
                            key = o[@keyElement]
                        else
                            key = i

                        @data[key] = o

                    resolve(@data)

                .fail (e) =>

                    reject(e)

            else

                reject new Error "Unknown "







