import java.util.*;

class Pair<A, B>
{
    public A first;
    public B second;
    
    Pair(A first, B second)
    {
        this.first = first;
        this.second = second;
    }
}

class Vertex
{
    double x, y;
    
    Vertex(double x, double y)
    {
        this.x = x;
        this.y = y;
    }
    
    Vertex(Vertex o)
    {
        this.x = o.x;
        this.y = o.y;
    }
}

class vector
{
    double x, y;
    
    // Vector that points from a -> b
    vector(Vertex a, Vertex b)
    {
        x = b.x - a.x;
        y = b.y - a.y;
    }
    
    vector(double x, double y)
    {
        this.x = x;
        this.y = y;
    }
    
    // calculates determinant (signed area) of 2x2 matrix [this, o] where 
    // the column vectors this and o are put into a matrix. 
    // Is negative when the transformation matrix flips 
    // the orientation of the vectors.
    public double calcuateArea(vector o)
    {
        if(o == null)
        {
            return 0;
        }
        
        return x * o.y - y * o.x;
    }
}

class Line
{
    // Angle assumes that a vertical line is drawn at the first
    // endpoint and calculates the angle. Straight down is angle 0
    // and increases counter clockwise. 
    // Distance is also how far the first endpoint is from the second.
    public double distance, angle;
    public Vertex end1,end2;
    public double m, b;
    public boolean isOuter = false;
    public boolean isCH = false;
    
    Line(Vertex end1, Vertex end2)
    {
        this.end1 = new Vertex(end1);
        this.end2 = new Vertex(end2);
        if(end1.x == end2.x)
        {
            m = Double.NaN;
            b = 0;
        }
        else
        {
            m = (end1.y - end2.y) / (end1.x - end2.x);
            b = end1.y - m * end1.x;
        }
        distance = Math.pow(end1.x - end2.x, 2) + Math.pow(end1.y - end2.y, 2);
        angle = Math.atan2(-1 * (end1.y - end2.y), end2.x - end1.x);
    }
    
    
    private boolean Contained(double point, double min, double max)
    {
        if(min >= max)
        {
            double temp = max;
            max = min;
            min = temp;
        }
        if(point >= min && point <= max)
        {
            return true;
        }
        return false;
    }
    
    public Pair<Double, Double> Intersects(Line o)
    {
        if(Double.isNaN(m) && Double.isNaN(o.m))
        {
            if(end1.x == o.end1.x && (Contained(end1.y, o.end1.y, o.end2.y)
            || Contained(end2.y, o.end1.y, o.end2.y)))
            {
                return new Pair<Double,Double>(end1.x, end1.y);
            }
            return null;
        }
        else if(Double.isNaN(m))
        {
            double y = o.m * end1.x + o.b;
            // System.out.println(y);
            if(Contained(end1.x, o.end1.x, o.end2.x) && 
                Contained(y, o.end1.y, o.end2.y) && Contained(y, end1.y, end2.y))
            {
                return new Pair<Double,Double>(end1.x, y);
            }
            return null;
        }
        else if(Double.isNaN(o.m))
        {
            double y = m * o.end1.x + b;
            if(Contained(o.end1.x, end1.x, end2.x) && 
                Contained(y, end1.y, end2.y) && Contained(y, o.end1.y, o.end2.y))
            {
                return new Pair<Double, Double>(o.end1.x, y);
            }
            return null;
        }
        else if(o.m == m)
        {
            if(b == o.b)
            {
                if((Contained(end1.y, o.end1.y, o.end2.y) || 
                Contained(end2.y, o.end1.y, o.end2.y)))
                {
                    return new Pair<Double, Double>(o.end2.x, o.end2.y);
                }
                return null;
            }
            return null;
        }
        else
        {
            double x = (o.b - b) / (m - o.m);
            double y = m * x + b;
            // System.out.println(x + " " + y);
            if(Contained(x, end1.x, end2.x) && Contained(y, end1.y, end2.y)
            && Contained(x, o.end1.x, o.end2.x) && Contained(y, o.end1.y, o.end2.y))
            {
                return new Pair<Double, Double>(x, y);
            }
            return null;
        }
    }
    
