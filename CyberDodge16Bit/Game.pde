// ==========================================================================
// GAME: la clase "sistema" del videojuego.
// Maneja: estados y transiciones, recursos (imágenes/sprites), generación y
// movimiento de mensajes, puntaje, bienestar, racha de negativos (REPORTAR),
// pantallas (menú, instrucciones, créditos, juego, game over, victoria) y HUD.
//
// ARREGLOS
//   Message[] mensajes   -> arreglo 1D con los mensajes activos (null = libre)
//   Bala[] balas         -> arreglo 1D con los bloqueos activos
//   String[][] muro      -> arreglo 2D: "muro de chat" (texto, tipo) del HUD
// ==========================================================================

class Game {

  // ---------------------------- Estado general ----------------------------
  int estado = STATE_CINEMATIC;
  int estadoSiguiente = STATE_MENU;
  boolean enTransicion = false;
  boolean cambiandoDeEstado = false;
  float alphaTransicion = 0;
  float velocidadTransicion = 10;

  // ------------------------------ Recursos --------------------------------
  PImage imgMenu, imgInstrucciones, imgEscenario;
  PImage sheetEstudiante, sheetMaton;
  PImage idleSprite, disparoSprite;
  PImage[] framesCaminar = new PImage[4];
  PImage[] framesRoll = new PImage[3];
  PImage[] matonIdle = new PImage[3];
  PImage[] matonCaminar = new PImage[7];
  PImage[] matonAtaque = new PImage[8];
  PImage[] matonHit = new PImage[4];
  Cinematic cine;

  // ------------------------- Escenario y colisiones -----------------------
  final float REF_W = 655, REF_H = 287;   // tamaño del escenario original
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
  boolean mostrarColisiones = false;     // tecla H para depurar

  // ------------------------------ Entidades -------------------------------
  Avatar avatar;
  Maton maton;
  final int MAX_MENSAJES = 30;
  final int MAX_BALAS = 24;
  Message[] mensajes = new Message[MAX_MENSAJES];
  Bala[] balas = new Bala[MAX_BALAS];
  String[][] muro = new String[4][2];

  // ------------------------------- Partida --------------------------------
  int puntaje = 0;
  int mejorPuntaje = 0;
  int framesJugados = 0;
  int ronda = 1;
  final int FRAMES_POR_RONDA = 1800;      // cada 30 s sube la dificultad
  int temporizadorRonda = 0;
  final int duracionIntro = 150;
  boolean pausado = false;

  // generación de mensajes
  int cooldownSpawn = 60;
  int racha = 0;                          // negativos seguidos
  int rafaga = 0;                         // negativos pendientes de la ráfaga
  boolean reporteDisponible = false;
  int reporteTimer = 0;
  final int REPORTE_DURACION = 420;       // 7 s para usarlo

  // estadísticas (pantalla final)
  int negBloqueados = 0, posCapturados = 0, posRecibidos = 0;
  int posBloqueados = 0, reportes = 0;

  // efectos visuales
  int temblor = 0, flashRojo = 0, flashReporte = 0, capturaFx = 0;
  int bannerRonda = 0;
  int cooldownCaptura = 0;
  final float RADIO_CAPTURA = 170;

  // feedback flotante (arreglos paralelos)
  final int MAX_FB = 10;
  String[] fbTexto = new String[MAX_FB];
  float[] fbX = new float[MAX_FB];
  float[] fbY = new float[MAX_FB];
  int[] fbVida = new int[MAX_FB];
  int[] fbColor = new int[MAX_FB];

  // entrada
  boolean qMantenida = false, cMantenida = false, rMantenida = false;

  // ------------------------------- Textos ---------------------------------
  String[] textosNegativos = {
    "Eres un perdedor", "Nadie te quiere aquí", "Qué ridículo te ves",
    "Borra tu cuenta", "Todos se ríen de ti", "Voy a exponerte",
    "Eres lo peor", "Nadie te va a creer"
  };
  String[] textosPositivos = {
    "Cuenta conmigo", "¡Buen trabajo!", "Eres genial", "Te apoyo",
    "No estás solo", "¡Tú puedes!", "Gracias por ayudar", "Qué valiente"
  };
  String[] textosNeutros = {
    "Meme del día", "¿Viste el video?", "Nueva historia", "Te etiquetaron",
    "+50 likes", "Notificación", "Sorteo gratis", "Mira este reto"
  };
  String[] consejos = {
    "Piensa antes de publicar: detrás de cada pantalla hay una persona.",
    "Bloquear y reportar es tu derecho, y además protege a otros.",
    "Si algo te hace daño en línea, cuéntaselo a un adulto de confianza.",
    "Equilibra tu tiempo: la vida real también necesita tu atención.",
    "No compartas rumores ni datos privados: lo viral también hiere.",
    "Rodéate de mensajes que suman: el apoyo también se contagia."
  };
  String consejoFinal = "";

  Game() {
  }

