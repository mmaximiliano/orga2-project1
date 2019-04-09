; FUNCIONES de C
	extern malloc
	extern free
	extern fopen
	extern fclose
	extern fprintf	

section .data

section .rodata
printString: DB "%s",0
printInt: DB "%i" ,0
printNULL: DB "NULL", 0
printCI: DB "[", 0
printCD: DB "]", 0
printComa: DB ",", 0
printBarra: DB "|", 0


section .text

global str_len
global str_copy
global str_cmp
global str_concat
global matrixAdd
global matrixRemove
global matrixDelete
global listNew
global listAddFirst
global listAddLast
global listAdd
global listRemove
global listRemoveFirst
global listRemoveLast
global listDelete
global listPrint
global strNew
global strSet
global strAddRight
global strAddLeft
global strRemove
global strDelete
global strCmp
global strPrint
global intNew
global intSet
global intRemove
global intDelete
global intCmp
global intPrint



%define struct_size 32 ; size de la estructura int
%define off_dataType 0
%define off_remove 8
%define off_print 16
%define off_data 24
%define NULL 0
%define int_size 4

;########### Funciones Auxiliares Recomendadas

; uint32_t str_len(char* a)		7 instrucciones
str_len:
	
	mov rax, 0

	.ciclo:
		cmp byte [rdi], 0
		je .fin
		inc rax
		inc rdi
		jmp .ciclo

	.fin:
		ret

; char* str_copy(char* a)		19 instrucciones
str_copy:	; rdi = *a
	push rbp					;alineada
	mov rbp, rsp
	push r12					;desalineada
	push r13					;alineada

	mov r12, rdi				;r12 = *a
	call str_len				;obtengo la longitud del String
	mov rdi, rax				;rdi = |a|
	mov r13, rdi				;r13 = |a| 


	inc rdi						;incremento el size (dejo espacio para el 0)
	
	call malloc		 			;pido memoria para el str

	xor rcx, rcx				;rcx = 0
	
	.ciclo:
		mov dl, [r12 + rcx]	;dl = a[i]
		mov [rax + rcx], dl	;b[i] = a[i]
		inc rcx					
		cmp rcx, r13
		jle .ciclo

	pop r13
	pop r12
	pop rbp
	ret

; int32_t str_cmp(char* a, char* b)	25 instrucciones
str_cmp:		;rdi = *a  rsi = *b
	push rbp
	mov rbp, rsp			;alineada
	push r12				;desalineada
	push r13				;alineada
	push r14				;desalineada
	push r15				;alineada

	mov r12, rdi			;r12 = *a
	mov r13, rsi			;r13 = *b

	call str_len			;rax = |a|
	mov r14, rax			;r14 = |a|

	mov rdi, r12			;rdi = *b
	call str_len			;rax = |b|
	
	xor r15, r15			;r15 = 0

	cmp r14, rax			;comparo |a| con |b|
	jg .cambio				;pongo la longitud minima en rax
	jmp .ciclo				;sino hago el ciclo

	.cambio:
		mov rax, r14		;pongo en rax el minimo

	.ciclo:
		cmp r15, rax		;veo si alcance la longitud minima
		je .iguales

		mov dl, [r12 + r15];dl = a[i]
		cmp dl, [r13 + r15];comparo a[i] con b[i]

		jg .mayor
		jl .menor

		inc r15				;aumento el contador
		jmp .ciclo			;si son iguales, comparo el siguiente
		

	.mayor:
		mov eax, -1
		jmp .fin
	.iguales:
		mov rdi, r12			;rdi = *a
		call str_len			;rax = |a|
		mov r14, rax			;r14 = |a|

		mov rdi, r13			;rdi = *b
		call str_len			;rax = |b|

		cmp r14, rax			;comparo |a| con |b|
		jg .mayor
		jl .menor

		mov eax, 0
		jmp .fin

	.menor:
		mov eax, 1

	.fin:
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

