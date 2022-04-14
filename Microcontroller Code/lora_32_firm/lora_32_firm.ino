/*Smart Home: IOT based Effiecient Household Resource usage Project
 *Using LoRa32 Micro-Controller: an ESP32 with Built in LoRa Capabilities and OLED Display
 * 
 * i.e., Electricity and Water
 * Final Year Project: @University of Malawi
 * Ramsey Njema bsc-com-ne-10-17@unima.ac.mw
 * Haddard Nyirenda bsc-com-ne-10-17@unima.ac.mw
 */
/*========================================================================================================================================================================================
 * Include Neccessary Libraries
 */

// Wifi
char *WIFI_SSID;
char *WIFI_PASSWORD; 
#if defined(ESP32)
#include <WiFi.h>
#include <FirebaseESP32.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#endif

//Bluetooth Serial

// DHT
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#define RELAY1 22 //switch for fan
#define RELAY2 13 //switch for light
//#define RELAY3 38
//#define RELAY4 38
#define DHTPIN 17 
#define pirPin 21  
#define LDR 36
#define DHTTYPE DHT22
DHT_Unified dht(DHTPIN, DHTTYPE);

//Firebase Necesities
//Provide the token generation process info.
#include <addons/TokenHelper.h>
//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

/*=========================================================================================================================================================================================
 * Fixed Variable declaration
 */
 
//For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino
/* 2. Define the API Key */
#define API_KEY " "
/* 3. Define the RTDB URL */
#define DATABASE_URL "https://shautom-app-test-default-rtdb.asia-southeast1.firebasedatabase.app" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app
/* 4. Define the user Email and password that alreadey registerd or added in your project */
char *USER_EMAIL;
char *USER_PASSWORD;

/*=========================================================================================================================================================================================
 * Variable Declration and intiation
 */
//Define Firebase objects
FirebaseJson json;
FirebaseJson result_appliance;
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

FirebaseData lightData;
FirebaseData fanData;

// Root Path and child nodes
String parentPath;
String databasePath;
String databasePath1;
String temperaturePath;
String humidityPath;
String pirStatusPath;
String lightdepentresistorStatusPath;
String sensorPath = "sensor_readings";
String roomBulbStatusPath = "appliance_status/roombulb/state";
String fanStatusPath  = "appliance_status/fan/state";
String switch1Path = "appliance_control/switch1/state";
String switch2Path = "appliance_control/switch2/state";
String switch3Path = "appliance_control/switch3/state";
String switch4Path = "appliance_control/switch4/state";

// wait for readings from sensor
unsigned long sendDataPrevMillis = 0;
uint32_t delayMS;
float prev_temp;
float prev_humidity;
String uid = "2vtcqvRNBVUPi0XtnxbUJRAy9GE2";


//variables

//the time we give the sensor to calibrate (10-60 secs according to the datasheet)
int calibrationTime = 30;        

//the time when the sensor outputs a low impulse
long unsigned int lowIn;         

//the amount of milliseconds the sensor has to be low 
//before we assume all motion has stopped
  

boolean lockLow = true;
boolean takeLowTime;  
int lightIntesityThreshhold = 700; 
/////////////////////////////

/*=========================================================================================================================================================================================
 *  main methods
 *  
 */

  
    //Global function that handles stream data
  void streamCallbackFn(StreamData data){
  
    //Print out all information
  
    Serial.println("Stream Data...");
    Serial.println(data.streamPath());
    Serial.println(data.dataPath());
    Serial.println(data.dataType());
  
    //Print out the value
    //Stream data can be many types which can be determined from function dataType
  
    if (data.dataTypeEnum() == fb_esp_rtdb_data_type_integer)
        {Serial.println(data.to<int>());}
    else if (data.dataTypeEnum() == fb_esp_rtdb_data_type_float)
        {Serial.println(data.to<float>(), 5);}
    else if (data.dataTypeEnum() == fb_esp_rtdb_data_type_double)
        {printf("%.9lf\n", data.to<double>());}
    else if (data.dataTypeEnum() == fb_esp_rtdb_data_type_boolean)
        {Serial.println(data.to<bool>()? "true" : "false");}
    else if (data.dataTypeEnum() == fb_esp_rtdb_data_type_string)
        {Serial.println(data.to<String>());}
    else if (data.dataTypeEnum() == fb_esp_rtdb_data_type_json)
    {
        FirebaseJson *json1 = data.to<FirebaseJson *>();
        Serial.println(json1->raw());
    }
    else if (data.dataTypeEnum() == fb_esp_rtdb_data_type_array)
    {
        FirebaseJsonArray *arr = data.to<FirebaseJsonArray *>();
        Serial.println(arr->raw());
    }
  }
  
  //Global function that notifies when stream connection lost
  //The library will resume the stream connection automatically
  void streamTimeoutCallback(bool timeout){
    if(timeout){
      //Stream timeout occurred
      Serial.println("Stream timeout, resume streaming...");
    }  
  }
 
 