  // ======================================================================
  //  RECURSOS
  // ======================================================================
  void cargarRecursos() {
    imgMenu = loadImage("pantalladeinicio.png");
    imgInstrucciones = loadImage("instrucciones.png");
    imgEscenario = loadImage("escenario.png");
    sheetEstudiante = loadImage("estudiante.png");
    sheetMaton = loadImage("el_maton_separado.png");
    if (imgMenu == null || imgEscenario == null || sheetEstudiante == null) {
      println("ERROR: no se encontraron las imágenes. La carpeta 'data' debe estar "
        + "DENTRO de la carpeta del sketch (CyberDodge16Bit/data).");
    }
    prepararSpritesEstudiante();
    prepararSpritesMaton();
    prepararColisiones();
    cine = new Cinematic();
    reiniciarPartida();
  }

  void prepararSpritesEstudiante() {
    if (sheetEstudiante == null) return;
    idleSprite = recortarAjustado(sheetEstudiante, 40, 30, 230, 330);
    int[][] regCam = {{500, 30, 210, 330}, {710, 30, 200, 330}, {910, 30, 210, 330}, {1120, 30, 220, 330}};
    for (int i = 0; i < 4; i++) {
      framesCaminar[i] = recortarAjustado(sheetEstudiante, regCam[i][0], regCam[i][1], regCam[i][2], regCam[i][3]);
    }
    int[][] regRol = {{220, 480, 210, 230}, {430, 480, 200, 230}, {635, 480, 200, 230}};
    for (int i = 0; i < 3; i++) {
      framesRoll[i] = recortarAjustado(sheetEstudiante, regRol[i][0], regRol[i][1], regRol[i][2], regRol[i][3]);
    }
    disparoSprite = recortarAjustado(sheetEstudiante, 1090, 430, 230, 280);
  }

  void prepararSpritesMaton() {
    if (sheetMaton == null) return;
    int celda = 400;
    for (int i = 0; i < 3; i++) matonIdle[i] = sheetMaton.get(i * celda, 0, celda, celda);
    for (int i = 0; i < 7; i++) matonCaminar[i] = sheetMaton.get(i * celda, celda, celda, celda);
    for (int i = 0; i < 8; i++) matonAtaque[i] = sheetMaton.get(i * celda, celda * 2, celda, celda);
    for (int i = 0; i < 4; i++) matonHit[i] = sheetMaton.get(i * celda, celda * 3, celda, celda);
  }

  // Recorta una región de la hoja de sprites y la ajusta a su contenido visible
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

  void prepararColisiones() {
    float ex = GW / REF_W;
    float ey = GH / REF_H;
    obstaculosPx = new float[obstaculosRef.length][4];
    for (int i = 0; i < obstaculosRef.length; i++) {
      obstaculosPx[i][0] = obstaculosRef[i][0] * ex;
      obstaculosPx[i][1] = obstaculosRef[i][1] * ey;
      obstaculosPx[i][2] = obstaculosRef[i][2] * ex;
      obstaculosPx[i][3] = obstaculosRef[i][3] * ey;
    }
  }

  // true si los pies de un personaje en (px, py) chocan con algo
  boolean colisiona(float px, float py) {
    float izq = px + CHAR_ANCHO_CENTRO - PIE_ANCHO / 2;
    float der = izq + PIE_ANCHO;
    float aba = py + CHAR_ALTO;
    float arr = aba - PIE_ALTO;
    if (izq < 0 || der > GW || arr < 0 || aba > GH) return true;
    for (float[] o : obstaculosPx) {
      if (der > o[0] && izq < o[0] + o[2] && aba > o[1] && arr < o[1] + o[3]) return true;
    }
    return false;
  }

  // ======================================================================
  //  PARTIDA
  // ======================================================================
  void reiniciarPartida() {
    avatar = new Avatar(400, 400);
    maton = new Maton(150, 300);
    for (int i = 0; i < mensajes.length; i++) mensajes[i] = null;
    for (int i = 0; i < balas.length; i++) balas[i] = null;
    for (int i = 0; i < muro.length; i++) {
      muro[i][0] = null;
      muro[i][1] = null;
    }
    for (int i = 0; i < MAX_FB; i++) fbVida[i] = 0;
    puntaje = 0;
    framesJugados = 0;
    ronda = 1;
    temporizadorRonda = 0;
    pausado = false;
    cooldownSpawn = 60;
    racha = 0;
    rafaga = 0;
    reporteDisponible = false;
    reporteTimer = 0;
    negBloqueados = 0;
    posCapturados = 0;
    posRecibidos = 0;
    posBloqueados = 0;
    reportes = 0;
    temblor = 0;
    flashRojo = 0;
    flashReporte = 0;
    capturaFx = 0;
    bannerRonda = 0;
    cooldownCaptura = 0;
  }

  void terminarPartida(boolean victoria) {
    if (victoria) puntaje += 200 + avatar.bienestar * 2;
    mejorPuntaje = max(mejorPuntaje, puntaje);
    consejoFinal = consejos[(int) random(consejos.length)];
    cambiarPantalla(victoria ? STATE_VICTORY : STATE_GAME_OVER);
  }

  // Fade a negro y cambio de estado
  void cambiarPantalla(int nuevoEstado) {
    if (enTransicion) return;
    estadoSiguiente = nuevoEstado;
    enTransicion = true;
    cambiandoDeEstado = false;
    alphaTransicion = 0;
  }

  // ======================================================================
  //  ACTUALIZACIÓN (lógica)
  // ======================================================================
  void actualizar() {
    boolean jugando = (estado == STATE_PLAYING) && !pausado && !enTransicion;
    if (jugando) actualizarJuego();
  }

