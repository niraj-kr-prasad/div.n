///////////////////////////////////////////
////      Stepper Controller           ///
////MAG 2024     -    Magda Carr      ///
////  Written for Arduino Nano EVERY ///
///////////////////////////////////////

//Accel-library for improved speed
#include <AccelStepper.h>
#include <AccelStepperWithDistance.h>

#define STEP_PIN 12   //PWM pin
#define DIR_PIN 11    //Step direction

AccelStepperWithDistance stepper(AccelStepperWithDistance::DRIVER, STEP_PIN, DIR_PIN);


// Start and Stop LED controls
const int startLED = 2;   //Start LED pin
const int stopLED = 3;    //Stop LED pin
int startLEDState = LOW;  //Start LED State Flag
int stopLEDState = LOW;   //Stop LED State Flag
int startButton = 0;      //Start button value
int stopButton = 0;       //Stop button value
int limit = 0;            //Initial limit condition
unsigned long int stepsPerRevolution = 24550;   //~150mm distance at 1600 pulse/rev

int DIST = 240;           //Distance in mm [do not add polarity!]

// Timer functions
unsigned long previousMillis = 0;  //Stores LED time
unsigned long currentMillis = millis();
const long interval = 100;         //LED Blink rate

//Flags
boolean homeRun = false;    // homeRun = stepper limit switch location check

void setup() {
  
  // pin assignment setup
#define startBTN A1
#define stopBTN A0
#define limiter A2
#define dirPin 11
#define stepPin 12
#define microtime 200
#define sampletrig 8

  // Pin function assignment
  pinMode(startLED, OUTPUT);
  pinMode(stopLED, OUTPUT);
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(sampletrig, OUTPUT);

  //Set default direction
  digitalWrite(dirPin, LOW); //bck
  //Set sampler trigger default = off
  //digitalWrite(sampletrig, LOW);        // Only used for sample trigger signal on D10

  //AccelStepper parameters
  stepper.setMaxSpeed(150000);
  stepper.setAcceleration(6000);
  stepper.setStepsPerRotation(200);  // For a 1.8° stepper motor
  stepper.setMicroStep(2);          // If using 1/16 microstepping
  stepper.setDistancePerRotation(5); // If one rotation moves 5mm

  Serial.begin(9600);
}

void alignmentLimit(){              // Defines limit switch location and saves as home position
limit = analogRead(limiter);

if (limit >=250){                   // If probe not in home position, move it and change LED
  digitalWrite(2, LOW);
  digitalWrite(3, HIGH);
  digitalWrite(dirPin, HIGH);
  for (int i=0; i < 200; i++) {
  digitalWrite(stepPin, HIGH);
  delayMicroseconds(500);
  digitalWrite(stepPin, LOW);
  delayMicroseconds(500);
    }
  }
  else if (limit <=250) {            // If limit switch is HIGH, end routine
    digitalWrite(3, LOW);
    digitalWrite(2, HIGH);
    homeRun = true;                  // Prevents routine running again until hard reset
  }
}


void MoveStepper() {                           // Execute a 150mm extension and retraction
  unsigned long currentMillis = millis();
  startButton = analogRead(startBTN);            // Read Start button condition and assign variable
   Serial.println(startButton);                // For debugging button/trigger bounce
  if (startButton <=500 && limit <=250){        //Check if button pressed
     delay(10);                            
      stepper.runToNewDistance(-DIST);            // Move 150mm
      stepper.runToNewDistance(0);               // Return to starting position
      delay(10);
      }
delay(1);
  }

void loop() {   
  if (homeRun == false)                      // Check if stepper has returned to home
  {
    alignmentLimit();
    }
  else  {
    MoveStepper();                           // Prime for strike
    }
}
