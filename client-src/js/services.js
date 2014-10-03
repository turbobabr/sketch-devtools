(function (module) {

    module.directive('openUrl', function() { return {
        restrict: 'A',
        compile: function(element, attributes) {

            if(angular.isDefined(attributes.protocolHandler)) {
                element.bind('click', function() {
                   // ???
                });

            }

            if(angular.isDefined(attributes.openUrl)) {

                console.log("EXTENDED!");

                element.bind('click', function() {
                    // do something with $rootScope here, as your question asks for that
                    // console.log(attributes.openUrl);
                    SketchDevTools.openURL(attributes.openUrl);
                });
            }
        }
    }; });

    module.directive('protocolHandler', function() { return {
        restrict: 'A',
        compile: function(element, attributes) {

            if(angular.isDefined(attributes.protocolHandler)) {
                element.bind('click', function() {

                    var parts=attributes.protocolHandler.split(":");

                    var params={
                        ide: parts[0],
                        path: decodeURI(parts[1]),
                        line: parseInt(parts[2])
                    };

                    SketchDevTools.openFileWithIDE(params.path,params.ide,params.line);

                });

            }
        }
    }; });

    module.directive('dynamic', function ($compile) {
        return {
            restrict: 'A',
            replace: true,
            link: function (scope, ele, attrs) {
                scope.$watch(attrs.dynamic, function(html) {
                    ele.html(html);
                    $compile(ele.contents())(scope);
                });
            }
        };
    })




}(angular.module("SketchConsole")));