; char* str_concat(char* a, char* b)	36 instrucciones
str_concat:			; rdi = *a  rsi = *b
	push rbp						;alineada
	mov rbp, rsp
	push r12						;desalineada
	push r13						;alineada
	push r14						;desalineada
	push r15						;alineada

	mov r13, rdi					;r13 = *a
	mov r14, rsi					;r14 = *b

	call str_len 					;rax = |a|
	mov r12, rax					;r12 = |a|
	
	mov rdi, r14					;rdi = *b
	call str_len 					;rax = |b|
	add r15, rax					;r15 = |b|
	
	mov rdi, rax					;rdi = |b|
	add rdi, r12					;rdi = |b|+|a|
	inc rdi							;rdi = |b|+|a| + 1
	call malloc						;rax = puntero a s+d

	xor rcx, rcx					;rcx = 0
	.copiarA:
	mov dl, [r13 + rcx]				;dl = a[i]
	mov [rax + rcx], dl				;b[i] = a[i]
	inc rcx
	cmp rcx, r12
	jl .copiarA
	
	xor rcx, rcx					;rcx = 0
	.copiarB:
	mov dl, [r14 + rcx]				;dl = a[i]
	mov [rax + r12], dl				;b[i] = a[i]
	inc rcx
	inc r12					
	cmp rcx, r15
	jle .copiarB

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

;########### Funciones: Matriz
;typedef struct s_matrix{
;   	type_t dataType;
;   	funcDelete_t *remove;
;   	funcPrint_t *print;
;   	uint32_t m;
;		uint32_t n;
;    	void **data;
;} matrix_t;


%define off_m 24
%define off_n 28
%define off_doblePunt 32
%define matrix_size	40


; matrix_t* matrixNew(uint32_t m, uint32_t n);	
;matrixNew:
;	push rbp 						;alineada
;	mov rbp, rsp
;	push r12						;desalineada
;	push r13						;alineada
;	push r14						;desalineada
;	push r15						;alineada
;
;	mov r12d, edi					;r12 = m
;	mov r13d, esi					;r13 = n
;
;	mov rdi, matrix_size			;rdi = matrix_size
;	call malloc
;
;	mov r15, rax					;r15 = *t
;
;	mov dword [rax + off_dataType], 3
;   mov qword [rax + off_remove], matrixRemove
;    mov qword [rax + off_print], matrixPrint
;    mov [rax + off_m], r12d			;OJO CON ESTO!!
;    mov [rax + off_n], r13d			;OJO CON ESTO!!
;    mov qword [rax + off_doblePunt], NULL
;
;    mov rax, r12					;rax = m
;    mul r13							;rax = m * n
;    mov r12, 8						;r12 = 8 = tam
;    mul r12							;rax = m * n * tam
;    mov rdi, rax					;rdi = m * n * tam
;    mov r14, rdi					;r14 = m * n * tam
;    call malloc						;rax = *m
;
;    mov [r15 + off_doblePunt], rax
;
;    xor rcx, rcx					;rcx = 0
;    .inicializar:
;    	cmp r14, rcx
;    	je .fin
;    	mov qword [rax + rcx], NULL
;    	inc rcx
;    	jmp .inicializar
;
;    .fin:	
;    	mov rax, r15					;rax = *t
;    	pop r15
;    	pop r14
;    	pop r13
;    	pop r12
;    	pop rbp
;    	ret


; matrix_t* matrixAdd(matrix_t* m, uint32_t x, uint32_t y, void* data);
matrixAdd:			; rdi = *t   esi = x (columna)  edx = y (fila)  rcx = *data
	push rbp						;alineada
	mov rbp, rsp
	push r12						;desalineada
	push r13						;alineada
	push r14						;desalineada
	push r15						;alineada
	push rbx						;desalineada
	sub rsp, 8						;alineada

	mov r12, rdi					;rdi = *t
	mov r14, rcx					;r14 = *data
	mov r15d, edx					;r15 = y (fila)
	mov ebx, esi					;ebx = x (columna) 

	mov rdi, [r12 + off_doblePunt]	;rdi = *m
	mov rax, [r12 + off_m]			;rax = m (cantidad de elementos por fila)
	mul r15d						;rax = m * y 
	add eax, esi					;rax = m * y + x
	xor rsi, rsi
	mov rsi, 8						;rsi = 8
	mul rsi							;rax = (m * y + x ) * 8
	

	add rdi, rax					;rdi = *m + (m * y + x ) * 8

	;preguntar si esta vacio
	mov r13, rdi
	cmp qword [rdi], NULL
	je .asignar
	
	mov rdi, [r13]					;rdi = *dato
	mov edx, r15d					;edx = y (fila)
	mov esi, ebx					;ebx = x (columna)
	call [rdi + off_remove]

	.asignar:
	mov [r13], r14


	mov rax, r12					;rax = *t
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret


