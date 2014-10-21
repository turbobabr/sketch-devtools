module.directive('wtf', function() {
    return {
        restrict: "E",
        replace: true,
        templateUrl: "./templates/wtf.html",
        scope: {
            classInfo: "="
        },
        controller: function($scope,$sce,APIReference) {

            function preprocess() {
                var classInfo=$scope.classInfo;

                var scope=classInfo.name;

                // Properties.
                _.each(classInfo.properties,function(property){
                    var symbol=APIReference.findProperty(scope,property.name);
                    if(angular.isDefined(symbol)) {
                        property.description=symbol.description;
                    }
                });

                // Instance methods.
                _.each(classInfo.methods,function(method){
                    var symbol=APIReference.findInstanceMethod(scope,method.selector);
                    if(angular.isDefined(symbol)) {
                        method.description=symbol.description;
                        if(angular.isDefined(method.returnValue)) {
                            /*
                            method.returnValue.description=symbol.returnValue.description;
                            method.returnValue.type.typeName=symbol.returnValue.type.typeName;
                            */
                        }

                        _.each(method.parameters,function(param,index){
                            var params=symbol.parameters;
                            if(angular.isDefined(params[index])) {
                               var pd=params[index];
                                param.name=pd.name;
                                param.description=pd.description;
                            }
                        });
                    }

                    // Cache parent.
                    _.each(method.parameters,function(param,index){
                        param._type="param";
                        param._method=method;
                        param._index=index;

                    });

                    // Cache class.
                    method._type="method";
                    method._class=classInfo;
                });
            }

            preprocess();


            $scope.listPropAttributes = function(property) {
                if(property.attributes.length>0) {

                    var str="<span class='rfs-p'>(</span>";
                    _.each(property.attributes,function(attribute,index){
                        str+="<span class='rfs-n'>"+attribute+"</span>";
                        if(index<property.attributes.length-1) {
                            str+="<span class='rfs-p'>, </span>";
                        }
                    });

                    str+="<span class='rfs-p'>)</span>"
                    return $sce.trustAsHtml(str);

                }

                return "";
            };

            $scope.propType = function(property) {
                if(property.type && property.type.typeName) {
                    return property.type.typeName;
                }

                return "(UnknownPropertyType)";
            };

            $scope.propSuffix = function(property) {
                if(property.type && property.type.isNamedObject) {
                    return "*";
                }

                return "";
            };

            $scope.onParamEditNameKeyDown = function(event,param) {
                if(event.which === 13) {
                    param.editParamName=false;

                }
            };

            $scope.onParamEditDescriptionKeyDown = function(event,param) {
                if(event.keyCode === 13 && event.metaKey) {
                    $scope.finishParamDescriptionEditing(param);
                }
            };

            $scope.finishParamDescriptionEditing = function(param) {
                param.isEditingParamDescription=false;

                // var symbol=APIReference.findInstanceMethod(param._method._class.name,param._method.selector);
                /*
                var symbol=APIReference.findInstanceMethodOrCreate(param._method._class.name,param._method.selector);
                console.log("THE SYMBOL:");
                console.log(symbol);
                */
                // var path="MSColor/methods/-fuzzyEqual:/parameters/0/description";
                // path="MSColor/methods/-fuzzyEqual:/parameters/0/type/typeName";

                var path=Mustache.render("#/{{cls}}/methods/-{{selector}}/parameters/{{index}}/description",
                    {
                        cls: param._method._class.name,
                        selector: param._method.selector,
                        index: param._index
                    });

                console.log("Property Path:");
                console.log(path);


                var root={};
                var parts=path.split("/");
                console.log(parts);
                console.log("Walk through object:");
                function findOrCreate(queue,obj,value) {

                    var key=queue.shift()
                    console.log(key);
                    if(_.isUndefined(key)) {
                        return;
                    }

                    key=key.toString();

                    if(queue.length==0) {
                        obj[key]=value;
                    } else if(key==="#") {
                        findOrCreate(queue,obj,value);
                    } else {
                        if(_.isUndefined(obj[key])) {
                            obj[key]={};
                            findOrCreate(queue,obj[key],value);
                        } else {
                            findOrCreate(queue,obj[key],value);
                        }

                    }
                }


                findOrCreate(parts,APIReference.data,param.description);

                console.log(root);




                APIReference.synchronize();

            };

            $scope.startParamDescriptionEditing = function(param) {
                param.isEditingParamDescription=true;
            };


        },
        link: function(scope, element, attrs) {
        }
    };
});