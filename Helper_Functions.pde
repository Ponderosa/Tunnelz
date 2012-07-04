// deep copies an ArrayList of beams
ArrayList copyArrayListOfBeams(ArrayList toCopy) {
  
  int nBeams = toCopy.size();
  ArrayList theCopy = new ArrayList(nBeams);
  
  for (int i= 0; i< nBeams; i++) {
    Beam beamToCopy = (Beam) toCopy.get(i); 
    theCopy.add(beamToCopy.copy());
  }
  
  return theCopy;
}
