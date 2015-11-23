$ ->

  addTest "City Title Case Test", ()->
    GlobalAddressNormalizer.fixTitleCase "new york"

  addTest "City Title Case Test varient", ()->
    GlobalAddressNormalizer.fixTitleCase "los angeles"
  go()