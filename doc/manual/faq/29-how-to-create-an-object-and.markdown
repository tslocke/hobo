# How to create an object and dependant objects on the same page

Originally written by amaltemara on 2008-12-21.

Example: 

I have an object called: 'contact', and an object called: 'office'.

The office has 3 separate fields, (pm, deputy, assistant), each of them a contact. The contacts do not stand on their own, so it doesn't make sense to create them separately.

office model:
belongs_to :pm_contact, class => 'Contact', :foreign_key => 'pm_contact_id'
belongs_to :deputy_contact, class => 'Contact', :foreign_key => 'deputy_contact_id'
belongs_to :assistant_contact, class => 'Contact', :foreign_key => 'assistant_contact_id'


The desired result is that while creating a new 'office', I can also create the 3 dependant contacts.

How can I do this hobo and dryml?

