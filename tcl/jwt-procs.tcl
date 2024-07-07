# -*- tab-width: 4 -*-											ex:sw=4:ts=4:
ad_library {
	JWT Procs

	@author			juan.tapia@nexadevs.com
	@creation-date	08/06/2020
}

namespace eval ctrl::restful::jwt {}

ad_proc -public ctrl::restful::jwt::get_setup {
    {-package_id:required}
    {-column_array "setup_info"}
} {
    Get the JWT information
} {
    upvar $column_array row
    set exists_p [db_0or1row select "" -column_array row]
    return $exists_p
}


ad_proc -public ctrl::restful::jwt::new_setup {
	{-client_id:required}
	{-jwt_type:required}
	{-client_key ""}
	{-public_key ""}
	{-private_key ""} 
	{-jwt_alg:required}
	{-token_expiration:required}
	{-iss ""}
	{-sub ""}
	{-aud ""}
	{-package_id:required}
} {
	Add a new JWT Setup

	@param	client_id Random 40 characters unique to the package
	@param	jwt_type The type of jwt that will be used. shared_secret or public_private_key
	@param	client_key Random 60 characters string to serve as a shared_secret
	@param	public_key Path relative to the project to the .pem public key
	@param	private_key Path relative to the project to the .pem private key
	@param	jwt_alg Algorithm used to generate the JWT
	@param	token_expiration Expiration date of the JWT
	@param	iss Issuer
	@param	sub Subject
	@param	aud Audience
	@param	package_id Package ID
		
	@return	1
} {

	set failed_p 0
	db_transaction {
		db_dml insert ""
	} on_error {
        set failed_p 1
        db_abort_transaction
    }
    
    if $failed_p {
        ad_return_error "Error creating a new JWT Setup" "Error creating a new JWT Setup $errmsg"
        ad_script_abort
    }
	
	return 1
}

ad_proc -public ctrl::restful::jwt::edit_setup {
    {-package_id:required}
    -client_id
	-jwt_type
	-client_key
	-public_key
	-private_key 
	-jwt_alg
	-token_expiration
	-iss
	-sub
	-aud
} {

    Edit a JWT setup

    @param	client_id Random 40 characters unique to the package
	@param	jwt_type The type of jwt that will be used. shared_secret or public_private_key
	@param	client_key Random 60 characters string to serve as a shared_secret
	@param	public_key Path relative to the project to the .pem public key
	@param	private_key Path relative to the project to the .pem private key
	@param	jwt_alg Algorithm used to generate the JWT
	@param	token_expiration Expiration date of the JWT
	@param	iss Issuer
	@param	sub Subject
	@param	aud Audience
	@param	package_id Package ID
} {

    set init_list [list client_id jwt_type client_key public_key private_key \
    					jwt_alg token_expiration iss sub aud]
    set sql_update [list]
    foreach var $init_list {
        if [info exists $var] {
            lappend sql_update "$var = :$var"
        }
    }
    set sql_update [join $sql_update ,]

    set failed_p 0
    db_transaction {
        db_dml update ""
    } on_error {
        set failed_p 1
        db_abort_transaction
    }
    if $failed_p {
        ad_return_error "Error updating JWT Setup" "Error updating JWT Setup $errmsg"
        ad_script_abort
    }
}



ad_proc -public ctrl::restful::jwt::generate_token {
	{-package_id:required}
	{-user_id:required}
	{-field:required}
	{-field_type_label:required}
	{-token_expiration ""}
} {
	Generates Token using the jwt setup

	@param	package_id Package ID of the ctrl-ws-restful instance
	@param	user_id User ID to use for the token
	@param	field The field to put in the token. email or screen_name
	@param	field_type_label The label to put in the JWT to indicate the field to identify the user
	@param 	token_expiration The amount of seconds that the token will be valid

	@return	jwt_token
} {

	if { [catch {acs_user::get -user_id $user_id -array user_info} fid] } {
	    error "System failed to generate Token : User does not exists"
		ad_script_abort
	}

	switch $field {
		"email" {
			set field_value $user_info(email)
		}
		"username" {
			set field_value $user_info(username)
		}
		"screen_name" {
			set field_value $user_info(screen_name)
		}
		default {
			error "System failed to generate Token : field $field not supported"
			ad_script_abort
		}
	}

	# The the JWT Setup data
	set exists_p [ctrl::restful::jwt::get_setup -package_id $package_id -column_array "setup_info"]

	if {$exists_p} {
	    set field_list [list client_id jwt_type client_key public_key private_key \
	                        jwt_alg token_expiration iss aud]

	    foreach field $field_list {
	        set $field $setup_info($field)
	    }


	    if {$token_expiration eq ""} {
	    	set token_expiration $setup_info(token_expiration)
	    }

	    # Put the field from the parameters in the sub
	    set sub "${field_type_label}:${field_value}"

	    set iat [clock seconds]
	    set exp [expr {$iat + $token_expiration }]
	    set exp_date [clock format $exp -format {%m/%d/%Y %H:%M:%S}]
	    
	    set claims_list [ctrl::jwt::cjwt_registered_claims -iss $iss \
	        -sub $sub \
	        -aud $aud \
	        -exp $exp \
	        -iat $iat \
	        -return_format "tcl_list"]

	    # OAuth token
	    set token_str [ad_generate_random_string 100]

	    set claims_list [linsert $claims_list end "client_id" "$client_id"]
	    set claims_list [linsert $claims_list end "cust_acc_token" "$token_str"]

	    set payload [ctrl::jwt::cjwt_generate_payload -claim_info_list $claims_list]

	    set root [get_server_root]
	    set jwt_token [ctrl::jwt::cjwt_generate_token -alg $jwt_alg \
	        -key_file "${root}/${private_key}" \
	        -secret $client_key \
	        -payload $payload] 

	    token::new -token_str $token_str \
	        -token_label "JWT for $field_value" \
	        -enable_p "t" \
	        -valid_until $exp_date \
	        -for_user_id $user_id \
	        -package_id $package_id \
	        -jwt_token $jwt_token

	} else {
	    error "System failed to generate Token : JWT Setup not defined"
	    ad_script_abort
	}

	return $jwt_token
}


ad_proc -public ctrl::restful::jwt::login_default_type_email  {
	{-email:required}
	{-password:required}
} {
	Generates Token using the jwt setup

	@param	email Email of the user to generate the token for.
	@param	password Password of the user to authenticate
		
	@return	jwt_token
} {

	set package_id [ad_conn package_id]

	set user_id [ctrl::oauth::jwt_check_oacs_fields -sub_value "email:${email}"]
	if {$user_id eq 0} {
		set valid_p 0
	} else {
		set valid_p [ad_check_password $user_id $password]
	}

	if {$valid_p} {
		set jwt_token [ctrl::restful::jwt::generate_token -package_id $package_id \
			-user_id $user_id \
			-field "email" \
			-field_type_label "email"]

		set response_body "$jwt_token"

		set return_data_json [ctrl::restful::api_return -response_code "Ok" -response_message "User authentication valid" -response_body "$response_body" -response_body_value_p t]
		doc_return 200 application/json $return_data_json
	} else {
		set return_data_json [ctrl::restful::api_return -response_code "Error" -response_message "User authentication failed" -response_body ""]
        doc_return 401 application/json $return_data_json
	}
}