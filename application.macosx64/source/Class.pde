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

   void scanImage(Capture src, PImage prev, int threshold) {

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

      color currentColor = src.pixels[index]; //colore del pixel (x,y)
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);

      color prevCol = prev.pixels[index]; // colore pixel al frame precedente
      float r2 = red(prevCol);
      float g2 = green(prevCol);
      float b2 = blue(prevCol);

      float dist = dist(r1, g1, b1, r2, g2, b2); // distanza euclidea fra due vettori

      // se la distanza è minore della soglia non esiste variazione altriemnti esiste
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
      // in teoria la funzione map dovrebbe tornare solo valori positivi perchè mappata da 14-130 ma in realta torna anche valori negativi
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

   void play(float note) {
   
      // Suono Oscilaltore con ampiezza 0.8
      // midiToFreq transforms the MIDI value into a frequency in Hz which we use

      triOsc.play(note, 0.8);

      // The envelope gets triggered with the oscillator as input and the times and
      env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);

   }

   
    //  disegna una spirale
   //varianza degli assi
   //float stepa, stepb; // incrementi degli assi

   void drawSound(int note, PImage prev) {
     

 

    // prima linea
    //int pixelIndex = ((video.width - 1 - x) + y * video.width);
    // random
    int pixelIndex = (int) random(prev.width) + (int) random(prev.height);


    //color col = video.pixels[pixelIndex];
    
    color col = color(random(250), random(250), random(250)); // scelgo il colore casualmente

    
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

    stepa = 0.5;
    stepb = 0.5;

    
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
       mya = a + (noise(noi) - 0.5) * variance;
       myb = b + (noise(noi) - 0.5) * variance;
  
       // casualità
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
       noi = noi + 0.05;
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
        return (pow(2, ((note-69)/12.0)))*440;
    }

  }