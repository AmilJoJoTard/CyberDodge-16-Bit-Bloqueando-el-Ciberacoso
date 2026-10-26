// ==========================================================================
// BALA: el "bloqueo". Es el icono de prohibido que lanza el estudiante con la
// tecla B. Destruye los mensajes que toca (ojo: bloquear un mensaje positivo
// penaliza) y debilita al Matón si lo alcanza.
// Se guardan en un arreglo de tamaño fijo (Game.balas).
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
    if (x < 0 || x > GW) {
      viva = false;
      return;
    }
    // se detiene contra las paredes y edificios del escenario
    float yChoque = ySuelo - 6;
    for (float[] o : juego.obstaculosPx) {
      if (x > o[0] && x < o[0] + o[2] && yChoque > o[1] && yChoque < o[1] + o[3]) {
        viva = false;
        return;
      }
    }
  }

  boolean golpea(Message m) {
    return abs(x - m.x) < m.w / 2 + 9 && abs(yDibujo - m.y) < m.h / 2 + 9;
  }

  boolean golpeaMaton(Maton m) {
    float cx = m.x + CHAR_ANCHO_CENTRO;
    float cy = m.y + CHAR_ALTO - 30;
    return dist(x, yDibujo, cx, cy) < 45;
  }

  void dibujar() {
    pushStyle();
    // estela
    noStroke();
    fill(255, 120, 120, 90);
    ellipse(x - vx * 1.2f, yDibujo, 14, 14);
    // icono "bloquear": círculo rojo con diagonal
    stroke(235, 60, 60);
    strokeWeight(3);
    fill(255, 255, 255, 235);
    ellipse(x, yDibujo, 20, 20);
    line(x - 6, yDibujo + 6, x + 6, yDibujo - 6);
    popStyle();
  }
}
