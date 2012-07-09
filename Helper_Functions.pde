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


// method to unwrap angles
float unwrap(float theAngle) {
  while (PI < theAngle) {
    theAngle = theAngle - TWO_PI;
  }
  while (PI < -1*theAngle) {
    theAngle = theAngle + TWO_PI;
  }
  
  return theAngle;
}
