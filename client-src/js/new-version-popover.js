

(function (module) {

    module.directive('newVersionPopover', function($http) {
        return {
            restrict: 'E',
            replace: true,
            scope: {
                "onHide": "&",
                "title": "=",
                "mode": "="
            },
            templateUrl: "./templates/new-version-popover.html",
            controller: function($scope,$sce) {

                // Load changelog.
                $http.get('./data/changelog.json').
                    success(function(data, status) {
                        $scope.changelog=data;
                    }).
                    error(function(data, status, headers, config) {
                        // error logging goes here!.
                    });

                $scope.hidePopover = function() {
                    $scope.onHide();
                };

                $scope.renderMarkdown = function(contents) {
                    var html=markdown.toHTML(contents);

                    // console.log(html);

                    var result= $.parseHTML(html);
                    $(result).find("a").each(function(i,element){

                        var link=$(this);
                        var ref=link.attr("href");
                        link.attr("href","#");

                        link.attr("onClick","SketchDevTools.openURL(\""+ref+"\");")
                        console.log(ref);
                    });

                    // return $sce.trustAsHtml(html);
                    return $sce.trustAsHtml($(result).html());
                }

            },
            link: function(scope, element, attrs) {


            }
        };
    });

}(angular.module("SketchConsole")));