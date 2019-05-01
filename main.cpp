//
//  main.cpp
//  IE523_Final_Continuous
//
//  Created by Tianhao Zhao on 12/13/18.
//  Copyright © 2018 Tianhao Zhao. All rights reserved.
//

#include <iostream>
#include <iomanip>
#include <cmath>
#include <fstream>
#include <cstdlib>
#include <random>
#include "normdist.h"
#include <math.h>
#include <chrono>

#define pi 3.141592653589793
using namespace std;

double risk_free_rate, strike_price, barrier_price, initial_stock_price;
double expiration_time, volatility;
double adjusted_call_price, adjusted_put_price;
int no_of_divisions, no_of_trials;
double call, put;

unsigned seed = (unsigned)std::chrono::system_clock::now().time_since_epoch().count();
std::default_random_engine generator (seed);

double max(double a, double b) {
    return (b < a) ? a : b;
}

double get_uniform()
{
    std::uniform_real_distribution<double>distribution(0.0, 1.0);
    double number = distribution(generator);
    return (number);
}

void european_down_and_out_option_continous() {

    int k;
    double delta_T = expiration_time / ((double)no_of_divisions);
    double delta_R = (risk_free_rate - 0.5*pow(volatility, 2))*delta_T;
    double delta_SD = volatility*sqrt(delta_T);
    
    double S1 = initial_stock_price;
    double S2 = initial_stock_price;
    double S3 = initial_stock_price;
    double S4 = initial_stock_price;
    int valid1 = 1; int valid2 = 1; int valid3 = 1; int valid4 = 1;
    
    for (k = 1; k <= no_of_divisions; k++) {
        double x = get_uniform();
        double y = get_uniform();
        double a = sqrt(-2.0*log(x)) * cos(2*pi*y);
        double b = sqrt(-2.0*log(x)) * sin(2*pi*y);
        if (S1 <= barrier_price) {
            valid1 = 0;
        }
        else {
            S1 = S1*exp(delta_R + delta_SD*a);
        }
        if (S2 <= barrier_price) {
            valid2 = 0;
        }
        else {
            S2 = S2*exp(delta_R - delta_SD*a);
        }
        if (S3 <= barrier_price) {
            valid3 = 0;
        }
        else {
            S3 = S3*exp(delta_R + delta_SD*b);
        }
        if (S4 <= barrier_price) {
            valid4 = 0;
        }
        else {
            S4 = S4*exp(delta_R - delta_SD*b);
        }
    }
    call = (max(0.0, S1 - strike_price)*valid1 + max(0.0, S2 - strike_price)*valid2
            + max(0.0, S3 - strike_price)*valid3 + max(0.0, S4 - strike_price)*valid4) / 4.0;
    put = (max(0.0, strike_price - S1)*valid1 + max(0.0, strike_price - S2)*valid2
           + max(0.0, strike_price - S3)*valid3 + max(0.0, strike_price - S4)*valid4) / 4.0;
    
}

