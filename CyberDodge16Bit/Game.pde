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

// ESTADO INICIAL: CINEMÁTICA
int gameState = STATE_CINEMATIC;
Cinematic cinematicaJuego;

// ==========================================================================
// VARIABLES DE RECURSOS GRÁFICOS
// ==========================================================================
PImage pantallaMenu, pantallaInstrucciones, escenarioJuego;
PImage sheetEstudiante, sheetMaton;

// Sprites Estudiante
PImage idleSprite, disparoSprite;
PImage[] framesCaminar = new PImage[4];
PImage[] framesRoll = new PImage[3];

// Sprites Matón
PImage[] matonIdle = new PImage[3];
PImage[] matonCaminar = new PImage[7];
PImage[] matonAtaque = new PImage[8];
PImage[] matonHit = new PImage[4];

float escalaSprite = 0.26;

// ==========================================================================
// CONTROL DEL JUEGO Y UI
// ==========================================================================
int estadoActual = 3;
int estadoSiguiente = 0;
float vidaMax = 100;
float vidaActual = 100;
int temporizadorRonda = 0;
int duracionRondaTexto = 120;
boolean enTransicion = false;
float alphaTransicion = 0;
float velocidadTransicion = 10;
boolean cambiandoDeEstado = false;

// ==========================================================================
// VARIABLES DEL JUGADOR
// ==========================================================================
float posX = 400, posY = 400;
float velocidad = 2.5;
boolean moviendoUp = false, moviendoDown = false, moviendoLeft = false, moviendoRight = false;
int frameActual = 0, velocidadAnimacion = 10, contadorAnimacion = 0;
boolean mirandoIzquierda = false;

// Dodge Roll
boolean rodando = false;
float rollVelocidad = 5.5;
int rollDuracion = 22, rollEspera = 25, rollTick = 0, rollCooldown = 0;
float rollDirX = 0, rollDirY = 0;
boolean qMantenida = false;

// Disparos
ArrayList<Bala> balas = new ArrayList<Bala>();
boolean disparando = false;
float balaVelocidad = 11.0;
int cadenciaDisparo = 15, cooldownDisparo = 0, duracionPose = 12, tiempoPoseDisparo = 0;

// Geometría del jugador
float charAlturaVisual = 80, charAnchoCentro = 27;
float pieAncho = 24, pieAlto = 8;

// ==========================================================================
// VARIABLES DEL MATÓN (ENEMIGO)
// ==========================================================================
Maton enemigoMaton;

// ==========================================================================
// COLISIONES Y ESCENARIO
// ==========================================================================
float REF_W = 655, REF_H = 287;
float[][] obstaculosRef = {
  {0, 0, 140, 178}, {140, 0, 308, 150}, {448, 0, 207, 183},
  {283, 118, 102, 54}, {248, 148, 36, 12}, {385, 170, 24, 14},
  {412, 166, 14, 16}, {144, 162, 40, 20}, {0, 205, 38, 20},
  {40, 207, 14, 18}, {72, 208, 20, 18}, {232, 213, 18, 20},
  {430, 203, 16, 18}, {586, 205, 42, 20}, {642, 210, 13, 20},
  {10, 238, 24, 20}, {0, 258, 8, 24}, {372, 222, 40, 20},
  {346, 236, 20, 16}, {346, 270, 20, 17}, {440, 225, 20, 18},
  {446, 236, 20, 18}, {630, 242, 25, 45}
};
float[][] obstaculosPx;
boolean mostrarColisiones = false;

// ==========================================================================
// SETUP Y PREPARACIÓN
// ==========================================================================
void setup() {
  size(960, 540);
  noSmooth();

  pantallaMenu = loadImage("pantalladeinicio.png");
  pantallaInstrucciones = loadImage("instrucciones.png");
  escenarioJuego = loadImage("escenario.png");

  // Cargar Estudiante
  sheetEstudiante = loadImage("el estudiante.png");
  if (sheetEstudiante != null) limpiarFondoBlanco(sheetEstudiante);
  prepararSpritesEstudiante();

  // Cargar Matón (Asegúrate de usar el archivo separado que creaste)
  sheetMaton = loadImage("el_maton_separado.png");
  if (sheetMaton != null) limpiarFondoBlanco(sheetMaton);
  prepararSpritesMaton();

  prepararColisiones();

  // Inicializar enemigo
  enemigoMaton = new Maton(150, 300);
  cinematicaJuego = new Cinematic();
}

