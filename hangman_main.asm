.data 
    fin: .asciiz "DETHI.txt"
    fout: .asciiz "NGUOICHOI.txt"
    message: .asciiz "The word to guess is:\n "
    userNameInput: .asciiz "Input username(contain 0-9,a-z,A-Z):\n"
    userName: .space 10
    score: .word 0
    enter: .asciiz "\n"
    string: .space 2000
    wordArr: .space 2000
    randWord: .space 20
    guessWord: .space 20
    imGuess: .space 20
    outOfWord: .asciiz "You have finished all question. Congratulation!!!"
    continuePlay: .asciiz "You Lost, Play again?"
    character: .space 5
    characterMess: .asciiz "Input a character: "
    wordMess: .asciiz "Input word: "
    errorMess: .asciiz "Current error is: "
    guessMess: .asciiz "1.Input character 2.Input Word:\n"
    hangman1: .asciiz "----------------\n|/\t|\n|\n|\n|\n"
    hangman2: .asciiz "----------------\n|/\t|\n|\tO\n|\n|\n"
    hangman3: .asciiz "----------------\n|/\t|\n|\tO\n|\t|\n|\n"
    hangman4: .asciiz "----------------\n|/\t|\n|\t\o\n|      /|\n"
    hangman5: .asciiz "----------------\n|/\t|\n|\t\o\n|      /|\\\n|\n"
    hangman6: .asciiz "----------------\n|/\t|\n|\t\o\n|      /|\\\n|      /\n"
    hangman7: .asciiz "----------------\n|/\t|\n|\t\o\n|      /|\\\n|      / \\\n"
.text
main:

#########################  XU LY FILE #################################

    #Mo file
    li $v0, 13
    la $a0, fin
    li $a1, 0
    li $a2, 0
    syscall
    move $s6, $v0 #luu trang thai file
    #Doc file
    li	$v0, 14
    move $a0, $s6
    la	$a1, string
    li	$a2, 1000
    syscall
    move $s0, $v0 #luu so ki tu doc duoc vao s7
    addi $s0, $s0, -7 #tru di 7 la so ki tu cua chu cai cuoi de tranh ran vo chu cuoi cung
    #Dong file
    li	$v0, 16
    move $a0, $s6
    syscall
    li $s2,0#So de
    
############################# THAN CHINH HAM MAIN ####################################

#Nhap username:
reinput:
    li $v0,54
    la $a0,userNameInput
    la $a1,userName
    li $a2,10
    syscall
    #Tham so
    la $a1,userName
    #kiem tra ten nguoi dung
    jal _checkUserName
    #goi ham random vi tri trong chuoi
reRandom:
    jal _randomPos
    #vi tri random luu tren a0
    la $a1,string #load dia chi cua chuoi vao t0
    #neu rand vao index 0 goi ham luu chu rieng
    beqz $a0,_storeRanWordIndexZero
    add $a1,$a1,$a0 #bat dau tinh tu vi tri random
    #kiem tra vi tri bat dau doc tu
    checkPos: lb $t0,($a1)
              beq $t0,42,valid #kiem tra gap ki tu '*'
              add $a1,$a1,1 #set byte tiep theo
              j checkPos
    valid: #neu gap ki tu '*' goi ham luu chu 
              jal _storeRanWord
    #Xuat chuoi random
startProm:   
    li $v0,4
    la $a0,randWord
    syscall
    #Xuong dong
    li $v0,4
    la $a0,enter
    syscall
    la $a1,randWord #truyen tham so
    #goi ham tinh chieu dai chu random
    jal _wordLenght
    move $a2,$v0 #luu do dai chuoi vao a2  
    #Xuong dong
    li $v0,4
    la $a0,enter
    syscall
    #Luu de vao chuoi tu da choi
    #Kiem tra het de
    la $a1,randWord #tham so
    jal _checkOutWord #goi ham kiem tra de da ton tai
    move $s5,$v0 #ket qua tra ve v0
    beq $s5,1,equalWordArr #de da ton tai
    j startInit #nguoc lai bat dau tao chuoi doan
    equalWordArr:
        jal _delString #goi ham xoa chuoi
        jal _delGuessString
        j reRandom #random lai