void simulation_adjusted() {
    double PC1, PC2, PC3, PC4;
    double R = (risk_free_rate - 0.5*volatility*volatility)*expiration_time;
    double SD = volatility*sqrt(expiration_time);
    double S1 = initial_stock_price;
    double S2 = initial_stock_price;
    double S3 = initial_stock_price;
    double S4 = initial_stock_price;
    double x = get_uniform();
    double y = get_uniform();
    double a = sqrt(-2.0*log(x)) * cos(2*pi*y);
    double b = sqrt(-2.0*log(x)) * sin(2*pi*y);
    S1 = S1*exp(R + SD*a);
    if (initial_stock_price <= barrier_price || S1 <= barrier_price) {
        PC1 = 1;
    }
    else {
        PC1 = exp(-(2 * log(initial_stock_price / ((double)barrier_price))*log(S1 / ((double)barrier_price))) / (expiration_time*pow(volatility, 2)));
    }
    S2 = S2*exp(R - SD*a);
    if (initial_stock_price <= barrier_price || S2 <= barrier_price) {
        PC2 = 1;
    }
    else {
        PC2 = exp(-(2 * log(initial_stock_price / ((double)barrier_price))*log(S2 / ((double)barrier_price))) / (expiration_time*pow(volatility, 2)));
    }
    S3 = S3*exp(R + SD*b);
    if (initial_stock_price <= barrier_price || S3 <= barrier_price) {
        PC3 = 1;
    }
    else {
        PC3 = exp(-(2 * log(initial_stock_price / ((double)barrier_price))*log(S3 / ((double)barrier_price))) / (expiration_time*pow(volatility, 2)));
    }
    S4 = S4*exp(R - SD*b);
    if (initial_stock_price <= barrier_price || S4 <= barrier_price) {
        PC4 = 1;
    }
    else {
        PC4 = exp(-(2 * log(initial_stock_price / ((double)barrier_price))*log(S4 / ((double)barrier_price))) / (expiration_time*pow(volatility, 2)));
    }
    
    adjusted_call_price = (max(0.0, S1 - strike_price)*(1 - PC1) + max(0.0, S2 - strike_price)*(1 - PC2) +
                           max(0.0, S3 - strike_price)*(1 - PC3) + max(0.0, S4 - strike_price)*(1 - PC4)) / 4.0;
    adjusted_put_price = (max(0.0, strike_price - S1)*(1 - PC1) + max(0.0, strike_price - S2)*(1 - PC2) +
                          max(0.0, strike_price - S3)*(1 - PC3) + max(0.0, strike_price - S4)*(1 - PC4)) / 4.0;
}


double option_price_put_black_scholes(const double& S,      // This is the spot price
                                      const double& K,      // This is the Strike price,
                                      const double& r,      // This is the interest rate
                                      const double& sigma,  // This is the volatility
                                      const double& time)
{
    double time_sqrt = sqrt(time);
    double d1 = (log(S / K) + r*time) / (sigma*time_sqrt) + 0.5*sigma*time_sqrt;
    double d2 = d1 - (sigma*time_sqrt);
    return K*exp(-r*time)*N(-d2) - S*N(-d1);
}

double option_price_call_black_scholes(const double& S,       // This is the spot price
                                       const double& K,       // This is the strike price,
                                       const double& r,       // This is the interest rate
                                       const double& sigma,   // This is the volatility
                                       const double& time)      // This is the time to maturity
{
    double time_sqrt = sqrt(time);
    double d1 = (log(S / K) + r*time) / (sigma*time_sqrt) + 0.5*sigma*time_sqrt;
    double d2 = d1 - (sigma*time_sqrt);
    return S*N(d1) - K*exp(-r*time)*N(d2);
}

double N(const double& z) {
    if (z > 6.0) { return 1.0; }; // this guards against overflow
    if (z < -6.0) { return 0.0; };
    double b1 = 0.31938153;
    double b2 = -0.356563782;
    double b3 = 1.781477937;
    double b4 = -1.821255978;
    double b5 = 1.330274429;
    double p = 0.2316419;
    double c2 = 0.3989423;
    double a = fabs(z);
    double t = 1.0 / (1.0 + a*p);
    double b = c2*exp((-z)*(z / 2.0));
    double n = ((((b5*t + b4)*t + b3)*t + b2)*t + b1)*t;
    n = 1.0 - b*n;
    if (z < 0.0) n = 1.0 - n;
    return n;
}

double closed_form_down_and_out_european_call_option()
{
    double K = (2 * risk_free_rate) / (volatility*volatility);
    double A = option_price_call_black_scholes(initial_stock_price, strike_price,
                                               risk_free_rate, volatility, expiration_time);
    double B = (barrier_price*barrier_price) / initial_stock_price;
    double C = pow(initial_stock_price / barrier_price, -(K - 1));
    double D = option_price_call_black_scholes(B, strike_price, risk_free_rate, volatility, expiration_time);
    return (A - D*C);
}