void limpiarFondoBlanco(PImage img) {
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    color c = img.pixels[i];
    if (red(c) > 160 && green(c) > 160 && blue(c) > 160) {
      img.pixels[i] = color(255, 255, 255, 0);
    }
  }
  img.updatePixels();
}

void prepararColisiones() {
  float ex = width / REF_W;
  float ey = height / REF_H;
  obstaculosPx = new float[obstaculosRef.length][4];
  for (int i = 0; i < obstaculosRef.length; i++) {
    obstaculosPx[i][0] = obstaculosRef[i][0] * ex;
    obstaculosPx[i][1] = obstaculosRef[i][1] * ey;
    obstaculosPx[i][2] = obstaculosRef[i][2] * ex;
    obstaculosPx[i][3] = obstaculosRef[i][3] * ey;
  }
}

boolean colisiona(float px, float py) {
  float izq = px + charAnchoCentro - pieAncho / 2;
  float der = izq + pieAncho;
  float aba = py + charAlturaVisual;
  float arr = aba - pieAlto;
  if (izq < 0 || der > width || arr < 0 || aba > height) return true;
  for (float[] o : obstaculosPx) {
    if (der > o[0] && izq < o[0] + o[2] && aba > o[1] && arr < o[1] + o[3]) return true;
  }
  return false;
}

// ==========================================================================
// PREPARACIÓN DE SPRITES
// ==========================================================================
void prepararSpritesEstudiante() {
  idleSprite = recortarAjustado(sheetEstudiante, 40, 30, 230, 330);
  int[][] regCam = {{500, 30, 210, 330}, {710, 30, 200, 330}, {910, 30, 210, 330}, {1120, 30, 220, 330}};
  for (int i=0; i<4; i++) framesCaminar[i] = recortarAjustado(sheetEstudiante, regCam[i][0], regCam[i][1], regCam[i][2], regCam[i][3]);
  int[][] regRol = {{220, 480, 210, 230}, {430, 480, 200, 230}, {635, 480, 200, 230}};
  for (int i=0; i<3; i++) framesRoll[i] = recortarAjustado(sheetEstudiante, regRol[i][0], regRol[i][1], regRol[i][2], regRol[i][3]);
  disparoSprite = recortarAjustado(sheetEstudiante, 1090, 430, 230, 280);
}

// VERSIÓN ACTUALIZADA PARA EL ARCHIVO DE 400x400
void prepararSpritesMaton() {
  if (sheetMaton == null) return;

  // Usamos las dimensiones fijas del archivo que exportaste
  int anchoCelda = 400;
  int altoCelda = 400;

  // Reinicializar arreglos
  matonIdle = new PImage[3];
  matonCaminar = new PImage[7];
  matonAtaque = new PImage[8];
  matonHit = new PImage[4];

  // Usamos get directo sin recortarAjustado para mantener el centrado perfecto
  for (int i = 0; i < 3; i++) matonIdle[i] = sheetMaton.get(i * anchoCelda, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 7; i++) matonCaminar[i] = sheetMaton.get(i * anchoCelda, altoCelda, anchoCelda, altoCelda);
  for (int i = 0; i < 8; i++) matonAtaque[i] = sheetMaton.get(i * anchoCelda, altoCelda * 2, anchoCelda, altoCelda);
  for (int i = 0; i < 4; i++) matonHit[i] = sheetMaton.get(i * anchoCelda, altoCelda * 3, anchoCelda, altoCelda);
}

PImage recortarAjustado(PImage img, int x, int y, int w, int h) {
  if (img == null || x >= img.width || y >= img.height) return null;
  w = min(w, img.width - x);
  h = min(h, img.height - y);
  PImage region = img.get(x, y, w, h);
  region.loadPixels();
  int minX = w, minY = h, maxX = -1, maxY = -1;
  for (int j = 0; j < h; j++) {
    for (int i = 0; i < w; i++) {
      if (alpha(region.pixels[j * w + i]) > 0) {
        minX = min(minX, i);
        maxX = max(maxX, i);
        minY = min(minY, j);
        maxY = max(maxY, j);
      }
    }
  }
  if (maxX < 0) return region;
  return region.get(minX, minY, maxX - minX + 1, maxY - minY + 1);
}

