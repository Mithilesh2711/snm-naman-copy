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

function filter_city(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"city/search");   
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function get_process_calculation(types){
    var usePath       = $.trim( $("#rootXPath").val() );
    var departcode    = $.trim( $("#al_depcode").val() );
    var sewacode  = ""
    if( types == 'code'){
        sewacode = $.trim( $("#al_sewadarcode").val() );
    }else if( types == 'sewadar'){
        sewacode = $.trim( $("#alsewdarname").val() );
    }
   
    if( sewacode !='' ){

            $.ajax({
                    url: usePath+"calculate_salary/ajax_process",
                    type: 'POST',
                    data: {'departcode': departcode,'sewacode':sewacode,'sewacategory':'','identity':'Y'},
                    async: false,
                    success: function (resp) {
                        $(".processed").removeClass("hidden");
                        $(".noprocessed").removeClass("hidden").addClass("hidden");
                        setTimeout(function(){ check_salary_recalculation(''); },500);
                        // alert(resp.message);
                        // if(resp.status){

                        // }
                    },
                    error: function () {
                        setTimeout(function(){ check_salary_recalculation(''); },500);
                        $(".processed").removeClass("hidden");
                        $(".noprocessed").removeClass("hidden").addClass("hidden");
                    },
                    cache: false
        });
        
        
    }


}


function get_salary_existing_detail(){
            var usePath    = $.trim( $("#rootXPath").val() );
            var sewcode     = $.trim( $("#ct_statecode").val() );
                
             $.ajax({
                             url: usePath+"monthly_advice/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'identity':'Y'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '<option value="">-Select-</option>';
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.dts_districtcode+'">'+leds.dts_districtcode+'</option>';
                                         i++;
                                    });
                              }
                              $("#ct_districtcode").html(mhtml);
                             },
                             error: function () {
                                 
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
            //setTimeout(function(){get_process_calculation(types); },500);
            setTimeout(function(){calculate_list_detailon_load(types); },500);
             
}

