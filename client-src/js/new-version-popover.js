

(function (module) {

    module.directive('newVersionPopover', function($http) {
        return {
            restrict: 'E',
            replace: true,
            scope: {
                "onHide": "&",
                "title": "=",
                "mode": "=",
                "changelog": "="
            },
            templateUrl: "./templates/new-version-popover.html",
            controller: function($scope,$sce) {

                $scope.hidePopover = function() {
                    $scope.onHide();
                };

                $scope.daysPastSinceRelease = function(dateStr) {
                    return moment(dateStr,"YYYY.MM.DD").fromNow();
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
                        // console.log(ref);
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