  void actualizarJuego() {
    if (temporizadorRonda < duracionIntro) {
      temporizadorRonda++;
      return;
    }
    framesJugados++;
    int nuevaRonda = 1 + framesJugados / FRAMES_POR_RONDA;
    if (nuevaRonda != ronda) {
      ronda = nuevaRonda;
      bannerRonda = 100;
    }

    if (temblor > 0) temblor--;
    if (flashRojo > 0) flashRojo--;
    if (flashReporte > 0) flashReporte--;
    if (capturaFx > 0) capturaFx--;
    if (bannerRonda > 0) bannerRonda--;
    if (cooldownCaptura > 0) cooldownCaptura--;

    avatar.actualizar();
    maton.actualizar();
    generarMensajes();
    moverMensajes();
    moverBalas();
    resolverBloqueos();
    actualizarReporte();
    actualizarFeedback();

    if (avatar.bienestar <= 0) terminarPartida(false);
    else if (!maton.vivo) terminarPartida(true);
  }

  // ---------------------------- Mensajes ---------------------------------
  void generarMensajes() {
    cooldownSpawn--;
    if (cooldownSpawn > 0) return;

    float seg = framesJugados / 60.0f;
    cooldownSpawn = (int) max(26, 85 - seg * 0.6f);   // cada vez más seguidos

    int tipo;
    if (rafaga > 0) {
      tipo = MSG_NEGATIVO;
      rafaga--;
      cooldownSpawn = 32;
    } else {
      float r = random(1);
      if (r < 0.50f) tipo = MSG_NEGATIVO;
      else if (r < 0.78f) tipo = MSG_POSITIVO;
      else tipo = MSG_NEUTRO;
      // a veces el acosador lanza 3 negativos seguidos
      if (tipo == MSG_NEGATIVO && random(1) < 0.22f) rafaga = 2;
    }
    crearMensaje(tipo);
  }

  void crearMensaje(int tipo) {
    int slot = -1;
    for (int i = 0; i < mensajes.length; i++) {
      if (mensajes[i] == null) {
        slot = i;
        break;
      }
    }
    if (slot < 0) return;

    float seg = framesJugados / 60.0f;
    float mult = min(2.4f, 1 + seg * 0.012f);         // la velocidad acelera con el tiempo
    float v = (2.0f + random(0, 1.0f)) * mult;
    boolean desdeIzq = random(1) < 0.5f;

    float y;
    if (random(1) < 0.6f) y = avatar.centroY() + random(-110, 110);   // apunta al avatar
    else y = random(270, GH - 30);
    y = constrain(y, 250, GH - 30);

    String txt = elegirTexto(tipo);
    Message m = new Message(tipo, txt, 0, y, desdeIzq ? v : -v);
    m.x = desdeIzq ? -m.w / 2 : GW + m.w / 2;
    mensajes[slot] = m;
    agregarAlMuro(txt, tipo);

    // racha de negativos -> habilita REPORTAR
    if (tipo == MSG_NEGATIVO) racha++;
    else racha = 0;
    if (racha >= 3 && !reporteDisponible) {
      reporteDisponible = true;
      reporteTimer = REPORTE_DURACION;
      mostrarFeedback("¡REPORTE DISPONIBLE! Pulsa R", GW / 2, 160, color(255, 230, 80));
    }
  }

  String elegirTexto(int tipo) {
    String[] fuente = textosNeutros;
    if (tipo == MSG_NEGATIVO) fuente = textosNegativos;
    else if (tipo == MSG_POSITIVO) fuente = textosPositivos;
    return fuente[(int) random(fuente.length)];
  }

  void agregarAlMuro(String txt, int tipo) {
    for (int i = 0; i < muro.length - 1; i++) {
      muro[i][0] = muro[i + 1][0];
      muro[i][1] = muro[i + 1][1];
    }
    muro[muro.length - 1][0] = txt;
    muro[muro.length - 1][1] = "" + tipo;
  }

  void moverMensajes() {
    for (int i = 0; i < mensajes.length; i++) {
      Message m = mensajes[i];
      if (m == null) continue;
      m.move();
      if (m.salioDePantalla()) {
        mensajes[i] = null;
        continue;
      }
      if (m.colisionaCon(avatar)) procesarContacto(i);
    }
  }

  // Un mensaje toca al avatar
  void procesarContacto(int i) {
    Message m = mensajes[i];
    if (m.tipo == MSG_POSITIVO) {
      recogerPositivo(i, false);
    } else if (m.tipo == MSG_NEGATIVO) {
      if (avatar.invulnerable()) return;           // la esquiva lo atraviesa
      avatar.recibirDano(10);
      mostrarFeedback("-10 bienestar", avatar.centroX(), avatar.y - 10, color(255, 90, 90));
      mensajes[i] = null;
    } else {
      if (avatar.invulnerable()) return;
      avatar.distraccion = 150;
      mostrarFeedback("¡Distraído!", avatar.centroX(), avatar.y - 10, color(210));
      mensajes[i] = null;
    }
  }

