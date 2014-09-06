(function (module) {

    var fileReader = function ($q, $log) {

        var onLoad = function(reader, deferred, scope) {
            return function () {
                scope.$apply(function () {
                    deferred.resolve(reader.result);
                });
            };
        };

        var onError = function (reader, deferred, scope) {
            return function () {
                scope.$apply(function () {
                    deferred.reject(reader.result);
                });
            };
        };

        var onProgress = function(reader, scope) {
            return function (event) {
                scope.$broadcast("fileProgress",
                    {
                        total: event.total,
                        loaded: event.loaded
                    });
            };
        };

        var getReader = function(deferred, scope) {
            var reader = new FileReader();
            reader.onload = onLoad(reader, deferred, scope);
            reader.onerror = onError(reader, deferred, scope);
            reader.onprogress = onProgress(reader, scope);
            return reader;
        };

        var readAsDataURL = function (file, scope) {
            var deferred = $q.defer();

            var reader = getReader(deferred, scope);
            reader.readAsDataURL(file);

            return deferred.promise;
        };

        return {
            readAsDataUrl: readAsDataURL
        };
    };

    module.factory("fileReader",
        ["$q", "$log", fileReader]);


    module.directive('openUrl', function() { return {
        restrict: 'A',
        compile: function(element, attributes) {

            if(angular.isDefined(attributes.openUrl)) {

                console.log("EXTENDED!");

                element.bind('click', function() {
                    // do something with $rootScope here, as your question asks for that
                    // console.log(attributes.openUrl);
                    SketchDevTools.openURL(attributes.openUrl);



                });
            }



            /*
            element.addClass('btn');
            if ( attributes.type === 'submit' ) {
                element.addClass('btn-primary');
            }
            if ( attributes.size ) {
                element.addClass('btn-' + attributes.size);
            }*/

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