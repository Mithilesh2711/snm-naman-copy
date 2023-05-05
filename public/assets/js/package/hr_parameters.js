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

function filter_hrparameter(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"hr_parameters/search");
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
function delete_common_data(types,id){
     var usePath       = $.trim( $("#rootXPath").val() );
    var formData      = new FormData();    
    var rangemid      = id;
    if( rangemid == '' ){
        alert("Please select first delete data.");        
        return false;
    }
    formData.append("identity", "DELT");
    formData.append("types", types);   
    formData.append("mid", rangemid);
   if( confirm("Are you sure want to delete this?")){
        $.ajax({
                     url: usePath+"hr_parameters/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         var vhtml = '';
                         if( resp.status){
                              var sdata = resp.data
                              var ntype = "'"+types+"'"
                              if( types == 'RNG' ){
                                          if(sdata.length >0 ){
                                                 $.each(sdata,function(key,leds){
                                                      var rngfrm  = leds.hpr_rangefrom; // ? parseFloat(leds.hpr_rangefrom).toFixed(2) :  0
                                                      var rangeto = leds.hpr_rangeto; //? parseFloat(leds.hpr_rangeto).toFixed(2) :  0
                                                      var rates1  = leds.hpr_rate1; //? parseFloat(leds.hpr_rate1).toFixed(2) :  0
                                                      var rates2  = leds.hpr_rate2; // ? parseFloat(leds.hpr_rate2).toFixed(2) :  0
                                                      var rngfrms = "'"+rngfrm+"'"
                                                      var rangetos = "'"+rangeto+"'"
                                                      var rates1s  = "'"+rates1+"'"
                                                      var rates2s  = "'"+rates2+"'"
                                                      var nids     = "'"+leds.id+"'"
                                                        vhtml +='<tr>';
                                                        vhtml +='<td id="center">'+rngfrm+'</td>';
                                                        vhtml +='<td  id="center">'+rangeto+'</td>';
                                                        vhtml +='<td id="center">'+rates1+'</td>';
                                                        vhtml +='<td id="center">'+rates2+'</td>';
                                                        vhtml +='<td><a href="javascript:" id="center" onclick="get_range_parameters('+nids+','+rngfrms+','+rangetos+','+rates1s+','+rates2s+')"><i class="fa fa-pencil m-r-5"></i></a></td>';
                                                        vhtml +='<td><a href="javascript:" id="center" onclick="delete_common_data('+ntype+','+nids+')"><i class="fa fa-trash-o m-r-5"></i></a></td>';
                                                        vhtml +='</tr>';
                                                 });
                                            }
                                            $("#parameterranges").html(vhtml);
                                            setTimeout(function(){ reset_range_parameters();},500);
                              }else if( types == 'AVL'  ){
                                     
                                      if(sdata.length >0 ){
                                             $.each(sdata,function(key,leds){
                                                      var rngfrm   = leds.hpa_value ? parseFloat(leds.hpa_value).toFixed(2) :  0
                                                      var rngupto  = leds.hpa_value ? parseFloat(leds.hpa_value).toFixed(2) :  0
                                                      var rngfrms  = "'"+rngfrm+"'"
                                                      var rnguptos = "'"+rngupto+"'"
                                                      var nids     = "'"+leds.id+"'"
                                                      var htptpe   = "'"+leds.hpa_types+"'"

                                                        vhtml +='<tr>';
                                                        vhtml +='<td  id="center">'+leds.hracctype+'</td>';
                                                        vhtml +='<td  id="center">'+rngfrm+'</td>';  
                                                        vhtml +='<td  id="center">'+rngupto+'</td>';                                                        
                                                        vhtml +='<td><a href="javascript:" id="center" onclick="edit_values_parameters('+nids+','+rngfrms+','+htptpe+','+rnguptos+')"><i class="fa fa-pencil m-r-5"></i></a></td>';
                                                        vhtml +='<td><a href="javascript:" id="center" onclick="delete_common_data('+ntype+','+nids+')"><i class="fa fa-trash-o m-r-5"></i></a></td>';
                                                        vhtml +='</tr>';
                                             });

                                      }
                                    $("#myhrparametervalue").html(vhtml);
                                  setTimeout(function(){ reset_values_parameters();},500);
                              }
                                alert(resp.message);
                         }else{
                              alert(resp.message);
                         }
                         
                         
                     },
                     error: function () {

                     },
                     cache: false
             });

   }
}
function get_range_parameters(id,rangefrm,rangeto,rate1,rate2){
        $("#hpr_rangefrom").val(rangefrm);
        $("#hpr_rangeto").val(rangeto);
        $("#hpr_rate1").val(rate1);
        $("#hpr_rate2").val(rate2);
        $("#rangemid").val(id);
}

