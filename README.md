# Utilities

A library of useful scripts

## Resize and optimize

**Language**: Bash

### Description

This script will resize all images with a width larger than the value provided or the default (1280). It will also optimize all images regardless of size.

**Dependencies**: [jpegoptim](https://github.com/tjko/jpegoptim), [mogrify](https://github.com/elixir-mogrify/mogrify), [gifsicle](http://www.lcdf.org/gifsicle/) and [pngquant](https://pngquant.org)

### Usage:

Takes two arguments:

1. Path to directory
2. The image width max size. Any images wider than the provided max width will be resized to the value provided or the default 1280. Script uses pixels as the value's unit.

**Example**

```bash
$ ./resize-optimize.sh ~/Desktop 1280
```

**Output**

```bash
/Users/alan/Projects/Utilities/src/resize-optimize.sh . 1024
Start time: 2024-01-04 13:10:29
Initial Size: 102M

Resized and optimized: ./Screenshot 2024-01-04 at 1.10.02 PM.png
Resized and optimized: ./Screenshot 2024-01-04 at 1.10.10 PM.png
Resized and optimized: ./Screenshot 2024-01-04 at 1.10.16 PM.png
Resized and optimized: ./Screenshot 2024-01-04 at 1.10.08 PM.png
Resized and optimized: ./Screenshot 2024-01-04 at 1.10.18 PM.png
Resized and optimized: ./Screenshot 2024-01-04 at 1.10.13 PM.png
Resized and optimized: ./Screenshot 2024-01-04 at 1.09.58 PM.png
Resized and optimized: ./Screenshot 2024-01-04 at 1.09.54 PM.png
Resized and optimized: ./Screenshot 2024-01-04 at 1.10.05 PM.png
Image resizing and optimization completed.

End time: 2024-01-04 13:10:35

Initial Size: 102M
Final Size:    89M
You saved:     13MB
```
