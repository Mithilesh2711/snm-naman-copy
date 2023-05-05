function isFloatNegativeKey(e,vls){

	  if (e.charCode >= 32 && e.charCode < 127 && !/^-?\d*[.,]?\d*$/.test(vls + '' + String.fromCharCode(e.charCode)))
	  {
		return false;
	  }
	  return true;
}

function isNumberFloatKey(evt)
 {
	  var charCode = (evt.which) ? evt.which : evt.keyCode;
	  if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57)){
		  return false;
	  }
	  return true;
   }

function isNumberKeys(evt) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
}
function check_module_isselected(){
    
        var lenths = 0
        var usertype = $.trim( $("#usertype").val() );
        if( usertype !='brc' ){
            if( $("input[name='listmodule[]']").is(":checked") ){
                lenths = $("input[name='listmodule[]']:checked").length;
            }       
            if( lenths <=0 ){
                alert("Please select aleast a module.");
                return false;
            }
        }
        
}
function check_modules_listing(event){
    var newid = event.id;
    var vls   = "";
    if( $("#"+newid).is(":checked") ){
        vls  =  $("#"+newid+":checked").val();
    }
    
    if( vls !='' && vls.toUpperCase() == 'HR' ){
        $(".manage_malisted").removeClass("hidden");
    }else{
        $(".manage_malisted").removeClass("hidden").addClass("hidden"); 
    }
}

function get_user_has_listing(){
     var usertype = $.trim( $("#usertype").val() );
     $("input[name='listmodule[]']").prop("checked",false);
     if( usertype == 'brc'){
        $(".user_department").removeClass("hidden").addClass("hidden");
        $(".mysewadar_list").removeClass("hidden").addClass("hidden");
        $(".processecmembers").removeClass("hidden").addClass("hidden");
        $(".user_zone").removeClass("hidden").addClass("hidden");
        $(".process_liested_modules").removeClass("hidden").addClass("hidden");
        $(".process_save_button").removeClass("hidden").addClass("hidden");

     }else{
         $(".user_department").removeClass("hidden");
         $(".mysewadar_list").removeClass("hidden");
         $(".processecmembers").removeClass("hidden");
         $(".process_liested_modules").removeClass("hidden");
         $(".process_save_button").removeClass("hidden");
     }
      
}

function get_employee_by_branch(){

            var usePath     = $.trim( $("#rootXPath").val() );
            var brccode     = $.trim( $("#my_branch").val() );
             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'brccode': brccode,'identity':'BRCHSEWA'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '<option value="">-Select Sewadar-</option>';
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewadar_name+'</option>';
                                         i++;
                                    });
                              }
                              $("#sewadarcode").html(mhtml);
                             },
                             error: function () {

                             },
                             cache: false
                 });


}

function get_employee_by_zone(){
            
            var usePath     = $.trim( $("#rootXPath").val() );
            var zonecode  = $.trim( $("#my_zones").val() );
             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'zonecode': zonecode,'identity':'ZNBRCH'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '<option value="">-Select Branch-</option>';
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.bch_branchcode+'">'+leds.bch_branchname+'</option>';
                                         i++;
                                    });
                              }
                              $("#my_branch").html(mhtml);
                             },
                             error: function () {
                                 
                             },
                             cache: false
                 });

    
}

