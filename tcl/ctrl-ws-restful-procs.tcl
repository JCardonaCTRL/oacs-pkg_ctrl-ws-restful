ad_library {

    Procedures to handle WS Procs


    @author KH
    @cvs-$id
    @creation-date 2014-04-28
}


namespace eval ctrl::restful {}

ad_proc -public ctrl::restful::setSpec {
    -package_id
    -spec_info_list:required
} {
    @param package_id the package_id
    @param spec_info_list 
} {

    if ![info exists package_id] {
	set package_id [ad_conn package_id]
    }

    foreach spec_info $spec_info_list {
	ctrl::restful::addSpecEntry -package_id $package_id $spec_info 
    }
} 


ad_proc -private ctrl::restful::setSpec_internal {
    -package_id
    -spec_info_list:required
} {
    @param package_id the package_id
    @param spec_info_list 
    @parma no_check Whether to check specification, Parameter used internally
} {

    if ![info exists package_id] {
	set package_id [ad_conn package_id]
    }

    nsv_set ctrl_ws_restful package_$package_id $spec_info_list
} 


ad_proc -private ctrl::restful::getSpec {
    package_id 
} {
    Returns the ws restful specification
} {

    if ![nsv_exists ctrl_ws_restful package_$package_id] {
	set spec_info_list [nsv_set ctrl_ws_restful package_$package_id [list]]
    } else {
	set spec_info_list [nsv_get ctrl_ws_restful package_$package_id]
    }
    return $spec_info_list
}


ad_proc -public ctrl::restful::addSpecEntry {
    -package_id:required 
    -spec_info:required
} {

   Adds WS specification for package. If the spec already exist, then 

   @param package_id the package 
   @param spec_info the specification
 
} {

    set spec_info_list [ctrl::restful::getSpec $package_id]
    array set spec_info_arr $spec_info

    if {![info exists spec_info_arr(url)] && ![info exists spec_info_arr(method)] } {
	error "specs require the URL and method"
    }	

    set index 0
    set found_p 0


    foreach spec_info_tmp $spec_info_list {
	array set spec_info_tmp_arr $spec_info_tmp
	
	if { ([string equal $spec_info_tmp_arr(method) $spec_info_arr(method)]) && ([string equal $spec_info_tmp_arr(url) $spec_info_arr(url)]) } {
	    set spec_info_list [lreplace $spec_info_list $index $index $spec_info]
	    set found_p 1
	    break
	}
	incr index 1
    }

    if !$found_p {
	lappend spec_info_list $spec_info
    }

    ctrl::restful::setSpec_internal -package_id $package_id -spec_info_list $spec_info_list
}


ad_proc -public ctrl::restful::removeSpecEntry {
    -package_id:required 
    -url:required
    {-method get}
} {


   removes WS specification for package 

   @param package_id the package 
   @param spec_info the specification
 
} {

    set spec_info_list [ctrl::restful::getSpec $package_id]
    if [empty_string_p $spec_info_list] return

    set index 0
    set found_p 0
    foreach spec_info_tmp $spec_info_list {
	array set spec_info_tmp_arr $spec_info_tmp
	
	if {[string equal -nocase $spec_info_tmp_arr(method) $method] &&  \
		[string equal -nocase $spec_info_tmp_arr(url) $url]} {
	    set spec_info_list [lreplace $spec_info_list $index $index]
	    set found_p 1
	    break
	}
	incr index 1
    }

    if $found_p {
	ctrl::restful::setSpec_internal -package_id $package_id -spec_info_list $spec_info_list
    }
}


ad_proc -public ctrl::restful::getSpecEntry {
    -package_id:required 
    -url:required
    {-method get}
} {

   removes WS specification for the URL and method

   @param package_id the package 
   @param url the url
   @param method
 
} {

    if ![nsv_exists ctrl_ws_restful package_$package_id] {
	return ""
    } 
    
    set spec_info_list [nsv_get ctrl_ws_restful package_$package_id]


    set index 0
    set found_p 0
    foreach spec_info_tmp $spec_info_list {

	array set spec_info_tmp_arr $spec_info_tmp
	
	if {[string equal -nocase $spec_info_tmp_arr(method) $method] &&  \
		[string equal -nocase $spec_info_tmp_arr(url) $url]} {
	    return $spec_info_tmp
	}
	incr index 1
    }

    return ""
}


