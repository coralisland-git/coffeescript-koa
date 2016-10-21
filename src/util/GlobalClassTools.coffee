
## -------------------------------------------------------------------------------------------------------------
## class GlobalClassTools
## providers a number of static functions that are designed to help in general purpose ways.
## this is required by all components in the folder
##

String.prototype.ucwords = ()->
    str = this.toLowerCase();
    return str.replace /(^([a-zA-Z\p{M}]))|([ -][a-zA-Z\p{M}])/g,
        ($1)->
            return $1.toUpperCase();

window.newPromise = (callFunction, context)->

    return new Promise (resolve, reject) ->

        if !callFunction?
            resolve(true)

        ##|
        ##|  parameter is a generator or something that co supports
        co(callFunction).call (context || this), (err, value)->
            if err
                console.log "ERR:", err
                reject(err)

            resolve(value)

class GlobalClassTools

    ##|
    ##|  Add an event manager object based on EvEmitter
    ##|  Adds functions on, off, once, and emitEvent to a calls.
    @addEventManager : (classObj) ->

        classObj.eventManager = new EvEmitter()
        classObj.on = (eventName, callback)->
            if eventName != "added_event"
                this.eventManager.emitEvent "added_event", [eventName, callback]

            this.eventManager.on eventName, callback
        classObj.off = (eventName, callback)->
            this.eventManager.off eventName, callback
        classObj.once = (eventName, callback)->
            this.eventManager.once eventName, callback
        classObj.emitEvent = (eventName, args)->
            if not Array.isArray(args) then args = [ args ]
            this.eventManager.emitEvent eventName, args

        true