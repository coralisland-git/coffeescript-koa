
globalMathEngine = null

class MathEngine

    constructor: ()->

        math.import
            IF : (cond, a, b)->
                if (cond) then return a
                return b

        @parser = math.parser()

    @getEngine: ()=>
        if !globalMathEngine?
            globalMathEngine = new MathEngine()

        return globalMathEngine

    ##|
    ##|  Set the values for the eval
    ##|
    setValues: (scope, prefix)=>

        for varName, value of scope

            txt = prefix + varName.replace(/[^a-zA-Z0-9]/g, "").toLowerCase()
            if typeof value == "object"
                if value.getTime?
                    @parser.set txt, value
                else
                    @setValues value, txt + "_"
            else
                console.log "Setting [#{txt}] = #{value}"
                @parser.set txt, value

        true


    ##|
    ##|  Calculate a formula
    ##|
    calculate: (expression, scope)=>

        try

            if !@parser? then @init()

            expression = expression.toLowerCase()
            @setValues scope, ""
            result = @parser.eval expression, scope
            return result

        catch e

            console.log "MathEngine error:", e, "in expression", expression, "scope:", scope
            return 0