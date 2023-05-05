function isFloatNegativeKey(e,vls){

	  if (e.charCode >= 32 && e.charCode < 127 && !/^-?\d*[.,]?\d*$/.test(vls + '' + String.fromCharCode(e.charCode)))
	  {
		return false;
	  }
	  return true;
}

$("#upto_date").click(function() {

    $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

});
$("#from_date").click(function() {

    $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

});


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

function filter_daily(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"daily_calculation/search");   
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function process_checkers_selected(obj){
            var types = obj.value;
            var monthbegningdated = $.trim( $("#monthbegningdated").val() );
            var todaydated        = $.trim( $("#todaydated").val() );
            var curmonth          = $.trim( $("#curmonth").val() );
           

            if( types == 'DYW'){
                $("#common_process").show();
                $("#monthwise_list").hide();
                $(".uppto_processdated").hide();
                $("#select_month").val('');
                $("#from_date").val(todaydated);
                $("#upto_date").val('');
            }else if( types == 'PRD'){
                $("#common_process").show();
                $("#monthwise_list").hide();
                $("#select_month").val('');
                $(".uppto_processdated").show();
                $("#from_date").val(monthbegningdated);
                $("#upto_date").val(todaydated);
            }else if( types == 'FMT'){
                $("#common_process").hide();
                $("#monthwise_list").show();
                $("#from_date").val('');
                $("#upto_date").val('');
                $("#select_month").val(curmonth);
            }
    }
    function check_process_running(){
        var usePath   = $.trim( $("#rootXPath").val() );
        var fromdate  = $.trim( $("#from_date").val() );
        var uptodate  = $.trim( $("#upto_date").val() );
        var amonth    = $.trim( $("#select_month").val() );

       

        var types     = "";            
        if( $("input[name='processcalculated']").is(":checked") ){
           types =  $("input[name='processcalculated']:checked").val();
        }
        if( types == 'DYW' ){
              if( fromdate == '') {
                  alert("Please select process date.");
                  $("#from_date").focus()
                  return false;
              }
        }else if( types == 'PRD' ){
            if( fromdate == '') {
                  alert("Please select process date.");
                  $("#from_date").focus()
                  return false;
              }else if( uptodate == '') {
                  alert("Please upto date.");
                  $("#upto_date").focus()
                  return false;
              }
        }else if( types == 'FMT' ){
            if(amonth == ''){
                 alert("Please select month");
                  $("#select_month").focus()
                  return false;
            }
        }
        $(".process_dailyattd").removeClass("hidden");
        $(".calculatebttnprocess").removeClass("hidden").addClass("hidden");
        setTimeout(function(){ process_attendance_calculation(); },500);
    }
    function process_attendance_calculation(){
            var usePath   = $.trim( $("#rootXPath").val() );
            var fromdate  = $.trim( $("#from_date").val() );
            var uptodate  = $.trim( $("#upto_date").val() );
            var amonth    = $.trim( $("#select_month").val() );
            var depcode    = $.trim( $("#al_depcode").val() );
            var empcode    = $.trim( $("#al_sewadarcode").val() );    
            

            var types     = "";            
            if( $("input[name='processcalculated']").is(":checked") ){
               types =  $("input[name='processcalculated']:checked").val();
            }
            if( types == 'DYW' ){
                  if( fromdate == '') {
                      alert("Please select process date.");
                      $("#from_date").focus()
                      return false;
                  }
            }else if( types == 'PRD' ){
                if( fromdate == '') {
                      alert("Please select process date.");
                      $("#from_date").focus()
                      return false;
                  }else if( uptodate == '') {
                      alert("Please upto date.");
                      $("#upto_date").focus()
                      return false;
                  }
            }else if( types == 'FMT' ){
                if(amonth == ''){
                     alert("Please select month");
                      $("#select_month").focus()
                      return false;
                }
            }
           
              $.ajax({
                     url: usePath + "daily_calculation/ajax_process",
                     type: 'POST',
                     data: {'identity':'PROCESS','depcode':depcode,'empcode':empcode,'from_date':fromdate,'upto_date':uptodate,'amonth':amonth,'type':types},
                     async: false,
                     success: function (resp) {
                        $(".process_dailyattd").removeClass("hidden").addClass("hidden");
                        $(".calculatebttnprocess").removeClass("hidden");
                         if( resp.status >0 ){
                             alert("Process successfully completed.");                             
                         }else{
                             if( resp.data =='2' ){
                                alert("Process already running by someone, Please try after some time");
                             }else{
                                alert("Process abort");
                             }
                            
                         }
                 },
                 error: function () {
                    $(".process_dailyattd").removeClass("hidden").addClass("hidden");
                        $(".calculatebttnprocess").removeClass("hidden");
                 },
                 cache: false
             });
}

function get_all_sewadar_by_department(){
    var usePath  = $.trim( $("#rootXPath").val() );
    var depcode  = $.trim( $("#al_depcode").val() );

     $.ajax({
                     url: usePath+"loans_advance/ajax_process",
                     type: 'POST',
                     data: {'depcode': depcode,'identity':'Y'},
                     async: false,
                     success: function (resp) {
                       var sdata = resp.data;
                       var vdata = resp.sedarname
                       var mhtml  = '<option value="">-Select-</option>';
                       var vhtml  = '<option value="">-Select-</option>';

                       var i = 1;
                      if(sdata.length >0 ){
                             $.each(sdata,function(key,leds){
                                 mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewcode+'</option>';
                                 i++;
                            });

                             $.each(sdata,function(key,led){
                                 vhtml +='<option value="'+led.sw_sewcode+'">'+led.sw_sewadar_name+'</option>';

                            });
                      }
                       $("#al_sewadarcode").html(mhtml);
                       $("#alsewdarname").html(vhtml);
                     },
                     error: function () {

                     },
                     cache: false
         });


}

function fill_from_sewadar_listed(types){
    var usePath  = $.trim( $("#rootXPath").val() );
    var sewcode  = ""
    if( types == 'code'){
        sewcode = $.trim( $("#al_sewadarcode").val() );
    }else if( types == 'sewadar'){
         sewcode = $.trim( $("#alsewdarname").val() );
    }

     $.ajax({
                     url: usePath+"loans_advance/ajax_process",
                     type: 'POST',
                     data: {'sewcode': sewcode,'identity':'SWCD'},
                     async: false,
                     success: function (resp) {
                         if(resp.status){
                             if( types == 'code'){
                                $("#alsewdarname").val(sewcode);
                                $(".my_dpeartmentname").html(resp.data[0].department);
                                $(".myjoining_dated").html(resp.data[0].joiningdate);
                                $(".mytotalworking_year").html(resp.data[0].sewduration);
                                $(".mytotalout_standing").html(resp.data[0].outstatnding);

                             }else if( types == 'sewadar'){
                                 $("#al_sewadarcode").val(sewcode);
                                $(".my_dpeartmentname").html(resp.data[0].department);
                                $(".myjoining_dated").html(resp.data[0].joiningdate);
                                $(".mytotalworking_year").html(resp.data[0].sewduration);
                                $(".mytotalout_standing").html(resp.data[0].outstatnding);
                             }
                         }else{
                                $(".my_dpeartmentname").html('');
                                $(".myjoining_dated").html('');
                                $(".mytotalworking_year").html('');
                                $(".mytotalout_standing").html('');
                                alert("No record(s) found.");
                         }


                     },
                     error: function () {
                               $(".my_dpeartmentname").html('');
                                $(".myjoining_dated").html('');
                                $(".mytotalworking_year").html('');
                                $(".mytotalout_standing").html('');
                     },
                     cache: false
         });
}