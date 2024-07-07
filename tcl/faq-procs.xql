<?xml version="1.0"?>
<queryset>
	
	<fullquery name="ctrl::restful::faq::get.select_tree_ids">
		<querytext>
	     	select distinct c.tree_id
			 	from   categories c inner join category_tree_map ctm
			 		on  (ctm.tree_id = c.tree_id)
			 	where    ctm.object_id = :package_id
			 	order by c.tree_id
		</querytext>
	</fullquery>
	


</queryset>
