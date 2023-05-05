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
function check_visibility_forms(){
    var tdsrpt = $.trim( $("input[name='tds_process_report']:checked").val() );
    if( tdsrpt == 'MONTH' ){
        $(".process_months").removeClass("hidden");
        $(".process_sewadaruser").removeClass("hidden").addClass("hidden"); 
        $("#hph_months").val('');
        $("#al_sewadarcode").val('');
        $("#alsewdarname").val('');
    }else if( tdsrpt == 'YEAR' ){
        $(".process_months").removeClass("hidden").addClass("hidden");
        $(".process_sewadaruser").removeClass("hidden").addClass("hidden");
        $("#hph_months").val('');
        $("#al_sewadarcode").val('');
        $("#alsewdarname").val('');
    }else if( tdsrpt == 'SEWADAR'){
        $("#hph_months").val('');
        $("#al_sewadarcode").val('');
        $(".process_months").removeClass("hidden").addClass("hidden");
        $(".process_sewadaruser").removeClass("hidden"); 
    }
}
function get_reset_tds_data(){
     $("#alsewdarname").val('');
    $("#process_month").val('');
    $("#process_year").val('');
    $("#process_deduction").val('');
    $("#al_sewadarcode").val('');
    $("#process_pan").val('');
    $("#process_tdslisted").html("<tr><td colspan='4'>No record(s) found.</td></tr>");
}

function print_tds_register(){
    var usePath      = $.trim( $("#rootXPath").val() );
    var years        = $.trim( $("#hph_years").val() );
    var months       = $.trim( $("#hph_months").val() );    
    var sewacode     = $.trim( $("#al_sewadarcode").val() );
    var types        = "" 
    if ( $("input[name='tds_process_report']").is(":checked") ) {
        types =  $("input[name='tds_process_report']:checked").val();
    }  
    if( types == 'YEAR'){
        if(years == ''){
            alert("Financial year is required");
            return false;

        }
    }else if( types == 'MONTH' ){
        if( months == '' ){
            alert("Month is required");
            return false;
        }
    }else if( types == 'SEWADAR' ){
        if( sewacode == '' ){
            alert("Sewadar is required");
            return false;
        }else if(years == ''){
            alert("Financial year is required");
            return false;

        }  
    }
    
   
     $.ajax({
                 url: usePath+"accounts/ajax_process",
                 type: 'POST',
                 data: {'finayear': years,'months':months,'sewacode':sewacode,'tds_type':types,'identity':'TDRPT'},
                 async: false,
                 success: function (resp) {
                     
                      if( resp.status ){
                        window.open(usePath+resp.printurl,"_blank")
                        
                       }else{
                         alert("No record(s) found.");
                         return false;
                       }
                      
                 },
                 error: function () {

                 },
                 cache: false
         });


}