  void recogerPositivo(int i, boolean capturado) {
    Message m = mensajes[i];
    mensajes[i] = null;
    int pts = capturado ? 10 : 5;
    int bien = capturado ? 5 : 3;
    puntaje += pts;
    avatar.curar(bien);
    if (capturado) posCapturados++;
    else posRecibidos++;
    mostrarFeedback("+" + pts + " apoyo", m.x, m.y - 20, color(90, 255, 130));
  }

  // ----------------------------- Bloqueos --------------------------------
  void crearBala(float bx, float by, float suelo, float vx) {
    for (int i = 0; i < balas.length; i++) {
      if (balas[i] == null) {
        balas[i] = new Bala(bx, by, suelo, vx);
        return;
      }
    }
  }

  void moverBalas() {
    for (int i = 0; i < balas.length; i++) {
      if (balas[i] == null) continue;
      balas[i].actualizar();
      if (!balas[i].viva) balas[i] = null;
    }
  }

  void resolverBloqueos() {
    for (int b = 0; b < balas.length; b++) {
      Bala bala = balas[b];
      if (bala == null) continue;
      for (int i = 0; i < mensajes.length && bala.viva; i++) {
        Message m = mensajes[i];
        if (m != null && bala.golpea(m)) {
          bloquearMensaje(i);
          bala.viva = false;
        }
      }
      if (bala.viva && maton.vivo && maton.estado != 3 && bala.golpeaMaton(maton)) {
        maton.recibirDano(15, true);
        puntaje += 5;
        mostrarFeedback("¡Bloqueado! +5", maton.x + CHAR_ANCHO_CENTRO, maton.y - 20, color(120, 200, 255));
        bala.viva = false;
      }
      if (!bala.viva) balas[b] = null;
    }
  }

  void bloquearMensaje(int i) {
    Message m = mensajes[i];
    if (m.tipo == MSG_NEGATIVO) {
      puntaje += 10;
      negBloqueados++;
      maton.recibirDano(6, false);
      mostrarFeedback("+10 bloqueado", m.x, m.y - 20, color(120, 200, 255));
    } else if (m.tipo == MSG_POSITIVO) {
      puntaje = max(0, puntaje - 15);
      avatar.bienestar = max(1, avatar.bienestar - 5);
      posBloqueados++;
      mostrarFeedback("-15 ¡bloqueaste apoyo!", m.x, m.y - 20, color(255, 150, 60));
    } else {
      mostrarFeedback("bloqueado", m.x, m.y - 20, color(200));
    }
    mensajes[i] = null;
  }

  // Tecla C: captura los mensajes positivos cercanos
  void capturar() {
    if (cooldownCaptura > 0) return;
    cooldownCaptura = 20;
    capturaFx = 14;
    int n = 0;
    for (int i = 0; i < mensajes.length; i++) {
      Message m = mensajes[i];
      if (m != null && m.tipo == MSG_POSITIVO
        && dist(m.x, m.y, avatar.centroX(), avatar.centroY()) < RADIO_CAPTURA) {
        recogerPositivo(i, true);
        n++;
      }
    }
    if (n == 0) mostrarFeedback("sin apoyo cerca", avatar.centroX(), avatar.y - 10, color(200));
  }

  // Tecla R: solo funciona tras 3 mensajes negativos seguidos
  void reportar() {
    if (!reporteDisponible) {
      mostrarFeedback("Reporte no disponible", avatar.centroX(), avatar.y - 10, color(200));
      return;
    }
    int n = 0;
    for (int i = 0; i < mensajes.length; i++) {
      Message m = mensajes[i];
      if (m != null && m.tipo == MSG_NEGATIVO) {
        mensajes[i] = null;
        n++;
      }
    }
    int bonus = 50 + 5 * n;
    puntaje += bonus;
    reportes++;
    maton.recibirDano(80, true);
    reporteDisponible = false;
    racha = 0;
    rafaga = 0;
    flashReporte = 14;
    mostrarFeedback("¡REPORTADO! +" + bonus, GW / 2, GH / 2, color(255, 230, 80));
  }

  void actualizarReporte() {
    if (!reporteDisponible) return;
    reporteTimer--;
    if (reporteTimer <= 0) {
      reporteDisponible = false;
      racha = 0;
      mostrarFeedback("El reporte expiró", GW / 2, 160, color(200));
    }
  }

  void efectoDano(int cantidad) {
    temblor = 12;
    flashRojo = 14;
  }

  // ---------------------------- Feedback ---------------------------------
  void mostrarFeedback(String t, float px, float py, int col) {
    int slot = 0;
    int menor = 9999;
    for (int i = 0; i < MAX_FB; i++) {
      if (fbVida[i] <= 0) {
        slot = i;
        break;
      }
      if (fbVida[i] < menor) {
        menor = fbVida[i];
        slot = i;
      }
    }
    fbTexto[slot] = t;
    fbX[slot] = px;
    fbY[slot] = py;
    fbVida[slot] = 55;
    fbColor[slot] = col;
  }

  void actualizarFeedback() {
    for (int i = 0; i < MAX_FB; i++) {
      if (fbVida[i] > 0) {
        fbVida[i]--;
        fbY[i] -= 0.6f;
      }
    }
  }

