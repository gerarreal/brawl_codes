###########################################################
Extra Fighters on Random Select [GeraRReal]
# Based on work by QuickLava and MarioDox.
# Touchless version.

# The code relies on having the code on Project+Ex due to
# depending on a number of codes added to the build.

# You can store up to 32 extra characters on Random Select.
# Hold L and press X or Y to swap.
###########################################################
.BA<- ExtraFighterData
.BA -> $804ECFC0 ## Store
.GOTO -> MyCode

ExtraFighterData:
byte [32] |
0x29,0x30,0x35,0xFF,| # 00-03: Random, Giga Bowser, Wario-Man, Empty
0xFF,0xFF,0xFF,0xFF,| # 04-07: Empty, Empty, Empty, Empty
0xFF,0xFF,0xFF,0xFF,| # 08-0B: Empty, Empty, Empty, Empty
0xFF,0xFF,0xFF,0xFF,| # 0C-0F: Empty, Empty, Empty, Empty
0xFF,0xFF,0xFF,0xFF,| # 10-13: Empty, Empty, Empty, Empty
0xFF,0xFF,0xFF,0xFF,| # 14-17: Empty, Empty, Empty, Empty
0xFF,0xFF,0xFF,0xFF,| # 18-1B: Empty, Empty, Empty, Empty
0xFF,0xFF,0xFF,0xFF | # 1C-1F: Empty, Empty, Empty, Empty

MyCode:
.RESET
.alias MaxChar = 2 # Keep it as max amount-1
.alias Write = 0x804ECFC0


// Grab L, R and Z input from previous getSysPadStatus
HOOK @ $80689A90
{
  lwz r17, 0x48(r1)
  rlwinm r17, r17, 28, 29, 31
  lwz r0, 0xA4(r30)
}

.macro lwd(<reg>, <addr>)
{
  .alias  temp_Lo = <addr> & 0xFFFF
  .alias  temp_Hi_ = <addr> / 0x10000
  .alias  temp_r = temp_Lo / 0x8000
  .alias  temp_Hi = temp_Hi_ + temp_r
  lis     <reg>, temp_Hi
  lwz     <reg>, temp_Lo(<reg>)
}

.macro saveGPR()
{
	stwu r1, -0x80(r1)
	stmw r3, 0x8(r1)
}
.macro loadGPR()
{
	lmw r3, 0x8(r1)
	addi r1, r1, 0x80
}
.macro charPic()
{
  lis r12, 0x8069
  ori r12, r12, 0x742C
  mtctr r12
  li r12, 0
  bctrl
}
.macro sendSystemCharKind()
{
  lis r12, 0x8069
  ori r12, r12, 0x6570
  mtctr r12
  li r12, 0
  bctrl
}

.macro incCostume()
{
  lis r12, 0x8069
  ori r12, r12, 0xA22C
  mtctr r12
  li r12, 0
  bctrl
}
.macro decCostume()
{
  lis r12, 0x8069
  ori r12, r12, 0xA340
  mtctr r12
  li r12, 0
  bctrl
}
# A macro for the setZeldas check, for Extra Fighters
.macro setZeldas()
{
  %lwd(r18,Write)
  lwz r17, 0x1E8(r3)
  lbzx r17, r18, r17
  cmpwi r17, 0xFF
  bne 0x8
  li r4, 0

  %sendSystemCharKind()
  %loadGPR()
  %saveGPR()
  %lwd(r5, Write)
  lwz r4, 0x1E8(r3)
  lbzx r4, r5, r4
  lwz r6, 0x1BC(r3)
  lwz r5, 0x1B4(r3)
  %charPic()
}

.macro moduloInc(<reg>,<max>)
{
  cmpwi <reg>, <max>
  beq 0xC
  addi <reg>, <reg>, 1
  b 0x8
  li <reg>, 0
}
.macro moduloDec(<reg>,<max>)
{
  cmpwi <reg>, 0
  beq 0xC
  addi <reg>, <reg>, -1
  b 0x8
  li <reg>, <max>
}
.macro shoulderButtonCheck()
{
  cmpwi r17, 0x4
  beq CheckSlot
}

# Fixes an issue where Extra Fighters would default to the amount of costumes the assigned slot would have... by assigning the current ID.
.macro CostumeFix()
{
  lwz r30, 0x1B8(r3)
  cmpwi r30, 0x29
  bne %END%
  %lwd(r30,Write)
  lwz r17, 0x1E8(r3)
  lbzx r30, r30, r17
  li r17, 0
}
# Ditto
.macro CostumeFixII()
{
  lwz r0, 0x1B8(r5)
  cmpwi r0, 0x29
  bne %END%
  %lwd(r28,Write)
  lwz r17, 0x1E8(r5)
  lbzx r0, r28, r17
  li r17, 0
  li r28, 0
}
.macro Uhh()
{
  lwz r4, 0x1B8(r31)
  cmpwi r4, 0x29
  beq 0xC
  mr r4, r3
  b %END%
  %lwd(r4,Write)
  lwz r9, 0x1E8(r31)
  lbzx r4, r4, r9
  li r9, 0
}


