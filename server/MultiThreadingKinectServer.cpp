/**
    Visualization of a Human using Kinect and XML3D - Prototype 2
    Copyright (C) 2015  Michael Hedderich, Magdalena Kaiser, Dushyant Mehta, Guillermo Reyes

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

/**
 * Server that consists of two parallel threads. One thread queries poses from
 * Kinect and converts them into the xml format. The other thread is a simple
 * webserver that answers requests from clients with the current xml-formated
 * pose.
 * 
 * @author Michael Hedderich, Magdalena Kaiser, Dushyant Mehta, Guillermo Reyes
 * Last modified: 2015/09/24
 */

#include "stdafx.h"
#include <string.h>
#include <iostream>
#include <chrono>
#include <thread>
#include "socket.h"
#include <string>
#include <sstream>
#include <iostream>
#include <Windows.h>
#include <Kinect.h>
#include <fstream>
#include <chrono>
#include <thread>
#include <mutex>
#include <math.h>
#include "Human.h"

#define LOCAL_SERVER_PORT 55004 //port to connect to

using namespace std;

//shared string between threads
static string xmlStreamingString;
static mutex mtx;
//flag to signal user termination request
static bool terminateFlag = false;

//initialize constants with meassured values
const double UPPER_ARM = 0.89;
const double FORE_ARM = 0.72;
const double THIGH = 1.4;
const double SHOULDER = 0.61;
const double SPINE_BASE = 1.02;
const double SPINE_CHEST = 0.745;
const double HIP = 0.28;

template<class Interface>
inline void SafeRelease(Interface *& pInterfaceToRelease)
{
	if (pInterfaceToRelease != NULL){
		pInterfaceToRelease->Release();
		pInterfaceToRelease = NULL;
	}
}

//calculate scaling regarding to values got from blender
double calculateBoneScaling(Joint joint1, Joint joint2, double blenderValue ) {
	double scale;
	double dist;
	dist = sqrt(pow((joint1.Position.X - joint2.Position.X), 2) + (pow((joint1.Position.Y - joint2.Position.Y), 2) + pow((joint1.Position.Z - joint2.Position.Z), 2)));
	scale = dist / blenderValue;
	return scale;
}

//calculate scaling  for upper part of the body
double calculateAverageScaleFactorUpperBody(Joint *joint, double oldUpperScale) {

	double scale = 1;
	double lambda = 0.1;
	double scaleUpperArmLeft = 0;
	double scaleUpperArmRight = 0;
	double scaleForeArmLeft = 0;
	double scaleForeArmRight = 0;
	double scaleSpineBase = 0;
	double scaleSpineChest = 0;

	int count = 0;
	//calculate scaling of left upper arm if available
	if (joint[4].TrackingState != 0 && joint[5].TrackingState != 0) {
		scaleUpperArmLeft = calculateBoneScaling(joint[4], joint[5], UPPER_ARM);
		count++;
	}
	//calculate scaling of right upper arm if available
	if (joint[8].TrackingState != 0 && joint[9].TrackingState != 0) {
		scaleUpperArmRight = calculateBoneScaling(joint[8], joint[9], UPPER_ARM);
		count++;
	}
	//calculate scaling of left fore arm if available
	if (joint[5].TrackingState != 0 && joint[6].TrackingState != 0) {
		scaleForeArmLeft = calculateBoneScaling(joint[5], joint[6], FORE_ARM);
		count++;
	}
	//calculate scaling of right fore arm if available
	if (joint[9].TrackingState != 0 && joint[10].TrackingState != 0) {
		scaleForeArmRight = calculateBoneScaling(joint[9], joint[10], FORE_ARM);
		count++;
	}
	//calculate scaling of spine base if available
	if (joint[0].TrackingState != 0 && joint[1].TrackingState != 0) {
		scaleSpineBase = calculateBoneScaling(joint[0], joint[1], SPINE_BASE);
		count++;
	}
	//calculate scaling of spine chest if available
	if (joint[1].TrackingState != 0 && joint[20].TrackingState != 0) {
		scaleSpineChest = calculateBoneScaling(joint[1], joint[20], SPINE_CHEST);
		count++;
	}
	
	//calculate average scaling
	if (count > 0)
		scale = (scaleUpperArmLeft + scaleUpperArmRight + scaleForeArmLeft + scaleForeArmRight + scaleSpineBase + scaleSpineChest) / count;
	
	//smooth with scaling value from previous frame
	if (oldUpperScale != -1) {
		scale = lambda * scale + (1 - lambda) * oldUpperScale;
	}

	return scale;
}

//calculate scaling for lower part of the body
double calculateAverageScaleFactorLowerBody(Joint *joint, double oldLowerScale) {
	
	double scale = 1;
	double lambda = 0.1;
	double scaleThighLeft = 0;
	double scaleThighRight = 0;
	int count = 0;

	//get values of left thigh if available
	if (joint[12].TrackingState != 0 && joint[13].TrackingState != 0) {
		scaleThighLeft = calculateBoneScaling(joint[12], joint[13], THIGH);
		count++;
	}
	//get values of right thigh if available
	if (joint[16].TrackingState != 0 && joint[17].TrackingState != 0) {
		scaleThighRight = calculateBoneScaling(joint[16], joint[17], THIGH);
		count++;
	}

	//calculate average
	if (count > 0)
		scale = (scaleThighLeft + scaleThighRight) / count;

	//smooth with scaling values from previous frame
	if (oldLowerScale != -1) {
		scale = lambda * scale + (1 - lambda) * oldLowerScale;
	}

	return scale;
}


