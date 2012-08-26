
// class for making ellipsoidal tunnels a la the prototype
class Tunnel extends Beam {
  
  // integer-valued parameters, derived from midi inputs and used to initialize the beam
  int rotSpeedI, thicknessI, radiusI, ellipseAspectI;
  int colCenterI, colWidthI, colSpreadI, colSatI;
  int segsI, blackingI;
  
  // scaled parameters used for drawing, set in updateParams() method.
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
  int blackingScale = 4;
  int xNudge = 10;
  int yNudge = 10;
  
  // array of colors for current parameters
  color[] segmentColors;
  
  // animations
  int nAnim = 4;
  Animation[] theAnims = new Animation[nAnim];
  int currAnim;

  // tunnel constructor for default tunnel
  Tunnel() {
    type = "tunnel";
    
    
    rotSpeedI = 64;
    thicknessI = 32;
    radiusI = 64;
    ellipseAspectI = 64;

    colCenterI = 0;
    colWidthI = 0;
    colSpreadI = 0;
    colSatI = 127;
    
    segsI = 126;
    blackingI = 72;

    currAngle = 0;
    
    xOffset = 0;
    yOffset = 0;
    
    for (int i=0; i < nAnim; i++) {
      theAnims[i] = new Animation();
    }
    
    currAnim = 0;
    
    segmentColors = new color[maxSegs];
    
    updateParams();
  }
  
  
  
  // tunnel constructor for a tunnel loaded from file
  Tunnel(String[] params) {
    type = params[0];
    rotSpeedI = int(params[1]);
    thicknessI = int(params[2]);
    radiusI = int(params[3]);
    ellipseAspectI = int(params[4]);
    colCenterI = int(params[5]);
    colWidthI = int(params[6]);
    colSpreadI = int(params[7]);
    colSatI = int(params[8]);
    segsI = int(params[9]);
    blackingI = int(params[10]);
    currAngle = float(params[11]);
    xOffset = int(params[12]);
    yOffset = int(params[13]);
    currAnim = int(params[14]);
    
    theAnims[0] = new Animation(Arrays.copyOfRange(params, 15, 20));
    theAnims[1] = new Animation(Arrays.copyOfRange(params, 20, 25));
    theAnims[2] = new Animation(Arrays.copyOfRange(params, 25, 30));
    theAnims[3] = new Animation(Arrays.copyOfRange(params, 30, 35));
    
  }
  
  // tunnel constructor for a saved tunnel
  Tunnel(int theRotSpeedI, int theThicknessI, int theRadiusI, int theEllipseAspectI,
         int thecolCenterI, int thecolWidthI, int theColSpreadI, int theColSatI,
         int theSegsI, int theBlackingI,
         int theXOffset, int theYOffset) {
           
    type = "tunnel";
    
    
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
    
    updateParams();
  }
  
  // deep copy constructor
  protected Tunnel(Tunnel original) {
    super(original);
    
    type = "tunnel";
    
    rotSpeedI = original.rotSpeedI;
    thicknessI = original.thicknessI;
    radiusI = original.radiusI;
    ellipseAspectI = original.ellipseAspectI;
    colCenterI = original.colCenterI;
    colWidthI = original.colWidthI;
    colSpreadI = original.colSpreadI;
    colSatI = original.colSatI;
    
    segsI = original.segsI;
    blackingI = original.blackingI;

    currAngle = original.currAngle;
    
    xOffset = original.xOffset;
    yOffset = original.yOffset;
    
    Animation toCopy;
    for (int i=0; i < nAnim; i++) {
      toCopy = original.getAnimation(i);
      theAnims[i] = toCopy.copy();
    }
    
    currAnim = original.currAnim;
    
    segmentColors = new color[maxSegs];
    
    updateParams();
    
  }
  
  Tunnel copy() {
    
    return new Tunnel(this);
    
  }
  
  
  // this method is called whenever a beam parameter is changed, by midi for example.  this is where parameter scaling occurs.
  void updateParams() {
    
    // update internal parameters from integer values
    
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
    
    blacking = (blackingI - 64) / blackingScale;
    
    if (xOffset > width/2)
      xOffset = width/2;
    else if (xOffset < -width/2)
      xOffset = -width/2;
    
    if (yOffset > height/2)
      yOffset = height/2;
    else if (yOffset < -width/2)
      yOffset = width/2;
    
  } // end of updateParams()
  
  
  // get any animation
  Animation getAnimation(int anim) {
    return theAnims[anim]; 
  }
  
  // get the currently selected animation
  Animation getCurrentAnimation() {
    return getAnimation(currAnim);
  }
  
