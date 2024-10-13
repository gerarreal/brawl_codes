Outline Engine [GeraRReal]
# When in Team Battle, it loads costume files with R,G and B at the end.
# This is designed specifically for model variants with an outline and nothing else.
# WARNING: This will add unnecessary bloat to your build!
#          Unless you are not interested in your build being huge,
#          do not add this code.
word 0x00000000 # Reload this player's costume?
word 0x01010101 # Team ID?
word 0x00FFFFFF # Team Battle?
.GOTO -> MyCode


.macro lwd(<reg>, <addr>)
{
  .alias  temp_Lo = <addr> & 0xFFFF
  .alias  temp_Hi_ = <addr> / 0x10000
  .alias  temp_r = temp_Lo / 0x8000
  .alias  temp_Hi = temp_Hi_ + temp_r
  lis   <reg>, temp_Hi
  lwz   <reg>, temp_Lo(<reg>)
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

MyCode:
HOOK @ $8068EF18 # Change Battle Mode
{
  stb r29, 0x5C8(r28) # Normal operation
  bl 0x4
  mflr r14
  subi r14, r14, 0x20
  lbz r15, 0x8(r14)   # Load our settings
  cmpw r29, r15       # Is it Team Battle?
  beq %END%
  stb r5, 0x0(r14)    # \
  stb r5, 0x1(r14)    # | Set Team Checks to 1, to trigger a refresh.
  stb r5, 0x2(r14)    # |
  stb r5, 0x3(r14)    # /
  stb r29, 0x8(r14)   # Set Team Glow settings to match the Team Battle setting
  nop 
  nop 
  nop 
  nop 
}

HOOK @ $80699B84 # Change Team Costume (incColor)
{
  stw r29, 0x1C0(r27)      # Save Team ID, this is what is originally did
  %saveGPR()
  bl 0x4
  mflr r28
  subi r28, r28, 0x78      # Get Table
  lwz r30, 0x1B0(r27)      # Get Player ID
  add r28, r28, r30
  stb r26, 0(r28)          # Set reload tag to 1
  add r29, r29, r26        # Add 1 to the ID so it loads the ID
  stb r29, 4(r28)          # Save Team ID
  %loadGPR()
}

HOOK @ $80699EC8 # Change Team Costume (decColor)
{
  stw r29, 0x1C0(r27)      # Save Team ID, this is what is originally did
  %saveGPR()
  bl 0x4
  mflr r28
  subi r28, r28, 0xB8      # Get Table
  lwz r30, 0x1B0(r27)      # Get Player ID
  add r28, r28, r30
  stb r26, 0(r28)          # Set reload tag to 1
  add r29, r29, r26        # Add 1 to the ID so it loads the ID
  stb r29, 4(r28)          # Save Team ID
  %loadGPR()
}

HOOK @ $80946420 # Right before the Hidden Alt check
{
  rlwinm r0, r5, 0, 24, 31 # Original operation
  bl 0x4
  mflr r11
  subi r11, r11, 0xF0      # Get Table
  lwz r12, 0x48(r30)       # Load Player ID
  add r11, r11, r12        # Add Player ID to the table
  lbz r12, 0(r11)          # Check reload tags
  cmpwi r12, 1             # Can we?
  stb r6, 0(r11)           # Does it regardless on whether a Team alt exists or not
                           # to prevent the game from loading indefinitely
  bne %END%
  li r3, 0x7F              # Set the costume to 128 to refresh
}

HOOK @ $8068EF3C # Team Battle Team Set after tapping the Versus/Brawl button
{
  lwz r3, 0x44(r30)        # It does what it did
  bl 0x4
  mflr r11
  subi r11, r11, 0x128     # Get Table
  lwz r12, 0x1B0(r3)       # Get Player ID
  add r11, r11, r12
  lwz r12, 0x1C0(r3)       # Get Team
  addi r12, r12, 1         # Add 1 to the ID so it loads the ID
  stb r12, 4(r11)          # Save Team ID
}

HOOK @ $8084D0A0 # Post sprintf process
{
  %saveGPR()
  bl 0x4
  mflr r11
  subi r11, r11, 0x15C     # Get Table. From now on, code length can be variable!
  lbz r12, 8(r11)          # Are we in Team Battle?
  cmpwi r12, 0
  beq RegularCostume
  add r12, r11, r21
  lbz r12, 4(r12)          # Check if it is set to a Team Costume
  cmpwi r12, 0
  beq RegularCostume
  mr r19, r3
  mr r15, r4
  lwz r15, -3(r4)
  cmpwi r12, 1; bne 0xC; li r18, 0x52; b theBuffer # R
  cmpwi r12, 2; bne 0xC; li r18, 0x42; b theBuffer # B
  cmpwi r12, 3; bne 0xC; li r18, 0x47; b theBuffer # G
  cmpwi r12, 4; bne 0xC; li r18, 0x59; b theBuffer # Y
  # Last bit is added for ilikepizza's Yellow Team Code
theBuffer:
  bl buffer
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
  word 0x00000000
buffer:
  # Store buffer space
  mflr r3
MakeString:
  sub r4, r6, r19
  addi r4, r4, 1
  # Copy string
  # strcpy/string.o
  lis r12, 0x803F
  ori r12, r12, 0xA280 
  mtctr r12
  bctrl
  stb r18, -4(r7)
  stw r15, -3(r7)
  stb r10, 1(r7)
  stw r3, -0x10(r1)
  # checkModSDFile from FilePatchCode.asm
  lis r12, 0x8001
  ori r12, r12, 0xF59C
  mtctr r12
  bctrl
  # Does the file exist?
  cmpwi r3, 0
  bne RegularCostume
  %loadGPR()
  stw r24, 0x8(r1)
  lwz r4, -0x90(r1)
  b %END%
RegularCostume:
  %loadGPR()
  stw r24, 0x8(r1)
  addi r4, r1, 0x290
}

op nop @ $8084D0A4
op nop @ $8084D0C4