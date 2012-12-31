# Quick-and-Dirty Required Field Highlighter

Originally written by dziesig on 2011-09-20.

After almost a year of beta testing, the REAL users requested that the required/mandatory fields be highlighted.  (I had thought of this last year at the beginning of development, but could not figure out how to do it, then).

I recently found a thread from January 2011 that discussed this capability\.  In this thread, the use of &lt;feckless-fieldset> was recommended.  I tried this and got it to work (functionally, that is; it would highlight the required fields), but it took much too much time to style.  Unless I missed something, each page needed to be styled independently which would have taken more time than I had available.

After examining the &lt;feckless-fieldset> code, it appeared that the highlighting capability could be merged with the normal &lt;field-list> tag to give me the effect that I wanted.

I modified &lt;field-list> to produce &lt;field-list-star-required> (star-required being the imperative, meaning put a star (\*) on each required field).

Using this, I could change the form code from:

    <field-list fields="family_name, given_name, middle_name, address1, address2, city, state_prov, postal_code, ssan" param/>

to:

    <field-list-star-required fields="family_name, given_name, middle_name, address1, address2, city, state_prov, postal_code, ssan" \
    required="family_name, given_name, address1, city, state_prov, postal_code, ssan" param/>

I put the following code in application.dryml (I should have put it in a separate file, but as the title says, "quick and dirty"):

    <def attrs='tag, no-edit, required' tag='field-list-star-required'>
      <% tag ||= scope.in_form ? "input" : "view"; no_edit ||= "skip" %>
      <% required ||= "" ; required = comma_split(required.gsub('-', '_')) -%>
      <labelled-item-list merge-attrs='&amp;attributes - attrs_for(:with_fields)'>
        <with-fields merge-attrs='&amp;attributes &amp; attrs_for(:with_fields)'>
        <% field_name = this_field_name 
           input_attrs = {:no_edit => no_edit} if tag == "input"
        -%>
          <labelled-item unless='&tag == &apos;input&apos; && no_edit == &apos;skip&apos; && !can_edit?'>
            <item-label \
            param='#{scope.field_name.to_s.sub(&apos;?&apos;, &apos;&apos;).sub(&apos;.&apos;, &apos;-&apos;)}-label' \
            unless='&field_name.blank?'>
            <do param='label'><%= field_name %></do>
            <% if required.index(scope.field_name) %>
              <span class='required'>*</span>
            <%end%>
            </item-label>
            <item-value \
            param='#{scope.field_name.to_s.sub(&apos;?&apos;, &apos;&apos;).sub(&apos;.&apos;, &apos;-&apos;)}-view' 
            colspan='&2 if field_name.blank?'>
              <do param='view'>
                 <call-tag tag='&tag' param='#{scope.field_name.to_s.sub(&apos;?&apos;, \
                 &apos;&apos;).sub(&apos;.&apos;, &apos;-&apos;)}-tag' 
                  merge-attrs='&amp;input_attrs'/>
              </do>
              <div param='input-help' if='&tag.to_sym == :input && !this_field_help.blank?'><%= this_field_help %></div>
            </item-value>
          </labelled-item>
        </with-fields>
      </labelled-item-list>
    </def>

and the following code in application.css:

    .required { color : red; }

The resulting form, when being edited, shows each of the required field's captions with a red asterisk appended.  Just what I needed, no more, no less.

If anyone would like to extend this such that the required fields in the model replace the static list in the tag's invocation, please do so (and let me know!).