  void dibujarFeedback() {
    pushStyle();
    textAlign(CENTER, CENTER);
    textSize(15);
    for (int i = 0; i < MAX_FB; i++) {
      if (fbVida[i] <= 0) continue;
      float a = constrain(fbVida[i] * 6, 0, 255);
      fill(0, a);
      text(fbTexto[i], fbX[i] + 1, fbY[i] + 1);
      fill(red(fbColor[i]), green(fbColor[i]), blue(fbColor[i]), a);
      text(fbTexto[i], fbX[i], fbY[i]);
    }
    popStyle();
  }

  // ======================================================================
  //  DIBUJO
  // ======================================================================
  void dibujar() {
    background(0);
    switch (estado) {
    case STATE_CINEMATIC:
      cine.updateAndDraw();
      break;
    case STATE_MENU:
      fondo(imgMenu);
      break;
    case STATE_INSTRUCTIONS:
      dibujarInstrucciones();
      break;
    case STATE_CREDITS:
      dibujarCreditos();
      break;
    case STATE_PLAYING:
      dibujarJuego();
      break;
    case STATE_GAME_OVER:
      dibujarFinal(false);
      break;
    case STATE_VICTORY:
      dibujarFinal(true);
      break;
    }
    if (enTransicion) actualizarTransicion();
  }

  void fondo(PImage img) {
    if (img != null) image(img, 0, 0, GW, GH);
    else background(20, 25, 40);
  }

  void actualizarTransicion() {
    if (!cambiandoDeEstado) {
      alphaTransicion += velocidadTransicion;
      if (alphaTransicion >= 255) {
        alphaTransicion = 255;
        cambiandoDeEstado = true;
        estado = estadoSiguiente;
        if (estado == STATE_PLAYING) reiniciarPartida();
      }
    } else {
      alphaTransicion -= velocidadTransicion;
      if (alphaTransicion <= 0) {
        alphaTransicion = 0;
        enTransicion = false;
        cambiandoDeEstado = false;
      }
    }
    pushStyle();
    noStroke();
    fill(0, alphaTransicion);
    rect(0, 0, GW, GH);
    popStyle();
  }

  // ----------------------------- Partida ---------------------------------
  void dibujarJuego() {
    pushMatrix();
    if (temblor > 0) translate(random(-3, 3), random(-3, 3));
    fondo(imgEscenario);

    if (maton.y < avatar.y) {
      maton.dibujar();
      avatar.draw();
    } else {
      avatar.draw();
      maton.dibujar();
    }
    for (int i = 0; i < balas.length; i++) {
      if (balas[i] != null) balas[i].dibujar();
    }
    for (int i = 0; i < mensajes.length; i++) {
      if (mensajes[i] != null) mensajes[i].draw();
    }
    if (capturaFx > 0) dibujarAnilloCaptura();
    if (mostrarColisiones) dibujarColisiones();
    dibujarFeedback();
    popMatrix();

    if (flashRojo > 0) {
      pushStyle();
      noStroke();
      fill(255, 0, 0, flashRojo * 7);
      rect(0, 0, GW, GH);
      popStyle();
    }
    if (flashReporte > 0) {
      pushStyle();
      noStroke();
      fill(255, 255, 160, flashReporte * 9);
      rect(0, 0, GW, GH);
      popStyle();
    }

    dibujarHUD();

    if (temporizadorRonda < duracionIntro) dibujarIntro();
    else if (bannerRonda > 0) dibujarBannerRonda();
    if (pausado) dibujarPausa();
  }

  void dibujarAnilloCaptura() {
    float p = 1 - capturaFx / 14.0f;
    float d = lerp(50, RADIO_CAPTURA * 2, p);
    pushStyle();
    noFill();
    stroke(80, 255, 120, 255 * (1 - p));
    strokeWeight(4);
    ellipse(avatar.centroX(), avatar.centroY(), d, d);
    popStyle();
  }

  void dibujarColisiones() {
    pushStyle();
    noFill();
    stroke(255, 0, 0);
    strokeWeight(1);
    for (float[] o : obstaculosPx) rect(o[0], o[1], o[2], o[3]);
    stroke(0, 255, 255);
    rect(avatar.centroX() - avatar.hitAncho / 2, avatar.centroY() - avatar.hitAlto / 2, avatar.hitAncho, avatar.hitAlto);
    popStyle();
  }

  void dibujarIntro() {
    pushStyle();
    noStroke();
    fill(0, 170);
    rect(0, 0, GW, GH);
    textAlign(CENTER, CENTER);
    fill(255, 215, 0);
    textSize(64);
    text("RONDA 1", GW / 2, GH / 2 - 50);
    fill(255);
    textSize(22);
    text("¡Prepárate! Bloquea lo negativo y rodéate de lo positivo.", GW / 2, GH / 2 + 15);
    fill(180, 230, 255);
    textSize(16);
    text("B bloquear  ·  C capturar apoyo  ·  R reportar  ·  Q esquivar  ·  P pausa", GW / 2, GH / 2 + 55);
    popStyle();
  }

  void dibujarBannerRonda() {
    pushStyle();
    textAlign(CENTER, CENTER);
    float a = constrain(bannerRonda * 6, 0, 255);
    textSize(44);
    fill(0, a);
    text("RONDA " + ronda + " · ¡más rápido!", GW / 2 + 2, 202);
    fill(255, 215, 0, a);
    text("RONDA " + ronda + " · ¡más rápido!", GW / 2, 200);
    popStyle();
  }

