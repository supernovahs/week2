pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";





template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
 
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    signal intermediate[n+1][2**n];
    component poseidon[n*(2**n)];
    var c=0;
    var i=n;
    for(var i=n;i>=1;i--)
{       var x=0;
        for(var j=0;j<2**(i);j+=2)
        {   
        if(i==n)
        {
            poseidon[c]=Poseidon(2);
            poseidon[c].inputs[0]<==leaves[j];
            poseidon[c].inputs[1]<==leaves[j+1];
            intermediate[i][x]<==poseidon[c].out;
            c++;
            x++;
            // intermediate[i][j]<==hash(leaves[k],leaves[k+1]);
        }
        else
        {
                        poseidon[c]=Poseidon(2);
 
             poseidon[c].inputs[0]<==intermediate[i+1][j];
            poseidon[c].inputs[1]<==intermediate[i+1][j+1];
            intermediate[i][x]<==poseidon[c].out;
            c++;
            x++;
            // intermediate[i][j]<==hash(intermediate[i+1][k],intermediate[i+1][k+1]);
            // k=k+2;
        }
        } 
}
            root<==intermediate[1][0];
 
}


template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    var z = 0;
    signal hash[n+1];
     hash[0] <== leaf;
    component mux1[n];
    component poseidon[n];
    component mux1secondcomponent[n];
    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    for(var i=0; i<n; i++){
        poseidon[i] = Poseidon(2);
        mux1[i] = Mux1();
        mux1secondcomponent[i] = Mux1();
        mux1[i].s <== path_index[i];
        mux1[i].c[0] <== path_elements[i];
        mux1[i].c[1] <== hash[z];
        poseidon[i].inputs[0] <== mux1[i].out;

        mux1secondcomponent[i].s <== path_index[i];
        mux1secondcomponent[i].c[0] <== hash[z];
        mux1secondcomponent[i].c[1] <== path_elements[i];
        poseidon[i].inputs[1] <== mux1secondcomponent[i].out;
        z++;
    hash[z] <== poseidon[i].out;
       
    }
    root <== hash[z];       

}

