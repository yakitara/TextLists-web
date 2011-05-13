link.png:
  http://commons.wikimedia.org/wiki/File:Icon_External_Link.png

as_available_appstore_icon_20091006.png:
  https://developer.apple.com/appstore/resources/marketing/
  https://developer.apple.com/appstore/images/as_available_appstore_icon_20091006.png


http://dl.dropbox.com/u/348426/processing_png.html

close_circle.png:
/* @pjs transparent=true; */
void setup() {
  int m = 5.2; // mergin
  int s = 14; // size
  size(s, s);
  background(0, 0, 0, 0);

  stroke(200);
  fill(200);
  ellipse(s/2, s/2, s-2, s-2);

  strokeWeight(1.5);
  stroke(100);
  line(m, m, s - m, s - m);
  line(s - m, m, m, s - m);
}

label.png:
/* @pjs transparent=true; */
void setup() {
  int m = 5.2; // mergin
  int s = 16; // size
  size(s, s);
  background(0, 0, 0, 0);

  int [][] points = [[0, 1/2], [1/4, 1/4], [1, 1/4], [1, 3/4], [1/4, 3/4]];
  int i;
  stroke(255, 150,0);
  fill(255, 200, 0);
  beginShape();
  for (i=0; i< points.length; i++) {
    vertex(s*points[i][0], s*points[i][1]);
  }
  vertex(s*points[0][0], s*points[0][1]);
  endShape();
  // hole
  fill(255, 0, 0, 0);
  stroke(255, 0, 0);
  ellipse(s/5, s/2, s/16, s/16);
}
      
