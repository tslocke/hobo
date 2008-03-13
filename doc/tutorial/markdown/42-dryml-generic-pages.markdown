## Customizing the Generic Pages

Rapid provides generic page layouts for the common model controller actions.

    <index-page>  e.g. /categories
    <show-page> e.g. /categories/1
    <new-page> e.g. /categories/new
    <edit-page> e.g. /categories/1/edit
    <show-collection-page> e.g. /categories/1/adverts
    <new-in-collection-page> e.g. /categories/1/adverts/new
{: .dryml}

To get started customizing a generic page you need to create the appropriate file in app/views and call the generic tag. For example, to begin customizing the index page for model named `Forum` you would create `app/views/forums/index.dryml` and write in the file:

    <index-page/>
{: .dryml}

Instead of calling `<index-page>` of course you could call any tag, but it is usually good practice to start from the generic version of the page you want to edit unless you want to do something drastically different

### Index Page

By default an index page is a paginated list of all the objects of a particular model.

    Index page
        [content-header:]
            heading:
            item-count:
        [content-body:]
            top-pagination-nav:
            collection:
            bottom-pagination-nav:
        [content-footer:]
            new-link:
            
Redefining an index page for an admin site:

    <def tag="index-page" extend-with="admin">
      <index-page-without-admin>
        <collection: replace>
          <table-plus param="table" merge-attrs="&attributes & attrs_for(:table_plus)" fields="name">
            <header: replace/>
            <controls:><a action="edit">Edit</a> <delete-button/></controls:>
          </table-plus>
        </collection:>
        <top-pagination-nav: replace/>
        <bottom-pagination-nav: replace/>
      </index-page-without-admin>
    </def>
{: .dryml}

### Show Page

### New Page

### Edit Page

### Show Collection Page

### New in Collection Page

Next: [Writing Individual Pages](43-dryml-individual-pages.html)