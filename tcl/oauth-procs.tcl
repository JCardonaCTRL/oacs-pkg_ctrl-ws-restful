ad_library  {

    Procedures to handle OAuth 


    @author KH
    @cvs-id $Id$
    @creation-date  2014-06-23

}

namespace eval ctrl::oauth {}


ad_proc ctrl::oauth::return_error { 
    -error_code
    {-error_desc  ""}
    {-error_uri ""}
} {

    @option error_code the error code
    @option error_desc the error description
    @option error_uri redirect to for error
} {

    set valid_error_list [list invalid_request invalid_client invalid_grant unauthorized_client unsupported_grant_type invalid_token_expired]

    set found_idx [lsearch -exact $valid_error_list $error_code]
    if {$found_idx < 0} {
	error "Invalid response valid"
    }

    set status_code 400
    if {[string equal $error_code "invalid_client"] || [string equal $error_code "invalid_token_expired"]} {
	set status_code 401
    }

    doc_return $status_code application/json "{[ctrl::json::construct_record [list [list response_code $error_code s]  [list response_message $error_desc s] [list response_body $error_uri s]]] }"

}


ad_proc -public ctrl::oauth::authenicate_with_token {
    -email:required
    -password:required
    -uuid:required
    {-grant_type password}
    {-refresh_token_p 0}
} {

    Uses OAuth protocol to authenicate user 
   <pre>

    {
       /* the account's email
           -type string 
           -cardinality 1
       */
       "email" : "test@ctrl.ucla.edu" ,

       /* the account's password
           -type string 
           -cardinality 1
       */
       "password" : "abc" ,
 
      /* the app UUID
           -type string 
           -cardinality 1
       */
        "uuid": "234234"
    }


    Returns 
    {
      /* the access token
           -type string 
           -cardinality 1
       */
        "access_token":"2710901%2c2002%2c2+%7b614+1403883963+752DC83B880D7823FCD033EAAFB11E37A6150F37%7d",
      /* the token type
           -type string 
           -cardinality 1
       */
        "token_type":"bearer",
      /* token expires in ...
           -type integer
           -cardinality 1
       */
        "expires_in":1200
        /* the refresh token
           -type string 
           -cardinality 1
       */
        "refresh_token":"2710901%2c2002%2c2+%7b614+1403883963+752DC83B880D7823FCD033EAAFB11E37A6150F37%7d",
      /* the refresh token type
           -type string 
           -cardinality 1
       */
        "refresh_token_type":"bearer",
      /* refresh token expires in ...
           -type integer
           -cardinality 1
       */
        "refresh_token_expires_in":86400
    }


   </pre>


    @option email the email
    @option password the password
    @option uuid the hardware UUID
    @option grant_type the grant type - default is password
    @option refresh_token_p option to send a refresh token - default is 0
} {
  
    set email [string trim $email]
    # --------------
    # Handle case where there are spaces in email
    # --------------
    if {[llength $email] > 0} {
	set email [string trim [lindex $email 0]]
    }
    set user_id [cc_lookup_email_user $email]
    if [empty_string_p $user_id]  {
	ctrl::oauth::return_error -error_code "invalid_client" -error_desc "Invalid user name or password '$email'"
    }
    acs_user::get -user_id $user_id -array user
    if [empty_string_p $user_id] {
	ctrl::oauth::return_error -error_code "invalid_client" -error_desc "Invalid user name or password"
    }

    set authority_id [auth::authority::local]
    set package_id [ad_conn package_id]


    set failed_p [catch  {
	array set result [auth::authentication::Authenticate  -username $user(username)  -authority_id $authority_id  -password $password]
 
    } errmsg]

    if {($failed_p) || (![string eq $result(auth_status) "ok"])}  {
	ns_log error "auth::authenticate: error invoking authentication driver for authority_id = $authority_id: $errmsg"
	ctrl::oauth::return_error -error_code "invalid_client" -error_desc "Invalid user name or password"
    }

    set session_id [sec_allocate_session]

    set access_token [ctrl::oauth::generate_access_token -user_id $user_id -session_id $session_id -email $email -uuid $uuid]
    sec_update_user_session_info $user_id

   
    if {$refresh_token_p} {
	    # Generate Refresh Token. It expires in 1 day
	    set refresh_token_duration 86400
	    set refresh_token ""

	    # The the JWT Setup data
        set exists_p [ctrl::restful::jwt::get_setup -package_id $package_id -column_array "setup_info"]

        if {$exists_p} {    
        	set field_list [list client_id jwt_type client_key public_key private_key \
        	                    jwt_alg iss sub aud]

        	foreach field $field_list {
        	    set $field $setup_info($field)
        	}

        	set iat [clock seconds]
        	set exp [expr {$iat + $refresh_token_duration }]

        	set sub "email:$email"
        	
        	set claims_list [ctrl::jwt::cjwt_registered_claims -iss $iss \
        	    -sub $sub \
        	    -aud $aud \
        	    -exp $exp \
        	    -iat $iat \
        	    -return_format "tcl_list"]


        	set claims_list [linsert $claims_list end "client_id" "$client_id"]
        	set claims_list [linsert $claims_list end "token_type" "refresh"]

        	set payload [ctrl::jwt::cjwt_generate_payload -claim_info_list $claims_list]

        	set root [get_server_root]
        	set refresh_token [ctrl::jwt::cjwt_generate_token -alg $jwt_alg \
        	    -key_file "${root}/${private_key}" \
        	    -secret $client_key \
        	    -payload $payload] 
        }
	}

    # ---------------------------------------------------------
    # Build valid response by to client 
    # ---------------------------------------------------------

    if {$refresh_token_p} {
    	    set json_return [ctrl::json::construct_record [list \
			                    [list access_token $access_token t] \
			                    [list user_id $user_id t] \
								[list token_type bearer t] \
			                    [list expires_in [ctrl::oauth::session_timeout] t] \
			                    [list refresh_token $refresh_token t] \
			                    [list refresh_token_type bearer t] \
			                    [list refresh_token_expires_in $refresh_token_duration  t] \
			                ]]
    } else {
	    set json_return [ctrl::json::construct_record [list \
		                    [list access_token $access_token t] \
		                    [list user_id $user_id t] \
							[list token_type bearer t] \
		                    [list expires_in [ctrl::oauth::session_timeout] t] \
		                ]]
    }


    set headers [ad_conn outputheaders]

    ns_set update $headers "Cache-Control" "no-store"
    ns_set update $headers "Pragma" "no-cache"
    ns_set update $headers "Content-Type" "application/json;charset=UTF-8"
    
    # Set cookie for websites to pull information
    ad_set_cookie authorization_str "Bearer $access_token"

    doc_return 200 application/json "{$json_return}" 
    return

    # ---------------------------------------------------------
    # Return results 
    # --------------------------------------------------------
    return $access_token
}

