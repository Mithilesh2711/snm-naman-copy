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
function chec_save_posting(){
        var ans_postedby = $.trim( $("#ans_postedby").val() );
        var ans_posteddashboard = $.trim( $("#ans_posteddashboard").val() );
        var ans_postingdate = $.trim( $("#ans_postingdate").val() );
        var ans_postingtime = $.trim( $("#ans_postingtime").val() );
        var ans_announcment = $.trim( $("#ans_announcment").val() );
        var ans_status      = $.trim( $("#ans_status:checked").val() );
        var ans_publishdate = $.trim( $("#ans_publishdate").val() );
        var ans_publishtime = $.trim( $("#ans_publishtime").val() );
        var counts = 0;
        if( ans_postedby == ''){
            counts = 1;
        }
        if( ans_posteddashboard == ''){
            counts = 1;
        }
        if( ans_postingdate == ''){
            counts = 1;
        }
        if(ans_postingtime == ''){
            counts = 1;
        }
        if( ans_postingtime == ''){
             counts = 1;
        }
        if( ans_announcment == ''){
            counts = 1;
        }
        if( ans_publishdate == ''){
             counts = 1;
        }
        if( ans_publishtime == ''){
            counts = 1;
        }
        if( counts <=0){
            $(".processleave").hide();
        }
}
function set_foucsout(id){
         $("#"+id).focus();
    }
    function common_time_formatted(str,id){
           var spltime = str.split(":");
           if( spltime[1] == '' || typeof(spltime[1]) =='undefined' ){
                 alert("Time format should be like hh:mm(10:20) onwards");
                 $("#"+id).val("");
                 setTimeout(function(){set_foucsout(id);},500);
                 return false;
             }
    }

function filter_announcement(){
    var useroot = $("#rootXPath").val();
    $("form#myforms").attr("action",useroot+"ec_announcement/search");
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
 $("#ans_postingdate").click(function() {
          $(this).datepick({ dateFormat: "dd/mm/yyyy" ,onSelect:function(evt){setTimeout(function(){ /* */ },500);} }).datepick("show");
       });
       $("#ans_publishdate").click(function() {
          $(this).datepick({ dateFormat: "dd/mm/yyyy" ,onSelect:function(evt){setTimeout(function(){ /* */ },500);} }).datepick("show");
       });
function get_district_zone(){
            var usePath    = $.trim( $("#rootXPath").val() );
            var zonecode  = $.trim( $("#bch_zonecode").val() );

             $.ajax({
                             url: usePath+"branch/ajax_process",
                             type: 'POST',
                             data: {'zonecode': zonecode,'identity':'Y'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '<option value="">-Select-</option>';
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.zd_distcode+'">'+leds.zd_name+'</option>';
                                         i++;
                                    });
                              }
                              $("#bch_districtcode").html(mhtml);
                             },
                             error: function () {
                                 
                             },
                             cache: false
                 });

    
}