function reset_range_parameters(){
        $("#hpr_rangefrom").val('');
        $("#hpr_rangeto").val('');
        $("#hpr_rate1").val('');
        $("#hpr_rate2").val('');
        $("#rangemid").val('');
        $("#process_rangesave").show();
}
function add_range_hrparameters(){
    var usePath       = $.trim( $("#rootXPath").val() );
    var formData      = new FormData();
    var hpr_rangefrom = $.trim( $("#hpr_rangefrom").val() );
    var hpr_rangeto   = $.trim( $("#hpr_rangeto").val() );
    var hpr_rate1     = $.trim( $("#hpr_rate1").val() );
    var hpr_rate2     = $.trim( $("#hpr_rate2").val() );
    var rangemid      = $.trim( $("#rangemid").val() );
    if( hpr_rangefrom == ''){
        alert("Range from is required.");
        $("#hpr_rangefrom").focus();
        return false;
    }else if( hpr_rangeto == ''){
        alert("Range to is required.");
        $("#hpr_rangeto").focus();
        return false;
    }
    formData.append("identity", "Y");
    formData.append("hpr_rangefrom", hpr_rangefrom);
    formData.append("hpr_rangeto", hpr_rangeto);
    formData.append("hpr_rate1", hpr_rate1);
    formData.append("hpr_rate2", hpr_rate2);
    formData.append("mid", rangemid);
    
    $("#process_rangesave").hide();
        $.ajax({
                     url: usePath+"hr_parameters/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         var vhtml = '';
                         if( resp.status){                             
                              var sdata = resp.data
                              var ntype = "'RNG'"
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                          var rngfrm  = leds.hpr_rangefrom ? leds.hpr_rangefrom :  0
                                          var rangeto = leds.hpr_rangeto ? leds.hpr_rangeto :  0
                                          var rates1  = leds.hpr_rate1 ? parseFloat(leds.hpr_rate1).toFixed(2) :  0
                                          var rates2  = leds.hpr_rate2 ? parseFloat(leds.hpr_rate2).toFixed(2) :  0
                                          var rngfrms = "'"+rngfrm+"'"
                                          var rangetos = "'"+rangeto+"'"
                                          var rates1s  = "'"+rates1+"'"
                                          var rates2s  = "'"+rates2+"'"
                                          var nids     = "'"+leds.id+"'"
                                            vhtml +='<tr>';
                                            vhtml +='<td id="center">'+rngfrm+'</td>';
                                            vhtml +='<td  id="center">'+rangeto+'</td>';
                                            vhtml +='<td id="center">'+rates1+'</td>';
                                            vhtml +='<td id="center">'+rates2+'</td>';
                                            vhtml +='<td><a href="javascript:" id="center" onclick="get_range_parameters('+nids+','+rngfrms+','+rangetos+','+rates1s+','+rates2s+')"><i class="fa fa-pencil m-r-5"></i></a></td>';
                                            vhtml +='<td><a href="javascript:" id="center" onclick="delete_common_data('+ntype+','+nids+')"><i class="fa fa-trash-o m-r-5"></i></a></td>';
                                            vhtml +='</tr>';
                                     });

                              }
                                alert(resp.message);
                         }else{                             
                              alert(resp.message);
                         }
                         $("#parameterranges").html(vhtml);
                         setTimeout(function(){ reset_range_parameters();},500);
                     },
                     error: function () {
                       
                     },
                     cache: false
             });
    
}
function edit_values_parameters(aid,value,type,rates){
        $("#hpa_value").val(value);
        $("#hpa_rates").val(rates);
        $("#hpa_types").val(type);
        $("#rangemid").val(aid);
}