function filter_users(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"create_user/user_list/search");
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
function validation_rules(types){
    $("#my_branch").html('<option value="">-Select Branch-</option>');
    $("#mydepartment").val('');
    $("#my_zones").val('');
    $("#sewadarcode").html('<option value="">-Select Sewadar-</option>');
    if( types == 'swd' ){        
        $("#mydepartment").attr("required",true);
        $("#sewadarcode").attr("required",true);
        $(".user_department").show();
        $(".user_zone").hide();
        $(".mysewadar_list").show();

    }else if( types == 'brc' ){
        $("#mydepartment").removeAttr("required");        
        $("#sewadarcode").attr("required",true);
        $("#my_zones").attr("required",true);
        $("#my_branch").attr("required",true);
        $(".user_zone").show();
        $(".user_department").hide();
        $(".mysewadar_list").show();
    }else if( types == 'gue' ){
        $("#mydepartment").removeAttr("required");
        $("#sewadarcode").removeAttr("required");
        $("#my_zones").removeAttr("required");
        $("#my_branch").removeAttr("required");
        $(".user_zone").hide();
        $(".user_department").hide();
        $(".mysewadar_list").hide();
    }else{
        $("#mydepartment").removeAttr("required");
        $("#sewadarcode").removeAttr("required");
        $("#my_zones").removeAttr("required");
        $("#my_branch").removeAttr("required");
        $(".user_zone").hide();
        $(".user_department").show();
        $(".mysewadar_list").show();
    }
}
function selected_users(types){
    if( types == 'swd' ){
        $("#listmodules_1").hide();
        $("#listmodules_2").hide();
        $("#listmodules_3").hide();
        $("#listmodules_4").hide();
        $("#listmodules_5").hide();
        $("#listmodules_6").hide();
        $("#listmodules_7").show();
        $("#listmodules_8").hide();
        $("#listmodules_9").hide();
        $("#mydepartment").attr("required",true);
        $("#sewadarcode").attr("required",true);
    }else if( types == 'spt' ){
        $("#listmodules_1").hide();
        $("#listmodules_2").hide();
        $("#listmodules_3").hide();
        $("#listmodules_4").hide();
        $("#listmodules_5").hide();
        $("#listmodules_6").show();
        $("#listmodules_7").show();
        $("#listmodules_8").hide();
        $("#listmodules_9").hide();
        $("#mydepartment").attr("required",true);
        $("#sewadarcode").attr("required",true);
    }else if( types == 'ecm' ){
        $("#listmodules_1").show();
        $("#listmodules_2").show();
        $("#listmodules_3").show();
        $("#listmodules_4").show();
        $("#listmodules_5").show();
        $("#listmodules_6").show();
        $("#listmodules_7").show();
        $("#listmodules_8").show();
        $("#listmodules_9").show();
        $("#mydepartment").attr("required",true);
        $("#sewadarcode").removeAttr("required");
     }else if( types == 'cod' ){
        $("#listmodules_1").show();
        $("#listmodules_2").show();
        $("#listmodules_3").show();
        $("#listmodules_4").show();
        $("#listmodules_5").show();
        $("#listmodules_6").show();
        $("#listmodules_7").show();
        $("#listmodules_8").show();
        $("#listmodules_9").show();
        $("#mydepartment").attr("required",true);
        $("#sewadarcode").attr("required",true);
    }else{
        $("#listmodules_1").show();
        $("#listmodules_2").show();
        $("#listmodules_3").show();
        $("#listmodules_4").show();
        $("#listmodules_5").show();
        $("#listmodules_6").show();
        $("#listmodules_7").show();
        $("#listmodules_8").show();
        $("#listmodules_9").show();
        $("#mydepartment").removeAttr("required");
        $("#sewadarcode").removeAttr("required");
    }
}

function generate_password(){
    var usePath     = $.trim( $("#rootXPath").val() );
   
    $.ajax({
                 url: usePath+"city/ajax_process",
                 type: 'POST',
                 data: {'Gepassw': 'Y','identity':'SPWD'},
                 async: false,
                 success: function (resp) {
                   if( resp.status){
                      $("#userpassword").val(resp.data);
                   }                  
                  
                 },
                 error: function () {

                 },
                 cache: false
     });
}
function get_employee_by_department(){
          
            var usePath    = $.trim( $("#rootXPath").val() );
            var departcode  = $.trim( $("#mydepartment").val() );
             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'departcode': departcode,'identity':'SWDPT'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '<option value="">-Select Sewadar-</option>';
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewadar_name+' ('+leds.sw_sewcode+')</option>';
                                         i++;
                                    });
                              }
                              $("#sewadarcode").html(mhtml);
                             },
                             error: function () {
                                 
                             },
                             cache: false
                 });

    
}

