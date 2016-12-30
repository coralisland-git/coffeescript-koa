Codo - Api Doc Generation
------------------------------------------

The documentation of classes api is generated using the codo. 

To install the codo globally use the below command

`npm install -g codo`

each class should contain the tags to include it into generated docs

for more information about codo [Codo Documentation](https://github.com/coffeedoc/codo)

### supported doc words
<table>
  <thead>
    <tr>
      <td><strong>Tag format</strong></td>
      <td><strong>Multiple occurrences</strong></td>
      <td><strong>Classes</strong></td>
      <td><strong>Mixins</strong></td>
      <td><strong>Methods</strong></td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>@namespace</strong> namespace</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@abstract</strong> (message)</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@author</strong> name</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@concern</strong> mixin</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@copyright</strong> name</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@deprecated</strong></td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@example</strong> (title)<br/>&nbsp;&nbsp;Code</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@extend</strong> mixin</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@include</strong> mixin</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@note</strong> message</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@method</strong> signature<br/>&nbsp;&nbsp;Method tags</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@mixin</strong></td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@option</strong> option [type] name description</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@event</strong> name [description]<br />&nbsp;&nbsp;Event tags</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@overload</strong> signature<br/>&nbsp;&nbsp;Method tags</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td>
        <strong>@param</strong> [type] name description<br/>
        <strong>@param</strong> name [type] description<br/>
      </td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@private</strong></td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@property</strong> [type] description</td>
      <td></td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@public</strong></td>
      <td></td>
      <td>&#10004;</td>
      <td></td>
      <td>&#10004;</td> 
    </tr> 
    <tr>
      <td><strong>@return</strong> [type] description</td>
      <td></td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@see</strong> link/reference</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@since</strong> version</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@throw</strong> message</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@todo</strong> message</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@version</strong> version</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@nodoc</strong></td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
  </tbody>
</table>

the default options for codo are defined inside `.codoopts`

to generate/update the current docs run the following command

`npm run docs`

the above command will create/update the doc folder with all generated documentation 

To view generated documentations visit

[http://localhost:9000/doc/index.html](http://localhost:9000/doc/index.html)