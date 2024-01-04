########################################
Expanded Result Screen Names [GeraRReal]
# Minor update from the CBM release that just changes how jumps is done
# Also added set related functions
########################################
# Set-specific Result Name, only difference is that it doesn't check for modulo 10.
# You might wanna use this if you have a set of costumes for 1X or if your build skips the modulo 10 check with costumes and ect files.
.macro setCostumeResultsName_set_nm(<ID>,<set>,<A>,<B>,<C>,<D>,<E>,<F>,<G>,<H>)
{
    cmpwi r5, <ID>		# Compare character
    bne end				# If it doesn't match, skip to the end
	li r15, <set>		# Get set (must be 00,10,20,30,40,50)
	cmpw r14, r15		# Compare with set ID
	blt end				# If less, skip the check
	addi r15, r15, 10	# Add 10
	cmpw r14, r15		# Compare with set ID again
	bge end				# If greater and equal, skip the check
	bl the_label		# Else, bl trick to the end and get the name
	word <A>
	word <B>
	word <C>
	word <D>
	word <E>
	word <F>
	word <G>
	word <H>
the_label:
	mflr r5				# Get new character name
	b %END%				# End
end:
}
# Set-specific Result Name.
.macro setCostumeResultsName_set(<ID>,<set>,<A>,<B>,<C>,<D>,<E>,<F>,<G>,<H>)
{
    cmpwi r5, <ID>		# Compare character
    bne end				# If it doesn't match, skip to the end
	li r15, <set>		# Get set (must be 00,10,20,30,40,50)
	cmpw r14, r15		# Compare with set ID
	blt end				# If less, skip the check
	addi r15, r15, 10	# Add 10
	cmpwi r15, 10		# Is it 10
	bne 0x8				# Else skip next command
	addi r15, r15, 10	# Add another 10
	cmpw r14, r15		# Compare with set ID again
	bge end				# If greater and equal, skip the check
	bl the_label		# Else, bl trick to the end and get the name
	word <A>
	word <B>
	word <C>
	word <D>
	word <E>
	word <F>
	word <G>
	word <H>
the_label:
	mflr r5				# Get new character name
	b %END%				# End
end:
}
# Costume-specific Result Name.
.macro setCostumeResultsName(<ID>,<Costume>,<A>,<B>,<C>,<D>,<E>,<F>,<G>,<H>)
{
    cmpwi r5, <ID>		# Compare character
    bne end				# If it doesn't match, skip to the end
    cmpwi r14, <Costume># Check if costume ID
    bne end				# If not equal, skip the check
	bl the_label		# Else, bl trick to the end and get the name
	word <A>
	word <B>
	word <C>
	word <D>
	word <E>
	word <F>
	word <G>
	word <H>
the_label:
	mflr r5				# Get new character name
	b %END%				# End
end:
}
HOOK @ $800e7c48
{
    lbz r14, 0x26(r3) 	# Get costume ID
    lbz r3, 0x24(r3)  	# Original Function
}
#
HOOK @ $800E7C54
{
	# Dark Pit
    %setCostumeResultsName_set(0x16,20,0x4461726B,0x20506974,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000)
    mr r5, r3           # Original Function
	li r14, 0			# Return r14 to it's original value
}