; matrix_t* matrixRemove(matrix_t* m, uint32_t x, uint32_t y);
matrixRemove:		;rdi = *t  esi = x  edx = y
	push rbp						;alineada
	mov rbp, rsp
	push r12						;desalineada
	push r13						;alineada

	mov r12, rdi					;r12 = *t

	;indexo
	mov rdi, [r12 + off_doblePunt]	;rdi = *m
	mov rax, [r12 + off_m]			;rax = m (cantidad de elementos por fila)
	mul edx							;rax = m * y 
	add rax, rsi					;rax = m * y + x
	mov esi, 8						;esi = 8
	mul esi							;rax = (m * y + x ) * 8
	add rdi, rax					;rdi = *m + (m * y + x ) * 8

	mov r13, rdi
	cmp qword [rdi], NULL
	je .fin
	mov rdi, [r13]					;rdi = *dato

	call [rdi + off_remove]
	mov qword [r13], NULL	

	.fin:
		mov rax, r12				;rax = *t
		pop r13
		pop r12
		pop rbp
		ret

; void matrixDelete(matrix_t* m);
matrixDelete:
	push rbp						;alineada
	mov rbp, rsp
	push rbx						;desalineada
	push r12						;alineada
	push r13						;desalineada
	push r14						;alineada
	push r15						;desalineada
	sub rsp, 8						;alineada

	mov rbx, rdi					;rbx = *t	
	mov r12d, [rdi + off_m]			;r12 = m
	mov r13d, [rdi + off_n]			;r13 = n
;
;	mov r14, -1						;r14 = -1
;	.fila:
;		inc r14
;		xor r15, r15				;r15 = 0
;		cmp r14, r12
;		je .fin
;		.columna:
;		 	cmp r15, r13
;		 	je .fila
;		 	mov rdi, rbx			;rdi = *t
;		 	mov rsi, r14			;rsi = x
;		 	mov rdx, r15			;rdx = y
;		 	call matrixRemove		;rax = *t
;		 	inc r15
;		 	jmp .columna

	mov rax, r12					;rax = m
	mul r13							;rax = m * n
	mov r12, 8						;r12 = 8
	mul r12							;rax = m * n * 8

	mov r13, rax					;r13 = m * n * 8
	xor r12, r12					;r12 = 0
	mov r14, [rbx + off_doblePunt]	;r14 = *m
	.ciclo:
	cmp r12, r13					;ya limpie todo?
	je .fin
	cmp qword [r14 + r12], NULL		;comparo si esta vacio
	jne .eliminar

	add r12, 8
	jmp .ciclo

	.eliminar:
	mov rdi, [r14 + r12]			;rdi = *data
	call [rdi + off_remove]			;rax = *data
	add r12, 8						;proxima posicion
	jmp .ciclo

	.fin:
		mov rdi, [rbx + off_doblePunt]	;rdi = *m
		call free
		mov rdi, rbx					;rdi = *t
		call free

	
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret

;void matrixPrint(matrix_t* m, FILE *pFile);
;matrixPrint:
;	push rbp						;alineada
;	mov rbp, rsp
;	push rbx						;desalineada
;	push r12						;alineada
;	push r13						;desalineada
;	push r14						;alineada
;	push r15						;desalineada
;	push rsi						;alineada
;	
;	mov rbx, rdi					;rbx = *t	
;	mov r12d, [rdi + off_m]			;r12 = m
;	mov r13d, [rdi + off_n]			;r13 = n
;
;	mov r14, -1						;r14 = -1
;	.fila:
;		inc r14
;		xor r15, r15				;r15 = 0
;		cmp r14, r12
;		je .fin
;		.columna:
;		 	cmp r15, r13
;		 	je .fila
;
;		 	;abro
;		 	mov rdi, printBarra 			;rdi = "|"
;		 	pop rsi							;rsi = *pFile
;		 	push rsi						;alineada
;		 	call fprintf
;
;		 	;indexo
;			mov rdi, [rbx + off_doblePunt]	;rdi = *m
;			mov rax, r12					;rax = m
;			mul r14							;rax = m * x
;			add rax, r15					;rax = m * x + y
;			mov esi, 8						;esi = 8
;			mul esi							;rax = (m * x + y ) * 8
;			add rdi, rax					;rdi = *m + (m * x + y ) * 8
;
;			mov rdi, [rdi]					;rdi = *dato
;		 	pop rsi  						;rsi = *pFile
;		 	push rsi						;alineada
;		 	call [rdi + off_print]			;imprimo
;
;		 	;cierro
;		 	mov rdi, printBarra 			;rdi = "|"
;		 	pop rsi							;rsi = *pFile
;		 	push rsi						;alineada
;		 	call fprintf
;
;		 	;seguimos
;		 	inc r15
;		 	jmp .columna
;
;	.fin:
;		pop rsi
;		pop r15
;		pop r14
;		pop r13
;		pop r12
;		pop rbx
;		pop rbp
;		ret
	

