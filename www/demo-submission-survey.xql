<?xml version="1.0"?>
<queryset>

	<fullquery name="select_surveys">
		<querytext>
		select s.name label, s.survey_id value
		from   cs_surveys s
		inner join acs_objects o on (s.survey_id = o.object_id)
		where o.package_id in (select package_id 
			from apm_packages 
			where package_key = 'ctrl-survey-2' 
			and instance_name = 'Patient My GI Health Questionnaire')
		order by lower(s.name)
		</querytext>
	</fullquery>

	<fullquery name="select_sessions">
		<querytext>
			select session_id label, session_id value
			from cs_survey_sessions se 
			where se.for_user_id = :user_id
				and survey_id = :survey_id
		</querytext>
	</fullquery>

</queryset>
