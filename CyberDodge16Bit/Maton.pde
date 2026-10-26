// ==========================================================================
// MATON: el acosador. Es el "jefe" del juego: su barra de toxicidad baja
// cuando el jugador bloquea mensajes negativos, lo bloquea a él o reporta.
// Estados: 0 = patrulla, 1 = persigue, 2 = ataca (empuja), 3 = recibe golpe
// ==========================================================================

class Maton {
  float x, y;
  float vel = 0.85f;
  int hp = 600;
  int maxHp = 600;

  int estado = 0;
  float destX, destY;
  int timerEstado = 0;
  int cooldownAtaque = 0;

  int frameActual = 0;
  int contadorAnim = 0;
  boolean mirandoIzquierda = false;
  boolean vivo = true;
  boolean enMovimiento = false;

  Maton(float startX, float startY) {
    this.x = startX;
    this.y = startY;
    elegirNuevoDestino();
    timerEstado = (int) random(180, 300);
  }

  void actualizar() {
    if (!vivo) return;
    Avatar av = juego.avatar;
    vel = min(1.6f, 0.85f + 0.12f * (juego.ronda - 1));

    if (cooldownAtaque > 0) cooldownAtaque--;

    // recibiendo un golpe
    if (estado == 3) {
      enMovimiento = false;
      if (timerEstado > 0) timerEstado--;
      else {
        estado = 1;
        timerEstado = 0;
      }
      animar();
      return;
    }

    // atacando (empujando): el daño se aplica al final de la animación
    if (estado == 2) {
      enMovimiento = false;
      if (timerEstado > 0) {
        timerEstado--;
        if (timerEstado == 0) {
          if (dist(x, y, av.x, av.y) < 70) av.recibirDano(15);
          estado = 1;
          cooldownAtaque = 90;
        }
      }
      animar();
      return;
    }

    float distAlJugador = dist(x, y, av.x, av.y);

    if (estado == 0) {
      moverHacia(destX, destY);
      if (dist(x, y, destX, destY) < 10) elegirNuevoDestino();
      timerEstado--;
      if (timerEstado <= 0) estado = 1;
    } else if (estado == 1) {
      moverHacia(av.x, av.y);
      if (distAlJugador < 55 && cooldownAtaque == 0) {
        estado = 2;
        timerEstado = 8 * 8;
        frameActual = 0;
      }
    }
    animar();
  }

  // El destino de patrulla siempre queda en la zona caminable (parte baja)
  void elegirNuevoDestino() {
    destX = random(40, GW - 90);
    destY = random(240, GH - 100);
  }

  void moverHacia(float objetivoX, float objetivoY) {
    float dx = objetivoX - x;
    float dy = objetivoY - y;
    float d = sqrt(dx * dx + dy * dy);

    if (d > 0) {
      dx = (dx / d) * vel;
      dy = (dy / d) * vel;

      if (dx < 0) mirandoIzquierda = true;
      else if (dx > 0) mirandoIzquierda = false;

      boolean seMovio = false;
      if (!juego.colisiona(x + dx, y + dy)) {
        x += dx;
        y += dy;
        seMovio = true;
      } else if (!juego.colisiona(x + dx, y)) {
        x += dx;
        seMovio = true;
      } else if (!juego.colisiona(x, y + dy)) {
        y += dy;
        seMovio = true;
      } else {
        if (estado == 0) elegirNuevoDestino();
      }
      enMovimiento = seMovio;
    } else {
      enMovimiento = false;
    }
  }

  // reaccionar = true -> se detiene un instante (animación de golpe)
  void recibirDano(int cantidad, boolean reaccionar) {
    if (!vivo) return;
    hp -= cantidad;
    if (hp <= 0) {
      hp = 0;
      vivo = false;
    } else if (reaccionar) {
      estado = 3;
      timerEstado = 20;
      frameActual = 0;
    }
  }

  void animar() {
    contadorAnim++;
    if (contadorAnim >= 8) {
      contadorAnim = 0;
      if (estado == 3) frameActual = min(frameActual + 1, juego.matonHit.length - 1);
      else if (estado == 2) frameActual = min(frameActual + 1, juego.matonAtaque.length - 1);
      else {
        if (enMovimiento) frameActual = (frameActual + 1) % juego.matonCaminar.length;
        else frameActual = (frameActual + 1) % juego.matonIdle.length;
      }
    }
  }

  void dibujar() {
    if (!vivo) return;

    PImage spriteActual = juego.matonIdle[0];
    if (spriteActual == null) return;

    if (estado == 3) spriteActual = juego.matonHit[min(frameActual, juego.matonHit.length - 1)];
    else if (estado == 2) spriteActual = juego.matonAtaque[min(frameActual, juego.matonAtaque.length - 1)];
    else {
      if (enMovimiento) spriteActual = juego.matonCaminar[frameActual % juego.matonCaminar.length];
      else spriteActual = juego.matonIdle[frameActual % juego.matonIdle.length];
    }
    if (spriteActual == null) return;

    float w = spriteActual.width * ESCALA_SPRITE;
    float h = spriteActual.height * ESCALA_SPRITE;

    // sombra
    pushStyle();
    noStroke();
    fill(0, 70);
    ellipse(x + CHAR_ANCHO_CENTRO, y + CHAR_ALTO, 42, 11);
    popStyle();

    pushMatrix();
    translate(x + CHAR_ANCHO_CENTRO, y + CHAR_ALTO - h);
    if (mirandoIzquierda) scale(-1, 1);
    image(spriteActual, -w / 2, 0, w, h);
    popMatrix();

    // mini barra de vida sobre la cabeza
    float anchoMiniBarra = 40;
    float barraX = x + CHAR_ANCHO_CENTRO - (anchoMiniBarra / 2);
    float barraY = y + CHAR_ALTO - h - 15;
    pushStyle();
    noStroke();
    fill(255, 0, 0);
    rect(barraX, barraY, anchoMiniBarra, 5);
    fill(0, 255, 0);
    rect(barraX, barraY, map(hp, 0, maxHp, 0, anchoMiniBarra), 5);
    popStyle();
  }
}
