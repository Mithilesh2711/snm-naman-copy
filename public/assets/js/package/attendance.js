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
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function shift_hide_showbtton(){
    var attend_shiftcode  = $.trim( $("input[name='attend_shiftcode']").val() );
    var attend_nightshift = $.trim( $("select[name='attend_nightshift']").val() );
    var attend_shfintime  = $.trim( $("input[name='attend_shfintime']").val() );
    var attend_shfout     = $.trim( $("input[name='attend_shfout']").val() );
    var attend_leavetakenrow = $.trim( $("input[name='attend_leavetakenrow']").val() );
    var attend_leaveavailby  = $.trim( $("input[name='attend_leaveavailby']").val() );
    var attend_totalsewarequired = $.trim( $("input[name='attend_totalsewarequired']").val() );
    var attend_whocanapply   = $("input[name='attend_whocanapply[]']:checked").length;
   
    var counts = 0
    if( attend_shiftcode == ''){
        counts = 1
    }else if( attend_nightshift == '' ){
        counts = 1
    }else if( attend_shfintime == '' ){
        counts = 1
    }else if( attend_shfout == '' ){
        counts = 1
    }
   // alert(counts)
    /*
    else if( attend_leavetakenrow == '' ){
        counts = 1
    }else if( attend_leaveavailby == '' ){
        counts = 1
    }else if( attend_totalsewarequired == '' ){
        counts = 1
    }else if( attend_whocanapply <=0 ){
         alert("Who can apply is required field.");
         counts = 1
    }*/

    if( counts <=0 ){
        $(".submit-section").hide();
    }else{
        return false;
    }
}


function process_save_leave_master(){
var attend_leaveCode = $.trim( $("input[name='attend_leaveCode']").val() );
var attend_leavetype = $.trim( $("input[name='attend_leavetype']").val() );

var attend_paidleave = $.trim( $("select[name='attend_paidleave']").val() );
var attend_runworking = $.trim( $("select[name='attend_runworking']").val() );
var attend_balancesleave = $.trim( $("select[name='attend_balancesleave']").val() );


var attend_enchash = $.trim( $("select[name='attend_enchash']").val() );
var attend_balanceforprevious = $.trim( $("select[name='attend_balanceforprevious']").val() );
var attend_annualquota = $.trim( $("input[name='attend_annualquota']").val() );
var attend_accumulationleave = $.trim( $("input[name='attend_accumulationleave']").val() );
var counts =0;
    if( attend_leaveCode == ''){
        counts = 1
    }else if( attend_leavetype == ''){
        counts = 1
    }else if( attend_paidleave == ''){
        counts = 1
    }else if( attend_runworking == ''){
        counts = 1
    }else if( attend_balancesleave == ''){
        counts = 1
    }else if( attend_enchash == ''){
        counts = 1
    }else if( attend_balanceforprevious == ''){
        counts = 1
    }else if( attend_annualquota == ''){
        counts = 1
    }else if( attend_accumulationleave == ''){
        counts = 1
    }
    
    if( counts <=0 ){
       // $(".submit-section").hide();
    }

}