//main setup
void setup() {
  pinMode(RELAY1, OUTPUT);
  pinMode(RELAY2, OUTPUT);
  //pinMode(RELAY3, OUTPUT);
  //pinMode(RELAY4, OUTPUT);
  // put your setup code here, to run once:
  digitalWrite(RELAY1, LOW);
  digitalWrite(RELAY2, LOW);
  //digitalWrite(RELAY3, LOW);
  //digitalWrite(RELAY4, LOW);
  Serial.begin(115200);
  initWifi();
  smartLight_setup();
  dht22setup();
  // Update database path
  databasePath = "/Shautom/User/";
  pirStatusPath = sensorPath + "/MotionSensor/pir-status";
  lightdepentresistorStatusPath = sensorPath + "/LightSensor/ldr-status";
  temperaturePath = sensorPath + "/DHT22/temperature";
  humidityPath = sensorPath + "/DHT22/humidity";
  parentPath = databasePath + uid;

  Firebase.RTDB.setStreamCallback(&fbdo, &streamCallbackFn, &streamTimeoutCallback);

//In setup(), set the streaming path to "/test/data" and begin stream connection

  if (!Firebase.RTDB.beginStream(&fbdo, parentPath + "/appliance_control/switch1/state")){
    //Could not begin stream connection, then print out the error detail
    Serial.println(fbdo.errorReason());}
  
   
}

