ad_page_contract {

    Save the ws procedures for package


}


set package_id [ad_conn package_id]

set dir "[acs_package_root_dir "ctrl-ws-restful"]/lib/ws/"


if ![file exists $dir]  {
    file mkdir $dir
}


set file_loc [ctrl::restful::get_ws_file $package_id]

# -------------------
# If file does not exist 
# ------------------
set file_exists_p [file exists $file_loc]

set write_file_p 0

ad_form -name publish_form -form {
    {confirm_p:text(hidden),optional {label Hide} {value 5}}
} -cancel_label "Cancel" -cancel_url index -on_submit {
    set write_file_p 1
}



if {(!$file_exists_p) || ($write_file_p)} {

    set fail_p [catch {
	set file_id [open $file_loc w]
	puts $file_id [ctrl::restful::getSpec $package_id]
	close $file_id
    } errmsg]

    if {$fail_p == 0} {
	set message "The WS specs was written to $file_loc"
    } else {
	set message "Failed writing to ... $file_loc because ... $errmsg "
    }

    ad_returnredirect index?[export_url_vars message]
    ad_script_abort
}
