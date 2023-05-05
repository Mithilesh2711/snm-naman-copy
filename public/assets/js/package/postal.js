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
function ValidateEmail(email) {
    var expr = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
    return expr.test(email);
}

function filter_dispatched(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"postal/search");   
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
function get_zone_branches(){
    var usePath    = $.trim( $("#rootXPath").val() );
    var zonecode  = $.trim( $("#so_zone").val() );

     $.ajax({
                     url: usePath+"branch/ajax_process",
                     type: 'POST',
                     data: {'zonecode': zonecode,'identity':'BRCH'},
                     async: false,
                     success: function (resp) {
                       var sdata = resp.data;
                       var mhtml  = '<option value="">-Select-</option>';
                       var i = 1;
                      if(sdata.length >0 ){
                             $.each(sdata,function(key,leds){
                                 mhtml +='<option value="'+leds.bch_branchcode+'">'+leds.bch_branchname+'</option>';
                                 i++;
                            });
                      }
                      $("#so_branch").html(mhtml);
                     },
                     error: function () {

                     },
                     cache: false
         });


}
function process_branch_headoffices(types){
    $("#dps_type").val(types);
    if( types != 'Branch' ){
        $(".branchclass").removeClass("hidden").addClass("hidden")
        
    }else{
        $(".branchclass").removeClass("hidden");
    }
}

function get_branchdarress_listed(){
    var usePath   = $.trim( $("#rootXPath").val() );
    var branchcode  = $.trim( $("#so_branch").val() );
   
     $.ajax({
                     url: usePath+"loans_advance/ajax_process",
                     type: 'POST',
                     data: {'branchcode': branchcode,'identity':'BRANCHADD'},
                     async: false,
                     success: function (resp) {                                        
                       var i = 1;
                       if( resp.status ){   
                           var sdata = resp.data                    
                            $("#dps_branchaddress").val(sdata.bch_address);
                         }else{
                            $("#dps_branchaddress").val('');
                         }
                        
                      
                       
                     },
                     error: function () {

                     },
                     cache: false
         });


}


$("#search_fromdated").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy"  }).datepick("show");
});
$("#search_uptodated").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy"  }).datepick("show");
});
