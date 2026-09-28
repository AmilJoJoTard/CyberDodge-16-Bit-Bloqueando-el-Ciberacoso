class Cinematic {
  int scene = 1;
  int timer = 0;
  String currentText = "";
  String fullText = "";
  int charIndex = 0;
  
  Cinematic() {
    loadSceneText(1);
  }
  
  void updateAndDraw() {
    timer++;
    
    // Efecto máquina de escribir (1 letra cada 3 frames)
    if (timer % 3 == 0 && charIndex < fullText.length()) {
      charIndex++;
      currentText = fullText.substring(0, charIndex);
    }
    
    background(10, 15, 30);
    
    // Caja de texto narrativa
    fill(0, 0, 0, 220);
    stroke(255);
    strokeWeight(2);
    rect(60, height - 180, width - 120, 120, 10);
    
    fill(255);
    textSize(18);
    textAlign(LEFT, TOP);
    text(currentText, 80, height - 160, width - 160, 90);
    
    fill(150);
    textSize(13);
    textAlign(RIGHT, BOTTOM);
    text("[ESPACIO] Avanzar | [ENTER] Saltar al menú", width - 80, height - 20);
  }
  
  void loadSceneText(int sceneNum) {
    timer = 0;
    charIndex = 0;
    currentText = "";
    
    if (sceneNum == 1) {
      fullText = "El patio de la escuela solía ser un lugar de encuentro... Pero en las sombras de la red, algo comenzó a cambiar.";
    } else if (sceneNum == 2) {
      fullText = "Los susurros se convirtieron en rumores. Mensajes hostiles de 'El Matón' y 'La Intriga' invadieron las pantallas.";
    } else if (sceneNum == 3) {
      fullText = "Detrás del caos se alza 'El Administrador', alimentando la tormenta digital de ciberacoso.";
    } else if (sceneNum == 4) {
      fullText = "Para salvar la convivencia escolar, deberás esquivar el odio y bloquear la toxicidad.";
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
          gameState = STATE_MENU;
        } else {
          loadSceneText(scene);
        }
      }
    }
    if (keyCode == ENTER) {
      gameState = STATE_MENU;
    }
  }
}
