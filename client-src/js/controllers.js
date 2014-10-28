var module = angular.module('SketchConsole', ['ui.bootstrap']);

module.controller('SketchConsoleController', function ($scope) {
    $scope.items = [];

    // Initialize options object.
    if(angular.isUndefined($scope.options)) {
        $scope.options=JSON.parse(SketchDevTools.getConsoleOptions());
    }

    $scope.addWtfItem = function(data) {

        $scope.items.push({
            type: "wtf",
            classInfo: data
        });
    };

    $scope.addDuplicateImportItem = function(info) {

        // Simulate console item for a list of imports.
        _.each(info.imports,function(impr){
            impr.type="duplicateImport";
        });

        $scope.items.push({
            type: "duplicateImport",
            filePath: info.filePath,
            imports: info.imports
        });
    };

    $scope.addBrokenImportItem = function(path,filePath,line) {
        $scope.items.push({
            type: "brokenImport",
            path: path,
            filePath: filePath,
            line: line
        });
    };

    $scope.addCustomPrintItem = function(contents) {
        $scope.items.push({
            type: "custom",
            contents: contents
        });
    };

    $scope.addSessionItem = function(filePath,duration) {
        var newItem={
            type: "session",
            filePath: filePath,
            duration: duration,
            timestamp: new Date().valueOf()
        };

        $scope.items.push(newItem);
    };

    $scope.addErrorItem = function(type,message,filePath,line,errorLineContents,callStack) {

        var newItem={
            type: "error",

            errorType: type,
            message: message,
            filePath: filePath,
            line: line,
            errorLineContents: errorLineContents,
            stack: JSON.parse(callStack)

        };

        $scope.items.push(newItem);

    };

    $scope.addMochaErrorItem = function(contents,filePath) {

        var newItem={
            type: "mochaError",
            contents: contents,
            filePath: filePath,
            line: 1
        };

        $scope.items.push(newItem);
    };

    $scope.addPrintItem = function(contents,filePath,line) {

        var newItem = {
            type: "extendedPrint",
            contents: contents,
            filePath: filePath,
            line: line,
            timestamp: new Date().valueOf()
        };

        $scope.items.push(newItem);
    };


    $scope.showLogo = function() {
        return $scope.items.length==0 && !$scope.isOptionsOpened;
    };

    $scope.clear = function() {
        $scope.items=[];
    };

    $scope.hideConsole = function() {
        SketchDevTools.hideConsole();
    };

    //  Options popup.
    $scope.showSettings = false;
    $scope.showChangelog = true;

});