var blueWords = new Set(
    ['cout','cin','endl','boolalpha','setprecision','size_t']
); 

var brownWords = new Set(
    ['std','iostream','iomanip','ostream','cstdlib','cstddef',
     'cassert','cmath','cstring','string','vector','utility',
     'algorithm','initializer_list']
); 

var unhighlighted = document.querySelectorAll('.n'); 
for(var i = 0; i < unhighlighted.length; i++) {
    var element = unhighlighted[i]; 
    if(blueWords.has(element.innerHTML)) {
        element.setAttribute("style", "color:#0000ff"); 
    } else if(brownWords.has(element.innerHTML)) {
        element.setAttribute("style", "color:#b5835a"); 
    } 
} 
