class Avatar {
  float x, y;
  int wellbeing = 100; // Vida / Salud emocional
  float speed = 7;
  
  Avatar(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void update() {
    if (keyPressed) {
      if (keyCode == LEFT || key == 'a' || key == 'A') x -= speed;
      if (keyCode == RIGHT || key == 'd' || key == 'D') x += speed;
    }
    x = constrain(x, 40, width - 40);
  }
  
  void draw() {
    fill(50, 150, 255);
    rectMode(CENTER);
    rect(x, y, 50, 60, 8); // Renderizado temporal hasta cargar el sprite real
    rectMode(CORNER);
  }
}
