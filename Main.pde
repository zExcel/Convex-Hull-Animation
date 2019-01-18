Polygon f;
int numPoints = 20;
Vector<Vertex> CH;
int amount = 20;

void settings()
{
    size(1080, 720);
}

void setup()
{
    
    f = new Polygon(numPoints);
    
    for(int i = 0; i < numPoints; i++)
    {
        f.addVertex(random(amount, width - amount), random(amount, height - amount));
    }
    
    f.constructHull();
    CH = f.convexHull;
}

void draw()
{
    background(50);
    
    
    fill(255);
    for(int i = 0; i < numPoints; i++)
    {
        ellipse((float)f.vertices[i].x, (float)f.vertices[i].y, 10, 10);
    }
    
    if(CH != null)
    {
        beginShape();
        for(int i = 0; i < CH.size(); i++)
        {
            vertex((float)CH.get(i).x, (float)CH.get(i).y);
        }
        noFill();
        endShape(CLOSE);
        
        for(int i = 0; i < CH.size(); i++)
        {
            fill(color(255, 0, 0));
            ellipse((float)CH.get(i).x, (float)CH.get(i).y, 10, 10);
        }
    }
    
}

void mousePressed()
{
    if(mouseButton == LEFT)
    {
        f.constructHull();
        CH = f.convexHull;
    }
}

void keyPressed()
{
    if(key == 'r' || key == 'R')
    {
        f = new Polygon(numPoints);
        for(int i = 0; i < numPoints; i++)
        {
            f.addVertex(random(amount, width - amount), random(amount, height - amount));
        }
        CH = null;
    }
    
    if(key == '+' || key == '=')
    {
        numPoints+=10;
        f = new Polygon(numPoints);
        for(int i = 0; i < numPoints; i++)
        {
            f.addVertex(random(amount, width - amount), random(amount, height - amount));
        }
        CH = null;
    }
    if(key == '-' || key == '_')
    {
        numPoints-=10;
        numPoints = Math.max(0, numPoints);
        f = new Polygon(numPoints);
        for(int i = 0; i < numPoints; i++)
        {
            f.addVertex(random(amount, width - amount), random(amount, height - amount));
        }
        CH = null;
    }
    if(key == 'a' || key == 'A')
    {
        if(mouseX > 0 && mouseX < width && mouseY > 0 && mouseY < height)
        {
            f.addVertex(mouseX, mouseY);
            numPoints++;
        }
    }
}