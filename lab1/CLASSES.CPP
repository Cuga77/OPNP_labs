#include <iostream>
#include <string.h>
#include <stdlib.h>
#include "CLASSES.H"
#include "FUNCS.H"
using namespace std;

Arc::Arc()
{
	Next = NULL;
  Prev = NULL;
  Mark = NotMarked;;
	node = NULL;
   Circle = NotMarked;
};

Arc::Arc(Node* _node)
{
	Next = NULL;
  Prev = NULL;
  Mark = NotMarked;;
	node = _node;
   Circle = NotMarked;
};


//////////////////////  NODE   //////////////////////


Node::Node(char* name,char* caption)
{
   Name = new char[strlen(name)+2];
   strcpy(Name, name);

   Caption = NULL;
   
   if (caption){
      Caption = new char[strlen(caption)+2];
      strcpy(Caption, caption);
   }

   First = NULL;
   Last = NULL;
   Curr_Arc = NULL;
   Curr_Num = 0;
   Count_Arcs = 0;
   Mark = NotMarked;
   Length = 0;
};

Node::~Node()
{
  delete Name;
  if (Caption)
  	delete Caption;
};

void Node::Add_Node(Node* node)
{
struct Arc* New_Arc = NULL;

if (node){
  New_Arc = new struct Arc(node);

   if (!Count_Arcs){
   	  First = New_Arc;
      Last = New_Arc;
      Curr_Arc = First;
      Curr_Num = 1;
   }
   else{
		  Last->Next = New_Arc;
      New_Arc->Prev = Last;
      Last = New_Arc;
   }
   New_Arc = NULL;
   Count_Arcs++;
}
};


Arc* Node::Next_Arc()
{
   if (Curr_Num == Count_Arcs)
   	return NULL;

   Curr_Arc = Curr_Arc->Next;
   Curr_Num++;
   return Curr_Arc;
};


Arc* Node::Prev_Arc()
{
   if (Curr_Num <= 1)
   	return NULL;

   Curr_Arc = Curr_Arc->Prev;
   Curr_Num--;
   return Curr_Arc;
};

Arc* Node::Get_Arc(unsigned num)
{
   if ((Count_Arcs < 1) ||(Count_Arcs < num))
   	return NULL;

   if (num == Count_Arcs)
   	return Last;

   Curr_Arc = First;

   for(int i = 1; i < Count_Arcs; i++){
		if (i == num)
      	return Curr_Arc;
    Curr_Arc = Curr_Arc->Next;
   }
   return NULL;
};

Arc* Node::Find_Not_Marked_Arc()
{
	int find = 0;
   Arc* _Curr_Arc = First;

   while(!find && _Curr_Arc)
   {
   	find = !_Curr_Arc->Mark;
      if (!find)
      	_Curr_Arc = _Curr_Arc->Next;
   }
   if (!find)
   	_Curr_Arc = NULL;

	return _Curr_Arc;
};

Arc* Node::Find_Circle_Arc()
{
	int find = 0;
   Arc* _Curr_Arc = First;

   while(!find && _Curr_Arc)
   {
   	find = (!_Curr_Arc->Mark) && _Curr_Arc->Circle; //for multi circles from one node
      if (!find)
      	_Curr_Arc = _Curr_Arc->Next;
   }
   if (!find)
   	_Curr_Arc = NULL;

	return _Curr_Arc;
};


Node* Node::Find_Not_Marked_Node()
{
   int i = 1;
   int stop = 0;
   Node* node = this;
   Node* tnode = node;
   while (!stop){
         if (tnode && tnode->Mark == NotMarked){
         	stop = 1;
         }
         else if (tnode){
           if (i > node->Count_Arcs){
               stop = 1;
               tnode = NULL;
           }
           else if (!node->Get_Arc(i)->Circle){
              tnode = node->Get_Arc(i)->node->Find_Not_Marked_Node();
              if (tnode){
   	           stop = 1;
              }
           }
           i++;
         }
         else{
           stop = 1;
         }
      }
      
//   if (find)
   	return tnode;
//   return NULL;
};