;########### Funciones: Lista
;struct de nodo
%define off_elem 0
%define off_next 8
%define nodo_size 16


; list_t* listNew();
listNew:
    push rbp		;alineada
    mov rbp, rsp
    push rdi		;desalineada
    sub rsp, 8		;alineada


    ; MALLOC
    mov rdi, struct_size ; pido memoria para almacenar la estructura
    call malloc

    ; List
    mov dword [rax + off_dataType], 3
    mov qword [rax + off_remove], listDelete
    mov qword [rax + off_print], listPrint
    mov qword [rax + off_data], NULL

    add rsp, 8
    pop rdi
    pop rbp
	ret


; list_t* listAddFirst(list_t* l, void* data);
listAddFirst:
	push rbp						;alineada
	mov rbp, rsp
	push r12						;desalineada
	push r13						;alineada

	mov r12, rdi					;r12 = *l
	mov r13, rsi					;r13 = *data

	mov rdi, nodo_size				;guardo el tamano del nodo
	call malloc

	mov [rax + off_elem], r13		;pongo el puntero al dato
	mov r13, [r12 + off_data]		;guardo el puntero al viejo prim
	mov [rax + off_next], r13		;pongo el puntero a next

	mov [r12 + off_data], rax		;pongo el puntero al nuevo prim

	mov rax, r12					;rax = *l

	pop r13
	pop r12
	pop rbp
	ret

; list_t* listAddLast(list_t* l, void* data);
listAddLast:
	push rbp							;alineada
	mov rbp, rsp
	push r12							;desalineada
	push r13							;alineada
	push r14							;desalineada
	sub rsp, 8							;alineada

	mov r12, rdi						;r12 = *l
	mov r13, rsi						;r13 = *data
	mov r14, rdi						;r14 = *l

	.vacia:
		cmp qword [r12 + off_data], NULL;comparo prim con NULL
		jne .noVacia					;si no es vacia busco el ultimo
	;Si es vacia, lo agrego como primero
		mov rdi, r14
		call listAddFirst
		jmp .fin

	.noVacia:
	;armo el nodo
	mov rdi, nodo_size					;pido memoria para nodo
	call malloc
	mov qword [rax + off_next], NULL	;apunta a NULL
	mov [rax + off_elem], r13			;puntero a dato
	mov r12, [r12 + off_data]			;apunto a prim

	.ciclo:
		cmp qword [r12 + off_next], NULL;me fijo si next es NULL
		je .agregar
		mov r12, [r12 + off_next]		;apunto al siguiente nodo
		jmp .ciclo

	.agregar:
		mov [r12 + off_next], rax		;pongo el puntero a nuevo nodo
	

	.fin:
		mov rax, r14					;rax = *l
		add rsp, 8
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