# A macro for the setPoke3 check, for SlotEx
.macro setSlotEx()
{
  cmpwi r0, 4
  bge 0x40 # Skip if the checks are repeated more than 4 times
  %lwd(r16, 0x806948C8)
  mulli r29, r29, 4
  add r16, r16, r29
  lbzx r28, r16, r17
  lbzx r29, r16, r4
  cmpwi r29, 0xFF
  bne 0x10
  %loadGPR()
  b %END%
  cmpw r28, r29
  bne 0xC
  mr r29, r19
  b SlotEx

  stw r4, 0x1F0(r3)
  %sendSystemCharKind()
  %loadGPR()
  %saveGPR()
  %lwd(r5, 0x806948C8)
  lwz r4, 0x1F0(r3)
  lwz r6, 0x1B8(r3)
  mulli r6, r6, 4
  add r6, r6, r4
  lbzx r4, r5, r6
  lwz r6, 0x1BC(r3)
  lwz r5, 0x1B4(r3)
  %charPic()
}

# Skip all CSP Touching checks
op b 0x210 @ $80697FC0
op b 0x1A0 @ $80698030
op b 0x130 @ $806980A0
op b 0xC0  @ $80698110

# sendSystemCharKind
op cmpwi r28, 0x29 @ $806965A8
op beq 0x14 @ $806965AC
op b 0x2C @ $806965DC
op b 0x3C @ $806965CC
HOOK @ $806965C4
{
  %lwd(r4,Write)
  li r0, 0
}

#decCharColorNo
HOOK @ $8069A354
{
  %CostumeFix()
}
HOOK @ $8069A3B8
{
  %CostumeFixII()
}
HOOK @ $8069A414
{
  %Uhh()
}

#incCharColorNo
HOOK @ $8069A240
{
  %CostumeFix()
}
HOOK @ $8069A2A8
{
  %CostumeFixII()
}
HOOK @ $8069A304
{
  %Uhh()
}

# Skip Poke3 check if Random
HOOK @ $80694A2C
{
  cmpwi r29, 0x29
  bne %END%
  %lwd(r11, Write)
}
op beq 0x4C @ $80694A30

# exchangeCharKingDetail
CODE @ $806948E8
{
  nop 
  nop 
}
op cmpwi r4, 0x29 @ $806948D4
HOOK @ $806948D8
{
  %lwd(r5, Write)
}
op beq 0x24 @ $806948DC
op nop @ $80694904
op lbzx r4, r5, r0 @ $80694908

#initCharKind
HOOK @ $80693D18
{
  li r12, 0
  %lwd(r11, Write)                   # Get Extra Fighter table pointer
  add r11, r11, r12
  lbz r11, 0(r11)                    # Get Slot ID
  cmpwi r11, 0xFF                    # If the slot is 0xFF, skip to the one that handles SlotEx
  beq ActualCodeStart
  cmpw r4, r11
  beq 0xC
  addi r12, r12, 1
  b -0x24
  li r4, 0x29                        # Go back to 0x29 and revert to Random
  stw r12, 0x1E8(r3)
ActualCodeStart:
  subi r0, r4, 3
}

# Press X
HOOK @ $80689D40
{
  %shoulderButtonCheck()
IncCostume: # Change costume
  %incCostume()
  b %END%
CheckSlot: # Check Slots for...
  %saveGPR()
  mr r4, r31
  lis r10, 0xFFFF
  ori r10, r10, 0xFFFF
  mr r31, r30
  mr r30, r3
  lwz r29, 0x01B8(r3)
  cmpwi r29, 0x29
  li r0, 0
  bne SlotEx
ExtraFighter:
  stw r0, 0x1BC(r3)
  lwz r4, 0x1E8(r3)
  %moduloInc(r4,MaxChar)
  stw r4, 0x1E8(r3)
  %setZeldas()
  b bEND
SlotEx:
  addi r0, r0, 1
  mr r19, r29
  lwz r4, 0x1F0(r3)
  %moduloInc(r4,3)
  mr r17, r4
  %moduloDec(r17,3)
  %setSlotEx()
bEND:
  %loadGPR()
}

# Press Y
HOOK @ $80689D4C
{
  %shoulderButtonCheck()
IncCostume: # Change costume
  %decCostume()
  b %END%
CheckSlot: # Check Slots for...
  %saveGPR()
  mr r4, r31
  lis r10, 0xFFFF
  ori r10, r10, 0xFFFF
  mr r31, r30
  mr r30, r3
  lwz r29, 0x01B8(r3)
  cmpwi r29, 0x29
  li r0, 0
  bne SlotEx
ExtraFighter:
  stw r0, 0x1BC(r3)
  lwz r4, 0x1E8(r3)
  %moduloDec(r4,MaxChar)
  stw r4, 0x1E8(r3)
  %setZeldas()
  b bEND
SlotEx:
  addi r0, r0, 1
  mr r19, r29
  lwz r4, 0x1F0(r3)
  %moduloDec(r4,3)
  mr r17, r4
  %moduloInc(r17,3)
  %setSlotEx()
bEND:
  %loadGPR()
}

# Reset setZeldas check if moving the token away
HOOK @ $80697044
{
  stw r3, 0x1E8(r30)
  mr r3, r30
}

## Change the sound effects to the scrolling one if holding L
HOOK @ $80689D9C
{
  cmpwi r17, 4
  beq audio_23
  b normal
audio_23:
  li r4, 0x23
  b %END%
normal:
  li r4, 0x0
}