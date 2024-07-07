set package_id [ad_conn package_id]
set auth_type [parameter::get -package_id $package_id -parameter auth_type]
set auth_type [string tolower $auth_type]

set ajax_url "oauth-tokens-list-ajax"
set add_url "oauth-tokens-add"
set status_url "oauth-tokens-status-update"
set expire_url "oauth-tokens-expire"
set jwt_view_url "jwt-view"


## Current theme on digital sign manager /www/healthsciences
## relies on jquery and bootstrap 3.4
## datatable integration with bootstrap
## jquery validate

template::head::add_javascript -src "https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min.js" -order 1
template::head::add_javascript -src "//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.2.0/js/bootstrap.min.js" -order 2
template::head::add_javascript -src //cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js -order 5a
template::head::add_javascript -src //cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js -order 5b
template::head::add_javascript -src //cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.19.1/jquery.validate.min.js -order 6
template::head::add_javascript -src //cdn.jsdelivr.net/npm/@popperjs/core@2.11.2/dist/umd/popper.min.js -order 8
template::head::add_javascript -src //cdn.jsdelivr.net/gh/Eonasdan/tempus-dominus@master/dist/js/tempus-dominus.js -order 9

template::head::add_css -href //cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.2.0/css/bootstrap-grid.min.css -media all -order 1
template::head::add_css -href //cdnjs.cloudflare.com/ajax/libs/datatables/1.10.19/css/dataTables.bootstrap.min.css -order 2b
template::head::add_css -href //cdn.jsdelivr.net/gh/Eonasdan/tempus-dominus@master/dist/css/tempus-dominus.css -order 9

## CSP for this package

security::csp::require script-src cdn.jsdelivr.net
security::csp::require script-src cdn.datatables.net

security::csp::require style-src cdn.jsdelivr.net
security::csp::require style-src cdn.datatables.net
#security::csp::require script-src 'self'
