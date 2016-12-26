EdgeServer – Understanding the data model:
------------------------------------------

There are 4 parts to all data:

 1. Database 
 2. Collection Name (or Table Name) 
 3. Key Value 
 4. Field Name

Within this model you can access any data value using a URL format like this:

    database://collection/key/field 

For example:

    Gameproject://user/bpollack/last_login 

The “field name” can be multiple levels deep as needed.   The database model stores an object at “key value” so that you can have any level of complexity such as

    /user/bpollack/profile/address/city

Notes:  

 - Within the database, the field “id” is always used to represent the “key value”.  So searching for {id: “bpollack”} is how the database will find the record.
 
 - The database stores internal fields with _ as the first letter.   Within the model you may find values such as _id or _last_modified that come back.  These values are internal to the system and  shouldn’t be modified.   You should be aware of them if you iterate over a record.

Understand Column Types
-----------------------

By default any data can be added to the database model for an object.   The system, however, tracks the data in each field to create a data type mapping.  This is very like how Elastic creates a “mapping” configuration for each record in an index.

For any field we have the following options:

| Property    | Description
| ----------- | -----------------------------------------------------------------------------------------
| Order       | A numerical value that is used to help any visualizing tools know the order to show this field
| Name        | The name of the column in a printable / human version 
| Source      | The name of the column in terms of it's javascript object name
| Visible     | Boolean - Indicates to visualization tools to show or hide the column
| Ignored     | Boolean - Indicates to visualization tools to ignore the column entirely (can't be known about)
| Editable    | Boolean - Indicates that the value is editable by users
| Required    | Boolean - Indicates that the value is required if adding a new record
| Autosize    | Boolean - Indicates to visualization tools that the display size should be calculated at runtime
| Width       | Number - Indicates to the visualizing tools a desired width 
| Calculation | Boolean - Indicates that the field is a calculation or is a result of some code and not added directly to the database
| Align       | String - Indicates the type of alignment used by visualization tools 
| Type        | String - Indicates a known type from a DataFormatter to be used
| Options     | Mixed - Some options used in editing or displaying the value, used by the specific formatter
| Render      | Mixed - Can be code or a math reference which is used to calculate the value
| ACL         | Mixed - Access Control List, Coming soon, not yet defined

Generally speaking these options are important only to visualization tools right now, however,
this will change as the server will be executing the "render" code blocks as well.

Currently "render" can be javascript code which is compiled into a function by the DataMap engine or
it can start with "=" which is designed to run like an Excel formula.   In the case of "=" the 
value is run using Math.js library with some extensions to make it more compatible with Excel.  For example:

    =(ItemsSold * ItemPrice) + ShippingCost





