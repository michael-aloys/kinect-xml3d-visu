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
 * Stores the scaling parameters and the current pose data for each user Kinect
 * tracks. 
 * 
 * @author Michael Hedderich, Magdalena Kaiser, Dushyant Mehta, Guillermo Reyes
 * Last modified: 2015/09/24
 */

#ifndef Human_h
#define Human_h

#include "stdafx.h"
#include <string>
#include <iostream>
#include <sstream>

class Human
{
public:
	int skeletonId;
	std::stringstream dataStream;
	double scaleFactorUpperBody = 1;
	double scaleFactorLowerBody = 1;

	Human(int id);
	Human();

};


#endif