ad_proc -private ctrl::oauth::session_timeout {} {
    Returns the access token timeout
} {

    return [sec_session_timeout]
}

ad_proc -private ctrl::oauth::generate_access_token {
    -user_id:required
    -session_id:required
    {-email ""}
    {-uuid ""}
    {-duration ""}
} {
    Generates the OAuth access token 
    
    @option user_id the user_id
    @option session_id the session_id
} {
    

    set secret ""
    set token_id ""
    # 2 = secure , 1 normal
    set login_level 2
    set value "$session_id,$user_id,$login_level,$email,$uuid"
    if {[exists_and_not_null duration]} {
        set max_age $duration 
    } else {
        set max_age [ctrl::oauth::session_timeout]
    }

    set cookie_value [ad_sign -secret $secret -token_id $token_id -max_age $max_age $value]
    set data [ns_urlencode [list $value $cookie_value]]
    return $data
}

ad_proc -public ctrl::oauth::check_auth_header {
    {-column_array user_info}
} {
    Check the header for Authorization. Returns 1 and populates the user_info if valid, otherwise
    return appropriate http response. 
} {

    set header_set [ad_conn headers]
    set authorization_list [ns_set iget $header_set authorization]
    set auth_type [string tolower [lindex $authorization_list 0]]
    set access_token [lindex $authorization_list 1]

    if [empty_string_p $authorization_list] {
    	ctrl::oauth::return_error -error_code invalid_client  -error_desc "Access Denied. Authorization header is missing" -error_uri "" 
    	ad_script_abort
    }

    if {![string equal $auth_type "bearer"] || [empty_string_p $access_token]} {
	ctrl::oauth::return_error -error_code invalid_client  -error_desc "Access Denied. Bearer type or Authentication Token are missing" 
	ad_script_abort
    }

    upvar $column_array user_info
    if ![ctrl::oauth::validate_access_token -column_array user_info $access_token] {
        if {$user_info(token_expired_p)} {
            ctrl::oauth::return_error -error_code "invalid_token_expired" -error_desc "Access Denied. Authentication Token is expired" 
        } else { 
            ctrl::oauth::return_error -error_code invalid_client  -error_desc "Access Denied. Authentication Token is not valid" 
        }
	ad_script_abort
    }
    return 1
}

