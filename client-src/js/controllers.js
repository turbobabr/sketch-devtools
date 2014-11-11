
// FIXME: Editor
// var module = angular.module('SketchConsole', ['ui.bootstrap','ui.ace']);
var module = angular.module('SketchConsole', ['ui.bootstrap']);

module.controller('SketchConsoleController', function ($scope,$http) {

    $scope.showChangelog = false;

    // Load remote changelog.
    $http.get('https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/client-src/data/changelog.json?ts='+(new Date().valueOf()).toString()).
        success(function(remoteData) {

            $http.get('./data/changelog.json').
                success(function(localData) {
                    if(_.isNull(localData) || _.isUndefined(localData)) {
                        return;
                    }

                    if(remoteData.currentVersion!=localData.currentVersion) {
                        $scope.remoteChangelog = {
                            currentVersion: localData.currentVersion,
                            // latestVersion: remoteData.versions[0],
                            latestVersion: localData.versions[0],
                            previousVersions: _.rest(remoteData.versions)
                        };

                        updateScrollableViews(); // Fixme: Dirty hack to update scrollable views viewports.
                        $scope.showChangelog = true;

                    }
                });
        });


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

    // FIXME: Editor.
    /*
    $scope.scriptSource = "";
    $scope.showScriptEditor = false;

    // ACE editor.
    $scope.aceLoaded = function(_editor){
        // Editor part
        var _session = _editor.getSession();
        var _renderer = _editor.renderer;

        // Options
        _editor.setReadOnly(false);
        _session.setUndoManager(new ace.UndoManager());
        _renderer.setShowGutter(true);

        // Events
        _editor.on("changeSession", function(){

            // console.log("changeSession");

        });
        _session.on("change", function(){
            // console.log("change!");
        });

        _editor.commands.addCommand({
            name: 'runScript',
            bindKey: { mac: 'Command-Enter'},
            exec: function(editor) {
                SketchDevTools.runScript(editor.getValue());
            },
            readOnly: false // false if this command should not apply in readOnly mode
        });

        _editor.commands.addCommand({
            name: 'showHideEditor',
            bindKey: { mac: 'Command-Shift-K'},
            exec: function(editor) {
                $scope.showScriptEditor=!$scope.showScriptEditor;
            },
            readOnly: false // false if this command should not apply in readOnly mode
        });
    };
    */




});