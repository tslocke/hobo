desc "Taglib admin file matches inclusions"
file_include?( "app/views/taglibs/subs_site.dryml", tags, admin_tag )
test_value_eql? true

desc "Taglib admin file matches exclusions"
file_exclude?("app/views/taglibs/subs_site.dryml", invite_only)
test_value_eql? true
