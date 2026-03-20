// evaluation of Bessel function of the second kind
#include <math.h>
#include <stdlib.h>
#include "sampler.h"
#include "ctrpoint.h"

double bessy(double x, double n)
{
CTRPOINT(1);
	const double small	= 1.0E-8;
	const double euler	= 0.57721566;
	const double pi     = 3.1415926;
	const double pi2	= 0.63661977;	// 2/pi
	int j;
	double x2,sum,t,
		ts,term,xx,y0,y1,
		ya,yb,yc,ans;
  double result = 0;
  if (x < 12) {
      xx = 0.5*x;
      x2 = xx*xx;
      t = log(xx)+euler;
      sum = 0.0;
      term = t;
      j = 1;
      ts = t-sum;
      term = -x2*term/(j*j)*(1-1.0/(j*ts));
      y0 = t+term;
      while (fabs(term)>=small) {
         sum += 1.0/j;
         j++;
         ts = t-sum;
         term = -x2*term/(j*j)*(1-1.0/(j*ts));
         y0 += term;
      };
      term = xx*(t-0.5);
      sum = 0.0;
      y1 = term;
      j = 1;
     do {
       sum += 1.0/j;
       j++;
       ts = t-sum;
       term = (-x2*term)/(j*(j-1))*((ts-0.5/j)/(ts+0.5/(j-1)));
       y1 += term;
    } while (fabs(term)>=small);
    y0 =pi2*y0;
    y1 =pi2*(y1-1.0/x);
    if (n == 0.0){
       ans = y0;
    }  else{
        if (n==1.0){
          ans = y1;
        } else {
          // find y by recursion }
          ts = 2.0/x;
          ya = y0;
          yb = y1;
          double n2 = 0;
          for (j=1; j <= n2 -1; j++) {
            yc = ts*j*yb-ya;
            ya = yb;
            yb = yc;
            n2 = floor(n+0.01);
          }
          ans = yc;
        }
    }
    result = ans;
  }		// x<12
  else{
		// x>11, asymtotic expansion
      result = sqrt(2.0/(pi*x))*sin(x-pi/4-n*pi/2);
  }
  CTRPOINT(3);
  CTRPOINT(2);
  return result;
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