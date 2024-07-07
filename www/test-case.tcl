ad_page_contract {


}



#ctrl::restful::setSpec_internal -package_id [ad_conn package_id] -spec_info_list {}

set result [ctrl::restful::addSpecEntry -package_id [ad_conn package_id] -spec_info {url ":category_id" method get private_param_list {} name "add category" procedure "category::add" document "Add category"}]

set result2 [ctrl::restful::getSpecEntry -package_id [ad_conn package_id] -url ":category_id"]

#set result3 [ctrl::restful::removeSpecEntry -package_id [ad_conn package_id] -url "khy-test/:category_id"]

set result4 [ctrl::restful::process_request_url -package_id [ad_conn package_id] -request_url "5"]

doc_return 200 text/plain "result -> $result2  ($result4)"


