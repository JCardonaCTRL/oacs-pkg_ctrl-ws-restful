#/packages/ctrl-ws-restful/www/admin/generate-token
ad_page_contract {
    Generate a Token for the Current User

    @author:        Juan Tapia
    @creation-date: 2021-04-27
} {

}

set user_id [ad_conn user_id]

acs_user::get -user_id $user_id -array user_info

set user_id $user_info(user_id)
set first_names $user_info(first_names)
set last_name $user_info(last_name)
set email $user_info(email)

ad_form -name token_form -export {} -form {
} -on_request {
    set access_token ""
} -on_submit {

    set package_id [ad_conn package_id]
    set auth_type [parameter::get -package_id $package_id -parameter auth_type]
    set auth_type [string tolower $auth_type]
    switch $auth_type {
        "oacs_user" {
            set session_id [sec_allocate_session]
            set access_token [ctrl::oauth::generate_access_token -user_id $user_id -session_id $session_id -email $email -uuid ""]
        }
        "oauth_token" {
            set token_id [db_nextval "shib_login_oauth_tokens_seq"]
            set access_token [ad_generate_random_string 100]

            set system_time [clock seconds]
            # The expiration date is in 24 hours
            set valid_until_date_seconds [expr {$system_time+24*60*60}]
            set valid_until_date [clock format $valid_until_date_seconds -format {%m/%d/%Y %H:%M:%S}]

            token::new -token_id $token_id \
                -token_str $access_token \
                -token_label "OAuth for $email" \
                -enable_p "t" \
                -valid_until $valid_until_date \
                -for_user_id $user_id \
                -package_id $package_id
        } 
        "jwt" {
            set access_token [ctrl::restful::jwt::generate_token -package_id $package_id \
                -user_id $user_id \
                -field "email" \
                -field_type_label "email"]
        }
    }

}