function set_foucsout(id){
         $("#"+id).focus();
    }
    function common_time_formatted(str,id){
        var spltime = str.split(":");
        if( id == 'intimes'  ){
             if( spltime[1] == '' || typeof(spltime[1]) =='undefined' ){
                 alert("Time format should be like hh:mm(10:20) onwards");
                 $("#"+id).val("");
                 setTimeout(function(){set_foucsout(id);},500);
                 return false;
             }
        }
    }
     function validate_in_out_time(str,id){
         var spltime = str.split(":");
         if( id == 'attend_outtime' || id =='attend_intime' ){
                 if( spltime[1] == '' || typeof(spltime[1]) =='undefined' ){
                     alert("Time format should be like hh:mm(10:20) onwards");
                     $("#"+id).val("");
                     setTimeout(function(){set_foucsout(id);},500);
                     return false;
                 }else{
                     if( $.trim( $("#attend_intime").val() )!= ''  && $.trim( $("#attend_outtime").val() )!= '' ){
                             var outime = $.trim( $("#attend_outtime").val() ).split(":");
                             var intime = $.trim( $("#attend_intime").val() ).split(":");
                             if( parseInt(outime[0]) >parseInt(intime[0])  ){
                                 alert("In Time should be greater than Out Time");
                                 $("#attend_intime").val('');
                                 setTimeout(function(){set_foucsout('attend_intime');},500);
                                 return false;
                             }else if( parseInt(intime[0]) == parseInt(outime[0]) && parseInt(outime[1]) >parseInt(intime[1]) ){
                                 alert("In Time should be greater than Out Time");
                                 $("#attend_intime").val('');
                                 setTimeout(function(){set_foucsout('attend_intime');},500);
                                 return false;
                             }else{
                                 get_outtimes_detail();
                             }
                     }
                 }

         }else if( id == 'attend_shfintime' || id =='attend_shfout' ){
                if( spltime[1] == '' || typeof(spltime[1]) =='undefined' ){
                     alert("Time format should be like hh:mm(10:20) onwards");
                     $("#"+id).val("");
                     setTimeout(function(){set_foucsout(id);},500);
                     return false;
                 }else{
                     if( $.trim( $("#attend_shfintime").val() )!= ''  && $.trim( $("#attend_shfout").val() )!= '' ){
                             var intm = $.trim( $("#attend_shfintime").val() ).split(":");
                             var outm  = $.trim( $("#attend_shfout").val() ).split(":");
                             if( parseInt(intm[0]) >parseInt(outm[0])   ){
                                 alert("Out Time should be greater than In Time");
                                 $("#attend_shfout").val('');
                                 setTimeout(function(){set_foucsout('attend_shfout');},500);
                                 return false;
                             }else if( parseInt(intm[0]) == parseInt(outm[0]) && parseInt(intm[1]) >parseInt(outm[1]) ){
                                 alert("Out Time should be greater than In Time");
                                 $("#attend_shfout").val('');
                                 setTimeout(function(){set_foucsout('attend_shfout');},500);
                                 return false;
                             }else{
                                  get_shift_hours();
                             }
                      }
                 }

         }else if( id == 'attend_starttime' || id =='attend_endtime' ){
                if( spltime[1] == '' || typeof(spltime[1]) =='undefined' ){
                     alert("Time format should be like hh:mm(10:20) onwards");
                     $("#"+id).val("");
                     setTimeout(function(){set_foucsout(id);},500);
                     return false;
                 }else{
                     if( $.trim( $("#attend_starttime").val() )!= ''  && $.trim( $("#attend_endtime").val() )!= '' ){
                             var intms = $.trim( $("#attend_starttime").val() ).split(":");
                             var outms  = $.trim( $("#attend_endtime").val() ).split(":");
                             if( parseInt(intms[0]) >parseInt(outms[0])   ){
                                 alert("End Time should be greater than Start Time");
                                 $("#attend_endtime").val('') ;
                                 setTimeout(function(){set_foucsout('attend_endtime');},500);
                                 return false;
                             }else if( parseInt(intms[0]) == parseInt(outms[0]) && parseInt(intms[1]) >parseInt(outms[1]) ){
                                 alert("End Time should be greater than Start Time");
                                 $("#attend_endtime").val('') ;
                                 setTimeout(function(){set_foucsout('attend_endtime');},500);
                                 return false;
                             }else{
                                  get_shift_hours_holiday();
                             }
                      }

                 }

         }
     }

    function ValidateTime(str,id){
     var spltime = str.split(":");
     if( parseInt(spltime) < 9 ){
         alert("Time format will be 9:00 onwards");
         $("#"+id).val("");
         $("#"+id).focus();
         return false;
     }else if( parseInt(spltime[0]) < 9 ){
         alert("Time format will be 9:00 onwards");
         $("#"+id).val("");
         $("#"+id).focus();
         return false;
     }else if( parseInt(spltime[1]) == '' || typeof(spltime[1]) =='undefined' ){
         alert("Time format should be like 9:00 onwards");
         $("#"+id).val("");
         $("#"+id).focus();
         return false;
     }

}


