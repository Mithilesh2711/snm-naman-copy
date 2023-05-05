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
function filter_deduction_list_search(){
    var useroot = $("#userXRoot").val();
    $("form#myForms").attr("action",useroot+"views/deductions_list/search");   
    $("form#myForms").submit();
}
function view_deduction_listed_data(){
    var usePath  = $.trim( $("#userXRoot").val() );
    var dataval = ""   
    if( $("input[name='monthly_deduction']").is(":checked") ){
        dataval =  $("input[name='monthly_deduction']:checked").val();
    }
    $("#requesttype").val(dataval);
   

}
function filter_sewdar_birthday_search(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"views/birthday_list/search");   
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function filter_sewdar_card_search(){
    var useroot = $("#userXRoot").val();
    var cattype  = $("input[name='sewdar_checked_filter']:checked").val();
     var catsname = "";
    if( cattype == 'SW' ){
        catsname = $("#sewadar_category").val();
    }else{
        catsname = $("#sewa_member").val(); 
    }
    if( catsname == '' ){
        alert("Please select category");
        return false;
    }
    $("#cattype").val(cattype);
    $("form#myforms").attr("action",useroot+"views/sewadar_cards/search");   
    $("form#myforms").submit();
}
function show_sewdar_checked_listed(){
    var vals = $("input[name='sewdar_checked_filter']:checked").val();
    if( vals != '' ){
            if( vals == 'SW'){
                $(".sewadar_organiztion").removeClass("hidden");
                $(".member_organiztion").removeClass("hidden").addClass("hidden");
                $("#sewadar_category").val("SDP");
                filter_sewdar_card_search();
            }else if( vals == 'MB'){
                $("#sewa_member").val("EC");
                $(".member_organiztion").removeClass("hidden");
                $(".sewadar_organiztion").removeClass("hidden").addClass("hidden");
                filter_sewdar_card_search();
            }
    }
}
function get_data_values(types){
    var usePath  = $.trim( $("#userXRoot").val() );
    var dataval = ""
    
    
    if( types == 'LIC' ){
        dataval = $.trim( $("#lic").val() );
    }else if( types == 'BUILD'){
        dataval = $.trim( $("#building").val() );
    }else if( types == 'ELEC'){
        dataval =  $.trim( $("#electricity").val() );
    }else if( types == 'HEAL'){
        dataval =  $.trim( $("#health").val() );
    }

  
    

    $.ajax({
                     url: usePath+"deductions_list/ajax_process",
                     type: 'POST',
                     data: {'dataval': dataval,'identity':'datalist'},
                     async: false,
                    
                     success: function (data1) {
                        alert("hi")
                        if( types == 'LIC'){
                            $("#stype").text("LIC Sewadar");
                        
                    
                        }else if  ( types == 'BUILD'){
                            $("#stype").text("Building Sewadar");
                            
                        } else if ( types == 'ELEC'){
                            $("#stype").text("Electricity Sewadar");
                            
                        } else if ( types == 'HEAL'){
                            $("#stype").text("Health Sewadar");
                            
                        }
                         


                     }

    });
       
    

      
 }
   


105213