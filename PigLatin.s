@ Pig Latin Converter
@ 2016.11.23
@ Thomas Reichman
@ Converts English to Pig Latin
@ See ReadMe.MD for more information.

@------------------------- SETUP --------------------------
			.data
			.align	2
InFile:		.asciiz "cat.txt"			@ we need input from a file to load,
ReservedMem:	.asciiz ""				@ and must reserve a memory location to store its contents
			.text
			.global	_start_
_start_:
@-------------------------- KEY ---------------------------
@ r0 = name of input file
@ r1 = allocated memory to store string
@ r2 = max number of bytes to store
@ r3 = i (an index of an observed character, typically the first character of the current word)
@-------------------- GLOBAL VARIABLES --------------------
			LDR		r0, =InFile		@ get the input file name
			MOV		r1, #0			@ tells next command to be in "input mode"
			SWI		0x66				@ open the file

			LDR 		r1, =ReservedMem	@ allocate space for the input string
			MOV		r2, #128			@ max number of bytes to store
			SWI		0x6A				@ read in string from file
			MOV 		r3, #0			@ default i to the first character
			B		Conversion
@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣
@================================
  @ 	          Conversion Process
  @ 		NOTE: "lines" are delimitted by |
  @ Check if the current word begins with a vowel or consonant:
  @ 		If so, call vowelConverter or consonantConverter, respectively.
  @ Otherwise, print out the current character, as it must be some form of punctuation.
  @ (If the character is a |, "overload" it with a true newline (\n) character)
  @ If a line begins with -1, exit.
  @ Else, move on to the next word or "line".
  @−−−−−−−−−−−−−−−−−−−−−−−−−− KEY −−−−−−−−−−−−−−−−−−−−−−−−−−−
  @ r0 = return value of vowelChecker/consonantChecker OR thing to print
  @ r1 =
  @ r2 = observed character
  @ r3 = i, the index of the first character of the current word
  @ r4 =
  @ r5 =
  @ r6 =
  @ r7 =
  @ r8 =
  @ r9 =
@================================
Conversion:
	LDRB 	r2, [r1, r3]		@ load the i-th character into r2
     BL  		charChecker         @ call charChecker, passing r2 in as value to compare
     CMP  	r0, #1              @ if r0 == 1, we had a vowel, so
     BEQ  	foundVowel      	@ call vowelConverter
     CMP  	r0, #2              @ if r0 == 0, we had a consonant, so
     BEQ  	foundConsonant		@ call consonantConverter
	MOV		r0, r2			@ if we made it here, it's not a letter, so put it in r0
	CMP 		r0, #124 			@ if we have a |,
	BEQ		newLineMaker		@ change its value so it prints as a newline character
finishPrinting:
	SWI 		0x00				@ so that we can print it
	ADD 		r3, r3, #1		@i++
	BL		checkEOF
	B		Conversion		@ convert the next word - converter functions will increment i accordingly before returning
newLineMaker:
	MOV 		r0, #10			@ set r0 to new line(\n) instead of vertical pipe(|)
	B		finishPrinting		@ go back to where we were before the swap

foundVowel:
	BL 		vowelConverter
	B		Conversion		@ convert the next word - converter functions will increment i accordingly before returning
foundConsonant:
	BL 		consonantConverter
	B		Conversion		@ convert the next word - converter functions will increment i accordingly before returning
@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣

@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣
@================================
  @ 	          Consonant Converter
  @ Prints the original word.
  @ Appends (prints) all letters of the word preceding the first vowel.
  @ Appends (prints) "ay" at the end of the word.
  @−−−−−−−−−−−−−−−−−−−−−−−−−− KEY −−−−−−−−−−−−−−−−−−−−−−−−−−−
  @ r0 = character to be printed OR indicator of whether r2 is vowel/consonant/neither
  @ r1 = location of input string in memory
  @ r2 = character to be passed into charChecker
  @ r3 = i (passed in as the index of first letter of current word, returned as index of first character of the next)
  @ r4 = n (a variable to measure incrementation so that we iterate over a whole word at a time)
