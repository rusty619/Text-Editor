.model tiny
.386
;org 100h
.data
 
 Filename db 'hello.txt',0
 Handle dw ?
 Buff db ? 
 StringArray dw 30 dup(0)
 OpenErrorMsg db 10,13,'can not open file$'
 ReadFileErrorMsg db 10,13,'can not read file$'
 WriteFileErrorMsg db 10,13,'can not write file$'
 CloseFileErrorMsg db 10,13,'can not close file$' 
 Saved db 10,13 ,"It's Saved$"
 
 
 .code
  org 100h
 .startup
      
      mov ah,0
      mov al,3
      int 10h ; set the video mode and clears the screen
      
      mov ah,6
      xor al,al
      mov bh,1eh ; blue background with yellow text
      xor cx,cx
      mov dx,184fh
      int 10h  
      
      call OpenFile ; open the file
      jc end1
      call ReadFile ; read the file
      ;call CloseFile ; close the file 
      call key
      
        
             
    key:   
        mov ah,2
        mov dh,0
        mov dl,0
        mov bh,0
        int 10h ; positions the cursor on the top left corner
      
   get:
      mov ah,0
      int 16h ; ah = scan code , al = ascii code
      
   check:
      cmp al,1bh ;checks to see if you press ESC button
      je end1 ; if yes jump to end
      
      cmp ah,0eh ;checks if you pressed BACKSPACE
      je backspace  
      
      cmp al,0dh ; checks to see if you pressed enter
      je loop_video_memory   ;je loop_video_memory   ; if yes jump to write
      
      cmp al,0 ; checks if you buttoned null(nothing)
	  jne check_next ;  no  a key was pressed
      
      call dir
      jmp next 
 
  check_next:
	           mov ah,2
	           mov dl,al
	           int 21h    ; display the character you just entered
	               
      
   next:
      mov ah,0
      int 16h
      jmp check
      
   dir:
      push bx
      push cx
      push dx
      push ax
      
      mov ah,3
      mov bh,0
      int 10h
      pop ax ; get location
      
      cmp ah,75 ; LEFT ARROW
      je go_left
      
      cmp ah,77 ; RIGHT ARROW
      je go_right
      
      jmp EXIT
      
  go_left:
      cmp dl,0
      je line
      dec dl
      jmp EXECUTE
      
  go_right:
      cmp dl,4fh
      je new_line
      inc dl
      jmp EXECUTE 
      
  backspace:
      mov ah,2
      mov dl,20h
      int 21h
      mov dl,8
      int 21h
      jmp get    
      
  line:
      cmp dh,0
      je no_jump
      dec dh
      mov ah,2
      mov bh,0
      mov dh,dh
      mov dl,4fh
      int 10h
      jmp EXIT
      
  no_jump:
      mov ah,2
      mov bh,0
      mov dx,0
      int 10h
      jmp EXIT
      
  new_line:
      cmp dh,18h
      je no_new_jump
      inc dh
      mov ah,2
      mov bh,0
      mov dh,dh
      mov dl,1
      int 10h
      jmp EXIT
      
  no_new_jump:
      mov ah,2
      mov bh,0
      mov dh,18h
      mov dl,4fh
      int 10h
      jmp EXIT
      
  EXECUTE:
      mov ah,2
      int 10h
  
  EXIT:
      pop dx
      pop cx
      pop bx
      
      ret
      
  end1:
       call closefile
       mov ah,4ch
       int 21h
       
    
  loop_video_memory:
       mov ax, 0b800h
       mov es, ax
       mov si, 0
       mov di, 0
       mov cx, 80
  loop_array:
      mov ax, es:[si];mov ax, es:si the orginal code didn't work on DOS
      mov [StringArray + di], ax
      add si,2
      add di,1
      loop loop_array

  
  write:

       ;delete file to delete what was inside
       mov ah,41h
       lea dx,filename
       int 21h

       ;create new file
       mov ah,3ch
       mov cx,2
       lea dx,Filename
       int 21h
       ;jc CreateError
       mov handle,ax
       
       
       mov ah,40h  ;write to file
       mov bx,handle
       mov cx,30 
       mov al,2
       lea dx,StringArray
       int 21h 
       ;jc WriteError 
  save:
       lea dx,saved
       mov ah,9
       int 21h
       ;call closefile     
       jmp end1           
   ;writeError:
    ;   lea dx,WriteFileErrorMsg
     ;  mov ah,9
      ; int 21h
      ; mov ah,4ch
      ; int 21h 
       
     
   OpenFile proc near
      mov ax,3d02h ;open file with handle
      Lea dx,Filename
      int 21h
      jc OpenError
      mov handle,ax
      ret
  OpenError:
      Lea dx,OpenErrorMsg ; set up pointer to open error message
      mov ah,9
      int 21h ; set error flag
      STC
      ret
  OpenFile ENDP
   
   ReadFile proc Near
       mov ah,3fh ; read from file function
       mov bx,handle
       lea dx,buff
       mov cx,1
       int 21h
       jc ReadError
       cmp ax,0
       jz EOff
       mov dl,buff
       cmp dl,1ah
       jz EOff
       mov ah,2
       int 21h
       jmp ReadFile
   
   ReadError:
       lea dx,ReadFileErrorMsg
       mov ah,9
       int 21h
       STC
   EOff:
       ret
   ReadFile Endp
   
   CloseFile proc near
       mov ah,3eh
       mov bx,handle
       int 21h
      ; jc CloseError
       ret
   ;CloseError:
   ;    lea dx,CloseFileErrorMsg
   ;    mov ah,9
   ;    int 21h
   ;    STC
   ;    ret
   CloseFile endp
     
 
     
   end   
