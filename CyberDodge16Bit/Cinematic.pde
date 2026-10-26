// ==========================================================================
// CINEMATIC: cinemática inicial (diálogos estilo RPG con efecto máquina de
// escribir). Al terminar, o al pulsar ENTER, pasa al menú con un fade.
// ==========================================================================
class Cinematic {
  int scene = 1;
  int timer = 0;
  String currentText = "";
  String fullText = "";
  int charIndex = 0;
  String speakerName = "";

  PImage patioBg;
  PImage portEstudiante, portIntrigante, portMaton;

  Cinematic() {
    patioBg = loadImage("escenario.png");
    portEstudiante = loadImage("portrait_estudiante.png");
    portIntrigante = loadImage("portrait_intrigante.png");
    portMaton = loadImage("portrait_maton.png");

    loadScene(1);
  }

  void updateAndDraw() {
    pushStyle();
    timer++;

    // Máquina de escribir (1 letra cada 2 frames)
    if (timer % 2 == 0 && charIndex < fullText.length()) {
      charIndex++;
      currentText = fullText.substring(0, charIndex);
    }

    // 1. ESCENARIO DE FONDO CON FILTRO NOCTURNO
    if (patioBg != null) {
      image(patioBg, 0, 0, GW, GH);
    } else {
      background(20, 25, 35);
    }

    noStroke();
    fill(10, 15, 40, 170); // Penumbra azulada
    rect(0, 0, GW, GH);

    // 2. HUD SUPERIOR
    stroke(255, 215, 0);
    strokeWeight(2);
    fill(0, 160);
    rect(30, 20, 235, 35, 5);

    fill(50, 205, 50);
    rect(40, 28, 125, 18, 3);
    fill(255);
    textSize(12);
    textAlign(LEFT, CENTER);
    text("BIENESTAR", 176, 37);

    // 3. PERSONAJES
    drawSceneCharacters();

    // 4. CAJA DE DIÁLOGO RPG INFERIOR
    stroke(255, 215, 0);
    strokeWeight(4);
    fill(10, 25, 80, 230);
    rect(30, GH - 160, GW - 60, 130, 10);

    // RETRATO Y MARCO
    drawSpeakerPortrait(45, GH - 145, 100, 100);

    // NOMBRE DEL PERSONAJE
    fill(255, 215, 0);
    textSize(16);
    textAlign(LEFT, TOP);
    text(speakerName, 160, GH - 145);

    // TEXTO DE LA HISTORIA
    fill(255);
    textSize(15);
    text(currentText, 160, GH - 120, GW - 240, 75);

    // INSTRUCCIONES EN PANTALLA
    fill(180);
    textSize(11);
    textAlign(RIGHT, BOTTOM);
    text("[ESPACIO] Avanzar | [ENTER] Saltar al Menú", GW - 45, GH - 40);
    popStyle();
  }

  // Personajes de la escena: sprites reales del juego. La Intrigante no tiene
  // sprite de cuerpo, así que aparece como una publicación de red social.
  void drawSceneCharacters() {
    float suelo = 368;
    float bob = sin(frameCount * 0.08f) * 2;
    float estX = (scene == 1 || scene == 4) ? GW / 2 : GW / 2 - 140;

    dibujarSombra(estX, suelo);
    dibujarSprite(juego.idleSprite, estX, suelo + bob, 205, false);

    if (scene == 2) {
      dibujarTarjetaIntrigante(GW / 2 + 110, 120);
    } else if (scene == 3) {
      float matX = GW / 2 + 150;
      dibujarSombra(matX, suelo);
      PImage[] idle = juego.matonIdle;
      PImage frame = idle[(frameCount / 14) % idle.length];
      dibujarSprite(frame, matX, suelo + 14, 270, true);
    }
  }

  void dibujarSombra(float cx, float suelo) {
    pushStyle();
    noStroke();
    fill(0, 110);
    ellipse(cx, suelo, 120, 22);
    popStyle();
  }

  // Dibuja un sprite centrado en cx con su base en "suelo"
  void dibujarSprite(PImage img, float cx, float suelo, float h, boolean espejo) {
    if (img == null) return;
    float w = img.width * h / img.height;
    pushMatrix();
    translate(cx, suelo - h);
    if (espejo) scale(-1, 1);
    image(img, -w / 2, 0, w, h);
    popMatrix();
  }

  void dibujarTarjetaIntrigante(float cx, float top) {
    float w = 240, h = 215, x = cx - w / 2;
    pushStyle();
    noStroke();
    fill(0, 110);
    rect(x + 5, top + 6, w, h, 12);
    stroke(160, 80, 210);
    strokeWeight(3);
    fill(30, 20, 60, 238);
    rect(x, top, w, h, 12);

    if (portIntrigante != null) image(portIntrigante, x + 15, top + 15, 90, 90);
    noFill();
    stroke(190, 110, 240);
    strokeWeight(2);
    rect(x + 15, top + 15, 90, 90, 8);

    noStroke();
    fill(255);
    textAlign(LEFT, TOP);
    textSize(15);
    text("@LaIntrigante", x + 118, top + 28);
    fill(170);
    textSize(11);
    text("hace 1 min · público", x + 118, top + 50);
    fill(255);
    textSize(13);
    text("¡RUMOR NUEVO! Compártelo antes de que lo borren...", x + 15, top + 118, w - 30, 50);
    fill(255, 130, 130);
    textSize(12);
    text("1,2 mil compartidos · 300 comentarios", x + 15, top + 182);
    popStyle();
  }

  void drawSpeakerPortrait(float x, float y, float w, float h) {
    fill(20, 40, 100);
    stroke(255);
    strokeWeight(2);
    rect(x, y, w, h, 8);

    PImage portraitTarget = null;
    if (speakerName.equals("EL ESTUDIANTE")) portraitTarget = portEstudiante;
    else if (speakerName.equals("LA INTRIGANTE")) portraitTarget = portIntrigante;
    else if (speakerName.equals("EL MATÓN")) portraitTarget = portMaton;

    if (portraitTarget != null) {
      image(portraitTarget, x, y, w, h);
    } else {
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(11);
      text("[" + speakerName + "]", x + w/2, y + h/2);
    }
  }

  void loadScene(int num) {
    timer = 0;
    charIndex = 0;
    currentText = "";

    if (num == 1) {
      speakerName = "EL ESTUDIANTE";
      fullText = "El patio del colegio solía ser un lugar tranquilo... hasta que las notificaciones comenzaron a inundar nuestras pantallas.";
    } else if (num == 2) {
      speakerName = "LA INTRIGANTE";
      fullText = "¡Atención a todos! ¿Ya vieron el nuevo rumor que circula en la red? ¡Esto se va a hacer viral en segundos!";
    } else if (num == 3) {
      speakerName = "EL MATÓN";
      fullText = "¡Nadie escapa de la red! Si no bloqueas mis ataques, tu bienestar va a llegar a cero.";
    } else if (num == 4) {
      speakerName = "EL ESTUDIANTE";
      fullText = "¡No me voy a rendir! Capturaré el apoyo [C], bloquearé la toxicidad [B] y reportaré el ciberacoso [R]!";
    }
  }

  void handleKeyPress() {
    if (key == ' ') {
      if (charIndex < fullText.length()) {
        charIndex = fullText.length();
        currentText = fullText;
      } else {
        scene++;
        if (scene > 4) {
          juego.cambiarPantalla(STATE_MENU);
        } else {
          loadScene(scene);
        }
      }
    }

    if (esEnter()) {
      juego.cambiarPantalla(STATE_MENU);
    }
  }
}
