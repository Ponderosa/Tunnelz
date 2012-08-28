// class for dealing with the matrix of buttons used to store beams
class BeamMatrixMinder implements Serializable {
  
  int nRows = 5; // using only clip launch
  int nColumns = 8; // ignoring master track
  
  boolean[][] isLook = new boolean[nRows][nColumns];
  boolean[][] hasData = new boolean[nRows][nColumns];
  ArrayList[] theSaves = new ArrayList[nRows];
  
  boolean waitingForBeamSave;
  boolean waitingForLookSave;
  boolean waitingForDelete;
  boolean waitingForLookEdit;
  
  // probably only have one constructor
  BeamMatrixMinder() {
    
    // initialize the arrays that hold everything
    for (int r = 0; r < nRows; r++) {
      
      // each row is an arraylist
      theSaves[r] = new ArrayList(nColumns);
      
      for (int c = 0; c < nColumns; c++) {
        
        // initialize the elements
        isLook[r][c] = false;
        hasData[r][c] = false;
        theSaves[r].add(null);
      }
    }
    
    updateAllLEDs();
    
    waitingForBeamSave = false;
    setBeamSaveLED(0);
    waitingForLookSave = false;
    setLookSaveLED(0);
    waitingForDelete = false;
    setDeleteLED(0);
    waitingForLookEdit = false;
    setLookEditLED(0);
    
  }
  
  // put a copy of a beam into the minder
  void putBeam(int row, int column, Beam theBeam) {
    theSaves[row].set(column, new BeamVault(theBeam) );
    
    // this element is a beam
    isLook[row][column] = false;
    hasData[row][column] = true;
    
    // update clip launch LED
    updateLED(row,column);
    
  }
  
  // put a BeamVault into the beam matrix; assume the BeamVault isn't referenced by anything else
  void putLook(int row, int column, BeamVault theLook) {
    theSaves[row].set(column, theLook);
    
    // this element is a look
    isLook[row][column] = true;
    hasData[row][column] = true;
    
    // update clip launch LED
    updateLED(row,column);
    
  }
  
  // delete an element from the minder
  void clearElement (int row, int column) {
    
    theSaves[row].set(column, null);
    hasData[row][column] = false;
    
    // update clip launch LED
    updateLED(row,column);
  }
  
  // delete all the elements from the minder
  void clearAllElements() {
    for (int r = 0; r < nRows; r++) {
      
      for (int c = 0; c < nColumns; c++) {
        
        clearElement(r,c);
        
      }
      
    }
    
  }
  
  // get an element from the minder
  BeamVault getElement (int row, int column) {
    return (BeamVault) theSaves[row].get(column);
  }
  
  // is an element a look?
  boolean elementIsLook(int row, int column) {
    return isLook[row][column];
  }
  
  boolean elementHasData(int row, int column) {
    return hasData[row][column]; 
  }
  
  // method to update an LED state
  void updateLED(int row, int column) {
    
    // if this element has data, turn it on
    if (hasData[row][column]) {
      
      // its a look, make it red
      if (isLook[row][column]) {
        setClipLaunchLED(row, column, 1, 1);
      }
      
      // otherwise make it orange
      else {
        setClipLaunchLED(row, column, 1, 2);
      }
    }
    
    // if no data, turn it off
    else {
      setClipLaunchLED(row, column, 0, 1);
    }
  }
  
  // run through the arrays and update everything
  void updateAllLEDs() {
    for (int r = 0; r < nRows; r++) {
      for (int c = 0; c < nColumns; c++) {
        updateLED(r,c);
      }
    }
  }
  
}

