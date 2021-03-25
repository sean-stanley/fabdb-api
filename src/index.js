const Koa = require('koa');
const Router = require('@koa/router');
const { default: axios } = require('axios');
const uniqid = require('uniqid');

const app = new Koa();
const router = new Router({ prefix: '/api' });

const PACK_URL = 'https://fabdb.net/api/packs/generate';

console.log('starting FAB Booster/Sealed Server');

router.get('boosters', '/:set/boosters/:number', async (ctx, next) => {
  // ctx.router available
  const { set, number } = ctx.params;
  const packs = await Promise.all(
    [...Array(parseInt(number, 10)).keys()].map(
      async () =>
        // eslint-disable-next-line implicit-arrow-linebreak
        (await axios.get(PACK_URL, { params: { set } })).data,
    ),
  );
  const slug = uniqid.time();
  ctx.body = {
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
});

app.use(router.routes()).use(router.allowedMethods());

app.listen(3000);

console.log('--- Listening on port 3000');