function check_user_listmodule(){
    /*
	var array = $.map($('input[name="listmodule[]"]:checked'), function(c){return c.value; });
	   if( $.inArray("SSS", array)!== -1 ){
		    $(".user_department").removeClass("hidden");
            $(".mysewadar_list").removeClass("hidden");
		    $("#mydepartment").prop("required",true);	
			$("#sewadarcode").prop("required",true);
	   }else{
		    $(".user_department").removeClass("hidden").addClass("hidden");
            $(".mysewadar_list").removeClass("hidden").addClass("hidden");
		    $("#mydepartment").prop("required",false);	
			$("#sewadarcode").prop("required",false);
			$("#mydepartment").val('');
			$("#sewadarcode").val('');
	   }
	   if( $.inArray("APV", array)!== -1 ){
		   $(".processecmembers").removeClass("hidden");
           $("#approvalby").prop("required",true);
		   $("#myecordination").prop("required",true);
	   }else{
		    $(".processecmembers").removeClass("hidden").addClass("hidden");
            $("#approvalby").prop("required",false);	
			$("#myecordination").prop("required",false);
			$("#approvalby").val('');
			$("#myecordination").val('');
		   
	   }
	   if( $.inArray("STF", array)!== -1 ){
		    $(".processupportstaff").removeClass("hidden");  
			$("#mysupportstaffdepartment").prop("required",true);
	   }else{
		   $(".processupportstaff").removeClass("hidden").addClass("hidden");  
           $("#mysupportstaffdepartment").val('');	
           $("#mysupportstaffdepartment").prop("required",false);		   
		   
	   }
    */
	
}

