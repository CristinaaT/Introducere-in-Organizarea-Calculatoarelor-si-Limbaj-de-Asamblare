extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

xor_strings:
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8] ; primul argument de pe stiva
	mov ebx, [ebp + 12] ; al doilea argument de pe stiva

xoring:
	xor eax, eax
	mov al, [ecx]
	mov ah, [ebx]
	xor al, ah
	mov byte[ecx], al
	inc ecx
	inc ebx
	xor eax, eax
	mov al, [ecx]
	cmp al, 0
	jnz xoring

	leave
	ret

rolling_xor:
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8] ; primul argument de pe stiva
	mov eax, [ebp + 8]

cauta_ultimul_caracter:
	inc eax
	xor ebx, ebx
	mov bl, [eax]
	cmp bl, 0
	jnz cauta_ultimul_caracter

	dec eax ; adresa ultimul caracter

aplica_xor_cu_precedentul:
	xor ebx, ebx
	mov bl, [eax]
	dec eax
	mov bh, [eax]
	xor bl, bh
	inc eax
	mov byte[eax], bl
	dec eax	
	cmp eax, ecx
	jnz aplica_xor_cu_precedentul

	leave
	ret

xor_hex_strings:
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8] ; primul argument de pe stiva
	mov ebx, [ebp + 12] ; al doilea argument de pe stiva
	xor edx, edx
	mov edx, ecx

transformare_sir:
	xor eax, eax
	mov al, [ecx]
	cmp al, 97
	jge litera_sir
	sub al, '0'
	jmp al_doilea_element_din_sir

litera_sir:
	sub al, 97
	add al, 10	
	
al_doilea_element_din_sir:
	inc ecx
	mov ah, [ecx]
	cmp ah, 97
	jge litera_sir_2
	sub ah, '0'
	jmp final_sir

litera_sir_2:
	sub ah, 97
	add ah, 10

final_sir:
	shl al, 4
	add al, ah
	mov byte[edx], al
	inc edx
	inc ecx
	xor eax, eax
	mov al, [ecx]
	cmp al, 0
	jnz transformare_sir

	mov byte[edx], 0

	xor edx, edx
	mov edx, ebx
transformare_cheie:
	xor eax, eax
	mov al, [ebx]
	cmp al, 97
	jge litera_cheie
	sub al, '0'
	jmp al_doilea_element_din_cheie

litera_cheie:
	sub al, 97
	add al, 10	
	
al_doilea_element_din_cheie:
	inc ebx
	mov ah, [ebx]
	cmp ah, 97
	jge litera_cheie_2
	sub ah, '0'
	jmp final_cheie

litera_cheie_2:
	sub ah, 97
	add ah, 10

final_cheie:
	shl al, 4
	add al, ah
	mov byte[edx], al
	inc edx
	inc ebx
	xor eax, eax
	mov al, [ebx]
	cmp al, 0
	jnz transformare_cheie

	mov byte[edx], 0

	leave
	ret

base32decode:
	; TODO TASK 4
	ret

bruteforce_singlebyte_xor:
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8]
	mov ebx, ecx

cauta_cheia:
	inc ebx
	mov al, [ebx]
	cmp al, 0
	jnz cauta_cheia

	inc ebx
	mov al, [ebx]

bruteforce_xoring:
	xor edx, edx
	mov dl, [ecx]
	xor dl, al
	mov [ecx], dl
	inc ecx
	xor edx, edx
	mov dl, [ecx]
	cmp dl, 0
	jnz bruteforce_xoring

	leave
	ret

decode_vigenere:
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8] ; primul argument de pe stiva, sirul
	mov ebx, [ebp + 12] ; al doilea argument de pe stiva, cheia
	xor edx, edx
	mov edx, ebx ; salvam cheia, poate o mai folosim

transformare_vigenere:
	xor eax, eax
	mov al, [ecx] ; mutam caracterul curent din sir
	cmp al, 'a' ; vedem daca e litera
	jge este_litera
	jmp verificare_sir

