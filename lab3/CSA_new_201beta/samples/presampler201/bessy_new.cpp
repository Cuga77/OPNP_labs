// evaluation of Bessel function of the second kind
#include <math.h>
#include <stdlib.h>
#include "sampler.h"
#include "ctrpoint.h"

double bessy(double x, double n)
{
CTRPOINT(1);	const double small	= 1.0E-8;
	const double euler	= 0.57721566;
	const double pi     = 3.1415926;
	const double pi2	= 0.63661977;	// 2/pi
	int j;
	double x2,sum,t,
		ts,term,xx,y0,y1,
		ya,yb,yc,ans;
  double result = 0;
CTRPOINT(3);   if (x < 12) {
CTRPOINT(5);      xx = 0.5*x;
      x2 = xx*xx;
      t = log(xx)+euler;
      sum = 0.0;
      term = t;
      j = 1;
      ts = t-sum;
      term = -x2*term/(j*j)*(1-1.0/(j*ts));
      y0 = t+term;
CTRPOINT(9);	while (fabs(term)>=small) {
CTRPOINT(15);
	 sum += 1.0/j;
	 j++;
	 ts = t-sum;
	 term = -x2*term/(j*j)*(1-1.0/(j*ts));
	 y0 += term;

CTRPOINT(16);
}
CTRPOINT(10);
;
      term = xx*(t-0.5);
      sum = 0.0;
      y1 = term;
      j = 1;
CTRPOINT(11);      do {
CTRPOINT(17);
	 sum += 1.0/j;
	 j++;
	 ts = t-sum;
	 term = (-x2*term)/(j*(j-1))*((ts-0.5/j)/(ts+0.5/(j-1)));
	 y1 += term;

CTRPOINT(18);
} while (fabs(term)>=small);
CTRPOINT(12);
      y0 =pi2*y0;
      y1 =pi2*(y1-1.0/x);
CTRPOINT(13);      if (n == 0.0){
CTRPOINT(19);
         ans = y0;
CTRPOINT(20);
}
      else{
CTRPOINT(21); if (n==1.0){
CTRPOINT(23);
         ans = y1;
CTRPOINT(24);
}
      else {
CTRPOINT(25);      // find y by recursion }
	 ts = 2.0/x;
         ya = y0;
         yb = y1;
         double n2 = 0;
CTRPOINT(27);         for (j=1;
CTRPOINT(29),
 j <= n2 -1; j++) {
CTRPOINT(30);
            yc = ts*j*yb-ya;
            ya = yb;
            yb = yc;
            n2 = floor(n+0.01);

CTRPOINT(31);
}
CTRPOINT(28);
         ans = yc;

CTRPOINT(26);
}
CTRPOINT(22);
}
CTRPOINT(14);
      result = ans;

CTRPOINT(6);
}		// x<12
   else{
CTRPOINT(7);
		// x>11, asymtotic expansion
      result = sqrt(2.0/(pi*x))*sin(x-pi/4-n*pi/2);
CTRPOINT(8);
}
CTRPOINT(4);
   return result;
CTRPOINT(2);
}	// function bessy


void main()
{
  int iter = 1000;
  double maxX = 100.0;
  int maxOrdr = 5;
  for(int count = 0; count < iter; count++) {

    double curX = (rand()*1.0 / RAND_MAX)* maxX;
    double ordr  = random(maxOrdr)/1.0 ;

    bessy(curX,ordr);
  };
}