function reset_values_parameters(){
        $("#hpa_value").val('');
        $("#hpa_types").val('');
        $("#aid").val('');
        $("#hpa_rates").val('');
        $("#process_hrvalues").show();
}

function add_hrparameter_values(){
    
    var usePath       = $.trim( $("#rootXPath").val() );
    var formData      = new FormData();
    var hpa_value     = $.trim( $("#hpa_value").val() );
    var hpa_rates     = $.trim( $("#hpa_rates").val() );
    var hpa_types     = $.trim( $("#hpa_types").val() );
    var mid           = $.trim( $("#rangemid").val() );
    if( hpa_types == ''){
        alert("Accomodation type is required.");
        $("#hpa_types").focus();
        return false;
    }else if( hpa_value == ''){
        alert("Value is required.");
        $("#hpa_value").focus();
        return false;
    }
    formData.append("identity", "HVL");
    formData.append("hpa_types", hpa_types);
    formData.append("hpa_value", hpa_value); 
    formData.append("hpa_rates", hpa_rates);      
    formData.append("mid", mid);
    $("#process_hrvalues").hide();
        $.ajax({
                     url: usePath+"hr_parameters/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         var vhtml = '';
                         if( resp.status){
                              var sdata = resp.data
                              var ntype = "'AVL'"
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                              var rngfrm   = leds.hpa_value ? parseFloat(leds.hpa_value).toFixed(2) :  0
                                              var rngupto  = leds.hpa_rates ? parseFloat(leds.hpa_rates).toFixed(2) :  0
                                              var rngfrms  = "'"+rngfrm+"'"
                                              var rnguptos = "'"+rngupto+"'"
                                              var nids     = "'"+leds.id+"'"
                                              var htptpe   = "'"+leds.hpa_types+"'"
                                          
                                                vhtml +='<tr>';
                                                vhtml +='<td  id="center">'+leds.hracctype+'</td>';
                                                vhtml +='<td  id="center">'+rngfrm+'</td>';
                                                vhtml +='<td  id="center">'+rngupto+'</td>';                                               
                                                vhtml +='<td><a href="javascript:" id="center" onclick="edit_values_parameters('+nids+','+rngfrms+','+htptpe+','+rnguptos+')"><i class="fa fa-pencil m-r-5"></i></a></td>';
                                                vhtml +='<td><a href="javascript:" id="center" onclick="delete_common_data('+ntype+','+nids+')"><i class="fa fa-trash-o m-r-5"></i></a></td>';
                                                vhtml +='</tr>';
                                     });

                              }
                                alert(resp.message);
                         }else{
                              alert(resp.message);
                         }
                         $("#myhrparametervalue").html(vhtml);
                         setTimeout(function(){ reset_values_parameters();},500);
                     },
                     error: function () {

                     },
                     cache: false
             });
}
function reste_hide_hrparaneters(){
    $(".process_headparameter").show();
}
function add_hrparameter_header(){
    var usePath       = $.trim( $("#rootXPath").val() );
    var formData      = new FormData();
    var other_data    = $('form#myForms').serializeArray();
     formData.append("identity", "HRHD");
        $(".process_headparameter").hide();
        $.each(other_data,function(key,input){
            formData.append(input.name,input.value);
        });
        
        $.ajax({
                     url: usePath+"hr_parameters/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {                         
                            alert(resp.message);
                            setTimeout(function(){ reste_hide_hrparaneters();},500);
                     },
                     error: function () {
                        setTimeout(function(){ reste_hide_hrparaneters();},500);
                     },
                     cache: false
             });
}