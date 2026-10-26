// ==========================================================================
// CYBERDODGE 16-BIT: Bloqueando el ciberacoso
// Laboratorio de Algoritmia y Programación II · Segundo semestre 2026
// Equipo N.º 1: Juan Ayala, Daniel Balaguera, Camilo Campos
//
// ARCHIVO PRINCIPAL (punto de entrada)
// En Processing este archivo debe llamarse igual que la carpeta del sketch.
// Su único trabajo es crear el objeto Game (la clase "sistema" del enunciado)
// y reenviarle draw(), el teclado y el mouse. Toda la lógica vive en las demás
// pestañas:
//   Game.pde       -> estados, puntaje, generación de mensajes, HUD, pantallas
//   Avatar.pde     -> el estudiante (posición, bienestar, movimiento, dibujo)
//   Message.pde    -> mensajes flotantes (tipo, texto, posición, velocidad...)
//   Maton.pde      -> el acosador (jefe)
//   Bala.pde       -> el "bloqueo" que lanza el jugador con la tecla B
//   Cinematic.pde  -> cinemática inicial
//
// MODO: pantalla completa (fullScreen). ESC pausa; en el menú, ESC sale.
// CONTROLES: WASD/flechas mover · Q esquivar · B bloquear · C capturar
//            R reportar · P (o ESC) pausa
// ==========================================================================

// ---------- Estados del juego (única fuente de verdad) ----------
final int STATE_CINEMATIC   = 0;
final int STATE_MENU        = 1;
final int STATE_INSTRUCTIONS = 2;
final int STATE_CREDITS     = 3;
final int STATE_PLAYING     = 4;
final int STATE_GAME_OVER   = 5;
final int STATE_VICTORY     = 6;

// ---------- Resolución lógica ----------
// El juego se diseñó para 960x540. En pantalla completa se escala (manteniendo
// la proporción 16:9 y con barras negras si hace falta), así que TODA la lógica
// usa GW/GH en lugar de width/height.
final int GW = 960;
final int GH = 540;
float escala = 1, offX = 0, offY = 0;

// ---------- Geometría compartida por Avatar, Maton y Bala ----------
final float ESCALA_SPRITE    = 0.26f;  // escala de los sprites en pantalla
final float CHAR_ALTO        = 80;     // altura visual del personaje (px)
final float CHAR_ANCHO_CENTRO = 27;    // mitad del ancho visual (px)
final float PIE_ANCHO        = 24;     // caja de colisión de los pies
final float PIE_ALTO         = 8;

Game juego;   // objeto principal del videojuego

void setup() {
  fullScreen();
  noSmooth();
  frameRate(60);
  juego = new Game();
  juego.cargarRecursos();
}

void draw() {
  escala = min(width / (float) GW, height / (float) GH);
  offX = (width - GW * escala) / 2;
  offY = (height - GH * escala) / 2;

  juego.actualizar();
  background(0);
  pushMatrix();
  translate(offX, offY);
  scale(escala);
  juego.dibujar();
  popMatrix();

  // barras negras (por si algo se dibuja fuera del área de juego)
  noStroke();
  fill(0);
  if (offX > 0) {
    rect(0, 0, offX, height);
    rect(width - offX, 0, offX, height);
  }
  if (offY > 0) {
    rect(0, 0, width, offY);
    rect(0, height - offY, width, offY);
  }
}

// Posición del mouse convertida a coordenadas del juego (960x540)
float mx() { return (mouseX - offX) / escala; }
float my() { return (mouseY - offY) / escala; }

void keyPressed() {
  boolean esc = (key == ESC);
  if (esc) key = 0;            // evita que ESC cierre el programa
  juego.teclaPresionada(esc);
}

void keyReleased() {
  juego.teclaSoltada();
}

void mousePressed() {
  juego.clic();
}

// Enter puede llegar como '\n' o '\r' según el sistema operativo
boolean esEnter() {
  return key == ENTER || key == RETURN;
}
