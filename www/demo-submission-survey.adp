<master>
@message@
<formtemplate id="svy">
	<table width="100%" cellpadding="10" cellspacing="2">
	    <tr>
	    <td>
	        <div class='cs_q' cs_name='action'>
	            <div class='cs_pt'><b>Action</b></div>
	            <div class='cs_acs_error'>
	                <div class="cs_input_error">
	                    <formerror id="action"></formerror>
	                </div>
	            </div>
	            <div class='cs_qt pain'>
	             	<formwidget id="action"> 
	            </div>
	        </div>
	    </td>
	    </tr>
	    
	    <tr>
	        <td>
	            <div class='cs_q' cs_name='login'>
	                <div class='cs_pt'><b>Login</b></div>
	                <div class='cs_acs_error'>
	                    <div class="cs_input_error">
	                        <formerror id="login"></formerror>
	                    </div>
	                </div>
	                <div class='cs_qt'>
	                    <formwidget id="login">
	                </div>
	            </div>
	        </td>
	    </tr>
	    
	    <tr>
	        <td>
	            <div class='cs_q' cs_name='password'>
	                <div class='cs_pt'><b>Password</b></div>
	                <div class='cs_acs_error'>
	                    <div class="cs_input_error">
	                        <formerror id="password"></formerror>
	                    </div>
	                </div>
	                <div class='cs_qt'>
	                    <formwidget id="password">
	                </div>
	            </div>
	        </td>
	    </tr>
	    <tr>
		    <td>
		        <div class='cs_q' cs_name='survey_id'>
		            <div class='cs_pt'><b>Survey</b></div>
		            <div class='cs_acs_error'>
		                <div class="cs_input_error">
		                    <formerror id="survey_id"></formerror>
		                </div>
		            </div>
		            <div class='cs_qt pain'>
		                <formwidget id="survey_id"> 
		            </div>
		        </div>
		    </td>
		</tr>
		<tr>
		    <td>
		        <div class='cs_q' cs_name='session_id'>
		            <div class='cs_pt'><b>Session</b></div>
		            <div class='cs_acs_error'>
		                <div class="cs_input_error">
		                    <formerror id="session_id"></formerror>
		                </div>
		            </div>
		            <div class='cs_qt pain'>
		                <formwidget id="session_id"> 
		            </div>
		        </div>
		    </td>
		</tr>
	    <tr>
	        <td colspan=3 align="center" style="border-top:1px solid #FFF;">
	            <formwidget id="ok_btn">
	        </td>
	    </tr>
	</table>

</formtemplate>

<p/>
<hr/>
<p/>

<fieldset><legend>Survey Submission</legend>
<table border=0>
<tr><td align=right valign=top>formInfo:</td><td><textarea rows="20" cols="80" name="formInfo" id="formInfo">@forminfo@</textarea></td></tr>
</table>
</fieldset>

<script type="text/javascript">
	function addAction () {
		$("div[cs_name=login]").hide('fast');
		$("div[cs_name=password]").hide('fast');
		$("div[cs_name=session_id]").hide('fast');
	}
	function updateAction () {
		$("div[cs_name=login]").show('fast');
		$("div[cs_name=password]").show('fast');
		$("div[cs_name=session_id]").show('fast');
	}
	$(document).ready(function() {
		$("#action").on('change', function(event) {
			var action = $("#action").val();
			if (action == 'add') {
				addAction();
			} else {
				updateAction();
			}
		});	
		$("#action").change();
	});
</script>
