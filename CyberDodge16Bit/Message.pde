// ==========================================================================
// MESSAGE: mensaje flotante de la red social.
//   Rojo  (MSG_NEGATIVO): quita bienestar si toca al avatar.
//   Verde (MSG_POSITIVO): suma puntos y bienestar.
//   Gris  (MSG_NEUTRO)  : no cambia las estadísticas, pero distrae.
// Atributos pedidos: tipo, texto, posición, velocidad.
// Métodos pedidos: move(), draw() y detección de colisión.
// ==========================================================================

final int MSG_NEGATIVO = 0;
final int MSG_POSITIVO = 1;
final int MSG_NEUTRO   = 2;

class Message {
  int tipo;
  String texto;
  float x, y;        // centro del mensaje
  float baseY;       // altura alrededor de la cual "flota"
  float vx;          // velocidad horizontal (px por frame)
  float w, h = 30;   // tamaño de la burbuja
  float fase, amplitud;

  Message(int tipo, String texto, float x, float y, float vx) {
    this.tipo = tipo;
    this.texto = texto;
    this.x = x;
    this.y = y;
    this.baseY = y;
    this.vx = vx;
    this.fase = random(TWO_PI);
    this.amplitud = random(6, 16);
    pushStyle();
    textSize(13);
    this.w = textWidth(texto) + 46;
    popStyle();
  }

  // Avanza en horizontal y flota con un vaivén senoidal
  void move() {
    x += vx;
    y = baseY + sin(frameCount * 0.07f + fase) * amplitud;
  }

  void draw() {
    int c = colorBase();
    pushStyle();
    rectMode(CENTER);
    // sombra
    noStroke();
    fill(0, 70);
    rect(x + 3, y + 4, w, h, 8);
    // burbuja
    stroke(20, 20, 30);
    strokeWeight(2);
    fill(c);
    rect(x, y, w, h, 8);
    // icono del tipo de mensaje
    noStroke();
    fill(255);
    ellipse(x - w / 2 + 16, y, 18, 18);
    fill(c);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(simbolo(), x - w / 2 + 16, y - 1);
    // texto
    fill(255);
    textSize(13);
    textAlign(LEFT, CENTER);
    text(texto, x - w / 2 + 30, y - 1);
    popStyle();
  }

  // Colisión (rectángulo contra rectángulo) con el avatar
  boolean colisionaCon(Avatar a) {
    return abs(x - a.centroX()) < (w / 2 + a.hitAncho / 2)
        && abs(y - a.centroY()) < (h / 2 + a.hitAlto / 2);
  }

  boolean salioDePantalla() {
    return (vx > 0 && x - w / 2 > GW) || (vx < 0 && x + w / 2 < 0);
  }

  int colorBase() {
    if (tipo == MSG_NEGATIVO) return color(225, 60, 60);
    if (tipo == MSG_POSITIVO) return color(50, 185, 90);
    return color(150, 150, 160);
  }

  String simbolo() {
    if (tipo == MSG_NEGATIVO) return "!";
    if (tipo == MSG_POSITIVO) return "+";
    return "?";
  }
}
