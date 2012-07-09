// class for dealing with the matrix of buttons used to store beams

class BeamMatrixMinder {
  
  int nRows = 5; // using only clip launch
  int nColumns = 8; // ignoring master track
  
  boolean[][] isLook = new boolean[nRows][nColumns];
  ArrayList[] theSaves = new ArrayList[nRows];
  
  boolean waitingForBeamSave;
  boolean waitingForLookSave;
  boolean waitingForDelete;
  
  // probably only have one constructor
  BeamMatrixMinder() {
    
    // initialize the arrays that hold everything
    for (int r = 0; r < nRows; r++) {
      
      // each row is an arraylist
      theSaves[r] = new ArrayList(nColumns);
      
      for (int c = 0; c < nColumns; c++) {
        
        // initialize the elements
        isLook[r][c] = false;
        theSaves[r].add(null);
        setClipLaunchLED(r, c, 0, 0);
      }
    }
    
    waitingForBeamSave = false;
    setBeamSaveLED(0);
    waitingForLookSave = false;
    setLookSaveLED(0);
    waitingForDelete = false;
    setDeleteLED(0);
    
  }
  
  // put a copy of a beam into the minder
  void putBeam(int row, int column, Beam theBeam) {
    theSaves[row].set(column, new BeamVault(theBeam) );
    
    // this element is a beam
    isLook[row][column] = false;
    
    // update clip launch LED
    setClipLaunchLED(row, column, 1, 2);
    
  }
  
  // put a BeamVault into the beam matrix; assume the BeamVault isn't referenced by anything else
  void putLook(int row, int column, BeamVault theLook) {
    theSaves[row].set(column, theLook);
    
    // this element is a look
    isLook[row][column] = true;
    
    // update clip launch LED
    setClipLaunchLED(row, column, 1, 1);
    
  }
  
  // delete an element from the minder
  void clearElement (int row, int column) {
    
    theSaves[row].set(column, null);
    
    // update clip launch LED
    setClipLaunchLED(row, column, 0, 1);
  }
  
  // get an element from the minder
  BeamVault getElement (int row, int column) {
    return (BeamVault) theSaves[row].get(column);
  }
  
  // is an element a look?
  boolean elementIsLook(int row, int column) {
    return isLook[row][column];
  }
  
}
