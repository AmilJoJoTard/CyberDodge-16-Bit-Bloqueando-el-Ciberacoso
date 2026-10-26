class Message {
  float x, y;
  float speed = 3.5;
  int type; // 0: Negativo (Rojo), 1: Positivo (Verde), 2: Neutral (Gris)
  
  Message(float x, float y, int type) {
    this.x = x;
    this.y = y;
    this.type = type;
  }
  
  void move() {
    y += speed;
  }
  
  void draw() {
    if (type == 0) stroke(255, 50, 50);       // Rojo
    else if (type == 1) stroke(50, 255, 50);  // Verde
    else stroke(180);                         // Gris
    
    fill(255);
    strokeWeight(3);
    rect(x, y, 70, 30, 6);
    
    fill(0);
    textSize(11);
    textAlign(CENTER, CENTER);
    if (type == 0) text("Ataque", x + 35, y + 15);
    else if (type == 1) text("+Apoyo", x + 35, y + 15);
    else text("Meme", x + 35, y + 15);
  }
  
  boolean checkCollision(Avatar p) {
    return (x > p.x - 40 && x < p.x + 40 && y > p.y - 40 && y < p.y + 40);
  }
}