double closed_form_down_and_in_european_put_option()
{
    double S = initial_stock_price;
    double r = risk_free_rate;
    double T = expiration_time;
    double sigma = volatility;
    double H = barrier_price;
    double X = strike_price;
    
    double lambda = (r + ((sigma*sigma) / 2)) / (sigma*sigma);
    double temp = 2 * lambda - 2.0;
    double x1 = (log(S / H) / (sigma*sqrt(T))) + (lambda*sigma*sqrt(T));
    double y = (log(H*H / (S*X)) / (sigma*sqrt(T))) + (lambda*sigma*sqrt(T));
    double y1 = (log(H / S) / (sigma*sqrt(T))) + (lambda*sigma*sqrt(T));
    return (-S*N(-x1) + X*exp(-r*T)*N(-x1 + sigma*sqrt(T)) +
            S*pow(H / S, 2 * lambda)*(N(y) - N(y1)) -
            X*exp(-r*T)*pow(H / S, temp)*(N(y - sigma*sqrt(T)) - N(y1 - sigma*sqrt(T))));
}

double closed_form_down_and_out_european_put_option()
{
    double vanilla_put = option_price_put_black_scholes(initial_stock_price, strike_price,
                                                        risk_free_rate, volatility, expiration_time);
    double put_down_in = closed_form_down_and_in_european_put_option();
    return (vanilla_put - put_down_in);
}


int main(int argc, char* argv[])
{
    
    sscanf (argv[1], "%lf", &expiration_time);
    sscanf (argv[2], "%lf", &risk_free_rate);
    sscanf (argv[3], "%lf", &volatility);
    sscanf (argv[4], "%lf", &initial_stock_price);
    sscanf (argv[5], "%lf", &strike_price);
    sscanf (argv[6], "%d", &no_of_trials);
    sscanf (argv[7], "%d", &no_of_divisions);
    sscanf (argv[8], "%lf", &barrier_price);
    
    double continous_call_option = 0.0;
    double continous_put_option = 0.0;
    double call_option_price = 0.0;
    double put_option_price = 0.0;
    
    for (int i = 0; i < no_of_trials; i++) {
        european_down_and_out_option_continous();
        simulation_adjusted();
        
        continous_call_option = continous_call_option + call;
        continous_put_option = continous_put_option + put;
        call_option_price = call_option_price + adjusted_call_price;
        put_option_price = put_option_price + adjusted_put_price;
    }
    
    call_option_price =     exp(-risk_free_rate*expiration_time)*(call_option_price / ((double)no_of_trials));
    put_option_price =      exp(-risk_free_rate*expiration_time)*(put_option_price / ((double)no_of_trials));
    continous_call_option = exp(-risk_free_rate*expiration_time)*(continous_call_option / ((double)no_of_trials));
    continous_put_option =  exp(-risk_free_rate*expiration_time)*(continous_put_option / ((double)no_of_trials));
    
    cout << "--------------------------------------" << endl;
    cout << "European Down and Out Continuous Barrier Option Pricing via Monte Carlo Simulation" << endl;
    cout << "Expiration Time (Years) = " << expiration_time << endl;
    cout << "Risk Free Interest Rate = " << risk_free_rate << endl;
    cout << "Volatility (%age of stock value) = " << volatility * 100 << endl;
    cout << "Initial Stock Price = " << initial_stock_price << endl;
    cout << "Strike Price = " << strike_price << endl;
    cout << "Barrier Price = " << barrier_price << endl;
    cout << "Number of Trials = " << no_of_trials << endl;
    cout << "Number of Divisions = " << no_of_divisions << endl;
    cout << "--------------------------------------" << endl;
    cout << "--------------------------------------" << endl;
    cout << "The average Call Price by explicit simulation  =    " << continous_call_option << endl;
    cout << "The call Price Using the (1-p)-Adjustment Term =    " << call_option_price << endl;
    cout << "Theoretical Call Price =                            " << closed_form_down_and_out_european_call_option() << endl;
    cout << "--------------------------------------" << endl;
    cout << " " << endl;
    cout << "The average Put Price by Explicit Simulation   =   " << continous_put_option << endl;
    cout << "The put Price Using the (1-p)-Adjustment Term  =   " << put_option_price << endl;
    cout << "Theoretical Put Price =                            " << closed_form_down_and_out_european_put_option() << endl;
    cout << "--------------------------------------" << endl;
    cout << endl;
    return 0;
}
