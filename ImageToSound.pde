/*------------------------------------------------------------------

                             Image To sound
                             
Trasforma immagine in suono e disegna una spirale in base alla nota con applicato rumore di perlin

Istruzioni:

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


 } //end video avaiable

} //end draw


/// fermo o faccio ripartire il loop

void keyReleased() {

 if (key == 'q' || key == 'S') noLoop();
 if (key == 'w' || key == 'W') loop();
 
}