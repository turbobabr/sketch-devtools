// (control v)

coscript.setShouldKeepAround(true);

var dx=-1;

function addImgToGroup (group, img, layerName) {
    var imageCollection = group.documentData().images();
    var imageData = imageCollection.addImage_name_convertColourspace(img, layerName, false);
    var newImage = MSBitmapLayer.alloc().initWithImage_parentFrame_name(imageData, group.frame(), layerName);
    group.addLayer(newImage);

    return newImage;
}

function extractIconFromApp(appURL,filter) {
    var icon=[[NSWorkspace sharedWorkspace] iconForFile:appURL.path()];
    extractIcon(icon,appURL.lastPathComponent(),filter);
}

function extractIconFromFileURL(fileURL,filter) {
    var icon=NSImage.alloc().initWithContentsOfFile(fileURL.path());

    extractIcon(icon,fileURL.lastPathComponent(),filter);
}




function extractIcon(icon,name,filter) {

    if(name.indexOf(".")>-1) {
        name=name.split(".")[0];
    }


    var sizes=filter.split(",");

    function isValidSize(size) {

        if(filter.toLowerCase()=="all") {
            return true;
        }

        for(var i=0;i<sizes.length;i++) {
            if(size==parseInt(sizes[i])) {
                return true;
            }
        }

        return false;
    }

    var items=[];
    for(var i=0;i<icon.representations().count();i++) {
        var rep=icon.representations().objectAtIndex(i);
        if(isValidSize(rep.size().width)) {
            items.push(rep);
        }
    }

    items.sort(function compare(a, b) {
        if (a.size().width>b.size().width) {
            return -1;
        }
        if (a.size().width<b.size().width) {
            return 1;
        }

        return 0;
    });

    for(var i=0;i<items.length;i++) {
        var rep=items[i];


        var image = [[NSImage alloc] initWithSize:[rep size]];
        [image addRepresentation: rep];

        var aspect=(rep.pixelsWide()/rep.size().width==2) ? " @2x" : "";

        if(isValidSize(rep.size().width) && aspect=="") {
            var layer=addImgToGroup(doc.currentPage(),image,name+": "+rep.size().width+"x"+rep.size().height+aspect);
            layer.frame().setWidth(rep.size().width);
            layer.frame().setHeight(rep.size().height);

            layer.frame().setY(0);



            if(dx==-1) {
                dx=layer.frame().x()+layer.frame().width();
                print("Init: "+dx);
            } else {
                dx+=20;
                layer.frame().setX(dx);
                dx+=layer.frame().width();
                print("Sequence: "+dx);
            }
        }
    }
}



function selectAppliction() {
    var appsDirs = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory,NSLocalDomainMask,true);
    var appsDir = nil;
    if ([appsDirs count]) appsDir = [appsDirs objectAtIndex:0];

    var openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:"Choose Application"];
    [openPanel setMessage:"Choose Application to Grab icon from"];
    [openPanel setPrompt:"Grab the Icon!"];
    [openPanel setAllowsMultipleSelection:false]; // ?
    [openPanel setCanChooseDirectories:true];

    NSInteger result = [openPanel runModal];
    if (result == NSOKButton) {
        var fileURLs = [openPanel URLs];
        if(fileURLs.count()>0) {
            return fileURLs.objectAtIndex(0);
        } else {
            return null;
        }
    }

    return null;
}


var appURL=selectAppliction();
if(appURL!=null) {

    var filter=[doc askForUserInput:"Filter:" initialValue:"all"]
    if(appURL.path().hasSuffix("icns") || appURL.path().hasSuffix("ico")) {
        extractIconFromFileURL(appURL,filter);
    } else {
        extractIconFromApp(appURL,filter);
    }
}