ad_proc -private ctrl::oauth::validate_access_token {
    {-column_array access_token_info}
    access_token
} {
    Return 1 if access token is valid and populates the column_array with valid access_token_info
           0 if access token is not valid

    @option user_id the user id
    @option session_id the sesion_id 
} {


    set package_id [ad_conn package_id]
    set auth_type [parameter::get -package_id $package_id -parameter auth_type]
    set auth_type [string tolower $auth_type]
    switch $auth_type {
        "oauth_token" {
            upvar $column_array access_token_info
            set access_token_info(token_expired_p) 0
            if { [token::exists -token_str $access_token] } {
                if { [token::isValid -token_str $access_token] } {
                    set access_token_info(user_id) [db_string get_user "" -default ""]
                    set access_token_info(token_str) $access_token
                    return 1
                } else {
                    # The token exists but its expired
                    set access_token_info(token_expired_p) 1
                }
            }
            
            return 0
        } 

        "oacs_user" {
            set access_token [ns_urldecode $access_token]
            upvar $column_array access_token_info
            lassign $access_token value signature

            set validation_result [ctrl::oauth::verify_signature $value $signature]
            lassign $validation_result hash_ok_p expiration_ok_p
            if { [expr {$hash_ok_p && $expiration_ok_p}] } {
                ns_log Debug "ad_get_signed_cookie: Verification of cookie OK"
                set value_list [split $value ","]
                util_unlist $value_list session_id user_id login_level email uuid
                
                set access_token_info(session_id) $session_id
                set access_token_info(user_id) $user_id 
                set access_token_info(login_level) $login_level
                set access_token_info(email) $email
                set access_token_info(uuid) $uuid
                set access_token_info(token_expired_p) 0
                return 1
            } elseif [expr {$hash_ok_p && !$expiration_ok_p}] {
                # Token hash is valid but its expired
                set access_token_info(token_expired_p) 1
                return 0
            } else {
                # Token is not valid
                set access_token_info(token_expired_p) 0
                return 0
            }
        }
        "jwt" {
            upvar $column_array access_token_info

            set access_token_info(token_expired_p) 0
            set valid_p [ctrl::oauth::jwt_validate -column_array access_token_info $access_token]
            if {$access_token_info(invalid_code) eq "EXP"} {
                set access_token_info(token_expired_p) 1
            }
            return $valid_p
        }
    }
}


ad_proc -private ctrl::oauth::conn_init {} {
   
    @option set whether to set connection
    @option field to get or set
    @option args if set is true then args is the value to set for
} {
    
    set verify_p [ctrl::oauth::check_auth_header] 

    global oAuthConn 
    set oAuthConn [ns_set create]

    foreach {var value} [array get user_info] {
	ns_set put $oAuthConn $var $value
    }

}


ad_proc -private ctrl::oauth::conn {
    field
} {
    @option field
} {
   global oAuthConn 
   return [ns_set iget $oAuthConn $field]
}


