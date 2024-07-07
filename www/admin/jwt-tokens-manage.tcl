#/packages/ctrl-ws-restful/www/admin/jwt-tokens-manage 
ad_page_contract {
    @author: Juan Tapia
    @creation-date: 2020-08-04
    @cvs-id: $Id$
} {
}

##-------------------------
#  Initial Settings
##-------------------------
set user_id	    [ad_conn user_id]
set package_id	[ad_conn package_id]
set package_url [ad_conn package_url]


set enabled_options [list [list "Yes" "t"] [list "No" "f"]]

set jwt_type_options [list [list "Shared Secret" "shared_secret"] [list "Public/Private Key" "public_private_key"]]
set jwt_alg_list [ctrl::jwt::cjwt_get_algorithms]
set jwt_alg_options [list [list "-- Select --" ""]]
foreach jwt_alg $jwt_alg_list {
    lappend jwt_alg_options [list $jwt_alg $jwt_alg]
}

ad_form -name jwt_token_form -export {} -has_submit 1 -html {class "boostrap-form validate-before-leave"} -form {
    {client_id:text(text),optional			
        {label "Client ID"}
        {html {class "form-control input-sm" size 40 readonly readonly}}
    }
    {jwt_type:text(radio),optional          
        {label "<b>JWT Type</b>  <br>"}
        {html ""}
        {options $jwt_type_options}
    }
    {client_key:text(text),optional	
        {label "Client Key"}
        {html {class "form-control input-sm" size 64 readonly readonly}}
    }
    {public_key:text(text),optional    
        {label "Public Key"}
        {html {class "form-control input-sm"}}
    }
    {private_key:text(text),optional    
        {label "Private Key"}
        {html {class "form-control input-sm"}}
    }
    {jwt_alg:text(select),optional    
        {label "JWT Alg"}
        {html {class "form-control input-sm"}}
        {options $jwt_alg_options}
    }
    {token_expiration:text(text),optional    
        {label "Token Expiration"}
        {html {class "form-control input-sm"}}
    }

    {iss:text(text),optional    
        {label "Issuer"}
        {html {class "form-control input-sm"}}
    }
    {sub:text(text),optional    
        {label "Subject"}
        {html {class "form-control input-sm"}}
    }
    {aud:text(text),optional    
        {label "Audience"}
        {html {class "form-control input-sm"}}
    }
} -on_request {

    set exists_p [ctrl::restful::jwt::get_setup -package_id $package_id -column_array "setup_info"]

    if {$exists_p} {
        set field_list [list client_id jwt_type client_key public_key private_key \
                            jwt_alg token_expiration iss sub aud]

        foreach field $field_list {
            set $field $setup_info($field)
        }

    } else {
        # 40 characters random string
        set client_id [ad_generate_random_string 39]
        
        # 64 characters random string
        set client_key "[ad_generate_random_string 39][ad_generate_random_string 23]"

        set jwt_alg ""
        set jwt_type ""
    }
} -on_submit {
    set exists_p [ctrl::restful::jwt::get_setup -package_id $package_id -column_array "setup_info"]
    if {$exists_p} {
        ctrl::restful::jwt::edit_setup -package_id $package_id \
            -client_id $client_id \
            -jwt_type $jwt_type \
            -client_key $client_key \
            -public_key $public_key \
            -private_key $private_key \
            -jwt_alg $jwt_alg \
            -token_expiration $token_expiration \
            -iss $iss \
            -sub $sub \
            -aud $aud
    } else {
        ctrl::restful::jwt::new_setup -package_id $package_id \
            -client_id $client_id \
            -jwt_type $jwt_type \
            -client_key $client_key \
            -public_key $public_key \
            -private_key $private_key \
            -jwt_alg $jwt_alg \
            -token_expiration $token_expiration \
            -iss $iss \
            -sub $sub \
            -aud $aud
    }
} -after_submit {
    ad_returnredirect ""
}



template::head::add_javascript -src "https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min.js" -order 1
template::head::add_javascript -src "//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.2.0/js/bootstrap.min.js" -order 2
template::head::add_javascript -src //cdnjs.cloudflare.com/ajax/libs/datatables/1.10.19/js/jquery.dataTables.min.js -order 5a
template::head::add_javascript -src //cdnjs.cloudflare.com/ajax/libs/datatables/1.10.19/js/dataTables.bootstrap.min.js -order 5b
template::head::add_javascript -src //cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.19.1/jquery.validate.min.js -order 6

template::head::add_css -href //cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.2.0/css/bootstrap-grid.min.css -media all -order 1
