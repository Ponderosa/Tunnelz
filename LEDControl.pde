// helper functions for controlling APC LEDs

// method to update the state of the control knobs when we change channels
void updateKnobState(int theLayer, Beam theBeam) {
  
  int[] knobNums = new int[] {16, 17, 18, 19,
                              20, 21, 22, 23,
                              48, 49, 50, 51,
                              52, 53, 54, 55};
  
  for(int i=0; i<knobNums.length; i++) {
    sendCC(0, knobNums[i], theBeam.getMIDIParam(false, knobNums[i]));
  }
  
}

// method to set the bottom LED ring values
void setBottomLEDRings(int channel, Beam thisBeam) {
  
  String beamType = thisBeam.type;
  
  if (beamType.equals("tunnel")) {
    sendCC(channel, 0x18, 1);
    sendCC(channel, 0x19, 1);
    sendCC(channel, 0x1A, 2);
    sendCC(channel, 0x1B, 2);
  
    sendCC(channel, 0x1C, 3);
    sendCC(channel, 0x1D, 2);
    sendCC(channel, 0x1E, 2);
    sendCC(channel, 0x1F, 1);
  }
}

// set the top LED ring values
void setTopLEDRings(Beam thisBeam) {
  
  String beamType = thisBeam.type;
  if (beamType.equals("tunnel")) {
  
    sendCC(0, 0x38, 1);
    sendCC(0, 0x39, 2);
    sendCC(0, 0x3A, 3);
    sendCC(0, 0x3B, 1);
    
    sendCC(0, 0x3C, 2);
    sendCC(0, 0x3D, 1);
  }
}

// method to adjust the animation LED state based on selected animation
void setAnimSelectLED(int whichAnim) {
  
  int buttonOffset = 0x57;
  
  for (int i = 0; i < 4; i++) {
    if (whichAnim == i) {
      sendNote(0, buttonOffset + i, 1);
    }
    else {
      sendNote(0, buttonOffset + i, 0);
    }
  }
  
}

// method to set the color state of a clip launch LED
// state is off=0, on=1, blink=2
// col is green=0, red=1, yellow=2
void setClipLaunchLED(int row, int column, int state, int col) {
  
  int val;
  
  if (0 == state) {
    val = 0;
  }
  else if (1 == state) {
    val = col*2 + 1;
  }
  else if (2 ==  state) {
    val = (col+1)*2;
  }
  else {
    val = 0;
  }

  // column is midi channel, row is note plus offset of 0x35
  sendNote(column, 0x35+row, val);
  
}

// method to set scene launch LED
// 0=off, 1=on, 2=blink
void setSceneLaunchLED(int row, int state) {
  sendNote(0, 0x52 + row, state);
}

void setBeamSaveLED(int state) {
  setSceneLaunchLED(0, state);
}

void setLookSaveLED(int state) {
  setSceneLaunchLED(1, state);
}

void setDeleteLED(int state) {
  setSceneLaunchLED(2, state);
}

void setTrackSelectLED(int channel, int state) {
  sendNote(channel, 0x33, state);
}

void setTrackSelectLEDRadio(int channel) {
  for (int i=0; i<8; i++) {
    
    if (i == channel) {
      setTrackSelectLED(i,1);
    }
    else{
      setTrackSelectLED(i,0);
    }
    
  }
  
}

void setBumpButtonLED(int channel, int state) {
  sendNote(channel, 0x32, state);
}