function calculate_list_detailon_load(types){
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
        data: {'sewcode': sewcode,'monthly_advance':'advance','identity':'SWCD'},
        async: false,
        success: function (resp) {
            if(resp.status){
                if( types == 'code'){
                   $("#alsewdarname").val(sewcode);
                   $(".my_dpeartmentname").html(resp.data[0].department);
                   $(".myjoining_dated").html(resp.data[0].joiningdate);
                   $(".mytotalworking_year").html(resp.data[0].sewduration);
                   $(".mytotalout_standing").html(resp.data[0].outstatnding);
                   $("#myjoining_dated").val(resp.data[0].joiningdate);
                   $("#sewadar_category").val(resp.data[0].sw_catgeory);
                }else if( types == 'sewadar'){
                   $("#al_sewadarcode").val(sewcode);
                   $(".my_dpeartmentname").html(resp.data[0].department);
                   $(".myjoining_dated").html(resp.data[0].joiningdate);
                   $(".mytotalworking_year").html(resp.data[0].sewduration);
                   $(".mytotalout_standing").html(resp.data[0].outstatnding);
                   $("#myjoining_dated").val(resp.data[0].joiningdate);
                   $("#sewadar_category").val(resp.data[0].sw_catgeory);
                }
                $("#pm_ded_repaidloan").val(0);
                $("#pm_ded_repaidadvance").val(resp.advamounts);
                
            }else{
                   $(".my_dpeartmentname").html('');
                   $(".myjoining_dated").html('');
                   $(".mytotalworking_year").html('');
                   $(".mytotalout_standing").html('');
                   $("#myjoining_dated").val('');
                   $("#sewadar_category").val('');
                   $("#pm_ded_repaidloan").val('');
                   $("#pm_ded_repaidadvance").val('');
                   alert("No record(s) found.");
                  
            }
            if( resp.monthslay !='' ){
                var mdsdata = resp.monthslay
               $("#working_days").val(mdsdata[0].pm_workingday);
               $("#paid_leaves").val(mdsdata[0].pm_paidleave);
               $("#weekly_off").val(mdsdata[0].weekoff);
               $("#no_holidays").val(mdsdata[0].holdays);
               $("#paid_days").val(mdsdata[0].pm_paydays);
               $("#absent_days").val(mdsdata[0].myabsent);
               $("#total_days").val(mdsdata[0].monthdays);
               //alert(mdsdata[0].myabsent)
               //$("#pm_ded_repaidadvance").val(mdsdata[0].pm_ded_repaidadvance);
               //$("#pm_ded_repaidloan").val(mdsdata[0].pm_ded_repaidloan);
               $("#current_work_days").val(mdsdata[0].pm_workingday);
               $("#current_paid_leave").val(mdsdata[0].pm_paidleave);
               $("#hph_months").val(mdsdata[0].pm_areaprvmonths);
               $("#hph_years").val(mdsdata[0].pm_areaprvyears);
               $("#no_days").val(mdsdata[0].pm_areardays);
               $("#pm_fixarear").val(mdsdata[0].pm_fixarear);

               $("#pm_ded_licemployee").val(mdsdata[0].pm_ded_licemployee);
               $("#pm_ded_healthsewdarpay").val(mdsdata[0].pm_ded_healthsewdarpay);
               $("#pm_ded_electricamount").val(mdsdata[0].pm_ded_electricamount);
               $("#pm_dedaccomodatamount").val(mdsdata[0].pm_dedaccomodatamount);
               $("#pm_incometaxamount").val(mdsdata[0].pm_totaltds);

               $("#pm_allowancefirst").val(mdsdata[0].pm_allowancefirst);
               $("#pm_allowanremarkfirst").val(mdsdata[0].pm_allowanremarkfirst);
               $("#pm_allowancesecond").val(mdsdata[0].pm_allowancesecond);
               $("#pm_allowanceremksecond").val(mdsdata[0].pm_allowanceremksecond);

               $("#pm_dedfirst").val(mdsdata[0].pm_dedfirst);
               $("#pm_dedremarkfirst").val(mdsdata[0].pm_dedremarkfirst);
               $("#pm_dedsecond").val(mdsdata[0].pm_dedsecond);
               $("#pm_dedremarksecond").val(mdsdata[0].pm_dedremarksecond);
               $("#pm_arearremarks").val(mdsdata[0].pm_arearremarks);
               if( mdsdata[0].myholds == 'Y'){
                 $("#pm_hold").prop("checked",true);
               }else{
                  $("#pm_hold").prop("checked",false);
               }
               
               
               
               

            }else{
               $("#pm_hold").prop("checked",false);
               $("#working_days").val('');
               $("#paid_leaves").val('');
               $("#weekly_off").val('');
               $("#no_holidays").val('');
               $("#paid_days").val('');
               $("#absent_days").val('');
               $("#total_days").val('');
               $("#pm_ded_repaidadvance").val('');
               $("#pm_ded_repaidloan").val('');
               $("#current_work_days").val('');
               $("#current_paid_leave").val('');
               $("#hph_months").val('');
               $("#hph_years").val('');
               $("#no_days").val('');
               $("#pm_fixarear").val('');
               $("#pm_ded_licemployee").val('');
               $("#pm_ded_healthsewdarpay").val('');
               $("#pm_ded_electricamount").val('');
               $("#pm_dedaccomodatamount").val('');
               $("#pm_incometaxamount").val('');

               $("#pm_allowancefirst").val('');
               $("#pm_allowanremarkfirst").val('');
               $("#pm_allowancesecond").val('');
               $("#pm_allowanceremksecond").val('');
               $("#pm_arearremarks").val('');
               $("#pm_dedfirst").val('');
               $("#pm_dedremarkfirst").val('');
               $("#pm_dedsecond").val('');
               $("#pm_dedremarksecond").val('');
            }


        },
        error: function () {
                   $(".my_dpeartmentname").html('');
                   $(".myjoining_dated").html('');
                   $(".mytotalworking_year").html('');
                   $(".mytotalout_standing").html('');
                   $("#myjoining_dated").val('');
                   $("#working_days").val('');
                   $("#paid_leaves").val('');
                   $("#weekly_off").val('');
                   $("#no_holidays").val('');
                   $("#paid_days").val('');
                   $("#absent_days").val('');
                   $("#total_days").val('');
                   $("#pm_ded_repaidadvance").val('');
                   $("#pm_ded_repaidloan").val('');
                   $("#current_work_days").val('');
                   $("#current_paid_leave").val('');
                   $("#hph_months").val('');
                   $("#hph_years").val('');
                   $("#no_days").val('');
                   $("#pm_fixarear").val('');
                   $("#sewadar_category").val('');
                   $("#pm_ded_licemployee").val('');
                   $("#pm_ded_healthsewdarpay").val('');
                   $("#pm_ded_electricamount").val('');
                   $("#pm_dedaccomodatamount").val('');
                   $("#pm_incometaxamount").val('');
                   $("#pm_allowancefirst").val('');
                   $("#pm_allowanremarkfirst").val('');
                   $("#pm_allowancesecond").val('');
                   $("#pm_allowanceremksecond").val('');
                   $("#pm_dedfirst").val('');
                   $("#pm_dedremarkfirst").val('');
                   $("#pm_dedsecond").val('');
                   $("#pm_dedremarksecond").val('');
                   $("#pm_arearremarks").val('');
        },
        cache: false
    });   
}

