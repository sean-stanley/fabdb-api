module.exports = async (req, res) => {
  const body = {
    hero: 'Rhinar, Reckless Rampage',
    hero_id: 'WTR001',
    weapons: [
      {
        id: 'WTR003',
        name: 'Romping Club',
        count: 1,
      },
    ],
    equipment: [
      {
        id: 'ARC150',
        name: 'Arcanite Skullcap',
        count: 1,
      },
      {
        id: 'WTR150',
        name: "Fyendal's Spring Tunic",
        count: 1,
      },
      {
        id: 'CRU179',
        name: "Gambler's Gloves",
        count: 1,
      },
      {
        id: 'WTR153',
        name: 'Goliath Gauntlet',
        count: 1,
      },
      {
        id: 'ARC157',
        name: 'Nullrune Gloves',
        count: 1,
      },
      {
        id: 'ARC156',
        name: 'Nullrune Robe',
        count: 1,
      },
      {
        id: 'WTR004',
        name: 'Scabskin Leathers',
        count: 1,
      },
      {
        id: 'CRU006',
        name: 'Skullhorn',
        count: 1,
      },
    ],
    sideboard: [
      {
        id: 'CRU009',
        name: 'ARGH... Smash!',
        count: 3,
      },
    ],
    deck: [
      {
        id: 'WTR006',
        name: 'Alpha Rampage',
        count: 3,
      },

      {
        id: 'WTR034',
        name: 'Awakening Bellow',
        count: 3,
      },
      {
        id: 'WTR017',
        name: 'Barraging Beatdown',
        count: 3,
      },
      {
        id: 'WTR018',
        name: 'Barraging Beatdown',
        count: 3,
      },
      {
        id: 'WTR019',
        name: 'Barraging Beatdown',
        count: 3,
      },
      {
        id: 'CRU011',
        name: 'Barraging Big Horn',
        count: 3,
      },
      {
        id: 'CRU007',
        name: 'Beast Within',
        count: 2,
      },
      {
        id: 'WTR007',
        name: 'Bloodrush Bellow',
        count: 3,
      },
      {
        id: 'WTR011',
        name: 'Breakneck Battery',
        count: 3,
      },
      {
        id: 'ARC159',
        name: 'Command and Conquer',
        count: 3,
      },
      {
        id: 'WTR170',
        name: 'Energy Potion',
        count: 1,
      },
      {
        id: 'WTR161',
        name: 'Last Ditch Effort',
        count: 1,
      },
      {
        id: 'CRU008',
        name: 'Massacre',
        count: 3,
      },
      {
        id: 'WTR023',
        name: 'Pack Hunt',
        count: 3,
      },
      {
        id: 'WTR035',
        name: 'Primeval Bellow',
        count: 1,
      },
      {
        id: 'WTR207',
        name: 'Pummel',
        count: 1,
      },
      {
        id: 'WTR008',
        name: 'Reckless Swing',
        count: 2,
      },
      {
        id: 'WTR163',
        name: 'Remembrance',
        count: 1,
      },

      {
        id: 'CRU017',
        name: 'Riled Up',
        count: 1,
      },

      {
        id: 'WTR009',
        name: 'Sand Sketched Plan',
        count: 2,
      },
      {
        id: 'WTR014',
        name: 'Savage Feast',
        count: 3,
      },
      {
        id: 'WTR021',
        name: 'Savage Swing',
        count: 2,
      },

      {
        id: 'WTR215',
        name: 'Sink Below',
        count: 2,
      },
      {
        id: 'WTR027',
        name: 'Smash Instinct',
        count: 3,
      },
      {
        id: 'CRU187',
        name: 'Springboard Somersault',
        count: 3,
      },
      {
        id: 'CRU021',
        name: 'Swing Fist, Think Later',
        count: 1,
      },
      {
        id: 'WTR172',
        name: 'Timesnap Potion',
        count: 1,
      },
      {
        id: 'WTR160',
        name: 'Tome of Fyendal',
        count: 2,
      },
      {
        id: 'WTR031',
        name: 'Wrecker Romp',
        count: 3,
      },
      {
        id: 'WTR030',
        name: 'Wrecker Romp',
        count: 3,
      },
    ],
  };
  res.send(JSON.stringify(body));
};
