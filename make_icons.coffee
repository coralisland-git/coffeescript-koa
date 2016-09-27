fs       = require 'fs'

data   = fs.readFileSync "test/vendor/baseedgeweb.css"
reIcon = /\.([sf][ia]\-.*):before/

data = data.toString()

all = []
for line in data.split("\n")
    m = line.match reIcon
    if m? and m[1]?
        all.push m[1]

list = all.sort()
fs.writeFileSync "icons.json", JSON.stringify(list)


