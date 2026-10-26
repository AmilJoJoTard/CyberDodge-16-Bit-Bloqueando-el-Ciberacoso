// ==========================================================================
// AVATAR: el estudiante que el jugador controla.
// Atributos pedidos: posición (x, y) y bienestar.
// Métodos pedidos: draw(). Además: movimiento, esquiva (roll), disparo del
// "bloqueo" y recepción de daño.
// ==========================================================================

class Avatar {
  float x, y;                       // esquina superior izquierda del sprite
  int bienestar = 100;
  final int bienestarMax = 100;

  // caja de impacto frente a los mensajes
  final float hitAncho = 36;
  final float hitAlto = 66;

  // movimiento
  float velocidad = 2.5f;
  boolean arriba, abajo, izquierda, derecha;
  boolean mirandoIzquierda = false;
  boolean caminando = false;

  // esquiva (roll): invulnerable mientras dura
  boolean rodando = false;
  float rollVel = 5.5f;
  int rollDuracion = 22;
  int rollEspera = 25;
  int rollTick = 0;
  int rollCooldown = 0;
  float rollDirX = 0, rollDirY = 0;

  // bloqueo (disparo con la tecla B)
  boolean disparando = false;
  int cadencia = 15;
  int cooldownDisparo = 0;
  int tiempoPose = 0;
  final int duracionPose = 12;

  // estados temporales
  int invulFrames = 0;     // inmunidad corta tras recibir daño
  int distraccion = 0;     // frames de distracción (mensajes grises)

  // animación de caminata
  int frameCaminar = 0;
  int contadorAnim = 0;
  final int velAnim = 10;

  Avatar(float x, float y) {
    this.x = x;
    this.y = y;
  }

  float centroX() { return x + CHAR_ANCHO_CENTRO; }
  float centroY() { return y + CHAR_ALTO - 40; }

  boolean invulnerable() {
    return rodando || invulFrames > 0;
  }

  void actualizar() {
    if (rollCooldown > 0) rollCooldown--;
    if (cooldownDisparo > 0) cooldownDisparo--;
    if (tiempoPose > 0) tiempoPose--;
    if (invulFrames > 0) invulFrames--;
    if (distraccion > 0) distraccion--;
    caminando = false;

    if (rodando) {
      mover(rollDirX * rollVel, rollDirY * rollVel);
      rollTick++;
      caminando = true;
      if (rollTick >= rollDuracion) {
        rodando = false;
        rollCooldown = rollEspera;
      }
    } else {
      float v = (distraccion > 0) ? velocidad * 0.55f : velocidad;
      float dx = 0, dy = 0;
      if (izquierda) { dx -= v; mirandoIzquierda = true; }
      if (derecha)   { dx += v; mirandoIzquierda = false; }
      if (arriba) dy -= v;
      if (abajo)  dy += v;
      if (dx != 0 || dy != 0) {
        mover(dx, dy);
        caminando = true;
      }
      if (disparando && cooldownDisparo == 0) disparar();
    }

    // animación de caminata
    if (caminando) {
      contadorAnim++;
      if (contadorAnim >= velAnim) {
        contadorAnim = 0;
        frameCaminar = (frameCaminar + 1) % 4;
      }
    } else {
      frameCaminar = 0;
      contadorAnim = 0;
    }
  }

  // Mueve por ejes separados para poder "resbalar" contra las paredes
  void mover(float dx, float dy) {
    if (!juego.colisiona(x + dx, y)) x += dx;
    if (!juego.colisiona(x, y + dy)) y += dy;
  }

  void iniciarRoll() {
    if (rodando || rollCooldown > 0) return;
    float dx = 0, dy = 0;
    if (izquierda) dx -= 1;
    if (derecha)   dx += 1;
    if (arriba)    dy -= 1;
    if (abajo)     dy += 1;
    if (dx == 0 && dy == 0) dx = mirandoIzquierda ? -1 : 1;
    float m = sqrt(dx * dx + dy * dy);
    rollDirX = dx / m;
    rollDirY = dy / m;
    if (dx < 0) mirandoIzquierda = true;
    if (dx > 0) mirandoIzquierda = false;
    rodando = true;
    rollTick = 0;
  }

  void disparar() {
    float dir = mirandoIzquierda ? -1 : 1;
    float bx = x + CHAR_ANCHO_CENTRO + dir * 24;
    float by = y + CHAR_ALTO - 40;
    juego.crearBala(bx, by, y + CHAR_ALTO, dir * 11.0f);
    cooldownDisparo = cadencia;
    tiempoPose = duracionPose;
  }

  void recibirDano(int cantidad) {
    if (invulnerable()) return;
    bienestar = max(0, bienestar - cantidad);
    invulFrames = 40;
    juego.efectoDano(cantidad);
  }

  void curar(int cantidad) {
    bienestar = min(bienestarMax, bienestar + cantidad);
  }

  void draw() {
    PImage sprite = juego.idleSprite;
    // sombra
    pushStyle();
    noStroke();
    fill(0, 70);
    ellipse(x + CHAR_ANCHO_CENTRO, y + CHAR_ALTO, 38, 10);
    popStyle();

    // parpadeo mientras es inmune por daño
    if (invulFrames > 0 && !rodando && (invulFrames / 4) % 2 == 0) return;

    if (rodando) {
      sprite = juego.framesRoll[(rollTick / 3) % juego.framesRoll.length];
    } else if (tiempoPose > 0) {
      sprite = juego.disparoSprite;
    } else if (caminando) {
      sprite = juego.framesCaminar[frameCaminar];
    }
    if (sprite == null) sprite = juego.idleSprite;
    if (sprite == null) return;

    float w = sprite.width * ESCALA_SPRITE;
    float h = sprite.height * ESCALA_SPRITE;
    pushMatrix();
    translate(x + CHAR_ANCHO_CENTRO, y + CHAR_ALTO - h);
    if (mirandoIzquierda && sprite != juego.idleSprite) scale(-1, 1);
    if (distraccion > 0) tint(185, 185, 215);
    image(sprite, -w / 2, 0, w, h);
    noTint();
    popMatrix();

    // burbuja de distracción sobre la cabeza
    if (distraccion > 0) {
      pushStyle();
      fill(255, 230);
      stroke(60);
      strokeWeight(2);
      rect(x + CHAR_ANCHO_CENTRO - 18, y - 22, 36, 18, 6);
      fill(60);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("...", x + CHAR_ANCHO_CENTRO, y - 15);
      popStyle();
    }
  }
}
