

(function (module) {

    module.directive('settingsPopover', function($compile) {
        return {
            restrict: 'E',
            replace: true,
            scope: {
                "onHide": "&"
            },
            templateUrl: "./templates/settings-popover.html",
            controller: function($scope) {

                // Initialize options object.
                if(angular.isUndefined($scope.options)) {
                    $scope.options=JSON.parse(SketchDevTools.getConsoleOptions());
                }

                $scope.hideSettings = function() {
                    $scope.onHide();
                },

                $scope.editors = [
                    {
                        name: "Sublime Text",
                        icon: "Sublime.png",
                        key: "sublime"
                    },
                    {
                        name: "TextMate",
                        icon: "TextMate.png",
                        key: "textmate"
                    },
                    {
                        name: "WebStorm",
                        icon: "WebStorm.png",
                        key: "webstorm"
                    },
                    {
                        name: "Atom",
                        icon: "Atom.png",
                        key: "atom"
                    },
                    {
                        name: "AppCode",
                        icon: "AppCode.png",
                        key: "appcode"
                    },
                    {
                        name: "Xcode",
                        icon: "XCode.png",
                        key: "xcode"
                    },
                    {
                        name: "MacVim",
                        icon: "MacVim.png",
                        key: "macvim"
                    },
                    {
                        name: "Custom Protocol Handler",
                        icon: "Custom.png",
                        key: "custom"
                    }
                ];

                $scope.iconForEditor = function(editor) {
                    return "./images/editors/"+editor.icon;
                };


                $scope.currentEditor = function()  {
                    return _.find($scope.editors,function(editor) {
                        return $scope.options.defaultProtocolHandler==editor.key;
                    });
                };

                $scope.needsSeparator = function(editor) {
                    return editor.key=="custom";
                };


                $scope.showProtocolHandlerTemplate = function() {
                    return $scope.currentEditor().key=="custom";
                };

                $scope.onEditorChange = function(editor) {
                    $scope.options.defaultProtocolHandler=editor.key;
                };

                $scope.$watch('options.defaultProtocolHandler', function() {
                    SketchDevTools.setConsoleOptions(JSON.stringify($scope.options,null,4));
                });

                $scope.$watch('options.showConsoleOnPrint', function() {
                    SketchDevTools.setConsoleOptions(JSON.stringify($scope.options,null,4));
                });

                $scope.$watch('options.showConsoleOnError', function() {
                    SketchDevTools.setConsoleOptions(JSON.stringify($scope.options,null,4));
                });

                $scope.$watch('options.clearConsoleBeforeLaunch', function() {
                    SketchDevTools.setConsoleOptions(JSON.stringify($scope.options,null,4));
                });

                $scope.$watch('options.showSessionInfo', function() {
                    SketchDevTools.setConsoleOptions(JSON.stringify($scope.options,null,4));
                });

                $scope.$watch('options.protocolHandlerTemplate', function() {
                    SketchDevTools.setConsoleOptions(JSON.stringify($scope.options,null,4));
                });

            },
            link: function(scope, element, attrs) {


            }
        };
    });

}(angular.module("SketchConsole")));