ad_proc ctrl::restful::get_form_data {} {
    Retrieves the form data based on the content type in a ns_set.  Currently supported :
       JSON 
      application/x-www-form-urlencoded;
} {

    array set headers [ns_set array [ns_conn headers]]

    set key_list "none"
    set key_value_list [list]

    set content_type_info_list [array get headers {[Cc][Oo][Nn][Tt][Ee][Nn][Tt]-[Tt][Yy][Pp][Ee]}]

    set found_index [lsearch -nocase $content_type_info_list content-type]


    if {$found_index > -1} {

	set header_item_info [lindex $content_type_info_list [expr $found_index+1]]
	set header_item_list [split $header_item_info ";"]

	set json_content_type 0
	foreach header_item $header_item_list {
	    if {[string first json $header_item]  > -1} {
		set json_content_type 1
	    }	
	}
	
	# ------------------------------------------
	# If content type is json then parse the json structure and put in ns_set
	# ------------------------------------------
	if {$json_content_type > 0} {
	    set form_data [ns_set create]
	    set message "[ns_conn content]"
	    package require json

	    if {[catch { set message_dict [json::json2dict $message] } errmsg] == 0} {
		set key_list [dict keys $message_dict]
		foreach key $key_list {
		    set value [dict get $message_dict $key]
		    ns_set put $form_data $key "$value"
		    lappend key_value_list $key $value
		}
	    } else {
		error $errmsg 
	    
}
	    	# doc_return 200 text/plain "$key_value_list"
	    return $form_data
	} 

	
    }

    # Return the default ns_getform , if no other format is handled
    return [ns_getform]

}

