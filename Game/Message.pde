// ==========================================
// CLASE MESSAGE (Burbujas de Diálogo / Proyectiles)
// ==========================================
class Message {
  float x, y;
  float vx, vy; 
  float speed = 3.5;
  int type; // 0: Intrigante (Lento), 1: Curación (Verde), 2: Gemelo de Datos (Pequeño y Rápido)
  boolean activo = true; 
  
  Message(float startX, float startY, int type, float targetX, float targetY) {
    this.x = startX;
    this.y = startY;
    this.type = type;
    
    // Asignar velocidad según el emisor
    if (type == 0) {
      speed = 2.2; // 🐢 Más lento (Intrigante)
    } else if (type == 2) {
      speed = 4.8; // ⚡ Más rápido (Gemelo de Datos)
    } else {
      speed = 3.5; // Estándar / Curación
    }
    
    float angle = atan2(targetY - startY, targetX - startX);
    this.vx = cos(angle) * speed;
    this.vy = sin(angle) * speed;
  }
  
  void move() {
    x += vx;
    y += vy;
    
    if (x < -50 || x > width + 50 || y < -50 || y > height + 50) {
      activo = false;
    }
  }
  
  void draw() {
    if (!activo) return;
    noStroke();
    
    if (type == 1) { 
      // 💚 Mensaje Positivo (Corazón Verde)
      fill(180, 220, 190);
      rect(x - 17, y - 12, 34, 22, 5);
      rect(x - 14, y + 10, 6, 6);
      rect(x - 11, y + 14, 4, 4);

      fill(255);
      rect(x - 15, y - 10, 30, 18, 4);
      rect(x - 12, y + 8, 4, 4);
      rect(x - 10, y + 12, 2, 3);

      fill(46, 204, 113);
      rect(x - 4, y - 4, 3, 3);
      rect(x + 1, y - 4, 3, 3);
      rect(x - 5, y - 2, 10, 4);
      triangle(x - 5, y + 2, x + 5, y + 2, x, y + 6);
    } 
    else if (type == 2) {
      // 🤖 Mensaje del Gemelo de Datos (Más pequeño y compacto)
      fill(50, 80, 100);
      rect(x - 11, y - 8, 22, 14, 3);
      rect(x - 9, y + 6, 4, 4);

      fill(100, 149, 237);
      rect(x - 10, y - 7, 20, 12, 2);
      
      // Mini calavera o cara triste digital
      fill(255, 100, 100);
      rect(x - 3, y - 4, 6, 4);
    }
    else {
      // 💀 Mensaje Negativo Estándar (La Intrigante)
      fill(80, 10, 10);
      rect(x - 17, y - 12, 34, 22, 5);
      rect(x - 14, y + 10, 6, 6); 
      rect(x - 11, y + 14, 4, 4); 

      fill(140, 25, 25);
      rect(x - 15, y - 10, 30, 18, 4);
      rect(x - 12, y + 8, 4, 4);
      rect(x - 10, y + 12, 2, 3);

      fill(255);
      rect(x - 4, y - 5, 8, 7);
      rect(x - 3, y + 2, 6, 3);
      
      fill(60, 0, 0);
      rect(x - 3, y - 3, 2, 3); 
      rect(x + 1, y - 3, 2, 3); 
      rect(x - 0.5, y + 1, 1, 1); 
    }
  }
  
  boolean checkCollision() {
    float centroJugadorX = posX + charAnchoCentro;
    float centroJugadorY = posY + charAlturaVisual - 20;
    
    float radioChoque = (type == 2) ? 25 : 35; // Los del gemelo son más chicos
    if (dist(x, y, centroJugadorX, centroJugadorY) < radioChoque) {
      return true;
    }
    return false;
  }
}
