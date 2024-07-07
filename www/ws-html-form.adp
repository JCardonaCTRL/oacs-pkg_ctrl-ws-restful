
<style>
div.restful_header {background-color:#b0c4de; padding-top:5px; padding-bottom:5px}
div.restful_body {background-color:#CEECF5; padding-top:10px; padding-bottom:5px}
div.restful_doc {background-color:#ECF6CE; padding-left:2cm; padding-top:10px; padding-bottom:5px}
div.restful_hide {display:none}
div.restful_show {display:inset}
span.require {color:red;}
</style>

<require api="jquery" version=2.1 />

<script langage="JavaScript" type="text/javascript" <if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>>


function getCookie(name) {
  var value = "; " + document.cookie;
  var parts = value.split("; " + name + "=");
  if (parts.length == 2) return parts.pop().split(";").shift();
}

function hideShow(clicked) {

   var ws_item = $(clicked).parent().parent();
   var ws_item_header = $(clicked).parent();
   var ws_item_body = ws_item.find(".restful_body");
   
   if (ws_item_body.hasClass("restful_hide")) {
         $(clicked).html("Hide Test");
         ws_item_body.removeClass("restful_hide");
         ws_item_body.addClass("restful_show");
   }  else {
         $(clicked).html("Test");
         ws_item_body.removeClass("restful_show");
         ws_item_body.addClass("restful_hide");
   }
}


function hideShowDoc(clicked) {

   var ws_item = $(clicked).parent().parent();
   var ws_item_header = $(clicked).parent();
   var ws_item_body = ws_item.find(".restful_doc");
   
   if (ws_item_body.hasClass("restful_hide")) {
         $(clicked).html("Hide Doc");
         ws_item_body.removeClass("restful_hide");
         ws_item_body.addClass("restful_show");
   }  else {
         $(clicked).html("Show Doc");
         ws_item_body.removeClass("restful_show");
         ws_item_body.addClass("restful_hide");
   }
}

function deleteConfirm(request_url,method) {
   var confirmDel = confirm("Confirm deletion of '"+request_url+"' webservice");
   var item_del = "entry-delete?request_url="+encodeURI(request_url)+"&method="+method;

   if (confirmDel) {
       document.location.href = item_del;
   }
};

function newObject (varName, varValue) {
    this.name = varName;
    this.value = varValue;
}


function formData (formItemArray) {
    for (var i = 0; i < formItemArray.length; i++) {
        eval ("this."+formItemArray[i].name+"= formItemArray["+i+"].value;");
    }
}

function submitForm(button,url,method) {

    // Get parent until class=restful_body
    var isConstant = true;
    var varname = "";
    var actionURL = "";

    // Retrieve the restful item parent selector corresponding to the current request
    var parentWSItem = $(button).closest(".restful_item");
    // ----------------------------------------------------
    // Process the URL information
    // ----------------------------------------------------
    if (parentWSItem !== undefined) {

        // Split the spected URL in sections to build the destination URL 
        // (replacing the URL parameters [:varName] with form values) 
        var urlArray = url.split("/");
        // A cycle is used to replace the URL parameters (:varName) with 
        // the form input values , whom have a matching name with the 
        // url parameters names
        for (var i = 0; i < urlArray.length; i++) {
            varName = urlArray[i];
            // The URL parameters are preceded with ":"
            if (urlArray[i].indexOf(":") == 0) {
                // Remove ":" from the parameter
                varName = urlArray[i].substr(1);
                // Get the form elements that can be used as URL parameters
                var foundSet = $(parentWSItem[0]).find("[data-ws_type=\"uri_var\"]");
                if (foundSet !== undefined) {
                    var input;
                    // Find the form input element who have a matiching name 
                    // with the current URL parameter
                    foundSet.each(function(i, e) {
                        if ($(e).is('input[name="' + varName + '"]')) {
                            input = e;
                            // break the .each iteration
                            return true;
                        };
                    });
                    if (input != undefined) {
                        // set the URL parameter value using the matched input's value
                        // since empty values are not allowed, 
                        // empty values are replaced using the parameter name 
                        // (:varName, the ":" character is included in the name)
                        if ($(input).val() === "") {
                            varName = ":" + varName;
                        } else {
                            varName = $(input).val();
                        }
                    }
                }
            }
            // Append the parameter value to the actionURL
            if (i == 0) {
                actionURL = "@post_loc;noquote@" + varName;
            } else {
                actionURL += "/" + varName;
            }
        }
        var formDataArray = new Array();

        // Process the Parameters that aren't included in the URL
        var formItemArr = $(parentWSItem[0]).find("[data-ws_type=\"form_var\"]");
        for (var i = 0; i < formItemArr.length; i++) {
            var inputName = $(formItemArr[i]).prop("name");
            var inputValue = $(formItemArr[i]).val();
            formDataArray[i] = new newObject(inputName, inputValue);
            //            formDataArr[i] = {inputName:inputValue};
        }
        var postData = new formData(formDataArray);
        // ----------------------------------------------------
        // Create a method 
        // ----------------------------------------------------
        var contentType = "application/x-www-form-urlencoded; charset=UTF-8";
        if (method.toUpperCase() === "PUT") {
            contentType = "application/json; charset=UTF-8";
            var postData = JSON.stringify(postData);
        }
        $("#resultDialog").dialog({
            title: " [ " + method + "] " + actionURL,
            width: 800
        });
        $.ajax({
            type: method,
            beforeSend: function(request) {
                var authorizationStr = getCookie("authorization_str");
                if ((authorizationStr != null) && (authorizationStr != "")) {
                    request.setRequestHeader("Authorization", authorizationStr);
                }
            },
            contentType: contentType,
            url: actionURL,
            error: function(xhr, status, error) {
                console.log("result --> ", xhr.status, " : " + xhr.responseText);
                displayResult(xhr.statusCode().status, xhr.responseText);
                //                      alert("error "+xhr);
            },
            success: function(xhr, status, error) {
                console.log("result --> ", xhr)
                displayResult(200, JSON.stringify(xhr));
                //                      alert("SUCCESS --> "+status+" : "+xhr.toString())
            },
            data: postData
        });
    }

}

function displayResult (status, returnMsg) {
   $("#resultDialog").dialog("open");
    $("#displayResultArea").val(" Return Code: "+status +" \n\n Body: \n\n"+returnMsg);
//    $("#divDisplay").html(" Return Code: "+status +" \n\n Body: \n\n"+returnMsg);

}
$(function () {
    $( "#resultDialog" ).dialog({autoOpen:false, buttons: [ { text: "Ok", click: function() { $( this ).dialog( "close" ); }}]});

    $(".request_delete_link").on('click', function(event) {
        event.preventDefault();
        
        var request_url = $(this).data("request_url");
        var method = $(this).data("method");

        var confirmDel = confirm("Confirm deletion of '"+request_url+"' webservice");
        var item_del = "entry-delete?request_url="+encodeURI(request_url)+"&method="+method;

        if (confirmDel) {
            document.location.href = item_del;
        }
    });

});
</script>

<if @message@ ne ""><blockquote><font color=red>@message;noquote@</font> </blockquote>
<br /></if>
<if @admin_p@ eq 1>
[<a href='entry-ae'> Add RESTFUL WS </a> | <a href="ws-write"> Save WS Spec </a> | <a href='ws-read'>Load WS Spec</a>
    <if @auth_type@ eq "oauth_token" or @auth_type@ eq "jwt"> | <a href='oauth-tokens-manage'>Manage OAuth Tokens</a> </if> 
    <if @auth_type@ eq "jwt" or @auth_type@ eq "oacs_user"> | <a href='jwt-tokens-manage'>JWT Tokens Setup</a> </if> 
    | <a href="generate-token">Generate Token for Current User</a>]
<br />
<br />
</if>

<multiple name="restful_list">
<div class="restful_item">
    <div class="restful_header"> [<a href='#' onClick="hideShow(this);">Test</a> | <a href='#' onClick="hideShowDoc(this);">Show Doc</a> <if @admin_p@ eq 1> | <a href="@restful_list.edit_url;noquote@">Edit</a> | <a href="#" class="request_delete_link" data-request_url="@restful_list.url@" data-method="@restful_list.method@">Delete</a> </if>] 
&nbsp;&nbsp;&nbsp;    <b> (@restful_list.method@) @restful_list.url@  </b>  <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <i> @restful_list.name@ </i>  - 
    @restful_list.summary_doc;noquote@
    </div>
    <div class="restful_doc restful_hide">
        @restful_list.document;noquote@ 
    </div>
    <div class="restful_body restful_hide">
       <if @restful_list.param_name@ ne "">
           <table>
              <group column="key">   
                 <tr valign="top"><th align="right" width="300px" >@restful_list.param_label;noquote@:</th><td align="left"><if @restful_list.data_type@ eq "boolean"><select name="@restful_list.param_name@" data-ws_type="@restful_list.param_type@"><option type="f">False</option>
                        <option type="t">True</option></select> </if><else> <input <if @restful_list.param_name@ eq "password"> type="password" </if><else>type=text</else> data-ws_type="@restful_list.param_type@" name="@restful_list.param_name@"></else>

   <br />@restful_list.param_desc;noquote@ 
</td></tr>
             </group>
           </table>    
      </if>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;       <input type="button" name="submit" onClick="submitForm(this,'@restful_list.url@','@restful_list.method@');" value="Submit"> <br />
  </div>

</div>
</multiple>


<div id="resultDialog" title="Result">
<div id="divDisplay"> Response from Server ... 
</div>

<form>
<textarea id="displayResultArea" rows="5" cols="80"></textarea>
</form>
</div>
