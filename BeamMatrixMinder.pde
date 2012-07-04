// class for dealing with the matrix of buttons used to store beams

class BeamMatrixMinder {
  
  int nRows = 5; // using only clip launch
  int nColumns = 8; // ignoring master track
  
  boolean[][] isLook = new boolean[nRows][nColumns];
  ArrayList[] theSaves;
  
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
      }
    }
    
  }
  
  // put a copy of a beam into the minder
  void putBeam(int row, int column, Beam theBeam) {
    theSaves[row].set(column, new BeamVault(theBeam) );
  }
  
  
  // get a copy of an object from the minder
  BeamVault getElement (int row, int column) {
    return null;
  }
  
}