// ==========================================================================
// CLASE DEL ENEMIGO (EL MATÓN) - ACTUALIZADA PARA FLUIDEZ
// ==========================================================================
class Maton {
  float x, y;
  float vel = 0.85;
  int hp = 500;
  int maxHp = 500;

  int estado = 0;
  float destX, destY;
  int timerEstado = 0;
  int cooldownAtaque = 0;

  int frameActual = 0;
  int contadorAnim = 0;
  boolean mirandoIzquierda = false;
  boolean vivo = true;

  // NUEVO: Variable para saber si realmente se está desplazando
  boolean enMovimiento = false;

  Maton(float startX, float startY) {
    this.x = startX;
    this.y = startY;
    elegirNuevoDestino();
    timerEstado = int(random(180, 300));
  }

  void actualizar() {
    if (!vivo) return;

    if (cooldownAtaque > 0) cooldownAtaque--;

    // Si está recibiendo daño
    if (estado == 3) {
      enMovimiento = false; // Se detiene al recibir daño
      if (timerEstado > 0) timerEstado--;
      else {
        estado = 1;
        timerEstado = 0;
      }
      animar();
      return;
    }

    // Si está atacando (empujando)
    if (estado == 2) {
      enMovimiento = false; // Se detiene para atacar
      if (timerEstado > 0) {
        timerEstado--;
        if (timerEstado == 0) {
          if (dist(x, y, posX, posY) < 70) vidaActual -= 20;
          estado = 1;
          cooldownAtaque = 90;
        }
      }
      animar();
      return;
    }

    float distAlJugador = dist(x, y, posX, posY);

    if (estado == 0) {
      moverHacia(destX, destY);
      if (dist(x, y, destX, destY) < 10) elegirNuevoDestino();

      timerEstado--;
      if (timerEstado <= 0) estado = 1;
    } else if (estado == 1) {
      moverHacia(posX, posY);
      if (distAlJugador < 55 && cooldownAtaque == 0) {
        estado = 2;
        timerEstado = 8 * 8;
        frameActual = 0;
      }
    }

    animar();
  }

  void elegirNuevoDestino() {
    destX = random(50, width - 50);
    destY = random(50, height - 50);
  }

  void moverHacia(float objetivoX, float objetivoY) {
    float dx = objetivoX - x;
    float dy = objetivoY - y;
    float d = sqrt(dx*dx + dy*dy);

    if (d > 0) {
      dx = (dx / d) * vel;
      dy = (dy / d) * vel;

      if (dx < 0) mirandoIzquierda = true;
      else if (dx > 0) mirandoIzquierda = false;

      boolean seMovio = false;

      if (!colisiona(x + dx, y + dy)) {
        x += dx;
        y += dy;
        seMovio = true;
      } else if (!colisiona(x + dx, y)) {
        x += dx;
        seMovio = true;
      } else if (!colisiona(x, y + dy)) {
        y += dy;
        seMovio = true;
      } else {
        if (estado == 0) elegirNuevoDestino();
      }

      enMovimiento = seMovio; // Actualiza el estado de movimiento real
    } else {
      enMovimiento = false;
    }
  }

  void recibirDano(int cantidad) {
    hp -= cantidad;
    if (hp <= 0) {
      vivo = false;
    } else {
      estado = 3;
      timerEstado = 20;
      frameActual = 0;
    }
  }

  void animar() {
    contadorAnim++;
    if (contadorAnim >= 8) {
      contadorAnim = 0;
      if (estado == 3) frameActual = min(frameActual + 1, matonHit.length - 1);
      else if (estado == 2) frameActual = min(frameActual + 1, matonAtaque.length - 1);
      else if (estado == 1 || estado == 0) {
        // SOLUCIÓN: Separa la animación según si está quieto o moviéndose
        if (enMovimiento) frameActual = (frameActual + 1) % matonCaminar.length;
        else frameActual = (frameActual + 1) % matonIdle.length;
      }
    }
  }

