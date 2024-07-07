#/packages/ctrl-digital-signs/www/admin/events-list-ae.tcl 
ad_page_contract {
    @author: Juan Tapia
    @creation-date: 2019-05-08
    @cvs-id: $Id$
} {
}

##-------------------------
#  Initial Settings
##-------------------------
set user_id	    [ad_conn user_id]
set package_id	[ad_conn package_id]
set package_url [ad_conn package_url]

set auth_type [parameter::get -package_id $package_id -parameter auth_type]
set auth_type [string tolower $auth_type]

set enabled_options [list [list "Yes" "t"] [list "No" "f"]]
set field_options [list [list "-- Select One --" ""] [list "Email" "email"] [list "Username" "username"]]

if {$auth_type eq "jwt"} {
    set widget_type "select"
} else {
    set widget_type "hidden"
}

ad_form -name oauth_token_form -export {} -has_submit 1 -html {class "boostrap-form validate-before-leave"} -form {
    {token_id:key(shib_login_oauth_tokens_seq)}
    {token_str:text(text),optional			
        {label "Token String"}
        {html {class "form-control input-sm" size 100 readonly readonly}}
    }
    {token_label:text(text),optional          
        {label "Token Label"}
        {html {class "form-control input-sm" size 100 required required}}
    }
    {enable_p:text(radio),optional	
        {label "<b>Is Enabled?</b>  <br>"}
        {html ""}
        {options $enabled_options}
    }
    {valid_until:text(text),optional   
        {label "Valid Until"}
        {html {class "form-control input-sm"}}
    }
    {for_user_id:text(text),optional   
        {label "For User ID"}
        {html {class "form-control input-sm" type "number"}}
    } 
    {user_field:text($widget_type),optional   
        {label "User Field to Store in Token"}
        {html {class "form-select input-sm" required required}}
        {options $field_options}
    } 
} -new_data {
    set valid_until [string map {"," ""} $valid_until]
    token::new -token_id $token_id \
        -token_str $token_str \
        -token_label $token_label \
        -enable_p $enable_p \
        -valid_until $valid_until \
        -for_user_id $for_user_id \
        -user_field $user_field \
        -package_id $package_id \
   
} -new_request {
     set token_str [ad_generate_random_string 100]
     set enable_p "t"
}

