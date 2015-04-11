//Begin page main
//Declare any variables shared between functions here
    
    //Constants
    int VECTOR_LENGTH;
	float ERROR_MARGIN;
	float POSITION_RESOLUTION;
	int X_AXIS;
	int Y_AXIS;
	int Z_AXIS;
	
	//Position of SPHERE
	float xPosition;
	float yPosition;
	float zPosition;
	float DeathStarPosition[3];
	float TargetPosition[3];
	
	//A unit vector direction for the satellite to poin toward
	float xAttitude;
	float yAttitude;
	float zAttitude;
	float DeathStarAttitude[3];
	
	//Closed-loop x, y, and z velocity vector
	float xVelocity;
	float yVelocity;
    float zVelocity;
    float DeathStarVelocity[3];
    
    //Closed-loop target rotation rate  
    float xAttitudeRotationRate;
    float yAttitudeRotationRate;
    float zAttitudeRotationRate;
    float DeathStarAttitudeRotationRate[3];
    
    //Open-loop x, y, and z linear forces 
    float xLinearForce;
    float yLinearForce;
    float zLinearForce;
    float DeathStarLinearForce[3];
    
    //Open-loop x, y, and z rotation torques
    float xTorqueForce;
    float yTorqueForce;
    float zTorqueForce;
    float DeathStarTorqueForce[3];
    
    //Time is second since start o f mission
    int MET;
    
    float debugTelemetryArray[7];
    
    //Death Star State Vector
    float DeathStarStateVector[12];

void init(){
	//This function is called once when your code is first loaded.

	//IMPORTANT: make sure to set any variables that need an initial value.
	//Do not assume variables will be set to 0 automatically!
	
	VECTOR_LENGTH = 3;
	ERROR_MARGIN = 0.03;         //0.03 meters = 3 cm
	POSITION_RESOLUTION = 0.01;  //0.01 meters = 1 cm
	X_AXIS = 0;
	Y_AXIS = 1;
	Z_AXIS = 2;
	
	//Position of SPHERE
	xPosition = 0.0;
	yPosition = 0.0;
	zPosition = 0.0;
	
	//A unit vector direction for the satellite to poin toward
	xAttitude = 0.0;
	yAttitude = 0.0;
	zAttitude = 0.0;
	
	//Closed-loop x, y, and z velocity vector
	xVelocity = 0.0;
	yVelocity = 0.0;
    zVelocity = 0.0;
    
    //Closed-loop target rotation rate  
    xAttitudeRotationRate = 0.0;
    yAttitudeRotationRate = 0.0;
    zAttitudeRotationRate = 0.0;
    
    //Open-loop x, y, and z linear forces 
    xLinearForce = 0.0;
    yLinearForce = 0.0;
    zLinearForce = 0.0;
    
    //Open-loop x, y, and z rotation torques
    xTorqueForce = 0.0;
    yTorqueForce = 0.0;
    zTorqueForce = 0.0;

    
    //Time is second since start o f mission
    MET = 0;
    
	DeathStarStateVector[0] = DeathStarPosition[0]; 
	DeathStarStateVector[1] = DeathStarPosition[1]; 
	DeathStarStateVector[2] = DeathStarPosition[2]; 
	DeathStarStateVector[3] = DeathStarVelocity[0];
	DeathStarStateVector[4] = DeathStarVelocity[1];
	DeathStarStateVector[5] = DeathStarVelocity[2];
	DeathStarStateVector[6] = DeathStarAttitude[0];
	DeathStarStateVector[7] = DeathStarAttitude[1];
	DeathStarStateVector[8] = DeathStarAttitude[2];
	DeathStarStateVector[9] = DeathStarAttitudeRotationRate[0];
	DeathStarStateVector[10] = DeathStarAttitudeRotationRate[1];
	DeathStarStateVector[11] = DeathStarAttitudeRotationRate[2];
}

void loop(){
	//This function is called once per second.  Use it to control the satellite.
	
	//http://static.zerorobotics.mit.edu/docs/tutorials/ZR_user_API.pdf
	//http://static.zerorobotics.mit.edu/docs/tutorials/setAttitudeTarget.pdf
	//http://static.zerorobotics.mit.edu/docs/tutorials/AppliedConditionals.pdf
	
	//http://www.cplusplus.com/reference/cstdio/printf/
	
	int index;
	float moveVector[3] = {0.0, 0.0, 0.0};
	 
	MET =  api.getTime();
	DEBUG(("Mission Elapse Time (MET) is MET %d", MET));
	
	api.getMyZRState(DeathStarStateVector);
	api.setDebug(debugTelemetryArray);
	
	moveVector[0] = 3;
	moveVector[1] = 2;
	moveVector[2] = 1;
	
	mathVecAdd(DeathStarPosition, DeathStarPosition, moveVector, VECTOR_LENGTH);
	api.setPositionTarget(DeathStarPosition);
	api.setAttitudeTarget(DeathStarAttitude);
	
	
	for (index = X_AXIS; index <= Z_AXIS; index++){
	  if (DeathStarStateVector[index] < (TargetPosition[index] - ERROR_MARGIN)){
	    api.setPositionTarget(DeathStarPosition[index] + POSITION_RESOLUTION);    
	  }
	  else{
	    if (index = X_AXIS){
	      DEBUG(("X axis locked"));    
	    }
	    if (index = Y_AXIS){
	      DEBUG(("Y axis locked"));    
	    }
	    if (index = Z_AXIS){
	      DEBUG(("Z axis locked"));    
	    }
	  }    
	}//END FOR LOOP 
	
}

//End page main