  // replace the currently selected animation
  void replaceCurrentAnimation(Animation newAnim) {
    theAnims[currAnim] = newAnim;
    
  }
  
  
  // method that draws the beam
  void display(int level, boolean drawAsMask) {
    
    float rotAdjust = 0;
    float ellipseAdjust = 0;
    
    int thisTarget = 0;
    
    // update the state of the animations and get relevant values
    for (int animIt=0; animIt < nAnim; animIt++) {
      
      Animation thisAnim = theAnims[animIt];
      thisAnim.updateState();
            
      thisTarget = thisAnim.target;
      
      // what is this animation targeting?
      switch (thisTarget) {
        case 1: // rotation speed
          rotAdjust += thisAnim.getValue(0);
          break;
        case 4: // ellipsing
          ellipseAdjust += thisAnim.getValue(0);
          break;
      } // end of target switch
    }
    
    // calulcate the rotation
    currAngle = currAngle + rotSpeed + rotAdjust/rotSpeedScale;
    
        
    // unwrap angle so it stays in the range -pi to pi
    currAngle = unwrap(currAngle);
    
    float tunnelRadX = radius*(ellipseAspect + (maxEllipseAspect * ellipseAdjust / 127) ) - thickness/2;
    float tunnelRadY = radius - thickness/2;

    noFill();

    // loop over segments and draw arcs
    for (int i = 0; i < segs; i++) {
      
      drawSegmentWithAnimation(tunnelRadX, tunnelRadY, i, drawAsMask, level);

    } // end of loop over segments
  }
  
