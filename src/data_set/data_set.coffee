###

This class represents one set of data which means

    b)  A source for the data

###

root = exports ? this
root.DataSet = class DataSet

    ##|
    ##|  Create a new data set
    ##|  param @baseName - The name for this data set, used to map the set to a database
    constructor : (@baseName)->

        @data       = {}
        @useDataMap = true


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

                    ##|
                    ##|  Access the global data map
                    if @useDataMap
                        dm = DataMap.getDataMap()

                    for i, o of rawData

                        if @keyElement?
                            key = o[@keyElement]
                        else
                            key = i

                        if @useDataMap
                            DataMap.addData @baseName, key, o
                        else
                            @data[key] = o

                    resolve(this)

                .fail (e) =>

                    reject(e)

            else

                reject new Error "Unknown "







