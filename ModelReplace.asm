Model Resource Replace [-]
# To be used for moveset variant characters (Ult. Wolf, Ult. Roy and Brawl MK, Giant DK, basically any EX character that reuses models without any changes) so you can save disk space by repurposing models.
# Doesn't repurpose animations, ect or motion ect.
# Example in the code replaces Mario with MarioD
.macro compare(<cond>,<to>)
{
    li r15, <cond>
    mulli r15, r15, 4
    cmpw r15, r0
    bne 0x10
    li r0, <to>
    mulli r0, r0, 4
    b Finish
    li r15, 0
}
HOOK @ $8084D030
{
    %compare(0x0,0x36) # Example, Mario to MarioD
Finish:
    lwzx r4, r3, r0
}