ad_proc -private ctrl::oauth::jwt_validate {
    {-column_array access_token_info}
    access_token
} {
    Validate the JWT passed to the web service
} {
    upvar $column_array access_token_info
    
    set access_token_info(invalid_code) ""

    # Get parameters
    set package_id [ad_conn package_id]
    set jwt_throttle_invalid_count [parameter::get -package_id $package_id -parameter jwt_throttle_invalid_count]
    set jwt_throttle_time [parameter::get -package_id $package_id -parameter jwt_throttle_time]
    set user_account_encoding [parameter::get -package_id $package_id -parameter user_account_encoding]
    set ctrl_auth_proc [parameter::get -package_id $package_id -parameter ctrl_auth_proc]
    set custom_auth_proc [parameter::get -package_id $package_id -parameter custom_auth_proc]

    set user_account_encoding [string tolower $user_account_encoding]

    set exists_p [ctrl::restful::jwt::get_setup -package_id $package_id -column_array "setup_info"]

    if {$exists_p} {

       set field_list [list client_id jwt_type client_key public_key]

        foreach field $field_list {
           set $field $setup_info($field)
        }
        switch $jwt_type {
            "shared_secret" {
                if { [catch {set jwtTokenObject [ctrl::jwt::cjwt_decode_token -jwt_token $access_token \
                                -secret $client_key]} fid] } {
                    return 0
                }
            }
            "public_private_key" {
                set root [get_server_root]
                
                if { [catch {set jwtTokenObject [ctrl::jwt::cjwt_decode_token -jwt_token $access_token \
                                -public_key_file "${root}/${public_key}"]} fid] } {
                    return 0
                }
            }
        }
        

        set claims_list [$jwtTokenObject set getClaimList]
        set payload [$jwtTokenObject set getPayload]
        set valid_p [$jwtTokenObject set isValid]
        set invalid_code [$jwtTokenObject set invalidCode]
        
        set client_id ""
        set cust_acc_token ""
        set sub ""

        # Check if client_id exists
        set client_id_pos [lsearch $claims_list "client_id"]
        if {$client_id_pos > -1} {
            # Get the value next to the client_id tag
            set client_id [lindex $claims_list [expr {$client_id_pos + 1}]]
        }

        set cust_acc_token_pos [lsearch $claims_list "cust_acc_token"]
        if {$cust_acc_token_pos > -1} {
            # Get the value next to the client_id tag
            set cust_acc_token [lindex $claims_list [expr {$cust_acc_token_pos + 1}]]
        }

        set sub_pos [lsearch $claims_list "sub"]
        if {$sub_pos > -1} {
            # Get the value next to the sub tag
            set sub [lindex $claims_list [expr {$sub_pos + 1}]]
        }

        set access_token_info(invalid_code) $invalid_code
        set access_token_info(client_id) $client_id
        set access_token_info(cust_acc_token) $cust_acc_token
        set access_token_info(claims_list) $claims_list

        if {$cust_acc_token ne ""} {
            if {[token::exists -package_id $package_id -token_str $cust_acc_token]} {
                if {![token::isValid -package_id $package_id -token_str $cust_acc_token]} {
                    set valid_p 0
                }
            }
        }

        # Check the failed attempts by the client_id and cust_acc_token
        if {$client_id ne "" && $cust_acc_token ne "" } {
            set variable_suffix "${package_id}_${client_id}_${cust_acc_token}"
            # If a block is set for the client_id and cust_acc_token then dont return access no matter the result
            set block_p ""
            if {[ns_cache_keys template_cache "block_${variable_suffix}"] ne ""} {
                set block_p [ns_cache_get template_cache "block_${variable_suffix}"]
            }
            if {$block_p eq 1} {
                return 0
            }

            if {!$valid_p} {
                set count ""
                if {[ns_cache_keys template_cache "failed_count_${variable_suffix}"] ne ""} {
                    set count [ns_cache_get template_cache "failed_count_${variable_suffix}"]
                }

                if {$count eq ""} {
                    set count 0
                }
                incr count
                ns_cache set template_cache "failed_count_${variable_suffix}" $count
                
                # When the count of failures is over the value set on the package parameters
                # Then block the client_id and cust_acc_token for the amount of time set in the parameters
                if {$count >= $jwt_throttle_invalid_count} {
                    # Set the block in the cache
                    ns_cache set template_cache "block_${variable_suffix}" 1

                    #Call a schedule proc to remove the block
                    set jwt_throttle_time_seconds [expr {$jwt_throttle_time * 60}]
                    ad_schedule_proc -once t $jwt_throttle_time_seconds ns_cache flush template_cache "block_${variable_suffix}" 

                    #Reset the count
                    ns_cache flush template_cache "failed_count_${variable_suffix}" 
                } 
            }
        } 


        # Get the user using the JWT
        set access_token_info(user_id) 0
        set access_token_info(token_str) ""

        if {$valid_p} {
            switch $user_account_encoding {
                "ctrl" {
                    set user_id [eval "$ctrl_auth_proc -sub_value $sub"]
                    set access_token_info(user_id) $user_id
                    set access_token_info(token_str) $access_token
                }
                "custom" {
                    set user_id [eval "$custom_auth_proc -jwt_payload $payload"]
                    set access_token_info(user_id) $user_id
                    set access_token_info(token_str) $access_token
                }
            }
        } 
        return $valid_p
       
   } else {
       return 0
   }
}

