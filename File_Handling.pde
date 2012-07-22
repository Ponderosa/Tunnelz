
String verification = "tunnelz_data";


void saveState(String fileNameBase, boolean appendMoment) {
  
  String filename;
  
  if(appendMoment) {
    filename = fileNameBase + getCurrentMoment() + ".tunnelz";
  }
  else {
    filename = fileNameBase + ".tunnelz";
  }
  
  println("trying to save file at " + filename);
  
  FileOutputStream fos;
  
  try {
    fos = new FileOutputStream(filename);
  }
  catch ( FileNotFoundException e ) {
    println("error: could not save to file name " + filename + " .");
    return;
  }
  
  try {
    ObjectOutputStream oos = new ObjectOutputStream(fos);
    
    oos.writeObject(verification);
    oos.writeObject(new Beam());
    //oos.writeObject(mixer);
    //oos.writeObject(beamMatrix);
    
    oos.flush();
    oos.close();
  }
  catch (InvalidClassException ice) {
    println("invalid class");
  }
  catch (NotSerializableException nse) {
    println("not serializable?");
    nse.printStackTrace();
  }
  catch (IOException ioe) {
    println("something went wrong with saving data to " + filename + " .");
  }
  
  try {
    fos.close();
  }
  catch (IOException close_e) {
  }
  
} // end of save state method

// load the software state from file
void loadState(String fileName, boolean loadMixer, boolean loadBeamMat) throws IOException, ClassNotFoundException {
  
  FileInputStream fis;
  
  // try to open an input stream from the file
  try {
    fis = new FileInputStream(fileName);
  }
  catch (FileNotFoundException e) {
    println("error: " + fileName + " was not found.");
    return;
  }
  
  // get an object input stream
  ObjectInputStream ois = new ObjectInputStream(fis);
  
  // get the first object to verify good data
  String verifyMe = (String) ois.readObject();
  
  // if the verification object is valid, load the data
  if (verifyMe.equals(verification)) {
    
    Mixer loadedMixer = (Mixer) ois.readObject();
    BeamMatrixMinder loadedBeamMatrix = (BeamMatrixMinder) ois.readObject();
    
    // replace the mixer if we want to
    if (loadMixer) {
      mixer = loadedMixer;
    }
    // replace the beam matrix if we want to
    if (loadBeamMat) {
      beamMatrix = loadedBeamMatrix;
      beamMatrix.updateAllLEDs();
    }
    
  }
  else {
    println("Reading data from file " + fileName + " failed due to missing verification string.");
  }
  
  try {
    fis.close();
  }
  catch (IOException close_e) {
  }
  
}

String getCurrentMoment() {
  
  int theHour = hour();
  
  String hourString;
  
  if (theHour < 10) {
    hourString = "0" + theHour;
  }
  else {
    hourString = "" + theHour;
  }
  
  int theMinute = minute();
  String minuteString;
  
  if (theMinute < 10) {
    minuteString = "0" + theMinute;
  }
  else {
    minuteString = "" + theMinute;
  }
  
  return month() + "_" +
         day() + "_" +
         year() + "_" +
         hourString + "." +
         minuteString + "." +
         second() + "." +
         millis();
}
