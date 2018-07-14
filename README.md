# ShapeConverter
converts Adobe Illustrator shapes (saved as Adobe Illustrator 8 files) into human readable Processing code

### What ShapeConverter does

ShapeConverter generates Processing code for simple paths found in an Adobe Illustrator 8 file. Using it, you can draw shapes using Adobe Illustrator (or any drawing application that exports Adobe Illustrator version 8 files), and convert those shapes to code that you can use in a Processing app.

Note that the following are NOT supported:
* compound paths
* gradient colours
* multiple document layers

### Why ShapeConverter is useful

Sometimes you may want to draw a simple shape in Illustrator and later on manipulate individual points of it in a Processing app.
If you have complex shapes (i.e. shapes with layers, or multiple colors), then you can use Geomerative ***link***(http://www.ricardmarxer.com/geomerative/) , but this might be overkill for your needs. If you just want to draw some simple shapes and then get the code to draw them in Processing, then ShapeConverter might be what you need. 

I made this project mainly for myself, as I often want to draw my shapes first in Illustrator and then use them inside Processing or openFrameworks. Since I’ve found such a tool very useful for me over the last almost 20 years, I would like to share this one with you. 

For a while I used a self-written Director application, after that I used an Illustrator extension called Drawscript ***link*** (https://forums.adobe.com/thread/1175097), but it stopped working at some point. Rather than go through the hassle of learning how to make a an Illustrator plugin, I thought it would be easier and more useful to make my own conversion app instead.

It could be better, I know. Instead of getting one vertex point and one bezierVertex with three points, I could have worked harder so that you get one bezier curve with all 4 points in one line, but I trust in you that you can fix this in your Processing code yourself if you feel the need to. ;)

### How to use ShapeConverter

1) Open Illustrator and create a new file. Set the units to Pixels, and to make things easier, set the width and height to the same size as your Processing project.

(If you set your document size to the same as your Processing project size, you can get an overall idea of how big the shapes will be in your Processing project while you are drawing them in Illustrator.)