function get_selected_accounts_listed(){
	
            var usePath  =  $.trim( $("#rootXPath").val() );
            var sewcode  =  $.trim( $("#alsewdarname").val() );
            var finayear =  $.trim( $("#financial_yearname").val() );
            var months   =  $.trim( $("#process_month").val() );
            var proyears =  $.trim( $("#process_year").val() );
         
            if( sewcode == '' ){                
                return false;
            }else if( finayear == '' ){
               return false;
            }
			
                $.ajax({
                             url: usePath+"accounts/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'finayear':finayear,'months':months,'proyears':proyears,'identity':'TDS'},
                             async: false,
                             success: function (resp) {
                                 var htmls = ''
                                 if(resp.status){
                                     var sdata = resp.data;
                                     var ndata = resp.newdata;
                                     var i = 1;
                                     $("#process_deduction").val(ndata.totaltdsdeduct);
                                     $.each(sdata,function(key,tds){
                                     var myma      =  tds.myma >0 ? parseFloat(tds.myma).toFixed(2): 0
                                     var tdss      =  tds.totaltdsdeduct >0 ? parseFloat(tds.totaltdsdeduct).toFixed(2) : 0
                                     var othded    =  tds.otherdeduction >0 ? parseFloat(tds.otherdeduction).toFixed(2) : 0
                                     var netpay    =  tds.netpay >0 ? parseFloat(tds.netpay).toFixed(2): 0
                                     var nenetpmts = 0
                                     htmls += '<tr class="new_tds_calculation">';
                                     htmls += '<input type="hidden" id="myma'+i+'" value="'+myma+'">';
                                     htmls += '<input type="hidden" id="mytds'+i+'" value="'+tdss+'">';
                                     htmls += '<input type="hidden" id="myothded'+i+'" value="'+othded+'">';
                                     htmls += '<input type="hidden" id="mynetpmt'+i+'" value="'+netpay+'">';

                                     htmls += '<td   class="process_visibility_2 col-md-2">'+tds.MonthName+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-1">'+tds.pm_payyear+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-2">'+myma+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-2">'+tdss+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-2">'+othded+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-2">'+netpay+'</td>';
                                     htmls += '</tr>';
                                     i++;
                                     });
                                      $("#process_tdslisted").html(htmls);
                                 }else{
                                    $("#process_deduction").val('');
                                     $("#process_tdslisted").html("<tr><td colspan='4'>No record(s) found.</td></tr>");
                                 }

                                 setTimeout(function(){ calculate_total();},500);
                                 

                             },
                             error: function () {

                             },
                             cache: false
             });

}
function reset_all_filled_data(){
    //$("#alsewdarname").val('');
    //$("#process_month").val('');
    //$("#process_year").val('');
    $("#process_deduction").val('');
    //$("#al_sewadarcode").val('');
}
function calculate_total(){
    var i = 1;
    var myma = 0
    var mytds = 0
    var myothded = 0
    var mynetpmt = 0
    $(".new_tds_calculation input").each(function(){
        var mymas     = $.trim( $("#myma"+i).val() ) !='' ? $.trim( $("#myma"+i).val() ) : 0;
        var mytdss    = $.trim( $("#mytds"+i).val() ) !='' ? $.trim( $("#mytds"+i).val() ) : 0;
        var myothdeds = $.trim( $("#myothded"+i).val() ) !='' ? $.trim( $("#myothded"+i).val() ) : 0;
        var mynetpmts = $.trim( $("#mynetpmt"+i).val() ) !='' ? $.trim( $("#mynetpmt"+i).val() ) : 0;
        myma      = eval(myma)+eval(mymas)
        mytds     = eval(mytds)+eval(mytdss);
        myothded  = eval(myothded)+eval(myothdeds);
        mynetpmt  = eval(mynetpmt)+eval(mynetpmts)
        i++;
    });
    myma     = parseFloat(myma).toFixed(2);
    mytds    = parseFloat(mytds).toFixed(2);
    myothded = parseFloat(myothded).toFixed(2);
    mynetpmt = parseFloat(mynetpmt).toFixed(2);
    
    $("#total_maamount").val(myma);
    $("#total_tds_deducted").val(mytds);
    $("#total_otherdeduct").val(myothded);
    $("#total_netpay").val(mynetpmt);
    
}
function process_tds_data(){
            var usePath  =  $.trim( $("#rootXPath").val() );
            var sewcode  =  $.trim( $("#alsewdarname").val() );
            var finayear =  $.trim( $("#financial_yearname").val() );
            var months   =  $.trim( $("#process_month").val() );
            var proyears =  $.trim( $("#process_year").val() );
            var deduct   =  $.trim( $("#process_deduction").val() );
            if( sewcode == '' ){
                alert("Sewadar is required");
                $("#alsewdarname").focus();
                return false;
            }else if( months == '' ){
                alert("Month is required");
                $("#process_month").focus();
                return false;
            }else if( proyears == '' ){
                alert("Year is required");
                $("#process_year").focus();
                return false;
            }else if( deduct == '' ){
                alert("Tds deduction is required");
                $("#process_deduction").focus();
                return false;
            }
            
            $.ajax({
                             url: usePath+"accounts/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'finayear':finayear,'months':months,'proyears':proyears,'deduct':deduct,'identity':'Y'},
                             async: false,
                             success: function (resp) {
                                 var htmls = ''
                                 if(resp.status){
                                     var sdata = resp.data;
                                     var i = 1;
                                     $.each(sdata,function(key,tds){
                                     var myma      =  tds.myma >0 ? parseFloat(tds.myma).toFixed(2): 0
                                     var tdss      =  tds.totaltdsdeduct >0 ? parseFloat(tds.totaltdsdeduct).toFixed(2) : 0
                                     var othded    =  tds.otherdeduction >0 ? parseFloat(tds.otherdeduction).toFixed(2) : 0
                                     var netpay    =  tds.netpay >0 ? parseFloat(tds.netpay).toFixed(2): 0
                                     var nenetpmts = 0
                                     htmls += '<tr   class="new_tds_calculation">';
                                     htmls += '<input type="hidden" id="myma'+i+'" value="'+myma+'">';
                                     htmls += '<input type="hidden" id="mytds'+i+'" value="'+tdss+'">';
                                     htmls += '<input type="hidden" id="myothded'+i+'" value="'+othded+'">';
                                     htmls += '<input type="hidden" id="mynetpmt'+i+'" value="'+netpay+'">';
                                     
                                     htmls += '<td   class="process_visibility_2 col-md-2">'+tds.MonthName+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-1">'+tds.pm_payyear+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-2">'+myma+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-2">'+tdss+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-2">'+othded+'</td>';
                                     htmls += '<td   class="process_visibility_2 col-md-2">'+netpay+'</td>';
                                     htmls += '</tr>';
                                     i++;
                                     });
                                      $("#process_tdslisted").html(htmls);
                                 }else{
                                     $("#process_tdslisted").html("<tr><td colspan='4'>No record(s) found.</td></tr>");
                                 }

                                 setTimeout(function(){ calculate_total();},500);
                                 setTimeout(function(){ reset_all_filled_data();},500);

                             },
                             error: function () {
                                    
                             },
                             cache: false
             });
            
}

function fill_from_sewadar_listed(types){
            var usePath       = $.trim( $("#rootXPath").val() );
            var requestyears  = $.trim( $("#requestyears").val() );
            var requestmonths = $.trim( $("#requestmonths").val() );
            $("#process_month").val(requestmonths);
            $("#process_year").val(requestyears);
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
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);

                                     }else if( types == 'sewadar'){
                                         $("#al_sewadarcode").val(sewcode);
                                        $(".my_dpeartmentname").html(resp.data[0].department);
                                        $(".myjoining_dated").html(resp.data[0].joiningdate);
                                        $(".mytotalworking_year").html(resp.data[0].sewduration);
                                        $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);
                                     }
									 $("#process_pan").val(resp.sewdarpin);
                                 }else{
                                        $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
										$("#process_pan").val('');
                                        alert("No record(s) found.");
                                 }

                                 setTimeout(function(){ get_selected_accounts_listed();},500);
                             },
                             error: function () {
                                       $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
                             },
                             cache: false
                 });
}