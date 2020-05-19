# C💚SS.css (ChartSS.css) - accessible html/css charts with markdown support

If you're viewing on github, see the html version at [here](https://rbitr.github.io/ChartS.css/).

Likewise, if you're viewing the website, you can see the github page [here](https://github.com/rbitr/ChartS.css)

## Features

- Charts directly from markdown lists via `pandoc`
- Retains accessible, semantic HTML
- No javascript or other frameworks, no external dependencies, uses only a small .css file
- Use html templates to directly create charts, or convert from markdown

The point of C💚SS.css is to allow easy creation of simple charts for documentation, data storytelling / journalism, etc. It features plots of 1-D lists, and has a custom markdown filter that converts suitably formatted lists directly to charts. It has no dependencies (other than a modern browser), and is very small compared to javascript based charting tools. The html is based on `<ul>` lists and will collapse back to readible lists in the absence of css support, making it accessible to all readers. It is open source and easily configurable according to project needs.

The non-chart elements on the html version of this page were styled with [mvp.css](https://andybrewer.github.io/mvp/). MVP.css was one of the inspirations for C💚SS.css. Although C💚SS.css turned out very differently, MVP.css got me on to the idea of having a simple, self-contained .css file that could easily transform a text page into something nice.


## Usage

__Requirements__

A modern browser that supports `css` is required. It has been tested on chrome and firefox. 

To write html directly, all you need is the C💚SS.css style file. 

[*Download C💚SS.css*](./ChartSS.css) 

See below or view source for usage.

To convert directly from markdown to html charts, you will need `pandoc` installed. Even if you never use C💚SS.css, you should still get `pandoc`. You can find information on how to install it [here](https://pandoc.org/installing.html). There is good information on markdown syntax [here](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).

Pandoc works with `chartss.lua` to parse markdown into html that uses C💚SS.css.

[*Download charts.lua*](./chartss.lua)

__Running chartss.lua__

The following command creates a stand alone html file out of a markdown file. Markdown lists conforming to the syntax discussed below will automatically be converted into charts.

```
$ pandoc -t chartss.lua infile.md > outfile.html
```

## Gallery and Markdown Syntax 

### Bar Charts:

Syntax

`(*|-) category: value`

Example

```
- Dogs: 39
- Cats: 7
- Lions: 36
- Tigers: 55
- Bears: 33
- Walruses: 30
```

Output (see html version)

- Dogs: 39 
- Cats: 7
- Lions: 36
- Tigers: 55
- Bears: 33
- Walruses: 30

### Scatter Plots:

Syntax

`(*|-) (xi,yi)`

Example

```
- (15,12)
- (0.25,6.78)
- (-.7,9)
- (-4,-6)
```

Output (see html version)

- (15,12)
- (0.25,6.78)
- (-.7,9)
- (-4,-6)


### A Regular List:

Syntax

`(*|-) List Item`

Example

```
* Cats
* Dogs
* Mice
* Men
* Lambs
* Lions
```

Output (if C💚SS.css cannot chart it, a normal list is displayed) 

* Cats
* Dogs
* Mice
* Men
* Lambs
* Lions


### Line Plot:

Syntax (constant spacing indicates a line)

```
(*|-) x1 : y1
(*|-) x1+dx : y2
(*|-) x1+2dx : y3
...
```

Example

```
* 1.5 : 3.3
* 3 : -1.2
* 4.5 : 0
* 6 : 0
* 7.5 : 1.5
* 9 : 4
* 10.5 : 8
```

Output (see html version)

* 1.5 : 3.3
* 3 : -1.2
* 4.5 : 0
* 6 : 0 
* 7.5 : 1.5
* 9 : 4
* 10.5 : 8

### Stacked Bar (a pie chart for grownups):

Syntax (add a plus sign to the end of labels)

`(*|-) category: label+`

Example

```
* Dogs : 20+
* Cats : 10+
* Lions : 30+
* Tigers : 15+
* Bears : 20+
```

Output (see html version)

* Dogs : 20+
* Cats : 10+
* Lions : 30+
* Tigers : 15+
* Bears : 20+

### Waterfall Chart

Syntax

```
(*|-) total: value=
(*|-) category1: value1+
(*|-) category2: value2+
...
```

Output (see html version)

* Animals: 95=
* Dogs : 20+
* Cats : 10+
* Lions : 30+
* Tigers : 15+
* Bears : 20+

## HTML templates

Note: this html was generated using the defaults of `chartss.lua`. This means that 1. More or fewer ticks can be added on the axes and 2. There has been som autoscaling applied to the chart areas. If you are creating manual charts, you will have to scale between the label values and the percentage values that the charting functions use. 

### Bar Chart

```html
<ul class="BarList">
<div class="PlotOuterContainer">
<div class="YTicks">
<span class="TickLabel" style="--tick-label:'99.8'"></span>
<span class="TickLabel" style="--tick-label:'79.8'"></span>
<span class="TickLabel" style="--tick-label:'59.9'"></span>
<span class="TickLabel" style="--tick-label:'39.9'"></span>
<span class="TickLabel" style="--tick-label:'20.0'"></span>
<span class="TickLabel" style="--tick-label:'0.0'"></span>
</div>
<div class="FlexColumn StackFlexColumn">
<li class="BarBlock" style="--stack-height:20.1%">Dogs: 20</li>
<li class="BarBlock" style="--stack-height:10.0%">Cats: 10</li>
<li class="BarBlock" style="--stack-height:30.1%">Lions: 30</li>
<li class="BarBlock" style="--stack-height:15.0%">Tigers: 15</li>
<li class="BarBlock" style="--stack-height:20.1%">Bears: 20</li>
</div></div>
</ul>
```

### Scatter Plot

```html
<div class="PlotOuterContainer">
<div class="YTicks">
<span class="TickLabel" style="--tick-label:'12.9'"></span>
<span class="TickLabel" style="--tick-label:'9.0'"></span>
<span class="TickLabel" style="--tick-label:'5.0'"></span>
<span class="TickLabel" style="--tick-label:'1.0'"></span>
<span class="TickLabel" style="--tick-label:'-3.0'"></span>
<span class="TickLabel" style="--tick-label:'-6.9'"></span>
</div>
<div class="FlexColumn"> <div class="ScatterMainContainer">
<div class="ScatterPoint" style="--pixel-x-percent:95%;--pixel-y-percent:95%"><li class="ScatterValue">(15,12)</li></div>
<div class="ScatterPoint" style="--pixel-x-percent:25%;--pixel-y-percent:69%"><li class="ScatterValue">(0.25,6.78)</li></div>
<div class="ScatterPoint" style="--pixel-x-percent:20%;--pixel-y-percent:80%"><li class="ScatterValue">(-0.7,9)</li></div>
<div class="ScatterPoint" style="--pixel-x-percent:5%;--pixel-y-percent:5%"><li class="ScatterValue">(-4,-6)</li></div>
</div><div class="BarLi"> <span class="XTicks">
<span class="TickLabel" style="--tick-label:'-5.0'"></span>
<span class="TickLabel" style="--tick-label:'-0.8'"></span>
<span class="TickLabel" style="--tick-label:'3.4'"></span>
<span class="TickLabel" style="--tick-label:'7.6'"></span>
<span class="TickLabel" style="--tick-label:'11.8'"></span>
<span class="TickLabel" style="--tick-label:'15.9'"></span>
</span></div></div></div>
```

### Line Plot

(For line plots, the lower y-value of each line segment always has to come first, as `--line-y-from`, with the direction specified by `--line-slope`. Also note that a zero slope line needs its `border-top-style:solid` property set as shown below as a hack to show the line.

```html
<div class="PlotOuterContainer">
<div class="YTicks">
<span class="TickLabel" style="--tick-label:'8.4'"></span>
<span class="TickLabel" style="--tick-label:'6.4'"></span>
<span class="TickLabel" style="--tick-label:'4.4'"></span>
<span class="TickLabel" style="--tick-label:'2.4'"></span>
<span class="TickLabel" style="--tick-label:'0.4'"></span>
<span class="TickLabel" style="--tick-label:'-1.7'"></span>
</div>
<div class="FlexColumn"> <div class="LineOuterContainer">
<li class="InvisibleListItem">1.5 : 3.3</li>
<div class="SegmentContainer"  style="--line-y-from:4.5%;--line-y-to:49.0%;--line-slope:to top right"> 
<li class="LineSegment">3 : -1.2</li> 
<div class="LineBlock"></div> </div>
<div class="SegmentContainer"  style="--line-y-from:4.5%;--line-y-to:16.3%;--line-slope:to top left"> 
<li class="LineSegment">4.5 : 0</li> 
<div class="LineBlock"></div> </div>
<div class="SegmentContainer"  style="--line-y-from:16.3%;--line-y-to:16.3%;--line-slope:to top left"> 
<li class="LineSegment" style="border-top-style:solid">6 : 0</li> 
<div class="LineBlock"></div> </div>
<div class="SegmentContainer"  style="--line-y-from:16.3%;--line-y-to:31.2%;--line-slope:to top left"> 
<li class="LineSegment">7.5 : 1.5</li> 
<div class="LineBlock"></div> </div>
<div class="SegmentContainer"  style="--line-y-from:31.2%;--line-y-to:55.9%;--line-slope:to top left"> 
<li class="LineSegment">9 : 4</li> 
<div class="LineBlock"></div> </div>
<div class="SegmentContainer"  style="--line-y-from:55.9%;--line-y-to:95.5%;--line-slope:to top left"> 
<li class="LineSegment">10.5 : 8</li> 
<div class="LineBlock"></div> </div>
</div><div class="BarLi"> <span class="XTicks">
<span class="TickLabel" style="--tick-label:'1.1'"></span>
<span class="TickLabel" style="--tick-label:'3.0'"></span>
<span class="TickLabel" style="--tick-label:'5.0'"></span>
<span class="TickLabel" style="--tick-label:'7.0'"></span>
<span class="TickLabel" style="--tick-label:'9.0'"></span>
<span class="TickLabel" style="--tick-label:'10.9'"></span>
</span></div></div></div>
```

### Stacked Bar Chart

```html
<ul class="BarList">
<div class="PlotOuterContainer">
<div class="YTicks">
<span class="TickLabel" style="--tick-label:'99.8'"></span>
<span class="TickLabel" style="--tick-label:'79.8'"></span>
<span class="TickLabel" style="--tick-label:'59.9'"></span>
<span class="TickLabel" style="--tick-label:'39.9'"></span>
<span class="TickLabel" style="--tick-label:'20.0'"></span>
<span class="TickLabel" style="--tick-label:'0.0'"></span>
</div>
<div class="FlexColumn StackFlexColumn">
<li class="BarBlock" style="--stack-height:20.1%">Dogs: 20</li>
<li class="BarBlock" style="--stack-height:10.0%">Cats: 10</li>
<li class="BarBlock" style="--stack-height:30.1%">Lions: 30</li>
<li class="BarBlock" style="--stack-height:15.0%">Tigers: 15</li>
<li class="BarBlock" style="--stack-height:20.1%">Bears: 20</li>
</div></div>
</ul>
```

### Waterfall Chart

(You need to account for the bar height as well as the padding that uses a `LineBlock`)

```html
<div class="PlotOuterContainer">
<div class="YTicks">
<span class="TickLabel" style="--tick-label:'99.8'"></span>
<span class="TickLabel" style="--tick-label:'79.8'"></span>
<span class="TickLabel" style="--tick-label:'59.9'"></span>
<span class="TickLabel" style="--tick-label:'39.9'"></span>
<span class="TickLabel" style="--tick-label:'20.0'"></span>
<span class="TickLabel" style="--tick-label:'0.0'"></span>
</div>
<div class="FlexColumn"> <div class="LineOuterContainer">
<div class="WaterfallContainer"> 
<li class="BarBlock" style="--stack-height:95.2%;width:100%">Animals: 95</li> 
<div class="LineBlock" style="--line-y-from:0.0%"></div> </div>
<div class="WaterfallContainer"> 
<li class="BarBlock" style="--stack-height:20.1%;width:100%">Dogs : 20</li> 
<div class="LineBlock" style="--line-y-from:75.2%"></div> </div>
<div class="WaterfallContainer"> 
<li class="BarBlock" style="--stack-height:10.0%;width:100%">Cats : 10</li> 
<div class="LineBlock" style="--line-y-from:65.2%"></div> </div>
<div class="WaterfallContainer"> 
<li class="BarBlock" style="--stack-height:30.1%;width:100%">Lions : 30</li> 
<div class="LineBlock" style="--line-y-from:35.1%"></div> </div>
<div class="WaterfallContainer"> 
<li class="BarBlock" style="--stack-height:15.0%;width:100%">Tigers : 15</li> 
<div class="LineBlock" style="--line-y-from:20.1%"></div> </div>
<div class="WaterfallContainer"> 
<li class="BarBlock" style="--stack-height:20.1%;width:100%">Bears : 20</li> 
<div class="LineBlock" style="--line-y-from:-0.0%"></div> </div>
</div><div class="BarLi"> <span class="XTicks">
</span></div></div></div>
```