  void dibujarPausa() {
    pushStyle();
    noStroke();
    fill(0, 190);
    rect(0, 0, GW, GH);
    textAlign(CENTER, CENTER);
    fill(255, 215, 0);
    textSize(60);
    text("PAUSA", GW / 2, GH / 2 - 70);
    fill(255);
    textSize(20);
    text("[P] o [ESC] continuar   ·   [M] volver al menú", GW / 2, GH / 2);
    fill(180, 230, 255);
    textSize(16);
    text("WASD/flechas mover · Q esquivar · B bloquear · C capturar · R reportar", GW / 2, GH / 2 + 45);
    popStyle();
  }

  // ------------------------------- HUD -----------------------------------
  void dibujarHUD() {
    pushStyle();

    // Barra de bienestar
    float bx = 30, by = 28, bw = 230, bh = 24;
    stroke(0);
    strokeWeight(3);
    fill(40);
    rect(bx, by, bw, bh, 4);
    noStroke();
    if (avatar.bienestar > 30) fill(46, 204, 113);
    else fill(231, 76, 60);
    float rel = constrain((float) avatar.bienestar / avatar.bienestarMax, 0, 1) * (bw - 6);
    rect(bx + 3, by + 3, rel, bh - 6, 2);
    fill(255);
    textSize(12);
    textAlign(LEFT, CENTER);
    text("BIENESTAR " + max(0, avatar.bienestar) + "/" + avatar.bienestarMax, bx + 10, by + bh / 2 - 1);

    // Puntaje
    textoSombra("PUNTOS: " + puntaje, bx, by + 42, 18, color(255, 230, 120));

    // Racha de negativos / reporte
    textoSombra("RACHA NEGATIVA", bx, by + 68, 12, color(255));
    for (int i = 0; i < 3; i++) {
      stroke(0);
      strokeWeight(2);
      if (racha > i) fill(225, 60, 60);
      else fill(70);
      ellipse(bx + 120 + i * 20, by + 68, 14, 14);
    }
    if (reporteDisponible) {
      boolean parpadeo = (frameCount / 10) % 2 == 0;
      fill(parpadeo ? color(255, 230, 80) : color(255, 150, 60));
      stroke(0);
      strokeWeight(2);
      rect(bx, by + 84, 170, 24, 5);
      noStroke();
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(14);
      text("¡REPORTAR! [R]", bx + 85, by + 96);
      fill(255, 230, 80);
      rect(bx, by + 112, 170 * (reporteTimer / (float) REPORTE_DURACION), 4);
    }
    if (avatar.distraccion > 0) {
      textoSombra("DISTRAÍDO: velocidad reducida", bx, by + 128, 12, color(210));
    }

    // Barra de toxicidad del Matón
    float tw = 300, tx = GW / 2 - tw / 2, ty = 34;
    textAlign(CENTER, CENTER);
    textoSombra("TOXICIDAD DEL MATÓN", GW / 2, ty - 14, 12, color(255));
    stroke(0);
    strokeWeight(3);
    fill(40);
    rect(tx, ty - 4, tw, 16, 4);
    noStroke();
    fill(155, 60, 200);
    rect(tx + 3, ty - 1, (tw - 6) * constrain(maton.hp / (float) maton.maxHp, 0, 1), 10, 2);

    popStyle();

    dibujarMuro();

    // Ayuda de controles
    pushStyle();
    noStroke();
    fill(0, 140);
    rect(0, GH - 22, GW, 22);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("WASD mover · Q esquivar · B bloquear · C capturar apoyo · R reportar · P pausa", GW / 2, GH - 11);
    popStyle();
  }

  // Muro de chat: usa el arreglo 2D "muro"
  void dibujarMuro() {
    float px = GW - 250, py = 14, pw = 236, ph = 118;
    pushStyle();
    stroke(0);
    strokeWeight(2);
    fill(10, 20, 40, 190);
    rect(px, py, pw, ph, 6);
    noStroke();
    fill(180, 230, 255);
    textAlign(LEFT, CENTER);
    textSize(11);
    text("MURO DE CHAT", px + 10, py + 12);
    textSize(12);
    for (int i = 0; i < muro.length; i++) {
      if (muro[i][0] == null) continue;
      int tipo = Integer.parseInt(muro[i][1]);
      float ry = py + 36 + i * 21;
      if (tipo == MSG_NEGATIVO) fill(225, 60, 60);
      else if (tipo == MSG_POSITIVO) fill(50, 185, 90);
      else fill(150, 150, 160);
      ellipse(px + 16, ry, 10, 10);
      fill(255);
      text(recortar(muro[i][0], pw - 40), px + 28, ry - 1);
    }
    popStyle();
  }

  String recortar(String s, float maxW) {
    while (s.length() > 1 && textWidth(s) > maxW) s = s.substring(0, s.length() - 1);
    return s;
  }

  void textoSombra(String t, float px, float py, float tam, int col) {
    pushStyle();
    textSize(tam);
    fill(0);
    text(t, px + 1, py + 1);
    fill(col);
    text(t, px, py);
    popStyle();
  }

