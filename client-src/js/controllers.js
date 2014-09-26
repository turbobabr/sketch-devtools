var phonecatApp = angular.module('SketchConsole', []);

phonecatApp.controller('SketchConsoleController', function ($scope,$http,$sce,$location,$anchorScroll,$compile) {
    $scope.items = [];

    // Initialize options object.
    if(angular.isUndefined($scope.options)) {
        $scope.options=JSON.parse(SketchDevTools.getConsoleOptions());
    }

    $scope.addErrorItem = function(type,message,filePath,line,errorLineContents,callStack) {

        var newItem={
            type: "error",
            error: {
                type: type,
                message: message,
                filePath: filePath,
                line: line,
                errorLineContents: errorLineContents,
                stack: JSON.parse(callStack)
            }
        };

        $scope.items.push(newItem);

    };

    $scope.addMochaErrorItem = function(contents,pluginName,pluginFilePath,pluginRootFolderPath) {

        var newItem={
            type: "mochaError",
            contents: contents,
            plugin: {
                name: pluginName,
                filePath: pluginFilePath,
                rootFolderPath: pluginRootFolderPath
            }
        };

        $scope.items.push(newItem);
    };

    $scope.addItem = function(contents,pluginName,pluginFilePath,pluginRootFolderPath) {

        var newItem={
            type: "print",
            contents: contents,
            plugin: {
                name: pluginName,
                filePath: pluginFilePath,
                rootFolderPath: pluginRootFolderPath
            }
        };

        $scope.items.push(newItem);
    };

    $scope.showLogo = function() {
        return $scope.items.length==0;
    };

    $scope.timestamp = function() {
        return moment().format("ddd, hA");
    };

    $scope.clear = function() {
        $scope.items=[];
    };

    $scope.showSettings = function() {
      console.log("SETTINGS!");
    };

    $scope.renderHtml = function(item) {

        if(item.type=="mochaError") {

            var template="<div class='bs-callout bs-callout-{{level}}'><h4><span class='label label-{{level}}'>{{symbol}}</span> {{errorTitle}}: </h4><p>{{errorMessage}}</p> <p><a href='{{link}}'>{{fileName}}</a></p></div>";

            var link=Mustache.render(
                "txmt://open/?url=file://{{{filePath}}}&line=1&column=1",{
                    filePath: item.plugin.filePath
                });

            var errorHtml=Mustache.render(
                template,
                {
                    level: "danger",
                    symbol: "M",
                    errorTitle: "Mocha RunTime Error",
                    errorMessage: item.contents,
                    fileName: _.last(item.plugin.filePath.split("/")),
                    link: link
                });

            return $sce.trustAsHtml(Mustache.render("<div class='col-md-12'>{{{error}}}</div>'",{
                error: errorHtml
            }));
        }


        if(item.type=="error") {
            var error=item.error;

            var fileName=_.last(error.filePath.split("/"));

            // txmt://open/?url=file://{{{filePath}}}&line={{line}}&column=1
            // subl://open/?url=file://{{{filePath}}}&line={{line}}
            // mvim://open/?url=file://{{{filePath}}}&line={{line}}&column=1
            // atom://{{{filePath}}}

            function buildProtocolHandlerString() {
                return $scope.options.defaultProtocolHandler+":"+error.filePath+":"+error.line;
            }

            function buildClickProtocolHandlerString() {
                // return $scope.options.defaultProtocolHandler+":"+error.filePath+":"+error.line;
                return Mustache.render('SketchDevTools.openFileWithIDE("{{{file}}}","{{ide}}",{{line}})',{
                    ide: $scope.options.defaultProtocolHandler,
                    file: error.filePath,
                    line: error.line.toString()
                });
            }

            console.log(buildClickProtocolHandlerString());

            var link=Mustache.render($scope.options.protocolHandlerTemplate,{
                    filePath: error.filePath,
                    line: error.line
                });

            // Новый обработчик отрывания файлов во внешнем редакторе.
            var protocolHandler=buildProtocolHandlerString();
            link = "#";


            var template="<div class='bs-callout bs-callout-{{level}}'><h4><span class='label label-{{level}}'>{{symbol}}</span> {{errorTitle}}: <span style='color: #545454;'>{{errorMessage}}</span></h4><p>»  {{errorLineContents}}  «</p> <p><a href='{{link}}' onclick='{{click}}' protocol_handler='{{protocolHandler}}'>{{fileName}}, Line: {{line}}</a></p>{{{callStack}}}</div>";



            /*
            var errors={
                "ReferenceError": {
                    level: "danger",
                    symbol: "R",
                    errorTitle: "Reference Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                },
                "SyntaxError": {
                    level: "danger",
                    symbol: "S",
                    errorTitle: "Syntax Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                },
                "TypeError": {
                    level: "danger",
                    symbol: "T",
                    errorTitle: "Type Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                },
                "RangeError": {
                    level: "danger",
                    symbol: "R",
                    errorTitle: "Range Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                },
                "CustomError": {
                    level: "danger",
                    symbol: "E",
                    errorTitle: "Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                }
            };
            */

            var errors={
                "JSReferenceError": {
                    level: "danger",
                    symbol: "R",
                    errorTitle: "Reference Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                },
                "JSSyntaxError": {
                    level: "danger",
                    symbol: "S",
                    errorTitle: "Syntax Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                },
                "JSTypeError": {
                    level: "danger",
                    symbol: "T",
                    errorTitle: "Type Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                },
                "JSRangeError": {
                    level: "danger",
                    symbol: "R",
                    errorTitle: "Range Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                },
                "JSCustomError": {
                    level: "danger",
                    symbol: "E",
                    errorTitle: "Error",
                    errorMessage: error.message,
                    fileName: fileName,
                    line: error.line,
                    link: link,
                    errorLineContents: error.errorLineContents,
                    protocolHandler: protocolHandler,
                    click: buildClickProtocolHandlerString()
                }
            };

            // Custom Script handler.
            var actualError=errors[error.type];
            if(actualError.fileName=="Untitled.sketchplugin") {
                actualError.fileName="Custom Script";
                actualError.link="#";
                actualError["click"]="SketchDevTools.showCustomScriptWindow("+actualError.line+")";
            } else {
                // actualError["click"]="";
            }

            // Call stack
            {

                var result="";
                _.each(error.stack,function(call) {
                    var fileName= _.last(call.filePath.split("/"));
                    var fn=(call.fn=="closure") ? "(anonymous function)" : call.fn;
                    fn =(fn=="global code") ? "(global)" : fn;

                    result+=Mustache.render("<p>{{{fn}}} - {{fileName}}:{{line}}:{{column}}</p>",{
                        fn: fn,
                        fileName: fileName,
                        line: call.line,
                        column: call.column
                    });
                })

                actualError["callStack"]=result;
            }


            var errorHtml=Mustache.render(template,actualError);
            // <div class="col-md-10" ng-bind-html="renderHtml(item)"></div>

            return $sce.trustAsHtml(Mustache.render("<div class='col-md-12' style='margin-bottom: 0px;'>{{{error}}}</div>",{
                error: errorHtml
            }));
        }

        /*
        function callout(title,obj,type) {
            type = type || "success";


            var html="<div class='bs-callout bs-callout-%TYPE%'>"+"<h4>"+"<span class='label label-danger'>S</span> "+title+"</h4>"+"<p>"+obj+"</p>"+"</div>";
            html = html.replace("%TYPE%",type);

            return html;
        }
        */

        var contents=item.contents;

        contents = contents.replace(/\n/g, '<br>');
        contents = contents.replace(/    /g, '&nbsp;&nbsp;&nbsp;&nbsp;');

        /*
        if((contents.indexOf("<MS")>-1 || contents.indexOf("<NS")>-1 || contents.indexOf("<BC")>-1) && false) {
            contents = contents.replace(/</g, '&lt;');
            contents = contents.replace(/>/g, '&gt;');
        }
        */

        // contents = "<div style='padding-left: 5px;padding-right: 15px;'>"+contents+"</div>";

        var link=Mustache.render(
            "txmt://open/?url=file://{{{filePath}}}&line=1&column=1",{
                filePath: item.plugin.filePath
            });


            var contentsHtml=Mustache.render(
                "<div class='col-md-10'>{{{contents}}}</div><div class='col-md-2'><span class='pull-right text-muted'><small><a href='{{link}}'>{{pluginName}}</a></small></span></div>",
                {
                    contents: contents,
                    pluginName: _.last(item.plugin.filePath.split("/")),
                    link: link
                });


       return $sce.trustAsHtml(contentsHtml);
    };


    $scope.isError = function(log) {

        if($scope.isSyntaxError(log)) return true;
        if($scope.isReferenceError(log)) return true;
        if($scope.isTypeError(log)) return true;
        if($scope.isCustomError(log)) return true;

        return false;
    };

    $scope.isCustomError = function(log) {
        return log.indexOf("Error:")==0;
    };

    $scope.isSyntaxError = function(log) {
        return log.indexOf("SyntaxError:")>-1;
    };

    $scope.isReferenceError = function(log) {
        return log.indexOf("ReferenceError:")>-1;
    };

    $scope.isTypeError = function(log) {
        return log.indexOf("TypeError:")>-1;
    };

    $scope.hideConsole = function() {
        SketchDevTools.hideConsole();
    };

    $scope.callPlugin = function(path) {

        $http.get(path)
            .success(function(data) {

                console.log(data);
                console.log("This was data!");
                // SketchDevTools.execScript(data);

                /*
                angular.extend(_this, data);
                defer.resolve();
                */
            })
            .error(function() {
                // defer.reject('could not find someFile.json');
            });



        /*
        fileReader.readAsDataUrl("./../plugins/makeItRed.js", $scope)
            .then(function(result) {
                // $scope.imageSrc = result;
                console.log(result);
            });

        /*

        /*
        var script="selection.firstObject().style().fill().setColor([MSColor colorWithHex:'#ff0000' alpha:1]);";
        SketchDevTools.execScript(script);
        */

    };

    $scope.customScript ="print('Hello World of Coding!');";

    $scope.runCustomScript = function() {
        var script=$scope.customScript;

        // What the heck is wrong with text area? :(
        script = script.replace(/“/g, '"');
        script = script.replace(/”/g, '"');

        script = script.replace(/‘/g, "'");
        script = script.replace(/’/g, "'");


        console.log(script);

        SketchDevTools.execScript(script);
    };

    $scope.getConsoleOptions = function() {

        var options=JSON.parse(SketchDevTools.getConsoleOptions());
        console.log(options);
    };

    $scope.setConsoleOptions = function() {
        var options={
            protocolHandlerTemplate: "subl://open/?url=file://{{{filePath}}}&line={{line}}",
            showConsoleOnError: false
        };

        SketchDevTools.setConsoleOptions(JSON.stringify(options,null,4));
    };

    $scope.test = function() {
        SketchDevTools.showCustomScriptWindow(2);
    };

});