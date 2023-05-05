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
function set_foucsout(id){
         $("#"+id).focus();
    }

    function edit_manual_punches(empcode,pid){
        var usePath        = $("#rootXPath").val();
        var manualouttime  = $("#manualouttime"+pid).val();
        alert(manualouttime)
        $.ajax({
            url: usePath + "manualpunch/ajax/insert_manual_punch",
            type: 'POST',
            data: {'machine_punch_detail':'UPD','empcode':empcode,'pid':pid,'mypunchtime':manualouttime},
            async: false,
            success: function (resp) {
                if( resp.status){
                    alert(resp.message)
                }                                
                   
        },
        error: function () {
            alert("No record(s) found.");
        },
        cache: false
       });
    }

    function get_all_manual_punches(){
        var usePath     = $("#rootXPath").val();
        var empcode     = $("#sewdar_name").val();
        var depcode     = $("#my_department").val();
        var from_date   = $("#trnFromDate").val();
        var upto_time   = $("#trnUptoDate").val();
                $.ajax({
                    url: usePath + "manualpunch/ajax/insert_manual_punch",
                    type: 'POST',
                    data: {'machine_punch_detail':'MNPNCH','empcode':empcode,'depcode':depcode,'from_date':from_date,'upto_time':upto_time},
                    async: false,
                    success: function (resp) {
                        var  mHtml = "";
                        var i =1;
                        if( resp.status){
                            var sdata = resp.data;
                            if( sdata.length >0 ){
                            $.each(sdata,function(key,manl){
                            mHtml += '<tr>';								  
                            mHtml += '<td class="td_tr_width"><input type="text" class="text_background  form-control" name="manualslnumber" id="manualslnumber'+manl.punchid+'" value="'+manl.mp_empcode+'"/></td>';
                            mHtml += '<td class="td_tr_width"><input type="text" class="text_background  form-control" name="manualslname" id="manualslname'+manl.punchid+'" value="'+manl.myempname+'"/></td>';
                            mHtml += '<td class="td_tr_text_width"><input type="text" class="form-control" name="manualintime" id="manualintime'+manl.punchid+'" value="'+manl.indate+'"/></td>';
                            mHtml += '<td class="td_tr_text_width"><input type="text" class="form-control" name="manualouttime" id="manualouttime'+manl.punchid+'" value="'+manl.intimes+'"/></td>';
                            mHtml += '<td class="text-right" style="display:flex;">';
                            var empcodes = "'"+manl.mp_empcode+"'"
                            mHtml += '<a class="dropdown-item" href="javascript:;" onclick="edit_manual_punches('+empcodes+','+manl.punchid+');" style="padding-left: 0;padding-right: 0;"><i class="fa fa-pencil m-r-5"></i></a>'; 
                            mHtml += '&nbsp;<a class="dropdown-item"  href="javascript:;" onclick="delete_manual_punches('+empcodes+','+manl.punchid+');"><i class="fa fa-trash-o m-r-5"></i></a>';
                            mHtml += '</td>';
                            mHtml  += '</td>';
                            mHtml  += '</tr>';
                            i = i+1;
                            });
                            $("#manuallpunchdetail").html(mHtml);
                            }
                        }else{
                            $("#manuallpunchdetail").html('<tr><td colspan="4">No record(s) found.</td></tr>');
                        }                                        
                        
                },
                error: function () {
                    $("#manuallpunchdetail").html('<tr><td colspan="4">No record(s) found.</td></tr>');
                },
                cache: false
            });
    }
    
    function delete_manual_punches(empcode,pid){
        var usePath        = $("#rootXPath").val();     
        if( confirm("Are you sure want to delete?") ){
                $.ajax({
                    url: usePath + "manualpunch/ajax/insert_manual_punch",
                    type: 'POST',
                    data: {'machine_punch_detail':'DELIT','empcode':empcode,'pid':pid},
                    async: false,
                    success: function (resp) {
                            var  mHtml = "";
                            var i =1;
                            if( resp.status){                         
                                alert(resp.message)
                            }
                            var sdata = resp.data;
                            if( sdata.length >0 ){
                             $.each(sdata,function(key,manl){
                              mHtml += '<tr>';								  
                              mHtml += '<td class="td_tr_width"><input type="text" class="text_background  form-control" name="manualslnumber" id="manualslnumber'+manl.punchid+'" value="'+manl.mp_empcode+'"/></td>';
                              mHtml += '<td class="td_tr_width"><input type="text" class="text_background  form-control" name="manualslname" id="manualslname'+manl.punchid+'" value="'+manl.empnames+'"/></td>';
                              mHtml += '<td class="td_tr_text_width"><input type="text" class="form-control" name="manualintime" id="manualintime'+manl.punchid+'" value="'+manl.indate+'"/></td>';
                              mHtml += '<td class="td_tr_text_width"><input type="text" class="form-control" name="manualouttime" id="manualouttime'+manl.punchid+'" value="'+manl.intimes+'"/></td>';
                              mHtml += '<td class="text-right" style="display:flex;">';
                              var empcodes = "'"+manl.mp_empcode+"'"
                              mHtml += '<a class="dropdown-item" href="javascript:;" onclick="edit_manual_punches('+empcodes+','+manl.punchid+');" style="padding-left: 0;padding-right: 0;"><i class="fa fa-pencil m-r-5"></i></a>'; 
                              mHtml += '&nbsp;<a class="dropdown-item"  href="javascript:;" onclick="delete_manual_punches('+empcodes+','+manl.punchid+');"><i class="fa fa-trash-o m-r-5"></i></a>';
                              mHtml += '</td>';
                              mHtml  += '</td>';
                              mHtml  += '</tr>';
                              i = i+1;
                              });
                              $("#manuallpunchdetail").html(mHtml);
                            }else{
                               $("#manuallpunchdetail").html('<tr><td colspan="4">No record(s) found.</td></tr>');
                            }                                        
                        
                },
                error: function () {
                    $("#manuallpunchdetail").html('<tr><td colspan="4">No record(s) found.</td></tr>');
                },
                cache: false
            });
    
         }
    }


    function get_sewadar_manual_department(){
        var usePath   = $.trim( $("#rootXPath").val() );
        var depcode   = $.trim( $("#manuallocation").val() );
        var loantype  = "";       
            $.ajax({
                         url: usePath+"loans_advance/ajax_process",
                         type: 'POST',
                         data: {'depcode': depcode,'loantype':loantype,'identity':'Y'},
                         async: false,
                         success: function (resp) {                          
                           var sdata = resp.data;                          
                           var mhtml  = '<option value="">-Select-</option>';                                                       
                           var i      = 1;
                            if( resp.status){
                                if(sdata.length >0 ){
                                        $.each(sdata,function(key,leds){
                                            mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewadar_name+' ('+leds.sw_sewcode+')</option>';
                                            i++;
                                        });                                      
                                }
                            }                          
                           $("#mannual_sewdar_name").html(mhtml);
                         },
                         error: function () {
                          
                         },
                         cache: false
             }); 



}
    function get_all_sewadar_by_department(){
        var usePath   = $.trim( $("#rootXPath").val() );
        var depcode   = $.trim( $("#my_department").val() );
        var loantype  = ""
       
            $.ajax({
                         url: usePath+"loans_advance/ajax_process",
                         type: 'POST',
                         data: {'depcode': depcode,'loantype':loantype,'identity':'Y'},
                         async: false,
                         success: function (resp) {
                          
                           var sdata = resp.data;                          
                           var mhtml  = '<option value="">-Select-</option>';                                                       
                           var i      = 1;
                            if( resp.status){
                                if(sdata.length >0 ){
                                        $.each(sdata,function(key,leds){
                                            mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewadar_name+' ('+leds.sw_sewcode+')</option>';
                                            i++;
                                        });                                      
                                }
                            }
                          
                           $("#sewdar_name").html(mhtml);
                         },
                         error: function () {
                          
                         },
                         cache: false
             }); 



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
        function get_all_raw_punches(){
            var depcode     = $("#my_department").val();  
            var empcode     = $("#sewdar_name").val();          
           if( depcode == ''){
                alert("Department is required.");
                $("#my_department").focus();
                return false;
            }else if( empcode == ''){
                alert("Sewadar is required.");
                $("#sewdar_name").focus();
                return false;
            }
            $(".processmachinedata").removeClass("hidden");
            $(".noprocessmachinedata").removeClass("hidden").addClass("hidden");
            setTimeout(function(){ get_machine_punches();},500);
            setTimeout(function(){ get_all_manual_punches();},500);
           
        }

         function get_machine_punches(){
           var usePath     = $("#rootXPath").val();
           var empcode     = $("#sewdar_name").val();
           var depcode     = $("#my_department").val();
           var from_date   = $("#trnFromDate").val();
           var upto_time   = $("#trnUptoDate").val();       

              $.ajax({
                     url: usePath + "manualpunch/ajax/insert_manual_punch",
                     type: 'POST',
                     data: {'machine_punch_detail':'Y','empcode':empcode,'depcode':depcode,"from_date":from_date,"upto_time":upto_time},
                     async: false,
                     success: function (resp) {
                        $(".processmachinedata").removeClass("hidden").addClass("hidden");
                        $(".noprocessmachinedata").removeClass("hidden");
                         var i = 1
                         var mHtml = '';
                          if( resp.status){                            
                              var sdata = resp.data;
                              if( sdata.length >0 ){
                               $.each(sdata,function(key,manl){
                                mHtml += '<tr>';
                                mHtml += '<td class="td_tr_width"><input type="text" class="text_background  form-control" name="slnumber" id="slnumber" value="'+manl.mp_empcode+'"/></td>';
                                mHtml += '<td class="td_tr_width"><input type="text" class="text_background  form-control" name="empnames" id="empnames" value="'+manl.myempname+'"/></td>';
                                mHtml += '<td class="td_tr_text_width"><input type="text" class="form-control" name="machineintime" id="machineintime" value="'+manl.indate+'"/></td>';
                                mHtml += '<td class="td_tr_text_width"><input type="text" class="form-control" name="machineouttime" id="machineouttime" value="'+manl.intimes+'"/></td>';
                                mHtml += '</tr>';                               
                                  i = i+1;
                                });
                              }
                              $("#machinepunchdetail").html(mHtml);
                          }else{                              
                               $("#machinepunchdetail").html('<tr><td colspan="4">No record(s) found.</td></tr>');
                              
                          }
                          
                 },
                 error: function () {
                    $("#machinepunchdetail").html('<tr><td colspan="4">No record(s) found.</td></tr>');
                    $(".processmachinedata").removeClass("hidden").addClass("hidden");
                    $(".noprocessmachinedata").removeClass("hidden");
                 },
                 cache: false
             });

}

function process_add_mannual_punches(){   
    var mp_empcode     = $("#mannual_sewdar_name").val();   
    var mp_date        = $.trim( $("#indates").val() );
    var mp_time        = $.trim( $("#intimes").val() );
    var depcode        = $.trim( $("#manuallocation").val() );
    if( depcode == ''){
        alert("Department is required");
        $("#manuallocation").focus();
        return false;
    }else if( mp_empcode == ''){
       alert("Name is required");
       $("#mannual_sewdar_name").focus();
       return false;
   }else if( mp_date == ''){
       alert("Date is required");
       $("#indates").focus();
       return false;
   }else if( mp_time == ''){
       alert("Time is required");
       $("#intimes").focus();
       return false;
   }
   $(".noaddmanulpunchesclass").removeClass("hidden");
   $(".addmanulpunchesclass").removeClass("hidden").addClass("hidden");   

   setTimeout(function(){ add_manual_punches(); },500);
}

function add_manual_punches(){
    var usePath        = $("#rootXPath").val();
    var mp_empcode     = $("#mannual_sewdar_name").val();   
    var mp_date        = $.trim( $("#indates").val() );
    var mp_time        = $.trim( $("#intimes").val() );
    var depcode        = $.trim( $("#manuallocation").val() );
   

              $.ajax({
                     url: usePath + "manualpunch/ajax/insert_manual_punch",
                     type: 'POST',
                     data: {'save_manual_detail':'MNL','depcode':depcode,'mp_empcode':mp_empcode,"mp_card_number":'',"mp_date":mp_date,"mp_time":mp_time},
                     async: false,
                     success: function (resp) {
                        $(".noaddmanulpunchesclass").removeClass("hidden").addClass("hidden");
                        $(".addmanulpunchesclass").removeClass("hidden");
                         var i = 1
                         var mHtml = '';
                          if( resp.status){
                              alert(resp.message);
                              var sdata = resp.data;
                              if( sdata.length >0 ){
                               $.each(sdata,function(key,manl){
                                mHtml += '<tr>';								  
                                mHtml += '<td class="td_tr_width"><input type="text" class="text_background  form-control" name="manualslnumber" id="manualslnumber'+manl.punchid+'" value="'+manl.mp_empcode+'"/></td>';
                                mHtml += '<td class="td_tr_width"><input type="text" class="text_background  form-control" name="manualslname" id="manualslname'+manl.punchid+'" value="'+manl.empnames+'"/></td>';
                                mHtml += '<td class="td_tr_text_width"><input type="text" class="form-control" name="manualintime" id="manualintime'+manl.punchid+'" value="'+manl.indate+'"/></td>';
                                mHtml += '<td class="td_tr_text_width"><input type="text" class="form-control" name="manualouttime" id="manualouttime'+manl.punchid+'" value="'+manl.intimes+'"/></td>';
                                mHtml += '<td class="text-right" style="display:flex;">';
                                var empcodes = "'"+manl.mp_empcode+"'"
                                mHtml += '<a class="dropdown-item" href="javascript:;" onclick="edit_manual_punches('+empcodes+','+manl.punchid+');" style="padding-left: 0;padding-right: 0;"><i class="fa fa-pencil m-r-5"></i></a>'; 
                                mHtml += '&nbsp;<a class="dropdown-item"  href="javascript:;" onclick="delete_manual_punches('+empcodes+','+manl.punchid+');"><i class="fa fa-trash-o m-r-5"></i></a>';
                                mHtml += '</td>';
                                mHtml  += '</td>';
                                mHtml  += '</tr>';
                                i = i+1;
                                });
                              }

                              $("#empcodes").val('');
                              $("#cardnumber").val('');
                              $("#indates").val('');
                              $("#intimes").val('');
                              //window.location = usePath +"manualpunch"
                          }else{
                              
                               alert(resp.message);
                          }
                          $("#manuallpunchdetail").html(mHtml);

                 },
                 error: function () {
                      
                      $(".noaddmanulpunchesclass").removeClass("hidden").addClass("hidden");
                      $(".addmanulpunchesclass").removeClass("hidden");
                 },
                 cache: false
             });

}

 
    function get_employee_punchdt(empcode){
             var usePath  = $("#rootXPath").val();
             $("#manual_empname").val(empcode);
              $.ajax({
                     url: usePath + "manualpunch/ajax/insert_manual_punch",
                     type: 'POST',
                     data: {'machine_emp_detail':'Y','empcode':empcode},
                     async: false,
                     success: function (resp) {
                         if ( resp.status){
                             $("#cardnumber").val(resp.data.ecd_card_number);
                         }else{
                            $("#cardnumber").val('');
                         }
                 },
                 error: function () {
                     
                 },
                 cache: false
             });
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

    $(document).on("click","input[name='indates']",function(){
    $(this).datepick({ dateFormat: "dd/M/yyyy"}).datepick("show");
    });

    $(document).on("click","input[name='trnFromDate']",function(){
      $(this).datepick({ dateFormat: "dd/m/yyyy"}).datepick("show");
    });

    $(document).on("click","input[name='trnFromDate']",function(){
      $(this).datepick({ dateFormat: "dd/m/yyyy"}).datepick("show");
    });