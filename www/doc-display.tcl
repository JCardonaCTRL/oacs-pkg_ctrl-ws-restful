ad_page_contract {

    Display the documentation


}


set package_id [ad_conn package_id]


set spec_info_list [ctrl::restful::getSpec $package_id]
multirow create restful_list key url name document method param_name param_label param_desc data_type

foreach spec_info $spec_info_list {
    array set spec_info_arr $spec_info 
    array set doc_elements [nsv_get api_proc_doc $spec_info_arr(procedure)]
    set spec_list [split $spec_info_arr(url) "/"]


    set url_var_list [list]

    foreach spec_name $spec_list {
	if [string first $spec_name ":"] {
	    lappend url_var_list [string range $spec_name 1 end]
	}
    }

    foreach option $doc_elements(option) {
	set first_space_idx [string first " " $option]
	set var_name [string range $option 0 [expr $first_space_idx-1]]  
	if ![empty_string_p $var_name] {
	    set desc [string range $option $first_space_idx end]
	    set help_text_arr($var_name) $desc
	}
    }

    if ![info exists spec_info_arr(private_param_list)] {
	set spec_info_arr(private_param_list) [list]
    }

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
	} elseif {[lsearch -exact $doc_elements(switches) $arg_name] < 0} {
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

	multirow append restful_list "${spec_info_arr(url)}_${spec_info_arr(method)}" $spec_info_arr(url) $spec_info_arr(name) $spec_info_arr(document) $spec_info_arr(method) 	$arg_name "${suffix_arg_name}$arg_name $suffix_text" $help_text $data_type

    }
    if {[llength $doc_elements(flags)] < 1} {
	multirow append restful_list "${spec_info_arr(url)}_${spec_info_arr(method)}" $spec_info_arr(url) $spec_info_arr(name) $spec_info_arr(document) $spec_info_arr(method) 	""
    }


#    set url_list [split $spec_info_arr(url) "/"]
}