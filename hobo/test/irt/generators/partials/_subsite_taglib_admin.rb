desc "Taglib admin file matches"
file_include?( "app/views/taglibs/subs_site.dryml", tags, admin_tag ) &&
file_exclude?("app/views/taglibs/subs_site.dryml", invite_only)
test_value_eql? true
