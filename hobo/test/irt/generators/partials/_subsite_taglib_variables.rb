tags = %(<!-- Tag definitions for the subs subsite -->

<include src="taglibs/auto/subs/rapid/cards"/>
<include src="taglibs/auto/subs/rapid/pages"/>
<include src="taglibs/auto/subs/rapid/forms"/>
)

invite_only = %(<extend tag="card" for="#{user_resource_name}">
  <old-card merge>
    <append-header:><%= h this.state.titleize %></append-header:>
  </old-card>
</extend>)