//main loop method
void loop(){
if (Firebase.ready() && (millis() - sendDataPrevMillis > delayMS || sendDataPrevMillis == 0)){
    sendDataPrevMillis = millis();
 
    
    delay(delayMS);
    smartLight();
    smartFan();
    Serial.printf("Set json... %s\n", Firebase.RTDB.updateNode(&fbdo, parentPath.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
    delay(3000);
    manualLight();
    manualFan();
    
  }
}

/*======================================================================================================================================================================================//
--Funtions in the setup
--Functions that will run one time
--Probably intializing the sensors
*/
void getSwitchState(){
  
  }
  

//Get the user id of the person signing in

//Update Temperature and Humidity Values
void updateTemp(float temp){
  if(prev_temp != temp){
    String tempString = "";
    tempString += (int)temp;
    tempString += "C";
    prev_temp = temp;
  }
}

void updateHumidity(float humidity){
  if(prev_humidity != humidity){
    String humidityString = "";
    humidityString += (int)humidity;
    humidityString += "%";
    prev_humidity = humidity;
  }
} 

//setup dhtt22 sensor
void dht22setup(){
  dht.begin();
  
  // Print temperature sensor details.
  sensor_t sensor;
  dht.temperature().getSensor(&sensor);

  // Print humidity sensor details.
  dht.humidity().getSensor(&sensor);
  
  // Set delay between sensor readings based on sensor details.
  delayMS = sensor.min_delay / 1000;
}

//Initialize WiFi and reconnect when disconnected
void initWifi(){
 
  Serial.println();
  delay(calibrationTime);

  
  WIFI_SSID = "Ramsey's MiFi";
  WIFI_PASSWORD = "Chimphepo";


  USER_EMAIL = "bsc-com-ne-10-17@unima.ac.mw";
  USER_PASSWORD = "12345678";

  

  
  //Serial.readBytesUntil(10, WIFI_PASSWORD, 50);
  //Serial.print(WIFI_PASSWORD);
  Serial.println("PASSWORD RECEIVED");
  Serial.println();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  
  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  
  //Or use legacy authenticate method
  //config.database_url = DATABASE_URL;
  //config.signer.tokens.legacy_token = "<database secret>";
  //To connect without auth in Test Mode, see Authentications/TestMode/TestMode.ino
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void temperature(){
    
}
void humidity(){
    sensors_event_t event;

}
//SMARTLIGHT SETUP
void smartLight_setup(){
  //pinMode(RELAY3, OUTPUT);
  pinMode(pirPin, INPUT);
  pinMode(LDR, INPUT);
  
  //give the sensor some time to calibrate
  Serial.print("calibrating sensor ");
    for(int i = 0; i < calibrationTime; i++){
      Serial.print(".");
      delay(1000);
      }
    Serial.println(" done");
    Serial.println("SENSOR ACTIVE");
    delay(50);
 }

void manualLight(){
if (Firebase.getInt(lightData, (parentPath + "/" + roomBulbStatusPath))) {

      if (lightData.dataTypeEnum() == fb_esp_rtdb_data_type_integer) {
        Serial.print("Light state: ");
      Serial.println(lightData.to<int>());
      if(lightData.to<int>() == 1){
          digitalWrite(RELAY1, HIGH);
          delay(5000);
        }}  
      else {
        Serial.println(lightData.errorReason());
      }
    }  
}

void smartLight(){
long unsigned int pause = 5000;
Serial.println("Light Intensity: ");
Serial.println(analogRead(LDR));       
    if((digitalRead(pirPin) == HIGH) && (analogRead(LDR)<= lightIntesityThreshhold)){
     digitalWrite(RELAY2, HIGH);
     json.add(lightdepentresistorStatusPath.c_str(),String(analogRead(LDR)));
     json.add(pirStatusPath.c_str(), 1);
     json.add(switch2Path.c_str(), 1);
     json.add(roomBulbStatusPath.c_str(), 1);
        
//     delay(pause);
//     
//     if(lockLow){  
//       //makes sure we wait for a transition to LOW before any further output is made:
//       lockLow = false;            
//       Serial.println("---");
//       Serial.print("motion detected at ");
//       Serial.print(millis()/1000);
//       Serial.println(" sec"); 
//       delay(50);
//       }         
//       takeLowTime = true;
     }
   else { 
    manualLight();
     digitalWrite(RELAY2, LOW);
     json.add(lightdepentresistorStatusPath.c_str(),String(analogRead(LDR)));
     json.add(pirStatusPath.c_str(), 0);
     json.add(switch2Path.c_str(), 0);
     json.add(roomBulbStatusPath.c_str(), 0);
     
//     if(takeLowTime){
//      lowIn = millis();          //save the time of the transition from high to LOW
//      takeLowTime = false;       //make sure this is only done at the start of a LOW phase
//      }
//     //if the sensor is low for more than the given pause, 
//     //we assume that no more motion is going to happen
//     if(!lockLow && millis() - lowIn > pause){  
//         //makes sure this block of code is only executed again after 
//         //a new motion sequence has been detected
//         lockLow = true;                        
//         Serial.print("motion ended at ");      //output
//         Serial.print((millis() - pause)/1000);
//         Serial.println(" sec");
         delay(50);
         }
}

void manualFan(){
if (Firebase.getInt(fanData, (parentPath + "/" + fanStatusPath))) {

      if (fanData.dataTypeEnum() == fb_esp_rtdb_data_type_integer) {
        Serial.print("Fan state: ");
      Serial.println(fanData.to<int>());
      if(fanData.to<int>() == 1){
          digitalWrite(RELAY2, HIGH);
          delay(5000);
        }}  
      else {
        Serial.println(fanData.errorReason());
      }
    }  
}
 
void smartFan(){
  sensors_event_t event;
  dht.temperature().getEvent(&event);
  if (isnan(event.temperature)) {
    Serial.println(F("Error reading temperature!"));
  }
  else {
    Serial.print(F("Temperature: "));
    Serial.print(event.temperature);
    Serial.println(F("°C"));
    
    json.add(temperaturePath.c_str(), float(event.temperature));
    updateTemp(event.temperature);
  }
  // Get humidity event and print its value.
  dht.humidity().getEvent(&event);
  if (isnan(event.relative_humidity)) {
    Serial.println(F("Error reading humidity!"));
  }
  else {
    Serial.print(F("Humidity: "));
    Serial.print(event.relative_humidity);
    Serial.println(F("%"));
    json.add(humidityPath.c_str(), float(event.relative_humidity));
    updateHumidity(event.relative_humidity);
  }

  
  
  if(event.temperature > 27 || event.relative_humidity > 50){
    digitalWrite(RELAY1, HIGH);
    json.add(switch1Path.c_str(), 1);
    json.add(fanStatusPath.c_str(), 1);
    
  }
  else{
    manualFan();
    digitalWrite(RELAY1, LOW);
    json.add(switch1Path.c_str(), 0);
    json.add(fanStatusPath.c_str(), 0);
    }
  }