  void dibujar() {
    if (!vivo) return;

    PImage spriteActual = matonIdle[0];
    if (spriteActual == null) return;

    // Selecciona el fotograma correcto para dibujar
    if (estado == 3) spriteActual = matonHit[min(frameActual, matonHit.length - 1)];
    else if (estado == 2) spriteActual = matonAtaque[min(frameActual, matonAtaque.length - 1)];
    else if (estado == 1 || estado == 0) {
      if (enMovimiento) spriteActual = matonCaminar[frameActual % matonCaminar.length];
      else spriteActual = matonIdle[frameActual % matonIdle.length];
    }

    float w = spriteActual.width * escalaSprite;
    float h = spriteActual.height * escalaSprite;

    pushMatrix();
    translate(x + charAnchoCentro, y + charAlturaVisual - h);
    if (mirandoIzquierda) scale(-1, 1);
    image(spriteActual, -w / 2, 0, w, h);
    popMatrix();

    float anchoMiniBarra = 40;
    float barraX = x + charAnchoCentro - (anchoMiniBarra / 2);
    float barraY = y + charAlturaVisual - h - 15;

    noStroke();
    fill(255, 0, 0);
    rect(barraX, barraY, anchoMiniBarra, 5);
    fill(0, 255, 0);
    rect(barraX, barraY, map(hp, 0, maxHp, 0, anchoMiniBarra), 5);
  }
}

// ==========================================================================
// CLASE BALA
// ==========================================================================
class Bala {
  float x, yDibujo, ySuelo, vx;
  boolean viva = true;

  Bala(float x, float yDibujo, float ySuelo, float vx) {
    this.x = x;
    this.yDibujo = yDibujo;
    this.ySuelo = ySuelo;
    this.vx = vx;
  }

  void actualizar() {
    x += vx;
    if (x < 0 || x > width) {
      viva = false;
      return;
    }

    float yChoque = ySuelo - 6;
    for (float[] o : obstaculosPx) {
      if (x > o[0] && x < o[0] + o[2] && yChoque > o[1] && yChoque < o[1] + o[3]) {
        viva = false;
        return;
      }
    }

    if (enemigoMaton != null && enemigoMaton.vivo && enemigoMaton.estado != 3) {
      float matonCentroY = enemigoMaton.y + charAlturaVisual - 30;
      float matonCentroX = enemigoMaton.x + charAnchoCentro;

      float distAlMaton = dist(x, yDibujo, matonCentroX, matonCentroY);

      if (distAlMaton < 45) {
        enemigoMaton.recibirDano(20);
        viva = false;
      }
    }
  }

  void dibujar() {
    noStroke();
    fill(30, 20, 40);
    rect(x - 9, yDibujo - 5, 18, 10);
    fill(255, 220, 60);
    rect(x - 7, yDibujo - 3, 14, 6);
    fill(255, 255, 200);
    rect(x - 4, yDibujo - 1, 8, 2);
  }
}