; list_t* listAdd(list_t* l, void* data, funcCmp_t* f);
listAdd:		; rdi = *l  rsi = *data  rdx = *f
	push rbp							;alineada
	mov rbp, rsp
	push r12							;desalineada
	push r13							;alineada
	push r14							;desalineada
	push r15							;alineada

	mov r12, rdi						;r12 = *l
	mov r13, rsi						;r13 = *data
	mov r15, rdx						;r15 = *f

	.vacia:
	cmp qword [r12 + off_data], NULL	;Vacia?
	jne .primero

	mov rdi, r12
	mov rsi, r13
	call listAddFirst
	jmp .fin

	.primero:							;primero?
	mov r14, [r12 + off_data]			;r14 = prim
	mov rdi, [r14 + off_elem]			;rdi = *data_a
	mov rsi, r13						;rsi = *data_b
	call r15							;comparo los datos
	cmp eax, 0							;if
	jge .ciclo

	mov rdi, r12						;rdi = *l
	mov rsi, r13						;rsi = *data
	call listAddFirst
	jmp .fin

	.ciclo:
	mov rcx, r14						;rcx = *nodoActual
	mov r14, [rcx + off_next]			;rcx = *prox nodo
	cmp r14, NULL						;Ultimo?
	je .ultimo
	mov rdi, [r14 + off_elem]			;rdi = *data_a
	mov rsi, r13						;rsi = *data_b

	push rcx							;desalineada
	sub rsp, 8							;alineada

	call r15							;comparo los datos
	cmp eax, 0							;if
	jl .agregar

	add rsp, 8
	pop rcx
	jmp .ciclo

	.ultimo:
	mov rdi, r12						;rdi = *l
	mov rsi, r13						;rsi = *data
	call listAddLast
	jmp .fin

	.agregar:
	;armo el nodo:
	mov rdi, nodo_size					;guardo el tamano del nodo
	call malloc
	mov [rax + off_elem], r13			;pongo el puntero al dato
	mov [rax + off_next], r14			;pongo el puntero a siguiente
	add rsp, 8
	pop rcx
	mov [rcx + off_next], rax			;pongo el puntero al nuevo

	.fin:
	mov rax, r12						;rax = *l
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; list_t* listRemove(list_t* l, void* data, funcCmp_t* f);
listRemove:
	
	push rbp							;alineada
	mov rbp, rsp
	push r12							;desalineada
	push r13							;alineada
	push r14							;desalineada
	push r15							;alineada
	push rbx							;desalineada
	sub rsp, 8							;alineada

	mov r12, rdi						;r12 = *l
	mov r13, rsi						;r13 = *data
	mov r15, rdx						;r15 = *f

	.inicio:

	.vacia:
	cmp qword [r12 + off_data], NULL	;Vacia?
	je .fin

	.primero:							;primero?
	mov r14, [r12 + off_data]			;r14 = prim
	mov rdi, [r14 + off_elem]			;rdi = *data_a
	mov rsi, r13						;rsi = *data_b
	call r15							;comparo los datos
	cmp eax, 0							;if a = b
	jne .ciclo
	mov rdi, r12						;rdi = *l
	call listRemoveFirst

	mov rdi, r12
	mov rsi, r13
	mov rdx, r15
	jmp .inicio

	.ciclo:
	mov rbx, r14						;rbx = *nodoActual
	mov r14, [rbx + off_next]			;r14 = *prox nodo
	cmp qword [rbx + off_next], NULL	;Ultimo?
	je .ultimo

	mov rdi, [r14 + off_elem]			;rdi = *data_a
	mov rsi, r13						;rsi = *data_b
	call r15							;comparo los datos
	cmp eax, 0							;if
	je .eliminar
	jmp .ciclo

	.ultimo:
	mov rdi, [rbx + off_elem]			;rdi = *data_a
	mov rsi, r13						;rsi = *data_b
	call r15							;comparo los datos
	cmp eax, 0							;if
	jne .fin
	mov rdi, r12						;rdi = *l
	call listRemoveLast
	jmp .fin

	.eliminar:

	mov rsi, [r14 + off_next]			;obtengo puntero a prox
	mov [rbx + off_next], rsi			;pongo nuevo prox

	mov rdi, [r14 + off_elem]			;rdi = *data_a
	call [rdi + off_remove]

	mov rdi, r14						;puntero a nodo a eliminar
	call free

	mov rdi, r12
	mov rsi, r13
	mov rdx, r15
	jmp .inicio

	.fin:
	mov rax, r12						;rax = *l
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
	

