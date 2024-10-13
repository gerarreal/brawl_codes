#############################################################################################################
Individual Costume Final Smash Works for All Costume IDs [Kapedani] + Set Dependent Final Smashes [GeraRReal]
# Modification of Kapedani's code that allows Set-specific Final Smashes
#############################################################################################################
.alias AltC = 78
.alias AltZ = 62
.alias AltR = 61
.macro perSet(<FighterID>)
{
    cmpwi r31, <FighterID>
    bne 0x3C
    cmpwi r6, AltZ
    b %END%
    cmpwi r6, AltR
    b %END%
    cmpwi r6, AltC
    blt 0x8
    subi r6, r6, AltC
    li r12, 10
    divw r6, r6, r12
    mulli r6, r6, 10    # Use Final Smash Files 00,20,30,40
    cmpwi r6, 10
    beq 0x8
    b %END%
    li r6, 0            # Use 00 over 10 files
}
HOOK @ $8084d52c
{
    nop
    %perSet(0x00) # Mario
}

op mr r6, r23 @$8084d518

# QuickLava Hidden Alt Fix
HOOK @ $8084D53C
{
    cmpwi r23, AltC
    bge AltCostume
    cmpwi r23, AltZ
    beq AltZCostume
    cmpwi r23, AltR
    beq AltRCostume
    b %END%
AltCostume:
    mr r6, r23
    subi r6, r6, AltC
    bl Buffer
    word 0x2573416C
    word 0x74253032
    word 0x64000000
AltZCostume:
    bl Buffer
    word 0x2573416C
    word 0x745A0000
AltRCostume:
    bl Buffer
    word 0x2573416C
    word 0x745A0000
Buffer:
    mflr r4
    b %END%
}