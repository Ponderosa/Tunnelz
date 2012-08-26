// method to generate a triangle wave
float triangleWave(float theAngle) {
  
  theAngle = unwrap(theAngle);
  
  if (theAngle < -HALF_PI)
    return -2 - 2*theAngle/PI;
  else if (theAngle > HALF_PI)
    return 2 - 2*theAngle/PI;
  else
    return 2*theAngle/PI;
}

// method to generate a square wave with smoothed edges
float squareWave(float theAngle, float smoothing) {
 
  theAngle = unwrap(theAngle);
  
  if (theAngle > -smoothing && theAngle < smoothing)
    return theAngle/smoothing;
    
  else if (theAngle > PI - smoothing)
    return (PI/smoothing) - theAngle/smoothing;
    
  else if (theAngle < smoothing - PI)
    return -(PI/smoothing) - theAngle/smoothing;
  else if (theAngle > 0) 
    return 1;
  else
    return -1;
    
}

// method to generate a sawtooth wave with smoothed edge
float sawtoothWave(float theAngle, float smoothing) {
  
  theAngle = unwrap(theAngle);
  
  if (theAngle > PI - smoothing)
    return (PI/smoothing) - theAngle/smoothing;
  else if (theAngle < smoothing - PI)
    return -(PI/smoothing) - theAngle/smoothing;
  else
    return theAngle/(PI - smoothing);
  
}
