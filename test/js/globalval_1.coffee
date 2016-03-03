$ ->


    addTest "GetMoment From Date", ()->

        testDate = new Date()
        m = GlobalValueManager.GetMoment(testDate)
        m.format("YYYY-MM-DD HH:mm:ss")

    addTest "DateTimeFormat 1 hr", ()->

        testDate = new Date()
        testDate.setHours testDate.getHours() - 1
        GlobalValueManager.DateTimeFormat GlobalValueManager.GetMoment(testDate)

    addTest "DateTimeFormat 5 min", ()->

        testDate = new Date()
        testDate.setMinutes testDate.getMinutes() - 5
        GlobalValueManager.DateTimeFormat GlobalValueManager.GetMoment(testDate)

    addTest "DateTimeFormat 12.5 hrs", ()->

        testDate = new Date()
        testDate.setHours testDate.getHours() - 12.5
        GlobalValueManager.DateTimeFormat GlobalValueManager.GetMoment(testDate)

    addTest "DateTimeFormat 50 hrs", ()->

        testDate = new Date()
        testDate.setHours testDate.getHours() - 50
        GlobalValueManager.DateTimeFormat GlobalValueManager.GetMoment(testDate)

    go()