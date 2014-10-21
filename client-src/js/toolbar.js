module.directive('toolbar', function() {
    return {
        restrict: "E",
        replace: true,
        templateUrl: "./templates/toolbar.html",
        scope: {
            onClear: "&",
            onSettings: "&",
            onClose: "&"
        },
        controller: function($scope) {
        },
        link: function(scope, element, attrs) {
        }
    };
});