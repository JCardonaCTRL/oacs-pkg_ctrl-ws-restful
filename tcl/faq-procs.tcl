ad_library {

    Procedures to return FAQ related data

}


namespace eval ctrl::restful::faq {}

ad_proc ctrl::restful::faq::get_invalid {
	{-message "Invalid FAQ ID"}	
} {
	set return_data_list [list]
	lappend return_data_list [list "result" 0 "t"]
	lappend return_data_list [list "message" $message "t"] 
	set return_data [ctrl::json::construct_record $return_data_list]
	return "{$return_data}"
}

ad_proc ctrl::restful::faq::get {
	faq_id
} {
	Return the FAQ structure with the faq id (optional) if this is not provided returs all FAQs
	<pre>
	/* Data submission */
	{
		"faq_id": "203033"
	}
	Empty 
	{
		"faq_id": ""
	}

	/* Returns if FAQ exists*/
	{
		/*
			The number of FAQs, if is received the faq id is 1 otherwise is a count of enabled FAQs
			-type integer
			-cardinality 1
		 */
	    "numberOfFaqs": "3",
        /*
	    	The result of the petition, is present when the faq id is invalid
	    	-type string
	    	-cardinality 0..1
	     */
	    "result": "Invalid FAQ ID",
	    /*
	    	The array of meta data for each FAQ, is present when the faq id is valid
	    	-type Array
	    	-cardinality 0..1
	     */
	    "faqArray": [
	        {
	        	/*
	        		The FAQ Identifier
	        		-type integer
	        		-cardinality 1
	        	 */
	            "faqId": "203033",
	            /*
	            	The FAQ name or description
	            	-type string
	            	-cardinality 1
	             */
	            "faqName": "1. Questions about the purpose of My GI Health",
	            /*
			    	The array of meta data for each Q&A corresponding to the current FAQ
			    	-type Array
			    	-cardinality 0..1
			     */
	            "qaArray": [
	                {
	                	/*
	                		The Q&A Identifier
	                		-type integer
	                		-cardinality 1
	                	 */
	                    "qaId": "204035",
	                    /*
	                    	The Q&A Title or Question, this supports HTML tags
	                    	-type string
	                    	-cardinality 1
	                     */
	                    "qaQuestion": "Why has my doctor asked me to use the My GI Health system?",
	                    /*
	                    	The Q&A Answer, this supports HTML tags
	                    	-type string
	                    	-cardinality 1z
	                     */
	                    "qaAnswer": "By answering the questions in My GI Health you will provide your gastrointestinal (GI) ..."
	                },
	                ...
	            ]
	        },
	        ...
        ]
	}
	</pre>
	@option faq_id Optional only when need an specific FAQ
} { 
	set return_data ""
	set return_data_list [list]
	set return_faq_list [list]
	set return_category_list [list]
	set package_id [faq::get_package_id]
	set locale "en_US"
	set faq_unique_id $faq_id

	# Retrieve the faqs before to start the JSON to evaluate its components 
	# like Q&A and categories to define the structure to use

	if {![string is integer $faq_id]} {
		doc_return 400 json/application [ctrl::restful::faq::get_invalid]
	}
	set faq_list [faq::get -faq_id $faq_id]
	set number_of_faqs [llength $faq_list]
	lappend return_data_list [list "numberOfFaqs" $number_of_faqs "t"]

	# Use only valid FAQ IDs
	if {$number_of_faqs < 1} {
		doc_return 404 json/application [ctrl::restful::faq::get_invalid \
				-message "Not Found FAQs registered in the system for the FAQ\
				ID received."]
	}

	foreach faq $faq_list {
		util_unlist $faq faq_id faq_name
		set faq_attribute_list [list \
			[list "faqId" "$faq_id" "t"] \
			[list "faqName" "$faq_name" "t"] \
		]
		set question_array ""

		# Retrieve the questions for the current faq of the loop
		set question_list [faq::question::get -faq_id $faq_id -category]
		foreach question $question_list {
			util_unlist $question entry_id faq_id question answer \
				sort_key category_id

			# Build the JSON structure for the questions using 
			# ctrl::json::construct_record proc 
			if {![empty_string_p $question_array]} {
				append question_array ", "
			}

			append question_array "[ctrl::json::construct_record \
				[list \
					[list \
						"" \
						[ctrl::json::construct_record \
							[list \
								[list \
									"qaId" \
									"$entry_id" \
									"t" \
								] \
								[list \
									"qaQuestion" \
									"$question" \
									"t" \
								] \
								[list \
									"qaAnswer" \
									"$answer" \
									"t" \
								] \
							] \
						] \
						"o" \
					] \
				] \
			]"
		}

		if {![empty_string_p $question_array]} {
			lappend faq_attribute_list [list \
				"qaArray" \
				"$question_array" \
				"a-joined" \
			]
		}

		lappend return_faq_list [list \
			"" \
			[ctrl::json::construct_record $faq_attribute_list] \
			"o" \
		]
	}
	if {[exists_and_not_null faq_unique_id]} {
		set return_data [ctrl::json::construct_record $return_faq_list]
		doc_return 200 json/application	"$return_data"
	}
	lappend return_data_list [list \
		"faqArray" \
		[ctrl::json::construct_record $return_faq_list] \
		"a-joined" \
	]

	set return_data [ctrl::json::construct_record $return_data_list]

	doc_return 200 json/application "{$return_data}"
}

ad_proc ctrl::restful::faq::get_all {} { 
	Return the FAQ structure, all FAQs
	<pre>
	/* Data submission */
	{
	}

	/* Returns if FAQ exists*/
	{
		/*
			The number of FAQs, if is received the faq id is 1 otherwise is a count of enabled FAQs
			-type integer
			-cardinality 1
		 */
	    "numberOfFaqs": "3",
	    /*
	    	The array of meta data for each FAQ
	    	-type Array
	    	-cardinality 0..1
	     */
	    "faqArray": [
	        {
	        	/*
	        		The FAQ Identifier
	        		-type integer
	        		-cardinality 1
	        	 */
	            "faqId": "203033",
	            /*
	            	The FAQ name or description
	            	-type string
	            	-cardinality 1
	             */
	            "faqName": "1. Questions about the purpose of My GI Health"
	        },
	        ...
        ]
	}
	</pre>
} {

	set return_data ""
	set return_data_list [list]
	set return_faq_list [list]

	set faq_list [faq::get]
	set number_of_faqs [llength $faq_list]
	lappend return_data_list [list "numberOfFaqs" $number_of_faqs "t"]

	if {$number_of_faqs < 1} {
		set return_data [ctrl::json::construct_record $return_data_list]
		return "{$return_data}"
	}

	foreach faq $faq_list {
		util_unlist $faq faq_id faq_name
		set faq_attribute_list [list \
			[list "faqId" "$faq_id" "t"] \
			[list "faqName" "$faq_name" "t"] \
		]
		lappend return_faq_list [list \
			"" \
			[ctrl::json::construct_record $faq_attribute_list] \
			"o" \
		]
	}

	lappend return_data_list [list \
		"faqArray" \
		[ctrl::json::construct_record $return_faq_list] \
		"a-joined" \
	]

	set return_data [ctrl::json::construct_record $return_data_list]
	doc_return 200 json/application "{$return_data}"
}

