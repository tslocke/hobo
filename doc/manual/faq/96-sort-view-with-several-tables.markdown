# Sort view with several tables

Originally written by Javier on 2011-05-10.

Hi, I have 2 tables in my data base, user and equipment, I have a view where i display the name of the user and the equipment he is using. I can order the view by equipment, if you click on the equipment header the page displays ins DESC or ASC order the report, but if I click on user It does'nt do anything. My report_controlle is like this:

hobo_model_controler
auto_actions :all

 def index
   scopes = {order_by => parse_sort_param(:equipment,:user)}
   hobo_index Equipment.apply_scopes(scopes) 
end
end

Can you help me pleas?