ad_proc -public ctrl::restful::process_request_url {
    -package_id
    -request_url:required
    {-method get}
} {

    Executes the request_url for the URL

    @param package_id the package_id
    @param requset url the URL
    @param method the method
} {

    if ![info exists package_id] {
	if ![ad_conn -connected_p] {
	    error "Failed: Package ID is required if there is no connection."
	}
	set package_id [ad_conn package_id]
    }

    # Retrieve the WS specifications to check what is the required to use 
    # in the current request; url, procedure, args, and so on.
    set spec_info_list [ctrl::restful::getSpec $package_id]

    # ------------------------------------------------------
    # Divide the URLs (Spect and Request) in sections in order to match the 
    # parameters with the corresponding values that the request URL has 
    set request_url_list [split $request_url "/"]
    set request_url_list_count [llength $request_url_list]

    set request_var_list [list]
    set index_place 0

    set page_ns_set [ctrl::restful::get_form_data]

    set failed_p 0
    
    set row_count 0

    foreach spec_info $spec_info_list {

	array set spec_info_arr $spec_info
	set url_list [split $spec_info_arr(url) "/"]

	set url_list_count [llength $url_list]
	incr row_count 1
    # ------------------------------------------------------


	if ![string equal -nocase  $method $spec_info_arr(method)] {
	    continue
	}

	# --------------------------------------------------
	# Find the registered procedue for handling this URL
	# --------------------------------------------------
	if {$url_list_count == $request_url_list_count} {

	    set url_index 0
	    set match_p 1
	    set tmp_page_var_value_list [list]

	    # Cycle to replace the match the URL parameters with the corresponding
	    # values that the request URL has
	    foreach item_var $url_list {
	    	set item_var [string trim $item_var]
	    	set request_item_var [string trim [lindex $request_url_list $url_index]]

	    	# Try to set the value when the current section of the cycle 
	    	# corresponding for an parameter, join the URL request value 
	    	# with the espect URL parameter
			if {[string equal [string index $item_var 0] ":"]} {
			    set item_var [string range $item_var 1 end]

			    # If the Request URL has not the value for the parameter set 
			    # as empty string to continue with the process, this to avoid 
			    # bad URLs when don;t exist interspersed parameters 
			    if {![string eq $request_item_var ":$item_var"]} {
			    	lappend tmp_page_var_value_list $item_var  $request_item_var
			    } else {
			    	lappend tmp_page_var_value_list $item_var  ""
			    }
			} else {
			    if ![string equal $request_item_var $item_var]  {
				set match_p 0
			    }
			}
			incr url_index 1
	    }
	    # ---------------------------
	    # Ignore if the signatures do not match 
	    # --------------------------
	    if !$match_p {
			continue
	    }


	    # ----------------------------
	    # Check if a audit log of the web service should be made
	    # ----------------------------
	    
	    if {![info exists spec_info_arr(log_p)]} {
	    	set spec_info_arr(log_p) "f"
	    }
	    if {![info exists spec_info_arr(self_handle_error_p)]} {
	    	set spec_info_arr(self_handle_error_p) "f"
	    }

	    if {$spec_info_arr(log_p) == "t"} {
	    	set new_value_list [list]

			set endPoint $spec_info_arr(url)

			set clientIP [ad_conn peeraddr]

			set input_list [ns_set array $page_ns_set]

			set json_input_list [list]
			foreach {key value} $input_list {
				set value [string map {"\\" "\\\\"} $value]
				lappend json_input_list [list $key $value]
			}

			foreach {key value} $tmp_page_var_value_list {
				set value [string map {"\\" "\\\\"} $value]
				lappend json_input_list [list $key $value]
			}

			set json_input_list [ctrl::json::construct_record $json_input_list]
			
			lappend new_value_list [list endPoint $endPoint] [list clientIP $clientIP] [list input $json_input_list "o"]
			
			set header_set [ad_conn headers]

			set authorization_list [ns_set iget $header_set authorization]
			set auth_type [lindex $authorization_list 0]
			set access_token [lindex $authorization_list 1]

			set auth_type [parameter::get -package_id [ad_conn package_id] -parameter auth_type]

			if {$access_token ne ""} {
				lappend new_value_list [list OAuthToken $access_token]
			}

			
			ctrl_acs_object_audit::new -object_id [ad_conn package_id] \
			    -audit_user_id [ad_conn user_id] \
			    -change_label "New Web Service Call" \
			    -old_value "" \
			    -new_value $new_value_list \
			    -package_id $package_id \
			    -audit_desc "New Web Service Call"

		
		}

	    # ----------------------------
	    # Check permissions and set headers
	    # ----------------------------
	    if {$spec_info_arr(oauth_p) == "t"} {
			ctrl::oauth::conn_init 
	    }

	    
	    array set doc_elements [nsv_get api_proc_doc $spec_info_arr(procedure)]
	    set switch_list $doc_elements(switches0)


	    array set page_var_arr $tmp_page_var_value_list 
	    set page_var_list [array names page_var_arr]

	    set arg_list $doc_elements(arg_list) 

	    array set default_value_arr $doc_elements(default_values) 

	    set visited_arg_list [list]
	    foreach {arg_name arg_flag_list} $doc_elements(flags) {


			# -----------------------------------
			# Check if this parameter is required 
			# ------------------------------------
			set require_p 0
			if {[lsearch -exact $arg_flag_list "required"] > -1} {
			    set require_p 1
			} elseif {[lsearch -exact $doc_elements(switches0) $arg_name] < 0} {
			    set require_p 1
			}
lappend visited_arg_list "no3-$arg_name"

			# ------------------------------------------------------------
			# If argument is already part of URL, then do not process variable from form 
			# -----------------------------------------------------------
			if {[lsearch -exact $page_var_list $arg_name] < 0} {

			    set found_index [ns_set find $page_ns_set $arg_name]
			    # if the required field does not exist, then it is an error
			    if {($found_index < 0) && ($require_p == 1)} {
					set return_data_json [ctrl::restful::api_return -response_code "missing_parameter" -response_message "Missing parameter $arg_name" -response_body ""]
					doc_return 400 application/json $return_data_json
					set failed_p 1
					break
			    } elseif {$found_index < 0} {
				# Not found, check if there are defualts
				# if {[lsearch -exact [array names default_value_arr] $arg_name] > -1} {
				#		set page_var_arr($arg_name) [set default_value_arr($arg_name)]
				# }
			    } else {

					set page_var_arr($arg_name) [ns_set get $page_ns_set $arg_name]
			    }
			} else {

			}

	    }


	    # --------------------------------------------------------
	    # Build the procedure call 
	    # --------------------------------------------------------
	    set call_param_list [list]
	    set process_list [list]
	    set var_index 1

	    if !$failed_p {
		foreach {arg arg_flag_list} $doc_elements(flags) {
		    
		    if [info exist page_var_arr($arg)] {

			# If not a switch , then pass in the value directly
			if {[lsearch -exact $switch_list $arg] <  0} {
			    set var__${arg} [set page_var_arr($arg)]			    

#			    lappend call_param_list "[set page_var_arr($arg)]"
#			    set var_${var_index} [set page_var_arr($arg)]
			    lappend call_param_list "\$var__${arg}"
			} else {

			    # If not boolean then pass in directly
			    if {[lsearch -exact $arg_flag_list boolean] < 0} {

				set var__${arg} [set page_var_arr($arg)]			    				
				
				lappend call_param_list "-$arg"  "\$var__${arg}"
				lappend process_list $arg
			    } else {
				lappend call_param_list "-$arg"
			    }
			}
		    }
		}
		set call_proc_details "$failed_p $spec_info_arr(procedure) $call_param_list -- $doc_elements(flags)"

		if {$spec_info_arr(self_handle_error_p)} {
			if {[llength $call_param_list] > 0} {
			    set result [eval $spec_info_arr(procedure) {*}$call_param_list]
			} else {
			    set result [eval $spec_info_arr(procedure)]	    
			}
		} else {
			if {[llength $call_param_list] > 0} {
			    set failed_p [catch {set result [eval $spec_info_arr(procedure) {*}$call_param_list]} errmsg]  
			} else {
			    set failed_p [catch {set result [eval $spec_info_arr(procedure)]} errmsg]   
			}

			if {$failed_p  != 0} {
			    ns_log notice "ERROR : $errmsg"
			    doc_return 500 application/json  [ctrl::restful::api_return -response_code "Server Error" -response_message "ERROR : $errmsg" -response_body ""] 
			    ad_script_abort
			} else {
				set result4 [ctrl::restful::api_return -response_code "ok" -response_message "" -response_body $result]
				doc_return 200 application/json "$result4"
				ad_script_abort
			}
		}

	    return "$result"

	    }
	}
    }

    set return_data_json [ctrl::restful::api_return -response_code "not_found" -response_message "Web Service was not found" -response_body ""]
    doc_return 404 application/json $return_data_json
    return ""

}

