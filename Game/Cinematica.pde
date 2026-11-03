// ==========================================
// CLASE CINEMATIC (PESTAÑA APARTE) - SIN BARRA DE BIENESTAR
// ==========================================
class Cinematic {
  int scene = 1;
  int timer = 0;
  String currentText = "";
  String fullText = "";
  int charIndex = 0;
  String speakerName = "";
  int tipoCinematica; // 0 = Intro, 1 = Boss, 2 = Final

  PImage patioBg;
  PImage portEstudiante, portIntrigante, portMaton, portJefe;

  Cinematic(int tipo) {
    tipoCinematica = tipo;
    patioBg = loadImage("patio_bg.png");
    portEstudiante = loadImage("portrait_estudiante.png");
    portIntrigante = loadImage("portrait_intrigante.png");
    portMaton = loadImage("portrait_maton.png");
    portJefe = loadImage("portrait_jefe.png"); 
    loadScene(1);
  }

  void updateAndDraw() {
    timer++;

    if (timer % 2 == 0 && charIndex < fullText.length()) {
      charIndex++;
      currentText = fullText.substring(0, charIndex);
    }

    if (patioBg != null) {
      image(patioBg, 0, 0, width, height);
    } else {
      background(20, 25, 35);
    }

    noStroke();
    fill(10, 15, 40, 170); 
    rect(0, 0, width, height);

    // La barra de BIENESTAR fue eliminada de aquí para limpiar la pantalla

    drawSceneCharacters();

    // Caja de diálogo inferior
    stroke(255, 215, 0);
    strokeWeight(4);
    fill(10, 25, 80, 230);
    rect(30, height - 160, width - 60, 130, 10);

    drawSpeakerPortrait(45, height - 145, 100, 100);

    fill(255, 215, 0);
    textSize(16);
    textAlign(LEFT, TOP);
    text(speakerName, 160, height - 145);

    fill(255);
    textSize(15);
    text(currentText, 160, height - 120, width - 240, 75);

    fill(180);
    textSize(11);
    textAlign(RIGHT, BOTTOM);
    text("[ESPACIO] Avanzar | [ENTER] Saltar", width - 45, height - 40);
    textAlign(LEFT, BASELINE);
  }

