
#ifndef CARDGAME_H
#define CARDGAME_H
#define MAX 200
#define NIL -1
#include <algorithm>


double mem[MAX][MAX];
void init(){
    for (int i = 0; i <101; i++) {
        for (int j = 0; j<101; j++) {
            mem[i][j] = NIL ;
        }
    }
}

double value(int r, int b)
{
    if (0 == r)
        return ((double) b);
    if (0 == b)
        return (0);
    
    if (mem[r][b] != NIL) {
        return mem[r][b];
    }
    
    else{
        
        double term1 = ((double) r/(r+b)) * value(r-1, b);
        
        double term2 = ((double) b/(r+b)) * value(r, b-1);
        
        mem[r][b] = std::max((term1 + term2), (double) (b - r));
        
        return mem[r][b];
        
    }
    
}



#endif
