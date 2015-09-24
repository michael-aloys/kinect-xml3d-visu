# kinect-xml3d-visu
Visualization of up to 6 users in real time in the browser using Kinect 
and XML3D.

# About
This set of programs can be used to track up to six people using Kinect 
v2 and visualize them in real time inside the browser in 3D. We use 
[XML3D](http://xml3d.org/) and Xflow which add allow to display 3D
content in the browser by just including a JavaScript library.

You can watch a demonstration here: 
[![YouTube Thumbnail](http://img.youtube.com/vi/WPJaDTGAIaI/1.jpg)](https://youtu.be/WPJaDTGAIaI)

There also exists a video of our first prototype:
[![YouTube Thumbnail](http://img.youtube.com/vi/BYWWkNrQdMg/3.jpg)](https://youtu.be/BYWWkNrQdMg) 

Some of its features are:
* One tracking server can work with multiple clients in parallel
* Using standard HTTP protocol and web techniques
* Automated size detection and scaling
* No initialization phase needed
* Variable number of interpolation and pose requests (for slower hardware)

This project is a result of the seminar "Cobots - Cooperative Robots" at
Saarland University (summer semester 2015).

#Extending / Using / Changing this project
This project can and has been used as basis for combining other 
tracking hardware with XML3D. Our work on the Kinect and retargeting part
can also be used for other forms of tracking and visualization. 
We have created a [presentation](https://github.com/michael-aloys/kinect-xml3d-visu/blob/master/presentation/VisualizationHuman_TechincalDetails.pdf)
 that explains some of the technical details of our implementation. 
 If you still have some questions or remarks, do not hesitate to contact us.

#People
Michael Hedderich, Magdalena Kaiser, Dushyant Mehta, Guillermo Reyes
Advisers: Ingo Zinnikus, Kristian Sons