void Node::Reset()
{
   Arc* tmp = First;

	Mark = NotMarked;
   for (int i = 0; i <  Count_Arcs; i++){
       tmp->Mark = NotMarked;
       tmp = tmp->Next;
   }

};

/////////////////   GRAPH  ////////////////////
Graph::Graph()
{
	  First = NULL;
	  Last = NULL;
	  Way = NULL;
	  Top = NULL;
     End = NULL;
     Count_Nodes = 0;
};

Graph::~Graph()
{
	// ?????
};

void Graph::Add_Node(char* name)
{
	if (Count_Nodes){
   	Last->Next = new Node_Pointer;
      Last->Next->Prev = Last;
      Last = Last->Next;
      Last->Item = new Node(name);
      Count_Nodes++;
   }
   else{
   	  First =  new Node_Pointer;
      Last = First;
      Last->Item = new Node(name);
      Count_Nodes++;
   }
};

Node*  Graph::Find_Node(char* name)
{
	int found = 0;
   int i = 0;
   Node_Pointer* cur = First;

   while((i < Count_Nodes)&&(!found)){
     found = !(strcmp(name, cur->Item->name()) != 0);
     if (!found){
     	i++;
      cur = cur->Next;
     }
   }
if (found)
	return cur->Item;
else
	return NULL;
};

int Graph::Find_Node(Node* node, Node_Pointer* NP)
   {
      int find = 0;
      Node_Pointer* tmp = NP;
         if (NP){
            do{
              find = (tmp->Item == node);
            }while(!find && (tmp = tmp->Next));
         }
         return find;
   }

void Graph::Detect_Circle(Node* node, Trace* TRACE)
{
Node* tmp = NULL;
Trace* tmpNP = new Trace;

if (!TRACE)
	TRACE = new Trace;

TRACE->Append(node);

  for (int i = 1; i <= node->Count_Arcs; i++){
	  	tmp = node->Get_Arc(i)->node;
     	if (TRACE->Belong(tmp)){
        if (Test_Circle(tmp, node)){
           node->Get_Arc(i)->Circle = Marked;
        }
        else{
           cout<<endl<<"Bad Graph structure at or near node "<<tmp->name();
           cout<<endl<<"Please, check the description.";
           cout<<endl<<"Press any key to continue...";
        	  cout<<endl;
           getchar();
        }
      }
      else{
         tmpNP->Cat(TRACE);
         Detect_Circle(tmp, tmpNP);
			tmpNP->Clear();
      }  //else
  }//for
};

int Graph::Test_Circle(Node* begin, Node* end)
{
int result = 1;

  for (int i =1; i <= begin->Count_Arcs; i++){
     int r = Detect_All_Ways(begin, end);
     result = result&&r;
  }
  return result;
};

int Graph::Detect_All_Ways(Node* begin, Node* end, Trace* TRACE)
{
int result = 1;
Trace* tmpNP = new Trace;
Node* tmp;

   if (begin == end){
      result= 1;
   }
   else{
    if (begin == End){
       result = 0;
    }
    else{

     if (!TRACE)
    	  TRACE = new Trace;

     TRACE->Append(begin);

     for (int i = 1; i <= begin->Count_Arcs; i++){
      if (!begin->Get_Arc(i)->Circle){
	  	   tmp = begin->Get_Arc(i)->node;
     	   if (!TRACE->Belong(tmp)){
             tmpNP->Cat(TRACE);
             int r = Detect_All_Ways(tmp, end, tmpNP);
             result = result&&r;
             tmpNP->Clear();
         }
      }
    }//for
   }
  }
  return result;
};


void Graph::Reset_Length()
{
Node_Pointer* tmp =   First;

	for (int i =0 ; i< Count_Nodes; i++){
   	tmp->Item->Length = 0;
      tmp = tmp->Next;
   }
};

void Graph::Reset()
{
Node_Pointer* tmp =   First;

	for (int i =0 ; i< Count_Nodes; i++){
   	tmp->Item->Reset();
      tmp = tmp->Next;
   }
};


