import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ImageToSound extends PApplet {

/*------------------------------------------------------------------
  
                         
                           
  
                             Image To sound
                             
Trasforma immagine in suono e disegna una spirale in base alla nota con applicato rumore di perlin

Istruzioni:
- Premere il pulsante del mouse per acquisire il background
- Premere i tasti '1' o '2' per attivare il teletrasporto
-------------------------------------------------------------------*/






// schermo dimensione
final int screenWidth = 1024;
final int screenHeight = 768;

int numPixel = screenHeight * screenWidth; // numero pixel schermo

// Tempo e livelli per ASR envelope
float attackTime = 0.001f;
float sustainTime = 0.004f;
float sustainLevel = 0.2f;
float releaseTime = 0.2f;
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
int[] midiSequence = new int[numNote];

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


PImage prev; // immagine precedente


public void setup() {
 

 video = new Capture(this, screenWidth, screenHeight); //creazione oggetto di tipo Capture
 video.start(); //cattura da webcam abilitata

 // Create triangle wave and envelope
 triOsc = new TriOsc(this);
 env = new Env(this);
 
 
 ///Creazione oggetto Image sound. Si noti il costruttore dopo l'istruzione new
   sound = new imageToSound( video,video, threshold);

}


public void draw() {
  //frameRate(30);
  background(0xff000000);
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
              
          triOsc.play(utils.midiToFreq(midiSequence[inote]), 0.8f);
          
          //sound.play(utils.midiToFreq(midiSequence[inote]));

              // The envelope gets triggered with the oscillator as input and the times and
             env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
             
                
            // Aggiorno il trigger in base alla durata e velocit\u00e0
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

public void keyReleased() {

 if (key == 'q' || key == 'S') noLoop();
 if (key == 'w' || key == 'W') loop();
 

}
  class imageToSound {
    
    private int screenWidth = 1024;
    private  int screenHeight = 768;

   // costruttore
   imageToSound(Capture src, PImage prev, int threshold) {
     this.screenWidth = screenWidth;
     this.screenHeight= screenHeight;


    println("Oggetto ImageSound inizializzato!!!");
   }


   /*
    * questa funziona controlla che ci siano veriazioni della immagine e mappa le note
    */
    
/*-----------------------------------------
  Metodo controlla che ci siano veriazioni nella schermatase ci sono calcola il valore HUE del pixel
  e lo somma ad un contatote 
  Poi Mappa il valore el contatore sulle note MIDI da 14 130
  
  @input Capture src
  @input PImage prev
  @input threshold
  
---------------------------------------------*/

   public void scanImage(Capture src, PImage prev, int threshold) {

    loadPixels(); //abilita modifica valori pixel canvas in array pixels
    src.loadPixels(); //abilita  modifiche sui pixel di imaggine corrente
    prev.loadPixels(); //abilita  modifiche sui pixel di image  precedente

    int[] pixelValue = new int[this.screenHeight];
    for (int y = 0; y < src.height; y++) {
     // array dove inserire valori somme riga
     int lineSum = 0; // contatori per calcolo nota
     // int lineSum1 = 0;

     for (int x = 0; x < src.width; x++) {


      int index = x + y * src.width; //conversione da punto 2D a indice array 1D di img

      int currentColor = src.pixels[index]; //colore del pixel (x,y)
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);

      int prevCol = prev.pixels[index]; // colore pixel al frame precedente
      float r2 = red(prevCol);
      float g2 = green(prevCol);
      float b2 = blue(prevCol);

      float dist = dist(r1, g1, b1, r2, g2, b2); // distanza euclidea fra due vettori

      // se la distanza \u00e8 minore della soglia non esiste variazione altriemnti esiste
      if (dist < threshold) {
        pixels[index]=color(map(mouseX, 0,width,0,255),map(mouseY, 0,width,0,255),random(0,255));
      } else {
       //pixels[index]=color(255);
       // sommo il valore hue di ogni pixel
       lineSum += hue(currentColor);
       //lineSum1 += (r1+g1+b1);
       pixels[index]= currentColor;
      }

      // mappo la nota MIDI in base al valore di col somma dei colori dei PIXEL
      //println("Sum: ",lineSum);
      int note = round(map(lineSum, 157332, 321676, 30, 130));
      // controllo che non ci siano battiti con note negative 
      // in teoria la funzione map dovrebbe tornare solo valori positivi perch\u00e8 mappata da 14-130 ma in realta torna anche valori negativi
      if (note < 0) note = -note;
      //int note1 = int(map(lineSum1,0,17850,14,130));
      // pixels[index]= currentColor;
      pixelValue[y] = note;


     }
     // calcolo valore casuale di dove iniziare a prendere  le note dal array delle righe

     int r = round(random(0, pixelValue.length - numNote));
     //println("r: ",r);
     //subset(list, start, count)
     midiSequence = subset(pixelValue, r, numNote);

     src.updatePixels(); //apporta modifiche di qui sopra ad image
     updatePixels();
    }


   }
   
   
  /*-----------------------------------------
  dovrebbe suonare la nota ma non funziona
  ---------------------------------------------*/

   public void play(float note) {
   
      // Suono Oscilaltore con ampiezza 0.8
      // midiToFreq transforms the MIDI value into a frequency in Hz which we use

      triOsc.play(note, 0.8f);

      // The envelope gets triggered with the oscillator as input and the times and
      env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);

   }

   
    //  disegna una spirale
   //varianza degli assi
   //float stepa, stepb; // incrementi degli assi

   public void drawSound(int note, PImage prev) {
     

 

    // prima linea
    //int pixelIndex = ((video.width - 1 - x) + y * video.width);
    // random
    int pixelIndex = (int) random(prev.width) + (int) random(prev.height);


    //color col = video.pixels[pixelIndex];
    
    int col = color(random(250), random(250), random(250)); // scelgo il colore casualmente

    
    float hueValue = hue(col);
    
    float startAngle; // angolo iniziale
    float endAngle; // angolo finale
    float stepAngle; // incremento dell'angolo
    float lastx, lasty, x, y; // coordinate precedenti e correnti
    
    //float variance = 200 
    // calcolo lavarianca in base alla nota moltiplicata per cento
    float variance = note * 50;
    
    float a = 10; // semiasse maggiore dell'ellisse
    float b = 10; // semiasse minore dell'ellisse
    float stepa, stepb; // incrementi degli assi

    float noi; // rumore di Perlin 

    float mya, myb;

    stepa = 0.5f;
    stepb = 0.5f;

    
    noi = random(note/10); //calcolo valore da passare a noise

    // lo spessore dipende dal valore della nota
    strokeWeight(note/5);
    // trasparenza calcolata random
    float trasp = random(200);

    noFill();

    stroke(col, trasp);


    startAngle = radians(random(360));
    endAngle = radians(360 * 4 + random(360 * 4)); //giri
    stepAngle = radians(random(3, 8)); // aumento angolo

    x = mouseX + a * cos(startAngle);
    y = mouseY + b * sin(startAngle);

    startAngle = radians(random(360));
    endAngle = radians(360 * 4 + random(360 * 4)); //giri
    stepAngle = radians(random(3, 8)); // aumento angolo

    for (float alpha = startAngle; alpha < endAngle; alpha += stepAngle) {
  
       lastx = x;
       lasty = y;
        
        // rumore perlin
       mya = a + (noise(noi) - 0.5f) * variance;
       myb = b + (noise(noi) - 0.5f) * variance;
  
       // casualit\u00e0
       //mya = a + (random(1) - 0.5) * variance;
      //myb = b + (random(1) - 0.5) * variance;
  
       // calcolo le coordinate di un punto sull'ellisse
       //x = width/note +  mya * cos(alpha);
       //y = height/note + myb * sin(alpha);
       
       x = width/2 + mya * cos(alpha);
       y = height/2 + myb * sin(alpha);
  
       // unisco con una linea il punto corrente e quello precedente
       line(x, y, lastx, lasty);
  
       // incremento gli assi dell'ellisse
       a = a + stepa;
       b = b + stepb;
  
       // incremento il seme del rumore di Perlin
       noi = noi + 0.05f;
    }
   }
   
   
  }
  
  
/*
    questa funziona calcola la rispettiva frequanza di una nota midi
*/
  
  static class utils {
    
    /*
    * questa funziona calcola la rispettiva frequanza di una nota midi
    */
    public static float midiToFreq(int note)
    {
     
        //return noise((pow(2, ((note-69)/12.0)))*440);
        return (pow(2, ((note-69)/12.0f)))*440;
    }

  }
  public void settings() {  size(1024, 768); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "ImageToSound" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
