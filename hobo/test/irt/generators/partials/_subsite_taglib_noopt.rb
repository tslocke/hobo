desc "Taglib file matches"
file_include?("app/views/taglibs/subs_site.dryml", tags) &&
file_exclude?("app/views/taglibs/subs_site.dryml", admin_tag, invite_only)
test_value_eql? true