int Graph::Ways()
{
   Reset();
   Min_Ways = new Traces;
   Trace* way = NULL;

   while(!Stop()){
   	End->Mark_Node();
   	way = do_Way(this, Top, End);
   	End->UnMark_Node();
      Min_Ways->Append(way);
   }

   MMin = Min_Ways->Count_M();
   Min_Ways->Print();
   cout<<endl<<"Complexity = "<<MMin<<endl;
   return 0;
};

int Graph::Z()
{
Node_Pointer* tmp = First;
Arc* t = NULL;
Circle_Z_Ways = new Traces;

   Reset();

   for (int k = 0; k < Count_Nodes; k++ ){
     if((t = tmp->Item->Find_Circle_Arc()))
     {
     	 if (!t->Mark){
     		Trace* way = new  Trace;
        	Reset_Length();
         way->Cat(Short_Way(t->node, tmp->Item));
         way->Append(t->node);
         t->Mark = 1;
	      Circle_Z_Ways->Append(way);
       }
     };//*/
     tmp = tmp->Next;
   }

  	Z_Ways = do_Way_Z(this, Top, End);

   MZ = Z_Ways->Count_M() + Circle_Z_Ways->Count_M();
   Circle_Z_Ways->Print();
   Z_Ways->Print();
   cout<<endl<<"Complexity = "<<MZ<<endl;
   return 0;
};

int Graph::Stop()
{
int s = 1;
	End->Mark_Node();
   if(Top->Find_Not_Marked_Node()){
   	s = 0;
      End->UnMark_Node();
   }
return s;
};


Trace* Graph::Short_Way(Node* From, Node* To)
{  //don't detect if node To is unreachable
Node* tmp = NULL;
unsigned 	 L = To->Length;
Trace* ShortWay = NULL;
Trace* Way = NULL;

	if (!To->Length || (From->Length <= To->Length)){ //1

      if (From==To){
         ShortWay = new Trace;
         ShortWay->Append(To);
      }
      else{
         if (From != End){ //5
            ShortWay = new Trace;
            for (int i = 1; i <= From->Count_Arcs; i++){

               if (!From->Get_Arc(i)->Circle){ //4
                  tmp = From->Get_Arc(i)->node;
                  tmp->Length = From->Length + tmp->Count_Arcs; // ???????
                  Way = Short_Way(tmp, To);
                  if (!L || (L > To->Length)){ //3
                     ShortWay->Clear();
				         ShortWay->Append(From);
                     ShortWay->Cat(Way);
                     L = To->Length;
                  }
                  delete Way;
                  Way = NULL;
                  To->Length = L;
               } //4
            }   //for
         }   //5
      }
   } //1
   return ShortWay;
};


////////////////   Trace //////////////////

Trace::Trace()
{
	Counter = 0;
   Current = Start = Finish = NULL;
};

Trace::~Trace()
{
	this->Clear();
};


int Trace::Reset()
{
int error = 1;
	if (Counter){
     Current = Start;
     error = 0;
   }

   return error;
};

Node_Pointer* Trace::Item()
{
	if (Counter)
   	return Current;

   return NULL;
};

int Trace::Next()
{
int error = 1;
	if (Current != Finish){
   	Current = Current->Next;
      error = 0;
   }

   return error;
};

int Trace::Prev()
{
int error = 1;
	if (Current != Start){
   	Current = Current->Next;
      error = 0;
   }

   return error;
};

void Trace::Cat(Trace* t)
{
Node* tmp;
if (t){
      if (!(t->Reset())){
   	   do{
         	tmp = t->Item()->Item;
				Append(tmp);
         }
         while(!(t->Next()));
         t->Reset();
      }
}
};

void Trace::Append(Node* n)
{
  if (Counter){
	Finish->Next = new Node_Pointer(n);
   Finish->Next->Prev = Finish;
   Finish = Finish->Next;
  }
  else{
    Node_Pointer* qq = new Node_Pointer(n);
    Finish = qq;
    Start = qq;
  }
  Counter++;
};

void Trace::Clear()
{
   Finish = NULL;
	for (int i = 0; i < Counter; i++ ){
		Current = Start;
   	Start = Start->Next;
      if (Current)
      	delete Current;
   }
   Start = NULL;
   Current = NULL;
   Counter = 0 ;
};