// ==========================================================================
// BUCLE PRINCIPAL (DRAW)
// ==========================================================================
void draw() {
  background(0);

  // 1. EVALUAR PRIMERO EL ESTADO DE LA CINEMÁTICA
  if (estadoActual == 3) {
    if (cinematicaJuego != null) {
      cinematicaJuego.updateAndDraw(); // Dibuja la cinemática
    }
  }
  // 2. TUS ESTADOS ORIGINALES PERMANECEN EXACTAMENTE IGUALES
  else if (estadoActual == 0) image(pantallaMenu, 0, 0, width, height);
  else if (estadoActual == 1) image(pantallaInstrucciones, 0, 0, width, height);
  else if (estadoActual == 2) {
    image(escenarioJuego, 0, 0, width, height);

    if (temporizadorRonda < duracionRondaTexto) {
      temporizadorRonda++;
      noStroke();
      fill(0, 150);
      rect(0, 0, width, height);
      textAlign(CENTER, CENTER);
      fill(255, 220, 60);
      textSize(64);
      text("RONDA 1", width / 2, height / 2);
      fill(255);
      textSize(20);
      text("¡Prepárate!", width / 2, height / 2 + 60);
      textAlign(LEFT, BASELINE);
    } else {
      if (rollCooldown > 0) rollCooldown--;
      if (cooldownDisparo > 0) cooldownDisparo--;
      if (tiempoPoseDisparo > 0) tiempoPoseDisparo--;

      boolean enMovimiento = false;

      if (rodando) {
        actualizarRoll();
        enMovimiento = true;
      } else {
        float dx = 0, dy = 0;
        if (moviendoUp) dy -= velocidad;
        if (moviendoDown) dy += velocidad;
        if (moviendoLeft) dx -= velocidad;
        if (moviendoRight) dx += velocidad;

        if (dx < 0) mirandoIzquierda = true;
        else if (dx > 0) mirandoIzquierda = false;

        if (dx != 0 && !colisiona(posX + dx, posY)) {
          posX += dx;
          enMovimiento = true;
        }
        if (dy != 0 && !colisiona(posX, posY + dy)) {
          posY += dy;
          enMovimiento = true;
        }
      }

      if (disparando && !rodando && cooldownDisparo == 0) disparar();

      if (enemigoMaton != null) {
        enemigoMaton.actualizar();
        enemigoMaton.dibujar();
      }

      dibujarEstudiante(enMovimiento);
      actualizarYDibujarBalas();
      dibujarBarraVida();

      if (mostrarColisiones) dibujarColisiones();
    }
  }

  if (enTransicion) actualizarTransicion();
}
// ==========================================================================
// MÉTODOS DE ACCIÓN Y SISTEMA
// ==========================================================================
void disparar() {
  float dir = mirandoIzquierda ? -1 : 1;
  float bx = posX + charAnchoCentro + dir * 24;
  float by = posY + charAlturaVisual - 40;
  float sueloY = posY + charAlturaVisual;
  balas.add(new Bala(bx, by, sueloY, dir * balaVelocidad));
  cooldownDisparo = cadenciaDisparo;
  tiempoPoseDisparo = duracionPose;
}

void actualizarYDibujarBalas() {
  for (int i = balas.size() - 1; i >= 0; i--) {
    Bala b = balas.get(i);
    b.actualizar();
    if (!b.viva) balas.remove(i);
    else b.dibujar();
  }
}

void dibujarBarraVida() {
  float x = 30, y = 30, barraAncho = 220, barraAlto = 22;
  stroke(0);
  strokeWeight(3);
  fill(40, 40, 40);
  rect(x, y, barraAncho, barraAlto, 4);
  noStroke();
  if (vidaActual > 30) fill(46, 204, 113);
  else fill(231, 76, 60);
  float anchoRelleno = constrain((vidaActual / vidaMax) * (barraAncho - 6), 0, barraAncho - 6);
  rect(x + 3, y + 3, anchoRelleno, barraAlto - 6, 2);
  fill(255);
  textSize(12);
  text("HP: " + max(0, int(vidaActual)) + " / " + int(vidaMax), x + 12, y + 16);
}

void dibujarColisiones() {
  noStroke();
  fill(255, 0, 0, 90);
  for (float[] o : obstaculosPx) rect(o[0], o[1], o[2], o[3]);
  fill(0, 255, 0, 160);
  rect(posX + charAnchoCentro - pieAncho / 2, posY + charAlturaVisual - pieAlto, pieAncho, pieAlto);
}

void dibujarEstudiante(boolean caminando) {
  if (idleSprite == null) return;
  PImage sprite = idleSprite;
  if (rodando) sprite = framesRoll[(rollTick / 3) % framesRoll.length];
  else if (tiempoPoseDisparo > 0) sprite = disparoSprite;
  else if (caminando) {
    contadorAnimacion++;
    if (contadorAnimacion >= velocidadAnimacion) {
      frameActual = (frameActual + 1) % framesCaminar.length;
      contadorAnimacion = 0;
    }
    sprite = framesCaminar[frameActual];
  }
  float w = sprite.width * escalaSprite, h = sprite.height * escalaSprite;
  pushMatrix();
  translate(posX + charAnchoCentro, posY + charAlturaVisual - h);
  if (mirandoIzquierda && sprite != idleSprite) scale(-1, 1);
  image(sprite, -w / 2, 0, w, h);
  popMatrix();
}

