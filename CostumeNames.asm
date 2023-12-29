###########################################################
Expanded Character Select Screen Portrait Names [GeraRReal]
###########################################################
# For vBrawl, Project M(Ex) and Legacy XP
# Allows CSP names to change depending on the cosmetic
HOOK @ $80697630
{
    mulli r3, r3, 10    # Multiply by 10
    add r3, r3, r24     # Add r24, which uses the cosmetic ID
}