void Trace::Print()
{
	if (!(this->Reset())){
   	do{
        cout<<" -> ";
        cout<<this->Item()->Item->name();
      }while(!(this->Next()));
      this->Reset();
   }
};

void Trace::Delete_Node(Node* node)
{
	int find = 0;
   Node_Pointer * t1, *t2;

	Current = Start;
   if (Counter){
   	do{
        find = Current->Item == node;
        if(!find)
        	Current = Current->Next;
      }while (!find && Current);

      if (find){
         t1 = Current->Prev;
         t2 = Current->Next;

         if (Finish == Current)
         	Finish = Finish->Prev;

         if (Current == Start)
         	Start = Start->Prev;

         delete Current;
         if (t1)
         	t1->Next = t2;
         if (t2)
         	t2->Prev = t1;
      }
   }
};

int Trace::Belong(Node* node)
{
	int find = 0;
	if (!(this->Reset())){
   	do{
         find = this->Item()->Item == node;
      }while(!(this->Next() || find));
      this->Reset();
   }
    return find;
};

unsigned Trace::Count_M()
{
   unsigned M = 0;
   if (!Reset()){
   	for (int i = 1; i <= Counter; i++){
        if (Item()->Item->Arcs() > 0)
	      	M += Item()->Item->Arcs()-1;
         Next();
      }
   }
   return M;
};



////////////  TRACES  /////////////

Traces::Traces()
{
	Count_Traces = 0;
   Last = NULL;
   First = NULL;
   Current = NULL;
};

Traces::~Traces()
{
	Count_Traces = 0;
   Last = NULL;
   Current = NULL;
   First = NULL;
};


void Traces::Append(Trace* trace)
{
	if (Count_Traces){
   	Last->Next = new Trace_Pointer(trace);
      Last->Next->Prev = Last;
      Last = Last->Next;
      Last->Next = NULL;
		Count_Traces ++;
   }
   else{
   	First = new Trace_Pointer(trace);
      Last = First;
      Last->Next = NULL;
      Last->Prev = NULL;
		Count_Traces ++;
	   Current = First;
   }
};

int Traces::Belong(Node* node)
{
	int find = 0;
	if (!(this->Reset())){
   	do{
         find = this->Item()->Item->Belong(node);
      }while(!(this->Next() || find));
      this->Reset();
   }
    return find;
};

int Traces::Reset()
{
int error = 1;
	if (Count_Traces){
     Current = First;
     error = 0;
   }

   return error;
};

Trace_Pointer* Traces::Item()
{
	if (Count_Traces)
   	return Current;

   return NULL;
};

int Traces::Next()
{
int error = 1;
	if (Current != Last){
   	Current = Current->Next;
      error = 0;
   }

   return error;
};

int Traces::Prev()
{
int error = 1;
	if (Current != First){
   	Current = Current->Next;
      error = 0;
   }

   return error;
};

void Traces::Print()
{
	if (!Reset()){
     for (int i = 1; i <= Count_Traces; i++){
	   cout<<"-------------- Path #"<<i<<" ---------------"<<endl;
	   Item()->Item->Print();
      cout<<endl<<"---------Press a key to continue ---------"<<endl;
   	getchar();
      Next();
      }
    }
};

unsigned Traces::Count_M()
{
   unsigned M = 0;
   if (!Reset()){
   	for (int i = 1; i <= Count_Traces; i++){
      	M += Item()->Item->Count_M();
         Next();
      }
   }
   return M;
};

void Traces::Cat(Traces* tr)
{
unsigned C = Count_Traces;
	if (Reset()){
	 for (int i = 0; i < C; i++){
	   if (tr->Reset()){
         tr->Next();
         do{
               Trace* tmp = new Trace;
               tmp->Cat(Item()->Item);
               tmp->Cat(tr->Item()->Item);
               Append(tmp);
         } while(tr->Next());
         tr->Reset();
         Item()->Item->Cat(tr->Item()->Item);
      }
    }
   }
  else{
	   if (tr->Reset()){
         do{
               Trace* tmp = new Trace;
               tmp->Cat(Item()->Item);
               tmp->Cat(tr->Item()->Item);
               Append(tmp);
         } while(tr->Next());
      }
  }
};