este_litera:
	mov ah, [ebx] ; mutam caracterul curent din cheie
	sub ah, 'a' ; calculam offset-ul fata de 'a'
	sub al, ah
	cmp al, 'a' ; vedem daca trecem de 'a'
	jb depasire
	mov [ecx], al ; rescriem rezultatul
	
	xor eax, eax
	inc ebx ; mergem pe urmatorul caracter din cheie
	mov al, [ebx]
	cmp al, 0
	jnz verificare_sir
	mov ebx, edx ; reiau cheia de la inceput
	jmp verificare_sir

depasire:
	mov ah, 'a'
	sub ah, al ; vedem cu cat depasim
	dec ah
	mov al, ah
	mov ah, 'z' ; punem 'z'
	sub ah, al ; scadem cat am depasit
	mov [ecx], ah ; rescriem rezultatul

	xor eax, eax
	inc ebx ; 
	mov al, [ebx]
	cmp al, 0
	jnz verificare_sir
	mov ebx, edx

verificare_sir:
	xor eax, eax
	inc ecx
	mov al, [ecx]
	cmp al, 0
	jnz transformare_vigenere 

	leave
	ret

main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
	; TASK 1: Simple XOR between two byte streams

	xor ebx, ebx
	mov ebx, ecx

cauta_cheie:
	inc ebx
	mov al, [ebx]
	cmp al, 0
	jnz cauta_cheie

	inc ebx ; adresa cheii
	push ecx ; salvam adresa sirului

	push ebx ; punem cheia 
	push ecx ; punem sirul
	call xor_strings

	add esp, 8 ; scoatem de pe stiva cheia si sirul
	; pe stiva a ramas adresa sirului
	call puts ; print resulting string
	add esp, 4 ; scoatem si ultimul element de pe stiva

	jmp task_done

task2:
	; TASK 2: Rolling XOR

	push ecx ; salvam adresa sirului	

	push ecx ; punem sirul
	call rolling_xor

	add esp, 4 ; scoatem sirul
	;pe stiva a ramas adresa sirului
	call puts
	add esp, 4 ; scoatem si ultimul element de pe stiva

	jmp task_done

task3:
	; TASK 3: XORing strings represented as hex strings

	xor ebx, ebx
	mov ebx, ecx

cauta_cheie_hex:
	inc ebx
	mov al, [ebx]
	cmp al, 0
	jnz cauta_cheie_hex

	inc ebx ; adresa cheii
	push ecx ; salvam adresa sirului
	push ebx ; salvam adresa cheii

	push ebx ; punem cheia
	push ecx ; punem sirul
	call xor_hex_strings ; doar le transformam din hex in binary

	add esp, 8 ; scoatem cheia si sirul

	pop ebx ; restauram cheia
	pop ecx ; restauram sirul

	push ecx ; salvam sirul
	
	push ebx ; punem cheia
	push ecx ; punem sirul

	call xor_strings
	add esp, 8 ; scoatem elementele
	; a ramas adresa sirului pe stiva
	call puts	
	add esp, 4 ; scoatem si ultimul element

	jmp task_done

task4:
	; TASK 4: decoding a base32-encoded string

	; TODO TASK 4: call the base32decode function
	
	push ecx
	call puts                    ;print resulting string
	pop ecx
	
	jmp task_done

task5:
	; TASK 5: Find the single-byte key used in a XOR encoding
	mov ebx, ecx
	
cauta_final:
	inc ebx
	mov al, [ebx]
	cmp al, 0
	jnz cauta_final

	inc ebx
	mov [ebx], byte 142

	push ecx ; salvam adresa sirului

	push ecx
	call bruteforce_singlebyte_xor
	add esp, 4

	pop ecx

	push ecx                    ;print resulting string
	call puts
	pop ecx

	mov eax, dword 142
	push eax                    ;eax = key value
	push fmtstr
	call printf                 ;print key value
	add esp, 8

	jmp task_done

task6:
	; TASK 6: decode Vignere cipher

	xor ebx, ebx
	mov ebx, ecx

cauta_cheie_vigenere_cipher:
	inc ebx
	mov al, [ebx]
	cmp al, 0
	jnz cauta_cheie_vigenere_cipher

	inc ebx ; adresa cheii

	push ecx ; salvam adresa sirului

	push ebx ; punem cheia pe stiva
	push ecx ; punem sirul pe stiva

	call decode_vigenere
	add esp, 8 ; scoatem cheia si sirul de pe stiva

	call puts
	add esp, 4 ; scoatem si ultimul element de pe stiva

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
