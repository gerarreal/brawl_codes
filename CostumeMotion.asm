#########################################
Costume Specific Motion files [GeraRReal]
#########################################
.alias HiddenAltsID = 78
.alias AltRID       = 61
.alias AltZID       = 62
.alias Alt          = 0x416C7400
.alias AltR         = 0x416C7452
.alias AltZ         = 0x416C745A
.alias Default      = 0x3030
.alias SetII        = 0x3230
.alias SetIII       = 0x3330
.alias SetIV        = 0x3430
HOOK @ $8084D124
{
	mr r18, r27
	mr r27, r3
}

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}

.macro checkForFighterID(<ID>)
{
	cmpwi r31, <ID>             # Use a FighterID to configure it.
	beq Check
}

.macro idk()
{
	li r0, 10
	divw r12, r18, r0
	cmpwi r12, 1
	bne 0x8
	subi r12, r12, 1
	cmpwi r12, 0
	bne 0x10
	%lwi(r12,Default)
	b 0x3C
	cmpwi r12, 2
	bne 0x10
	%lwi(r12,SetII)
	b 0x28
	cmpwi r12, 3
	bne 0x10
	%lwi(r12,SetIII)
	b 0x14
	cmpwi r12, 4
	bne 0xC
	%lwi(r12,SetIV)
}

HOOK @ $8084D1CC
{
	bl buffer
	word 0x4D6F7469
	word 0x6F6E0000
	word 0x00000000
	word 0x00000000
buffer:
	mflr r6                     # \ Store buffer space to r6 so it will always load
								# / "Motion" in the sprintf after this hook
	%checkForFighterID(0x2)     # Check if the fighter is Link.
								# \ If it's none of the characters above
	b ZeroRequest               # | zero out the rest of the characters
								# / for good measure.
Check:
	cmpwi r18, AltRID
	beq Div_AltR
	cmpwi r18, AltZID
	beq Div_AltZ
	cmpwi r18, HiddenAltsID
	blt Div
Div_AltCostume:
	subi r18, r18, HiddenAltsID
	%lwi(r12,Alt)
	stw r12, 6(r6)
	%idk()
	stw r12, 9(r6)
	b GetFile
Div_AltR:
	%lwi(r12,AltR)
	stw r12, 6(r6)
	b GetFile
Div_AltZ:
	%lwi(r12,AltZ)
	stw r12, 6(r6)
	b GetFile
Div:
	%idk()
	sth r12, 6(r6)
	b GetFile
ReloadRegisters:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x80           # Reload our registers
ZeroRequest:
	li r12, 0x0
	stw r12, 6(r6)              # Zero out the other characters to correctly load just the Motion file
	b OriginalFunction
GetFile:
	stwu r1, -0x80(r1)
	stmw r3, 0x8(r1)            # Save our registers for later
	lis r12, 0x803F
	ori r12, r12, 0x89FC
	mtctr r12
	bctrl # sprintf/printf.0

	lbz r0, -1(r6)
	cmpwi r0, 0x2F
	subi r6, r6, 1
	bne -0xC
	lbz r0, -1(r6)
	cmpwi r0, 0x2F
	subi r6, r6, 1
	bne -0xC 
	lbz r0, -1(r6)
	cmpwi r0, 0x2F
	subi r6, r6, 1
	bne -0xC
	mr r3, r6
	lis r12, 0x8001
	ori r12, r12, 0xF59C
	mtctr r12
	bctrl # checkModSDFile from FilePatchCode.asm
	
	cmpwi r3, 0
	bne ReloadRegisters
	lmw r3, 0x8(r1)
	addi r1, r1, 0x80           # Reload our registers
	b %END%
OriginalFunction:
	crclr 6,6
	li r18, 0
}