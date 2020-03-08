;Tomoescu Iulia Cristina, 324CC

%include "io.inc"
%define MAX_INPUT_SIZE 4096

section .bss
	expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
	mov ebp, esp
        push ebp

	GET_STRING expr, MAX_INPUT_SIZE
        
        ;Aflu lungimea expresiei (se cauta prima aparitie a terminatorului de sir)
        mov edi, expr
        mov al, 0
        cld
        repne scasb
        sub edi, expr
        dec edi

        mov ecx, 0
        
;Parcurg expresia 
for:
        cmp ecx, edi
        jl comparare
        
        jmp print
        
;Vedem ce semnificatie are byte-ul curent: operator, spatiu sau cifra
comparare:
        cmp byte [expr + ecx], 32         ;" "
        je spatiu  
        cmp byte [expr + ecx], 42         ;"*"
        je inmultire 
        cmp byte [expr + ecx], 43         ;"+"
        je adunare
        cmp byte [expr + ecx], 45         ;"-" 
        je minus
        cmp byte [expr + ecx], 47         ;"/"
        je impartire              
        jmp numar_1                       ;Daca nu este "*", "-", "+", "/" sau " " atunci este o cifra      
  
;Numar format dintr-o cifra
;Formula de calculc: cifra unitatilor * 1         
numar_1:
        cmp byte [expr + ecx + 2], 32     ;Verific daca numarul are doua cifre
        je numar_2
        cmp byte [expr + ecx + 1], 32     ;Verific daca numarul are trei cifre
        jne numar_3
        movzx eax, byte [expr + ecx]      ;Cifra unitatilor 
        mov ebx, 48
        sub eax, ebx
        cmp byte [expr + ecx - 1], 45     ;Verific daca numarul este negativ 
        je numar_1_negativ
        push eax                          ;Adaug numarul in stiva
        inc ecx
        jmp for
     
numar_1_negativ:
        neg eax                           ;Neg numarul, deoarece nu il pot adauga cu -
        push eax                          ;Adaug numarul in stiva
        inc ecx
        jmp for

;Numar format din 2 cifre
;Formula de calcul: cifra zecilor * 10 + cifra unitatilor * 1 
numar_2:
        movzx eax, byte [expr + ecx]      ;Cifra zecilor 
        mov ebx, 48
        sub eax, ebx      
        mov ebx, 10
        mul ebx                            
        movzx ebx, byte [expr + ecx + 1]  ;Cifra unitatilor
        mov edx, 48
        sub ebx, edx
        add eax, ebx                       
        cmp byte [expr + ecx - 1], 45     ;Verific daca numarul este negativ 
        je numar_2_negativ
        push eax                          ;Adaug numarul in stiva 
        add ecx, 2
        jmp for
        
numar_2_negativ:
        neg eax                           ;Neg numarul, deoarece nu il pot adauga cu -
        push eax                          ;Adaug numarul in stiva 
        add ecx, 2
        jmp for
 
;Numar format din 3 cifre  
;Formula de calcul: cifra sutelor * 100 + cifra zecilor * 10 + cifra unitatilor * 1    
numar_3:
        movzx eax, byte [expr + ecx]      ;Cifra sutelor
        mov ebx, 48
        sub eax, ebx
        mov ebx, 100
        mul ebx
        mov esi, eax                      ;Aici este stocat calculul
        movzx eax, byte [expr + ecx + 1]  ;Cifra zecilor
        mov ebx, 48
        sub eax, ebx
        mov ebx, 10
        mul ebx
        add esi, eax                      ;Facem primele doua adunari din calcul
        movzx eax, byte [expr + ecx + 2]  ;Cifra unitatilor
        mov ebx, 48
        sub eax, ebx
        add esi, eax       
        cmp byte [expr + ecx - 1], 45     ;Verific daca numarul este negativ
        je numar_3_negativ
        push esi                          ;Adaug numarul in stiva 
        add ecx, 3
        jmp for 
        
numar_3_negativ:   
        neg esi                           ;Neg numarul, deoarece nu il pot adauga cu -
        push esi                          ;Adaug numarul in stiva 
        add ecx, 3
        jmp for 

;Cazul in care byte-ul curent este spatiu
spatiu:
        inc ecx
        jmp for

;Cazul in care byte-ul curent este "*"               
inmultire:
        ;Scot ultimele doua valori din stiva
        pop eax
        pop ebx
        imul eax, ebx                     ;Le inmultim
        push eax                          ;Adaug rezultatul in stiva 
        inc ecx
        jmp for

;Cazul in care byte-ul curent este "*" 
adunare:
        ;Scot ultimele doua valori din stiva
        pop eax
        pop ebx
        add eax, ebx
        push eax                          ;Adaug rezultatul in stiva 
        inc ecx
        jmp for

;Cazul in care byte-ul curent este "-": fie este pentru operatia de scadere, fie pentru un numar negativ        
minus:
        cmp byte [expr + ecx + 1], 32    ;Spatiu
        je scadere
        cmp byte [expr + ecx + 1], 0     ;Final de sir
        je scadere
        ;In cazul in care este pentru un numar negativ, incrementez ecx si merg in label-ul numar_1, pentru
            ;a continua de acolo si a afla daca este un numar negativ de o cifra, 2 sau 3
        inc ecx
        jmp numar_1
                
        
scadere:
        ;Scot ultimele doua valori din stiva
        pop eax
        pop ebx
        cmp ebx, eax                      ;Compar numerele, iar daca scaderea ar da negativa
        jl scadere_negativa                   ;sare la label-ul scadere_negativa
        sub ebx, eax                      ;Se face scaderea "normala"
        push ebx                          ;Adaug rezultatul in stiva 
        inc ecx
        jmp for
        
scadere_negativa:
        sub eax, ebx                      ;Fac scaderea "inversa" astfel incat rezultatul sa fie poziti
        neg eax                           ;Neg rezultatul
        push eax                              ;si il adaug in stiva 
        inc ecx
        jmp for
                
impartire:
        ;Scot ultimele doua valori din stiva
        pop ebx
        pop eax
        cdq
        idiv ebx                          ;Le impart
        push eax                          ;Adaug rezultatul in stiva
        inc ecx
        jmp for
	
print:
        pop eax                           ;Scot rezultatul final din stiva
        cmp eax, 0                        ;Il compar cu 0 si daca este mai mic
        jl print_negativ                      ;sare la label-ul print_negativ
        PRINT_UDEC 4, eax                 ;Printez rezultatul
        jmp exit
        
print_negativ:
        neg eax                           ;Neg rezultatul final aducandu-l astfel la forma sa pozitiva
        PRINT_STRING "-"                  ;Printez "-" urmat de
        PRINT_UDEC 4, eax                   ;rezultatul final in forma pozitiv
        jmp exit
        
exit:
	mov esp, ebp
	ret
