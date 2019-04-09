#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "matriz_lista_string.h"

void test_ejemplo(FILE *pfile){
	fprintf(pfile,"Caso lista\n");
	list_t* l = listNew();

	integer_t* n30 = intNew();
	intSet(n30,13);
	integer_t* n50 = intNew();
	intSet(n50, 58);

	l = listAdd(l, intSet(intNew(), 34), (funcCmp_t*) &intCmp);
	l = listAdd(l, intSet(intNew(), 42), (funcCmp_t*) &intCmp);
	l = listAdd(l, intSet(intNew(), 13), (funcCmp_t*) &intCmp);
	l = listAdd(l, intSet(intNew(), 44), (funcCmp_t*) &intCmp);
	l = listAdd(l, intSet(intNew(), 58), (funcCmp_t*) &intCmp);
	l = listAdd(l, intSet(intNew(), 11), (funcCmp_t*) &intCmp);
	l = listAdd(l, intSet(intNew(), 92), (funcCmp_t*) &intCmp);
	listPrint(l, pfile);
	fprintf(pfile, "\n");
	listRemove(l, (void*)n30, (funcCmp_t*) &intCmp);
	listRemove(l, (void*)n50, (funcCmp_t*) &intCmp);

	intDelete(n30);
	intDelete(n50);
	listPrint(l, pfile);
	listDelete(l);
	fprintf(pfile, "\n");


	fprintf(pfile,"Caso Matriz\n");
	list_t* n1 = listNew();
	n1 = listAdd(n1, intSet(intNew(), 1), (funcCmp_t*) &intCmp);
	n1 = listAdd(n1, intSet(intNew(), 2), (funcCmp_t*) &intCmp);
	n1 = listAdd(n1, intSet(intNew(), 3), (funcCmp_t*) &intCmp);

	list_t* s1 = listNew();
	s1 = listAddLast(s1, strSet(strNew(), "SA"));
	s1 = listAddLast(s1, strSet(strNew(), "RA"));
	s1 = listAddLast(s1, strSet(strNew(), "SA"));

	list_t* n2 = listNew();
	n2 = listAddLast(n2, intSet(intNew(), 2));
	n2 = listAddLast(n2, intSet(intNew(), 3));
	list_t* ll = listNew();
	n2 = listAddFirst(n2,ll);

	list_t* s4 = listNew();
	s4 = listAddLast(s4, strSet(strNew(), "SA"));
	s4 = listAddLast(s4, strSet(strNew(), "RA"));
	s4 = listAddLast(s4, strSet(strNew(), "SA"));

	list_t* n3 = listNew();
	n3 = listAddFirst(n3,listNew());
	n3 = listAddFirst(n3, listNew());
	n3 = listAddLast(n3, intSet(intNew(), 3));

	list_t* s2 = listNew();
	s2 = listAddLast(s2, listAddFirst(listNew(),strSet(strNew(),"SA")));
	s2 = listAddLast(s2, listAddFirst(listNew(),strSet(strNew(),"RA")));
	s2 = listAddLast(s2, listAddFirst(listNew(),strSet(strNew(),"SA")));

	list_t* s5 = listNew();
	s5 = listAddLast(s5, listAddFirst(listNew(),strSet(strNew(),"SA")));
	s5 = listAddLast(s5, listAddFirst(listNew(),strSet(strNew(),"RA")));
	s5 = listAddLast(s5, listAddFirst(listNew(),strSet(strNew(),"SA")));

	list_t* n4 = listNew();
	n4 = listAddLast(n4,intSet(intNew(), 1));
	n4 = listAddLast(n4, listAddFirst(listNew(),intSet(intNew(), 2))); 
	n4 = listAddLast(n4, intSet(intNew(), 3));

	list_t* s3_1 = listNew();
	s3_1 = listAddLast(s3_1,strSet(strNew(),"ra"));
	s3_1 = listAddLast(s3_1,strSet(strNew(),"ra"));
	s3_1 = listAddLast(s3_1,intSet(intNew(),33));

	list_t* s3_2 = listNew();
	s3_2 = listAddLast(s3_2,strSet(strNew(),"ro"));
	s3_2 = listAddLast(s3_2,strSet(strNew(),"ro"));
	s3_2 = listAddLast(s3_2,intSet(intNew(),35));

	list_t* s3 = listNew();
	s3 = listAddLast(s3, s3_1);
	s3 = listAddLast(s3, s3_2);


	matrix_t* m;
	m = matrixNew(4,5);
	m = matrixAdd(m,1,0, n1);
	m = matrixAdd(m,2,0, s1);
	m = matrixAdd(m,1,1, n2);
	m = matrixAdd(m,2,1, s4);
	m = matrixAdd(m,1,2, n3);
	m = matrixAdd(m,2,2, s2);
	m = matrixAdd(m,3,2, intSet(intNew(), 35));
	m = matrixAdd(m,1,3, s5);
	m = matrixAdd(m,2,3, n4);
	m = matrixAdd(m,3,3, intSet(intNew(), 32));
	m = matrixAdd(m,1,4, s3);
	m = matrixAdd(m,2,4, intSet(intNew(), 8));
	m = matrixAdd(m,3,4, intSet(intNew(), 31));
	matrixPrint(m,pfile);
	matrixDelete(m);

}

int main (void){
	FILE *pfile = fopen("salida.casos.propios.txt","a");
	test_ejemplo(pfile);
	fclose(pfile);
	return 0;    
}