startInit: 
    la $a1,guessWord #truyen tham so 
    jal _initGuessWord #ham khoi tao chuoi an
    #Xuat chuoi an tren box mess
    ######Xu li nhap ki tu o day ######### 
    jal _userIntputChar 
    ####### Neu thang thi goi ham them de da choi, thua thi nhay ve endmain
    addi $s2,$s2,1
    la $a1,randWord
    jal _wordLenght
    move $a2,$v0
    #Them tu vao chuoi nhung tu da choi
    la $a1,randWord
    jal _addWordArr
    li $v0,4
    la $a0,wordArr
    syscall
    li $v0,4
    la $a0,enter
    syscall
    beq $s2,5,outOfWordEnd #het de!! nhay ve thoat
    #Xuong dong
    jal _delString
    jal _delGuessString
    j reRandom
#thoat khi het de
outOfWordEnd:
    li $v0,55
    la $a0,outOfWord
    li $a1,2
    syscall
    li $v0,10
    syscall
#thoat khi thua
endmain:
    #Hoi nguoi choi choi tiep hay nghi 
    li $v0,50  
    la $a0,continuePlay
    syscall
    #a0 chua lua chon 0 choi tiep 1,2 thoat
    beq $a0,0,reRandom
    li $v0,10
    syscall
 