; list_t* listRemoveFirst(list_t* l);
listRemoveFirst:
	push rbp							;alineada
	mov rbp, rsp
	push r12							;desalineada
	push r13							;alineada

	mov r12, rdi						;r12 = *l

	cmp qword [r12 + off_data], NULL	;veo si la lista es vacia
	je .fin
	mov rdi, [r12 + off_data]			;rdi = puntero a prim
	
	mov r13, [rdi + off_next]			;r13 = puntero a 2do nodo
	mov [r12 + off_data], r13			;pongo el puntero al 2do nodo
	mov r13, rdi						;r13 = puntero a viejo 1er nodo
	mov rdi, [rdi + off_elem]			;rdi = puntero a dato

	call [rdi + off_remove]				;elimino dato de data						
	mov rdi, r13						;rdi = puntero a viejo 1er nodo
	call free							;libero el nodo


	.fin:
		mov rax, r12					;rax = *l
		pop r13
		pop r12
		pop rbp
		ret

; list_t* listRemoveLast(list_t* l);
listRemoveLast:
	push rbp							;alineada
	mov rbp, rsp
	push r12							;desalineada
	push r13							;alineada
	push r14							;desalineada
	sub rsp, 8							;alineada

	mov r14, rdi						;r14 = *l

	.vacia:
		mov r12, rdi					;r12 = *l
		cmp qword [r12 + off_data], NULL;comparo si la lista es vacia
		je .fin							;si es vacia salgo
		mov rdi, [rdi + off_data]		;puntero al primer nodo
	.unElemento:
		cmp qword [rdi + off_next], NULL;veo si hay 1 solo nodo
		jne .ciclo
		
		mov r13, rdi					;r13 = *nodo a borrar
		mov rdi, [r13 + off_elem]		;rdi = *data
		call [rdi + off_remove]			;libero el dato del nodo

		mov rdi, [r12 + off_data]
		call free
		mov qword [r12 + off_data], NULL;*next = NULL
		jmp .fin


	.ciclo:
		cmp qword [rdi + off_next], NULL;Es el ultimo?
		je .eliminar
		mov r12, rdi					;r12 = nodo anterior
		mov rdi, [rdi + off_next]
		jmp .ciclo

	.eliminar:
		mov r13, rdi						;r13 = *nodo a borrar
		mov rdi, [r13 + off_elem]			;rdi = *data

		call [rdi + off_remove]			;libero el dato del nodo

		mov rdi, [r12 + off_next]		;rdi = *nodo a borarr
		call free
		mov qword [r12 + off_next], NULL;*next = NULL
		jmp .fin

	.fin:
		mov rax, r14					;rax = *l
		add rsp, 8
		pop r14
		pop r13
		pop r12
		pop rbp
		ret


; void listDelete(list_t* l);
listDelete:
	push rbp							;alineada
	mov rbp, rsp
	push r12							;desalineada
	sub rsp, 8							;alineada

	mov r12, rdi						;r12 = *l

	.ciclo:
		cmp qword [r12 + off_data], NULL	;veo si prim es NULL
		je .fin

		mov rdi, r12						;rdi = *l
		call listRemoveFirst				;elimino el primer nodo
		jmp .ciclo

	.fin:
		mov rdi, r12						;rdi = *l
		call free							;libero la lista

		add rsp, 8
		pop r12
		pop rbp
		ret





; void listPrint(list_t* m, FILE *pFile);
listPrint:
	
	push rbp							;alineada
	mov rbp, rsp
	push r12							;desalineada
	push r13							;alineada

	mov r12, rdi						;r12 = *l
	mov r13, rsi						;r13 = *pFile

	.abrir:
	mov rdi, rsi						;rdi = *pfile
	mov rsi, printCI					;rsi = "["
	call fprintf

	mov r12, [r12 + off_data]			;apunto a prim
	cmp r12, NULL						;comparo si es NULL
	je .cerrar
	mov rsi, r13						;rdi = *pFile
	mov rdi, [r12 + off_elem]			;rdi = puntero al dato
	call [rdi + off_print] 				;llamo a print del dato

	mov r12, [r12 + off_next]			;apunto al siguiente
	
	.imprimir:
	cmp r12, NULL						;comparo si es NULL
	je .cerrar

	mov rdi, r13						;rdi = *pFile
	mov rsi, printComa 					;rsi = ","
	call fprintf

	mov rsi, r13						;rdi = *pFile
	mov rdi, [r12 + off_elem]			;rdi = puntero al dato
	call [rdi + off_print] 				;llamo a print del dato

	mov r12, [r12 + off_next]			;apunto al siguiente
	jmp .imprimir

	.cerrar:
	mov rdi, r13						;rdi = *pfile
	mov rsi, printCD					;rsi = "]"
	call fprintf

	.fin:
		pop r13
		pop r12
		pop rbp

	ret

