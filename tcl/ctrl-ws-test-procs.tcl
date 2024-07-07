ad_library {

    Test procedures for webservice 
    


}

namespace eval ctrl::restful::test {}


ad_proc -public ctrl::restful::test::get_id {
    id 
} {
    
    Test case for returning the ID

    @param id  Returns the ID

} {
    set user_id [ctrl::oauth::conn user_id]

    return "{[ctrl::json::construct_record [list [list id $id]]]}"

}

ad_proc -public ctrl::restful::test::update_id {
    -id 
    -var_name
    -var_value
} {
    
    Test case for returning the ID
    @param id  Returns the ID
    @param var_name the variable name
    @param var_value the variable value
} {
    return "id $id var_name $var_name var_value $var_value"
}

ad_proc -public ctrl::restful::test::delete_id {
    id 
} {
    
    Test case for returning the ID

    @param id  Returns the ID

} {
    return "deleted $id"
}


ad_proc -public ctrl::restful::test::put_id {
    id 
} {
    
    Test case for returning the ID

    @param id  Returns the ID

} {
    return "put $id"
}

ad_proc -public ctrl::restful::test::ws_1 {
} {
    Test web service 1

    Web service url              : app/v1/test-ws-1
    Requires OAuth Authenication : No 
} {
    set return_data_list [list \
                             [list "error" "" ""] \
                             [list "error_description" "" ""] \
                             [list "error_uri" "" ""] \
                             [list "ws" "test::ws_1" ""] \
                         ]
    set return_data [ctrl::json::construct_record $return_data_list]
    doc_return 200 text/plain "{$return_data}"
}

ad_proc -public ctrl::restful::test::ws_2 {
} {
    Test web service 2

    Web service url              : app/v1/test-ws-2
    Requires OAuth Authenication : Yes 
} {
    set error ""
    set error_description ""
    set continue_p 1

    ctrl::oauth::check_auth_header
    set user_id $user_info(user_id) 
    if {[empty_string_p $user_id] || $user_id == 0} {
        set error "error_user_id"
        set error_description "Error : Undefined user_id"
        set continue_p 1
    }

    set return_data_list [list \
                             [list "error" "$error" ""] \
                             [list "error_description" "$error_description" ""] \
                             [list "error_uri" "" ""] \
                             [list "ws" "test::ws_2" ""] \
                             [list "arg" "none" ""] \
                             [list "user_id" "$user_id" ""] \
                         ]
    set return_data [ctrl::json::construct_record $return_data_list]
    doc_return 200 text/plain "{$return_data}"
}



ad_proc -public ctrl::restful::test::authenication {
} {
    Procedure to that requires a token authenication and returns the user for the token
} {
    
    ctrl::oauth::check_auth_header
    set user_id $user_info(user_id)

    acs_user::get -user_id $user_id -array user_array
    set email $user_array(email)

    set response_body "Authenication Valid. User $user_id. Email: $email "
    set return_data_json [ctrl::restful::api_return -response_code "Ok" -response_message "Success" -response_body "$response_body" -response_body_value_p t]
    doc_return 200 application/json $return_data_json
}