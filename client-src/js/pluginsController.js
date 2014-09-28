var module = angular.module('SketchFusion', []);

module.controller('PluginsController', function ($scope,$http,$sce,$location,$anchorScroll) {

    $scope.plugins=[];

    var url="file:///Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/Sketch DevTools/data/plugins.json";
    $http({method: 'GET', url: url}).
        success(function(data, status, headers, config) {
            // $scope.plugins=data;
            _.each(data,function(plugin) {

                var parts=plugin.plugin.split("/");


                function parseShortcut(sh) {
                    if(sh.length<1) {
                        return "?";
                    }

                    var keys = {
                        cmd: '\u2318',
                        command: '\u2318',
                        ctrl: '\u2303',
                        control: '\u2303',
                        alt: '\u2325',
                        option: '\u2325',
                        shift: '\u21e7',
                        enter: '↩',
                        left: '\u2190',
                        right: '\u2192',
                        up: '\u2191',
                        down: '\u2193'
                    };

                    var str="";
                    _.each(sh,function(symbol){
                        if(!_.isUndefined(keys[symbol])) {
                            str+=keys[symbol];
                        } else {
                            str+=symbol.toUpperCase();
                        }
                    });


                    // return sh.join("-");
                    return str;
                }

                $scope.plugins.push({
                    name: _.last(parts).replace(".sketchplugin",""),
                    shortcut: parseShortcut(plugin.shortcut)
                });


            });

            var conflicts=_.groupBy($scope.plugins,function(obj){
                return obj.shortcut;
            });

            _.each(conflicts,function(value,key){
                if(value.length<2) {
                    value.length["hasConflicts"]=false;
                } else {
                    _.each(value,function(pl){
                        pl["hasConflicts"]=true;
                    });
                }
            });


        }).
        error(function(data, status, headers, config) {

        });

    /*
    var url="https://raw.githubusercontent.com/sketchplugins/plugin-directory/master/plugins.json";
    $http({method: 'GET', url: url}).
        success(function(data, status, headers, config) {
            $scope.plugins=data;

//            _.each(data,function(pluginInfo){
//
//                var query="duplicator";
//                $http.get('https://api.github.com/repos/'+pluginInfo.owner+'/'+pluginInfo.name, { params: {  } })
//                    .success(function (data) {
//                        console.log(data);
//                    })
//                    .error(function (e) {
//                        console.log(e);
//                    });
//            });
        }).
        error(function(data, status, headers, config) {

        });
        */


    // https://api.github.com/repos/{owner}/{repo}


    // https://raw.githubusercontent.com/sketchplugins/plugin-directory/master/plugins.json

});


// Token: d6d27c434d339b372270dafaecc18792f8343351