    public Pair<Double, Double> Intersects(Vertex a, Vertex b)
    {
        Line temp = new Line(a, b);
        return this.Intersects(temp);
    }
}

class SortByAngle implements Comparator<Line>
{
    public int compare(final Line left, final Line right)
    {
        if(left.angle < right.angle)
        {
            return -1;
        }
        else if(left.angle == right.angle)
        {
            if(left.distance < right.distance)
            {
                return -1;
            }
            return 1;
        }
        return 1;
    }
}

class Polygon
{
    public double minHeight;
    public int n;
    public int index = 0;
    public int leftMostIndex = 0;
    public Vertex vertices[];
    public Vector<Vertex> convexHull;
    boolean isConcave[];
    
    private void printStack(Stack<Vertex> S)
    {
        Stack<Vertex> temp = new Stack<Vertex>();
        while(S.size() > 0)
        {
            Vertex t = S.pop();
            System.out.println(t.x + " " + t.y);
            temp.push(t);
        }
        
        while(temp.size() > 0)
        {
            Vertex t = temp.pop();
            S.push(t);
        }
    }
    
    Polygon(int n)
    {
        minHeight = Double.MAX_VALUE;
        this.n = n;
        vertices = new Vertex[n];
        isConcave = new boolean[n];
        convexHull = new Vector<Vertex>();
    }
    
    public int getN()
    {
        return n;
    }
    
    public void constructHull()
    {
        if(n <= 1)
        {
            return;
        }
        convexHull = new Vector<Vertex>();
        Line []angles = new Line[n - 1];
        int index = 0;
        Vertex leftMost = this.getVertex(leftMostIndex);
        for(int i = 0; i < n; i++)
        {
            if(i == leftMostIndex)
            {
                continue;
            }
            Line current = new Line(leftMost, this.getVertex(i));
            angles[index] = current;
            index++;
        }
        Arrays.sort(angles, new SortByAngle());
        
        // We only want to look at vertices 
        // that aren't colinear with base point.
        Vector<Vertex> nonColVert = new Vector<Vertex>();
        for(int i = 0; i < n - 1; i++)
        {
            while(i < n - 2 && angles[i].angle == angles[i + 1].angle)
            {
                i++;
            }
            if(i == n - 1)
            {
                nonColVert.add(new Vertex(angles[n - 2].end2));
            }
            else
            {
                nonColVert.add(new Vertex(angles[i].end2));
            }
        }
        nonColVert.trimToSize();
        // for(int i = 0; i < nonColVert.size(); i++)
        // {
        //     System.out.println(nonColVert.get(i).x + " " + nonColVert.get(i).y);
        // }
        
        Stack<Vertex> CH = new Stack<Vertex>();
        CH.push(new Vertex(vertices[leftMostIndex]));
        CH.push(new Vertex(nonColVert.get(0)));
        
        Vertex check = nonColVert.get(0);
        vector current = new vector(vertices[leftMostIndex], check);
        
        for(int i = 1; i < nonColVert.size(); i++)
        {
            // System.out.println("i is : " + i);
            // printStack(CH);
            // System.out.println("\n");
            
            Vertex add = nonColVert.get(i);
            vector addition = new vector(check, add);
            double area = current.calcuateArea(addition);
            // System.out.println("area is : " + area);
            boolean entered = false;
            while(area < 0)
            {
                entered = true;
                check = CH.pop();
                if(CH.size() == 0)
                {
                    //CH.push(check);
                    area = 1;
                }
                else
                {
                    Vertex temp = CH.pop();
                    CH.push(temp);
                    current = new vector(temp, check);
                    addition = new vector(check, add);
                    area = current.calcuateArea(addition);
                }
            }
            if(entered)
            {
                CH.push(check);
            }
            CH.push(add);
            check = add;
            current = addition;
            // System.out.println("i is : " + i);
            // printStack(CH);
            // System.out.println("\n");
        }
        
        while(CH.size() > 0)
        {
            convexHull.add(0, CH.pop());
        }
        
        convexHull.trimToSize();
        // for(int i = 0; i < convexHull.size(); i++)
        // {
        //     Vertex temp = convexHull.get(i);
        //     System.out.println(temp.x + " " + temp.y);
        // }
        this.rotateHull(minHeight);
    }
    