  // ----------------------------- Pantallas -------------------------------
  void dibujarInstrucciones() {
    fondo(imgInstrucciones);
    // Panel nuevo sobre el panel original de la imagen (que mostraba los
    // controles de la versión anterior)
    pushStyle();
    stroke(103, 184, 203);
    strokeWeight(3);
    fill(19, 43, 71);
    rect(275, 106, 393, 332, 8);
    noStroke();
    fill(145, 228, 234);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("CONTROLES", 471, 126);
    textAlign(LEFT, CENTER);
    textSize(15);
    fill(255);
    String[] controles = {
      "WASD / Flechas  =  Moverse",
      "Q  =  Esquivar (invulnerable un instante)",
      "B  =  Bloquear mensajes",
      "C  =  Capturar apoyo (mensajes verdes)",
      "R  =  Reportar (3 negativos seguidos)",
      "P  =  Pausa"
    };
    for (int i = 0; i < controles.length; i++) text(controles[i], 296, 154 + i * 22);

    fill(145, 228, 234);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("REGLAS DEL JUEGO", 471, 298);
    textAlign(LEFT, CENTER);
    textSize(15);
    fill(255, 120, 120);
    text("ROJO: quita bienestar. ¡Bloquéalo!", 296, 326);
    fill(120, 235, 150);
    text("VERDE: apoyo. ¡Captúralo, no lo bloquees!", 296, 348);
    fill(200);
    text("GRIS: distrae y te ralentiza.", 296, 370);
    fill(255, 230, 120);
    text("3 rojos seguidos activan REPORTAR [R].", 296, 392);
    fill(255);
    text("Baja la toxicidad del Matón a 0 para ganar.", 296, 414);
    popStyle();
  }

  void dibujarCreditos() {
    fondo(imgEscenario);
    pushStyle();
    noStroke();
    fill(0, 190);
    rect(0, 0, GW, GH);
    stroke(255, 215, 0);
    strokeWeight(3);
    fill(10, 25, 80, 235);
    rect(150, 40, 660, 460, 10);
    noStroke();
    textAlign(CENTER, CENTER);
    fill(255, 215, 0);
    textSize(40);
    text("CRÉDITOS", GW / 2, 85);
    fill(255);
    textSize(22);
    text("CyberDodge 16-Bit: Bloqueando el ciberacoso", GW / 2, 135);
    fill(180, 230, 255);
    textSize(18);
    text("Equipo N.º 1", GW / 2, 175);
    fill(255);
    text("Juan Ayala  ·  Daniel Balaguera  ·  Camilo Campos", GW / 2, 205);
    fill(200);
    textSize(15);
    text("Algoritmia y Programación II · Segundo semestre 2026", GW / 2, 240);
    text("Hecho con Processing / Java", GW / 2, 262);
    popStyle();

    // retratos de los personajes
    PImage[] retratos = {cine.portEstudiante, cine.portIntrigante, cine.portMaton};
    String[] nombres = {"El Estudiante", "La Intrigante", "El Matón"};
    for (int i = 0; i < 3; i++) {
      float rx = 215 + i * 190;
      if (retratos[i] != null) image(retratos[i], rx, 290, 120, 120);
      pushStyle();
      noFill();
      stroke(255, 215, 0);
      strokeWeight(2);
      rect(rx, 290, 120, 120);
      noStroke();
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(14);
      text(nombres[i], rx + 60, 425);
      popStyle();
    }
    dibujarBoton("VOLVER [ENTER]", GW / 2 - 110, 445, 220, 40);
  }

  void dibujarFinal(boolean victoria) {
    fondo(imgEscenario);
    pushStyle();
    noStroke();
    fill(0, 195);
    rect(0, 0, GW, GH);
    stroke(255, 215, 0);
    strokeWeight(3);
    fill(10, 25, 80, 240);
    rect(100, 28, 760, 484, 10);
    noStroke();

    textAlign(CENTER, CENTER);
    if (victoria) fill(90, 255, 130);
    else fill(255, 90, 90);
    textSize(48);
    text(victoria ? "¡VICTORIA!" : "GAME OVER", GW / 2, 68);

    // retrato + estadísticas
    if (cine != null && cine.portEstudiante != null) image(cine.portEstudiante, 130, 110, 130, 130);
    noFill();
    stroke(255, 215, 0);
    strokeWeight(2);
    rect(130, 110, 130, 130);
    noStroke();
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(18);
    text("Puntaje: " + puntaje + "   (mejor: " + mejorPuntaje + ")", 290, 125);
    textSize(15);
    text("Bienestar final: " + max(0, avatar.bienestar) + "/" + avatar.bienestarMax, 290, 155);
    text("Mensajes negativos bloqueados: " + negBloqueados, 290, 178);
    text("Apoyos recibidos: " + (posCapturados + posRecibidos) + "  (capturados con C: " + posCapturados + ")", 290, 201);
    text("Reportes realizados: " + reportes + "   ·   Apoyos bloqueados por error: " + posBloqueados, 290, 224);

    // mensaje reflexivo
    fill(255, 215, 0);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("REFLEXIÓN", GW / 2, 270);
    fill(255);
    textAlign(CENTER, TOP);
    textSize(16);
    String reflexion;
    if (victoria) {
      reflexion = "¡Lo lograste! Bloquear, reportar y rodearte de mensajes de apoyo no es huir: es cuidarte. "
        + "En internet, igual que en la vida real, nadie merece ser acosado, y pedir ayuda siempre es una decisión valiente.";
    } else {
      reflexion = "Tu bienestar llegó a cero. Cuando la toxicidad se acumula, lo mejor es bloquear, reportar y hablar "
        + "con alguien de confianza. No tienes que cargar con esto en silencio: desconectarte un rato también es cuidarte.";
    }
    text(reflexion, 140, 290, 680, 90);
    fill(180, 230, 255);
    textSize(15);
    text("Consejo: " + consejoFinal, 140, 385, 680, 40);
    popStyle();

    dibujarBoton("JUGAR DE NUEVO [ENTER]", 190, 445, 260, 46);
    dibujarBoton("MENÚ [M]", 510, 445, 260, 46);
  }