;########### Funciones: String

; string_t* strNew();
strNew:
	; STACK
    sub rsp, 8

    ; MALLOC
    mov rdi, struct_size ; pido memoria para almacenar la estructura
    call malloc

    ; INT
    mov dword [rax + off_dataType], 2
    mov qword [rax + off_remove], strDelete
    mov qword [rax + off_print], strPrint
    mov qword [rax + off_data], NULL

    add rsp, 8
	ret

; string_t* strSet(string_t* s, char* c);
strSet:		; rdi = *s 	rsi = *c

	push rbp						;alineada
	mov rbp, rsp
	push rdi						;desalineada
	push rsi						;alineada

	mov rdi, [rdi + off_data]		;obtengo el puntero al string
	cmp rdi, NULL					;comparo si el puntero es NULL
	jne .conDato

	.sinDato:
		pop rsi			
		mov rdi, rsi				;rdi = puntero al string a copiar			
		call str_copy				;copio el string (rdi = puntero a string)

		pop rdi						;recupero el puntero a la estructura
		mov [rdi + off_data], rax 	;guardo el puntero a nuevo string
		mov rax, rdi				;rax = puntero a estructura

		jmp .fin

	.conDato:
		call free					;rdi = puntero al string
		jmp .sinDato

	.fin: 					 
		pop rbp
	ret

; string_t* strAddRight(string_t* s, string_t* d);
strAddRight:	;rdi = *s  rsi = *d
	push rbp						;alineada
	mov rbp, rsp
	push r12						;desalineada
	push r13						;alineada
	push rsi						;desalineada
	push rdi						;alineada
			

	mov r12, rdi					;r12 = *s

	mov rdi, [rdi + off_data]		;puntero al string s
	mov rsi, [rsi + off_data]		;puntero al string d

	call str_concat					;rax = puntero a s+d
	pop rdi							;recupero puntero a estr s

	mov rsi, rax					;rsi = *s+d
	mov r13, rax					;r13 = *s+d
	sub rsp, 8						;alineada
	call strSet						;pongo en estr s, s+d

	mov rdi, r13					;rdi = *s+d
	call free						;libero *s+d

	add rsp, 8
	pop rsi							;rsi = *d
	cmp rsi, r12					;comparo *s con *d
	je .fin
	
	mov rdi, rsi					;rdi = *d
	call strDelete 					;borro la estr d

	.fin:
	mov rax, r12					;rax = *s

	add rsp, 8
	pop r12
	pop rbp
	ret

; string_t* strAddLeft(string_t* s, string_t* d);
strAddLeft:		;rdi = *s  rsi = *d
	push rbp 						;alineada
	mov rbp, rsp
	push r12 						;desalineada
	sub rsp, 8						;alineada

	mov r12, rdi 					;hago swap de los parametros
	mov rdi, rsi					;rdi = *d
	mov rsi, r12					;rsi = *s

	call strAddRight

	add rsp, 8
	pop r12
	pop rbp
	ret

; string_t* strRemove(string_t* s);
strRemove:
	push rbp							;alineada
	mov rbp, rsp
	push rdi							;desalineada
	sub rsp, 8							;alineada

	mov rdi, [rdi + off_data] 			;leo el puntero a str
	call free 							;libero data

	add rsp, 8
	pop rdi								;recupero puntero a estructura
	mov qword [rdi + off_data], NULL	;pongo el puntero en NULL
	mov rax, rdi						;rax = puntero a estructura

	pop rbp
	ret


; void strDelete(string_t* s);
strDelete:
	sub rsp, 8		;alineada

	call strRemove 	;libero el string

	mov rdi, rax	;rdi = *s
	call free 		;libero estructura, en rdi ya tengo el puntero

	add rsp, 8
	ret


; int32_t strCmp(string_t* a, string_t* b);
strCmp:
	mov rdi, [rdi + off_data]
	mov rsi, [rsi + off_data]
	call str_cmp
	ret

