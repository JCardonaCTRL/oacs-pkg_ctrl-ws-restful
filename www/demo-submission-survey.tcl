# packages/ctrl-ws-restful/www/demo-submission-survey.tcl
ad_page_contract {
    Survey web services demo JSON geneartion

    @author: Elias (elias@viaro.net)
    @creation-date: 08-01-2014
} {
    {login:trim ""}
    {password ""}
    {action:trim ""}
    {survey_id:integer ""}
    {session_id:integer ""}
}

set message ""
set action_options [list \
                        [list "Add" "add"] \
                        [list "Update" "update"] \
                   ]
if {[empty_string_p $action]} {
    set action [lindex [lindex $action_options 0] 1]
}
set survey_id_options [db_list_of_lists select_surveys ""]

if {[empty_string_p $survey_id] && [llength $survey_id_options] > 0} {
    set survey_id [lindex [lindex $survey_id_options 0] 1]
}
set result_code ""
set session_id_options [list]
if {![empty_string_p $login] && ![empty_string_p $password] && [string eq $action "update"] && [exists_and_not_null survey_id]} {
    set failed_p [catch  {
        set authority_id [auth::authority::local]
        set user_id [cc_lookup_email_user $login]
        acs_user::get -user_id $user_id -array user
         array set result [auth::authentication::Authenticate  -username $user(username)  -authority_id $authority_id  -password $password]
        if {$result(auth_status) eq "ok"} {
            set dummy $result(account_status)
        }
    } errmsg]
    if {($failed_p) || (![string eq $result(auth_status) "ok"])} {
        set message "Invalid Login, please check the credentials!"
    } else {
        set valid_subject_p [aegis::participant_login::get_subject_id_by_user_id \
                    -user_id $user_id -column_array subject_info]
        if {$valid_subject_p} {
            set subject_id $subject_info(subject_id)
            set result_code 0
            set session_id_options [db_list_of_lists select_sessions {**SQL**}]
            if {[empty_string_p $session_id] && [llength $session_id_options] > 0} {
                set session_id [lindex [lindex $session_id_options 0] 1]
            } 
        } 
    }
} elseif {[string eq $action "add"] && [exists_and_not_null survey_id]} {
    set result_code 0
}

ad_form -name svy -form {
     {action:text(select) {label "Action"} {options $action_options}}      
     {login:text(text) {label "Login"}}
     {password:text(password) {label "Password"} }
     {survey_id:text(select) {label "Survey"} {options $survey_id_options}}      
     {session_id:text(select),optional {label "Session"} {options $session_id_options}}  
     {page_error_message:text(hidden),optional {label Error}} 
     {ok_btn:text(submit),optional {label OK}}     
} -validate {
} -on_request {
     set login $login
     set password $password
     set action $action
     set survey_id $survey_id
     set session_id $session_id
} -on_submit {
} -after_submit {
     ad_returnredirect "demo-submission-survey?[export_url_vars login password action survey_id session_id]"
}

set forminfo ""
if {$result_code == 0} {
    switch $action {
        "update" {
            set forminfo [ctrl::restful::survey::json_session_data -session_id $session_id -action $action -survey_id $survey_id]
        }
        "add" {
            set forminfo [ctrl::restful::survey::json_session_data -action $action -survey_id $survey_id]
        }
    }
}

