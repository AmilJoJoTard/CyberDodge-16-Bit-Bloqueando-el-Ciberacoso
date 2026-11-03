// ==========================================
// PROYECTO: CyberDodge 16-Bit - PESTAÑA PRINCIPAL
// ==========================================

final int STATE_CINEMATIC      = 0;
final int STATE_MENU           = 1;
final int STATE_INSTRUCTIONS   = 2;
final int STATE_GAME           = 3;
final int STATE_GAME_OVER      = 4;
final int STATE_VICTORY        = 5;
final int STATE_BOSS_CINEMATIC = 6;
final int STATE_ENDING_CINEMATIC = 7;
final int STATE_CREDITS        = 8; // NUEVO ESTADO PARA CRÉDITOS

int estadoActual = STATE_CINEMATIC; 
int estadoSiguiente = STATE_CINEMATIC;

float vidaMax = 100;
float vidaActual = 100;
int temporizadorRonda = 0;
int duracionRondaTexto = 120;
boolean enTransicion = false;
float alphaTransicion = 0;
float velocidadTransicion = 10;
boolean cambiandoDeEstado = false;

boolean juegoPausado = false; // VARIABLE PARA CONTROLAR LA PAUSA

PImage pantallaMenu, pantallaInstrucciones, escenarioJuego;
PImage sheetEstudiante, sheetMaton, sheetIntrigante, sheetGemelo, sheetJefe;

PImage idleSprite, disparoSprite;
PImage[] framesCaminar = new PImage[4];
PImage[] framesRoll = new PImage[3];

PImage[] matonIdle = new PImage[3];
PImage[] matonCaminar = new PImage[7];
PImage[] matonAtaque = new PImage[8];
PImage[] matonHit = new PImage[4];

PImage[] intriganteIdle = new PImage[3];
PImage[] intriganteCaminar = new PImage[7];
PImage[] intriganteAtaque = new PImage[8];
PImage[] intriganteHit = new PImage[4];

// Sprites del Gemelo de Datos
PImage[] gemeloIdle = new PImage[3];
PImage[] gemeloCaminar = new PImage[7];
PImage[] gemeloDisparar = new PImage[4];

// Sprites del Jefe Final
PImage[] jefeIdle = new PImage[3];
PImage[] jefeCaminar = new PImage[7];
PImage[] jefeAtaque = new PImage[8];
PImage[] jefeHit = new PImage[4];

float escalaSprite = 0.26;

PImage recortarAjustado(PImage img, int x, int y, int w, int h) {
  if (img == null || x >= img.width || y >= img.height) return null;
  w = min(w, img.width - x); h = min(h, img.height - y);
  PImage region = img.get(x, y, w, h);
  region.loadPixels();
  int minX = w, minY = h, maxX = -1, maxY = -1;
  for (int j = 0; j < h; j++) {
    for (int i = 0; i < w; i++) {
      if (alpha(region.pixels[j * w + i]) > 0) {
        minX = min(minX, i); maxX = max(maxX, i);
        minY = min(minY, j); maxY = max(maxY, j);
      }
    }
  }
  if (maxX < 0) return region;
  return region.get(minX, minY, maxX - minX + 1, maxY - minY + 1);
}

float posX = 150, posY = 270; 
float velocidad = 2.5;
boolean moviendoUp = false, moviendoDown = false, moviendoLeft = false, moviendoRight = false;
int frameActual = 0, velocidadAnimacion = 10, contadorAnimacion = 0;
boolean mirandoIzquierda = false;

boolean rodando = false;
float rollVelocidad = 5.5;
int rollDuracion = 22, rollEspera = 25, rollTick = 0, rollCooldown = 0;
float rollDirX = 0, rollDirY = 0;
boolean qMantenida = false;

ArrayList<Bala> balas = new ArrayList<Bala>();
ArrayList<Message> mensajesEnemigos = new ArrayList<Message>();
boolean disparando = false;
float balaVelocidad = 11.0;
int cadenciaDisparo = 15, cooldownDisparo = 0, duracionPose = 12, tiempoPoseDisparo = 0;

int municionMax = 10;
int municionActual = 10;
boolean recargando = false;
int timerRecarga = 0;
int tiempoRecargaMax = 60; 

boolean aturdido = false;
int timerAturdido = 0;
int tiempoAturdidoMax = 45; 

float charAlturaVisual = 80, charAnchoCentro = 27;
float pieAncho = 24, pieAlto = 8;

boolean tieneEscudo = false;
boolean modoFuegoRapido = false;
int timerFuegoRapido = 0;
boolean powerUpGeneradoBajoVida = false;

ArrayList<Maton> listaMatones = new ArrayList<Maton>();
ArrayList<Intrigante> listaIntrigantes = new ArrayList<Intrigante>();
ArrayList<GemeloDatos> listaGemelos = new ArrayList<GemeloDatos>();
ArrayList<PowerUp> listaPowerUps = new ArrayList<PowerUp>();
JefeFinal jefeFinal = null;

int rondaActual = 1;
int matonesSpawned = 0;
int intrigantesSpawned = 0;
int gemelosSpawned = 0;
int timerSpawn = 0; 

Cinematic cinematicaJuego;
Cinematic cinematicaBoss;
Cinematic cinematicaFinal; 

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

void setup() {
  size(960, 540); // Mantenido en tamaño de ventana sin fullScreen
  noSmooth();

  pantallaMenu = loadImage("pantalladeinicio.png");
  pantallaInstrucciones = loadImage("instrucciones.png");
  escenarioJuego = loadImage("escenario.png");

  sheetEstudiante = loadImage("el estudiante.png");
  if (sheetEstudiante != null) limpiarFondoBlanco(sheetEstudiante);
  prepararSpritesEstudiante();

  sheetMaton = loadImage("el_maton_separado.png");
  if (sheetMaton != null) limpiarFondoBlanco(sheetMaton);
  prepararSpritesMaton();
  
  sheetIntrigante = loadImage("La intrigante_sheet.png");
  if (sheetIntrigante != null) limpiarFondoBlanco(sheetIntrigante);
  prepararSpritesIntrigante();

  sheetGemelo = loadImage("gemelo_datos.png");
  if (sheetGemelo != null) {
    limpiarFondoBlanco(sheetGemelo);
    prepararSpritesGemelo();
  }

  sheetJefe = loadImage("sheet_jefe.png"); 
  if (sheetJefe != null) {
    limpiarFondoBlanco(sheetJefe);
    prepararSpritesJefe();
  }

  prepararColisiones();
  reiniciarJuego();
  
  cinematicaJuego = new Cinematic(0);
  cinematicaBoss = new Cinematic(1);
}

void reiniciarJuego() {
  vidaActual = vidaMax;
  municionActual = municionMax;
  posX = 150; 
  posY = 270;
  
  rondaActual = 1;
  matonesSpawned = 0;
  intrigantesSpawned = 0;
  gemelosSpawned = 0;
  timerSpawn = 0;
  temporizadorRonda = 0;
  
  tieneEscudo = false;
  modoFuegoRapido = false;
  powerUpGeneradoBajoVida = false;
  aturdido = false;
  recargando = false;
  juegoPausado = false; // Asegurar que inicie sin pausa
  
  listaMatones.clear();
  listaIntrigantes.clear();
  listaGemelos.clear();
  listaPowerUps.clear();
  balas.clear();
  mensajesEnemigos.clear();
  jefeFinal = null;

  listaMatones.add(new Maton(800, 350));
  matonesSpawned++;
  
  listaIntrigantes.add(new Intrigante(750, 420));
  intrigantesSpawned++;

  listaPowerUps.add(new PowerUp(250, 480, 0)); 
  listaPowerUps.add(new PowerUp(550, 500, 1)); 
  listaPowerUps.add(new PowerUp(750, 420, 0)); 
  listaPowerUps.add(new PowerUp(400, 320, 1)); 
}

