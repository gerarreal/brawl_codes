###############################################################
Expanded Result Screen Names + Pokemon Stadium Name [GeraRReal]
###############################################################
# <ID> corresponds to the Cosmetic ID in BrawlEx's folder

# Range specific Result Name
# Replaces set specific costumes to add more choice
.macro replace_(<ID>,<min>,<max>,<A>,<B>,<C>,<D>,<E>,<F>,<G>,<H>,<register>)
{
	cmpwi r5, <ID>		# Compare character
	bne 0x40		# If it doesn't match, skip to the end
	cmpwi r14, <min>	# Compare with min
	blt 0x38		# If less, skip the check
	cmpwi r14, <max>	# Compare with max
	bge 0x30		# If greater and equal, skip the check
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
	mflr <register>		# Get new character name
	b %END%			# End
}

# Costume-specific Result Name.
.macro replace(<ID>,<Costume>,<A>,<B>,<C>,<D>,<E>,<F>,<G>,<H>,<register>)
{
    	cmpwi r5, <ID>		# Compare character
    	bne 0x38		# If it doesn't match, skip to the end
 	cmpwi r14, <Costume>	# Check if costume ID
    	bne 0x30		# If not equal, skip the check
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
	mflr <register>		# Get new character name
	b %END%			# End
}

HOOK @ $800AFA98
{
	lbz r14, 0x26(r31)
	stw r31, 0xC(r1)
}

HOOK @ $800AFA44
{
	lwz r3, -0x4340(r13)
	lwz r14, 0x0018(r3)
	cmpwi r24, 3
	bgt leader
	cmpwi r24, 0
	blt leader
	b normal
normal:
	mulli r15, r24, 0x2AC
	b b_end
leader:
	mulli r15, r29, 0x2AC
b_end:
	add r14, r14, r15
	mr r5, r31
	lbz r14, 0x26(r14)
	b %END%
}

# Results Screen
HOOK @ $800E7C54
{
	# Dr. Mario
    	%replace_(0x00,20,30,0x44722E20,0x4D617269,0x6F000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,r5)
	# Dark Pit
    	%replace_(0x16,20,30,0x4461726B,0x20506974,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,r5)
    	mr r5, r3           	# Original Function
	li r14, 0		# Return r14 to it's original value
}

# Pokemon Stadium
HOOK @ $800AFA74
{
	# Dr. Mario
    	%replace_(0x00,20,30,0x44722E20,0x4D617269,0x6F000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,r3)
	# Dark Pit
    	%replace_(0x16,20,30,0x4461726B,0x20506974,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,r3)
	lwzx r3, r3, r0 	# Original function
	li r14, 0 		# Return r14 to it's original value
}