@================================
consonantConverter:
@-------- usual stuff at beginning of function
	SUB		sp, sp, #28
	STR		lr, [sp]
	STR		r4, [sp, #4]
	STR		r5, [sp, #8]
	STR		r6, [sp, #12]
	STR		r7, [sp, #16]
	STR		r8, [sp, #20]
	STR		r9, [sp, #24]
@--- Body
	ADD 		r4, r3, #1 	@ make a copy of i+1 called n
consonantLoop:
	LDRB 	r2, [r1, r4]	@ load list[n] into r2 to be checked
	BL 		charChecker	@ find out what type of character n is now
	CMP 		r0, #0		@ are we at the end of the word? (i.e. is the observed character is non-alphabetic?)
	BEQ 		consonantDeux	@ if so, move on
	LDRB 	r0, [r1, r4]	@ else, load list[n] into r0 to be printed
	SWI 		0x00			@ print it
	ADD 		r4, r4, #1 	@ n++
	B		consonantLoop
consonantDeux:				@ by here, the entire word has been printed
	LDRB 	r2, [r1, r3]	@ load list[i] into r2 to be checked
	BL 		charChecker	@ find out what type of character i is now
	CMP 		r0, #1		@ are we at the first vowel?
	BEQ		consonantDone	@ if so, prepare to add "ay" then start converting next word
	LDRB 	r0, [r1, r3]	@ else, load list[i] into r0 to be printed
	SWI 		0x00			@ print it
	ADD 		r3, r3, #1 	@ i++
	B		consonantDeux  @ loop this section
consonantDone:
	MOV 		r3, r4		@ return i as start of next word (where n left off)
	MOV 		r0, #97		@ get ready to print "a"
	SWI 		0x00			@ print it
	MOV 		r0, #121		@ get ready to print "y"
	SWI 		0x00			@ print it
@------- usual stuff at end of function
	LDR		lr, [sp]
	LDR		r4, [sp, #4]
	LDR		r5, [sp, #8]
	LDR		r6, [sp, #12]
	LDR		r7, [sp, #16]
	LDR		r8, [sp, #20]
	LDR		r9, [sp, #24]
	ADD 		sp, sp, #28
	BX		lr
@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣

@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣
@================================
  @ 	          Vowel Converter
  @ Prints the current word.
  @ Appends (prints) "way" to the end of the word.
  @−−−−−−−−−−−−−−−−−−−−−−−−−− KEY −−−−−−−−−−−−−−−−−−−−−−−−−−−
  @ r0 = character to be printed OR indicator of whether r2 is vowel/consonant/neither
  @ r1 = location of input string in memory
  @ r2 = n (a variable to measure incrementation so that we iterate over a whole word at a time)
  @ r3 = i (passed in as first letter of current word, returned as first of next word)
@================================
vowelConverter:
@-------- usual stuff at beginning of function
	SUB		sp, sp, #28
	STR		lr, [sp]
	STR		r4, [sp, #4]
	STR		r5, [sp, #8]
	STR		r6, [sp, #12]
	STR		r7, [sp, #16]
	STR		r8, [sp, #20]
	STR		r9, [sp, #24]
@--- Body
vowelLoop:
	LDRB 	r2, [r1, r3]	@ load list[i] into r2 to be checked
	BL 		charChecker	@ find out what type of character i is now
	CMP 		r0, #0		@ are we at the end of the word? (i.e. is the observed character is non-alphabetic?)
	BEQ 		vowelDone		@ if so, move on
	LDRB 	r0, [r1, r3]	@ else, load list[n] into r0 to be printed
	SWI 		0x00			@ print it
	ADD 		r3, r3, #1 	@ n++
	B		vowelLoop
vowelDone:
	MOV 		r0, #119		@ get ready to print "a"
	SWI 		0x00			@ print it
	MOV 		r0, #97		@ get ready to print "a"
	SWI 		0x00			@ print it
	MOV 		r0, #121		@ get ready to print "y"
	SWI 		0x00			@ print it
@------- usual stuff at end of function
	LDR		lr, [sp]
	LDR		r4, [sp, #4]
	LDR		r5, [sp, #8]
	LDR		r6, [sp, #12]
	LDR		r7, [sp, #16]
	LDR		r8, [sp, #20]
	LDR		r9, [sp, #24]
	ADD 		sp, sp, #28
	BX		lr
@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣

@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣
@================================
  @ 	          EOF Checker
  @ Compare the passed in character (r2) with "|-1", the indicator of an EOF
  @ If the string matches, end the program
  @ Else, return
  @−−−−−−−−−−−−−−−−−−−−−−−−−− KEY −−−−−−−−−−−−−−−−−−−−−−−−−−−
  @ r0 = copy of i so that we don't modify the original - hooray for Pass-By-Value!
  @ r1 = the input string (passed in)
  @ r2 = the character to check for an EOF-indicating string
  @ r3 = passed in "i" - the index of character to check for EOF - MUST REMAIN CONSTANT
@================================
checkEOF:
@-------- usual stuff at beginning of function
	SUB		sp, sp, #28
	STR		lr, [sp]
	STR		r4, [sp, #4]
	STR		r5, [sp, #8]
	STR		r6, [sp, #12]
	STR		r7, [sp, #16]
	STR		r8, [sp, #20]
	STR		r9, [sp, #24]
@--- Body
	LDRB		r2, [r1, r3]		@ load up the input character
	MOV 		r0, r3			@ make r0 a backup of r3 so that we don't modify the parameter (we want to keep r3 constant)
	CMP 		r2, #124			@ if the character is a newline (represented by "|")
	BEQ 		possibleEnd		@ check for following "-1"
	BX		LR				@ else return where we left off (no EOF found)
possibleEnd:
	ADD		r0, r0, #1		@ increment index of input character - this is safe because we don't care what r0 is afterwards
	LDRB 	r2, [r1, r0]		@ load the next character after the "|"
	CMP  	r2, #45             @ if the first letter of the first word is NOT "-" (we use ASCII)...
	BNE  	goToReturn          @ continue searching for vowels/consonants
	ADD		r0, r0, #1		@ increment index of input character - this is safe because it gets overwritten during return statement anyways
	LDRB 	r2, [r1, r0]		@ load the next character after the "-"
	CMP		r2, #49			@ if the character following the first of the line is "1"...
	BEQ 		done				@ we're done
goToReturn:
	BX		LR				@ look for vowels/consonants
@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣

@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣
@================================
  @ 	          Character Checker
  @ Compare the passed in character (r2) with vowels. If it matches, return r0 as 1.
  @ Compare the passed in character (r2) with consonants. If it matches, return r0 as 2.
  @ Else, return r0 as 0.
  @ (This could be optimized by comparing to most common characters first, as well as doing lowercase before uppercase since there's more of those)
  @−−−−−−−−−−−−−−−−−−−−−−−−−− KEY −−−−−−−−−−−−−−−−−−−−−−−−−−−
  @ r0 = gets returned based on what type of character we just observed
  @ r2 = the input character
@================================
charChecker:
@-------- usual stuff at beginning of function
	SUB		sp, sp, #28
	STR		lr, [sp]
	STR		r4, [sp, #4]
	STR		r5, [sp, #8]
	STR		r6, [sp, #12]
	STR		r7, [sp, #16]
	STR		r8, [sp, #20]
	STR		r9, [sp, #24]
@------------- Check if Vowel
	CMP 		r2, #97 			@ is it a lower case a?
	BEQ 		returnVowel 		@ return that it's a vowel
	CMP 		r2, #65 			@ is it an upper case A?
	BEQ 		returnVowel 		@ return that it's a vowel
	CMP 		r2, #101 			@ is it a lower case e?
	BEQ 		returnVowel 		@ return that it's a vowel
	CMP 		r2, #69 			@ is it an upper case E?
	BEQ 		returnVowel 		@ return that it's a vowel
	CMP 		r2, #105 			@ is it a lower case i?
	BEQ 		returnVowel 		@ return that it's a vowel
	CMP 		r2, #73 			@ is it an upper case I?
	BEQ 		returnVowel 		@ return that it's a vowel
	CMP 		r2, #111 			@ is it a lower case o?
	BEQ 		returnVowel 		@ return that it's a vowel
	CMP 		r2, #79 			@ is it an upper case O?
	BEQ 		returnVowel 		@ return that it's a vowel
	CMP 		r2, #117 			@ is it a lower case u?
	BEQ 		returnVowel 		@ return that it's a vowel
	CMP 		r2, #85 			@ is it an upper case U?
	BEQ 		returnVowel 		@ return that it's a vowel
@------------- Check if Consonant
	CMP 		r2, #98 			@ is it a lower case b?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #66 			@ is it an upper case B?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #99 			@ is it a lower case c?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #67 			@ is it an upper case C?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #100 			@ is it a lower case d?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #68 			@ is it an upper case D?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #102 			@ is it a lower case f?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #70 			@ is it an upper case F?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #103 			@ is it a lower case g?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #71 			@ is it an upper case G?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #104			@ is it a lower case h?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #72 			@ is it an upper case H?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #106 			@ is it a lower case j?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #74 			@ is it an upper case J?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #107 			@ is it a lower case k?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #75 			@ is it an upper case K?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #108 			@ is it a lower case l?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #76 			@ is it an upper case L?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #109 			@ is it a lower case m?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #77 			@ is it an upper case M?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #110			@ is it a lower case n?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #78 			@ is it an upper case N?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #112 			@ is it a lower case p?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #80 			@ is it an upper case P?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #113 			@ is it a lower case q?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #81 			@ is it an upper case Q?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #114 			@ is it a lower case r?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #82 			@ is it an upper case R?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #115 			@ is it a lower case s?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #83 			@ is it an upper case S?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #116 			@ is it a lower case t?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #84 			@ is it an upper case T?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #118 			@ is it a lower case v?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #86 			@ is it an upper case V?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #119 			@ is it a lower case w?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #87 			@ is it an upper case W?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #120 			@ is it a lower case x?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #88 			@ is it an upper case X?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #121 			@ is it a lower case y?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #89 			@ is it an upper case Y?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #122 			@ is it a lower case z?
	BEQ 		returnConsonant	@ return that it's a consonant
	CMP 		r2, #90 			@ is it an upper case Z?
	BEQ 		returnConsonant	@ return that it's a consonant

	B 		neither
returnVowel:
	MOV 		r0, #1
	B		endOfChecker
returnConsonant:
	MOV 		r0, #2
	B		endOfChecker
neither:
	MOV 		r0, #0
	B		endOfChecker
endOfChecker:
@------- usual stuff at end of function
	LDR		lr, [sp]
	LDR		r4, [sp, #4]
	LDR		r5, [sp, #8]
	LDR		r6, [sp, #12]
	LDR		r7, [sp, #16]
	LDR		r8, [sp, #20]
	LDR		r9, [sp, #24]
	ADD 		sp, sp, #28
	BX		lr
@≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣≣
done:
SWI 0x11
