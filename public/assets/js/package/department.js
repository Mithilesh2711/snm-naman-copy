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
function filter_department(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"department/search");
    $("form#myforms").submit();
}

function check_dpeartment_coordinate(){
    var vls = $("input[name='cordinate']:checked").val();
    if( vls ){
        $(".cordinatevalue").removeClass("hidden");
    }else{
        $(".cordinatevalue").removeClass("hidden").addClass("hidden");
    }
}

function filter_sub_department(){
           var usePath     = $.trim( $("#userXRoot").val() );
            var subdepart  = $.trim( $("#searchdepartcode").val() );
             $.ajax({
                             url: usePath+"department/ajax_process",
                             type: 'POST',
                             data: {'subdepart': subdepart,'identity':'Y'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '';
                               var i = 1;
                              if(sdata.length >0 ){
                                 
                                     $.each(sdata,function(key,leds){
                                        var nrur   = usePath+"sub_department/"+leds.id+"/deletes"
                                        var newurl = "'"+nrur+"'"
                                        mhtml +='<tr>';
                                        mhtml +='<td>'+i+'</td>';
                                        mhtml +='<td>'+leds.departCode+'</td>';
                                        mhtml +='<td>'+leds.departDescription+'</td>';
                                        mhtml +='<td>'+leds.department+'</td>';
                                        mhtml +='<td class="text-right">';
                                        mhtml +='<div class="dropdown dropdown-action">';
                                        mhtml +='<a href="javascript:;" class="action-icon dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="material-icons">more_vert</i></a>';
                                        mhtml +='<div class="dropdown-menu dropdown-menu-right">';
                                        mhtml +='<a class="dropdown-item" href="'+usePath+'sub_department/add_sub_department/'+leds.id+'"><i class="fa fa-pencil m-r-5"></i> Edit</a>';
                                        mhtml +='<a class="dropdown-item" onclick="alertChecked('+newurl+');" href="javascript:;"><i class="fa fa-trash-o m-r-5"></i> Delete</a>';
                                        mhtml +='</div>';
                                        mhtml +='</div>';
                                        mhtml +='</td>';
                                        mhtml +='</tr>';
                                         i++;
                                    });
                              }
                              $("#myselectedsubdepartment").html(mhtml);
                             },
                             error: function () {

                             },
                             cache: false
                 });
}

function check_department_hidetrue(tbsname){
         var usePath    = $.trim( $("#rootXPath").val() );
        if( tbsname =='DPT'){
            $("#mydepartment").show();
            $("#mysubdepartment").hide();
        }else if( tbsname =='SDPT'){
            $("#mydepartment").hide();
            $("#mysubdepartment").show();
        }
          
            if( tbsname == 'DPT'){
               $("#basic-justified-tab1").removeClass("active").addClass("active");
               $("#basic-justified-tab2").removeClass("active");
            }else if( tbsname == 'SDPT'){
                $("#basic-justified-tab1").removeClass("active");
                $("#basic-justified-tab2").removeClass("active").addClass("active");
            }
             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'tabsname': tbsname,'identity':'DTBS'},
                             async: false,
                             success: function (resp) {
                                 if( resp.status){
                                     // exceute if required
                                 }

                             },
                             error: function () {

                             },
                             cache: false
                 });
}