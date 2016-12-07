# Pig Latin Converter

This converter takes in a string of text from a file called "cat.txt" (case sensitive) that's in the same folder as PigLatin.s. It can convert up to 128 bytes worth of input at once. Contents must be able to be represented in standard ASCII. Only the first line of text is pulled from the file. The output will interpret the vertical bar ("|") characters as an indicator of a new line and output to stdout accordingly. The last three characters of the first line MUST be "|-1" (without quotes).

The program will replace words with their Pig Latin equivalent and only exit upon parsing a new line beginning with -1. (Hence, the above requirement). The translation is simple: words beginning with vowels have "way" appended to them, and words beginning with consonants have all consonants of the word preceding the first vowel appended, as well as "ay". The definition of a "word" is any set of alphabetical characters adjacent to each other - they are delimited by the preceding and following non-alphabetical characters. This means that the program is compatible with all punctuation and capitalization, so something like "good-Hearted" will translate properly. The converter will not get caught up on any ASCII character, though it will be assumed to be a delimiter between words if it is not alphabetic.

All letters will remain in their original case - capitalization is kept in tact. It's a feature, not a bug!

### Future plans:
1. Change "consonant words" to begin at the vowel, not the character preceding them (in the case of >1 consonants prior to the first vowel). This kind of goes against the rule you set, but makes the words easier to pronounce if they begin with a "ch". Instead of just "placing" the initial consonants at the end, we're moving them.
2. Add ability to convert to a pirate language, replacing words like "you" with "ye" and "are" with "be".
3. Something A-Level worthy?
