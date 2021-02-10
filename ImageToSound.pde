/*------------------------------------------------------------------
  
                          Esame  Creative Computing  
                          Massimiliano Collavo
                           
  
                             Image To sound
                             
Trasforma immagine in suono e disegna una spirale in base alla nota con applicato rumore di perlin

Istruzioni:
- 
- Premere i tasti 'q' e 'w' per fermare e attivare il script
-------------------------------------------------------------------*/



import processing.sound.*;
import processing.video.*;

// schermo dimensione
final int screenWidth = 1024;
final int screenHeight = 768;

int numPixel = screenHeight * screenWidth; // numero pixel schermo

// Tempo e livelli per ASR envelope
float attackTime = 0.001;
float sustainTime = 0.004;
float sustainLevel = 0.2;
float releaseTime = 0.2;
int threshold = 25; //soglia fissa 0, 255. Scegliere un valore adeguato (eventualmente con il mouse, tweak o GUI).

// Note MIDI
/*
int[] midiSequence = {
14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,77,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107
};


*/

Capture video; // dichiarazione variabile Capture
imageToSound sound; //Dichiarazione varibile di tipo ImagetoSound

int numNote = 30;


/* Disegno */

int x,y;
int curvePointX = 0;
int curvePointY = 0;
int pointCount = 1;
float diffusion = 50;


/* 
* Oscilaltore ed envelope */

TriOsc triOsc;
Env env;

int duration = 200; // Setta la durata fra le note
int trigger = 10; // Setta il trigger delle note
int inote = 0; // indice per contare il numero di note


PImage prev; // memorizza immagine screen precedente
int[] midiSequence = new int[numNote]; //inizializzo array con le note


void setup() {
 size(1024, 768);
 video = new Capture(this, screenWidth, screenHeight); //creazione oggetto di tipo Capture
 video.start(); //cattura da webcam abilitata
 

 // Definisco Oscillaltore e Inviluppo
 triOsc = new TriOsc(this);
 env = new Env(this);
 
 
 ///Creazione oggetto Image sound. 
  sound = new imageToSound(video,video, threshold,screenWidth,screenHeight);

}


void draw() {
  //frameRate(30);
  background(#000000);
  smooth();
  //noFill();
  

  if (video.available()) {

   prev = video.copy(); // copia immagine video in prev(vecchio frame)
   video.read(); // leggi nuovo frame


   int threshold = 20; /// valore di soglia
   //int thres=int(map(mouseX,0, width,0, 255)); /// valore di soglia

   sound.scanImage(video, prev, threshold);
   //image(video,0,0);

   /* ########## SUONO */
   
     // If value of trigger is equal to the computer clock and if not all
     // notes have been played yet, the next note gets triggered.
         if ((millis() > trigger) && (inote<midiSequence.length)) {
       

           //sound.play(inote);
           // Suono Oscilaltore con ampiezza 0.8
              // midiToFreq transforms the MIDI value into a frequency in Hz which we use
              
          triOsc.play(utils.midiToFreq(midiSequence[inote]), 0.8);
          
          //sound.play(utils.midiToFreq(midiSequence[inote]));

              // The envelope gets triggered with the oscillator as input and the times and
             env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
             
                
            // Aggiorno il trigger in base alla durata e velocità
            trigger = millis() + duration;
                  

            
            // disegno spirale

            sound.drawSound(midiSequence[inote],prev);
            
            
            
            
          inote ++;
          if (inote == numNote) inote=0;
  } /// fine suono note
       
   /* ########## */      



  

  } //end video avaiable

 } //end draw



/// fermo o faccio ripartire il loop

void keyReleased() {

 if (key == 'q' || key == 'S') noLoop();
 if (key == 'w' || key == 'W') loop();
 

}