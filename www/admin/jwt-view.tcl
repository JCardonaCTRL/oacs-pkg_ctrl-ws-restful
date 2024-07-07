#/packages/ctrl-ws-restful/www/admin/jwt-view 
ad_page_contract {
    @author: Juan Tapia
    @creation-date: 2020-08-04
    @cvs-id: $Id$
} {
	{token_id}
}

set jwt_token [db_string select_token ""]

set package_id [ad_conn package_id]

set exists_p [ctrl::restful::jwt::get_setup -package_id $package_id -column_array "setup_info"]
if {$exists_p} {
    set field_list [list client_id jwt_type client_key public_key private_key \
                        jwt_alg token_expiration iss sub aud]

    foreach field $field_list {
        set $field $setup_info($field)
    }

    set root [get_server_root]
    set jwtTokenObject [ctrl::jwt::cjwt_decode_token -jwt_token $jwt_token \
    	-public_key_file "${root}/${public_key}" \
    	-secret $client_key]

    set header_json [$jwtTokenObject set getHeader]
    set payload [$jwtTokenObject set getPayload]
    set signature [$jwtTokenObject set getSignature]
    set valid_p [$jwtTokenObject set isValid]
    set invalid_code [$jwtTokenObject set invalidCode]

    set header_json [ util::json::indent $header_json]
    set payload [ util::json::indent $payload]


    if {$valid_p} {
    	set valid_message "Yes"
    } else {
    	set valid_message "No ($invalid_code)"
    }

}