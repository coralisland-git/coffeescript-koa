## -------------------------------------------------------------------------------------------------------------
## class DataSet global class to handle all the data providing task
## behaves as a source of data
##
root = exports ? this
root.DataSet = class DataSet

    ## -------------------------------------------------------------------------------------------------------------
    ## create a new data set
    ##
    ## @param [String] baseName the name for this data set, used to map the set to a database
    ##
    constructor : (@baseName)->
        # @property [Object] data the data to provide
        @data       = {}

        # @property [Boolean] useDataMap weather to use dataMap or not
        @useDataMap = true

    ## -------------------------------------------------------------------------------------------------------------
    ## function to set the ajax as data source
    ##
    ## @param [String] url the url from where to fetch data
    ## @param [String] subElement to look for the key in the response
    ## @param [String] keyElement key name to track the data
    ## @return [Boolean]
    ##
    setAjaxSource: (url, @subElement, @keyElement) =>

        @dataSourceType = "ajax"
        @dataSourceUrl  = url
        true

    ## -------------------------------------------------------------------------------------------------------------
    ## Returns a promise that loads the data
    ##
    ## @return [Promise]
    ##
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

                    if Array.isArray(rawData)

                        for i in rawData

                            if i.data?
                                DataMap.addDataUpdateTable @baseName, i.data.id, i.data
                            else
                                DataMap.addDataUpdateTable @baseName, i[@keyElement], i

                    else

                        for i, o of rawData

                            if @keyElement?
                                key = o[@keyElement]
                            else
                                key = i

                            if @useDataMap
                                DataMap.addDataUpdateTable @baseName, key, o
                            else
                                @data[key] = o

                    resolve(this)

                .fail (e) =>

                    reject(e)

            else

                reject new Error "Unknown "
