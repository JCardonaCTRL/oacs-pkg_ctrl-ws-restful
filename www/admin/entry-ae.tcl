ad_page_contract {

    Add/Edit Entry of webservice

    @author KH
    @cvs-id $Id$
    @creation-date 2014-05-06

} {
    request_url:optional
    method:optional
}


set option_list [list [list "(Select One ...)" ""] [list Post post] [list Put put] [list Get get] [list Delete delete]]

ad_form -name entry_fm -form {
    {url:text(text)  {label "URL:"}}
    {method:text(select) {label Method} {options $option_list}}
    {ws_name:text(text) {label Name} {label "Name"} {html {size 80}}}
    {private_param_list:text(text),optional {label "Hide these parameters from UI"} {html {size 100}}}
    {procedure:text(text) {label "procedure"} {html {size 80}}}
    {oauth_p:text(radio) {label "Requires OAuth Authenication"} {options {{Yes t} {No n}}}}
    {log_p:text(radio) {label "Logs the web service calls"} {options {{No n}}}}
    {self_handle_error_p:text(radio) {label "Procedure self handles the errors"} {options {{Yes t} {No f}}}}
    {document:text(textarea) {label "Document"} {html {cols 80 rows 5}}}
} -on_request {
    set self_handle_error_p "f"

    if {[info exists request_url] && [info exists method]}  {
	set restful_info_list [ctrl::restful::getSpecEntry -package_id [ad_conn package_id] -url $request_url -method $method]

	foreach {name value} $restful_info_list {
	    set $name $value
	}
    }


} -validate {
    {procedure {![empty_string_p [nsv_get api_proc_doc $procedure]]} {Procedure name does not exist}}
} -on_submit {


    set spec_info [list url $url method $method ws_name $ws_name procedure $procedure document $document private_param_list $private_param_list oauth_p $oauth_p log_p $log_p self_handle_error_p $self_handle_error_p]
    ctrl::restful::addSpecEntry -package_id [ad_conn package_id] -spec_info $spec_info


    ad_returnredirect .
    ad_script_abort

}
