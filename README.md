![Header Logo](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/header_logo.png)
===============

Sketch DevTools is a set of tools & utilities that help in development of [Sketch App](http://bohemiancoding.com/sketch/) plugins.

The Sketch App itself provides a very limited number of tools for plugins developers. The most annoying things are the lack of convenient debugging tools and lack of documentation of available APIs. The aim of this project is to solve these two problems and provide newbie developers with a comprehensive information on plugins development for Sketch App.

Currently the most valuable feature of DevTools is a built-in console that makes it a breeze to debug your plugins and scripts. I plan to work on this project futher to make development process even more easier! :)

> Sketch DevTools uses a lot of undocmented and hidden APIs of Sketch App, thus it might stop working with any update of the application.

## Installation

1. [Download Sketch DevTools.zip archive file](https://github.com/turbobabr/sketch-devtools/blob/master/dist/Sketch%20DevTools.zip?raw=true).
2. Reveal plugins folder in finder ('Sketch App Menu' -> 'Plugins' -> 'Reveal Plugins Folder...').
3. Copy downloaded zip file to the revealed folder and un-zip it.
4. Install [Sketch DevTools Assistant](https://github.com/turbobabr/sketch-devtools-assistant) application.
5. You are ready to go! :)

## Updating

Starting from version 0.2.0, Sketch DevTools supports automatic notifications about new releases. As soon as new version is available you will see the following popover screen with detailed info about the new release:

![New Version Notifications](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/new_version_notification_popover.png)

Unfortunately automatic updates are not supported yet, thus you have to update everything manually. Follow these steps to update your current version of Sketch DevTools to a new one:

1. Reveal plugins folder in finder ('Sketch App Menu' -> 'Plugins' -> 'Reveal Plugins Folder...').
2. Quit Sketch App.
3. Find and remove `Sketch DevTools` folder in revealed plugins folder.
4. [Download Sketch DevTools.zip archive file](https://github.com/turbobabr/sketch-devtools/blob/master/dist/Sketch%20DevTools.zip?raw=true).
5. Copy downloaded zip file to the plugins folder and un-zip it.
6. IMPORTANT: Reinstall [Sketch DevTools Assistant](https://github.com/turbobabr/sketch-devtools-assistant) application.
7. Launch Sketch App
8. Launch DevTools using `Command-Option-K`
9. Setup `Jump to Code` editor and other preferences as described in [Jump To Code](https://github.com/turbobabr/sketch-devtools#jump-to-code) section.
10. Mission complete! :)

## Change Log

#### v0.2.0: November 11, 2014

- Bug Fix: Fixed bug with `@""` literal is not being processed correctly. [Issue #25](https://github.com/turbobabr/sketch-devtools/issues/25)
- Bug Fix: Relative paths in `#import` statements are now processed with excatly the same way Sketch App does it. [Issue #20](https://github.com/turbobabr/sketch-devtools/issues/20)
- Bug Fix: `Jump To Code` feature didn't recognize Sublime 2 during protocol handling routine. [Sketch DevTools Assistant: Issue #1](https://github.com/turbobabr/sketch-devtools-assistant/issues/1)
- New Feature: Invalid `#import` statements are now reported as a nice looking error box.
- New Feature: Notifications about new releases are now supported! [Issue #10](https://github.com/turbobabr/sketch-devtools/issues/10)

#### v0.1.0: October 24, 2014

- Initial release with a bunch of bugs! :)


## Usage

Sketch DevTools is just a regular plugin that uses some rocket science to survive in this cruel world. Since it's just a plugin - there are some commands available:

`Command-Option-K` - Show/Hide DevTools

`Command-Option-Shift-K` - Clear Console

DevTools panel like any WebKit inspector is bound to a specific document. If you want to use console in the current Sketch document you have to activate it using `Command-Option-K` shortcut. As soon as you activate it - all the log statements and errors from plugins executed in the document will be automatically redirected to this console. All the logging techniques are desribed below.

### Basic Logging

Sketch DevTools console automatically handles all the exceptions and print statements. You use the same `print` or `log` function for logging in custom script editor or external sketchplugin/js file without any additional libs.

Just run the following script in the custom script editor:

```JavaScript
print("Hi Handsome!");
log("Yo! Yo! Yo!");
print(sketch);
```

It produces the following result:

![Basic Logging Sample](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/basic_logging_result.png)


### Logging with HTML formatting

Since Sketch DevTools uses WebKit for its UI there is a way to use rich text formatting in console. You can pass any HTML formatted string into `print` or `log` function and it will be rendered as HTML.

##### Demo

I want to demonstrate it with something cool and totally useless! :) Here is an example of HTML formatted logging:

```JavaScript
print("<h5>Adventure Time - Bacon Pancakes - New York remix</h5>")
print("<iframe width='560' height='315' src='http://www.youtube.com/embed/cUYSGojUuAU' frameborder='0' allowfullscreen></iframe>");
```

The result will be:

![Adventure Time - Bacon Pancakes](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/jake_the_dog.png)

##### Using Bootstrap

By default [Twitter Bootstrap](http://getbootstrap.com/) is used as CSS engine. Thus, you can freely use all the styles provided by it. Here is more useful example of HTML formatting that shows Bootstrap usage:

```JavaScript
var layer=selection.firstObject();
if(layer && layer.isKindOfClass(MSShapeGroup.class())) {
    print("<h3>Selected Layer:</h3>")
    var color="#"+layer.style().fill().color().hexValue();
    print("Color: <span class='label' style='background-color:"+color+";'>"+color+"</span>")
    print("Bezier Path:");
    print("<pre>"+layer.bezierPath().bezierPath()+"</pre>");
}
```

This 'short' logging statement produces the following result:

![HTML Formatting Sample](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/html_formatting_sample.png)

##### Logging Objects

If you want to log an object combined with some text in a single line you have to escape HTML symbols first:

```JavaScript
function escapeHTML(string) {
    var entityMap = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#x27;',
        '`': '&#x60;',
        "\n": "<br>",
        "    ": "&nbsp;&nbsp;&nbsp;&nbsp;"
    };

    return String(string).replace(new RegExp("[&<>\"'\/\\n]",'g'), function (s) {
        return entityMap[s];
    }).replace(/    /g, "&nbsp;&nbsp;&nbsp;&nbsp;");
}

var layer=selection.firstObject();
if(layer) {

    // No HTML escaping.
    print("<strong>Layer:</strong> "+layer);

    // HTML symbols are escaped.
    print("<strong>Layer:</strong> "+escapeHTML(layer.toString()));
}
```

In the following image you can see the difference between these two print statements:

![HTML Escaping](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/html_escaping.png)

##### Console Framework

If you plan to use HTML formatting in your logs a lot, there is a ready to use solution:

- [Sketch DevTools: Console Framework (Under Development)](https://github.com/turbobabr/sketch-devtools-console)

This small library is very similar to WebKit Console API and contains a lot of useful methods for Sketch specific logging, HTML formatting and convenient things like timers, counters, tags, etc.


### Jump to Code

Console allows you to quickly open a file on certain line with your IDE of choice. Prior using this feature be sure that [Sketch DevTools Assistant](http://github.com/turbobabr/sketch-devtools-assistant) is installed and running.

Then you have to select an editor you are using for Sketch plugins development. To do that, follow the instructions below:

![Changing IDE](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/change_ide.png)

All the default `print` statements and error boxes have an url with the name of actual file and line number that generated the record. For example lets run the following script:

```JavaScript
print(selection);
print(selection.last());
```

It produces two records. The first one is just a print statement the second is an error box. Both records have the previously mentioned URL you can click on to go straight to the root of the problem or reveal the print statement location to quickly disable it:

![Jump to code URLs](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/jump_to_code_figure.png)

You can use a `Quick Jump To Code` feature to save some time:

![Quick Jumpt To Code](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/quick_jump_to_code.png)

## Roadmap

Here is the list of some half-baked ideas and features I'm planning to include in the future releases of Sketch DevTools:

- [ ] Dedicated site for all of this.
- [ ] A separate `console` CocoaScript module similar to the WebKit console object that utilizes all the features of Sketch DevTools Console tab.
- [ ] Automatic initialization of tools on Sketch launch.
- [ ] Symbols Explorer. A separate tab panel that contains a Sketch classes reference.
- [ ] Custom script runner. The same thing as built-in Sketch custom script dialog but embedded right into DevTools panel.
- [ ] Console prompt to quickly evaluate JS expressions.

## Feedback

If you discover any issue or have any suggestions, please [open an issue](https://github.com/turbobabr/sketch-devtools/issues) or find me on twitter [@turbobabr](http://twitter.com/turbobabr).

## Credits

- Some code from [CocoaScript](http://github.com/ccgus/CocoaScript) framework by [August Mueller](http://github.com/ccgus) is used in the project.
- The [flat Sketch icon desing](http://dribbble.com/shots/1705797-Sketch-App-Icon-Yosemite-Edition?list=users&offset=0) for the logo was shamelessly borrowed from [Mehmet Gozetlik](http://dribbble.com/Antrepo). Thanks you Mehmet for the great work! :)
- Excelent [NSLogger](https://github.com/fpillet/NSLogger) is used here! :)

## License

The MIT License (MIT)

Copyright (c) 2014 Andrey Shakhmin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
