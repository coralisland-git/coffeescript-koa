CoffeeNinja – Understanding the Widget
------------------------------------------

Using jQuery to access DOM is easy but very slow.   Consider something simple

    $("#pageTitle").html("This is the new title");

In this case we ask jQuery to search DOM for the correct element(s) and then we execute an update 
against the DOM.  It doesn't matter if it is needed or not.  There is a lot of CPU time to do this.

Many frameworks such as Angular and Vue have created the Shadow DOM to solve this problem.  This
is the same with [class Widget](src/WidgetBase.coffee).   The idea is to shadow a given element of
the DOM so when we make changes it can be done very fast.   For example, setting the HTML only
executes agains the DOM if a change is detected.   The element size such as height and width
are stored in Cache so they are very fast to access many times.

The Widget is key to making very fast controls in HTML5 and should be the Base for all custom
widget controls in the CoffeeNinja library.

Currently it is not due to legacy old code that needs to be updated.   It will be a goal to 
use Widget as a base in the future.

Note, the Widget is important for another reason.

All data on the screen can be defined as static (text) or dynamic (variable).   If the data is dynamic 
then we must be prepared for a realtime update.  So a dynamic value should be mapped to a path in 
the [DataMap](/UnderstandData.md).    When the data is changed in the data map it will issue an event
and the Widget will know to change the display value.

For example, suppose we have something on the screen related to a user and his total earnings.  This might be defined as:

    /user/bpollack/sales/total_earnings

This would defined as a *number* which has a [Data Formatter](/src/data_formatter/data_formatter_types).   The value in the data map may be 10040.34245.

The Widget will know to use the DataFormatter class before updating the display and will show '$10,040.32' on the screen correctly.

The Widget will also know the column is Editable and will create the events and CSS so the user can edit the value.   Save the value back to the server, and update the data map so any other place it appears on the screen are updated.