ad_proc -public ctrl::oauth::jwt_check_oacs_fields {
    {-sub_value ""}
} {
   
    @sub_value the sub value in the JWT in format \{id_type\}:\{id\} with id_type being email
    @return the user_id of the email
} {
    
    set sub_value_parts [split $sub_value ":"]
    set id_type [lindex $sub_value_parts 0]
    set value [lindex $sub_value_parts 1]

    switch $id_type {
        "email" {
            set user_id [db_string get_by_email "" -default ""]      
        }
        "username" {
            set user_id [acs_user::get_by_username -username $value]        
        }
        "screen_name" {
            set user_id [acs_user::get_user_id_by_screen_name -screen_name $value]        
        }
        default {
            return 0
        }
    }
    
    if {$user_id eq ""} {
        set user_id 0
    }
    return $user_id
}


ad_proc -public ctrl::oauth::verify_signature {
    {-secret ""}
    value 
    signature
} {
    Procedure that Verifies a digital signature. Based on __ad_verify_signature procedure, but customized to know if the failure is due to expiration
    Returns a list with the hash validation and the expiration validation. Both are necesary for a token to be valid
} {
    lassign $signature token_id expire_time hash

    if { $secret eq "" } {
        if { $token_id eq "" } {
            ns_log Debug "ctrl::oauth::verify_signature: Neither secret, nor token_id supplied"
            return 0
        } elseif {![string is integer -strict $token_id]} {
            ns_log Warning "ctrl::oauth::verify_signature: token_id <$token_id> is not an integer"
            return 0
        }
        set secret_token [sec_get_token $token_id]

    } else {
        set secret_token $secret
    }

    ns_log Debug "ctrl::oauth::verify_signature: Getting token_id $token_id, value $secret_token ; "
    ns_log Debug "ctrl::oauth::verify_signature: Expire_Time is $expire_time (compare to [ns_time]), hash is $hash"

    # validate cookie: verify hash and expire_time
    set computed_hash [ns_sha1 "$value$token_id$expire_time$secret_token"]

    # Need to verify both hash and expiration
    set hash_ok_p 0
    set expiration_ok_p 0

    if {$computed_hash eq $hash} {
        ns_log Debug "ctrl::oauth::verify_signature: Hash matches - Hash check OK"
        set hash_ok_p 1
    } else {
        # check to see if IE is lame (and buggy!) and is expanding \n to \r\n
        # See: http://rhea.redhat.com/bboard-archive/webdb/000bfF.html
        set value [string map [list \r ""] $value]
        set org_computed_hash $computed_hash
        set computed_hash [ns_sha1 "$value$token_id$expire_time$secret_token"]

        if {$computed_hash eq $hash} {
            ns_log Debug "ctrl::oauth::verify_signature: Hash matches after correcting for IE bug - Hash check OK"
            set hash_ok_p 1
        } else {
            ns_log Debug "ctrl::oauth::verify_signature: Hash ($hash) doesn't match what we expected ($org_computed_hash) - Hash check FAILED"
        }
    }

    if { $expire_time == 0 } {
        ns_log Debug "ctrl::oauth::verify_signature: No expiration time - Expiration OK"
        set expiration_ok_p 1
    } elseif { $expire_time > [ns_time] } {
        ns_log Debug "ctrl::oauth::verify_signature: Expiration time ($expire_time) greater than current time ([ns_time]) - Expiration check OK"
        set expiration_ok_p 1
    } else {
        ns_log Debug "ctrl::oauth::verify_signature: Expiration time ($expire_time) less than or equal to current time ([ns_time]) - Expiration check FAILED"
    }

    # Return validation result
    return [list $hash_ok_p $expiration_ok_p]
}




