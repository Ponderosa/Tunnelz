class Animation {
 
  // midi-driven parameters
  int typeI, speedI, weightI, targetI;
  
  // scaled parameters
  int type; // 0 = sine, 1 = triangle, 2 = square, 3 = sawtooth
  int nPeriods;
  float speed;
  int weight;
  int target; // tricky to figure out how we want to do this...
 
  // internal variables
  float currAngle;
  boolean active;
 
  // constants
  int speedScale = 200;
  float waveSmoothing = PI/8;
 
  // default constructor
  Animation() {
    typeI = 0;
    speedI = 64;
    weightI = 0;
    targetI = 0;
    
    currAngle = 0;
  
    updateParams();
  
  }
  
  // constructor if we know the parameters already
  Animation(int theTypeI, int theSpeedI, int theWeightI, int theTargetI) {
    typeI = theTypeI;
    speedI = theSpeedI;
    weightI = theWeightI;
    targetI = theTargetI;
    
    currAngle = 0;   
   
    updateParams();
  }
  
  // object copying:
  protected Animation(Animation original) {
    typeI = original.typeI;
    speedI = original.speedI;
    weightI = original.weightI;
    targetI = original.targetI;
    
    currAngle = original.currAngle;
    
    updateParams();
  }
  
  Animation copy() {
    return new Animation(this);
    
  }
  
  // method to update the scaled parameters when midi values change/etc.
  void updateParams() {
   
    // sine wave
    if (typeI < 32) {
      type = 0;
      nPeriods = typeI / 4;
    }
    // triangle wave
    else if (typeI < 64) {
      type = 1;
      nPeriods = (typeI - 32) / 4; 
    }
    // square wave
    else if (typeI < 96) {
      type = 2;
      nPeriods = (typeI - 64) / 4;
    }
    // sawtooth wave
    else {
      type = 3;
      nPeriods = (typeI - 96) / 4;
    }
   
    if (65 < speedI)
      speed = -(float)(speedI-65)/speedScale;
    else if (63 > speedI)
      speed = (float)(-speedI+63)/speedScale;
    else
      speed = 0;
    
    weight = weightI;
    
    if (weightI > 0)
      active = true;
    else
      active = false;
    
    target = targetI / 32; // really need to do this mapping in a more explicit way...
  }
  
  // method that updates the angle.  call this in the draw loop.
  void updateState() {
    
    if (active) {
      currAngle = currAngle + speed;
      currAngle = unwrap(currAngle);
    }
  }
  
  // method that returns the current value of the animation, with an offset
  float getValue(float angleOffset) {
    
    if (active) {
    
      switch (type) {
        // sine wave
        case 0:
          return (float) weight * sin(angleOffset * nPeriods + currAngle);
          
        // triangle wave
        case 1:
          return (float) weight * triangleWave(angleOffset * nPeriods + currAngle);
          
        // square wave
        case 2:
          return (float) weight * squareWave(angleOffset * nPeriods + currAngle, waveSmoothing);
          
        // sawtooth wave
        case 3:
          return (float) weight * sawtoothWave(angleOffset * nPeriods + currAngle, waveSmoothing);
          
      } // end of switch
      
    }
    
    return 0.0;

  }

} // end of Animation class