void iniciarRoll() {
  if (rodando || rollCooldown > 0 || estadoActual != 2 || enTransicion) return;
  float dx = 0, dy = 0;
  if (moviendoUp) dy -= 1;
  if (moviendoDown) dy += 1;
  if (moviendoLeft) dx -= 1;
  if (moviendoRight) dx += 1;
  if (dx == 0 && dy == 0) dx = mirandoIzquierda ? -1 : 1;
  float m = sqrt(dx * dx + dy * dy);
  rollDirX = dx / m;
  rollDirY = dy / m;
  mirandoIzquierda = (rollDirX < 0);
  rodando = true;
  rollTick = 0;
}

void actualizarRoll() {
  float dx = rollDirX * rollVelocidad, dy = rollDirY * rollVelocidad;
  if (dx != 0 && !colisiona(posX + dx, posY)) posX += dx;
  if (dy != 0 && !colisiona(posX, posY + dy)) posY += dy;
  rollTick++;
  if (rollTick >= rollDuracion) {
    rodando = false;
    rollCooldown = rollEspera;
  }
}

void actualizarTransicion() {
  noStroke();
  fill(0, alphaTransicion);
  rect(0, 0, width, height);
  if (!cambiandoDeEstado) {
    alphaTransicion += velocidadTransicion;
    if (alphaTransicion >= 255) {
      alphaTransicion = 255;
      estadoActual = estadoSiguiente;
      cambiandoDeEstado = true;
    }
  } else {
    alphaTransicion -= velocidadTransicion;
    if (alphaTransicion <= 0) {
      alphaTransicion = 0;
      enTransicion = false;
      cambiandoDeEstado = false;
    }
  }
}

void cambiarPantalla(int nuevoEstado) {
  if (!enTransicion) {
    estadoSiguiente = nuevoEstado;
    enTransicion = true;
    cambiandoDeEstado = false;
    alphaTransicion = 0;
    if (nuevoEstado == 2) temporizadorRonda = 0;
  }
}

// ==========================================================================
// CONTROLES
// ==========================================================================
void mousePressed() {
  if (enTransicion) return;
  if (estadoActual == 0) {
    if (mouseX >= 366 && mouseX <= 561 && mouseY >= 169 && mouseY <= 218) cambiarPantalla(2);
    else if (mouseX >= 366 && mouseX <= 561 && mouseY >= 234 && mouseY <= 282) cambiarPantalla(1);
    else if (mouseX >= 366 && mouseX <= 516 && mouseY >= 366 && mouseY <= 414) exit();
  } else if (estadoActual == 1) {
    if (mouseX >= 405 && mouseX <= 555 && mouseY >= 450 && mouseY <= 505) cambiarPantalla(0);
  }
}

void keyPressed() {
  if (estadoActual == 3) {
    cinematicaJuego.handleKeyPress();
    return;
  }
  if (estadoActual == 2 && temporizadorRonda < duracionRondaTexto) return;
  if (key == 'w' || key == 'W') moviendoUp = true;
  if (key == 's' || key == 'S') moviendoDown = true;
  if (key == 'a' || key == 'A') moviendoLeft = true;
  if (key == 'd' || key == 'D') moviendoRight = true;
  if (key == 'h' || key == 'H') mostrarColisiones = !mostrarColisiones;
  if ((key == 'q' || key == 'Q') && !qMantenida) {
    qMantenida = true;
    iniciarRoll();
  }
  if (key == 'p' || key == 'P') disparando = true;
}

void keyReleased() {
  if (key == 'w' || key == 'W') moviendoUp = false;
  if (key == 's' || key == 'S') moviendoDown = false;
  if (key == 'a' || key == 'A') moviendoLeft = false;
  if (key == 'd' || key == 'D') moviendoRight = false;
  if (key == 'q' || key == 'Q') qMantenida = false;
  if (key == 'p' || key == 'P') disparando = false;
}