ad_proc -public ctrl::oauth::refresh_token {
    -refresh_token:required
} {
    Recieves a refresh token and if its valid, it returns a new access token
  
} {
  
    set refresh_token [lindex $refresh_token 0]
    set refresh_token [string trim $refresh_token]
    
    set valid_p [ctrl::oauth::jwt_validate -column_array access_token_info $refresh_token]
    set user_id $access_token_info(user_id)
    set claims_list $access_token_info(claims_list)

    set search_claims [list "token_type" "sub"]

    foreach claim $search_claims {
    	set "${claim}_pos" [lsearch $claims_list $claim]
    	if {[set ${claim}_pos] > -1} {
    	    # Get the value next to the sub tag
    	    set $claim [lindex $claims_list [expr {[set "${claim}_pos"] + 1}]]
    	} else {
    		set ${claim} ""
    	}
    }

    set sub_value_parts [split $sub ":"]
    set id_type [lindex $sub_value_parts 0]
    set email [lindex $sub_value_parts 1]

    if {$id_type ne "email"} {
    	set valid_p 0
    }

    if {$token_type ne "refresh"} {
    	set valid_p 0
    }

    if { $valid_p } {
		set session_id [sec_allocate_session]        
        
        set access_token [ctrl::oauth::generate_access_token -user_id $user_id -session_id $session_id -email $email -uuid ""]
        sec_update_user_session_info $user_id
    } elseif {$access_token_info(invalid_code) eq "EXP"} {
        # Token hash is valid but its expired
        ctrl::oauth::return_error -error_code "invalid_token_expired" -error_desc "Refresh Token has Expired" 
    } else {
        # Token is not valid
        ctrl::oauth::return_error -error_code invalid_client  -error_desc "Refresh Token is not Valid" 
    }


    # ---------------------------------------------------------
    # Build valid response by to client 
    # ---------------------------------------------------------
    set json_return [ctrl::json::construct_record [list \
                        [list access_token $access_token t] \
                        [list user_id $user_id t] \
                        [list token_type bearer t] \
                        [list expires_in [ctrl::oauth::session_timeout] t] \
                    ]]

    set headers [ad_conn outputheaders]

    ns_set update $headers "Cache-Control" "no-store"
    ns_set update $headers "Pragma" "no-cache"
    ns_set update $headers "Content-Type" "application/json;charset=UTF-8"
    
    # Set cookie for websites to pull information
    ad_set_cookie authorization_str "Bearer $access_token"

    set json_return [ctrl::restful::api_return -response_code "ok" -response_message "" -response_body "$json_return" -response_body_value_p f]

    doc_return 200 application/json "$json_return" 
}

ad_proc -public ctrl::oauth::login  {
    {-email:required}
    {-password:required}
} {
    Generates an Oauth token for the user passed in the parameters

    @param  email Email of the user to generate the token for.
    @param  password Password of the user to authenticate
        
    @return oauth_token
} {

    set package_id [ad_conn package_id]

    set user_id [db_string get_by_email "" -default 0]  

    if {$user_id eq 0} {
        set valid_p 0
    } else {
        set valid_p [ad_check_password $user_id $password]
    }

    if {$valid_p} {
        set token_id [db_nextval "shib_login_oauth_tokens_seq"]
        set oauth_token [ad_generate_random_string 100]

        set system_time [clock seconds]
        # The expiration date is in 24 hours
        set valid_until_date_seconds [expr {$system_time+24*60*60}]
        set valid_until_date [clock format $valid_until_date_seconds -format {%m/%d/%Y %H:%M:%S}]

        token::new -token_id $token_id \
            -token_str $oauth_token \
            -token_label "OAuth for $email" \
            -enable_p "t" \
            -valid_until $valid_until_date \
            -for_user_id $user_id \
            -package_id $package_id

        set response_body "$oauth_token"

        set return_data_json [ctrl::restful::api_return -response_code "Ok" -response_message "User authentication valid" -response_body "$response_body" -response_body_value_p t]
        doc_return 200 application/json $return_data_json
    } else {
        set return_data_json [ctrl::restful::api_return -response_code "Error" -response_message "User authentication failed" -response_body ""]
        doc_return 401 application/json $return_data_json
    }
}