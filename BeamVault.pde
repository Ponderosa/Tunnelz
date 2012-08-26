
// class for storing and retrieving deep copies of beams; the idea is that
// beams stored in a vault are only referenced by the Vault itself.
class BeamVault implements Serializable {
  
  // the list of beams
  private ArrayList theBeams;
  
  // no parameter constructor
  BeamVault() {
    theBeams = new ArrayList(0);
  }
  
  // regular constructor
  BeamVault(int nBeams) {
    theBeams = new ArrayList(nBeams);
    for (int i=0; i<nBeams; i++) {
      theBeams.add(new Beam() );
    }
  }
  
  // initialize a BeamVault with a single beam
  BeamVault(Beam theBeam) {
    theBeams = new ArrayList(1);
    theBeams.add(null);
    storeCopy(0, theBeam);
  }
  
  // initialize a BeamVault with a collection of beams
  BeamVault(ArrayList theBeamArray) {

    theBeams = copyArrayListOfBeams(theBeamArray);
  }
  
  // this constructor should copy?  not convinced I wrote this correctly, don't use me.
  BeamVault(Beam[] theBeamArray) {
    theBeams = new ArrayList(Arrays.asList(theBeamArray));
  }
  
  // copying constructor
  protected BeamVault(BeamVault original) {
    
    theBeams = copyArrayListOfBeams(original.theBeams);
    
    
  }
  
  // deep copy method
  BeamVault copy() {
    return new BeamVault(this);
  }
  
  // copy a beam into the Vault
  void storeCopy(int index, Beam beamToAdd) {
    theBeams.set(index, beamToAdd.copy());
    
  }
  
  // get a copy from the vault
  Beam retrieveCopy(int index) {
    Beam toCopy = (Beam) theBeams.get(index);
    return toCopy.copy();
  }
  
  int size() {
    return theBeams.size();
  }
  
  // method to return this collection of beams as an array of strings
  String[] toStringArray() {
    int nBeams = size();
    String[] theStrings = new String[nBeams];
    
    // loop over beams and make them into strings
    for (int i = 0; i < nBeams; i++) {
      theStrings[i] = ((Beam) theBeams.get(i)).toString(); 
    }
    
    return theStrings;
  } 
}
