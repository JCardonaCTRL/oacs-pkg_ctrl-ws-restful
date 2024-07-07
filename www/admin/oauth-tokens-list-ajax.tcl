#bgpd-x/packages/ctrl-digital-signs/www/admin/oauth-tokens-list-ajax.tcl
ad_page_contract {
    Returns a json with the tokens

    @author:  Juan Carlos Tapia (juancarlos@viaro.net)
   @creation-date: 2019-05-23
} {
    {show_expired_tokens_p "t"}
}

set this_package_id [ad_conn package_id]
set auth_type [parameter::get -package_id $this_package_id -parameter auth_type]
set auth_type [string tolower $auth_type]

ctrl::jquery::datatable::query_param

set sql_order ""
set sql_order_list ""
foreach {col dir} $dt_info(sort_list) {
    set col [string map {"valid_until_pretty" "valid_until" "creation_date_pretty" "creation_date" "for_user" "for_user_id"} $col]
    lappend sql_order_list "$col $dir NULLS LAST"
}

if ![empty_string_p $sql_order_list] {
    set sql_order " order by [join $sql_order_list ","]"
}

set sql_search_filter ""

# ---------------------------------------------
# Add filter for the numbmer of rows to display
# ----------------------------------------------
array set dt_page_info $dt_info(page_attribute_list)
set sql_filter_row "where rn > $dt_page_info(start) and rn <= [expr $dt_page_info(start)+$dt_page_info(length)]"
# ---------------------------------------------
# Set search up
# ---------------------------------------------

set search_value ""
if ![empty_string_p $dt_info(search_global)] {
    array set search_arr $dt_info(search_global)
    set search_value $search_arr(value)
}

set field_list [list token_str token_label for_user_id jwt_token]
set sql_search_list  [list]
set sql_search_filter ""

foreach field_name $field_list {
    if ![empty_string_p $search_value] {
        lappend sql_search_list "lower(${field_name}::text) like '%'||lower(:search_value::text)||'%'"
    }
}

if {[llength $sql_search_list] > 0} {
    set sql_search_filter " and  ([join $sql_search_list " or "])"
}

set sql_where_filter ""
if {!$show_expired_tokens_p} {
    append sql_where_filter " and valid_until > now() "
}

# -----------------------------------------------
# Generate the records to return
# -----------------------------------------------

set data_json_list ""
set field_list [list token_str token_label creation_date_pretty valid_until_pretty status for_user jwt_token expired_p]

db_foreach selected_rows_to_display selected_rows_to_display {
    #set token_label [ctrl::oauth::check_auth_header]
    foreach fs_field $field_list {
        if [empty_string_p $fs_field] {
          continue
        }
        set _value_list [list]
        set new_value [set $fs_field]
        set new_value [regsub -all "\r" $new_value " "]

        lappend field_json [ctrl::json::construct_record  [list [list $fs_field $new_value]]]
    }


    set list_actions ""

    if {$enable_p} {
        append list_actions "<button id='$token_id' data-enable_p=f class='btn btn-danger statusBtn btn-xs' title='Disable Token'>Disable</button>&nbsp;&nbsp;"
    } else {
        append list_actions "<button id='$token_id' data-enable_p=t class='btn btn-success statusBtn btn-xs' title='Enable Token'>Enable</button>&nbsp;&nbsp;"
    }
    append list_actions "<button id='$token_id' class='btn btn-primary expireBtn btn-xs' title='Expire Token'>Expire</button>&nbsp;&nbsp;"

    if {$auth_type eq "jwt" && $jwt_token ne ""} {
        append list_actions "<button id='$token_id' class='btn btn-info jwtBtn btn-xs' title='View JWT'>View JWT</button>&nbsp;&nbsp;"
    }

    lappend field_json [ctrl::json::construct_record [list [list "actions" $list_actions]]]

    lappend data_json_list "{[join $field_json ","]}"
} 

set iFilteredTotal [db_string total_selected_rows ""]
set iTotal         [db_string total_rows ""]


set result [ctrl::json::construct_record [list [list draw $dt_page_info(draw) i] [list recordsTotal $iTotal] [list recordsFiltered $iFilteredTotal] [list data [join $data_json_list ","] a-joined]]]

doc_return 200 application/json "{$result}"