void limpiarFondoBlanco(PImage img) {
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    color c = img.pixels[i];
    if (red(c) == 0 && green(c) == 0 && blue(c) == 0) {
      img.pixels[i] = color(0, 0, 0, 0); 
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

boolean posicionValida(float px, float py) {
  if (colisiona(px, py)) return false;
  if (py < 250 || py > 480) return false; 
  if (px < 150 || px > 850) return false;
  return true;
}

void prepararSpritesEstudiante() {
  idleSprite = recortarAjustado(sheetEstudiante, 40, 30, 230, 330);
  int[][] regCam = {{500, 30, 210, 330}, {710, 30, 200, 330}, {910, 30, 210, 330}, {1120, 30, 220, 330}};
  for (int i=0; i<4; i++) framesCaminar[i] = recortarAjustado(sheetEstudiante, regCam[i][0], regCam[i][1], regCam[i][2], regCam[i][3]);
  int[][] regRol = {{220, 480, 210, 230}, {430, 480, 200, 230}, {635, 480, 200, 230}};
  for (int i=0; i<3; i++) framesRoll[i] = recortarAjustado(sheetEstudiante, regRol[i][0], regRol[i][1], regRol[i][2], regRol[i][3]);
  disparoSprite = recortarAjustado(sheetEstudiante, 1090, 430, 230, 280);
}

void prepararSpritesMaton() {
  if (sheetMaton == null) return;
  int anchoCelda = 400; int altoCelda = 400;
  matonIdle = new PImage[3]; matonCaminar = new PImage[7];
  matonAtaque = new PImage[8]; matonHit = new PImage[4];
  for (int i = 0; i < 3; i++) matonIdle[i] = sheetMaton.get(i * anchoCelda, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 7; i++) matonCaminar[i] = sheetMaton.get(i * anchoCelda, altoCelda, anchoCelda, altoCelda);
  for (int i = 0; i < 8; i++) matonAtaque[i] = sheetMaton.get(i * anchoCelda, altoCelda * 2, anchoCelda, altoCelda);
  for (int i = 0; i < 4; i++) matonHit[i] = sheetMaton.get(i * anchoCelda, altoCelda * 3, anchoCelda, altoCelda);
}

void prepararSpritesIntrigante() {
  if (sheetIntrigante == null) return;
  int anchoCelda = 400; int altoCelda = 400;
  intriganteIdle = new PImage[3]; intriganteCaminar = new PImage[7];
  intriganteAtaque = new PImage[8]; intriganteHit = new PImage[4];
  for (int i = 0; i < 3; i++) intriganteIdle[i] = recortarAjustado(sheetIntrigante.get(i * anchoCelda, 0, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 7; i++) intriganteCaminar[i] = recortarAjustado(sheetIntrigante.get(i * anchoCelda, altoCelda, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 8; i++) intriganteAtaque[i] = recortarAjustado(sheetIntrigante.get(i * anchoCelda, altoCelda * 2, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 4; i++) intriganteHit[i] = recortarAjustado(sheetIntrigante.get(i * anchoCelda, altoCelda * 3, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
}

void prepararSpritesGemelo() {
  if (sheetGemelo == null) return;
  int anchoCelda = 400; int altoCelda = 400;
  gemeloIdle = new PImage[3]; gemeloCaminar = new PImage[7]; gemeloDisparar = new PImage[4];
  for (int i = 0; i < 3; i++) gemeloIdle[i] = recortarAjustado(sheetGemelo.get(i * anchoCelda, 0, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 7; i++) gemeloCaminar[i] = recortarAjustado(sheetGemelo.get(i * anchoCelda, altoCelda, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 4; i++) gemeloDisparar[i] = recortarAjustado(sheetGemelo.get(i * anchoCelda, altoCelda * 2, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
}

void prepararSpritesJefe() {
  if (sheetJefe == null) return;
  int anchoCelda = 400; int altoCelda = 400;
  jefeIdle = new PImage[3];
  jefeCaminar = new PImage[7];
  jefeAtaque = new PImage[8];
  jefeHit = new PImage[4];
  
  for (int i = 0; i < 3; i++) jefeIdle[i] = recortarAjustado(sheetJefe.get(i * anchoCelda, 0, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 7; i++) jefeCaminar[i] = recortarAjustado(sheetJefe.get(i * anchoCelda, altoCelda, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 8; i++) jefeAtaque[i] = recortarAjustado(sheetJefe.get(i * anchoCelda, altoCelda * 2, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
  for (int i = 0; i < 4; i++) jefeHit[i] = recortarAjustado(sheetJefe.get(i * anchoCelda, altoCelda * 3, anchoCelda, altoCelda), 0, 0, anchoCelda, altoCelda);
}

// ==========================================
// CLASE JEFE FINAL (MEJORADO)
// ==========================================
class JefeFinal {
  float x, y;
  float vel = 1.3;
  int hp = 2000, maxHp = 2000;
  int estado = 0; 
  int timerEstado = 0;
  int tipoAtaqueActual = 0;
  int cooldownAtaque = 70;
  int rafagaRestante = 0;
  int timerRafaga = 0;
  int frameActual = 0, contadorAnim = 0;
  boolean mirandoIzquierda = false, vivo = true, enMovimiento = false;
  float escalaJefe = 0.35;
  boolean enIra = false; 

  JefeFinal(float startX, float startY) {
    this.x = startX;
    this.y = startY;
  }

  void actualizar() {
    if (!vivo) return;
    if (cooldownAtaque > 0) cooldownAtaque--;

    if (hp <= maxHp / 2) enIra = true; 

    if (estado == 2) {
      enMovimiento = false;
      if (timerEstado > 0) timerEstado--;
      else estado = 0;
      animar();
      return;
    }

    float distAlJugador = dist(x, y, posX, posY);
    mirandoIzquierda = (posX < x);

    if (distAlJugador > 300) {
      moverHacia(posX, posY);
      enMovimiento = true;
    } else if (distAlJugador < 180) {
      float anguloHuid = atan2(y - posY, x - posX);
      moverHacia(x + cos(anguloHuid) * (enIra ? 130 : 100), y + sin(anguloHuid) * (enIra ? 130 : 100));
      enMovimiento = true;
    } else {
      enMovimiento = false;
    }

    if (rafagaRestante > 0) {
      timerRafaga--;
      if (timerRafaga <= 0) {
        dispararRafagaMensajes();
        rafagaRestante--;
        timerRafaga = enIra ? 6 : 10; 
      }
    } else if (cooldownAtaque == 0) {
      tipoAtaqueActual = int(random(3));
      estado = 1;
      frameActual = 0;

      if (tipoAtaqueActual == 0) {
        rafagaRestante = enIra ? 6 : 4; 
        timerRafaga = 0;
        cooldownAtaque = enIra ? 90 : 150; 
      } else if (tipoAtaqueActual == 1) {
        dispararMensajeLento();
        cooldownAtaque = enIra ? 70 : 120;
      } else if (tipoAtaqueActual == 2) {
        dispararOndaConEspacio();
        cooldownAtaque = enIra ? 110 : 180;
      }
    }

    x = constrain(x, 50, width - 50);
    y = constrain(y, 180, height - 50);
    animar();
  }

  void moverHacia(float objetivoX, float objetivoY) {
    float dx = objetivoX - x, dy = objetivoY - y, d = sqrt(dx*dx + dy*dy);
    if (d > 0) {
      float velActual = enIra ? vel * 1.3 : vel; 
      dx = (dx / d) * velActual; dy = (dy / d) * velActual;
      if (!colisiona(x + dx, y + dy)) { x += dx; y += dy; }
      else if (!colisiona(x + dx, y)) { x += dx; }
      else if (!colisiona(x, y + dy)) { y += dy; }
    }
  }

  void dispararRafagaMensajes() {
    float centroX = x + charAnchoCentro;
    float centroY = y + charAlturaVisual / 2;
    mensajesEnemigos.add(new Message(centroX, centroY, 2, posX + charAnchoCentro, posY + charAlturaVisual / 2));
  }

  void dispararMensajeLento() {
    float centroX = x + charAnchoCentro;
    float centroY = y + charAlturaVisual / 2;
    
    Message m1 = new Message(centroX, centroY, 0, posX + charAnchoCentro, posY + charAlturaVisual / 2);
    m1.speed = enIra ? 2.5 : 2.0; 
    mensajesEnemigos.add(m1);

    if (enIra) {
      float predX = posX + (moviendoRight ? 120 : (moviendoLeft ? -120 : 0));
      float predY = posY + (moviendoDown ? 120 : (moviendoUp ? -120 : 0));
      Message m2 = new Message(centroX, centroY, 0, predX + charAnchoCentro, predY + charAlturaVisual / 2);
      m2.speed = 2.0;
      mensajesEnemigos.add(m2);
    }
  }

  void dispararOndaConEspacio() {
    float centroX = x + charAnchoCentro;
    float centroY = y + charAlturaVisual / 2;
    float anguloBase = atan2(posY - y, posX - x);
    
    float[] offsets = enIra ? new float[]{-0.8, -0.4, 0, 0.4, 0.8} : new float[]{-0.6, -0.3, 0.3, 0.6};
    
    for (float off : offsets) {
      float ang = anguloBase + off;
      Message m = new Message(centroX, centroY, 3, centroX + cos(ang) * 200, centroY + sin(ang) * 200);
      mensajesEnemigos.add(m);
    }
  }

  void recibirDano(int cantidad) {
    hp -= cantidad;
    estado = 2;
    timerEstado = 20;
    frameActual = 0;
    if (hp <= 0) {
      vivo = false;
    }
  }

  void animar() {
    contadorAnim++;
    int cadenciaAnim = enIra ? 6 : 8; 
    if (contadorAnim >= cadenciaAnim) {
      contadorAnim = 0;
      if (estado == 2 && jefeHit != null) {
        frameActual = min(frameActual + 1, jefeHit.length - 1);
      } else if (estado == 1 && jefeAtaque != null) {
        frameActual = (frameActual + 1) % jefeAtaque.length;
        if (frameActual == 0) estado = 0;
      } else if (enMovimiento && jefeCaminar != null) {
        frameActual = (frameActual + 1) % jefeCaminar.length;
      } else if (jefeIdle != null) {
        frameActual = (frameActual + 1) % jefeIdle.length;
      }
    }
  }

  void dibujar() {
    if (!vivo) return;
    PImage spriteActual = null;
    
    if (estado == 2 && jefeHit != null && jefeHit.length > 0) {
      spriteActual = jefeHit[min(frameActual, jefeHit.length - 1)];
    } else if (estado == 1 && jefeAtaque != null && jefeAtaque.length > 0) {
      spriteActual = jefeAtaque[frameActual % jefeAtaque.length];
    } else if (enMovimiento && jefeCaminar != null && jefeCaminar.length > 0) {
      spriteActual = jefeCaminar[frameActual % jefeCaminar.length];
    } else if (jefeIdle != null && jefeIdle.length > 0) {
      spriteActual = jefeIdle[frameActual % jefeIdle.length];
    }

    if (spriteActual == null && jefeIdle != null) spriteActual = jefeIdle[0];
    if (spriteActual == null) return;

    float w = spriteActual.width * escalaJefe, h = spriteActual.height * escalaJefe;
    pushMatrix();
    translate(x + charAnchoCentro, y + charAlturaVisual - h);
    if (mirandoIzquierda) scale(-1, 1);
    
    if (enIra && frameCount % 10 < 5) tint(255, 150, 150);
    imageMode(CORNER);
    image(spriteActual, -w / 2, 0, w, h);
    noTint();
    popMatrix();

    float anchoBarraJefe = 400;
    float barraX = (width / 2) - (anchoBarraJefe / 2);
    float barraY = 60;
    stroke(0); strokeWeight(2); fill(40, 40, 40); rect(barraX, barraY, anchoBarraJefe, 16, 4);
    noStroke();
    if (enIra) fill(255, 50, 50); else fill(200, 0, 255); 
    rect(barraX + 2, barraY + 2, map(hp, 0, maxHp, 0, anchoBarraJefe - 4), 12, 2);
    fill(255); textSize(12); textAlign(CENTER, CENTER);
    text(enIra ? "JEFE FINAL (ENFURECIDO) - HP: " + max(0, hp) : "JEFE FINAL - HP: " + max(0, hp) + " / " + maxHp, width / 2, barraY + 8);
    textAlign(LEFT, BASELINE);
  }
}

// ==========================================================================
// CLASE: EL GEMELO DE DATOS
// ==========================================================================
class GemeloDatos {
  float x, y;
  float vel = 1.4;
  int hp = 270, maxHp = 270;
  int estado = 0; 
  int cooldownDisparo = 90; 
  int ráfagaRestante = 0;
  int timerRafaga = 0;
  int frameActual = 0, contadorAnim = 0;
  boolean mirandoIzquierda = false, vivo = true, enMovimiento = false;
  float escalaGemelo = 0.20;

  GemeloDatos(float startX, float startY) {
    this.x = startX;
    this.y = startY;
  }

  void actualizar() {
    if (!vivo) return;
    if (cooldownDisparo > 0) cooldownDisparo--;

    float distAlJugador = dist(x, y, posX, posY);
    mirandoIzquierda = (posX < x);

    if (distAlJugador > 280) {
      moverHacia(posX, posY); 
      enMovimiento = true;
    } else if (distAlJugador < 180) {
      float anguloHuid = atan2(y - posY, x - posX);
      moverHacia(x + cos(anguloHuid) * 80, y + sin(anguloHuid) * 80);
      enMovimiento = true;
    } else {
      enMovimiento = false; 
    }

    if (ráfagaRestante > 0) {
      timerRafaga--;
      if (timerRafaga <= 0) {
        dispararMensajeGemelo();
        ráfagaRestante--;
        timerRafaga = 12; 
      }
    } else if (cooldownDisparo == 0 && distAlJugador <= 320) {
      ráfagaRestante = 3;
      timerRafaga = 0;
      cooldownDisparo = 200; 
    }

    x = constrain(x, 40, width - 40);
    y = constrain(y, 180, height - 50);
    animar();
  }

  void moverHacia(float objetivoX, float objetivoY) {
    float dx = objetivoX - x, dy = objetivoY - y, d = sqrt(dx*dx + dy*dy);
    if (d > 0) {
      dx = (dx / d) * vel; dy = (dy / d) * vel;
      if (!colisiona(x + dx, y + dy)) { x += dx; y += dy; }
      else if (!colisiona(x + dx, y)) { x += dx; }
      else if (!colisiona(x, y + dy)) { y += dy; }
    }
  }

  void dispararMensajeGemelo() {
    float centroX = x + charAnchoCentro;
    float centroY = y + charAlturaVisual / 2;
    mensajesEnemigos.add(new Message(centroX, centroY, 2, posX + charAnchoCentro, posY + charAlturaVisual / 2));
  }

  void recibirDano(int cantidad) {
    hp -= cantidad;
    if (hp <= 0) {
      vivo = false;
      if (vidaActual <= 40) {
        listaPowerUps.add(new PowerUp(x + charAnchoCentro, y + charAlturaVisual / 2, 2));
      }
    }
  }

  void animar() {
    contadorAnim++;
    if (contadorAnim >= 8) {
      contadorAnim = 0;
      if (ráfagaRestante > 0) {
        frameActual = (frameActual + 1) % gemeloDisparar.length;
      } else if (enMovimiento) {
        frameActual = (frameActual + 1) % gemeloCaminar.length;
      } else {
        frameActual = (frameActual + 1) % gemeloIdle.length;
      }
    }
  }

  void dibujar() {
    if (!vivo) return;
    PImage spriteActual = gemeloIdle[0];
    if (spriteActual == null) return;

    if (ráfagaRestante > 0 && gemeloDisparar != null) {
      spriteActual = gemeloDisparar[frameActual % gemeloDisparar.length];
    } else if (enMovimiento && gemeloCaminar != null) {
      spriteActual = gemeloCaminar[frameActual % gemeloCaminar.length];
    } else if (gemeloIdle != null) {
      spriteActual = gemeloIdle[frameActual % gemeloIdle.length];
    }

    float w = spriteActual.width * escalaGemelo, h = spriteActual.height * escalaGemelo;
    pushMatrix();
    translate(x + charAnchoCentro, y + charAlturaVisual - h);
    if (mirandoIzquierda) scale(-1, 1);
    imageMode(CORNER);
    image(spriteActual, -w / 2, 0, w, h);
    popMatrix();

    float anchoMiniBarra = 40;
    float barraX = x + charAnchoCentro - (anchoMiniBarra / 2);
    float barraY = y + charAlturaVisual - h - 15;
    noStroke(); fill(255, 0, 0); rect(barraX, barraY, anchoMiniBarra, 5);
    fill(0, 255, 0); rect(barraX, barraY, map(hp, 0, maxHp, 0, anchoMiniBarra), 5);
  }
}

// ==========================================================================
// CLASE MATON
// ==========================================================================
class Maton {
  float x, y;
  float vel = 0.85;
  int hp = 500, maxHp = 500;
  int estado = 0;
  float destX, destY;
  int timerEstado = 0, cooldownAtaque = 0;
  int frameActual = 0, contadorAnim = 0;
  boolean mirandoIzquierda = false, vivo = true, enMovimiento = false;
  boolean evadiendo = false;
  float evadeX, evadeY;
  int framesStuck = 0, tiempoEvadiendo = 0;

  Maton(float startX, float startY) {
    this.x = startX; this.y = startY;
    elegirNuevoDestino(); timerEstado = int(random(180, 300));
  }

  void actualizar() {
    if (!vivo) return;
    if (cooldownAtaque > 0) cooldownAtaque--;
    if (estado == 3) { enMovimiento = false; if (timerEstado > 0) timerEstado--; else { estado = 1; timerEstado = 0; } animar(); return; }
    if (estado == 2) {
      enMovimiento = false;
      if (timerEstado > 0) {
        timerEstado--;
        if (timerEstado == 0) {
          if (dist(x, y, posX, posY) < 70) {
            if (tieneEscudo) { tieneEscudo = false; }
            else { vidaActual -= 20; aturdido = true; timerAturdido = tiempoAturdidoMax; rodando = false; }
          }
          estado = 1; cooldownAtaque = 90;
        }
      }
      animar(); return;
    }
    float distAlJugador = dist(x, y, posX, posY);
    if (estado == 0) {
      moverHacia(destX, destY);
      if (dist(x, y, destX, destY) < 10) elegirNuevoDestino();
      timerEstado--; if (timerEstado <= 0) estado = 1;
    } else if (estado == 1) {
      moverHacia(posX, posY);
      if (distAlJugador < 55 && cooldownAtaque == 0) { estado = 2; timerEstado = 64; frameActual = 0; }
    }
    animar();
  }

  void elegirNuevoDestino() { destX = random(50, width - 50); destY = random(50, height - 50); }

  void moverHacia(float objetivoX, float objetivoY) {
    float targetX = objetivoX, targetY = objetivoY;
    if (evadiendo) {
      targetX = evadeX; targetY = evadeY; tiempoEvadiendo--;
      if (tiempoEvadiendo <= 0 || dist(x, y, evadeX, evadeY) < 15) evadiendo = false;
    }
    float dx = targetX - x, dy = targetY - y, d = sqrt(dx*dx + dy*dy);
    if (d > 0) {
      dx = (dx / d) * vel; dy = (dy / d) * vel;
      if (!evadiendo) { if (dx < 0) mirandoIzquierda = true; else if (dx > 0) mirandoIzquierda = false; }
      float prevX = x, prevY = y; boolean seMovio = false;
      if (!colisiona(x + dx, y + dy)) { x += dx; y += dy; seMovio = true; } 
      else if (!colisiona(x + dx, y)) { x += dx; seMovio = true; } 
      else if (!colisiona(x, y + dy)) { y += dy; seMovio = true; } 
      if (dist(prevX, prevY, x, y) < vel * 0.3) {
        framesStuck++;
        if (framesStuck > 30) {
          evadiendo = true; framesStuck = 0; tiempoEvadiendo = 90;
          float angulo = atan2(posY - y, posX - x);
          float desvio = (random(1) > 0.5) ? HALF_PI : -HALF_PI; 
          evadeX = constrain(x + cos(angulo + desvio) * 150, 50, width - 50);
          evadeY = constrain(y + sin(angulo + desvio) * 150, 50, height - 50);
        }
      } else { framesStuck = 0; }
      enMovimiento = seMovio;
      if (!seMovio && estado == 0) elegirNuevoDestino();
    } else { enMovimiento = false; }
  }

  void recibirDano(int cantidad) {
    hp -= cantidad;
    if (hp <= 0) {
      vivo = false;
      if (vidaActual <= 40) listaPowerUps.add(new PowerUp(x + charAnchoCentro, y + charAlturaVisual / 2, 2));
    } else { estado = 3; timerEstado = 20; frameActual = 0; }
  }

  void animar() {
    contadorAnim++;
    if (contadorAnim >= 8) {
      contadorAnim = 0;
      if (estado == 3) frameActual = min(frameActual + 1, matonHit.length - 1);
      else if (estado == 2) frameActual = min(frameActual + 1, matonAtaque.length - 1);
      else if (enMovimiento) frameActual = (frameActual + 1) % matonCaminar.length;
      else frameActual = (frameActual + 1) % matonIdle.length;
    }
  }

  void dibujar() {
    if (!vivo) return;
    PImage spriteActual = matonIdle[0];
    if (spriteActual == null) return;
    if (estado == 3) spriteActual = matonHit[min(frameActual, matonHit.length - 1)];
    else if (estado == 2) spriteActual = matonAtaque[min(frameActual, matonAtaque.length - 1)];
    else if (enMovimiento) spriteActual = matonCaminar[frameActual % matonCaminar.length];
    else spriteActual = matonIdle[frameActual % matonIdle.length];

    float w = spriteActual.width * escalaSprite, h = spriteActual.height * escalaSprite;
    pushMatrix();
    translate(x + charAnchoCentro, y + charAlturaVisual - h);
    if (mirandoIzquierda) scale(-1, 1);
    image(spriteActual, -w / 2, 0, w, h);
    popMatrix();

    float anchoMiniBarra = 40;
    float barraX = x + charAnchoCentro - (anchoMiniBarra / 2);
    float barraY = y + charAlturaVisual - h - 15;
    noStroke(); fill(255, 0, 0); rect(barraX, barraY, anchoMiniBarra, 5);
    fill(0, 255, 0); rect(barraX, barraY, map(hp, 0, maxHp, 0, anchoMiniBarra), 5);
  }
}

// ==========================================================================
// CLASE DE LA ENEMIGA: LA INTRIGANTE
// ==========================================================================
class Intrigante {
  float x, y;
  float vel = 1.6; 
  int hp = 250, maxHp = 250; 
  int estado = 0; 
  int timerEstado = 0; 
  int cooldownDisparo = 90; 
  int frameActual = 0, contadorAnim = 0;
  boolean mirandoIzquierda = false, vivo = true, enMovimiento = false;

  Intrigante(float startX, float startY) { 
    this.x = startX; 
    this.y = startY; 
  }

  void actualizar() {
    if (!vivo) return;
    if (cooldownDisparo > 0) cooldownDisparo--;

    if (estado == 3) {
      enMovimiento = false;
      if (timerEstado > 0) {
        timerEstado--;
      } else {
        estado = 0; 
        timerEstado = 0;
      }
      animar(); 
      return;
    }

    float distAlJugador = dist(x, y, posX, posY);
    mirandoIzquierda = (posX < x);

    if (distAlJugador < 190) {
      float anguloHuid = atan2(y - posY, x - posX);
      moverHacia(x + cos(anguloHuid) * 100, y + sin(anguloHuid) * 100);
      estado = 0;
      if (cooldownDisparo == 0) { 
        dispararMensajeRojo(); 
        cooldownDisparo = 180; 
        estado = 2; 
      }
    } else if (distAlJugador >= 190 && distAlJugador <= 450) {
      enMovimiento = false;
      if (cooldownDisparo == 0) { 
        dispararMensajeRojo(); 
        cooldownDisparo = 220; 
        estado = 2; 
      }
    } else {
      moverHacia(posX, posY);
      estado = 0;
    }
    
    x = constrain(x, 40, width - 40);
    y = constrain(y, 180, height - 50);
    animar();
  }

  void moverHacia(float objetivoX, float objetivoY) {
    float dx = objetivoX - x, dy = objetivoY - y, d = sqrt(dx*dx + dy*dy);
    if (d > 0) {
      dx = (dx / d) * vel; dy = (dy / d) * vel;
      if (!colisiona(x + dx, y + dy)) { x += dx; y += dy; enMovimiento = true; } 
      else if (!colisiona(x + dx, y)) { x += dx; enMovimiento = true; } 
      else if (!colisiona(x, y + dy)) { y += dy; enMovimiento = true; } 
      else { enMovimiento = false; }
    } else { enMovimiento = false; }
  }

  void dispararMensajeRojo() {
    float centroX = x + charAnchoCentro;
    float centroY = y + charAlturaVisual / 2;
    mensajesEnemigos.add(new Message(centroX, centroY, 0, posX + charAnchoCentro, posY + charAlturaVisual / 2));
  }

  void recibirDano(int cantidad) {
    hp -= cantidad;
    if (hp <= 0) {
      vivo = false;
      if (vidaActual <= 40) {
        listaPowerUps.add(new PowerUp(x + charAnchoCentro, y + charAlturaVisual / 2, 2));
      }
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
      if (estado == 3 && intriganteHit != null) {
        frameActual = min(frameActual + 1, intriganteHit.length - 1);
      } else if (estado == 2 && intriganteAtaque != null) {
        frameActual = (frameActual + 1) % intriganteAtaque.length;
      } else if (enMovimiento && intriganteCaminar != null) {
        frameActual = (frameActual + 1) % intriganteCaminar.length;
      } else if (intriganteIdle != null) {
        frameActual = (frameActual + 1) % intriganteIdle.length;
      }
    }
  }

  void dibujar() {
    if (!vivo) return;
    
    PImage spriteActual = null;
    if (estado == 3 && intriganteHit != null && intriganteHit.length > 0) {
      spriteActual = intriganteHit[min(frameActual, intriganteHit.length - 1)];
    } else if (estado == 2 && intriganteAtaque != null && intriganteAtaque.length > 0) {
      spriteActual = intriganteAtaque[frameActual % intriganteAtaque.length];
    } else if (enMovimiento && intriganteCaminar != null && intriganteCaminar.length > 0) {
      spriteActual = intriganteCaminar[frameActual % intriganteCaminar.length];
    } else if (intriganteIdle != null && intriganteIdle.length > 0) {
      spriteActual = intriganteIdle[frameActual % intriganteIdle.length];
    }
    
    if (spriteActual == null && intriganteIdle != null) spriteActual = intriganteIdle[0];
    if (spriteActual == null) return;

    float w = spriteActual.width * 0.20, h = spriteActual.height * 0.20;
    pushMatrix();
    translate(x + charAnchoCentro, y + charAlturaVisual - h);
    if (mirandoIzquierda) scale(-1, 1);
    imageMode(CORNER);
    image(spriteActual, -w / 2, 0, w, h);
    popMatrix();

    float anchoMiniBarra = 40;
    float barraX = x + charAnchoCentro - (anchoMiniBarra / 2);
    float barraY = y + charAlturaVisual - h - 15;
    noStroke(); fill(255, 0, 0); rect(barraX, barraY, anchoMiniBarra, 5);
    fill(0, 255, 0); rect(barraX, barraY, map(hp, 0, maxHp, 0, anchoMiniBarra), 5);
  }
}

// ==========================================
// CLASE BALA (CON HITBOX MEJORADA PARA EL JEFE)
// ==========================================
class Bala {
  float x, yDibujo, ySuelo, vx;
  boolean viva = true;

  Bala(float x, float yDibujo, float ySuelo, float vx) {
    this.x = x; this.yDibujo = yDibujo; this.ySuelo = ySuelo; this.vx = vx;
  }

  void actualizar() {
    x += vx;
    if (x < 0 || x > width) { viva = false; return; }
    float yChoque = ySuelo - 6;
    for (float[] o : obstaculosPx) {
      if (x > o[0] && x < o[0] + o[2] && yChoque > o[1] && yChoque < o[1] + o[3]) {
        viva = false; return;
      }
    }
    for (Maton m : listaMatones) {
      if (m.vivo && m.estado != 3) {
        if (dist(x, yDibujo, m.x + charAnchoCentro, m.y + charAlturaVisual - 30) < 45) {
          m.recibirDano(40); viva = false; break;
        }
      }
    }
    for (Intrigante in : listaIntrigantes) {
      if (in.vivo && in.estado != 3) {
        if (dist(x, yDibujo, in.x + charAnchoCentro, in.y + charAlturaVisual - 30) < 45) {
          in.recibirDano(40); viva = false; break;
        }
      }
    }
    for (GemeloDatos g : listaGemelos) {
      if (g.vivo) {
        if (dist(x, yDibujo, g.x + charAnchoCentro, g.y + charAlturaVisual - 30) < 45) {
          g.recibirDano(40); viva = false; break;
        }
      }
    }
    
    if (jefeFinal != null && jefeFinal.vivo) {
      float wJefe = 400 * jefeFinal.escalaJefe; 
      float hJefe = 400 * jefeFinal.escalaJefe; 
      
      float izq = jefeFinal.x + charAnchoCentro - (wJefe / 2);
      float der = jefeFinal.x + charAnchoCentro + (wJefe / 2);
      float arr = jefeFinal.y + charAlturaVisual - hJefe;
      float aba = jefeFinal.y + charAlturaVisual;
      
      if (x > izq - 10 && x < der + 10 && yDibujo > arr - 10 && yDibujo < aba + 10) {
        jefeFinal.recibirDano(40); 
        viva = false;
      }
    }
  }

  void dibujar() {
    noStroke();
    fill(30, 20, 40); rect(x - 9, yDibujo - 5, 18, 10);
    fill(255, 220, 60); rect(x - 7, yDibujo - 3, 14, 6);
    fill(255, 255, 200); rect(x - 4, yDibujo - 1, 8, 2);
  }
}

// ==========================================
// CLASE POWER UP
// ==========================================
class PowerUp {
  float x, y;
  int tipo; 
  boolean activo = true;
  float animY = 0; 

  PowerUp(float x, float y, int tipo) {
    this.x = x; this.y = y; this.tipo = tipo;
  }

  void actualizar() {
    if (!activo) return;
    animY = sin(frameCount * 0.1) * 5;
    if (dist(x, y + animY, posX + charAnchoCentro, posY + charAlturaVisual / 2) < 35) {
      aplicarEfecto();
      activo = false; 
    }
  }

  void aplicarEfecto() {
    if (tipo == 0) { tieneEscudo = true; } 
    else if (tipo == 1) { modoFuegoRapido = true; timerFuegoRapido = 180; municionActual = municionMax; } 
    else if (tipo == 2) { vidaActual = min(vidaActual + 12, vidaMax); }
  }

  void dibujar() {
    if (!activo) return;
    pushMatrix();
    translate(x, y + animY);
    noStroke();
    if (tipo == 0) {
      fill(41, 128, 185); ellipse(0, 0, 30, 30);
      fill(93, 173, 226); ellipse(0, 0, 22, 22);
      fill(255); rect(-2, -6, 4, 12); rect(-6, -2, 12, 4);
    } else if (tipo == 1) {
      fill(241, 196, 15); ellipse(0, 0, 30, 30);
      fill(255, 247, 153); ellipse(0, 0, 22, 22);
      fill(211, 84, 0);
      triangle(2, -10, -4, 0, 2, 0);
      triangle(-2, 10, 4, 0, -2, 0);
    } else if (tipo == 2) {
      fill(180, 220, 190); rect(-17, -12, 34, 22, 5);
      fill(255); rect(-15, -10, 30, 18, 4);
      fill(46, 204, 113); rect(-4, -4, 3, 3); rect(1, -4, 3, 3); rect(-5, -2, 10, 4); triangle(-5, 2, 5, 2, 0, 6);
    }
    popMatrix();
  }
}

// ==========================================
// BUCLE PRINCIPAL (DRAW)
// ==========================================
void draw() {
  background(0);

  if (estadoActual == STATE_CINEMATIC) {
    if (cinematicaJuego != null) cinematicaJuego.updateAndDraw();
  } else if (estadoActual == STATE_BOSS_CINEMATIC) {
    if (cinematicaBoss != null) cinematicaBoss.updateAndDraw();
  } else if (estadoActual == STATE_ENDING_CINEMATIC) {
    if (cinematicaFinal != null) cinematicaFinal.updateAndDraw();
  } else if (estadoActual == STATE_MENU) {
    image(pantallaMenu, 0, 0, width, height);
  } else if (estadoActual == STATE_INSTRUCTIONS) {
    image(pantallaInstrucciones, 0, 0, width, height);
  } else if (estadoActual == STATE_CREDITS) { // --- PANTALLA DE CRÉDITOS ---
    background(15, 20, 30);
    textAlign(CENTER, CENTER);
    
    fill(255, 215, 0); textSize(50); 
    text("CRÉDITOS", width / 2, height / 2 - 140);
    
    fill(255); textSize(24); 
    text("Diseño y Desarrollo:", width / 2, height / 2 - 60);
    
    fill(50, 205, 50); textSize(36); 
    text("Juan Ayala", width / 2, height / 2 + 10);
    text("Daniel Balaguera", width / 2, height / 2 + 65);
    text("Camilo Campos", width / 2, height / 2 + 120);
    
    fill(100, 150, 255); textSize(18);
    text("Ingeniería de Sistemas", width / 2, height / 2 + 190);
    
    fill(180); textSize(16);
    text("Presiona ENTER o haz clic para volver al menú", width / 2, height - 50);
    textAlign(LEFT, BASELINE);
  } else if (estadoActual == STATE_GAME_OVER) {
    background(0);
    textAlign(CENTER, CENTER);
    fill(255, 220, 60); textSize(64); 
    text("GAME OVER", width / 2, height / 2 - 40);
    fill(255); textSize(24); 
    text("Llegaste hasta la ronda: " + rondaActual, width / 2, height / 2 + 30);
    textSize(16); fill(180);
    text("Presiona ENTER para volver al menú principal", width / 2, height / 2 + 85);
    textAlign(LEFT, BASELINE);
  } else if (estadoActual == STATE_VICTORY) {
    background(20, 30, 50);
    textAlign(CENTER, CENTER);
    fill(50, 255, 100); textSize(64); 
    text("¡VICTORIA!", width / 2, height / 2 - 40);
    fill(255); textSize(22); 
    text("¡Has derrotado al ciberacoso y salvado el colegio!", width / 2, height / 2 + 30);
    textSize(16); fill(180);
    text("Presiona ENTER para volver al menú principal", width / 2, height / 2 + 90);
    textAlign(LEFT, BASELINE);
  } else if (estadoActual == STATE_GAME) {
    image(escenarioJuego, 0, 0, width, height);

    if (vidaActual <= 0 && !juegoPausado) {
      cambiarPantalla(STATE_GAME_OVER);
    }

    // SI EL TEMPORIZADOR AÚN NO TERMINA, SOLO MOSTRAMOS EL TEXTO (Y LA PAUSA SI LA ACTIVAN)
    if (temporizadorRonda < duracionRondaTexto) {
      if (!juegoPausado) temporizadorRonda++;
      
      noStroke(); fill(0, 150); rect(0, 0, width, height);
      textAlign(CENTER, CENTER); fill(255, 220, 60); textSize(64); 
      text(rondaActual == 3 ? "¡RONDA FINAL!" : "RONDA " + rondaActual, width / 2, height / 2);
      fill(255); textSize(20); text("¡Prepárate!", width / 2, height / 2 + 60);
      textAlign(LEFT, BASELINE);

      // Dibujar menú de pausa si presionan ESC justo en el letrero de "Prepárate"
      if (juegoPausado) {
        fill(0, 180); rect(0, 0, width, height);
        textAlign(CENTER, CENTER); fill(255, 215, 0); textSize(70); text("PAUSA", width / 2, height / 2 - 30);
        fill(255); textSize(22); text("Presiona ESC para continuar", width / 2, height / 2 + 40);
        textAlign(LEFT, BASELINE);
      }
      
    } else {
      // AQUÍ EMPIEZA LA JUGABILIDAD REAL, LOS PERSONAJES APARECEN Y SE MUEVEN
      boolean estudianteSeMueve = false;

      // --- LÓGICA DE ACTUALIZACIÓN (SE DETIENE EN PAUSA) ---
      if (!juegoPausado) {
        if (rondaActual == 3) {
          if (vidaActual <= 40 && !powerUpGeneradoBajoVida) {
            float pX = random(200, 750); float pY = random(300, 450);
            listaPowerUps.add(new PowerUp(pX, pY, 2)); powerUpGeneradoBajoVida = true;
          } else if (vidaActual > 40) { powerUpGeneradoBajoVida = false; }
        }

        if (rollCooldown > 0) rollCooldown--;
        if (cooldownDisparo > 0) cooldownDisparo--;
        if (tiempoPoseDisparo > 0) tiempoPoseDisparo--;
        
        if (modoFuegoRapido) {
          timerFuegoRapido--; municionActual = municionMax;
          if (frameCount % 6 == 0 && !rodando) disparar();
          if (timerFuegoRapido <= 0) modoFuegoRapido = false;
        }
        if (aturdido) { timerAturdido--; if (timerAturdido <= 0) aturdido = false; }
        if (recargando) { timerRecarga--; if (timerRecarga <= 0) { municionActual = municionMax; recargando = false; } }

        if (!aturdido) {
          if (rodando) { actualizarRoll(); estudianteSeMueve = true; } 
          else {
            float dx = 0, dy = 0;
            if (moviendoUp) dy -= velocidad; if (moviendoDown) dy += velocidad;
            if (moviendoLeft) dx -= velocidad; if (moviendoRight) dx += velocidad;
            if (dx < 0) mirandoIzquierda = true; else if (dx > 0) mirandoIzquierda = false;
            if (dx != 0 && !colisiona(posX + dx, posY)) { posX += dx; estudianteSeMueve = true; }
            if (dy != 0 && !colisiona(posX, posY + dy)) { posY += dy; estudianteSeMueve = true; }
          }
          if (disparando && !rodando && cooldownDisparo == 0 && (municionActual > 0 || modoFuegoRapido) && !recargando) disparar();
        }

        if (rondaActual == 1) {
          if (matonesSpawned < 3 || intrigantesSpawned < 3) {
            timerSpawn++;
            if (timerSpawn >= 500) {
              timerSpawn = 0; float spawnX = 0, spawnY = 0; boolean encontrado = false; int intentos = 0;
              while (!encontrado && intentos < 50) {
                spawnX = random(200, 800); spawnY = random(320, 460);
                if (posicionValida(spawnX, spawnY)) encontrado = true;
                intentos++;
              }
              if (encontrado) {
                if (matonesSpawned < 3 && (matonesSpawned <= intrigantesSpawned)) { listaMatones.add(new Maton(spawnX, spawnY)); matonesSpawned++; } 
                else if (intrigantesSpawned < 3) { listaIntrigantes.add(new Intrigante(spawnX, spawnY)); intrigantesSpawned++; }
              }
            }
          }
        } else if (rondaActual == 2) {
          if (matonesSpawned < 2 || intrigantesSpawned < 3 || gemelosSpawned < 3) {
            timerSpawn++;
            if (timerSpawn >= 300) {
              timerSpawn = 0; float spawnX = random(200, 800); float spawnY = random(320, 460);
              if (posicionValida(spawnX, spawnY)) {
                if (gemelosSpawned < 3) { listaGemelos.add(new GemeloDatos(spawnX, spawnY)); gemelosSpawned++; } 
                else if (intrigantesSpawned < 3) { listaIntrigantes.add(new Intrigante(spawnX, spawnY)); intrigantesSpawned++; } 
                else if (matonesSpawned < 2) { listaMatones.add(new Maton(spawnX, spawnY)); matonesSpawned++; }
              }
            }
          }
        }

        if (rondaActual == 3 && jefeFinal != null) jefeFinal.actualizar();
        for (int i = listaMatones.size() - 1; i >= 0; i--) listaMatones.get(i).actualizar();
        for (int i = listaIntrigantes.size() - 1; i >= 0; i--) listaIntrigantes.get(i).actualizar();
        for (int i = listaGemelos.size() - 1; i >= 0; i--) listaGemelos.get(i).actualizar();
        for (int i = listaPowerUps.size() - 1; i >= 0; i--) { PowerUp p = listaPowerUps.get(i); p.actualizar(); if (!p.activo) listaPowerUps.remove(i); }

        if (rondaActual == 1) {
          if (matonesSpawned >= 3 && intrigantesSpawned >= 3) {
            boolean todosMuertos = true;
            for (Maton m : listaMatones) if (m.vivo) todosMuertos = false;
            for (Intrigante in : listaIntrigantes) if (in.vivo) todosMuertos = false;
            if (todosMuertos) {
              rondaActual = 2; temporizadorRonda = 0; matonesSpawned = 0; intrigantesSpawned = 0; gemelosSpawned = 0;
              listaMatones.clear(); listaIntrigantes.clear(); listaPowerUps.clear();
              listaPowerUps.add(new PowerUp(250, 480, 0)); listaPowerUps.add(new PowerUp(550, 500, 1)); 
              listaPowerUps.add(new PowerUp(750, 420, 0)); listaPowerUps.add(new PowerUp(400, 320, 1)); 
            }
          }
        } else if (rondaActual == 2) {
          boolean todosMuertosR2 = true;
          for (Maton m : listaMatones) if (m.vivo) todosMuertosR2 = false;
          for (Intrigante in : listaIntrigantes) if (in.vivo) todosMuertosR2 = false;
          for (GemeloDatos g : listaGemelos) if (g.vivo) todosMuertosR2 = false;
          if (matonesSpawned >= 2 && intrigantesSpawned >= 3 && gemelosSpawned >= 3 && todosMuertosR2) {
            if (estadoActual != STATE_BOSS_CINEMATIC && !enTransicion) { cinematicaBoss = new Cinematic(1); cambiarPantalla(STATE_BOSS_CINEMATIC); }
          }
        } else if (rondaActual == 3) {
          if (jefeFinal != null && !jefeFinal.vivo) {
            if (estadoActual != STATE_ENDING_CINEMATIC && !enTransicion && estadoActual != STATE_VICTORY) {
              cinematicaFinal = new Cinematic(2); cambiarPantalla(STATE_ENDING_CINEMATIC); 
            }
          }
        }
      } else {
        estudianteSeMueve = (moviendoUp || moviendoDown || moviendoLeft || moviendoRight || rodando);
      }

      // --- LÓGICA DE DIBUJADO (SE MANTIENE DURANTE LA PAUSA) ---
      if (rondaActual == 3 && jefeFinal != null) jefeFinal.dibujar();
      for (Maton m : listaMatones) m.dibujar();
      for (Intrigante in : listaIntrigantes) in.dibujar();
      for (GemeloDatos g : listaGemelos) g.dibujar();
      for (PowerUp p : listaPowerUps) p.dibujar();

      dibujarEstudiante(estudianteSeMueve && !juegoPausado);
      actualizarYDibujarBalas(!juegoPausado);
      actualizarYDibujarMensajes(!juegoPausado);
      dibujarBarraVida(); 
      if (mostrarColisiones) dibujarColisiones();

      // --- DIBUJO DEL MENÚ DE PAUSA ---
      if (juegoPausado) {
        fill(0, 180); rect(0, 0, width, height);
        textAlign(CENTER, CENTER); fill(255, 215, 0); textSize(70); text("PAUSA", width / 2, height / 2 - 30);
        fill(255); textSize(22); text("Presiona ESC para continuar", width / 2, height / 2 + 40);
        textAlign(LEFT, BASELINE);
      }
    }
  }
  
  if (enTransicion) actualizarTransicion();
}

void disparar() {
  float dir = mirandoIzquierda ? -1 : 1;
  balas.add(new Bala(posX + charAnchoCentro + dir * 24, posY + charAlturaVisual - 40, posY + charAlturaVisual, dir * balaVelocidad));
  cooldownDisparo = cadenciaDisparo; 
  tiempoPoseDisparo = duracionPose;
  if (!modoFuegoRapido) municionActual--; 
}

void actualizarYDibujarBalas(boolean actualizar) {
  for (int i = balas.size() - 1; i >= 0; i--) {
    Bala b = balas.get(i);
    if (actualizar) b.actualizar();
    if (!b.viva) balas.remove(i); else b.dibujar();
  }
}

void actualizarYDibujarMensajes(boolean actualizar) {
  for (int i = mensajesEnemigos.size() - 1; i >= 0; i--) {
    Message m = mensajesEnemigos.get(i);
    if (actualizar) m.move();
    if (!m.activo) {
      mensajesEnemigos.remove(i); 
    } else {
      m.draw();
      if (actualizar && m.checkCollision() && !rodando) {
        if (m.type != 1) { 
          if (tieneEscudo) { 
            tieneEscudo = false; 
          } else {
            int danoRecibido = (m.type == 3 ? 15 : 10);
            if (rondaActual == 3) {
              danoRecibido = (m.type == 3 ? 25 : 20); 
            }
            vidaActual -= danoRecibido;
            aturdido = true;
            timerAturdido = (m.type == 3 ? 60 : tiempoAturdidoMax);
          }
        }
        mensajesEnemigos.remove(i); 
      }
    }
  }
}

void dibujarBarraVida() {
  float x = 30, y = 30, barraAncho = 220, barraAlto = 22;
  stroke(0); strokeWeight(3); fill(40, 40, 40); rect(x, y, barraAncho, barraAlto, 4);
  noStroke();
  if (vidaActual > 30) fill(46, 204, 113); else fill(231, 76, 60);
  float anchoRelleno = constrain((vidaActual / vidaMax) * (barraAncho - 6), 0, barraAncho - 6);
  rect(x + 3, y + 3, anchoRelleno, barraAlto - 6, 2);
  fill(255); textSize(12); text("HP: " + max(0, int(vidaActual)) + " / " + int(vidaMax), x + 12, y + 16);
  textSize(16);
  if (recargando) { fill(255, 255, 0); text("RECARGANDO...", x, y + 40); } 
  else {
    if (municionActual == 0) fill(255, 50, 50); else fill(255);
    text("BALAS: " + municionActual + " / " + municionMax + " [R]", x, y + 40);
  }
}

void dibujarColisiones() {
  noStroke(); fill(255, 0, 0, 90);
  for (float[] o : obstaculosPx) rect(o[0], o[1], o[2], o[3]);
  fill(0, 255, 0, 160); rect(posX + charAnchoCentro - pieAncho / 2, posY + charAlturaVisual - pieAlto, pieAncho, pieAlto);
}

void dibujarEstudiante(boolean animarCaminata) {
  if (idleSprite == null) return;
  PImage sprite = idleSprite;
  if (rodando) sprite = framesRoll[(rollTick / 3) % framesRoll.length];
  else if (tiempoPoseDisparo > 0) sprite = disparoSprite;
  else if (animarCaminata) {
    contadorAnimacion++;
    if (contadorAnimacion >= velocidadAnimacion) { frameActual = (frameActual + 1) % framesCaminar.length; contadorAnimacion = 0; }
    sprite = framesCaminar[frameActual];
  }
  float w = sprite.width * escalaSprite, h = sprite.height * escalaSprite;
  pushMatrix();
  translate(posX + charAnchoCentro, posY + charAlturaVisual - h);
  if (mirandoIzquierda && sprite != idleSprite) scale(-1, 1);
  if (aturdido && timerAturdido % 8 < 4) tint(255, 50, 50); 
  image(sprite, -w / 2, 0, w, h);
  noTint(); 
  if (modoFuegoRapido) {
    pushStyle(); noFill(); stroke(255, 230, 50, 150 + sin(frameCount * 0.3) * 80); strokeWeight(4);
    ellipse(0, h / 2, h * 0.95, h * 0.95);
    fill(255, 240, 100, 50); noStroke(); ellipse(0, h / 2, h * 0.95, h * 0.95);
    popStyle();
  }
  if (tieneEscudo) {
    pushStyle(); noFill(); stroke(52, 152, 219, 180 + sin(frameCount * 0.2) * 75); strokeWeight(3);
    ellipse(0, h / 2, h * 0.9, h * 0.9);
    fill(133, 193, 233, 40); noStroke(); ellipse(0, h / 2, h * 0.9, h * 0.9);
    popStyle();
  }
  popMatrix();
}

void iniciarRoll() {
  if (rodando || rollCooldown > 0 || (estadoActual != STATE_GAME) || enTransicion || aturdido) return; 
  float dx = 0, dy = 0;
  if (moviendoUp) dy -= 1; if (moviendoDown) dy += 1;
  if (moviendoLeft) dx -= 1; if (moviendoRight) dx += 1;
  if (dx == 0 && dy == 0) dx = mirandoIzquierda ? -1 : 1;
  float m = sqrt(dx * dx + dy * dy);
  rollDirX = dx / m; rollDirY = dy / m;
  mirandoIzquierda = (rollDirX < 0);
  rodando = true; rollTick = 0;
}

void actualizarRoll() {
  float dx = rollDirX * rollVelocidad, dy = rollDirY * rollVelocidad;
  if (dx != 0 && !colisiona(posX + dx, posY)) posX += dx;
  if (dy != 0 && !colisiona(posX, posY + dy)) posY += dy;
  rollTick++;
  if (rollTick >= rollDuracion) { rodando = false; rollCooldown = rollEspera; }
}

void actualizarTransicion() {
  noStroke(); fill(0, alphaTransicion); rect(0, 0, width, height);
  if (!cambiandoDeEstado) {
    alphaTransicion += velocidadTransicion;
    if (alphaTransicion >= 255) { alphaTransicion = 255; estadoActual = estadoSiguiente; cambiandoDeEstado = true; }
  } else {
    alphaTransicion -= velocidadTransicion;
    if (alphaTransicion <= 0) { alphaTransicion = 0; enTransicion = false; cambiandoDeEstado = false; }
  }
}

void cambiarPantalla(int nuevoEstado) {
  if (!enTransicion) {
    estadoSiguiente = nuevoEstado; 
    enTransicion = true; 
    cambiandoDeEstado = false; 
    alphaTransicion = 0;
    
    if (nuevoEstado == STATE_GAME && estadoActual != STATE_BOSS_CINEMATIC && estadoActual != STATE_ENDING_CINEMATIC) {
      reiniciarJuego();
    }
  }
}

void mousePressed() {
  if (enTransicion) return;
  if (estadoActual == STATE_MENU) {
    if (mouseX >= 366 && mouseX <= 561 && mouseY >= 169 && mouseY <= 218) cambiarPantalla(STATE_GAME);
    else if (mouseX >= 366 && mouseX <= 561 && mouseY >= 234 && mouseY <= 282) cambiarPantalla(STATE_INSTRUCTIONS);
    else if (mouseX >= 366 && mouseX <= 561 && mouseY >= 300 && mouseY <= 348) cambiarPantalla(STATE_CREDITS); 
    else if (mouseX >= 366 && mouseX <= 516 && mouseY >= 366 && mouseY <= 414) exit();
  } else if (estadoActual == STATE_INSTRUCTIONS || estadoActual == STATE_CREDITS) {
    cambiarPantalla(STATE_MENU);
  } else if (estadoActual == STATE_GAME_OVER || estadoActual == STATE_VICTORY) {
    if (mouseX >= 0) cambiarPantalla(STATE_MENU);
  }
}

void keyPressed() {
  // ANULACIÓN DE ESC PARA EVITAR QUE SE CIERRE Y ACTIVAR PAUSA EN SU LUGAR
  if (key == ESC) {
    if (estadoActual == STATE_GAME && !enTransicion) {
      juegoPausado = !juegoPausado;
    }
    key = 0; // Obligatorio para evitar el cierre instantáneo de la ventana
    return;
  }
  
  if (estadoActual == STATE_CINEMATIC) {
    if (cinematicaJuego != null) cinematicaJuego.handleKeyPress();
    return;
  }
  if (estadoActual == STATE_BOSS_CINEMATIC) {
    if (cinematicaBoss != null) cinematicaBoss.handleKeyPress();
    return;
  }
  if (estadoActual == STATE_ENDING_CINEMATIC) {
    if (cinematicaFinal != null) cinematicaFinal.handleKeyPress();
    return;
  }
  if (estadoActual == STATE_GAME_OVER || estadoActual == STATE_VICTORY || estadoActual == STATE_CREDITS) {
    if (keyCode == ENTER || keyCode == RETURN) {
      cambiarPantalla(STATE_MENU);
      return;
    }
  }
  if (estadoActual == STATE_GAME && !juegoPausado) {
    if (temporizadorRonda < duracionRondaTexto) return; 
    if (key == 'w' || key == 'W') moviendoUp = true;
    if (key == 's' || key == 'S') moviendoDown = true;
    if (key == 'a' || key == 'A') moviendoLeft = true;
    if (key == 'd' || key == 'D') moviendoRight = true;
    if (key == 'h' || key == 'H') mostrarColisiones = !mostrarColisiones;
    if ((key == 'q' || key == 'Q') && !qMantenida) { qMantenida = true; iniciarRoll(); }
    if (key == 'p' || key == 'P') disparando = true;
    if (key == 'r' || key == 'R') {
      if (municionActual < municionMax && !recargando) { recargando = true; timerRecarga = tiempoRecargaMax; }
    }
  }
}

void keyReleased() {
  if (estadoActual == STATE_GAME) {
    if (key == 'w' || key == 'W') moviendoUp = false;
    if (key == 's' || key == 'S') moviendoDown = false;
    if (key == 'a' || key == 'A') moviendoLeft = false;
    if (key == 'd' || key == 'D') moviendoRight = false;
    if (key == 'q' || key == 'Q') qMantenida = false;
    if (key == 'p' || key == 'P') disparando = false;
  }
}
