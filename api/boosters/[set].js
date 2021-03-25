const { default: axios } = require('axios');
const uniqid = require('uniqid');

const PACK_URL = 'https://fabdb.net/api/packs/generate';

console.log('starting FAB Booster/Sealed Server');

module.exports = async (req, res) => {
  const { set, number } = req.query;
  const packs = await Promise.all(
    [...Array(parseInt(number, 10)).keys()].map(
      async () =>
        // eslint-disable-next-line implicit-arrow-linebreak
        (await axios.get(PACK_URL, { params: { set } })).data,
    ),
  );
  const slug = uniqid.time();
  const body = {
    cardBack: 1,
    creadedAt: new Date().toISOString(),
    format: 'boosters',
    name: `${number} Booster(s) of ${set.toUpperCase()}`,
    notes: null,
    parentId: null,
    slug,
    visibility: 'private',
    cards: packs.reduce((deck, booster) => [...deck, ...booster], []),
  };

  res.json(body);
};
