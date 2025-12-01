#############################################################################
Expanded Result Screen Names + Pokemon Stadium Name v1.1 [GeraRReal, Squidgy]
# Fix issues with P+Ex 1.6 credits module
#############################################################################
# <ID> corresponds to the Cosmetic ID in BrawlEx's folder

# Range specific Result Name
# Replaces set specific costumes to add more choice
.macro replace_(<ID>,<min>,<max>,<A>,<B>,<C>,<D>,<E>,<F>,<G>,<H>)
{
    cmpwi r5, <ID>		# Compare character
    bne 0x38			# If it doesn't match, skip to the end
	cmpwi r6, <min>		# Compare with min
	blt 0x30			# If less, skip the check
	cmpwi r6, <max>		# Compare with max
	bge 0x28			# If greater and equal, skip the check
	bl bl_trick			# Else, bl trick to the end and get the name
	word <A>
	word <B>
	word <C>
	word <D>
	word <E>
	word <F>
	word <G>
	word <H>
}

# Costume-specific Result Name.
.macro replace(<ID>,<Costume>,<A>,<B>,<C>,<D>,<E>,<F>,<G>,<H>)
{
    cmpwi r5, <ID>		# Compare character
    bne 0x30			# If it doesn't match, skip to the end
    cmpwi r6, <Costume>	# Check if costume ID
    bne 0x28			# If not equal, skip the check
	bl bl_trick			# Else, bl trick to the end and get the name
	word <A>
	word <B>
	word <C>
	word <D>
	word <E>
	word <F>
	word <G>
	word <H>
}

.macro myNames()
{
	# Dr. Mario
    %replace_(0x00,20,30,0x44722E20,0x4D617269,0x6F000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000)
	# Dark Pit
    %replace_(0x16,20,30,0x4461726B,0x20506974,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000)
}

# Results Screen
HOOK @ $800E7C54
{
	lbz r6, 0x26 (r31)	# load costume ID into r6
    %myNames()
    mr r5, r3           # Original Function
	b %END%
bl_trick:
	mflr r5				# Get new character name
	b %END%				# End
}

# Pokemon Stadium
HOOK @ $80986278
{
	# reimplement the entire exchangeMuStockchkind2MuCharName function
	mr r4, r3
	lwz r3, -0x4340 (r13)
	lis r12, 0x8004			# \ setNameRumbleSwitch
	ori r12, r12, 0xD9E8	# |
	mtctr r12				# |
  	bctrl 					# /
	cmpwi r3, 0
	beq- getName
	lis r3, 0x817D
	rlwinm r0, r4, 2, 0, 29
	addi r3, r3, 0x62E0
	lwzx r3, r3, r0
	b defaultName
getName:
	lis r3, 0x817D
	rlwinm r0, r4, 2, 0, 29
	addi r3, r3, 0x62E0
	# new code
	lis r6, 0x805a			# \ get GameGlobal
	ori r6, r6, 0x00e0		# |
	lwz r6, 0x0 (r6)		# |
	lwz r6, 0x0018(r6)		# | GameGlobal->gmResultInfo
	addi r6, r6, 0x24		# | gmResultInfo->gmPlayerResultInfo
	mulli r7, r24, 0x2AC	# | r24 is the port number, each element of gmPlayerResultInfo is 0x2AC in size, so multiply these to get correct player data
	add r6, r6, r7			# | add to r6 to get correct offset
	lbz r6, 0x2 (r6)		# / load costume ID into r6
	mr r5, r4				# load fighter ID into r5
    %myNames()
	lwzx r3, r3, r0 	# Original function
	b defaultName
bl_trick:
	mflr r3				# Get new character name
	# end new code
defaultName:
	lwz r0, 0x14 (r1)
}