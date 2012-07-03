
// class for storing and retrieving deep copies of beams; the idea is that
// beams stored in a vault are only referenced by the Vault itself.
class BeamVault {
  
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
      theBeams.add(null);
    }
  }
  
  // copying constructor
  protected BeamVault(BeamVault original) {
    theBeams = new ArrayList(original.theBeams);
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
  
  
}
