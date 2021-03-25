const { default: axios } = require('axios');

const PACK_URL = 'https://fabdb.net/api/packs/generate';

console.log('starting FAB Booster/Sealed Server');

const cardCodeRegex = /[A-Z]{3}\d{3}/;

module.exports = async (req, res) => {
  const { set, number } = req.query;
  const packs = await Promise.all(
    [...Array(parseInt(number, 10)).keys()].map(
      async () =>
        // eslint-disable-next-line implicit-arrow-linebreak
        (await axios.get(PACK_URL, { params: { set } })).data,
    ),
  );

  const body = {
    hero: 'Dash',
    hero_id: 'ARC002',
    maindeck: packs
      .reduce((deck, booster) => [...deck, ...booster], [])
      .map((card) => ({
        id: cardCodeRegex.exec(card.image)[0],
      })),
  };

  res.json(body);
};
