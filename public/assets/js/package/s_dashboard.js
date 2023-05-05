   var slideIndex = 1;
   var slideIndex1=1
showSlides(slideIndex);
showSlides1(slideIndex1);
function plusSlides(n) {
  showSlides(slideIndex += n);
}

function currentSlide(n) {
  showSlides(slideIndex = n);
}
function plusSlides1(n) {
  showSlides(slideIndex1 += n);
}

function currentSlide1(n) {
  showSlides(slideIndex1 = n);
}
function showSlides(n) {
  var i;
  var slides = document.getElementsByClassName("mySlides");
  var dots = document.getElementsByClassName("dot");
  if (n > slides.length) {slideIndex = 1}    
  if (n < 1) {slideIndex = slides.length}
  for (i = 0; i < slides.length; i++) {
      slides[i].style.display = "none";  
  }
  for (i = 0; i < dots.length; i++) {
      dots[i].className = dots[i].className.replace(" active", "");
  }
  slides[slideIndex-1].style.display = "block";  
  dots[slideIndex-1].className += " active";
}
function showSlides1(n) {
  var i;
  var slides = document.getElementsByClassName("mySlides1");
  var dots = document.getElementsByClassName("dot");
  if (n > slides.length) {slideIndex1 = 1}    
  if (n < 1) {slideIndex1 = slides.length}
  for (i = 0; i < slides.length; i++) {
      slides[i].style.display = "none";  
  }
  for (i = 0; i < dots.length; i++) {
      dots[i].className = dots[i].className.replace(" active", "");
  }
  slides[slideIndex1-1].style.display = "block";  
  dots[slideIndex1-1].className += " active";
}
window.onload= function () {
 setInterval(function(){ 
     plusSlides(1);
     plusSlides1(1);
 }, 3000);
 }

 function process_restoreses_data(){
    var usePath  = $.trim( $("#globalrootaccesspath").val() );   
    $.ajax({
                  url: usePath+"new_dashboard/ajax_process",
                  type: 'POST',
                  data: {'identity':'SWDABS'},
                  async: false,
                  success: function (resp) {                                     
                    if(resp.status ){   
                    // execute message if required                      
                    }                   
                    
                  },
                  error: function () {

                  },
                  cache: false
      });
}
