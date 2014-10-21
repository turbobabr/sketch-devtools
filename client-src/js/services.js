

(function (module) {

    module.config( [
            '$compileProvider',
            function( $compileProvider)
            {
                // A list of allowed protocol handlers.
                var allowedSchemas=["subl","txmt","skdtsubl","skdtwstorm","skdtappcode","skdtatom","skdtxcode","skdtmvim"];

                // Adding custom protocol handler if exists.
                if(angular.isDefined(SketchDevTools)) {
                    var options=JSON.parse(SketchDevTools.getConsoleOptions());
                    var template=options.protocolHandlerTemplate;
                    var parts=template.split(":");
                    if(parts.length>1) {
                        var customSchema=parts[0];
                        if(!_.contains(allowedSchemas,customSchema)) {
                            console.log("Adding Custom Schema:");
                            console.log(customSchema);
                            allowedSchemas.push(customSchema);
                        }
                    }
                }

                var whiteList=new RegExp(Mustache.render("^\\s*(https?|ftp|mailto|{{{schemas}}}):",{ schemas:allowedSchemas.join("|")}));
                $compileProvider.aHrefSanitizationWhitelist(whiteList);

            }
        ]);

    module.factory('DynamicTemplates', function() {

        var loadingList=[
            {
                name: "error",
                url: "console-error-item.html"
            },
            {
                name: "extendedPrint",
                url: "console-print-item.html"
            },
            {
                name: "session",
                url: "console-session-item.html"
            },
            {
                name: "mochaError",
                url: "console-mocha-error-item.html"
            },
            {
                name: "brokenImport",
                url: "console-broken-import-item.html"
            },
            {
                name: "custom",
                url: "console-custom-item.html"
            },
            {
                name: "stackCall",
                url: "stack-call.html"
            },
            {
                name: "duplicateImport",
                url: "console-duplicate-import-item.html"
            },
            {
                name: "wtf",
                url: "console-wtf-item.html"
            }
        ];

        var templates = {};

        _.each(loadingList,function(obj){
            templates[obj.name]=$.ajax({type: "GET",url: "./templates/"+obj.url,async: false}).responseText;
        });

        return templates;
    });

    // JumpToCode Functionality.
    module.directive('jumpToCode', function(JumpToCode) {
        return {
            restrict: 'A',
            link: function(scope , element,attributes){

                // Session item has no jump to code functionality.
                if(attributes.jumpToCode=="") {
                    return;
                }

                // This is a custom script jumpt to code.
                if(JumpToCode.decode(attributes.jumpToCode).ide=="sketch") {
                    element.bind("click", function(e){
                        JumpToCode.jump(attributes.jumpToCode);
                    });
                    return;
                }

                // External jump to code workflow.
                var href=JumpToCode.protocolHandler(attributes.jumpToCode);
                attributes.$set("href",href);
            }
        };
    });

    // Open in default brower.
    module.directive('defaultBrowser', function() {
        return {
            restrict: 'A',
            link: function(scope , element,attributes){
                element.bind("click", function(e){
                    SketchDevTools.openURL(attributes.defaultBrowser);
                });
            }
        };
    });


    module.directive('stackCall', function($compile,DynamicTemplates,JumpToCode,Preferences) {
        var template=DynamicTemplates.stackCall;
        var prefs=Preferences.get();
        return {
            restrict: 'E',
            replace: true,
            scope: {
                stack: "="
            },
            controller: function($scope) {
                $scope.isExpanded=false;
                $scope.expanderClass = function(){
                    return $scope.isExpanded ? "fa fa-caret-down" : "fa fa-caret-right";
                };

                $scope.fnName = function(name) {
                    if(name=="closure") return "(anonymous function)";
                    if(name=="global code") return "(global)";

                    return name;
                };

                $scope.onExpanderClick = function() {
                    $scope.isExpanded=!$scope.isExpanded;
                };

                $scope.jumpToCodeForCall = function(call) {
                    var ide=$scope.isCustomScript(call) ? "sketch" : prefs.defaultProtocolHandler;
                    return JumpToCode.encode(ide,call.filePath,call.line);
                };

                $scope.isCustomScript = function(call) {
                    var name= _.last(call.filePath.split("/"));
                    return name==="Untitled.sketchplugin";
                };

                $scope.scriptFileName = function(call) {
                    var name= _.last(call.filePath.split("/"));
                    return $scope.isCustomScript(call) ? "Custom Script" : name;

                }
            },
            link: function(scope, element, attrs) {
                element.html(template).show();
                $compile(element.contents())(scope);
            }
        };
    });

    module.directive('consoleitem', function ($compile,$sce,DynamicTemplates) {

        function wrap(s) {
            return "<div class='row console-row' ng-click-2='mouseClick($event,item)' ng-mouseenter='mouseEnter($event,item)' ng-mouseleave='mouseLeave($event,item)'><div class='col-lg-12'><a href='#' jump-to-code='{{prepareJumpToCode(item)}}' ng-show='showJumpToCodePopover(item)'><div class='jump-to-code-popover'><div class='jump-to-code-popover-icon'><div class='jump-to-code-popover-icon-ex'><i class='fa fa-code'></i></div></div></div></a>"+s+"</div></div>";
        }

        return {
            restrict: 'E',
            replace: true,
            scope: {
                item: "="
            },
            controller: function($scope,Preferences,JumpToCode) {

                var prefs=Preferences.get();

                $scope.humanizeDuration = function(duration) {
                    if(Math.floor(duration)>0) return Math.floor(duration)+"s "+(((duration-Math.floor(duration)))*1000).toFixed()+"ms";
                    return (duration*1000).toFixed()+" ms";
                };

                $scope.humanizeTimestamp = function(timestamp) {
                    return moment(timestamp).format('HH:mm:ss.SSS');
                };

                $scope.renderAsHtml = function(contents) {
                    return $sce.trustAsHtml(contents);
                };

                $scope.isCustomScript = function(item) {
                    var name= _.last(item.filePath.split("/"));
                    return name==="Untitled.sketchplugin";
                };

                $scope.prepareJumpToCode = function(item) {
                    if(!$scope.hasJumpToCode(item)) return "";
                    var ide=$scope.isCustomScript(item) ? "sketch" : prefs.defaultProtocolHandler;
                    return JumpToCode.encode(ide,item.filePath,item.line);
                };

                $scope.scriptFileName = function(item) {
                    var name= _.last(item.filePath.split("/"));
                    return $scope.isCustomScript(item) ? "Custom Script" : name;
                };

                $scope.mouseEnter = function(event,item) {
                    if(!$scope.hasJumpToCode(item)) return;
                    item.showPopover=true;
                };

                $scope.mouseLeave = function(event,item) {
                    item.showPopover=false;
                };

                $scope.mouseClick = function(event,item) {
                    if(!$scope.hasJumpToCode(item)) return;
                    if(item.showPopover && isCmdKey) {
                        var jtc=$scope.prepareJumpToCode(item);
                        JumpToCode.jump(jtc);
                    }
                };

                $scope.hasJumpToCode = function(item) {
                    var types=["error","extendedPrint","mochaError","brokenImport","duplicateImport"];
                    return _.contains(types,item.type);
                };

                $scope.showJumpToCodePopover = function(item) {
                    if(!$scope.hasJumpToCode(item)) return;
                    return item.showPopover && isCmdKey;
                };

                $scope.errorInfo = function(item) {
                    var errors={
                        "JSReferenceError": { symbol: "R", title: "Reference Error" },
                        "JSSyntaxError": { symbol: "S", title: "Syntax Error" },
                        "JSTypeError": { symbol: "T",title: "Type Error" },
                        "JSRangeError": { symbol: "R", title: "Range Error" },
                        "JSCustomError": { symbol: "E", title: "Error" }
                    };

                    return errors[item.errorType];
                };
            },
            link: function(scope, element, attrs) {
                element.html(wrap(DynamicTemplates[scope.item.type])).show();
                $compile(element.contents())(scope);
            }
        };
    });

    module.factory('Preferences', function() {
        return {
            get: function() {
                return JSON.parse(SketchDevTools.getConsoleOptions())
            }
        };
    });

    module.factory('JumpToCode', function(Preferences) {

        return {
            encode: function(ide,filePath,line) {
                return [ide,filePath,line].join(":");
            },
            decode: function(jtc) {
                var parts=jtc.split(":");
                return {
                    ide: parts[0],
                    path: decodeURI(parts[1]),
                    line: parseInt(parts[2])
                };
            },
            jump: function(obj) {
                var params = (_.isString(obj)) ? this.decode(obj) : obj;
                if(angular.isDefined(SketchDevTools)) {
                    if(params.ide=="sketch") {
                        SketchDevTools.showCustomScriptWindow(params.line);
                    }

                } else {
                    throw new Error("SketchDevTools object is not found!")
                }
            },

            protocolHandler: function(obj) {

                var prefs=Preferences.get();

                var params = (_.isString(obj)) ? this.decode(obj) : obj;
                if(params.ide=="custom") {

                    var template=prefs.protocolHandlerTemplate;
                    template = template.replace(/\{/g, '{{{');
                    template = template.replace(/\}/g, '}}}');

                    return Mustache.render(template,{
                        file: SketchDevTools.filePathToFileURL(params.path),
                        line: params.line,
                        column: "1"
                    });
                }

                var href=Mustache.render("{{schema}}://open?url={{{url}}}&line={{line}}&column={{column}}",{
                    schema: this.schemaMap[prefs.defaultProtocolHandler],
                    url: SketchDevTools.filePathToFileURL(params.path),
                    line: params.line,
                    column: "1"
                });

                return href;
            },
            schemaMap: {
                "sublime": "skdtsubl",
                "textmate": "txmt",
                "webstorm": "skdtwstorm",
                "appcode": "skdtappcode",
                "atom": "skdtatom",
                "xcode": "skdtxcode",
                "macvim": "skdtmvim"
            }
        };
    });


    module.factory('APIReference', function() {
        return {
            findSymbol: function(scope,symbol) {
                var cls=this.data[scope];
                if(_.isUndefined(cls)) return;

                if(symbol.charAt(0)==='@') {
                    if(_.isUndefined(cls.properties)) return;
                    return cls.properties[symbol];
                }

                if(symbol.charAt(0)==='-') {
                    if(_.isUndefined(cls.methods)) return;
                    return cls.methods[symbol];
                }

                if(symbol.charAt(0)==='+') {
                    if(_.isUndefined(cls.classMethods)) return;
                    return cls.methods[symbol];
                }

                return cls[symbol];
            },
            findClass: function(className) {
                return this.data[className];
            },
            findClassOrCreate: function(className) {
                var classSymbol=this.findClass(className);
                if(_.isUndefined(classSymbol)) {
                    classSymbol={};
                    this.data[className]=classSymbol;
                }

                return classSymbol;
            },
            findProperty: function(scope,propName) {
                return this.findSymbol(scope,"@"+propName);
            },
            findInstanceMethod: function(scope,selector) {
                return this.findSymbol(scope,"-"+selector);
            },
            findInstanceMethodOrCreate: function(scope,selector) {
                var classSymbol=this.findClassOrCreate(scope);
                if(_.isUndefined(classSymbol.methods)) {
                    classSymbol.methods={};
                }

                var method=this.findInstanceMethod(scope,selector);
                if(_.isUndefined(method)) {
                    method={};
                    classSymbol.methods["-"+selector]=method;
                }

                return method;
            },
            findClassMethod: function(scope,selector) {
                return this.findSymbol(scope,"+"+selector);
            },

            synchronize: function() {
                try {
                    var str=JSON.stringify(this.data,null,4);
                    SketchDevTools.synchronizeSymbols(str);

                } catch(e) {
                    throw new Erro("Unable to synchronize symbols!");
                }

            },
            initialize: function() {


            },
            data: (function(){
                var json=$.ajax({type: "GET",url: "./data/symbols.json",async: false}).responseText;
                return JSON.parse(json);
            })()
            /*
            data: {
                "MSColor": {
                    description: "A model object that represents Color.",

                    properties: {
                        "@red": {
                            description: "red color"
                        },
                        "@green": {
                            description: "green color"
                        },
                        "@blue": {
                            description: "blue color"
                        },
                        "@alpha": {
                            description: "alpha channel"
                        }
                    },

                    methods: {
                        "-isWhite": {
                            description: "Whether color is white.",
                            returnValue: {
                                description: "The BOOL value",
                                type: {
                                    typeName: "BOOL"
                                }
                            }
                        },
                        "-hexValue": {
                            description: "A hex representation of the color",
                            returnValue: {
                                description: "A hex string value of the color without `#` symbol, e.g. 'FF0000'",
                                type: {
                                    isTypedObject: true,
                                    typeName: "NSString"
                                }
                            }
                        }
                    }
                }
            }
            */
        };
    });

    module.directive('inlineTextarea', function() {
        return {
            restrict: "E",
            replace: true,
            templateUrl: "./templates/inline-textarea.html",
            scope: {
                contents: "="
            },
            controller: function($scope,$sce,$element) {

                $scope.placeholder="Click here to add some content...";

                $scope.startEditing = function() {


                    $scope.isEditing=true;
                };

                $scope.finishEditing = function() {
                    $scope.isEditing=false;
                };

                $scope.onKeyPress = function(event) {

                    if((event.keyCode===13 && event.metaKey) || event.keyCode===27) {
                        $scope.finishEditing();
                    }
                };

                $scope.produceHtmlContent = function() {
                    return $sce.trustAsHtml(markdown.toHTML($scope.contents));
                };

            },
            link: function(scope, element, attrs) {

            }
        };
    });


}(angular.module("SketchConsole")));