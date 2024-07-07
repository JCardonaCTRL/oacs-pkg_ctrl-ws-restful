ad_page_contract {

    Read the package ws file to load


}

set package_id [ad_conn package_id]

set file_loc [ctrl::restful::get_ws_file $package_id]

set file_exists_p [file exists $file_loc]


if {$file_exists_p} {
    ad_form -name fm_load -form {
	{reload_type:text(radio) {label "Reload Options:"} {options {{"Clear and Load" cl} {"Load only" l}}}}
    } -cancel_url index -on_submit {

#	set file_id [open $file_loc r]
#	set spec_file_text [read $file_id]
#	close $file_id

	if [string equal $reload_type "cl"] {
	    ctrl::restful::setSpec_internal -package_id $package_id -spec_info_list [list]
	} 
	ctrl::restful::load_file $package_id
#	ctrl::restful::setSpec_internal -package_id $package_id -spec_info_list $spec_file_text
    } -after_submit {
	set message "Reload WS Sucessfully"
	ad_returnredirect index?[export_url_vars message]
	ad_script_abort
    }

} else {
    set message "File does not exist "
    ad_returnredirect index?[export_url_vars message]
    ad_script_abort
}