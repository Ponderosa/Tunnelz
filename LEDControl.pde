// helper functions for controlling APC LEDs

// method to update the state of the control knobs when we change channels
void updateKnobState(Beam theBeam) {
  
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