function get_shift_hours_holiday(){
             var usePath      = $("#rootPath").val();
             var startTime    = $("#attend_starttime").val();
             var endTime      = $("#attend_endtime").val();
             $.ajax({
                 url: usePath+"employee/ajax/process_action_module",
                 type: 'POST',
                 data: {'ishourscalculate':'Y',"FromTime":startTime,"EndTime":endTime},
                 async: false,
                 success: function (resp) {
                    if(resp.status){
                       $("#attend_endhours").val(resp.dataTime);
                    }else{
                        //alert(resp.message);
                        return false
                    }

                 },
                 error: function () {

                 },
                 cache: false

             });
         }
         function get_outtimes_detail(){
                 var usePath      = $("#rootPath").val();
                 var startTime    = $("#attend_outtime").val();
                 var endTime      = $("#attend_intime").val();
                 $.ajax({
                     url: usePath+"employee/ajax/process_action_module",
                     type: 'POST',
                     data: {'ishourscalculate':'Y',"FromTime":startTime,"EndTime":endTime},
                     async: false,
                     success: function (resp) {
                        if(resp.status){
                           $("#attend_runworking").val(resp.dataTime);
                        }else{
                            //alert(resp.message);
                            return false
                        }

                     },
                     error: function () {

                     },
                     cache: false

                 });
         }

         function get_shift_hours(){
             var usePath      = $("#rootPath").val();
             var startTime    = $("#attend_shfintime").val();
             var endTime      = $("#attend_shfout").val();
             $.ajax({
                 url: usePath+"employee/ajax/process_action_module",
                 type: 'POST',
                 data: {'ishourscalculate':'Y',"FromTime":startTime,"EndTime":endTime},
                 async: false,
                 success: function (resp) {
                    if(resp.status){
                       $("#attend_shfhrs").val(resp.dataTime);
                    }else{
                        //alert(resp.message);
                        return false
                    }

                 },
                 error: function () {
                     alert("System is not responding.");
                 },
                 cache: false

             });
         }

         function get_text_from_leaves(Id){
     $("#trntype").val(Id);
     if( Id== 'ob'){
        $("#frmd").text("Balance On");
        $("#numdays").text("Balance Days");
        $("#useleavecode").val('');
        $("#Bo").val('');
        $("#Lc").val('');
        $(".todate").hide();
     }else if( Id== 'cl'){
        $("#frmd").text("Credit On");
        $("#numdays").text("Credit Days");
        $("#useleavecode").val('');
        $("#Bo").val('');
        $("#Lc").val('');
        $(".todate").hide();
     }else if( Id== 'ec'){
        $("#frmd").text("Encash On");
        $("#numdays").text("Encashment");
        $("#useleavecode").val('');
        $("#Bo").val('');
        $("#Lc").val('');
        $(".todate").hide();
     }else if( Id== 'al'){
        $("#frmd").text("Avail From");
        $("#numdays").text("Avail Days");
        $(".todate").show();
        $("#useleavecode").val('');
        $("#Bo").val('');
        $("#Lc").val('');
     }
 }

  function get_employee_code(Vl){
   
            if( Vl!= '' ){
                $("#employeeCode").val(Vl);
                $("#empname").val(Vl);
            }else{
                $("#employeeCode").val('');
                $("#empname").val('');
            }
        }
         function get_all_leave_detail(){
             
             var usePath  = $("#rootXPath").val();
             var empCode  = $("#empcode").val();
             var paidyear = $("#attend_paidyear").val();
             if( paidyear == ''){
                alert("Please select year")
                 $("#attend_paidyear").focus();
                 return false;
             }else if( empCode == ''){
                 alert("Please select employee first")
                 $("#empcode").focus();
                 return false;
             }

             $.ajax({
                 url: usePath+"leave/ajax/add_leave_details",
                 type: 'POST',
                 data: {'empCode':empCode,'all_leaves':'Y',"paidyear":paidyear},
                 async: false,
                 success: function (resp) {
                        if( resp.nsleavs.length >0 ){
                               var lvdata = resp.nsleavs;
                               var c = 1;
                               $.each(lvdata,function(keys,lv){
                                    html +='<tr><td><input type="text" readonly  class="text_background" name="leavecodes[]" id="leavecodes'+c+'" style="width:120px;" value="'+lv.lb_leavecode+'"/></td>';
                                    html +=' <td><input type="text" readonly  class="" name="leavebalance[]" id="leavebalance'+c+'" style="width:120px;" value="'+lv.lb_openbal+'"/></td>';
                                    html +='</tr>';
                                    c +=1
                                });
                                $("#leavebalancedetail").html(html);
                         }
                        if( resp.status ){
                            var html = '';
                            var sdata = resp.data;
                            if( sdata.length >0 ){
                                var i =1;
                                var trans;
                                $.each(sdata,function(key,lvs){
                                    if ( lvs.ls_transtype == 'O'){
                                        trans = 'OPENED ON';
                                    }else if( lvs.ls_transtype == 'C'){
                                        trans = 'CREDITED ON';
                                    }else if( lvs.ls_transtype == 'E'){
                                        trans = 'ENCASHMENT ON';
                                    }
                                    else if( lvs.ls_transtype == 'A'){
                                        trans = 'AVAILED ON';
                                    }

                                   html += '<tr class="isTotalInc">';
                                   html += '<td><input type="text" readonly class="text_background"  name="slno" id="slno" style="width:100px;text-align:center;" value="'+i+'"/></td>';
                                   html += '<td><input type="text" readonly  name="Id[]"  id="Id" style="width:110px;text-align:center;" value="'+lvs.ls_number+'"/></td>';
                                   html += '<td><input type="text" readonly  name="EmpCode[]" id="EmpCode" style="width:110px;text-align:center;" value="'+lvs.ls_empcode+'"/></td>';
                                   html += '<td><input type="text" readonly  name="TransType[]" id="TransType" style="width:110px;" value="'+lvs.ls_transtype+'"/></td>';
                                   html += '<td><input type="text" readonly  name="FromDate[]" id="FromDate" style="width:110px;" value="'+lvs.frmdate+'"/></td>';
                                   html += '<td><input type="text" readonly  name="ToDate[]" id="ToDate" style="width:110px;" value="'+lvs.upsdate+'"/></td>';
                                   html += '<td><input type="text" readonly  name="ToBal[]" id="ToBal" style="width:110px;text-align:center;" value="'+lvs.ls_days+'"/></td>';
                                   html += '</tr>';
                                   i++;
                                });
                                var isprtPaths = usePath.replace(/\/$/, '');
                                var printUrl   = '';
                                if( location.port !=3000 ){
                                    isprtPaths = isprtPaths+":12001";
                                    printUrl = '<a href="'+isprtPaths+resp.printpath+'" target="_blank"><img src="'+usePath+'images/print.png"/></a>';
                                }else{
                                    printUrl = '<a href="'+isprtPaths+resp.printpath+'" target="_blank"><img src="'+usePath+'images/print.png"/></a>';
                                 }
                                 $(".is_print_employee").html(printUrl);
                                 $("#alleavescode").html(html);
                                 $("#useleavecode").val('');
                                 $("#Bo").val('');
                                 $("#Lc").val('');
                                 $("#todate").val('');
                                 $('html, body').animate({scrollTop: 0}, 'slow');
                            }

                        }else{
                            $(".is_print_employee").html('<img src="'+usePath+'images/print.png" disabled="disabled"/>');
                           alert(resp.message);
                        }
                 },
                 error: function () {

                 },
                 cache: false

             });
         }
         function get_shift_hours_holiday(){
             var usePath      = $("#rootPath").val();
             var startTime    = $("#attend_starttime").val();
             var endTime      = $("#attend_endtime").val();
             $.ajax({
                 url: usePath+"employee/ajax/process_action_module",
                 type: 'POST',
                 data: {'ishourscalculate':'Y',"FromTime":startTime,"EndTime":endTime},
                 async: false,
                 success: function (resp) {
                    if(resp.status){
                       $("#attend_endhours").val(resp.dataTime);
                    }else{
                        //alert(resp.message);
                        return false
                    }

                 },
                 error: function () {

                 },
                 cache: false

             });
         }
         function get_outtimes_detail(){
                 var usePath      = $("#rootPath").val();
                 var startTime    = $("#attend_outtime").val();
                 var endTime      = $("#attend_intime").val();
                 $.ajax({
                     url: usePath+"employee/ajax/process_action_module",
                     type: 'POST',
                     data: {'ishourscalculate':'Y',"FromTime":startTime,"EndTime":endTime},
                     async: false,
                     success: function (resp) {
                        if(resp.status){
                           $("#attend_runworking").val(resp.dataTime);
                        }else{
                            //alert(resp.message);
                            return false
                        }

                     },
                     error: function () {

                     },
                     cache: false

                 });
         }

         