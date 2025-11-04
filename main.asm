.386
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc


.data
MAX_ATTEMPTS = 100 ;maximum number of user attempts
MIN_NUM = 1 ;minimum value of a number
MAX_NUM = 5000 ;maximum value of a number
currentMax DWORD ? ;variable for difficuly
num1 DWORD ? ;stores the value of the first number
num2 DWORD ? ;stores the value of the second number
guess1 DWORD ? ;stores the users most recent guess for the first number
guess2 DWORD ? ;stores the users most recent guess for the second number
attempts DWORD 0 ;stores the number of attempts the user has used so far
gameWon BYTE 0 ;stores the status of the current game (if the user has won or not)

; Messages
welcomeMSG BYTE "Welcome to the Animated Number Guessing Game!", 0
instructions BYTE "I'm thinking of two numbers between 1 and 5000. Try and guess them!", 0
prompt1 BYTE "Enter your guess for the first number: ", 0
prompt2 BYTE "Enter your guess for the second number: ", 0
correctMSG BYTE "Congrats! You guessed correctly!", 0
tooHighMSG BYTE "Too high!", 0
tooLowMSG BYTE "Too low!", 0
attemptsMSG BYTE "Attempts: ", 0
gameOverMSG BYTE "Game Over! the numbers were: ", 0
playAgainMSG BYTE "Play again? (1=Yes, 0=No): ", 0
difficultyMSG BYTE "Choose difficulty (1=Easy, 2=Medium, 3=Hard): ", 0

;Color Constants
DARK_BLUE = 1
BLUE_ON_BLACK = 1
GREEN_ON_BLACK = 2 
RED_ON_BLACK = 4
DARK_RED = 9
INTENSE_BLUE = 9
INTENSE_RED = 12
WHITE_ON_BLACK = 15

.code
;generate a random number between MIN_NUM and MAX_NUM
GenerateRandomNumber PROC
	mov eax, currentMax
	sub eax, MIN_NUM
	inc eax
	call RandomRange
	add eax, MIN_NUM
	ret
GenerateRandomNumber ENDP

;set up the game with new random numbers
InitializeGame PROC
	call Randomize
	call GenerateRandomNumber
	mov num1, eax
	call GenerateRandomNumber
	mov num2, eax
	mov attempts, 0
	mov gameWon, 0
	ret
InitializeGame ENDP

; determines the color for the "Too High" meessage based on the distance between the user guess and the actual value
CalculateColorHigh PROC
	mov ebx, eax
	mov eax, ebx
	mov ecx, 100
	mul ecx
	mov ecx, MAX_NUM
	div ecx ;stores the how out oof range the guess is as a percentage

	cmp eax, 75
	jg very_off
	cmp eax, 50
	jg off
	cmp eax, 25
	jg close
	jmp really_close

; set colors for very off guess
very_off:
	mov eax, 4
	jmp done_color_high
; set color for off guess
off:
	mov eax, 12
	jmp done_color_high
close:
	mov eax, 13
	jmp done_color_high
really_close:
	mov eax, WHITE_ON_BLACK
	jmp done_color_high
done_color_high:
	ret
CalculateColorHigh ENDP

; determines the color for the "Too Low" meessage based on the distance between the user guess and the actual value
CalculateColorLow PROC
	mov ebx, eax
	mov eax, ebx
	mov ecx, 100
	mul ecx
	mov ecx, MAX_NUM
	div ecx ;stores the how out of range the guess is as a percentage

	cmp eax, 75
	jg very_far_low
	cmp eax, 50
	jg far_low
	cmp eax, 25
	jg medium_low
	jmp close_low


very_far_low:
	mov eax, 1
	jmp done_color_low
far_low:
	mov eax, 9
	jmp done_color_low
medium_low:
	mov eax, 11
	jmp done_color_low
close_low:
	mov eax, WHITE_ON_BLACK
	jmp done_color_low
done_color_low:
	ret
CalculateColorLow ENDP

CheckGuess PROC
	cmp eax, ebx
	je correct_guess
	jg too_high_guess
	mov edx, OFFSET tooLowMSG
	push eax
	push ebx
	mov eax, ebx
	sub eax, [esp + 4]
	call CalculateColorLow
	call SetTextColor
	call WriteString
	call Crlf
	mov eax, WHITE_ON_BLACK
	call SetTextColor
	pop ebx
	pop eax
	jmp check_done

too_high_guess:
	mov edx, OFFSET tooHighMSG
	push eax
	push ebx
	sub eax, ebx
	call CalculateColorHigh
	call SetTextColor
	call WriteString
	call Crlf
	mov eax, WHITE_ON_BLACK
	call SetTextColor
	pop ebx
	pop eax
	jmp check_done
correct_guess:
	mov edx, OFFSET correctMSG
	mov eax, GREEN_ON_BLACK
	call SetTextColor
	call WriteString
	call Crlf
	mov eax, WHITE_ON_BLACK
	call SetTextColor
check_done:
	ret
CheckGuess ENDP

; Displays the current game status
DisplayGame PROC
	mov edx, OFFSET attemptsMSG
	call WriteString
	mov eax, attempts
	call WriteDec
	call Crlf
	call Crlf
	ret
DisplayGame ENDP

GetUserGuess PROC
	mov edx, OFFSET prompt1
	call WriteString
	call ReadInt
	mov guess1, eax
	mov edx, OFFSET prompt2
	call WriteString
	call ReadInt
	mov guess2, eax
	ret
GetUserGuess ENDP

;determine if both guesses are correct 
CheckWinCondition PROC
	mov eax, guess1
	cmp eax, num1
	jne not_won
	mov eax, guess2
	cmp eax, num2
	jne not_won
	mov gameWon, 1
	mov al, 1
	ret
not_won:
	mov al, 0
	ret
CheckWinCondition ENDP

; Shows game over message
DisplayGameOver PROC
	mov edx, OFFSET gameOverMSG
	call WriteString
	mov eax, num1
	call WriteDec
	mov edx, OFFSET ", "
	call WriteString
	mov eax, num2
	call WriteDec
	call Crlf
	ret 
DisplayGameOver ENDP

PlayGame PROC

	;difficulty logic
    mov edx, OFFSET difficultyMSG
    call WriteString
    call ReadInt
    cmp eax, 1
    je easy
    cmp eax, 2
    je medium
    cmp eax, 3
    je hard
    jmp default_difficulty

easy:
    mov currentMax, 1000
    jmp continue_game
medium:
    mov currentMax, 2500
    jmp continue_game
hard:
    mov currentMax, 5000
    jmp continue_game
default_difficulty:
    mov currentMax, 5000
continue_game:

	call InitializeGame
game_loop:
	mov eax, attempts
	cmp eax, MAX_ATTEMPTS
	jge game_over
	cmp gameWon, 1
	je game_won
	call DisplayGame
	call GetUserGuess
	mov eax, guess1
	mov ebx, num1
	call CheckGuess
	mov eax, guess2
	mov ebx, num2
	call CheckGuess
	call CheckWinCondition
	cmp al, 1
	je game_won

	inc attempts
	call Crlf
	jmp game_loop
game_won:
	mov edx, OFFSET correctMSG
	call WriteString
	call Crlf
	jmp	play_again_prompt
game_over:
	call DisplayGameOver
play_again_prompt:
	call Crlf
	mov edx, OFFSET playAgainMSG
	call WriteString
	call ReadInt
	cmp eax, 1
	je play_again
	ret
play_again:
	call Clrscr
	call PlayGame
	ret
PlayGame ENDP







