
proc ::my_options_handler args {
    ns_set put [ad_conn outputheaders] "Access-Control-Allow-Origin" "*"
    ns_set put [ad_conn outputheaders] "Access-Control-Allow-Methods" "GET, POST, PATCH, FETCH, PUT, DELETE, OPTIONS"
    ns_set put [ad_conn outputheaders] "Access-Control-Allow-Headers" "Content-Type, Authorization"
    ns_return 200 text/plain {}
}

#Test PUT and POST

ns_log notice "CTRL-WS preauth filters loaded"

set url_list [list "/ws-v1/*" "/ws/*"]

foreach url $url_list {
    ns_register_proc DELETE ${url} rp_handler
    ns_register_proc PUT ${url} rp_handler
    ns_register_proc OPTIONS ${url} ::my_options_handler
}

# ----------------------------------------
# reload all the json files for all instances
# ----------------------------------------
db_foreach pkg_instance_id {
    select package_id 
    from apm_packages
    where package_key = 'ctrl-ws-restful' 
} {
    set error_p [catch {ctrl::restful::load_file $package_id} errmg]
    if {$error_p != 0} {
	ns_log error "Failed loading CTRL-WS-RESTFUL $package_id : $errmsg"
    }
}
