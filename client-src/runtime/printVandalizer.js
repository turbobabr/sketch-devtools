(function(){
    return function(obj) {

        function isDevToolsInitialized() {
            return NSClassFromString("SketchConsole")!=null;
        }

        try {
            throw new Error("console.log");
        } catch(error) {
            if(isDevToolsInitialized()) {
                var stack=error.stack.split("\n");

                function parseStackCall(call) {
                    var parts=call.split("@");
                    var fn=(parts.length<2) ? "closure" : parts[0];
                    parts=parts[(parts.length<2 ? 0 : 1)].split(":");

                    return {
                        fn: fn,
                        file: parts[0],
                        line: parts[1],
                        column: parts[2]
                    };
                }

                function findLogCall() {
                    for(var i=0;i<stack.length;i++) {
                        var call=stack[i];

                        /*
                        if(call.indexOf("log@")>-1) {
                            if(i+1>=stack.length) {
                                return null;
                            }

                            return parseStackCall(stack[i+1]);
                        }
                        */

                        if(call=="") {
                            return parseStackCall(stack[i+1]);
                        }
                    }

                    return null;
                }

                var logCall=findLogCall();
                if(logCall!=null) {
                    // print(obj);
                    // print(logCall);
                    // [SketchConsole extendedPrint:logCall sourceScript:coscript.printController().script()];

                    // coscript.print("<H2><span class='label label-danger'>Меня подменили! :)</span></H2>")
                    // SketchConsole.extendedPrint_sourceScript_(logCall,coscript.printController().script());

                    SketchConsole.extendedPrint_info_sourceScript_(obj,logCall,coscript.printController().script());

                    // Mirror log to stderr.
                    coscript.print(obj);



                } else {
                    // No log call?
                    coscript.print(obj);

                }

            } else {
                // Print object without console.
                coscript.print(obj);
            }
        }
    };
})();




