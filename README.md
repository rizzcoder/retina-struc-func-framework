# Retinal Structure-Function Assessment Framework

## Authors  

Rijul S. Soans, PhD  
Benjamin E. Smith, PhD  
Susana T. L. Chung, OD, PhD  

Sight Enhancement Laboratory ([SELAB])  
Herbert Wertheim School of Optometry & Vision Science  
University of California, Berkeley, USA.




## Features

- 2 modes: Automatic and Manual
- Registration Quality: Multi-tiered and self-assessing automatic approach
- Automatic OCT B-scan overlay accounting for eye movements
- Overlapping OCT B-scans highlighted
- Microperimetry-style color-coded sensitivity map overlay
- User-editable Excel sheet: MAIA Test Point ID, MAIA Test Point Threshold (dB), Closest B-scan, Location of the MAIA Test Point ID from the start of the closest B-scan (pixels) and thickness of 10 retinal layers (μm)

## Software Dependencies

The framework requires the following software:

- [MATLAB R2022b] - Programming & Numeric Computing platform
- [Fiji] - Open-source image processing package
- [OCT Explorer 3.8.0] - Open-source software for OCT image segmentation

## Installation  

1. Install MATLAB from the link provided above.
2. Install FIJI/ImageJ 1.54d from the link provided above.
3. Configure FIJI to work with MATLAB by adding it to the MATLAB path. Eg. If FIJI was installed on the Desktop, then add the following to the MATLAB path: C:\Users\RS\Desktop\fiji-win64\Fiji.app\scripts


## License
MIT License

Copyright 2023  &copy; Rijul S. Soans, &copy; Benjamin E. Smith, &copy; Susana T. L. Chung  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.   


[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job.)

   [MATLAB R2022b]: <https://www.mathworks.com/products/matlab.html>
   [Fiji]: <https://imagej.net/software/fiji/>
   [OCT Explorer 3.8.0]: <https://iibi.uiowa.edu/oct-reference>
   [SELAB]: <https://selab.berkeley.edu/>
