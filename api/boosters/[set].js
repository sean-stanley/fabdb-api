const { default: axios } = require('axios');
const { default: makeMonarchPack } = require('../../utils/makeMonarchPack');
const { default: monarch } = require('../../data/monarch');

const PACK_URL = 'https://fabdb.net/api/packs/generate';

console.log('starting FAB Booster/Sealed Server');

const cardCodeRegex = /[A-Z]{3}\d{3}/;

module.exports = async (req, res) => {
  const { set, number } = req.query;

  const body = {
    hero: 'hero',
    hero_id: `${set}001`,
    weapons: [],
    equipment: [],
    sideboard: [],
  };

  if (['wtr', 'arc'].includes(set)) {
    const packs = await Promise.all(
      [...Array(parseInt(number, 10)).keys()].map(
        async () =>
          // eslint-disable-next-line implicit-arrow-linebreak
          (await axios.get(PACK_URL, { params: { set } })).data,
      ),
    );

    body.maindeck = packs
      .reduce((deck, booster) => [...deck, ...booster], [])
      .map((card) => ({
        id: cardCodeRegex.exec(card.image)[0],
        name: card.identifier,
      }));
  }

  // MONARCH RNG
  if (set === 'mon') {
    body.maindeck = [...Array(parseInt(number, 10)).keys()]
      .reduce((deck) => [...deck, ...makeMonarchPack()], [])
      .map((id) => ({ id, name: monarch[id].name }));
  }

  res.json(body);
};
