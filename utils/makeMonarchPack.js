const {
  tokens,
  legendaries,
  majestics,
  rares,
  commons,
  commonEquipment,
  majesticWeapons,
  fabled,
} = require('../data/monarch');

/**
 * @function selectCard
 * @param {string[]} cards
 * @returns {string}
 */
const selectCard = (cards) => cards[Math.floor(Math.random() * cards.length)];

// we used to have 5 legendaries in a set at 1:96 or 1:480 each.
// I'm assuming the 1:480 rules is consistent like it was with CRU
const LEG_RATE = 480;
// taking the 1:480 rule again here but adjusting it for the number of possible equipment/weapons.
const FOIL_EQUIPMENT_RATE = 384;
const NON_RARE = 4;

const makeMonarchPack = () => {
  const equipment = selectCard(commonEquipment);
  const common = [...Array(11).keys()].map(() => selectCard(commons));
  const rare = selectCard(rares);
  let token = [selectCard(tokens)];
  if (token[0] !== 'MON306') token = [...token, selectCard(tokens)];
  // eslint-disable-next-line operator-linebreak
  const rarePlus =
    Math.floor(Math.random() * NON_RARE) === 0
      ? selectCard([...majestics, ...majestics, ...majesticWeapons])
      : selectCard(rares);
  // eslint-disable-next-line operator-linebreak

  const foilFabled = Math.random() < 1 / 960 ? fabled : [];
  const foilLegendary = legendaries.filter(
    () => !Math.floor(Math.random() * LEG_RATE),
  );

  const coldFoil = [...commonEquipment, ...majesticWeapons].filter(
    () => !Math.floor(Math.random() * FOIL_EQUIPMENT_RATE),
  );

  const foilRoll = Math.random();
  let foilOther = '';
  if (foilRoll < 11 / 13) foilOther = selectCard(commons);
  else if (foilRoll < 11 / 13 + 1.75 / 13) foilOther = selectCard(rares);
  else foilOther = selectCard(majestics);

  const foil = [...foilFabled, ...foilLegendary, ...coldFoil, foilOther][0];

  return [
    ...common.slice(0, 8),
    equipment,
    rare,
    rarePlus,
    foil,
    ...common.slice(8),
    ...token,
  ];
};

export default makeMonarchPack;
