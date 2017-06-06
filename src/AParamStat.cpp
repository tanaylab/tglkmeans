#include "AParamStat.h"
#include "Ranking.h"
#include "IndirectSort.h"

float spearman(const vector<float> &v1, const vector<float> &v2,
				vector<float> &rank1, vector<float> &rank2,
				double &pv)
{
	list<int> ids;
	int max_i = v1.size();
	for(int i = 0; i < max_i; i++) {
		ids.push_back(i);
	}
	ids.sort<IndirectSort<float> >(IndirectSort<float>(v1));
	rank1.resize(v1.size());
	cond_mid_ranking(rank1, ids, v1, v2);
	ids.sort<IndirectSort<float> >(IndirectSort<float>(v2));
	rank2.resize(v2.size());
	cond_mid_ranking(rank2, ids, v2, v1);

	vector<float>::iterator r1 = rank1.begin();
	vector<float>::iterator r2 = rank2.begin();
	vector<float>::iterator max_r1 = rank1.end();

	int num = 0;
	float cov = 0;
	float e1 = 0; float e2 = 0;
	float var1 = 0; float var2 = 0;

	while(r1 != max_r1) {
		if(*r1 != -REAL_MAX) {
//			Rcpp::Rcout << "r1 r2 " << *r1 << " " << *r2 << endl;
			cov += (*r1) * (*r2);

			e1 += (*r1);
			e2 += (*r2);
			var1 += (*r1)*(*r1);
			var2 += (*r2)*(*r2);
			num++;
		}
		r1++;
		r2++;
	}

	if(num == 0) {
		pv = 1;
		return(0);
	}

	e1 /= num;
	e2 /= num;
	var1 = var1/num - e1*e1;
	var2 = var2/num - e2*e2;
	
	if(var1 <= 0 || var2 <= 0) {
		pv = 1;
		return(0);
	}

	float cor = ((cov/num) - e1*e2)/sqrt(var1*var2);
	if(num < 9) {
		pv = 1;
		return(cor);
	}

	float fac = (1.0 + cor)*(1.0 - cor);
	float t = cor * sqrt((num - 2.0)/fac);
	float df = num - 2.0;
	pv = betai(0.5 * df, 0.5, df/(df+t*t));
//	Rcpp::Rcout << "num " << num << " cor " << cor << " pv " << pv << endl;
	return(cor);
}

float corr_pv(float cor, int num) 
{
	float fac = (1.0 + cor)*(1.0 - cor);
	float t = cor * sqrt((num - 2.0)/fac);
	float df = num - 2.0;
	float pv = betai(0.5 * df, 0.5, df/(df+t*t));
	return(pv);
//	Rcpp::Rcout << "num " << num << " cor " << cor << " pv " << pv << endl;
	
}


//Used by betai: Evaluates continued fraction for incomplete beta function by
//modified Lentz's method ( x 5.2).

double betacf(double a, double b, double x){
    double MAXIT=100;
    double EPS=3.0e-7;
    double FPMIN=1.0e-20;

    int m = 0;
    int m2 = 0;
    double aa,c,d,del,h,qab,qam,qap;
    qab=a+b; 		//These q's will be used in factors that occur
    //in the coefficients (6.4.6).
    qap=a+1.0;
    qam=a-1.0;
    c=1.0; 			//First step of Lentz's method.
    d=1.0-qab*x/qap;
    if (fabs(d) < FPMIN)
        d=FPMIN;

    d=1.0/d;
    h=d;
    for (m=1;m<=MAXIT;m++) {
        m2=2*m;
        aa=m*(b-m)*x/((qam+m2)*(a+m2));
        d=1.0+aa*d; //One step (the even one) of the recurrence.
        if (fabs(d) < FPMIN)
            d=FPMIN;
        c=1.0+aa/c;
        if (fabs(c) < FPMIN)
            c=FPMIN;
        d=1.0/d;
        h *= d*c;
        aa = -(a+m)*(qab+m)*x/((a+m2)*(qap+m2));
        d=1.0+aa*d; //Next step of the recurrence (the odd one).
        if (fabs(d) < FPMIN)
            d=FPMIN;
        c=1.0+aa/c;
        if (fabs(c) < FPMIN)
            c=FPMIN;
        d=1.0/d;
        del=d*c;
        h *= del;
        if (fabs(del-1.0) < EPS)
            break; 	//Are we done?
    }
    if (m > MAXIT)  {
        Rcpp::Rcout << "a " << a << " or b " << b << " too big, or MAXIT too small in betacf, x = " << x << endl;
    }
    return h;
}

double dbl_gamma_ln(float xx)
{
    double x, y, tmp, ser;

    static double cof[6] = {
            76.18009172947146,
            -86.50532032941677,
            24.01409824083091,
            -1.231739572450155,
            0.1208650973866179e-2,
            -0.5395239384953e-5};

    y = x = xx;

    tmp = x+5.5;
    tmp -= (x+0.5) * log(tmp);
    ser = 1.000000000190015;
    for(int j = 0; j <= 5; j++) {
        ser += cof[j]/++y;
    }
    return(-tmp+log(2.5066282746310005 * ser/x));
}

//Returns the incomplete beta function I x (a; b).

double betai(double a, double b, double x)
{
    double bt;
    if(x < 0.0 || x > 1.0) {
        Rcpp::Rcout << "Bad x " << x<< " in routine betai";
        return(-1);
    }
    if(x == 0.0 || x == 1.0) {
        bt=0.0;
    } else {	//Factors in front of the continued fraction.
        bt=exp(dbl_gamma_ln(a+b)-dbl_gamma_ln(a)-dbl_gamma_ln(b)+a*log(x)+b*log(1.0-x));
    }
    if(x < (a+1.0)/(a+b+2.0)) { //Use continued fraction directly.
        return bt*betacf(a,b,x)/a;
    } else {	//Use continued fraction after making the
        //symmetry transformation.
        return 1.0-bt*betacf(b,a,1.0-x)/b;
    }
}

