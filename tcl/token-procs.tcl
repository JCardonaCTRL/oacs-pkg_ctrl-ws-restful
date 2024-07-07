ad_library  {

    Procedures to handle Oauth Tokens 


    @author JCT
    @cvs-id $Id$
    @creation-date  2019-08-19

}

namespace eval token {}

ad_proc token::request {
    {-package_id ""}
    {-user_id ""}
    {-duration "30"}
} {
    Creates a token
} {
    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }

    if {$user_id eq ""} {
        set user_id [ad_conn user_id]
    }

    set token_str [ad_generate_random_string 100]
    set enable_p "t"
    db_dml insert ""
}

ad_proc token::new { 
    {-token_id ""}
    {-token_str ""}
    {-token_label}
    {-valid_until ""}
    {-enable_p "t"}
    {-for_user_id ""}
    {-user_field "email"}
    {-package_id ""}
    {-jwt_token "" }
} {
    Procedure to add a new token
} {

    set failed_p 0
    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }

    if {$token_id eq ""} {
        set token_id [db_nextval "shib_login_oauth_tokens_seq"]
    }

    set auth_type [parameter::get -package_id $package_id -parameter auth_type]
    set auth_type [string tolower $auth_type]

    # Ticket 68470
    # Generate a JWT if the parameter of the package is set and no jwt_token was passed to this proc
    if {$auth_type eq "jwt" && $jwt_token eq ""} {

        # The the JWT Setup data
        set exists_p [ctrl::restful::jwt::get_setup -package_id $package_id -column_array "setup_info"]

        if {$exists_p} {

            set field_list [list client_id jwt_type client_key public_key private_key \
                                jwt_alg token_expiration iss sub aud]

            foreach field $field_list {
                set $field $setup_info($field)
            }

            set iat [clock seconds]

            if {$valid_until eq ""} {
                set exp [expr {$iat + $token_expiration }]
                set valid_until [clock format $exp -format {%m/%d/%Y %H:%M:%S}]
            } else {
                set exp [clock scan $valid_until -format {%m/%d/%Y %H:%M %p}]
            }

            if {$for_user_id ne ""} {
                if { [catch {acs_user::get -user_id $for_user_id -array user_info} fid] } {
                    error "System failed to generate Token : User does not exists"
                    ad_script_abort
                }

                set user_field_value $user_info($user_field)
                set sub "${user_field}:${user_field_value}"
            }
            
            set claims_list [ctrl::jwt::cjwt_registered_claims -iss $iss \
                -sub $sub \
                -aud $aud \
                -exp $exp \
                -iat $iat \
                -return_format "tcl_list"]



            set claims_list [linsert $claims_list end "cust_acc_token" "$token_str"]
            set claims_list [linsert $claims_list end "client_id" "$client_id"]

            set payload [ctrl::jwt::cjwt_generate_payload -claim_info_list $claims_list]
            set root [get_server_root]
            set jwt_token [ctrl::jwt::cjwt_generate_token -alg $jwt_alg \
                -key_file "${root}/${private_key}" \
                -secret $client_key \
                -payload $payload] 

        } else {
            error "System failed to add Token : JWT Setup not defined"
            ad_script_abort
        }
    } 

    db_transaction {
        db_dml insert ""
    } on_error {
        set failed_p 1
        db_abort_transaction
    }
    if $failed_p {
        error "System failed to add Token : $errmsg"
        ad_script_abort
    }
    return $token_id
}


ad_proc token::setStatus { 
    {-token_id}
    {-enable_p}
} {
    Procedure to set the status of a token
} {

    set failed_p 0
    db_transaction {
        db_dml update ""
    } on_error {
        set failed_p 1
        db_abort_transaction
    }
    if $failed_p {
        ad_return_error "System failed to update Token" "System failed to update Token : $errmsg"
        ad_script_abort
    }
    return 1
}


ad_proc token::expire { 
    {-token_id}
} {
    Procedure to expire a token by setting its validation date to now
} {

    set failed_p 0
    db_transaction {
        db_dml update ""
    } on_error {
        set failed_p 1
        db_abort_transaction
    }
    if $failed_p {
        ad_return_error "System failed to update Token" "System failed to update Token : $errmsg"
        ad_script_abort
    }
    return 1
}



ad_proc token::isValid { 
    {-package_id ""}
    {-token_str}
} {
    Procedure to check if a token is valid
} {

    set failed_p 0

    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }
    
    db_transaction {
        set valid_p [db_string get_token_p "" -default 0]
    } on_error {
        set failed_p 1
        db_abort_transaction
    }
    if $failed_p {
        ad_return_error "System failed check if token is valid" "System failed if token is valid : $errmsg"
        ad_script_abort
    }
    return $valid_p
}



ad_proc token::exists { 
    {-package_id ""}
    {-token_str}
} {
    Procedure to check if a token exists in the system, even if its expired
} {

    set failed_p 0

    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }
    
    db_transaction {
        set exists_p [db_string get_token_p "" -default 0]
    } on_error {
        set failed_p 1
        db_abort_transaction
    }
    if $failed_p {
        error "System failed check if token exists" "System failed if token exists : $errmsg"
    }
    return $exists_p
}

