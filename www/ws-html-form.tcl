
# @param post_loc the Post location
# @param admin_p whether to allow admin features

if ![info exists post_loc] {
    set post_loc ""
}

if ![info exists admin_p] {
    set admin_p 0
}


set package_id [ad_conn package_id]
set auth_type [parameter::get -package_id $package_id -parameter auth_type]
set auth_type [string tolower $auth_type]

set spec_info_list [ctrl::restful::getSpec $package_id]
multirow create restful_list key edit_url delete_url url name summary_doc document method param_type param_name param_label param_desc data_type

#doc_return 200 text/plain $spec_info_list

foreach spec_info $spec_info_list {
    array set spec_info_arr $spec_info 
    array set doc_elements [nsv_get api_proc_doc $spec_info_arr(procedure)]
    set spec_list [split $spec_info_arr(url) "/"]

    #doc_return 200 text/plain "[array get doc_elements] $spec_list"

    set url_var_list [list]


    foreach spec_name $spec_list {
	if [string first $spec_name ":"] {
	    lappend url_var_list [string range $spec_name 1 end]
	}
    }

    if [info exists doc_elements(option)] {
	foreach option $doc_elements(option) {
	    set first_space_idx [string first " " $option]
	    set var_name [string range $option 0 [expr $first_space_idx-1]]  
	    if ![empty_string_p $var_name] {
		set desc [string range $option $first_space_idx end]
		set help_text_arr($var_name) $desc
	    }
	}
    }

    if ![info exists spec_info_arr(private_param_list)] {
	set spec_info_arr(private_param_list) [list]
    }

    set request_url $spec_info_arr(url)
    set edit_url "entry-ae?[export_url_vars request_url method=$spec_info_arr(method)]"
    set delete_url ""

    set flag_count 0
    foreach {arg_name arg_flag_list} $doc_elements(flags) {

	if {[lsearch -exact $spec_info_arr(private_param_list) $arg_name] > -1} {
	    continue
	}

	# -----------------------------------
	# Check if this parameter is required 
	# ------------------------------------
	set require_p 0
	if {[lsearch -exact $arg_flag_list "required"] > -1} {
	    set require_p 1
	} elseif {[lsearch -exact $doc_elements(switches0) $arg_name] < 0} {
	    set require_p 1
	}

	set suffix_text ""
	if $require_p {
	    set suffix_text "(<span class='require'>*</span>)"
	}

	set suffix_arg_name ""
	if {[lsearch -exact $url_var_list $arg_name] > -1} {
	    set suffix_arg_name ":"
	}
	
	set data_type ""
	if {[lsearch  -exact $arg_flag_list boolean] > -1}  {
	    set data_type boolean
	}
	
	set help_text ""
	if [info exists help_text_arr($arg_name)] {
	    set help_text [set help_text_arr($arg_name)]
	}

	set param_type "form_var"
	if {[lsearch -exact $url_var_list $arg_name] > -1} {
	    set param_type "uri_var"
	}

	multirow append restful_list "${spec_info_arr(url)}_${spec_info_arr(method)}" $edit_url $delete_url $spec_info_arr(url) $spec_info_arr(ws_name) $spec_info_arr(document) [lindex $doc_elements(main) 0] [string toupper $spec_info_arr(method)] $param_type $arg_name "${suffix_arg_name}$arg_name $suffix_text" $help_text $data_type
	incr flag_count 1

    }
    if {$flag_count < 1} {
		multirow append restful_list "${spec_info_arr(url)}_${spec_info_arr(method)}" $edit_url $delete_url $spec_info_arr(url) $spec_info_arr(ws_name) $spec_info_arr(document) [lindex $doc_elements(main) 0] [string toupper $spec_info_arr(method)]  "" ""
    }


#    set url_list [split $spec_info_arr(url) "/"]
}

multirow sort  restful_list -increasing  url 