; void strPrint(string_t* m, FILE *pFile);
strPrint:
	push rbp							;alineada
	mov rbp, rsp
	push r12							;desalineada
	sub rsp, 8							;alineada

	xor r12, r12						;limpio r12

	cmp qword [rdi + off_data], NULL	;comparo si es NULL
	jne .dato


	.vacio:
		mov rdi, rsi					;rdi = *pfile
		mov rsi, printNULL				;rsi = "NULL"
		call fprintf

		jmp .fin

	.dato:
		mov rdx, [rdi + off_data]		;r12 = *char

		mov rdi, rsi					;rdi = *pfile
	
		mov rsi, printString 			;rsi = "%s"
		
		call fprintf


	.fin:
		add rsp, 8
		pop r12
		pop rbp
		ret


;########### Funciones: Entero

; integer_t* intNew(); 11 instruccines
intNew:

  ; MALLOC
  mov rdi, struct_size ; pido memoria para almacenar la estructura
  call malloc

  ; INT
  mov dword [rax + off_dataType], 1
  mov qword [rax + off_remove], intDelete
  mov qword [rax + off_print], intPrint
  mov qword [rax + off_data], NULL

	ret

; integer_t* intSet(integer_t* i, int d); 15 instruccines
intSet:			; rdi = *i  esi = d
	cmp qword [rdi + off_data], NULL	; comparo si el puntero es NULL
	jne .conDato

.sinDato:

	push rdi					;alineada
	push rsi 					;desalineada
	sub rsp, 8					;alineada

	mov rdi, int_size			;parametro para usar malloc
	call malloc 				;pido memoria
	add rsp, 8
	pop rsi						;recupero dato
	pop rdi						;recupero el puntero a la estructura

	mov [rax], esi 				;en la posicion de memoria guardo el dato
	mov [rdi + off_data], rax	;pongo el puntero al dato en la estructura
	mov rax, rdi
	jmp .fin

.conDato:
	mov rax, rdi ; guardo el resultado

	mov rdi, [rdi + off_data] 	;obtengo el puntero
	mov [rdi], esi				;piso el dato

.fin:
	ret

; integer_t* intRemove(integer_t* i); 11 instruccines
intRemove:
	;STACK
	push rbp					;alineada
	mov rbp, rsp
	push r12					;desalineada
	sub rsp, 8					;alineada

	mov r12, rdi				;r12 = *i
	mov rdi, [rdi + off_data] 	;leo el puntero a data
	call free 					;libero data

	mov qword [r12 + off_data], NULL	;pongo el puntero en NULL
	mov rax, r12

	add rsp, 8
	pop r12
	pop rbp
	ret

; void intDelete(integer_t* i); 6 instruccines
intDelete:

	call intRemove 	;libero el int

	mov rdi, rax
	call free 		;libero estructura, en rdi ya tengo el puntero

	ret

; int32_t intCmp(integer_t* a, integer_t* b); 10 instruccines
intCmp:			; rdi = *a   rsi = *b

	mov rax, [rsi + off_data]	;rax = *data_b
	mov eax, [rax]				;eax = int (b)

	mov rcx, [rdi + off_data]	;rax = *data_a
	mov ecx, [rcx]				;ecx = int (a)


	cmp eax, ecx				;comparo los enteros
	jg .menor
	jl .mayor

	.iguales:
		mov eax, 0
		jmp .fin
	.menor:
		mov eax, 1
		jmp .fin
	.mayor:
		mov eax, -1

	.fin:
		ret

; void intPrint(integer_t* m, FILE *pFile); 14 instruccines
intPrint:   	;rdi = *m  rsi = *pFile
	push rbp							;alineada
	mov rbp, rsp
	push r12							;desalineada
	sub rsp, 8							;alineada

	xor r12, r12						;limpio r12

	cmp qword [rdi + off_data], NULL	;comparo si es NULL
	jne .dato


	.vacio:
		mov rdi, rsi					;rdi = *pfile

		mov rsi, printNULL				;rsi = "NULL"

		call fprintf

		jmp .fin

	.dato:
		mov r12, [rdi + off_data]		;r12 = *m
		mov r12, [r12]					;r12 = int

		mov rdi, rsi					;rdi = *pfile

		mov rsi, printInt 				;rsi = "%i"

		mov rdx, r12					;rdx = int

		call fprintf


	.fin:
		add rsp, 8
		pop r12
		pop rbp
		ret
