/*
 *  alice_and_bob.h
 *  Loosing as little as possible
 *
 *  Created by Ramavarapu Sreenivas on 9/2/12.
 *  Copyright 2012 University of Illinois at Urbana-Champaign. All rights reserved.
 *
 */
#ifndef ALICE_AND_BOB
#define ALICE_AND_BOB

#include <cmath>
#include <fstream>
#include <vector>

using namespace std;

class I_have_nothing_apropos_for_this_class
{
private:
    double alice_probability, bob_probability;
    
    // private member function: uniform RV generator
    double get_uniform()
    {
        // write the appropriate code here
        return (((double) random())/(pow(2.0, 31.0)-1.0));
    }
    
    // private member function: nCi (i.e. n-take-i)
    long long int take(int n, int i) // the last few values in theoretical values is almost zero if I use int rather long long int. I asked a classmate
    {
        // write a **RECURSIVE** implementation of n-take-i.
        // If you made it non-recurisive (i.e. n!/((n-i)!i!)) -- it
        // will take too long for large size
        /*
        if(n==i){
            return 1;
        }
        if (i==0){
            return 1;
        }
        else{
            return (take(n-1, i-1) + take(n-1, i));
        }
        return 0;
        */
        // the above method took too long to run
        if (i == 0) {
            return 1;
        } else {
            return ((take(n, i - 1)*(n - i + 1)) / i); // With the help of a classmate
        }
        
    }
    
    // this routine implements the probability that Alice has more
    // heads than Bob after n-many coin tosses
    double theoretical_value(double q, double p, int n)
    {
        // implement equation 1.1 of Addona-Wagon-Wilf paper
        double f = 0.0;
        for (int i = 0; i < n; i++){
            for (int j = i+1; j<=n; j++){
                f += (take(n,i)*pow(p,i)*pow(1-p, n-i)*take(n,j)*pow(q,j)*pow(1-q,n-j)); // equations from the article 
            }
        }
        return f;
    }
    
public:
    // public function:
    void set_probability(double alice_p, double bob_p)
    {
        alice_probability = alice_p;
        bob_probability = bob_p;
    }
    
    // probability of Alice winning the game.
    double simulated_value(int number_of_coin_tosses_in_each_game, int no_of_trials)
    {
        int no_of_wins_for_alice = 0;
        for (int i = 0; i < no_of_trials; i++)
        {
            int number_of_heads_for_alice = 0;
            int number_of_heads_for_bob = 0;
            for (int j = 0; j < number_of_coin_tosses_in_each_game; j++)
            {
                if (get_uniform() < alice_probability)
                    number_of_heads_for_alice++;
                if (get_uniform() < bob_probability)
                    number_of_heads_for_bob++;
            }
            if (number_of_heads_for_alice > number_of_heads_for_bob)
                no_of_wins_for_alice++;
        }
        return (((double) no_of_wins_for_alice)/((double) no_of_trials));
    }
    
    int search_result()
    {
        // implememt a discrete-search procedure for the optimal n-value.
        // start with n = 1 and find the discrete-value of n that has
        // the largest probability for Alice winning.  Why would this work?
        // See Theorem 2.2 of the paper for the reason!
        int result = 0;
        for (int i = 1; i <= 100; i++) {
            if (((theoretical_value(alice_probability, bob_probability, i)) >= (theoretical_value(alice_probability, bob_probability, i - 1))) &&
                ((theoretical_value(alice_probability, bob_probability, i)) >= (theoretical_value(alice_probability, bob_probability, i + 1))))
            {
                result = i;
                break;
            }
        }
        return result;
    }
    
    void  output_file()
    {
        vector<double> sim;
        vector<double> theo;
        ofstream simulation;
        ofstream theoretical;
        
        for (int i = 0; i<50; i++){
            cout << i << endl; //used to check the progress of running
            sim.push_back(simulated_value(i, 500000));
            theo.push_back(theoretical_value(alice_probability, bob_probability, i));
        }
        
        simulation.open("sim");
        theoretical.open("theo");
        for (int i = 0; i< sim.size(); i++){
            simulation << sim[i] << endl;
            theoretical << theo[i] << endl;
        }
    }
    
    
};
#endif