function get_employee_by_ecmember(type){

            var usePath     = $.trim( $("#rootXPath").val() );
            var departcode  = $.trim( $("#mydepartment").val() );
            
	  /*
            if( type == 'ec' || type == 'cod' ){
                 $(".processecmembers").removeClass("hidden");
                 $("#myecordination").prop("required",true);
                 $(".process_department").removeClass("hidden").addClass("hidden");
                 $(".user_zone").hide();
                 $(".processupportstaff").removeClass("hidden").addClass("hidden");
                 $("#mydepartment").prop("required",false);
                 $("#sewadarcode").prop("required",false);
                 $("#my_zones").prop("required",false);
                 $("#my_branch").prop("required",false);
                 $("#mysupportstaffdepartment").prop("required",false);
            }else if( type == 'adm' ){
                 $(".processecmembers").removeClass("hidden");
                 $("#myecordination").prop("required",true);
                 $(".process_department").removeClass("hidden").addClass("hidden");
                 $(".user_zone").hide();
                 $(".processupportstaff").removeClass("hidden").addClass("hidden");
                 $("#mydepartment").prop("required",false);
                 $("#sewadarcode").prop("required",false);
                 $("#my_zones").prop("required",false);
                 $("#my_branch").prop("required",false);
                 $("#sewadarcode").prop("required",false);
                 $("#myecordination").prop("required",false);
                 $("#mysupportstaffdepartment").prop("required",false);
                 $(".processecmembers").removeClass("hidden").addClass("hidden");
            }else if( type == 'std'){
                 $(".processupportstaff").removeClass("hidden");
                 $(".user_department").removeClass("hidden");
                 $(".user_department").show();
                 $("#mydepartment").prop("required",true);
                 $("#sewadarcode").prop("required",false);
                 $("#myecordination").prop("required",false);
                 $("#my_zones").prop("required",false);
                 $("#my_branch").prop("required",false);
                 $(".mysewadar_list").removeClass("hidden");
                 $(".mysewadar_list").show();
                 $(".process_department").removeClass("hidden");
                 $(".processecmembers").removeClass("hidden").addClass("hidden");                
                 $("#myecordination").html('<option value="">-Select-</option>');
                 $(".user_zone").hide();
                return false;
             }else if( type == 'swd' ){
                 $(".user_department").removeClass("hidden");
                 $(".user_department").show();
                 $(".mysewadar_list").removeClass("hidden");
                 $(".mysewadar_list").show();
                 $("#mydepartment").prop("required",true);
                 $("#sewadarcode").prop("required",true);
                 $(".process_department").removeClass("hidden");
                 $("#my_zones").prop("required",false);
                 $("#my_branch").prop("required",false);
                 $(".user_zone").hide();
                 $(".processecmembers").removeClass("hidden").addClass("hidden");
                 $("#myecordination").prop("required",false);
                 $("#myecordination").html('<option value="">-Select-</option>');
                 $(".processupportstaff").removeClass("hidden");
                 $(".processupportstaff").removeClass("hidden").addClass("hidden");
            }else if( type == 'hr'  || type == 'ict' ){
                 $(".user_department").removeClass("hidden");
                 $(".user_department").show();
                 $(".mysewadar_list").removeClass("hidden");
                 $(".mysewadar_list").show();
                 $("#mydepartment").prop("required",true);
                 $("#sewadarcode").prop("required",false);
                 $(".process_department").removeClass("hidden");
                 $("#my_zones").prop("required",false);
                 $("#my_branch").prop("required",false);
                 $(".user_zone").hide();
                 $(".processecmembers").removeClass("hidden").addClass("hidden");
                 $("#myecordination").prop("required",false);
                 $("#myecordination").html('<option value="">-Select-</option>');
                 $(".processupportstaff").removeClass("hidden");
                 $(".processupportstaff").removeClass("hidden").addClass("hidden");
            }else{
                 $(".processecmembers").removeClass("hidden").addClass("hidden");
                 $("#myecordination").prop("required",false);
                 $("#my_branch").prop("required",true);
                  $("#my_zones").prop("required",true);
                 $("#myecordination").html('<option value="">-Select-</option>');
                 $(".process_department").addClass("hidden");
                 $(".user_zone").show();
                 $(".processupportstaff").removeClass("hidden");
                 $(".processupportstaff").removeClass("hidden").addClass("hidden");
                 $(".mysewadar_list").removeClass("hidden");
                 $(".process_department").removeClass("hidden");
                 $(".user_department").removeClass("hidden").addClass("hidden");
                 $(".user_department").hide();
                 $(".mysewadar_list").show();
            }
            
             */
            $("input[name='listmodule[]']").prop("checked",false);
             if( type == 'ec' || type == 'cod'  ){
                $("#listmodules_3").removeClass("hidden");
                $("#listmodules_9").removeClass("hidden").addClass("hidden");
                $("#listmodules_10").removeClass("hidden").addClass("hidden");
                        $(".user_department").removeClass("hidden").addClass("hidden");
                        $(".mysewadar_list").removeClass("hidden").addClass("hidden");
                        $(".process_department").removeClass("hidden").addClass("hidden");
                         $("#mydepartment").prop("required",false);
                         $("#sewadarcode").prop("required",false);
                         $("#myecordination").prop("required",true);
                         $("#mydepartment").val('');
                        $("#sewadarcode").val('');
                        $(".approvaltype").removeClass("hidden");
             }else{
                        $("#listmodules_3").removeClass("hidden").addClass("hidden");
                        $("#listmodules_9").removeClass("hidden");
                       $("#listmodules_10").removeClass("hidden");
                        $(".user_department").removeClass("hidden");
                        $(".mysewadar_list").removeClass("hidden");
                        $(".process_department").removeClass("hidden");
		        $("#mydepartment").prop("required",true);
			$("#sewadarcode").prop("required",true);
                        $("#myecordination").prop("required",false);
						$(".approvaltype").removeClass("hidden").addClass("hidden");
             }
             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'type': type,'identity':'MEMCOD'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '';
                               if( type == 'ec' ){
                                    mhtml  = '<option value="">-Select EC Member-</option>';
                               }else if( type == 'cod' ){
                                   mhtml  = '<option value="">-Select Co-Ordinator-</option>';
                               }else{
                                    mhtml  = '<option value="">-Select-</option>';
                               }
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.id+'">'+leds.lds_name+' ('+leds.lds_membno+')</option>';
                                         i++;
                                    });
                              }
                              $("#myecordination").html(mhtml);
                             },
                             error: function () {

                             },
                             cache: false
                 });


}