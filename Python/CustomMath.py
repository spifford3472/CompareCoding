import cmath

class CustomMath:
    """Customized polygon math to detect collisions between objects.

    Code for checking if a given point lies inside or outside a polygon was found at
    https://www.linkedin.com/pulse/short-formula-check-given-point-lies-inside-outside-polygon-ziemecki
    It was written by Andres Ziemecki in article published on 26-Sept-2021
    The code was built using concepts about
        * Complex Numbers
        * Line Integrals
        * Cauchy's Theorem
    More Information available at: https://math.mit.edu/~jorloff/18.04/notes/topic3.pdf

    Attributes:
        No public attributes for use
    """    

    def __init__(self,vertices):
        """
        __init__ Constructs the necessary attributes for the class  

        :param vertices: Contains a list of points in the form (x,y) that form the verticies of a polygon
        :type vertices: list
        """    
        self._polygon_verticies = vertices

    def _is_P_InSegment_P0P1(self,P, P0,P1):
        """
        _is_P_InSegment_P0P1 Determine if point is in the current polygon segment

        :param P: Point to check
        :type P: tuple
        :param P0: a vertice of the polygon
        :type P0: object (int, int)
        :param P1: an adjacent vertice of the polygon
        :type P1: object (int, int)
        :return: valid border as the point is on the border of the polygon
        :rtype: boolean
        """        
        p0 = P0[0]- P[0], P0[1]- P[1]
        p1 = P1[0]- P[0], P1[1]- P[1]
        det = (p0[0]*p1[1] - p1[0]*p0[1])
        prod = (p0[0]*p1[0] + p0[1]*p1[1])
        return (det == 0 and prod < 0) or (p0[0] == 0 and p0[1] == 0) or (p1[0] == 0 and p1[1] == 0)

    def isInsidePolygon(self, P: tuple, validBorder=False) -> bool:
        """
        isInsidePolygon Determines if a point is inside a polygon

        :param P: Point to check against the polygon
        :type P: tuple
        :param validBorder: Boolean to define if a point on the border should be true or false, defaults to False
        :type validBorder: bool, optional
        :return: True if point is in the polygon
        :rtype: bool
        """        
        sum_ = complex(0,0)
        for i in range(1, len(self._polygon_verticies) + 1):
            v0, v1 = self._polygon_verticies[i-1] , self._polygon_verticies[i%len(self._polygon_verticies)]
            if self._is_P_InSegment_P0P1(P,v0,v1):
                return validBorder
            sum_ += cmath.log( (complex(*v1) - complex(*P)) / (complex(*v0) - complex(*P)) )
        return abs(sum_) > 1
    