##################################  CAC HAM XU LY #####################################################################
  
    _randomPos: move $a1,$s0 #a1 la gioi han random
               li,$v0,42 #Ket qua random luu tren a0
               syscall
               jr $ra #Quay ve
    #Ham luu chu da random
    _storeRanWord: 
    #tao stack
              addi $sp,$sp,-12
              sw $t0,($sp)
              sw $t1,4($sp)
              sw $ra,8($sp)
              la $t0,randWord
	      addi $a1, $a1, 1
	      loop_StoreWord:
	              lb $t1, ($a1)
	              beq $t1, 42, exit_StoreWord 
	              beqz $t1, exit_StoreWord		
	              sb $t1,($t0)
	              addi $a1, $a1, 1
	              addi $t0, $t0, 1
	              j loop_StoreWord
	      exit_StoreWord:
	              #Restore thanh ghi
                       lw $t0,($sp)
                       lw $t1,4($sp)
                       lw $ra,8($sp)
                       #Xoa stack
                       addi $sp,$sp,12
                       #Quay ve
	               jr $ra
    #Ham tinh chieu dai chu:
    _wordLenght:#tao stack
              addi $sp,$sp,-12
              sw $t0,($sp)
              sw $t1,4($sp)
              sw $ra,8($sp)
              #Khoi tao bien
              li $t0,0
              li $t1,0
              loop_wordLenght:
                       lb $t0,($a1)
                       beqz $t0,exit_wordLenght
                       addi $a1,$a1,1
                       addi $t1,$t1,1
                       j loop_wordLenght
	      exit_wordLenght:
	              #luu kq vao v0
	               move $v0,$t1
	              #Restore thanh ghi
                       lw $t0,($sp)
                       lw $t1,4($sp)
                       lw $ra,8($sp)
                       #Xoa stack
                       addi $sp,$sp,12
                       #Quay ve
	               jr $ra
     _initGuessWord: addi $sp,$sp,-12
                    sw $t0,($sp)
                    sw $t1,4($sp)
                    sw $ra,8($sp)
                    #Khoi tao bien
                    li $t0,42 #Dau '*'
                    li $t1,0
              loop_init:
                       beq $a2,$t1,exit_init #a2 dang chua do dai chuoi random
                       sb $t0,($a1) #luu ki tu '*' vao tu can doan
                       addi $a1,$a1,1 #di den ki tu ke tiep
                       addi $t1,$t1,1 #tang bien dem
                       j loop_init
	      exit_init:
	              #Restore thanh ghi
                       lw $t0,($sp)
                       lw $t1,4($sp)
                       lw $ra,8($sp)
                       #Xoa stack
                       addi $sp,$sp,12
                       #Quay ve
	               jr $ra   
    #Kiem tra username:	                
    _checkUserName: 
              addi $sp,$sp,-8
              sw $t0,($sp)
              sw $ra,4($sp)
              loop_checkUserName:
                       lb $t0,($a1) 
                       beq $t0,10,exit_checkUserName#gap xuong dong thoat
                       blt $t0,123,check1
                       j reinput#neu lon hon 123 nhap lai
              continue:addi $a1,$a1,1 #di den ki tu ke tiep
                        j loop_checkUserName 
              check1: blt $t0,97,check1con #kiem tra tu a-z
                      j continue    
              check1con:bgt $t0,90,reinput############
                      j check2
              check2: blt $t0,65,check2con#kiem tra tu A-Z"
                      j continue
              check2con:bgt $t0,57,reinput########
                      j check3
              check3: blt $t0,48,reinput#kiem tra tu 0-9
	      exit_checkUserName:
                       #Quay ve
                       lw $t0,($sp)
                       lw $ra,4($sp)
                       addi $sp,$sp,8
	               jr $ra
  #Them vao chuoi da dc doan                            
   _addWordArr:
              addi $sp,$sp,-20
              sw $t0,($sp)
              sw $t1,4($sp)
              sw $t2,8($sp)
              sw $t3,12($sp)
              sw $ra,16($sp)
              #a1 chua chuoi de bai
              #a2 chua do dai chuoi de bai
              li $t1,42
              la $t0,wordArr
              li $t2,0
              li $t3,0
              #di den cuoi chuoi:
              loopEndWord:
                    lb $t2,($t0)
                    beqz $t2,loopAddWordArr
                    addi $t0,$t0,1
                    j loopEndWord
              #them chuoi vao mang:
              loopAddWordArr:
                     beq $a2,$t3,exitAddWordArr
                     lb $t2,($a1)
                     sb $t2,($t0)
                     addi $a1,$a1,1
                     addi $t0,$t0,1
                     addi $t3,$t3,1
                     j loopAddWordArr
              exitAddWordArr:
                     #them ki tu *:
                     sb $t1,($t0)
                     #Restore thanh ghi
                     lw $t0,($sp)
                     lw $t1,4($sp)
                     lw $t2,8($sp)
                     lw $t3,12($sp)
                     lw $ra,16($sp)
                     #Xoa stack
                     addi $sp,$sp,20
                     #Quay ve
	             jr $ra   
     #Kiem tra tu da duoc doan hay chua:	             
     _checkOutWord:
              addi $sp,$sp,-28
              sw $t0,($sp)
              sw $t1,4($sp)
              sw $t2,8($sp)
              sw $t3,12($sp)
              sw $t4,16($sp)
              sw $t5,20($sp)
              sw $ra,24($sp)
              #a1 chua chuoi de bai
              #a2 chua do dai chuoi de bai
              li $t1,42
              la $t0,wordArr
              li $t2,0
              li $t3,0
              li $t5,0
              loopCheckOutWord:
                  lb $t2,($t0)
                  beq $t2,42,endCheckOutWord1#gap dau * la tu da duoc doan
                  beq $t2,0,endCheckOutWord2# tu chua dc doan, het chuoi chua tim thay
                  lb $t3,($a1)
                  beq $t2,$t3,con1 #trung ki tu thi xet tiep
                  bne $t2,$t3,con2 #Ko trung ki tu thi nhay den tu tiep theo
                  con1:
                     addi $a1,$a1,1
                     addi $t5,$t5,1
                     addi $t0,$t0,1
                     j loopCheckOutWord
                  con2:
                      sub $t5,$zero,$t5 
                      add $a1,$a1,$t5 #Lui lai tai byte dau tien
                      loop1:
                         lb $t4,($t0)
                         addi $t0,$t0,1
                         beq $t4,42,loopCheckOutWord
                         beq $t4,0,endCheckOutWord2
                         j loop1
              endCheckOutWord1:
                         li $v0,1
                         j endCheckOutWord
              endCheckOutWord2:
                         li $v0,0
                         j endCheckOutWord   
              endCheckOutWord:
                         #Restore thanh ghi
                         lw $t0,($sp)
                         lw $t1,4($sp)
                         lw $t2,8($sp)
                         lw $t3,12($sp)
                         lw $t4,16($sp)
                         lw $t5,20($sp)
                         lw $ra,24($sp)
                         #Xoa stack
                         addi $sp,$sp,28
                         jr $ra
      #Xoa chuoi de bai
     _delString:
           addi $sp,$sp,-8
           sw $t0,($sp)
           sw $ra,4($sp)
           move $t0,$a2
           loopDelString:
                   beq $t0,-1,endDelString
                   sb $zero,randWord($t0)
                   addi $t0,$t0,-1
                   j loopDelString
           endDelString:
                   lw $t0,($sp)
                   lw $ra,4($sp)
                   addi $sp,$sp,8
                   jr $ra     
     _storeRanWordIndexZero: 
              #tao stack
              addi $sp,$sp,-12
              sw $t0,($sp)
              sw $t1,4($sp)
              sw $ra,8($sp)
              la $t0,randWord
	      loop_StoreWordIndexZero:
	              lb $t1,($a1)
	              beq $t1, 42, exit_StoreWordIndexZero 
	              beqz $t1, exit_StoreWordIndexZero		
	              sb $t1,($t0)
	              addi $a1, $a1, 1
	              addi $t0, $t0, 1
	              j loop_StoreWordIndexZero
	      exit_StoreWordIndexZero:
	              #Restore thanh ghi
                       lw $t0,($sp)
                       lw $t1,4($sp)
                       lw $ra,8($sp)
                       #Xoa stack
                       addi $sp,$sp,12
                       #Quay ve diem bat dau ctrinh
	               j startProm             
     _displayGuessWord: 
               addi $sp,$sp,-4
               sw $ra,($sp)  
               li $v0,59
               la $a0,message
               la $a1,guessWord
               syscall
               lw $ra,($sp) 
               addi $sp,$sp,4
               jr $ra
     _userIntputChar:
              addi $sp,$sp,-32
              sw $t0,($sp)
              sw $t1,4($sp)
              sw $t2,8($sp)
              sw $t3,12($sp)
              sw $t4,16($sp)
              sw $t5,20($sp)
              sw $t6,24($sp)
              sw $ra,28($sp)
              li $t3,0#so loi
              li $t6,0 #so ki tu da doan dc
              #tinh chieu dai chuoi de bai
              la $a1,randWord
              jal _wordLenght
              move $a2,$v0
              inputChar:
              #xuat chuoi an
              jal  _displayGuessWord
              beq $t6,$a2,endUserIntputChar #doan dung het thoat
              beq $t3,7,endmain #doan sai 7 lan thoat
              rechoose: 
              li $v0,51
              la $a0,guessMess
              li $a1,0
              syscall
              #Lua chon nhap ki tu hoac nhap chu
              beq $a0,1,startGuess
              beq $a0,2,_inputWord
              j rechoose #Nhap sai nhap lai
              startGuess: 
              #Nhap ki tu:
              li $v0,54            
              la $a0,characterMess
              la $a1,character
              syscall 
              #load lai dia chi
              la $a1,randWord
              #a2 do dai chuoi  
              la $t5,character
              lb $t0,0($t5)
              li $t1,0
              li $t4,0
              loopuserIntputChar:
                       lb $t2,($a1)
                       beqz $t2,endLoopUserIntputChar #hetchuoithoat
                       beq $t2,$t0,guessUpdate #trung nhau thi update chuoi an
              conCheck: 
                       addi $a1,$a1,1
                       add  $t1,$t1,1  
                       j loopuserIntputChar
                       guessUpdate:
                             sb $t2,guessWord($t1) #hien ki tu doan trùn
                             addi $t6,$t6,1 #tang so lan doan dung
                             li $t4,1 #danh dau doan dung
                             j conCheck
              endLoopUserIntputChar:
                       beq $t4,1,inputChar #doan dung thi nhap tiep 
                       addi $t3,$t3,1 #doan sai thi cong so lan sai
                       #Xuat so loi hien tai
                       li $v0,4
                       la $a0,errorMess
                       syscall
                       li $v0,1
                       move $a0,$t3
                       syscall
                       li $v0,4
                       #Xuong dong
                       la $a0,enter
                       syscall
                       move $a3,$t3 #truyen tham so va ve hangman
                       jal _hangmanDraw
                       j inputChar #ve xong nhap tiep
              endUserIntputChar: 
                       lw $t0,($sp)
                       lw $t1,4($sp)
                       lw $t2,8($sp)
                       lw $t3,12($sp)
                       lw $t4,16($sp)
                       lw $t5,20($sp)
                       lw $t6,24($sp)
                       lw $ra,28($sp)  
                       addi $sp,$sp,32            
                       jr $ra
     _hangmanDraw:
               #Cac lan ve tuong ung
                beq $a3,1,hangmanDraw1
                beq $a3,2,hangmanDraw2  
                beq $a3,3,hangmanDraw3 
                beq $a3,4,hangmanDraw4    
                beq $a3,5,hangmanDraw5
                beq $a3,6,hangmanDraw6 
                beq $a3,7,hangmanDraw7 
                hangmanDraw1:
                     li $v0,4
                     la $a0,hangman1
                     syscall 
                     jr $ra   
                hangmanDraw2:
                     li $v0,4
                     la $a0,hangman2
                     syscall 
                     jr $ra  
                hangmanDraw3:
                     li $v0,4
                     la $a0,hangman3
                     syscall 
                     jr $ra  
                hangmanDraw4:
                     li $v0,4
                     la $a0,hangman4
                     syscall 
                     jr $ra  
                hangmanDraw5:
                     li $v0,4
                     la $a0,hangman5
                     syscall 
                     jr $ra  
                hangmanDraw6:
                     li $v0,4
                     la $a0,hangman6
                     syscall 
                     jr $ra  
                hangmanDraw7:
                     li $v0,4
                     la $a0,hangman7
                     syscall 
                     jr $ra 
      #Doan luon tu
     _inputWord: 
               li $v0,54        #Nhap tu doan    
               la $a0,wordMess
               la $a1,imGuess
               la $a2,20
               syscall 
               la $a1,imGuess
               la $a2,randWord
               inputWordLoop:
                     lb $t0,($a2)
                     beqz $t0,endInputWord #het chuoi thoat
                     lb $t1,($a1)
                     addi $a1,$a1,1
                     addi $a2,$a2,1
                     beq $t0,$t1,inputWordLoop #2 ki tu bang nhau thi loop tiep
                     j endmain #Sai thi nhay ve thua
               endInputWord:
                     j endUserIntputChar # Dung nhay ve ket thuc
      #Xoa chuoi an
     _delGuessString:
           addi $sp,$sp,-8
           sw $t0,($sp)
           sw $ra,4($sp)
           move $t0,$a2
           loopDelGuessString:
                   beq $t0,-1,endDelGuessString
                   sb $zero,guessWord($t0)
                   addi $t0,$t0,-1
                   j loopDelGuessString
           endDelGuessString:
                   lw $t0,($sp)
                   lw $ra,4($sp)
                   addi $sp,$sp,8
                   jr $ra                            
