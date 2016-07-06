$ ->

    addTest "Change Title", ()->

        html = '''
            <input id='tags1' name='tags' style='width: 100%; height: 200px' />
        '''

        m = new ModalDialog
            title:   "Change title test"
            content: html

        $("#tags1").selectize
            plugins: ['remove_button']
            delimiter: ','
            persist: false
            create: (input) ->
                console.log "Adding[#{input}]"
                return { value: input, text: input }


    go()