  void dibujarBoton(String t, float bx, float by, float bw, float bh) {
    boolean sobre = enRect(bx, by, bw, bh);
    pushStyle();
    stroke(255, 215, 0);
    strokeWeight(3);
    if (sobre) fill(30, 70, 160);
    else fill(15, 35, 100);
    rect(bx, by, bw, bh, 8);
    noStroke();
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(17);
    text(t, bx + bw / 2, by + bh / 2 - 2);
    popStyle();
  }

  boolean enRect(float rx, float ry, float rw, float rh) {
    return mx() >= rx && mx() <= rx + rw && my() >= ry && my() <= ry + rh;
  }

  // ======================================================================
  //  ENTRADA
  // ======================================================================
  void teclaPresionada(boolean esc) {
    char k = Character.toLowerCase(key);

    if (estado == STATE_PLAYING && k == 'h') mostrarColisiones = !mostrarColisiones;
    if (enTransicion) return;

    switch (estado) {
    case STATE_CINEMATIC:
      cine.handleKeyPress();
      return;
    case STATE_MENU:
      if (esEnter()) cambiarPantalla(STATE_PLAYING);
      else if (esc) exit();
      return;
    case STATE_INSTRUCTIONS:
    case STATE_CREDITS:
      if (esc || esEnter()) cambiarPantalla(STATE_MENU);
      return;
    case STATE_GAME_OVER:
    case STATE_VICTORY:
      if (esEnter()) cambiarPantalla(STATE_PLAYING);
      else if (k == 'm' || esc) cambiarPantalla(STATE_MENU);
      return;
    }

    // ---- STATE_PLAYING ----
    if (k == 'p' || esc) {
      if (temporizadorRonda >= duracionIntro) pausado = !pausado;
      return;
    }
    if (pausado) {
      if (k == 'm') {
        pausado = false;
        cambiarPantalla(STATE_MENU);
      }
      return;
    }
    if (temporizadorRonda < duracionIntro) return;

    if (k == 'w' || (key == CODED && keyCode == UP)) avatar.arriba = true;
    if (k == 's' || (key == CODED && keyCode == DOWN)) avatar.abajo = true;
    if (k == 'a' || (key == CODED && keyCode == LEFT)) avatar.izquierda = true;
    if (k == 'd' || (key == CODED && keyCode == RIGHT)) avatar.derecha = true;
    if (k == 'q' && !qMantenida) {
      qMantenida = true;
      avatar.iniciarRoll();
    }
    if (k == 'b') avatar.disparando = true;
    if (k == 'c' && !cMantenida) {
      cMantenida = true;
      capturar();
    }
    if (k == 'r' && !rMantenida) {
      rMantenida = true;
      reportar();
    }
  }

  void teclaSoltada() {
    char k = Character.toLowerCase(key);
    if (avatar == null) return;
    if (k == 'w' || (key == CODED && keyCode == UP)) avatar.arriba = false;
    if (k == 's' || (key == CODED && keyCode == DOWN)) avatar.abajo = false;
    if (k == 'a' || (key == CODED && keyCode == LEFT)) avatar.izquierda = false;
    if (k == 'd' || (key == CODED && keyCode == RIGHT)) avatar.derecha = false;
    if (k == 'q') qMantenida = false;
    if (k == 'b') avatar.disparando = false;
    if (k == 'c') cMantenida = false;
    if (k == 'r') rMantenida = false;
  }

  void clic() {
    if (enTransicion) return;
    switch (estado) {
    case STATE_MENU:
      if (enRect(366, 169, 195, 49)) cambiarPantalla(STATE_PLAYING);
      else if (enRect(366, 234, 195, 48)) cambiarPantalla(STATE_INSTRUCTIONS);
      else if (enRect(366, 300, 195, 48)) cambiarPantalla(STATE_CREDITS);
      else if (enRect(366, 366, 195, 48)) exit();
      break;
    case STATE_INSTRUCTIONS:
      if (enRect(405, 450, 150, 55)) cambiarPantalla(STATE_MENU);
      break;
    case STATE_CREDITS:
      if (enRect(GW / 2 - 110, 445, 220, 40)) cambiarPantalla(STATE_MENU);
      break;
    case STATE_GAME_OVER:
    case STATE_VICTORY:
      if (enRect(190, 445, 260, 46)) cambiarPantalla(STATE_PLAYING);
      else if (enRect(510, 445, 260, 46)) cambiarPantalla(STATE_MENU);
      break;
    }
  }
}