  void drawSceneCharacters() {
    imageMode(CENTER);
    float baseY = height / 2 + 40;

    if (tipoCinematica == 0) {
      if (scene == 1 || scene == 4) {
        if (idleSprite != null) {
          float w = idleSprite.width * 0.26;
          float h = idleSprite.height * 0.26;
          fill(0, 100); noStroke(); ellipse(width / 2, baseY + h/2 - 5, 70, 18);
          image(idleSprite, width / 2, baseY, w, h);
        }
      } else if (scene == 2) {
        if (intriganteIdle != null && intriganteIdle.length > 0) {
          float w = intriganteIdle[0].width * 0.20;
          float h = intriganteIdle[0].height * 0.20;
          fill(0, 100); noStroke(); ellipse(width / 2, baseY + h/2 - 5, 65, 16);
          image(intriganteIdle[0], width / 2, baseY + 10, w, h);
        }
      } else if (scene == 3) {
        if (matonIdle != null && matonIdle.length > 0) {
          float w = matonIdle[0].width * 0.24;
          float h = matonIdle[0].height * 0.24;
          fill(0, 100); noStroke(); ellipse(width / 2, baseY + h/2 - 5, 70, 18);
          image(matonIdle[0], width / 2, baseY + 5, w, h);
        }
      }
    } else if (tipoCinematica == 1) {
      if (scene == 1) {
        if (matonIdle != null && matonIdle.length > 0) {
          float w = matonIdle[0].width * 0.24;
          float h = matonIdle[0].height * 0.24;
          fill(0, 100); noStroke(); ellipse(width / 2, baseY + h/2 - 5, 70, 18);
          image(matonIdle[0], width / 2, baseY + 5, w, h);
        }
      } else if (scene == 2) {
        if (intriganteIdle != null && intriganteIdle.length > 0) {
          float w = intriganteIdle[0].width * 0.20;
          float h = intriganteIdle[0].height * 0.20;
          fill(0, 100); noStroke(); ellipse(width / 2, baseY + h/2 - 5, 65, 16);
          image(intriganteIdle[0], width / 2, baseY + 10, w, h);
        }
      } else if (scene == 3) {
        if (jefeIdle != null && jefeIdle.length > 0) {
          PImage spriteBoss = jefeIdle[0];
          float w = spriteBoss.width * 0.35;
          float h = spriteBoss.height * 0.35;
          fill(0, 100); noStroke(); ellipse(width / 2, baseY + h/2 - 5, 90, 22);
          image(spriteBoss, width / 2, baseY, w, h);
        }
      } else if (scene == 4) {
        if (idleSprite != null) {
          float w = idleSprite.width * 0.26;
          float h = idleSprite.height * 0.26;
          fill(0, 100); noStroke(); ellipse(width / 2, baseY + h/2 - 5, 70, 18);
          image(idleSprite, width / 2, baseY, w, h);
        }
      }
    } else if (tipoCinematica == 2) {
      if (scene == 1) {
        if (jefeHit != null && jefeHit.length > 0) {
          PImage spriteBoss = jefeHit[0]; 
          float w = spriteBoss.width * 0.35;
          float h = spriteBoss.height * 0.35;
          fill(0, 100); noStroke(); ellipse(width / 2, baseY + h/2 - 5, 90, 22);
          image(spriteBoss, width / 2, baseY, w, h);
        }
      } else if (scene == 2 || scene == 3) {
        if (idleSprite != null) {
          float w = idleSprite.width * 0.26;
          float h = idleSprite.height * 0.26;
          fill(0, 100); noStroke(); ellipse(width / 2, baseY + h/2 - 5, 70, 18);
          image(idleSprite, width / 2, baseY, w, h);
        }
      }
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
    else if (speakerName.equals("EL JEFE")) portraitTarget = portJefe;

    if (portraitTarget != null) {
      imageMode(CORNER);
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

    if (tipoCinematica == 0) {
      if (num == 1) { speakerName = "EL ESTUDIANTE"; fullText = "El patio del colegio solía ser un lugar tranquilo... hasta que los mensajes negativos empezaron a arruinar todo."; }
      else if (num == 2) { speakerName = "LA INTRIGANTE"; fullText = "¡Atención a todos! ¿Ya vieron el rumor que circula en la red? ¡Alguien quiere acabar con nosotros!"; }
      else if (num == 3) { speakerName = "EL MATÓN"; fullText = "¡Imposible! Quien quiera que seas, acabaré contigo."; }
      else if (num == 4) { speakerName = "EL ESTUDIANTE"; fullText = "¡Eso lo veremos! No me rendiré hasta que el ciberacoso se vaya de este colegio."; }
    } else if (tipoCinematica == 1) {
      if (num == 1) { speakerName = "EL MATÓN"; fullText = "Es demasiado fuerte, no puedo pararlo yo solo."; }
      else if (num == 2) { speakerName = "LA INTRIGANTE"; fullText = "No puedo con su energía positiva, es demasiado para mí."; }
      else if (num == 3) { speakerName = "EL JEFE"; fullText = "¡Inútiles! No son lo suficientemente inteligentes para vencerlo. Tendré que hacerlo con mis propias manos."; }
      else if (num == 4) { speakerName = "EL ESTUDIANTE"; fullText = "¡Ah, con que tú estás detrás de todo esto! Venga, vamos a acabar con el ciberacoso de una vez por todas."; }
    } else if (tipoCinematica == 2) {
      if (num == 1) { speakerName = "EL JEFE"; fullText = "¡NO! NO PUEDE SER. ¡Todo el ciberacoso desaparecerá!"; }
      else if (num == 2) { speakerName = "EL ESTUDIANTE"; fullText = "¡Sí! Hemos vencido al ciberacoso y el colegio por fin volverá a ser como antes: lleno de risas, alegría y energía positiva!"; }
      else if (num == 3) { speakerName = "EL ESTUDIANTE"; fullText = "Gracias por jugar y recuerda: Di no al ciberacoso."; }
    }
  }

  void finalizarCinematica() {
    if (tipoCinematica == 0) {
      cambiarPantalla(STATE_MENU);
    } else if (tipoCinematica == 1) {
      rondaActual = 3;
      temporizadorRonda = 0;
      jefeFinal = new JefeFinal(width / 2, 350);
      cambiarPantalla(STATE_GAME);
    } else if (tipoCinematica == 2) {
      cambiarPantalla(STATE_VICTORY); 
    }
  }

  void handleKeyPress() {
    if (key == ' ') {
      if (charIndex < fullText.length()) {
        charIndex = fullText.length();
        currentText = fullText;
      } else {
        scene++;
        int maxScenes = (tipoCinematica == 2) ? 3 : 4; 
        if (scene > maxScenes) {
          finalizarCinematica();
        } else {
          loadScene(scene);
        }
      }
    }
    if (keyCode == ENTER || keyCode == RETURN) {
      finalizarCinematica();
    }
  }
}
