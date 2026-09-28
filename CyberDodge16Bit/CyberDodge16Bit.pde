// ==========================================
// PROYECTO: CyberDodge 16-Bit
// EQUIPO N.º 1: Juan Ayala, Daniel Balaguera, Camilo Campos
// ==========================================

// ESTADOS DEL JUEGO
final int STATE_CINEMATIC     = 0;
final int STATE_MENU          = 1;
final int STATE_INSTRUCTIONS  = 2;
final int STATE_GAME          = 3;
final int STATE_GAME_OVER     = 4;
final int STATE_VICTORY       = 5;

int gameState = STATE_CINEMATIC;

// OBJETOS Y ARREGLOS
Avatar player;
Message[] activeMessages = new Message[20]; // Arreglo unidimensional
Cinematic introCinematic;

int score = 0;
int consecutiveNegatives = 0;

void setup() {
  fullScreen(); // Pantalla completa adaptable al monitor del usuario
  
  player = new Avatar(width / 2, height - 100);
  introCinematic = new Cinematic();
}

void draw() {
  background(20);
  
  switch(gameState) {
    case STATE_CINEMATIC:
      introCinematic.updateAndDraw();
      break;
    case STATE_MENU:
      drawMenu();
      break;
    case STATE_INSTRUCTIONS:
      drawInstructions();
      break;
    case STATE_GAME:
      updateAndDrawGame();
      break;
    case STATE_GAME_OVER:
      drawGameOver();
      break;
    case STATE_VICTORY:
      drawVictory();
      break;
  }
}

void updateAndDrawGame() {
  background(40, 50, 60); // Escenario del patio de recreo
  
  // Dibujar y actualizar jugador
  player.update();
  player.draw();
  
  // Generador de mensajes
  if (frameCount % 90 == 0) {
    spawnMessage();
  }
  
  // Recorrer el arreglo unidimensional de mensajes
  for (int i = 0; i < activeMessages.length; i++) {
    if (activeMessages[i] != null) {
      activeMessages[i].move();
      activeMessages[i].draw();
      
      // Colisión con el avatar
      if (activeMessages[i].checkCollision(player)) {
        if (activeMessages[i].type == 0) { // Negativo
          player.wellbeing -= 15;
          consecutiveNegatives++;
        } else if (activeMessages[i].type == 1) { // Positivo
          player.wellbeing = min(100, player.wellbeing + 10);
          score += 100;
          consecutiveNegatives = 0;
        }
        activeMessages[i] = null;
      } else if (activeMessages[i].y > height) {
        activeMessages[i] = null;
      }
    }
  }
  
  // Interfaz de Usuario (HUD)
  fill(255);
  textSize(18);
  textAlign(LEFT, TOP);
  text("Bienestar: " + player.wellbeing + "%", 30, 30);
  text("Puntos: " + score, 30, 60);
  
  if (consecutiveNegatives >= 3) {
    fill(255, 50, 50);
    text("¡SISTEMA DE REPORTE LISTO! Presiona [R]", 30, 90);
  }
  
  if (player.wellbeing <= 0) {
    gameState = STATE_GAME_OVER;
  }
}

void spawnMessage() {
  for (int i = 0; i < activeMessages.length; i++) {
    if (activeMessages[i] == null) {
      int randomType = int(random(0, 3)); // 0: Negativo, 1: Positivo, 2: Neutral
      activeMessages[i] = new Message(random(100, width - 100), 0, randomType);
      break;
    }
  }
}

void drawMenu() {
  background(30, 30, 50);
  textAlign(CENTER, CENTER);
  fill(255, 200, 0);
  textSize(42);
  text("CYBERDODGE 16-BIT", width / 2, height / 3);
  textSize(22);
  fill(200);
  text("Bloqueando el Ciberacoso", width / 2, height / 3 + 50);
  
  fill(255);
  textSize(20);
  text("Presiona [1] para JUGAR", width / 2, height / 2 + 50);
  text("Presiona [2] para INSTRUCCIONES", width / 2, height / 2 + 100);
}

void drawInstructions() {
  background(20, 40, 40);
  textAlign(CENTER, CENTER);
  fill(255);
  textSize(32);
  text("CÓMO JUGAR", width / 2, 100);
  
  textSize(18);
  textAlign(LEFT, TOP);
  text("- WASD / Flechas: Mover al estudiante\n" +
       "- [C] Capturar mensajes positivos\n" +
       "- [B] Bloquear mensajes\n" +
       "- [R] Reportar (Limpia la pantalla tras 3 mensajes negativos seguidos)\n" +
       "- [P] Pausar", width / 3, 200);
       
  textAlign(CENTER, CENTER);
  fill(255, 200, 0);
  text("Presiona [M] para volver al Menú", width / 2, height - 100);
}

void drawGameOver() {
  background(50, 10, 10);
  textAlign(CENTER, CENTER);
  fill(255, 50, 50);
  textSize(36);
  text("GAME OVER", width / 2, height / 3);
  fill(255);
  textSize(18);
  text("El ciberacoso agotó tu bienestar emocional.\nRecuerda pedir ayuda a tus profesores o familia.", width / 2, height / 2);
  text("Presiona [R] para reiniciar", width / 2, height - 150);
}

void drawVictory() {
  background(10, 50, 20);
  textAlign(CENTER, CENTER);
  fill(100, 255, 100);
  textSize(36);
  text("¡VICTORIA EN LA RED!", width / 2, height / 3);
  
  fill(255);
  textSize(18);
  text("\"El entorno digital lo construimos entre todos.\nEnfrentar el ciberacoso no significa luchar solo:\nreportar a tiempo y apoyar a otros transforma las redes.\"", width / 2, height / 2);
}

void keyPressed() {
  if (gameState == STATE_CINEMATIC) {
    introCinematic.handleKeyPress();
  } else if (gameState == STATE_MENU) {
    if (key == '1') gameState = STATE_GAME;
    if (key == '2') gameState = STATE_INSTRUCTIONS;
  } else if (gameState == STATE_INSTRUCTIONS) {
    if (key == 'm' || key == 'M') gameState = STATE_MENU;
  } else if (gameState == STATE_GAME) {
    if ((key == 'r' || key == 'R') && consecutiveNegatives >= 3) {
      for (int i = 0; i < activeMessages.length; i++) {
        if (activeMessages[i] != null && activeMessages[i].type == 0) {
          activeMessages[i] = null;
        }
      }
      score += 300;
      consecutiveNegatives = 0;
    }
  } else if (gameState == STATE_GAME_OVER) {
    if (key == 'r' || key == 'R') {
      player.wellbeing = 100;
      score = 0;
      consecutiveNegatives = 0;
      gameState = STATE_GAME;
    }
  }
}
