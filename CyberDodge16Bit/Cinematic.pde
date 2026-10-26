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
    patioBg = loadImage("patio_bg.png");
    portEstudiante = loadImage("portrait_estudiante.png");
    portIntrigante = loadImage("portrait_intrigante.png");
    portMaton = loadImage("portrait_maton.png");

    loadScene(1);
  }

  void updateAndDraw() {
    timer++;

    // Máquina de escribir (1 letra cada 2 frames)
    if (timer % 2 == 0 && charIndex < fullText.length()) {
      charIndex++;
      currentText = fullText.substring(0, charIndex);
    }

    // 1. ESCENARIO DE FONDO CON FILTRO NOCTURNO
    if (patioBg != null) {
      image(patioBg, 0, 0, width, height);
    } else {
      background(20, 25, 35);
    }

    noStroke();
    fill(10, 15, 40, 170); // Penumbra azulada
    rect(0, 0, width, height);

    // 2. HUD SUPERIOR
    stroke(255, 215, 0);
    strokeWeight(2);
    fill(0, 160);
    rect(30, 20, 220, 35, 5);

    fill(50, 205, 50);
    rect(40, 28, 150, 18, 3);
    fill(255);
    textSize(12);
    textAlign(LEFT, CENTER);
    text("BIENESTAR", 200, 37);

    // 3. PERSONAJES
    drawSceneCharacters();

    // 4. CAJA DE DIÁLOGO RPG INFERIOR
    stroke(255, 215, 0);
    strokeWeight(4);
    fill(10, 25, 80, 230);
    rect(30, height - 160, width - 60, 130, 10);

    // RETRATO Y MARCO
    drawSpeakerPortrait(45, height - 145, 100, 100);

    // NOMBRE DEL PERSONAJE
    fill(255, 215, 0);
    textSize(16);
    textAlign(LEFT, TOP);
    text(speakerName, 160, height - 145);

    // TEXTO DE LA HISTORIA
    fill(255);
    textSize(15);
    text(currentText, 160, height - 120, width - 240, 75);

    // INSTRUCCIONES EN PANTALLA
    fill(180);
    textSize(11);
    textAlign(RIGHT, BOTTOM);
    text("[ESPACIO] Avanzar | [ENTER] Saltar al Menú", width - 45, height - 40);
  }

  void drawSceneCharacters() {
    fill(0, 100);
    ellipse(width / 2 - 100, height / 2 + 100, 80, 20);
    fill(50, 150, 255);
    rect(width / 2 - 130, height / 2, 60, 100, 5);

    if (scene == 2 || scene == 3) {
      fill(0, 100);
      ellipse(width / 2 + 100, height / 2 + 100, 80, 20);
      fill(255, 80, 80);
      rect(width / 2 + 70, height / 2, 60, 100, 5);
    }
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
          estadoActual = 0; // <--- Cambia a tu estadoActual = 0 (pantallaMenu)
        } else {
          loadScene(scene);
        }
      }
    }

    if (keyCode == ENTER) {
      estadoActual = 0; // <--- Cambia a tu estadoActual = 0 (pantallaMenu)
    }
  }
}
