.386
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc

ExitProcess PROTO, dwExitCode:DWORD
WriteString PROTO
WriteChar PROTO
ReadInt PROTO
Crlf PROTO
Randomize PROTO
RandomRange PROTO
SetTextColor PROTO
GetTextColor PROTO
Delay PROTO

.data
MAX_ATTEMPTS = 100 ;maximum number of user attempts
MIN_NUM = 1 ;minimum value of a number
MAX_NUM = 5000 ;maximum value of a number
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

;Color Constants
BLUE = 1
GREEN = 2
RED = 4
INTENSE =8
WHITE = 15

.code
main PROC
	mov edx, OFFSET welcomeMSG ;printing welcome message
	call WriteString
	call Crlf
	call Crlf

	mov edx, OFFSET instructions ;printing instructions
	call WriteString
	call Crlf
	call Crlf

    call Randomize ;make sure number is random -ch.5

    ;get first random number
    mov eax, MAX_NUM
    sub eax, MIN_NUM
    inc eax
    call RandomRange
    add eax, MIN_NUM
    mov num1, eax

    ;get second random number
    mov eax, MAX_NUM
    sub eax, MIN_NUM
    inc eax
    call RandomRange
    add eax, MIN_NUM
    mov num2, eax

    ;get first guess
    mov edx, OFFSET prompt1
    call WriteString
    call ReadInt
    mov guess1, eax

    ;get second guess
    mov edx, OFFSET prompt2
    call WriteString
    call ReadInt
    mov guess2, eax



    ;compare guesses to randomly generated nums
    ;tell user if their guess is too high or low or right

	INVOKE ExitProcess
main ENDP
END main