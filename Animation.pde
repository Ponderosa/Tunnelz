

class Animation {
 
  // midi-driven parameters
  int typeI, speedI, weightI, targetI, nPeriodsI, dutyCycleI, smoothingI;
  
  // scaled parameters
  int type; // 0 = sine, 1 = triangle, 2 = square, 3 = sawtooth
  int nPeriods;
  float speed;
  int weight;
  float dutyCycle;
  float smoothing;
  int target; // tricky to figure out how we want to do this...
  /*
    0 none
    1 rotation
    2 thickness
    3 radius
    4 ellipse
    5 color
    6 spread
    7 periodicity
    8 saturation
    9 segments
    10 blacking
    11 x
    12 y
    13 x + y
  */
 
  // internal variables
  float currAngle;
  boolean active;
 
  // constants
  int speedScale = 200;
  float waveSmoothing = PI/8;
 
  // default constructor
  Animation() {
    typeI = 24;
    speedI = 64;
    weightI = 0;
    targetI = 36;
    nPeriodsI = 0;
    dutyCycleI = 0;
    smoothingI = 0;
    
    currAngle = 0;
  
    updateParams();
  
  }
  
  // constructor if we know the parameters already
  Animation(int theTypeI, int theSpeedI, int theWeightI, int theTargetI, float theCurrAngle) {
    typeI = theTypeI;
    speedI = theSpeedI;
    weightI = theWeightI;
    targetI = theTargetI;
    
    currAngle = theCurrAngle;   
   
    updateParams();
  }
  
  // constructor from string array from file
  Animation(String[] params) {
    typeI = int(params[0]);
    speedI = int(params[1]);
    weightI = int(params[2]);
    targetI = int(params[3]);
    
    currAngle = float(params[4]);
    
    updateParams();
  }
  
  // object copying:
  protected Animation(Animation original) {
    typeI = original.typeI;
    speedI = original.speedI;
    weightI = original.weightI;
    targetI = original.targetI;
    nPeriodsI = original.nPeriodsI;
    dutyCycleI = original.dutyCycleI;
    smoothingI = original.smoothingI;
    
    currAngle = original.currAngle;
    
    updateParams();
  }
  
  Animation copy() {
    return new Animation(this);
    
  }
  
  // method to update the scaled parameters when midi values change/etc.
  void updateParams() {
    
    type = typeI - 24;
    nPeriods = nPeriodsI;
   
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
    
    target = targetI - 35 + 1; // really need to do this mapping in a more explicit way...
    
    dutyCycle = (float) dutyCycleI / 127;
    
    smoothing = (float) (PI/2) * smoothingI / 127;
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
  
  // convert to string for saving purposes
  String toString() {
    return "" + typeI + "\t" +
           speedI + "\t" +
           weightI + "\t" +
           targetI + "\t" +
           currAngle;
  }

} // end of Animation class
