# C💚SS.css (ChartSS.css) - accessible html/css charts with markdown support

If you're viewing on github, see the html version at <https://rbitr.github.io/ChartS.css/>

## Features

- Charts directly from markdown lists via `pandoc`
- Retains accessible, semantic HTML
- No javascript, uses only a small .css file
- Parse with `pandoc` or use as templates

## Usage

```
$ pandoc -t chartss.lua infile.md > outfile.html
```

## Details Coming Soon
...

## Gallery 

### Bar Charts:
(see html version)

- Dogs: 39 
- Cats: 7
- Lions: 36
- Tigers: 55
- Bears: 33
- Walruses: 30

### Scatter Plots:
(see html version)

- (15,12)
- (0.25,6.78)
- (-.7,9)
- (-4,-6)


### A Regular List:

* Cats
* Dogs
* Mice
* Men
* Lambs
* Lions



### Line Plot:
(see html version)

* 1.5 : 3.3
* 3 : -1.2
* 4.5 : 0
* 6 : .25
* 7.5 : 1.5
* 9 : 4
* 10.5 : 8

### Stacked Bar (a pie chart for grownups):
(see html version)

* Dogs : 20+
* Cats : 10+
* Lions : 30+
* Tigers : 15+
* Bears : 20+

### Waterfall Chart
(see html version)

* Animals: 95=
* Dogs : 20+
* Cats : 10+
* Lions : 30+
* Tigers : 15+
* Bears : 20+

