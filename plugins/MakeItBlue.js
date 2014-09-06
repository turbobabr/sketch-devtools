#import 'lib.js'
(function(){
    for(var i=0;i<selection.count();i++) {
        var layer=selection[i];
        if(layer) {
            layer.style().fill().setColor([MSColor colorWithHex:"#3E8ACC" alpha:1]);
        }
    }

    print("It became BLUE! :)");
})();