//receive and process data from kinect
void kinectWorkerFunc()
{
	cout << "Worker: running" << endl;

	//initialize kinect specific variables
	IMultiSourceFrameReader *reader;
	IKinectSensor* pSensor = nullptr;
	HRESULT hResult = S_OK;
	hResult = GetDefaultKinectSensor(&pSensor);
	if (FAILED(hResult)){
		cerr << "Error : GetDefaultKinectSensor" << endl;
		exit(-1);
	}

	hResult = pSensor->Open();
	if (FAILED(hResult)){
		cerr << "Error : IKinectSensor::Open()" << endl;
		exit(-1);
	}

	IBodyFrameSource* pBodySource;
	hResult = pSensor->get_BodyFrameSource(&pBodySource);
	if (FAILED(hResult)){
		cerr << "Error : IKinectSensor::get_BodyFrameSource()" << endl;
		exit(-1);
	}

	IBodyFrameReader* pBodyReader;
	hResult = pBodySource->OpenReader(&pBodyReader);
	if (FAILED(hResult)){
		cerr << "Error : IBodyFrameSource::OpenReader()" << endl;
		exit(-1);
	}

	// Coordinate Mapper
	ICoordinateMapper* pCoordinateMapper;
	hResult = pSensor->get_CoordinateMapper(&pCoordinateMapper);
	if (FAILED(hResult)){
		cerr << "Error : IKinectSensor::get_CoordinateMapper()" << endl;
		exit(-1);
	}

	//maps position of joint in kinect hierachy to position expected by xml3D
	int positionMap[] = { 0, 0, 1, 20, 20, 4, 5, 6, 20, 8, 9, 10, 0, 16, 17, 0, 12, 13 };
	int rotationMap[] = { 0, 1, 20, 2, 4, 5, 6, 7, 8, 9, 10, 11, 16, 17, 18, 12, 13, 14 };
	//reduced number of joints
	const int XML_JOINT_COUNT = 18;
	const int scalarCorrection = 1;
	const int zCorrection = 0;//-3;

	long keyFrameCounter = 0;
	double scaleFactorUpperBody = -1;
	double scaleFactorLowerBody = -1;

	//track up to 6 persons, save ids in data structure
	Human human[6];
	for (int i = 0; i < BODY_COUNT; i++)
	{
		human[i].skeletonId = i;
	}

	while (1) {
		//go through all tracked skeletons, initialize data stream
		for (int i = 0; i < BODY_COUNT; i++)
		{
			human[i].dataStream.str("");
		}
		
		//TODO: clarify: any reason why two times keyFrameCounter++??
	//	keyFrameCounter++;

		stringstream xmlStream;
		//write xml3d header into stream
		xmlStream << "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n"
			<< "<xml3d xmlns = \"http:\/\/www.xml3d.org\/2009\/xml3d\">\n"
			<< "<data id = 'animation'>";

		keyFrameCounter++;
		IBodyFrame *pBodyFrame = nullptr;
		hResult = pBodyReader->AcquireLatestFrame(&pBodyFrame);
		if (SUCCEEDED(hResult))
		{
			IBody* pBody[BODY_COUNT] = { 0 };
			hResult = pBodyFrame->GetAndRefreshBodyData(BODY_COUNT, pBody);
			if (SUCCEEDED(hResult))
			{
				/*joint*/
				for (int count = 0; count < BODY_COUNT; count++){
					BOOLEAN bTracked = false;
					hResult = pBody[count]->get_IsTracked(&bTracked);
					if (SUCCEEDED(hResult) && bTracked){
						//get joints and joint orientation
						Joint joint[JointType::JointType_Count];
						JointOrientation orientation[JointType::JointType_Count];
						hResult = pBody[count]->GetJointOrientations(JointType::JointType_Count, orientation);
						if (SUCCEEDED(hResult)){
							hResult = pBody[count]->GetJoints(JointType::JointType_Count, joint);
							if (SUCCEEDED(hResult)){
								//get tracking information for each tracked person and each joint
								human[count].dataStream << "<int id = 'tracking" << human[count].skeletonId << "' name = 'tracking' key = '1'>\n";
								for (int type = 0; type < XML_JOINT_COUNT; type++){
									human[count].dataStream
										<< joint[positionMap[type]].TrackingState << " ";
								}
								//get location for each tracked person and each joint
								human[count].dataStream << "</int>\n<float3 id = 'location" << human[count].skeletonId<<"' name = 'location' key = '1'>\n";
								for (int type = 0; type < XML_JOINT_COUNT; type++){
									human[count].dataStream
										<< (joint[positionMap[type]].Position.X * scalarCorrection) << " "
										<< (joint[positionMap[type]].Position.Y *scalarCorrection) << " "
										<< (joint[positionMap[type]].Position.Z * scalarCorrection + zCorrection) << " ";
								}
								//get rotation for each tracked person and each joint
								human[count].dataStream << "</float3>\n<float4 id = 'rotation_quaternion" << human[count].skeletonId << "' name='rotation_quaternion' key='1'>\n";
								for (int type = 0; type < XML_JOINT_COUNT; type++){
									human[count].dataStream
										<< orientation[rotationMap[type]].Orientation.x << " "
										<< orientation[rotationMap[type]].Orientation.y << " "
										<< orientation[rotationMap[type]].Orientation.z << " "
										<< orientation[rotationMap[type]].Orientation.w << " ";
								}
								human[count].dataStream << "</float4>\n";
								//calculate scaling
								scaleFactorUpperBody = calculateAverageScaleFactorUpperBody(joint, scaleFactorUpperBody);
								scaleFactorLowerBody = calculateAverageScaleFactorLowerBody(joint, scaleFactorLowerBody);
								//get scaling for each tracked person and each joint
								human[count].dataStream << "<float3 id = 'scale" << human[count].skeletonId << "' name = 'scale' key = '1'>\n";
								for (int type = 0; type < XML_JOINT_COUNT; type++) {
									//differentiate between lower and upper part of body
									if (type <= 11)
										human[count].dataStream
										<< 3 * scaleFactorUpperBody << " "
										<< 3 * scaleFactorUpperBody << " "
										<< 3 * scaleFactorUpperBody << " ";
									else {
										human[count].dataStream
											<< 3 * scaleFactorLowerBody << " "
											<< 3 * scaleFactorLowerBody << " "
											<< 3 * scaleFactorLowerBody << " ";
									}
								}
								human[count].dataStream << "</float3>\n";
							}
						}
					}
				}
			}
			for (int count = 0; count < BODY_COUNT; count++)
				SafeRelease(pBody[count]);
		}
		SafeRelease(pBodyFrame);
		//write data from each tracked person into one stream
		for (int i = 0; i < BODY_COUNT;i++)
		{
			xmlStream << human[i].dataStream.str();
		}

		xmlStream << "</data>\n </xml3d>";

		mtx.lock();
		//assign stream to global variable so that it can be used in the other threads
		xmlStreamingString.assign(xmlStream.str().c_str());
		mtx.unlock();
	
		this_thread::sleep_for(chrono::milliseconds(32)); //kinect 30 frames per second
		if (terminateFlag) 
			break;
	}
	if (pSensor){
		pSensor->Close();
	}
	SafeRelease(pSensor);

	cout << "Worker: finished" << endl;
	exit(1);
}