    private void rotateHull(double minHeight)
    {
        int rotateAmount = -1;
        if(convexHull.get(0).y == minHeight && convexHull.get(convexHull.size() - 1).y == minHeight)
        {
            int index = convexHull.size() - 1;
            while(index > 0 && convexHull.get(index).y == minHeight)
            {
                index--;
            }
            rotateAmount = index + 1;
        }
        else
        {
            for(int i = 0; i < convexHull.size(); i++)
            {
                if(convexHull.get(i).y == minHeight)
                {
                    rotateAmount = i;
                    break;
                }
            }
        }
        rotateAmount = convexHull.size() - rotateAmount;
        Vertex tempVertices[] = new Vertex[convexHull.size()];
        for(int i = 0; i < convexHull.size(); i++)
        {
            int index = (i + rotateAmount) % convexHull.size();
            tempVertices[index] = convexHull.get(i);
        }
        
        for(int i = 0; i < convexHull.size(); i++)
        {
            convexHull.set(i, tempVertices[i]);
        //     System.out.println(convexHull.get(i).x + " " + convexHull.get(i).y);
        }
    }
    
    private void rotateVertices(double minHeight)
    {
        int rotateAmount = -1;
        if(vertices[0].y == minHeight && vertices[n - 1].y == minHeight)
        {
            int index = n - 1;
            while(index > 0 && vertices[index].y == minHeight)
            {
                index--;
            }
            rotateAmount = index + 1;
        }
        else
        {
            for(int i = 0; i < n; i++)
            {
                if(vertices[i].y == minHeight)
                {
                    rotateAmount = i;
                    break;
                }
            }
        }
        // System.out.println(rotateAmount);
        rotateAmount = n - rotateAmount;
        Vertex tempVertices[] = new Vertex[n];
        for(int i = 0; i < n; i++)
        {
            int index = (i + rotateAmount) % n;
            tempVertices[index] = vertices[i];
        }
        
        System.arraycopy(tempVertices, 0, vertices, 0, n);
        
        double smallestX = Double.MAX_VALUE;
        for(int i = 0; i < n; i++)
        {
            if(vertices[i].x < smallestX)
            {
                smallestX = vertices[i].x;
                leftMostIndex = i;
            }
        }
        // for(int i = 0; i < n; i++)
        // {
        //     System.out.println(vertices[i].x + " " + vertices[i].y);
        // }
        // System.out.println();
        // Scanner input = new Scanner(System.in);
        // input.nextInt();
    }
    
    public Vertex getVertex(int index)
    {
        if(index >= n)
        {
            index %= n;
        }
        else if(index < 0)
        {
            index %= n;
            index += n;
        }
        index %= n;
        return this.vertices[index];
    }
    
    public boolean getConcavity(int index)
    {
        if(index >= n)
        {
            index %= n;
        }
        else if(index < 0)
        {
            index %= n;
            index += n;
        }
        index %= n;
        return isConcave[index];
    }
    
    private void calculateAngles()
    {
        for(int i = 0; i < n; i++)
        {
            Vertex first = this.getVertex(i - 1);
            Vertex second = this.getVertex(i);
            Vertex third = this.getVertex(i + 1);
            vector a = new vector(second.x - first.x, second.y - first.y);
            vector b = new vector(third.x - second.x, third.y - second.y);
            double area = a.calcuateArea(b);
            if(area < 0)
            {
                isConcave[i] = true;
            }
            // System.out.println(i + " " + isConcave[i] + " " + area);
        }
    }
    
    public void addVertex(double x, double y)
    {
        if(y < minHeight)
        {
            minHeight = y;
        }
        if(index >= vertices.length)
        {
            n += 1;
            Vertex temp[] = new Vertex[n];
            boolean temp2[] = new boolean[n];
            System.arraycopy(isConcave, 0, temp2, 0, n - 1);
            System.arraycopy(vertices, 0, temp, 0, n - 1);
            vertices = temp;
            isConcave = temp2;
        }
        vertices[index] = new Vertex(x, y);
        index++;
        if(index == n)
        {
            this.rotateVertices(this.minHeight);
            this.calculateAngles();
        }
    }
}












//=================================================================