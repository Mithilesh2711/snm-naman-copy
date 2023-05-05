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

function generate_serial_numbers(id){
    var prefix = $.trim( $("#sn_prefix_"+id).val() );
    var lenth  = $.trim( $("#sn_length_"+id).val() );
    var type   = $.trim( $("#sn_type_"+id).val() );
    var sufix  = ""
    var comval = ""
    if( type == 'Sewadar'){
        if( prefix !='' && lenth >0 ){
              sufix =  generate_serial_number(lenth)
              comval = prefix+sufix+"1"
               $("#sn_series_sample_"+id).val(comval);
               $("#snseries_sample_"+id).html(comval);
        }
    }else if( type =='Department'){
        if( prefix !='' && lenth >0 ){
              sufix =  generate_serial_number(lenth)
              comval = prefix+sufix+"1"
              $("#sn_series_sample_"+id).val(comval);
               $("#snseries_sample_"+id).html(comval);
        }
    }else if( type =='SubDepartment'){
        if( prefix !='' && lenth >0 ){
              sufix =  generate_serial_number(lenth)
              comval = prefix+sufix+"1"
              $("#sn_series_sample_"+id).val(comval);
               $("#snseries_sample_"+id).html(comval);
        }
    }else if( type =='Designation'){
        if( prefix !='' && lenth >0 ){
              sufix =  generate_serial_number(lenth)
              comval = prefix+sufix+"1"
              $("#sn_series_sample_"+id).val(comval);
               $("#snseries_sample_"+id).html(comval);
        }
    }else if( type =='Qualification'){
        if( prefix !='' && lenth >0 ){
              sufix =  generate_serial_number(lenth)
              comval = prefix+sufix+"1"
              $("#sn_series_sample_"+id).val(comval);
               $("#snseries_sample_"+id).html(comval);
        }
    }else if( type =='Responsibility'){
        if( prefix !='' && lenth >0 ){
              sufix =  generate_serial_number(lenth)
              comval = prefix+sufix+"1"
              $("#sn_series_sample_"+id).val(comval);
               $("#snseries_sample_"+id).html(comval);
        }
    }else{
       if( prefix !='' && lenth >0 ){
              sufix =  generate_serial_number(lenth)
              comval = prefix+sufix+"1"
              $("#sn_series_sample_"+id).val(comval);
               $("#snseries_sample_"+id).html(comval);
        }
    }
    return comval
    //sn_series_sample_1
    //snseries_sample_1
}
function generate_serial_number(lgth){
    var chracters = ""
    for(var i =1;i<lgth;i++ ){
        chracters +="0"
    }
    return chracters
}
