datasg    SEGMENT BYTE 'veri'
n dw 10
sonuc dw 0
dizi dw 10 dup(?)
datasg    ENDS
stacksg    SEGMENT BYTE STACK 'yigin'
DW 100 DUP(?)
stacksg    ENDS
codesg    SEGMENT PARA 'kod'
ASSUME CS:codesg, DS:datasg, SS:stacksg



ANA        PROC FAR
PUSH DS               
XOR AX, AX
PUSH AX
MOV AX, datasg        
MOV DS, AX
                            
							
push n              ;girilen n sayısı stack'e atıldı

call far ptr Conway      

;call far ptr Conway_dynamic ;Bonus kısım için yaptığım fonksiyon;Eksik kısımları var

pop ax        

mov sonuc,ax

call printint

RETF                           

ANA        ENDP                        

Conway proc far
       
   push ax 	   ;kullanılan registerlar stack'te tutuluyor
   push bx
   push cx
   push bp

mov bp,sp     
mov ax,[bp+12]    ;4 tane bizim pushladığımız değer+2 tane proc far'dan gelen değer var=12 ax=n; bp'nin gösterdiği yerin 12 byte altında n var


mov bx,ax	   ;bx=n           ax ileride kullanılacak ve değişecek. bu yüzden yedeği bx'te tuttum            

cmp ax,0
je return0
cmp ax,1
je return1
cmp ax,2	   ;n=0,1,2 ise ilgili return dallanması yapılır
je return1        

dec ax
push ax                
call far ptr conway  ;cx=a(n-1) burasi tekrar kullanilacak
pop cx

push cx               
call far ptr conway  ;ax=a(a(n-1))
pop ax

sub bx,cx 			 ;bx=n-a(n-1)
push bx
call far ptr conway
pop bx				 ;bx=a(n-a(n-1))

add ax,bx			 ;ax=a(a(n-1)+a(n-a(n-1))
jmp end_proc

return0:
xor ax,ax ;ax=0 ise
jmp end_proc

return1: 
mov ax,1;ax=1 ise

end_proc:
mov [bp+12],ax;stack'teki register değerlerinin hemen altına sonucu koyuyorum 

   pop bp
   pop cx
   pop bx
   pop ax ;procedure bitince registerlar proc başlamadan önceki haline geri getirilir
retf
Conway endp

Conway_dynamic proc far;Bu kısımda bonus kısmı yapmaya çalıştım fakat bu procedure içinden ana data segment'teki diziye erişirken sorun yaşadım.Bundan dolayı eksik kaldı
   push ax 	   ;Erişim düzgün yapıldığında program da düzgün çalışacaktır
   push bx
   push cx
   push dx
   push bp
   push si
   push di		;kullanılan registerlar stack'te tutuluyor
   
   mov bp,sp
   mov cx,[bp+18];7 tane bizim pushladığımız değer + 2 tane proc far'dan gelen değer=18 ;sp'nin 18 byte altında n bilgisi tutuluyor
   ;cx son n değerini verecek

   mov dizi[0],0;dizinin initial değerlerini verdim
   dec cx
   mov dizi[1],1;dizinin initial değerlerini verdim
   dec cx
   mov dizi[2],1;dizinin initial değerlerini verdim
   dec cx

   mov dx,3;şu anki n
   mov si,4; n-1 index
label1:

   mov bx,dizi[si];bx=a(n-1)
   mov ax,dizi[bx];ax=a(a(n-1))

   push dx; dx=n
   sub dx,bx;dx=n-a(n-1)
   mov di,dx
   mov bx,dizi[di];bx=a(n-a(n-1))
   
   add ax,bx ;ax=a(a(n-1)+a(n-a(n-1))
   
   pop dx ;dx=n
   add si,2
   mov dizi[si],ax
   inc dx
   loop label1
   
   mov [bp+18],ax  ;stack'teki register değerlerinin altına sonucu koydum
   pop di
   pop si
   pop bp
   pop dx
   pop cx
   pop bx
   pop ax
   
   retf

Conway_dynamic endp

;Başta int 21h ile yapmayı denedim fakat başaramadım. Ardından stackoverflow'daki bir çözümü gördüm
;https://stackoverflow.com/questions/1922134/printing-out-a-number-in-assembly-language
PRINTINT proc
 CMP AL, 0 ; al 0 ise direkt olarak 0'ın ascii değeri basılır
 JNE PRINT_AX
 PUSH AX
 MOV AL, '0'
 MOV AH, 0EH
 INT 10H		;ah 0eH iken int 10h teletype output yapar ;al'deki değeri prompt'a basar
 POP AX
 RET 
    PRINT_AX:    
 PUSH Ax
 MOV AH, 0
 CMP AX, 0
 JE PN_DONE;ax 0 değilse 10 a bölünür. 0 ise basılması gereken değer ah'tadır ve proc'tan çıkınca bu değer basılır;proctan çıkınca parent proc'un 164. satırdan devam eder
 MOV DL, 10
 DIV DL    
 CALL PRINT_AX
 MOV AL, AH;remainder al'ye atılır
 ADD AL, 30H;30h=48;48 ascii tablosunda 0 değerini gösteriyor. Rakamın değerine 48'e eklersek ilgili rakamın ascii karşılığını buluruz.
 MOV AH, 0EH
 INT 10H    
    PN_DONE:
 POP Ax  
 RET  
PRINTINT endp




codesg    ENDS
END ANA