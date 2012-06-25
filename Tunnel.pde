
// class for making ellipsoidal tunnels a la the prototype
class Tunnel extends Beam {
  
  // integer-valued parameters, derived from midi inputs and used to initialize the beam
  int rotSpeedI, thicknessI, radiusI, ellipseAspectI;
  int colCenterI, colWidthI, colSpreadI, colSatI;
  int segsI, blackingI;
  
  // scaled parameters used for drawing, set in updateBeam() method.
  float rotSpeed, thickness, ellipseAspect;
  int radius;
  int colCenter, colWidth, colSpread, colSat;
  int segs, blacking;
  
  // rotation angles
  float currAngle, rotInterval;
  
  // location
  int xOffset, yOffset;
  
  // constants
  int rotSpeedScale = 400;
  
  // array of colors for current parameters
  color[] segmentColors;
  
  // animations
  int nAnim = 4;
  Animation[] theAnims = new Animation[nAnim];
  int currAnim;

  // tunnel constructor for default tunnel
  Tunnel() {
    type = "tunnel";
    
    levelI = 0;
    
    rotSpeedI = 64;
    thicknessI = 32;
    radiusI = 64;
    ellipseAspectI = 64;

    colCenterI = 0;
    colWidthI = 0;
    colSpreadI = 0;
    colSatI = 0;
    
    segsI = 126;
    blackingI = 20;

    currAngle = 0;
    
    xOffset = 0;
    yOffset = 0;
    
    for (int i=0; i < nAnim; i++) {
      theAnims[i] = new Animation();
    }
    
    currAnim = 0;
    
    segmentColors = new color[maxSegs];
    
    updateBeam();
  }
  
  // tunnel constructor for a saved tunnel
  Tunnel(int theLevelI,
         int theRotSpeedI, int theThicknessI, int theRadiusI, int theEllipseAspectI,
         int thecolCenterI, int thecolWidthI, int theColSpreadI, int theColSatI,
         int theSegsI, int theBlackingI,
         int theXOffset, int theYOffset) {
           
    type = "tunnel";
    
    levelI = theLevelI;
    
    rotSpeedI = theRotSpeedI;
    thicknessI = theThicknessI;
    radiusI = theRadiusI;
    ellipseAspectI = theEllipseAspectI;
    colCenterI = thecolCenterI;
    colWidthI = thecolWidthI;
    colSpreadI = theColSpreadI;
    colSatI = theColSatI;
    
    segsI = theSegsI;
    blackingI = theBlackingI;

    currAngle = 0;
    
    xOffset = theXOffset;
    yOffset = theYOffset;
    
    for (int i=0; i < nAnim; i++) {
      theAnims[i] = new Animation();
    }
    
    currAnim = 0;
    
    segmentColors = new color[maxSegs];
    
    updateBeam();
  }
  
  
  // this method is called whenever a beam parameter is changed, by midi for example.  this is where parameter scaling occurs.
  void updateBeam() {
    
    // update internal parameters from integer values
    level = levelI * 2;
    
    if (65 < rotSpeedI)
      rotSpeed = (float)(rotSpeedI-65)/rotSpeedScale;
    else if (63 > rotSpeedI)
      rotSpeed = -(float)(-rotSpeedI+63)/rotSpeedScale;
    else
      rotSpeed = 0;
      
    thickness = (float)thicknessI*2.7;
    radius = (int) maxRadiusMultiplier * maxRadius * radiusI / 127;
    ellipseAspect = maxEllipseAspect * ellipseAspectI / 127;
    
    colCenter = colCenterI*2;
    colWidth = colWidthI;
    colSpread = colSpreadI / 8;
    colSat = (127 - colSatI) * 2;  // we have a "desaturate" knob, not a saturate knob.
    
    segs = segsI; // THIS IS A HACK.  This only works because the APC40 doesn't put out 0 for the bottom of the knob.
    rotInterval = TWO_PI / segs;  // ALSO A HACK.
    
    blacking = blackingI / blackingScale;
    
    if (xOffset > width/2)
      xOffset = width/2;
    else if (xOffset < -width/2)
      xOffset = -width/2;
    
    if (yOffset > height/2)
      yOffset = height/2;
    else if (yOffset < -width/2)
      yOffset = width/2;
    
    color segColor;

    // loop over segments, set fill color
    for (int segNum = 0; segNum < segs; segNum++) {

      // if no blacking at all, or if this is not a blacked segment
      if ( (0 == blacking) || !(segNum % blacking == 0) ) {
        
        float segAngle = rotInterval*segNum;
        
        int theHue = colCenter + (int) (colWidth*sawtoothWave(segAngle*colSpread, 0));
        
        // wrap the hue index
        while (theHue > 255)
          theHue = theHue - 255;
        while (theHue < 0)
          theHue = theHue + 255;
        
        segColor = color(theHue, colSat, level);
        
        /*
        // blend the selected color with the saturation parameter
        segColor = blendColor(colPallete[colPnt], satColor, ADD);
        
        // multiply by the level
        segColor = blendColor(segColor, levelColor, MULTIPLY);
        */
      }
      // otherwise this is a blacked segment.
      else {
        segColor = color(0,0,0);
      }
      
      segmentColors[segNum] = segColor;
    }
  } // end of updateBeam()
  
