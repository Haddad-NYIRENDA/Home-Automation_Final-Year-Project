///variables
///<*Smart Home: IOT based Effiecient Household Resource usage Project
///<*Using LoRa32 Micro-Controller: an ESP32 with Built in LoRa Capabilities and OLED Display
///* 
 ///<* i.e., Electricity and Water
 ///<* Final Year Project: @University of Malawi
 ///<* Ramsey Njema bsc-com-ne-10-17@unima.ac.mw
 ///<* Haddard Nyirenda bsc-com-ne-10-17@unima.ac.mw
 ///<*/
////<*========================================================================================================================================================================================
 ///<* Include Neccessary Libraries
 ///<*/


char *WIFI_SSID;
char *WIFI_PASSWORD; 
#if defined(ESP32)
#include <WiFi.h>
#include <FirebaseESP32.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#endif

///DHT
#include <Adafruit_Sensor.h>
/// DHT
#include <DHT.h>
#include <DHT_U.h>
#define RELAY1 22 ///switch for fan
#define RELAY2 13 ///switch for light
#define DHTPIN 17 
#define pirPin 21  
#define LDR 36
#define DHTTYPE DHT22
DHT_Unified dht(DHTPIN, DHTTYPE);

////Firebase Necesities
///Provide the token generation process info.
#include <addons/TokenHelper.h>
///Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

///*=========================================================================================================================================================================================
/// * Fixed Variable declaration
/// */
 
///For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino
/* 2. Define the API Key */
<<<<<<< HEAD
#define API_KEY ""
=======
#define API_KEY " "
>>>>>>> 77fdfd987945ca42f46f9dfa2ecb9a56ab8e55e5
/* 3. Define the RTDB URL */
#define DATABASE_URL "https://shautom-app-test-default-rtdb.asia-southeast1.firebasedatabase.app" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app
/* 4. Define the user Email and password that alreadey registerd or added in your project */
char *USER_EMAIL;
char *USER_PASSWORD;

/*=========================================================================================================================================================================================
 * Variable Declration and instatiation
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

//DHT events
sensors_event_t event;

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
   
}

//main loop method
void loop(){
if (Firebase.ready() && (millis() - sendDataPrevMillis > delayMS || sendDataPrevMillis == 0)){
    sendDataPrevMillis = millis();
 
    
    delay(delayMS);
    //smartLight();
    //smartFan();
    
    manualLight();
    sendDHT();
    manualFan();
    Serial.printf("Set json... %s\n", Firebase.RTDB.updateNode(&fbdo, parentPath.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
    
  }
}

/*======================================================================================================================================================================================//
--Funtions in the setup
--Functions that will run one time
--Probably intializing the sensors
*/
  

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

  /* 
  --WiFi and Email credentials
  */
  WIFI_SSID = "Ramsey's MiFi";
  WIFI_PASSWORD = "Chimphepo";


  USER_EMAIL = "bsc-com-ne-10-17@unima.ac.mw";
  USER_PASSWORD = "12345678";

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



void sendDHT(){
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
}

//SMARTLIGHT SETUP
void smartLight_setup(){
  //pinMode(RELAY3, OUTPUT);
  pinMode(pirPin, INPUT);
  pinMode(LDR, INPUT);
  
  //give the sensor some time to calibrate, this is the passive infrared sensor.
  Serial.print("calibrating sensor ");
    for(int i = 0; i < calibrationTime; i++){
      Serial.print(".");
      delay(1000);
      }
    Serial.println(" done");
    Serial.println("SENSOR ACTIVE");
    delay(50);
 }


/*
This portion lets the user to be to control the light manually
*/

void manualLight(){
  FirebaseData ld;
if (Firebase.getInt(lightData, (parentPath + "/" + switch2Path))) {
      if (lightData.dataTypeEnum() == fb_esp_rtdb_data_type_integer){
        Serial.print("Light state: ");
      Serial.println(lightData.to<int>());
         int lightState = lightData.to<int>();
         smartLight(lightState);
    }  
}
else {
        //digitalWrite(RELAY2, LOW);
        Serial.println(lightData.errorReason());
      }

}
/*
The motion sensor (passive infrared sensor) by reading radiation in form of heat produced by animaic things (humans, animals).
The light dependent resistor works by reading analog values from 0-1023, if values fall 700 its night time.
combining these sensors we create a smart light controller that turns lights on if its dark only in a presence of animaic being (i.e., man)
*
then updates the data base on the state of ldr, pir and bulb
*/
void smartLight(int val){
long unsigned int pause = 5000;
Serial.println("Light Intensity: ");
Serial.println(analogRead(LDR));    
Serial.printf("%d",digitalRead(pirPin));
    if(val == 1){   
      if(analogRead(LDR)<= lightIntesityThreshhold){
        digitalWrite(RELAY2, HIGH);
        json.add(lightdepentresistorStatusPath.c_str(),String(analogRead(LDR)));
        json.add(pirStatusPath.c_str(), 1);
        //json.add(switch2Path.c_str(), 1);
        json.add(roomBulbStatusPath.c_str(), 1);
       }
      else { 
        json.add(lightdepentresistorStatusPath.c_str(),String(analogRead(LDR)));
        json.add(pirStatusPath.c_str(), 0);
        //json.add(switch2Path.c_str(), 0);
        json.add(roomBulbStatusPath.c_str(), 0);
         }
    }else{
      digitalWrite(RELAY2, LOW);
      json.add(roomBulbStatusPath.c_str(), 0);
      }
}

/*
Fan should automatically turn on or off. For humidity above 50 % or temperature greater than 27 turn on since a person is comfortable when
the temperature is not more above 25% and presence of water vapor is no more that 50%. *
*/

void smartFan(int val){
        if(val == 1){
          if(event.temperature > 25 || event.relative_humidity > 50){
            digitalWrite(RELAY1, HIGH);
            json.add(fanStatusPath.c_str(), 1);
          }else{
            //digitalWrite(RELAY1, LOW);
            json.add(fanStatusPath.c_str(), 0);
         }
       }else{
        digitalWrite(RELAY1, LOW);
        }         
}

/*

The Manual part of the fan is like switching on or off the main circuit and then being able to manually control the fan in absence of the automatic
mechanism.

*/
void manualFan(){
    if (Firebase.getInt(fanData, (parentPath + "/" + switch1Path).c_str())) {
      if (fanData.dataTypeEnum() == fb_esp_rtdb_data_type_integer){
        Serial.print("Fan state: ");
        Serial.println(fanData.to<int>());
           int powerState = fanData.to<int>();
          smartFan(powerState);
    } 
    }else {
        Serial.println(fanData.errorReason());}
}
