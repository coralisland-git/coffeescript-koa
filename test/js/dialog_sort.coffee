$ ->

    Words = [ "Apple", "Ball", "Bat", "Bath", "Car", "Dog", "Double", "Big Dog", "Bath House", "Ball Boy", "Dog Track", "Tracking", "Simple", "Zebra", "Cow","Horse","Pig","Snake"]

    list = []
    counter = 0
    for w in Words
        isActive = true
        if counter % 4 == 0 then isActive = false
        list.push
            name: w
            order: counter
            active: isActive
        counter++

    m = new ModalSortItems("Sort items test", list)