  Animation getAnimation(int anim) {
    return theAnims[anim]; 
  }
  
  Animation getCurrentAnimation() {
    return theAnims[currAnim];
  }
  
  // function to set the control parameter based on passed midi value
  void setMIDIParam(boolean isNote, int num, int val) {
    
    Animation thisAnim;
    // define the mapping between APC40 and parameters and set values
    if (isNote) {
      switch(num) {
        case 0x57: //anim 0
          currAnim = 0;
          updateTopKnobState(this);
          break;
        case 0x58: //anim 1
          currAnim = 1;
          updateTopKnobState(this);
          break;
        case 0x59: //anim 2
          currAnim = 2;
          updateTopKnobState(this);
          break;
        case 0x5A: //anim 3
          currAnim = 3;
          updateTopKnobState(this);
          break;
      }
      
    }
    else { // this is a control change
      switch(num) {    
        // upfader
        case 7: // level - essentially inverse transparency
          levelI = val;
          break;
    
        // color parameters: top of lower bank
        case 16: // color center
          colCenterI = val;
          break;
        case 17: // color width
          colWidthI = val;
          break;
        case 18: // color spread
          colSpreadI = val;
          break;    
        case 19: // saturation
          colSatI = val;
          break;
          
        // geometry parameters: bottom of lower bank
        case 20: // rotation speed
            rotSpeedI = val;
          break; 
        case 21: // thickness
          thicknessI = val;
          break;
        case 22: // radius
          radiusI = val;
          break;
        case 23: // ellipse aspect ratio
          ellipseAspectI = val;
          break;
          
        // segments parameters: bottom of upper bank
          
        case 52: // number of segments
          segsI = val;
          break;  
        case 53: // blacking
          blackingI = val;
          break;
          
        // animation parameters: top of upper bank
        // /* fix this code
        case 48:
          thisAnim = getAnimation(currAnim);
          thisAnim.typeI = val;
          thisAnim.updateParams();
          break;
        case 49:
          thisAnim = getAnimation(currAnim);
          thisAnim.weightI = val;
          thisAnim.updateParams();
          break;
        case 50:
          thisAnim = getAnimation(currAnim);
          thisAnim.speedI = val;
          thisAnim.updateParams();
          break;
        case 51:
          thisAnim = getAnimation(currAnim);
          thisAnim.targetI = val;
          thisAnim.updateParams();
          break;
        // */
        
      } // end of switch
    }
    
  }
  
  // method that draws the beam
  void display() {
    
    // calulcate the rotation
    currAngle = currAngle + rotSpeed;
    
        
    // unwrap angle so it stays in the range -pi to pi
    currAngle = unwrap(currAngle);
    
    // update the state of the animations
    for (int animIt=0; animIt < nAnim; animIt++) {
      theAnims[animIt].updateState();
    }
    
    float tunnelRadX = (radius*ellipseAspect) - thickness/2;
    float tunnelRadY = radius - thickness/2;

    noFill();
    strokeWeight(thickness);

    // loop over segments and draw arcs
    for (int i = 0; i < segs; i++) {

      // only draw something if the segment color isn't black.
      if(color(0) != segmentColors[i]) {
        stroke(segmentColors[i]);
      }
      else {
        noStroke();
      }
      
      drawSegmentWithAnimation(tunnelRadX, tunnelRadY, i);

    } // end of loop over segments
  }
  
  // method that actually draws a tunnel segment given animation parameters
  void drawSegmentWithAnimation(float radX, float radY, int segNum) {
      
      // parameters that animation may modify
      float radAdjust = 0;
      float thicknessAdjust = 0;
      int xAdjust = 0;
      int yAdjust = 0;
      
      // the angle of this particular segment
      float segAngle = rotInterval*segNum+currAngle;
      float relAngle = rotInterval*segNum;
      
      Animation thisAnim;
      int thisTarget;
      
      // loop over animations
      for (int animIt = 0; animIt < nAnim; animIt++) {
      
        thisAnim = theAnims[animIt];
        thisTarget = thisAnim.target;
        
        // what is this animation targeting?
        switch (thisTarget) {
          case 0: // radius
            radAdjust += thisAnim.getValue(relAngle);
            break;
          case 1: // thickness
            thicknessAdjust += thisAnim.getValue(relAngle);
            break;
          case 2: // x offset
            xAdjust += thisAnim.getValue(0)*(width/2)/127;
            break;
          case 3: // y offset
            yAdjust += thisAnim.getValue(0)*(height/2)/127;
            break;
        } // end of target switch
      } // end of animations loop

      strokeWeight(thickness*(1 + thicknessAdjust/127));  
    
      // draw pie wedge for this cell
      arc(x_center+xOffset+xAdjust, y_center+yOffset+yAdjust, radX+radAdjust, radY+radAdjust, 
      segAngle, segAngle + rotInterval);
  } 
} // end of Tunnel class
