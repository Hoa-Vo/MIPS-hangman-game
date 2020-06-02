.data 
    fin: .asciiz "DETHI.txt"
    message: .asciiz "The word to guess is:\n "
    userNameInput: .asciiz "Input username(contain 0-9,a-z,A-Z):\n"
    userName: .space 10
    enter: .asciiz "\n"
    test1: .asciiz "trung"
    string: .space 2000
    wordArr: .space 2000
    randWord: .space 20
    guessWord: .space 20
    outOfWord: .asciiz "You have finished all question. Congratulation!!!"
    continuePlay: .asciiz "Play again?"
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
        j reRandom #random lai
 startInit: 
    la $a1,guessWord #truyen tham so 
    jal _initGuessWord #ham khoi tao chuoi an
    #Xuat chuoi an tren box mess
    li $v0,59
    la $a0,message
    la $a1,guessWord
    syscall
    ######Xu li nhap ki tu o day #########
    
    
    ####### Neu thang thi goi ham them de da choi, thua thi nhay ve endmain
    addi $s2,$s2,1
    la $a1,randWord
    #Them tu vao chuoi nhung tu da choi
    jal _addWordArr
    li $v0,4
    la $a0,wordArr
    syscall
    li $v0,4
    la $a0,enter
    syscall
    beq $s2,5,outOfWordEnd #het de!! nhay ve thoat
    #Xuong dong
    li $v0,4
    la $a0,enter
    syscall
    jal _delString
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
              addi $sp,$sp,-16
              lw $t0,($sp)
              lw $t1,4($sp)
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
                       sw $t0,($sp)
                       sw $t1,4($sp)
                       #Xoa stack
                       addi $sp,$sp,16
                       #Quay ve
	               jr $ra
    #Ham tinh chieu dai chu:
    _wordLenght:#tao stack
              addi $sp,$sp,-16
              lw $t0,($sp)
              lw $t1,4($sp)
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
                       sw $t0,($sp)
                       sw $t1,4($sp)
                       #Xoa stack
                       addi $sp,$sp,16
                       #Quay ve
	               jr $ra
     _initGuessWord: addi $sp,$sp,-16
                    lw $t0,($sp)
                    lw $t1,4($sp)
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
                       sw $t0,($sp)
                       sw $t1,4($sp)
                       #Xoa stack
                       addi $sp,$sp,16
                       #Quay ve
	               jr $ra     
    _checkUserName: 
              loop_checkUserName:
                       lb $t0,($a1) 
                       beq $t0,10,exit_checkUserName#gap xuong dong thoat
                       blt $t0,123,check1
                       j reinput#neu lon hon 123 nhap lai
              continue:addi $a1,$a1,1 #di den ki tu ke tiep
                        j loop_checkUserName 
              check1: ble $t0,97,check1con #kiem tra tu a-z
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
	               jr $ra
   _addWordArr:
              addi $sp,$sp,-32
              lw $t0,($sp)
              lw $t1,4($sp)
              lw $t2,8($sp)
              lw $t3,12($sp)
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
                     sw $t0,($sp)
                     sw $t1,4($sp)
                     sw $t2,8($sp)
                     sw $t3,12($sp)
                     #Xoa stack
                     addi $sp,$sp,32
                     #Quay ve
	             jr $ra   
     _checkOutWord:
              addi $sp,$sp,-48
              lw $t0,($sp)
              lw $t1,4($sp)
              lw $t2,8($sp)
              lw $t3,12($sp)
              lw $t4,16($sp)
              lw $t5,20($sp)
              #a1 chua chuoi de bai
              #a2 chua do dai chuoi de bai
              li $t1,42
              la $t0,wordArr
              li $t2,0
              li $t3,0
              li $t5,0
              loopCheckOutWord:
                  lb $t2,($t0)
                  beq $t2,42,endCheckOutWord1
                  beq $t2,0,endCheckOutWord2
                  lb $t3,($a1)
                  beq $t2,$t3,con1
                  bne $t2,$t3,con2
                  con1:
                     addi $a1,$a1,1
                     addi $t5,$t5,1
                     addi $t0,$t0,1
                     j loopCheckOutWord
                  con2:
                      sub $t5,$zero,$t5
                      add $a1,$a1,$t5
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
                         sw $t0,($sp)
                         sw $t1,4($sp)
                         sw $t2,8($sp)
                         sw $t3,12($sp)
                         sw $t4,16($sp)
                         sw $t4,20($sp)
                         #Xoa stack
                         addi $sp,$sp,48
                         jr $ra
     _delString:
           move $t0,$a2
           loopDelString:
                   beq $t0,-1,endDelString
                   sb $zero,randWord($t0)
                   addi $t0,$t0,-1
                   j loopDelString
           endDelString:
                    jr $ra     
     _storeRanWordIndexZero: 
              #tao stack
              addi $sp,$sp,-16
              lw $t0,($sp)
              lw $t1,4($sp)
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
                       sw $t0,($sp)
                       sw $t1,4($sp)
                       #Xoa stack
                       addi $sp,$sp,16
                       #Quay ve diem bat dau ctrinh
	               j startProm             
           
                 
