ad_page_contract {
	Page to validate the symptom unique constraint
} {
	symptom
}

set unique_p [db_string select_unique_p {**SQL**} -default "true"]

doc_return 200 application/json "$unique_p"