ad_proc -public ctrl::restful::api_return {
	{-response_code "ok"}
	{-response_message ""}
	{-response_body ""}
	{-response_body_value_p "t"}
} {
	@param response_code the code to indicate if there is an error. If there is no error then use ok
	@param response_message the message to give details of an error. If there is no error then return empty
	@param response_body the results of the api calls. If there is an error then return empty
} {
    if {$response_body_value_p == "t"} {
        set response_body_type "s"
    } else {
        set response_body_type "o"
    }
    return "{[ctrl::json::construct_record [list [list response_code $response_code s]  [list response_message $response_message s] [list response_body $response_body $response_body_type]]] }"
}

		  
ad_proc -public ctrl::restful::load_file {
    package_id
} {
    @param package_id the package_id
} {

#    set file_loc "[acs_package_root_dir "ctrl-ws-restful"]/lib/ws/spec-files-${package_id}.json"

    set file_loc [ctrl::restful::get_ws_file $package_id]

    set file_exists_p [file exists $file_loc]
    if $file_exists_p {
	set file_id [open $file_loc r]
	set spec_file_text [read $file_id]
	close $file_id
	ctrl::restful::setSpec_internal -package_id $package_id -spec_info_list $spec_file_text
    }
}


ad_proc -public ctrl::restful::get_ws_file {
    package_id 
} {



    set p_ws_file [parameter::get -package_id $package_id -parameter ws_file]
    set p_ws_dir [parameter::get -package_id $package_id -parameter ws_dir]

    if {[empty_string_p $p_ws_file]} {
	set p_ws_file "spec-files-${package_id}.json"
    }
    set file "[get_server_root]/$p_ws_dir/$p_ws_file"
    return $file
}


ad_proc -public ctrl::restful::ad_script_abort_p {
} {
    Check if there was a call made to  ad_script_abort.  Pretty much error rolling up
} {
    global errorCode
    set is_ad_script_abort 0

    if [info exists errorCode] {
        if {[lindex $errorCode 2]  == "ad_script_abort"} {
            set is_ad_script_abort 1
        }
    }
    return $is_ad_script_abort
} 
