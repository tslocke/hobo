# What do I do to make search and sorting work with table-plus? 

Originally written by kevinpfromnm on 2010-09-12.

Hello,
   First of all, huzzah for Hobo and DRY.   Anyway, I'm a newbie and I
need help with table-plus and searching on index.dryml?  Here's my
code and scripts:

    $ hobo searchie
    $ script/generate hobo_model_resource person first_name:string last_name:string

`searchie/app/views/persons/index.dryml`

    <index-page>
      <collection: replace>
        <table-plus fields="this, first_name, last_name">
          <empty-message:>No persons match your criteria</empty-message:>
        </table-plus>
      </collection:>
    </index-page>

What do I put on `searchie/app/controllers/persons_controller.rb` to
make search and sorting work?

Regards,
JD 