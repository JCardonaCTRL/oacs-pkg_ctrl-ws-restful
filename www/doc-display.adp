<master>

<style>
div.restful_header {background-color:#b0c4de;}
div.restful_body {background-color:#CEECF5;}
div.restful_hide {display:none}
div.restful_show {display:inset}
span.require {color:red;}
</style>

<require api="jquery" version=2.1 />


<script>

function hideShow(clicked) {

   var ws_item = $(clicked).parent().parent();
   var ws_item_header = $(clicked).parent();
   var ws_item_body = ws_item.find(".restful_body");
   
   if (ws_item_body.hasClass("restful_hide")) {
         $(clicked).html("Hide");
         ws_item_body.removeClass("restful_hide");
         ws_item_body.addClass("restful_show");
   }  else {
         $(clicked).html("Show");
         ws_item_body.removeClass("restful_show");
         ws_item_body.addClass("restful_hide");
   }
   
}
</script>

<br />
<br />

<multiple name="restful_list">
<div class="restful_item">
    <div class="restful_header"> [<a href='#' onClick="hideShow(this);">Show</a>]
    <b> @restful_list.url@  (@restful_list.method@) </b> <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <i> @restful_list.name@ </i>  - 
    @restful_list.document@

    </div>
    <div class="restful_body restful_hide">
       <if @restful_list.param_name@ ne "">
           <table>
              <group column="key">   
                 <tr valign="top"><th align="right" width="300px" >@restful_list.param_label;noquote@:</th><td align="left"><if @restful_list.data_type@ eq "boolean"><select name="@restful_list.param_name@"><option type="f">False</option>
                        <option type="t">True</option></select> </if><else> <input type=text name="@restful_list.param_name@"></else>

   <br />@restful_list.param_desc;noquote@ 
</td></tr>
             </group>
           </table>    
      </if>
   </div>
</div>
</multiple>


