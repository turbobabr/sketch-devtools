
(function(){
    for(var i=0;i<selection.count();i++) {
        var layer=selection[i];
        if(layer) {
            layer.style().fill().setColor([MSColor colorWithHex:"#DB524B" alpha:1]);
        }
    }

    print("It became RED! :)");
})();
