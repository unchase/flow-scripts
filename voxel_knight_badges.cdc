import NonFungibleToken from 0x1d7e57aa55817448
import Mynft from 0xf6fcbef550d97aa5

pub struct Metadata 
{
    pub let name: String
    pub let description: String

    init(name: String, description: String) 
    {
        self.name = name
        self.description = description
    }
}

pub struct RarityCounter 
{
    pub var nftRarityKeys: [Int]
    pub var nftCount: {Int: UInt64}

    init(nftRarityKeys: [Int]) 
    {
        self.nftRarityKeys = nftRarityKeys
        self.nftCount = {}
        for nftRarityKey in nftRarityKeys 
        {
            self.nftCount.insert(key: nftRarityKey, 0)
        }
    }

    pub fun increaseCount(key: Int)
    {
        if (self.nftRarityKeys.contains(key))
        {
            self.nftCount[key] = self.nftCount[key]! + 1
        }
    }

    pub fun decreaseCount(key: Int)
    {
        if (self.nftRarityKeys.contains(key))
        {
            self.nftCount[key] = self.nftCount[key]! - 1
        }
    }
}

pub struct BadgeData 
{
    pub let metadata: [Metadata?]
    pub let bronze: UInt64
    pub let silver: UInt64
    pub let gold: UInt64
    pub let usedIds: [UInt64]

    init(metadata: [Metadata?], bronze: UInt64, silver: UInt64, gold: UInt64, usedIds: [UInt64]) 
    {
        self.metadata = metadata
        self.bronze = bronze
        self.silver = silver
        self.gold = gold
        self.usedIds = usedIds
    }
}

pub fun getBadgeData(metadata: [Metadata?], counter: RarityCounter, nftRarityIds: {Int: [UInt64]}) : BadgeData
{
    var bronze: UInt64 = 0
    var silver: UInt64 = 0
    var gold: UInt64 = 0
    var usedIds: [UInt64] = []

    while (counter.nftCount[1]! > 0 
            && counter.nftCount[2]! > 0 
            && counter.nftCount[3]! > 0 
            && counter.nftCount[4]! > 0 
            && counter.nftCount[5]! > 0)
    {
        bronze = bronze + 1

        counter.decreaseCount(key: 1)
        usedIds.append(nftRarityIds[1]?.removeFirst()!)

        counter.decreaseCount(key: 2)
        usedIds.append(nftRarityIds[2]?.removeFirst()!)

        counter.decreaseCount(key: 3)
        usedIds.append(nftRarityIds[3]?.removeFirst()!)

        counter.decreaseCount(key: 4)
        usedIds.append(nftRarityIds[4]?.removeFirst()!)

        counter.decreaseCount(key: 5)
        usedIds.append(nftRarityIds[5]?.removeFirst()!)
    }

    while (counter.nftCount[6]! > 0 
            && counter.nftCount[7]! > 0 
            && counter.nftCount[8]! > 0)
    {
        silver = silver + 1

        counter.decreaseCount(key: 6)
        usedIds.append(nftRarityIds[6]?.removeFirst()!)

        counter.decreaseCount(key: 7)
        usedIds.append(nftRarityIds[7]?.removeFirst()!)

        counter.decreaseCount(key: 8)
        usedIds.append(nftRarityIds[8]?.removeFirst()!)
    }

    while(counter.nftCount[9]! > 0)
    {
        if (gold <= silver && gold <= bronze)
        {
            gold = gold + 1

            counter.decreaseCount(key: 9)
            usedIds.append(nftRarityIds[9]?.removeFirst()!)
        }
    }

    return BadgeData(metadata: metadata, bronze: bronze, silver: silver, gold: gold, usedIds: usedIds)
}

// address - the owner's blocto wallet address like "0x0000000000000001"
// nftRarityIds: key - For exaple: 1 - "Church", 
//                                 2 - "welcome to ithaqua", 
//                                 3 - "preacher Leo", 
//                                 4 - "Thieves Clausside", 
//                                 5 - "Drosophila Baal Hadad",
//                                 6 - "leo's fight", 
//                                 7 - "Clausside's fight", 
//                                 8 - "Baal Hadad's fight",
//                                 9 - "Unpleasant encounter"
//               value - array of IDs for the key
// usedBeforIds - IDs that be used before (for another wallet) - will be excluded
pub fun main(address: Address, nftRarityIds: {Int: [UInt64]}, usedBeforIds: [UInt64]): BadgeData? 
{
    let account = getAccount(address)
    let rarityData: [Metadata?] = []

    if (account.getCapability<&Mynft.Collection{Mynft.MynftCollectionPublic}>(Mynft.CollectionPublicPath).check()) 
    {
        let counter: RarityCounter = RarityCounter(nftRarityKeys: nftRarityIds.keys)

        for nft in Mynft.getNft(address: address) 
        {
            if (usedBeforIds.contains(nft.id) == true)
            {
                continue
            }

            for nftRarityKey in nftRarityIds.keys 
            {
                if (nftRarityIds[nftRarityKey]?.contains(nft.id) == true)
                {
                    counter.increaseCount(key: nftRarityKey)
                    rarityData.append(Metadata(name: nft.metadata.name, description: nft.metadata.description))
                    break
                }
            }
        }

        let badgeData = getBadgeData(metadata: rarityData, counter: counter, nftRarityIds: nftRarityIds)
        return badgeData;
    }

    return nil;
}