#include "matriz_lista_string.h"

matrix_t* matrixNew(uint32_t m, uint32_t n){
	matrix_t* t = malloc(sizeof(matrix_t));
	t->dataType = 4;
	t->remove = (funcDelete_t*) &matrixDelete;
	t->print = (funcPrint_t*) &matrixPrint;
	t->m = m;
	t->n = n;
	t->data = malloc(m*n*8);

	for (uint32_t i = 0; i < m*n; ++i)
	{
		t->data[i] = NULL;
	}

    return t;
}

void matrixPrint(matrix_t* m, FILE *pFile) {
	int fila = m->n;
	int columna = m->m;

	int f = 0; 

	while(f < fila)
	{
		for (int c = 0; c < columna; c++)
		{

			fprintf(pFile,"|" );

				integer_t* t = m->data[f * columna + c];
				if (t == NULL){
					fprintf(pFile, "NULL");
				}else{
					t->print(t,pFile);	
				}
							
		}
		fprintf(pFile, "|\n");
		f++;
	}
}