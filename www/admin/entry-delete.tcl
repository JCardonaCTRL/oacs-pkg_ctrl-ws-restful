ad_page_contract {

    
    Delete the webservice entry

    @param request_url
    @param method

} {
    request_url
    method
}


ctrl::restful::removeSpecEntry -package_id [ad_conn package_id] -url $request_url -method $method

ad_returnredirect index