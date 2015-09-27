# kinect-xml3d-visu
Visualization of up to 6 users in real time in the browser using Kinect 
and XML3D.

# About
This set of programs can be used to track up to six people using Kinect 
for Windows v2 and visualize them in real time inside the browser in 3D. We use 
[XML3D](http://xml3d.org/) and Xflow which allow to display 3D
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

#Extending and changing this project
This project can and has been used as basis for combining other 
tracking hardware with XML3D. Our work on the Kinect and retargeting part
can also be used for other forms of tracking and visualization. 
We have created a [presentation](https://github.com/michael-aloys/kinect-xml3d-visu/blob/master/presentation/VisualizationHuman_TechincalDetails.pdf)
 that explains some of the technical details of our implementation. 
 If you still have questions or remarks, do not hesitate to contact us.

#Compiling, executing and using

## Client - online version
Just open the online-version.html in your browser. It expects the 
tracking server to be running at the URL defined on the lower part of the page 
(default: http://localhost:55004).

In theory, XML3D supports all modern browsers. We have experienced some
problems with a stricter Cross-Origin-Policy in Google Chrome and 
Microsoft Edge when starting the client from the local file system. The
system has been tested successfully with Firefox 41. 

## Server
The server is written in C++. To build the server, you need to install 
and link the Kinect for Windows v2 library. Additionally, you need to 
add the Winsock library (WS2_32.LIB, WINSOCK32.LIB or something similar).

The official Kinect v2 library is unfortunately limited to Windows 8 and
above. If you want to make it run on a different platform, you have
to replace the tracking code in MultiThreadingKinectServer and the 
code in socket.cpp.

## Model
The model was created using MakeHuman. The armature/bones were replaced
using Blender with a skeleton similar to the one Kinect uses. 
In the model directory you can find the Blender file of the modified model.
You can export it using a Blender-XML3D 
[exporter](https://github.com/ksons/xml3d-blender-exporter). The exported
model is also part of the client code.

## Retargeting
The retrageting directoy contains the matlab code used to calculate
the transformation matrices necessary to transform a recorded pose
from Kinect to the same pose in Blender/XML3D. We use these transformations
to retarget the pose data received from Kinect inside the client's Xflow
code. This improves the quality of the visualization strongly. Retargeting
only needs to be done once per model. So you do not need to do this, if
you just want to run the visualization. For different tracking systems 
and/or models, this process needs to be repeated.

## Client - offline version
This is an old prototype of the client that visualizes prerecorded
movements (stored as sequence of poses in a file) instead of 
connecting to the server.

Since the original version of this code is from the beginning of 
the development phase, it lacked many improvements, such as the improved
retargeting and the scaling functionality. The main reason this old offline
version is part of the repository is because it is a useful tool when 
porting the system from Kinect to another tracking device (so you can
prerecord some poses and work on the skeleton, retargeting, etc. without 
anyone moving in front of the tracking device all the time).

The code was updated to include the new model and part of the retargeting.
But due to missing scale information, it won't look that good. But its 
just for development, anyways.

## Presentation
The repository includes a presentation that explains the structure
of the system, technical details, open problems and todos, etc. 


#People
The authors of this project are Michael Hedderich, Magdalena Kaiser, 
Dushyant Mehta and Guillermo Reyes. Our advisers are Ingo Zinnikus
and Kristian Sons. This project is a result of the seminar
"Cobots - Cooperative Robots" at Saarland University, Germany
(summer semester 2015).







