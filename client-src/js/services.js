

(function (module) {

    module.config( [
            '$compileProvider',
            function( $compileProvider)
            {
                // A list of allowed protocol handlers.
                var allowedSchemas=[/*"subl","txmt",*/"sdtsubl","sdtwstorm","sdtappcode","sdtatom","sdtxcode","sdtmvim"];

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
                url: "./js/console-error-item.html"
            },
            {
                name: "extendedPrint",
                url: "./js/console-print-item.html"
            },
            {
                name: "session",
                url: "./js/console-session-item.html"
            },
            {
                name: "mochaError",
                url: "./js/console-mocha-error-item.html"
            },
            {
                name: "brokenImport",
                url: "./js/console-broken-import-item.html"
            },
            {
                name: "custom",
                url: "./js/console-custom-item.html"
            },
            {
                name: "stackCall",
                url: "./js/stack-call.html"
            },
            {
                name: "duplicateImport",
                url: "./js/console-duplicate-import-item.html"
            }
        ];

        var templates = {};

        _.each(loadingList,function(obj){
            templates[obj.name]=$.ajax({type: "GET",url: obj.url,async: false}).responseText;
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

    module.directive('stackCall', function($compile,DynamicTemplates,JumpToCode,Preferences) {
        var template=DynamicTemplates.stackCall;
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
                    var ide=$scope.isCustomScript(call) ? "sketch" : Preferences.defaultProtocolHandler;
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
                    var ide=$scope.isCustomScript(item) ? "sketch" : Preferences.defaultProtocolHandler;
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
                    var types=["error","extendedPrint","mochaError","brokenImport"];
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
        return JSON.parse(SketchDevTools.getConsoleOptions());
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
                    } else {
                        SketchDevTools.openFileWithIDE(params.path,params.ide,params.line);
                    }

                } else {
                    throw new Error("SketchDevTools object is not found!")
                }
            },

            protocolHandler: function(obj) {

                var params = (_.isString(obj)) ? this.decode(obj) : obj;
                if(params.ide=="custom") {

                    var template=Preferences.protocolHandlerTemplate;
                    template = template.replace(/\{/g, '{{{');
                    template = template.replace(/\}/g, '}}}');

                    return Mustache.render(template,{
                        file: SketchDevTools.filePathToFileURL(params.path),
                        line: params.line,
                        column: "1"
                    });
                }

                var href=Mustache.render("{{schema}}://open?url={{{url}}}&line={{line}}&column={{column}}",{
                    schema: this.schemaMap[Preferences.defaultProtocolHandler],
                    url: SketchDevTools.filePathToFileURL(params.path),
                    line: params.line,
                    column: "1"
                });

                return href;
            },
            schemaMap: {
                "sublime": "sdtsubl",
                "textmate": "txmt",
                "webstorm": "sdtwstorm",
                "appcode": "sdtappcode",
                "atom": "sdtatom",
                "xcode": "sdtxcode",
                "macvim": "sdtmvim"
            }
        };
    });


}(angular.module("SketchConsole")));