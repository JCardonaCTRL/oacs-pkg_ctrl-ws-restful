ad_library {

    

}


namespace eval ctrlws {}



ad_proc -public ctrlws::util_httpsopen {
    {-method POST} 
    {-url:required}
    {-rqset}
    {-timeout 30}
    {-http_referer}
} {
    if { ![string match "https://*" $url] } {
        return -code error "Invalid url \"$url\":  _httpopen only supports HTTPS"
    }
    set url [split $url /]
    set hp [split [lindex $url 2] :]
    set host [lindex $hp 0]
    set port [lindex $hp 1]


    if { [string match $port ""] } {set port 443}
    set uri /[join [lrange $url 3 end] /]
    set fds [ns_openssl_sockopen -nonblock $host $port]
    set rfd [lindex $fds 0]
    set wfd [lindex $fds 1]

    if { [catch {
        _ns_https_puts $timeout $wfd "$method $uri HTTP/1.0\r"
        _ns_https_puts $timeout $wfd "Host: $host\r"
        if {$rqset ne ""} {
            for {set i 0} {$i < [ns_set size $rqset]} {incr i} {
                _ns_https_puts $timeout $wfd  "[ns_set key $rqset $i]: [ns_set value $rqset $i]\r"
            }
        } else {
            _ns_https_puts $timeout $wfd  "Accept: */*\r"
#            _ns_https_puts $timeout $wfd "Accept-Language:en-US,en\r"
            _ns_https_puts $timeout $wfd "User-Agent: Mozilla/1.01 \[en\] (Win95; I)\r"    
            _ns_https_puts $timeout $wfd "Referer: $http_referer \r"    
	}

    } errMsg] } {
        global errorInfo
        #close $wfd
        #close $rfd
        if { [info exists rpset] } {ns_set free $rpset}
        return -1
    }
    return [list $rfd $wfd ""]
}

ad_proc -public ctrlws::util_httpspost { 
    {-url:required} 
    {-timeout 30}
    {-depth 0}
    {-http_referer ""}
    {-json:boolean}
    {-method POST}
    {-formvars ""}
    {-column_array request_headers}
} {
    
    Returns the page content and sets the request_header 

} {

    upvar $column_array request_headers

    if { [catch {
	if {[incr depth] > 10} {
		return -code error "util_httpspost:  Recursive redirection:  $url"
	}

	set http [ctrlws::util_httpsopen -method $method -url $url -rqset "" -timeout $timeout -http_referer $http_referer]
	set rfd [lindex $http 0]
	set wfd [lindex $http 1]

	#headers necesary for a post and the form variables
	if $json_p  {
	    _ns_https_puts $timeout $wfd "Content-Type: application/json\r"
	} else {
	    _ns_https_puts $timeout $wfd "Content-Type: application/x-www-form-urlencoded; charset=utf-8\r"
	}

	_ns_https_puts $timeout $wfd "Content-Length: [string length $formvars]\r"
	_ns_https_puts $timeout $wfd "\r"
	_ns_https_puts $timeout $wfd "$formvars\r"
	flush $wfd
	close $wfd

	set rpset [ns_set new [_ns_https_gets $timeout $rfd]]
	while 1 {
	    set line [_ns_https_gets $timeout $rfd]
	    if { ![string length $line] } break
			ns_parseheader $rpset $line
	}

	set headers $rpset
	set response [ns_set name $headers]
	ns_set put $headers response_status $response
	set status [lindex $response 1]
	if {$status == 302} {
	    set location [ns_set iget $headers location]
	    if {$location ne ""} {
			    ns_set free $headers
			    close $rfd
		return [util_httpsget $location {}  $timeout $depth]
	    }
	}
	set length [ns_set iget $headers content-length]

	if { "" eq $length } {set length -1}
	set err [catch {
	    while 1 {
		set buf [_ns_https_read $timeout $rfd $length]
				append page $buf
		if { "" eq $buf } break
		if {$length > 0} {
		    incr length -[string length $buf]
		    if {$length <= 0} break
		}
	    }
	} errMsg]

	array set request_headers [ns_set array $headers]

	ns_set free $headers
	close $rfd
	if {$err} {
		global errorInfo
		return -code error -errorinfo $errorInfo $errMsg
	}
    } errmsg ] } {
	return $errmsg
    }

    return $page



}