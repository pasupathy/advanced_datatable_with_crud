# advanced_datatable_with_crud
<ul>
<li>This is a sample Create,Read,Update and Delete records in Flutter.</li>
<li>For Read / Listing , it uses <b>advanced_datatable</b> package which by default, comes with pagination, page size,sorting, general search using one text input</li>
<li>I have added extra features by adding a dropdown of all the fields and a text input, with them you can search by fields</li>
<li>At the end of a row , I have added action column edit and delete</li>
<li>Edit will navigate to new page with selected row values populating the form, complete with validation</li>
<li>Delete uses flutter's show dialog and alert dialog to prompt cancel or confirm deletion</li>
  <li>Add is available as floating button at bottom and navifate to a new page</li>  
  <li>Context of the main widget is passed to the datatable source to allow navigation from and to for edit,delete and also add</li>
    <li>The following package are used : advanced_datatable - for datatable, http - for async call to remote DB, fluttertoast for notification</li>
  <li>What is not included here is a serverside api codes</li>
<li>You can use any database and server side language to generate json data for the api calls
<li>The code runs well for both android and web</li>

</ul>

