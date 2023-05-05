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
 function check_email_validation(email,id){
     if (!ValidateEmail(email )) {
          alert("Invalid email address.");
          $("#"+id).val('');
          $("#"+id).focus();
      }else {
          
      }
 }
 function set_last_focus(id){
     $("#"+id).focus();
 }
 function exportDataToExcel(tabled, filename){
        var downloadurl;
        var fileType    = 'application/vnd.ms-excel';
         var tableSelect = document.getElementById(tabled);
         var dataHTML    = tableSelect.outerHTML.replace(/ /g, '%20');
         filename        = filename?filename+'.xls':'education_report_list.xls';
         downloadurl     = document.createElement("a");
         document.body.appendChild(downloadurl);

          if(navigator.msSaveOrOpenBlob){
                       var blob = new Blob(['\ufeff', dataHTML],{type:  fileType });
                       navigator.msSaveOrOpenBlob( blob, filename);
              }else
                {
                         downloadurl.href = 'data:' + fileType + ', ' + dataHTML;
                         downloadurl.download = filename;
                         downloadurl.click();
                }

}

 function process_search_sewadar(){
  var useroot = $("#userXRoot").val();
  $("form#myforms").attr("action",useroot+"education_report/search");
  $(".nomysearching").removeClass("hidden").addClass("hidden");
  $(".mysearching").removeClass("hidden");
  $("form#myforms").submit();
}

  $("#sewadar_fromdate").click(function() {
     $(this).datepick({ dateFormat: "dd/mm/yyyy" }).datepick("show");
  });

  $("#sewadar_uptodate").click(function() {
     $(this).datepick({ dateFormat: "dd/mm/yyyy" }).datepick("show");
  });
