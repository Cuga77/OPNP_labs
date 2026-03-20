#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include "FUNCS.H"
#include "CLASSES.H"
using namespace std;

int main(int argc, char* argv[])
{
FILE* File_In;
Graph* graph;

  system("clear");
	if (argc < 2){
   	cout<<"Less of argument..."<<endl;
		return -1;
   }

	if ( !(File_In = fopen(argv[1], "r")) ){
		cout<<"Error open file "<<argv[1]<<endl;
      return -1;
   }
   if (!Build_Graph(File_In, &graph)){
		system("clear");
      cout<<"Min ways...."<<endl;
      graph->Ways();
      cout<<endl<<"Press a key..."<<endl;
      getchar();
      system("clear");
      cout<<endl<<"Z ways...."<<endl;
      graph->Z();
      cout<<endl<<"Press a key..."<<endl;
      getchar();
   }
   else{
   	cout<<"Error creating graph. Check the describtion...";
      getchar();
   }
   return 0;
}
