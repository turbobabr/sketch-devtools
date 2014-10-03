Sketch DevTools
===============

#### (Work in progress...)
Sketch DevTools is a set of tools & utilities that help to develop [Sketch App](http://bohemiancoding.com/sketch/) plugins.

## Installation

1. [Download Sketch DevTools.zip archive file](https://github.com/turbobabr/sketch-devtools/blob/master/dist/Sketch%20DevTools.zip?raw=true).
2. Reveal plugins folder in finder ('Sketch App Menu' -> 'Plugins' -> 'Reveal Plugins Folder...').
3. Copy downloaded zip file to the revealed folder and un-zip it.
4. You are ready to go! :)

## Usage

### Shortcuts

`Command-Option-K` - Show/Hide Console

`Command-Option-Shift-K` - Clear Console

### Basic Logging

Sketch DevTools console automatically handles all the exceptions and print statements. You use the same print/log function for logging in custom script editor or external sketchplugin/js file without any additional libs.

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

I want to demonstrate it with somthing cool and totally useless! :) Here is an example of HTML formatted logging:

```JavaScript
print("<h5>Adventure Time - Bacon Pancakes - New York remix</h5>")
print("<iframe width='560' height='315' src='http://www.youtube.com/embed/cUYSGojUuAU' frameborder='0' allowfullscreen></iframe>");
```

The result will be:

![Adventure Time - Bacon Pancakes](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/jake_the_dog.png)


By default [Twitter Bootstrap](http://getbootstrap.com/) is used as CSS engine. Thus, you can freely use all the styles provided by it. Here is more useful sample that shows Bootstrap usage:

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

### Jump to Code

Console allows you to quickly open a file on certain line with your IDE of choice. Before using this feature you have to select an editor you are using for Sketch plugins development:
![Changing IDE](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/change_ide.png)

All the default `print` statements and error boxes have an url with the name of actual file and line number that generated the record. For example lets run the following script:

```JavaScript
print(selection);
print(selection.last());
```

It produces two records. The first one is just a print statement the second is an error box. Both records have the previously mentioned URL you can click on to go straight to the root of the problem:

![Jump to code URLs](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/jump_to_code_figure.png)

When you click on the error box url it will be automatically opned in the editor (WebStorm in my case):

![File opened in IDE](https://raw.githubusercontent.com/turbobabr/sketch-devtools/master/docs/jump_to_code_result.png)


## Roadmap

- [ ] A separate `console` CocoaScript module similar to the WebKit console that utilizes all the features of Sketch DevTools Console tab.
- [ ] Symbols Explorer. A separate tab panel that contains a Sketch classes reference.
- [ ] Custom script runner. The same thing as built-in Sketch custom script dialog but embedded right into DevTools panel.
- [ ] Console prompt to quickly evaluate JS expressions.

## Version history

> The project is under development...

## Feedback

If you discover any issue or have any suggestions for improvement of the plugin, please [open an issue](https://github.com/turbobabr/sketch-devtools/issues) or find me on twitter [@turbobabr](http://twitter.com/turbobabr).

## License

The MIT License (MIT)

Copyright (c) 2014 Andrey Shakhmin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.