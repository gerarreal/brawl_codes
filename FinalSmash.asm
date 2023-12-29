#############################################################################################################
Individual Costume Final Smash Works for All Costume IDs [Kapedani] + Set Dependent Final Smashes [GeraRReal]
# Modification of Kapedani's code that allows Set-specific Final Smashes
#############################################################################################################
.alias AltZ = 62
.alias AltR = 61
.macro perSet(<FighterID>)
{
    cmpwi r31, <FighterID>
    bne notThat
    cmpwi r6, AltZ; beq AltZ_FS
    cmpwi r6, AltR; beq AltR_FS
Normal_FS:
    li r12, 10
    divw r6, r6, r12
    mulli r6, r6, 10    # Use Final Smash Files 00,20,30,40,50
    cmpwi r6, 10; beq modulo10
    b %END%
modulo10:
    li r6, 0            # Use 00 over 10 files
    b %END%
AltZ_FS:
    li r6, AltZ         # Use Final Smash File 62
    b %END%
AltR_FS:
    li r6, AltR         # Use Final Smash File 61
    b %END%
notThat:
}
HOOK @ $8084d52c
{
    %perSet(0x00) # Mario
    %perSet(0x00) # Sonic
}