//thread to send xml data to client
void sendXMLPoseHandlerFunc(socket_t* sock2) {

	string xmlString;
	mtx.lock();
	//write streaming data into new string
	xmlString.assign(xmlStreamingString.c_str());
	//create stream to combine header and data string
	stringstream httpStream;
	httpStream << "HTTP\/1.1 200 OK\r\nContent-Length: " << xmlString.length() <<
		"\r\nAccess-Control-Allow-Origin: *"
		<< "\r\nContent-type: application/xml \r\n\r\n" + xmlString;
	mtx.unlock();

	string message = httpStream.str();
	//send message to client
	TCP_send(sock2, message.c_str(), message.length());
	//sleep necessary to avoid messages getting lost. Not a stable solution.
	this_thread::sleep_for(chrono::milliseconds(100));
	close_socket(sock2);
	delete sock2;
}

//thread to handle incoming connection
void connectionHandlerFunc(socket_t sock1)
{
	while (1) {
		socket_t* sock2 = new socket_t();
		accept_socket(&sock1, sock2); //currently this is used only once, but would also allow several parallel connections

		//start thread to send data to client
		thread sendXMLPoseThread(sendXMLPoseHandlerFunc,sock2);
		//std::cout << "Connection established." << std::endl;
		sendXMLPoseThread.detach();
		if (terminateFlag)
			break;
	}
	exit(1);
}


//main method: starts threads and initialize socket
int _tmain(int argc, _TCHAR* argv[]) {

	//start kinect thread
	thread kinectWorkerThread(kinectWorkerFunc);

	//Init socket1
	socket_t sock1;
	int addrlen;
	sock1 = create_socket(AF_INET, SOCK_STREAM, 0);//AF_INET = IPV4, SOCK_STREAM = for TCP, 0 -> use standard protocol for this type => TCP
	atexit(cleanup);
	bind_socket(&sock1, INADDR_ANY, LOCAL_SERVER_PORT);
	listen_socket(&sock1);
	addrlen = sizeof(struct sockaddr_in);
	cout << "Listening on port " << LOCAL_SERVER_PORT << " for incomming connections." << endl;
	//start thread to handle  incomming connections
	thread connectionHandlerThread(connectionHandlerFunc, sock1);

	//wait for user to stop execution
	system("pause");
	//set flag to true so that other threads can exit properly as well
	terminateFlag = true;
	close_socket(&sock1); 
	return EXIT_SUCCESS;
}


