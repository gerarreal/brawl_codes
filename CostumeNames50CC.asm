###########################################################
Expanded Character Select Screen Portrait Names [GeraRReal]
###########################################################
# For Project+(EX), PMEX REMIX and any build that uses 50CC
# Allows CSP names to adhere to 50CC and change depending on the cosmetic
HOOK @ $80697630
{
    mulli r3, r3, 50    # Multiply by 50
    add r3, r3, r24     # Add r24, which uses the cosmetic ID
}
op cmpwi r31, 255 @ $80697608 # Random Fix