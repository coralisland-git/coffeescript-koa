root = exports ? this
root.TableConfigTest = []

root.TableConfigTest.push
        name       : 'RR ID'
        source     : 'id'
        visible    : true
        hideable   : true
        editable   : false
        type       : 'int'
        required   : true

root.TableConfigTest.push
        name       : 'MLS ID'
        source     : 'mls_id'
        visible    : false
        hideable   : false
        editable   : false
        type       : 'int'
        required   : true

root.TableConfigTest.push
        name       : 'RETS Server Unique ID'
        source     : 'sys_id'
        visible    : false
        hideable   : false
        editable   : false
        limit      : 32
        type       : 'text'
        required   : false