  // method that actually draws a tunnel segment given animation parameters
  void drawSegmentWithAnimation(float radX, float radY, int segNum, boolean drawAsMask, int level) {
      
      // parameters that animation may modify
      float radAdjust = 0;
      float thicknessAdjust = 0;
      float colCenterAdjust = 0;
      float colWidthAdjust = 0;
      float colPeriodAdjust = 0;
      float colSatAdjust = 0;
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
          case 2: // thickness
            thicknessAdjust += thisAnim.getValue(relAngle);
            break;
          case 3: // radius
            radAdjust += thisAnim.getValue(relAngle);
            break;
          case 5: // color center
            colCenterAdjust += thisAnim.getValue(0);
            break;
          case 6: // color width
            colWidthAdjust += thisAnim.getValue(0);
            break;
          case 7: // color periodicity
            colPeriodAdjust += thisAnim.getValue(0) / 16;
            break;
          case 8: // saturation
            colSatAdjust += thisAnim.getValue(relAngle);
            break;
          case 11: // x offset
            xAdjust += thisAnim.getValue(0)*(width/2)/127;
            break;
          case 12: // y offset
            yAdjust += thisAnim.getValue(0)*(height/2)/127;
            break;
        } // end of target switch
      } // end of animations loop

      strokeWeight( abs(thickness*(1 + thicknessAdjust/127)) );  // the abs() is there to prevent negative width setting when using multiple animations.
      
      // now set the color
      
      color segColor;
      
      boolean blackMe;
      
      boolean blackingMode; // true for standard, false for inverted
      if (blacking < 0) {
        blackingMode = false;
      }
      else {
        blackingMode = true;
      }
      
      // if no blacking at all, or if this is not a blacked segment
      if ( (0 == blacking) || (blackingMode ^ !(segNum % abs(blacking) == 0) ) ) {
        
        
        float theHue = colCenter + colCenterAdjust + ( (colWidth+colWidthAdjust) * sawtoothWave(relAngle*(colSpread+colPeriodAdjust), 0));
        
        // wrap the hue index
        while (theHue > 255)
          theHue = theHue - 255;
        while (theHue < 0)
          theHue = theHue + 255;
        
        segColor = color(theHue, colSat + colSatAdjust, 255);
      }
      // otherwise this is a blacked segment.
      else {
        segColor = color(0);
      }

      // only draw something if the segment color isn't black.
      if(color(0) != segColor) {
        
        // if we're drawing this beam as a mask, make the segment black
        if (drawAsMask) {
          stroke(0);
        }
        // otherwise pick the color and set the level
        else {
          stroke( blendColor(segColor, color(0,0,level), MULTIPLY) );
        }
      }
      
      else {
        noStroke();
      }
    
      // draw pie wedge for this cell
      arc(x_center+xOffset+xAdjust, y_center+yOffset+yAdjust, abs(radX+radAdjust), abs(radY+radAdjust),
      segAngle, segAngle + rotInterval);
  } 
  
  
  // function to set the control parameter based on passed midi value
  void setMIDIParam(boolean isNote, int num, int val) {
    
    Animation thisAnim;
    // define the mapping between APC40 and parameters and set values
    if (isNote) {
      
      // ipad animation type select
      if (num >= 24 && num <= 31) {
        
        // haven't implemented these waveforms yet
        if (num != 28 && num != 29 && num != 30 && num != 31) {
          thisAnim = getAnimation(currAnim);
          thisAnim.typeI = num;
          thisAnim.updateParams();
        }
      }
      
      // ipad periodicity select
      else if (num >= 0 && num <= 15) {
        thisAnim = getAnimation(currAnim);
        thisAnim.nPeriodsI = num;
        thisAnim.updateParams();
      }
      
      // ipad target select
      else if (num >= 36 && num <= 48) {
        if (num != 48) {
          thisAnim = getAnimation(currAnim);
          thisAnim.targetI = num;
          thisAnim.updateParams();
        }
      }
      
      switch(num) {
        // animation control buttons, for iPad control
        
        
        
        // aniamtion select buttons:
        case 0x57: //anim 0
          currAnim = 0;
          setAnimSelectLED(0);
          break;
        case 0x58: //anim 1
          currAnim = 1;
          setAnimSelectLED(1);
          break;
        case 0x59: //anim 2
          currAnim = 2;
          setAnimSelectLED(2);
          break;
        case 0x5A: //anim 3
          currAnim = 3;
          setAnimSelectLED(3);
          break;
          
        // directional controls
        case 0x5E: // up on D-pad
          yOffset -= yNudge;
          break;
        case 0x5F: // down on D-pad
          yOffset += yNudge;
          break;
        case 0x60: // right on D-pad
          xOffset += xNudge;
          break;
        case 0x61: // left on D-pad
          xOffset -= xNudge;
          break;
        case 0x62: // "shift" - beam center
          xOffset = 0;
          yOffset = 0;
          break;
      } // end of note num switch
      
    }
    
    else { // this is a control change
      switch(num) {
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
          thisAnim.speedI = val;
          thisAnim.updateParams();
          break;
        case 49:
          thisAnim = getAnimation(currAnim);
          thisAnim.weightI = val;
          thisAnim.updateParams();
          break;
        case 50:
          thisAnim = getAnimation(currAnim);
          thisAnim.dutyCycleI = val;
          thisAnim.updateParams();
          break;
        case 51:
          thisAnim = getAnimation(currAnim);
          thisAnim.smoothingI = val;
          thisAnim.updateParams();
          break;
        // */
        
      } // end of switch
      
    }
    
  } // end up update midi param method
  
  // method to get the midi-scaled value for a control parameter
  int getMIDIParam(boolean isNote, int num) {
    int theVal = 0;
    
    Animation thisAnim;
    
    if (!isNote) {
      switch(num) {
        case 16: // color center
          theVal = colCenterI;
          break;
        case 17: // color width
          theVal = colWidthI;
          break;
        case 18: // color spread
          theVal = colSpreadI;
          break;    
        case 19: // saturation
          theVal = colSatI;
          break;
          
        // geometry parameters: bottom of lower bank
        case 20: // rotation speed
          theVal = rotSpeedI;
          break; 
        case 21: // thickness
          theVal = thicknessI;
          break;
        case 22: // radius
          theVal = radiusI;
          break;
        case 23: // ellipse aspect ratio
          theVal = ellipseAspectI;
          break;
          
        // segments parameters: bottom of upper bank
          
        case 52: // number of segments
          theVal = segsI;
          break;  
        case 53: // blacking
          theVal = blackingI;
          break;
          
        // animation parameters: top of upper bank
        // /* fix this code
        case 48:
          thisAnim = getAnimation(currAnim);
          theVal = thisAnim.speedI;
          break;
        case 49:
          thisAnim = getAnimation(currAnim);
          theVal = thisAnim.weightI;
          break;
        case 50:
          thisAnim = getAnimation(currAnim);
          theVal = thisAnim.dutyCycleI;
          break;
        case 51:
          thisAnim = getAnimation(currAnim);
          theVal = thisAnim.smoothingI;
          break;
      }
    }
    
    return theVal;
  } // end of getMIDIParam method
  
  
  String toString() {
    return type + "\t" +
           rotSpeedI + "\t" +
           thicknessI + "\t" +
           radiusI + "\t" +
           ellipseAspectI + "\t" +
           colCenterI + "\t" +
           colWidthI + "\t" +
           colSpreadI + "\t" +
           colSatI + "\t" +
           segsI + "\t" +
           blackingI + "\t" +
           currAngle + "\t" +
           xOffset + "\t" +
           yOffset + "\t" +
           currAnim  + "\t" +
           theAnims[0].toString() + "\t" +
           theAnims[1].toString() + "\t" +
           theAnims[2].toString() + "\t" +
           theAnims[3].toString();
  }
  
} // end of Tunnel class
