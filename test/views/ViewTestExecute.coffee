class ViewTestExecute extends View

    onShowScreen: ()=>

    addHolder: (name)=>

        for e in @children
            e.el.remove()

        @children = []
        @resetCached()

        return this
