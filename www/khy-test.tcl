set data  { 
    {
		"device_uuid"   : "23423423" ,
		"model_string"         : "iPhone 4s",
		"device_token"  : "4565b56626w264554n66546546" ,
		"system_version": "7.01" ,
		"language"      : "US_en"
    }
}



set result [ctrlws::util_httpspost -url "https://app.mygihealth.org/ws/mygi/v1/app/device" -json -formvars $data]

doc_return 200 text/plain "result -> $result"