function check_years_months(){
    var months  = $.trim( $("#hph_months").val() );
    var years   = $.trim( $("#hph_years").val() );
    var saly_m  = $.trim( $("#slary_month").val() );
    var saly_y  = $.trim( $("#slary_years").val() );
    if( months !='' && years != ''  && saly_m != '' && saly_y != '' ){
            if( months == saly_m && years == saly_y ){
                alert("Same month and year could not be process.");
                $("#hph_months").val('');
                $("#hph_years").val('');
                return false;
            }
    }
    
}
function check_salary_recalculation(vls){
    
        var working_days  = $.trim( $("#working_days").val()) != '' ? $("#working_days").val() : 0;
        var paid_leaves   = $.trim( $("#paid_leaves").val()) != '' ?  $("#paid_leaves").val() : 0;
        var weekly_off    = $.trim( $("#weekly_off").val() ) != '' ?  $("#weekly_off").val() : 0;
        var no_holidays   = $.trim( $("#no_holidays").val() ) != '' ?  $("#no_holidays").val() : 0;
        var paid_days     = $.trim( $("#paid_days").val() ) != '' ? $("#paid_days").val() : 0  ;
        var absent_days   = $.trim( $("#absent_days").val() ) != '' ? $("#absent_days").val() : 0;
        var total_days    = $.trim( $("#total_days").val() ) != '' ? $("#total_days").val() : 0;
        var curwdays      = $.trim( $("#current_work_days").val() ) !=''  ? $.trim( $("#current_work_days").val() ) : 0;
        var curleave      = $.trim( $("#current_paid_leave").val() ) !='' ? $.trim( $("#current_paid_leave").val() ) : 0;
        var sumpaid       = eval(working_days)+eval(paid_leaves)+eval(weekly_off)+eval(no_holidays);
       
        if( sumpaid >total_days ){
            alert("Paid days should not be greater than total days.");
            $("#working_days").val(curwdays);
            $("#paid_leaves").val(curleave);
            return false;
        }else{
            absent_days = eval(total_days)-eval(sumpaid);
            paid_days   = sumpaid
        }
        $("#paid_days").val(paid_days);
        $("#absent_days").val(absent_days);
}

function process_save_checks(){
    
}