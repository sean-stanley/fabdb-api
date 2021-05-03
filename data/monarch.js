const monarchSet = {
  MON000: {
    name: 'Great Library of Solana',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON000.png',
    text:
      '**Legendary** *(You may only have 1 Great Library of Solana in your deck.)*\n\nAt the beginning of each end phase, if a hero has 2 or more cards with yellow color strips in their pitch zone, they gain +1[Defense] until end of turn.\n\n**Action** - Discard 2 cards with yellow color strips; Destroy Great Library of Solana. Any hero may activate this ability. **Go again**.',
  },
  MON001: {
    name: 'Prism, Sculptor of Arc Light',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON001.png',
    text:
      'Once per Turn Instant\xa0- [2 Resource], banish a card from Prism\'s soul: Create a Spectral Shield token.\xa0(It\'s an Illusionist aura\xa0with "If your hero would be dealt damage, instead destroy Spectral Shield\xa0and prevent 1 damage that source would deal.")',
  },
  MON002: {
    name: 'Prism',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON002.png',
    text:
      'Once per Turn Instant\xa0- [2 Resource], banish a card from Prism\'s soul: Create a Spectral Shield token.\xa0(It\'s an Illusionist aura\xa0with "If your hero would be dealt damage, instead destroy Spectral Shield\xa0and prevent 1 damage that source would deal.")',
  },
  MON003: {
    name: 'Luminaris',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON003.png',
    text:
      'During your action phase,\xa0Illusionist auras you control are weapons\xa0with 1 [Power] and\xa0"Once per Turn Action\xa0- 0: Attack"\n\nWhile there is a card with a yellow color strip in your pitch zone, Illusionist attacks you control have\xa0go again.',
  },
  MON004: {
    name: 'Herald of Erudition (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON004.png',
    text:
      "Dominate\xa0(The defending hero can't defend Herald of Erudition with more than 1 card from their hand.)\n\nIf {name} hits,\xa0put it into your hero's soul and draw 2\xa0cards.\n\nPhantasm\xa0(If Herald of Erudition is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Erudition and close the combat chain.)",
  },
  MON005: {
    name: 'Arc Light Sentinel (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON005.png',
    text:
      'Prism Specialization\xa0(You may only have Arc Light Sentinel in your deck if your hero is Prism.)\n\nIf Arc Light Sentinel is in the arena when an opponent announces an attack, they must choose Arc Light Sentinel as the target of the attack.\n\nSpectra\xa0(Arc Light Sentinel can be attacked.\xa0When Arc Light Sentinel becomes the target of an attack, destroy it and close the combat chain.\xa0The attack does not resolve.)',
  },
  MON006: {
    name: 'Genesis (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON006.png',
    text:
      "At the start of your turn, you may put a card from your hand into your hero's soul. If it's an Illusionist card, create a Spectral Shield token. If it's a Light card, draw a card.\n\nSpectra\xa0(Genesis can be attacked.\xa0When Genesis becomes the target of an attack, destroy it and close the combat chain.\xa0The attack does not resolve.)",
  },
  MON007: {
    name: 'Herald of Judgment (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON007.png',
    text:
      "Prism Specialization\xa0(You may only have Herald of Judgment in your deck if your hero is Prism.)\n\nIf Herald of Judgment hits,\xa0put it into your hero's soul and the defending hero can't play cards from their banished zone during their next action phase.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Judgment is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Judgment and close the combat chain.)",
  },
  MON008: {
    name: 'Herald of Triumph (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON008.png',
    text:
      "Attack action\xa0cards have -1 [Power]\xa0while defending Herald of Triumph.\n\nIf Herald of Triumph hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Triumph is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Triumph and close the combat chain.)",
  },
  MON009: {
    name: 'Herald of Triumph (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON009.png',
    text:
      "Attack action\xa0cards have -1 [Power]\xa0while defending Herald of Triumph.\n\nIf Herald of Triumph hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Triumph is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Triumph and close the combat chain.)",
  },
  MON010: {
    name: 'Herald of Triumph (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON010.png',
    text:
      "Attack action\xa0cards have -1 [Power]\xa0while defending Herald of Triumph.\n\nIf Herald of Triumph hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Triumph is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Triumph and close the combat chain.)",
  },
  MON011: {
    name: 'Parable of Humility (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON011.png',
    text:
      'Attack action cards controlled by an opposing hero\xa0have -1 [Power] while attacking and defending.\n\nSpectra\xa0(Parable of Humility can be attacked.\xa0When Parable of Humility becomes the target of an attack, destroy it and close the combat chain.\xa0The attack does not resolve.)',
  },
  MON012: {
    name: 'Merfiful Retribution (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON012.png',
    text:
      "Whenever an aura or attack action card you control is destroyed, deal 1 arcane damage to target hero. If it's a non-token Light card, put it into your hero's soul.\xa0(Put it face up under your hero card.)\n\nSpectra\xa0(Merfiful Retribution can be attacked.\xa0When Merfiful Retribution becomes the target of an attack, destroy it and close the combat chain.\xa0The attack does not resolve.)",
  },
  MON013: {
    name: 'Ode to Wrath (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON013.png',
    text:
      'Whenever a source you control deals damage to an opposing hero, they lose 1[Life].\n\nIllusionist attack action cards you control have\xa0go again.\xa0(If an attack\xa0is destroyed,\xa0go again does not resolve.)\n\nSpectra\xa0(Ode to Wrath can be attacked.\xa0When Ode to Wrath becomes the target of an attack, destroy it and close the combat chain.\xa0The attack does not resolve.)',
  },
  MON014: {
    name: 'Herald of Protection (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON014.png',
    text:
      'If Herald of Protection hits,\xa0put it into your hero\'s soul and\xa0create a Spectral Shield token.\xa0(It\'s an Illusionist aura\xa0with "If your hero would be dealt damage, instead destroy Spectral Shield\xa0and prevent 1 damage that source would deal.")\n\nPhantasm\xa0(If Herald of Protection is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Protection and close the combat chain.)',
  },
  MON015: {
    name: 'Herald of Protection (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON015.png',
    text:
      'If Herald of Protection hits,\xa0put it into your hero\'s soul and\xa0create a Spectral Shield token.\xa0(It\'s an Illusionist aura\xa0with "If your hero would be dealt damage, instead destroy Spectral Shield\xa0and prevent 1 damage that source would deal.")\n\nPhantasm\xa0(If Herald of Protection is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Protection and close the combat chain.)',
  },
  MON016: {
    name: 'Herald of Protection (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON016.png',
    text:
      'If Herald of Protection hits,\xa0put it into your hero\'s soul and\xa0create a Spectral Shield token.\xa0(It\'s an Illusionist aura\xa0with "If your hero would be dealt damage, instead destroy Spectral Shield\xa0and prevent 1 damage that source would deal.")\n\nPhantasm\xa0(If Herald of Protection is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Protection and close the combat chain.)',
  },
  MON017: {
    name: 'Herald of Ravages (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON017.png',
    text:
      "If Herald of Ravages hits,\xa0put it into your hero's soul and deal 1 arcane damage to target hero.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Ravages is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Ravages and close the combat chain.)",
  },
  MON018: {
    name: 'Herald of Ravages (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON018.png',
    text:
      "If Herald of Ravages hits,\xa0put it into your hero's soul and deal 1 arcane damage to target hero.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Ravages is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Ravages and close the combat chain.)",
  },
  MON019: {
    name: 'Herald of Ravages (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON019.png',
    text:
      "If Herald of Ravages hits,\xa0put it into your hero's soul and deal 1 arcane damage to target hero.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Ravages is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Ravages and close the combat chain.)",
  },
  MON020: {
    name: 'Herald of Rebirth (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON020.png',
    text:
      "If Herald of Rebirth hits,\xa0put it into your hero's soul and put up to 1 card\xa0with\xa0phantasm\xa0from your graveyard on top of your deck.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Rebirth is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Rebirth and close the combat chain.)",
  },
  MON021: {
    name: 'Herald of Rebirth (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON021.png',
    text:
      "If Herald of Rebirth hits,\xa0put it into your hero's soul and put up to 1 card\xa0with\xa0phantasm\xa0from your graveyard on top of your deck.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Rebirth is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Rebirth and close the combat chain.)",
  },
  MON022: {
    name: 'Herald of Rebirth (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON022.png',
    text:
      "If Herald of Rebirth hits,\xa0put it into your hero's soul when the chain link resolves and put up to 1 card\xa0with\xa0phantasm\xa0from your graveyard on top of your deck.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Rebirth is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Rebirth and close the combat chain.)",
  },
  MON023: {
    name: 'Herald of Tenacity (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON023.png',
    text:
      "Dominate\xa0(The defending hero can't defend Herald of Tenacity with more than 1 card from their hand.)\n\nIf Herald of Tenacity hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Tenacity is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Tenacity and close the combat chain.)",
  },
  MON024: {
    name: 'Herald of Tenacity (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON024.png',
    text:
      "Dominate\xa0(The defending hero can't defend Herald of Tenacity with more than 1 card from their hand.)\n\nIf Herald of Tenacity hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Tenacity is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Tenacity and close the combat chain.)",
  },
  MON025: {
    name: 'Herald of Tenacity (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON025.png',
    text:
      "Dominate\xa0(The defending hero can't defend Herald of Tenacity with more than 1 card from their hand.)\n\nIf Herald of Tenacity hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Herald of Tenacity is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Herald of Tenacity and close the combat chain.)",
  },
  MON026: {
    name: 'Wartune Herald (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON026.png',
    text:
      "If Wartune Herald hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Wartune Herald is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Wartune Herald and close the combat chain.)",
  },
  MON027: {
    name: 'Wartune Herald (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON027.png',
    text:
      "If Wartune Herald hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Wartune Herald is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Wartune Herald and close the combat chain.)",
  },
  MON028: {
    name: 'Wartune Herald (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON028.png',
    text:
      "If Wartune Herald hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)\n\nPhantasm\xa0(If Wartune Herald is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Wartune Herald and close the combat chain.)",
  },
  MON029: {
    name: 'Ser Boltyn, Breaker of Dawn',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON029.png',
    text:
      "If you've\xa0charged\xa0this turn, attacks you control have +1 [Power] while defended by an attack action card.\n\nAttack Reaction\xa0- Banish a\xa0card\xa0from Boltyn's soul: Target attack with [Power] greater than its base [Power] gains\xa0go again.",
  },
  MON030: {
    name: 'Boltyn',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON030.png',
    text:
      "If you've\xa0charged\xa0this turn, attacks you control have +1 [Power] while defended by an attack action card.\n\nAttack Reaction\xa0- Banish a\xa0card\xa0from Boltyn's soul: Target attack with [Power] greater than its base [Power] gains\xa0go again.",
  },
  MON031: {
    name: 'Raydn, Duskbane',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON031.png',
    text:
      "Once per Turn Action\xa0- 0:\xa0Attack\n\nIf you've\xa0charged\xa0this turn, Raydn\xa0gains +3 [Power].",
  },
  MON032: {
    name: 'Bolting Blade (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON032.png',
    text:
      "Bolting Blade costs [2 Resource] less to play for each time you've\xa0charged\xa0this turn.",
  },
  MON033: {
    name: 'Beacon of Victory (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON033.png',
    text:
      "As an additional cost to play Beacon of Victory, banish X\xa0cards from your hero's soul. X can't be 0.\n\nTarget attack gains +X [Power].\n\nIf you've charged\xa0this turn, search your deck for an action card with cost X or less, reveal it, put it into your hand, then shuffle your deck.",
  },
  MON034: {
    name: 'Lumina Ascension (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON034.png',
    text:
      "Boltyn Specialization\xa0(You may only have Lumina Ascension in your deck if your hero is Boltyn.)\n\nUntil end of turn, weapons you control gain\xa0+1 [Power] and \"If this hits,\xa0reveal the top card of your deck. If it's a Light card, put it into your hero's soul and gain 1[Life], otherwise put it on the bottom of your deck.\"\n\nIf you've\xa0charged\xa0this turn, you may attack an additional time with each weapon\xa0you control.\n\nGo again",
  },
  MON035: {
    name: 'V of the Vanguard (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON035.png',
    text:
      "Boltyn Specialization\xa0(You may only have V of the Vanguard in your deck if your hero is Boltyn.)\n\nAs an additional cost to play V of the Vanguard, you may charge\xa0your hero's soul any number of times.\xa0(Put 1 or more cards from your hand face up under your hero card.)\n\nAttacks on this combat chain\xa0gain +1 [Power] for each Light card charged\xa0this way.",
  },
  MON036: {
    name: 'Battlefield Blitz (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON036.png',
    text:
      "If you've\xa0charged\xa0this turn, Battlefield Blitz gains\xa0go again.",
  },
  MON037: {
    name: 'Battlefield Blitz (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON037.png',
    text:
      "If you've\xa0charged\xa0this turn, Battlefield Blitz gains\xa0go again.",
  },
  MON038: {
    name: 'Battlefield Blitz (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON038.png',
    text:
      "If you've\xa0charged\xa0this turn, Battlefield Blitz gains\xa0go again.",
  },
  MON039: {
    name: 'Valiant Thrust (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON039.png',
    text: "If you've\xa0charged\xa0this turn, Valiant Thrust gains +3 [Power].",
  },
  MON040: {
    name: 'Valiant Thrust (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON040.png',
    text: "If you've\xa0charged\xa0this turn, Valiant Thrust gains +3 [Power].",
  },
  MON041: {
    name: 'Valiant Thrust (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON041.png',
    text: "If you've\xa0charged\xa0this turn, Valiant Thrust gains +3 [Power].",
  },
  MON042: {
    name: 'Bolt of Courage (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON042.png',
    text:
      'As an additional cost to play Bolt of Courage, you may charge\xa0your hero\'s soul.\xa0(Put a card from your hand face up under your hero card.)\n\nIf you\'ve\xa0charged\xa0this turn, Bolt of Courage gains\xa0"If this hits,\xa0draw a card."',
  },
  MON043: {
    name: 'Bolt of Courage (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON043.png',
    text:
      'As an additional cost to play Bolt of Courage, you may charge\xa0your hero\'s soul.\xa0(Put a card from your hand face up under your hero card.)\n\nIf you\'ve\xa0charged\xa0this turn, Bolt of Courage gains\xa0"If this hits,\xa0draw a card."',
  },
  MON044: {
    name: 'Bolt of Courage (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON044.png',
    text:
      'As an additional cost to play Bolt of Courage, you may charge\xa0your hero\'s soul.\xa0(Put a card from your hand face up under your hero card.)\n\nIf you\'ve\xa0charged\xa0this turn, Bolt of Courage gains\xa0"If this hits,\xa0draw a card."',
  },
  MON045: {
    name: 'Cross the Line (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON045.png',
    text:
      "As an additional cost to play Cross the Line, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)",
  },
  MON046: {
    name: 'Cross the Line (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON046.png',
    text:
      "As an additional cost to play Cross the Line, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)",
  },
  MON047: {
    name: 'Cross the Line (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON047.png',
    text:
      "As an additional cost to play Cross the Line, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)",
  },
  MON048: {
    name: 'Engulfing Light (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON048.png',
    text:
      "As an additional cost to play Engulfing Light, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)\n\nIf you've\xa0charged\xa0this turn, Engulfing Light gains \"If this hits,\xa0put it into your hero's soul.\"",
  },
  MON049: {
    name: 'Engulfing Light (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON049.png',
    text:
      "As an additional cost to play Engulfing Light, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)\n\nIf you've\xa0charged\xa0this turn, Engulfing Light gains \"If this hits,\xa0put it into your hero's soul.\"",
  },
  MON050: {
    name: 'Engulfing Light (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON050.png',
    text:
      "As an additional cost to play Engulfing Light, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)\n\nIf you've\xa0charged\xa0this turn, Engulfing Light gains \"If this hits,\xa0put it into your hero's soul.\"",
  },
  MON051: {
    name: 'Express Lightning (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON051.png',
    text:
      "As an additional cost to play Express Lightning, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)",
  },
  MON052: {
    name: 'Express Lightning (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON052.png',
    text:
      "As an additional cost to play Express Lightning, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)",
  },
  MON053: {
    name: 'Express Lightning (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON053.png',
    text:
      "As an additional cost to play Express Lightning, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)",
  },
  MON054: {
    name: 'Take Flight (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON054.png',
    text:
      "As an additional cost to play Take Flight, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)\n\nIf you've\xa0charged\xa0this turn, Take Flight gains go again.",
  },
  MON055: {
    name: 'Take Flight (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON055.png',
    text:
      "As an additional cost to play Take Flight, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)\n\nIf you've\xa0charged\xa0this turn, Take Flight gains go again.",
  },
  MON056: {
    name: 'Take Flight (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON056.png',
    text:
      "As an additional cost to play Take Flight, you may charge\xa0your hero's soul.\xa0(Put a card from your hand face up under your hero card.)\n\nIf you've\xa0charged\xa0this turn, Take Flight gains go again.",
  },
  MON057: {
    name: 'Courageous Steelhand (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON057.png',
    text: "If you've\xa0charged\xa0this turn, target attack gains +3 [Power].",
  },
  MON058: {
    name: 'Courageous Steelhand (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON058.png',
    text: "If you've\xa0charged\xa0this turn, target attack gains +2 [Power].",
  },
  MON059: {
    name: 'Courageous Steelhand (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON059.png',
    text: "If you've\xa0charged\xa0this turn, target attack gains +1 [Power].",
  },
  MON060: {
    name: 'Vestige of Sol',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON060-CF.png',
    text:
      "Whenever you pitch a Light card, if a card has been put into your hero's soul this turn, gain [1 Resource].\n\nBlade Break\xa0(If you defend with Vestiage of Sol, destroy it when the combat chain closes.)",
  },
  MON061: {
    name: 'Halo of Illumination',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON061.png',
    text:
      "Instant - [1 Resource], destroy Halo of Illumination: Put a card from your hand into your hero's soul. If it's a Light card, draw a card.\xa0(Put the card face up under your hero card.)\n\nSpellvoid 2\xa0(If your hero would be dealt arcane damage, you may destroy Halo of Illumination instead. If you do, prevent 2 arcane damage that source would deal.)",
  },
  MON062: {
    name: 'Celestial Cataclysm (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON062.png',
    text:
      "As an additional cost to play\xa0Celestial Cataclysm, banish 3 cards from your hero's soul.\n\nGo again",
  },
  MON063: {
    name: 'Soul Shield (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON063.png',
    text:
      "Put Soul Shield into your hero's soul when the combat chain closes. (Put this card face up under your hero card.)",
  },
  MON064: {
    name: 'Soul Food (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON064.png',
    text:
      "Put Soul Food and all cards in your hand into your hero's soul. (Put the cards face up under your hero card.)",
  },
  MON065: {
    name: 'Tome of Divinity (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON065.png',
    text:
      "Draw 2\xa0cards.\n\nIf a card has been put into your hero's soul this turn, instead draw 3 cards.",
  },
  MON066: {
    name: 'Invigorating Light (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON066.png',
    text:
      "When you play Invigorating Light, if there are no cards in your hero's soul, put it into your hero's soul when the combat chain closes.\xa0(Put the card face up under your hero card.)",
  },
  MON067: {
    name: 'Invigorating Light (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON067.png',
    text:
      "When you play Invigorating Light, if there are no cards in your hero's soul, put it into your hero's soul when the combat chain closes.\xa0(Put the card face up under your hero card.)",
  },
  MON068: {
    name: 'Invigorating Light (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON068.png',
    text:
      "When you play Invigorating Light, if there are no cards in your hero's soul, put it into your hero's soul when the combat chain closes.\xa0(Put the card face up under your hero card.)",
  },
  MON069: {
    name: 'Glisten (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON069.png',
    text:
      'Distribute up to four\xa0+1 [Power] counters among any number of weapons you control.\n\nAt the beginning of your end phase, remove all +1 [Power] counters from weapons you control.\xa0(If a permanent is no longer a weapon during your end phase, +1 [Power] counters on it are not removed.)',
  },
  MON070: {
    name: 'Glisten (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON070.png',
    text:
      'Distribute up to three +1 [Power] counters among any number of weapons you control.\n\nAt the beginning of your end phase, remove all +1 [Power] counters from weapons you control.\xa0(If a permanent is no longer a weapon during your end phase, +1 [Power] counters on it are not removed.)',
  },
  MON071: {
    name: 'Glisten (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON071.png',
    text:
      'Distribute up to two +1 [Power] counters among any number of weapons you control.\n\nAt the beginning of your end phase, remove all +1 [Power] counters from weapons you control.\xa0(If a permanent is no longer a weapon during your end phase, +1 [Power] counters on it are not removed.)',
  },
  MON072: {
    name: 'Illuminate (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON072.png',
    text:
      "If Illuminate hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)",
  },
  MON073: {
    name: 'Illuminate (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON073.png',
    text:
      "If Illuminate hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)",
  },
  MON074: {
    name: 'Illuminate (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON074.png',
    text:
      "If Illuminate hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)",
  },
  MON075: {
    name: 'Impenetrable Belief (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON075.png',
    text:
      "If 3 or more cards have been put into an opposing hero's banished zone this turn, Impenetrable Belief gains +2[Defense] while defending.",
  },
  MON076: {
    name: 'Impenetrable Belief (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON076.png',
    text:
      "If 3 or more cards have been put into an opposing hero's banished zone this turn, Impenetrable Belief gains +2[Defense] while defending.",
  },
  MON077: {
    name: 'Impenetrable Belief (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON077.png',
    text:
      "If 3 or more cards have been put into an opposing hero's banished zone this turn, Impenetrable Belief gains +2[Defense] while defending.",
  },
  MON078: {
    name: 'Rising Solartide (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON078.png',
    text:
      "If Rising Solartide hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)",
  },
  MON079: {
    name: 'Rising Solartide (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON079.png',
    text:
      "If Rising Solartide hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)",
  },
  MON080: {
    name: 'Rising Solartide (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON080.png',
    text:
      "If Rising Solartide hits,\xa0put it into your hero's soul.\xa0(Put this card face up under your hero card.)",
  },
  MON081: {
    name: 'Seek Enlightenment (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON081.png',
    text:
      'The next attack action card you play this turn gains +3 [Power] and "If this hits, put it into your hero\'s soul."\xa0(Put the card face up under your hero card.)\n\nGo again',
  },
  MON082: {
    name: 'Seek Enlightenment (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON082.png',
    text:
      'The next attack action card you play this turn gains +2 [Power] and "If this hits, put it into your hero\'s soul."\xa0(Put the card face up under your hero card.)\n\nGo again',
  },
  MON083: {
    name: 'Seek Enlightenment (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON083.png',
    text:
      'The next attack action card you play this turn gains +1 [Power] and "If this hits, put it into your hero\'s soul."\xa0(Put the card face up under your hero card.)\n\nGo again',
  },
  MON084: {
    name: 'Blinding Beam (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON084.png',
    text:
      'Blinding Beam costs [1 Resource] less to play if it targets a Shadow card.\n\nTarget attacking or defending attack action card gets -3 [Power].',
  },
  MON085: {
    name: 'Blinding Beam (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON085.png',
    text:
      'Blinding Beam costs [1 Resource] less to play if it targets a Shadow card.\n\nTarget attacking or defending attack action card gets -2 [Power].',
  },
  MON086: {
    name: 'Blinding Beam (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON086.png',
    text:
      'Blinding Beam costs [1 Resource] less to play if it targets a Shadow card.\n\nTarget attacking or defending attack action card gets -1 [Power].',
  },
  MON087: {
    name: 'Ray of Hope (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON087.png',
    text:
      "Attacks you control have +1 [Power] while attacking a Shadow hero this turn.\n\nIf you have less [Life] than an opposing Shadow hero, put Ray of Hope into your hero's soul.\xa0(Put this card face up under your hero card.)",
  },
  MON088: {
    name: 'Iris of Reality',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON088.png',
    text:
      'During your action phase, Illusionist auras\xa0you control are\xa0weapons with 4 [Power] and\xa0"Once per Turn Action\xa0- [3 Resource]: Attack. Go again"\n\n',
  },
  MON089: {
    name: 'Phantasmal Footsteps',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON089-CF.png',
    text:
      'The first time\xa0an Illusionist attack action card you control is destroyed each turn, you may pay [1 Resource]. If you do, gain 1 action point.\n\nWhenever you defend with Phantasmal Footsteps, you may pay [1 Resource]. If you do, its [Defense] becomes 1 until end of turn.\n\nIf Phantasmal Footsteps defends a non-Illusionist attack with 6 or more [Power], destroy it when the combat chain closes.',
  },
  MON090: {
    name: 'Dream Weavers',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON090.png',
    text:
      "Action\xa0- Destroy Dream Weavers: The next Illusionist attack\xa0action card\xa0you play this turn\xa0loses and can't gain\xa0phantasm.\xa0Go again\n\nSpellvoid 1\xa0(If your hero would be dealt arcane damage, you may destroy Dream Weavers instead. If you do, prevent 1 arcane damage that source would deal.)",
  },
  MON091: {
    name: 'Phantasmaclasm (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON091.png',
    text:
      "Look at the defending hero's hand and choose a card. They put it on the bottom of their deck then draw a card.\n\nPhantasm\xa0(If Phantasmaclasm is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Phantasmaclasm and close the combat chain.)",
  },
  MON092: {
    name: 'Prismatic Shield (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON092.png',
    text:
      'Create 3 Spectral Shield tokens.\xa0(They\'re Illusionist auras\xa0with "If your hero would be dealt damage, instead destroy Spectral Shield\xa0and prevent 1 damage that source would deal.")',
  },
  MON093: {
    name: 'Prismatic Shield (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON093.png',
    text:
      'Create 2\xa0Spectral Shield tokens.\xa0(They\'re Illusionist auras\xa0with "If your hero would be dealt damage, instead destroy Spectral Shield\xa0and prevent 1 damage that source would deal.")',
  },
  MON094: {
    name: 'Prismatic Shield (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON094.png',
    text:
      'Create a\xa0Spectral Shield token.\xa0(It\'s an Illusionist aura\xa0with "If your hero would be dealt damage, instead destroy Spectral Shield\xa0and prevent 1 damage that source would deal.")',
  },
  MON095: {
    name: 'Phantasmify (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON095.png',
    text:
      'The next attack\xa0action card\xa0you play this turn is Illusionist in addition to its other class types, and gains +5 [Power] and phantasm.\xa0(If the attack is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy it\xa0and close the combat chain.)\xa0\n\nGo again',
  },
  MON096: {
    name: 'Phantasmify (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON096.png',
    text:
      'The next attack\xa0action card\xa0you play this turn is Illusionist in addition to its other class types, and gains +4 [Power] and phantasm.\xa0(If the attack\xa0is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy it\xa0and close the combat chain.)\xa0\n\nGo again',
  },
  MON097: {
    name: 'Phantasmify (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON097.png',
    text:
      'The next attack\xa0action card\xa0you play this turn is Illusionist in addition to its other class types, and gains +3 [Power] and phantasm.\xa0(If the attack\xa0is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy it\xa0and close the combat chain.)\xa0\n\nGo again',
  },
  MON098: {
    name: 'Enigma Chimera (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON098.png',
    text:
      'Phantasm\xa0(If Enigma Chimera is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Enigma Chimera and close the combat chain.)',
  },
  MON099: {
    name: 'Enigma Chimera (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON099.png',
    text:
      'Phantasm\xa0(If Enigma Chimera is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Enigma Chimera and close the combat chain.)',
  },
  MON100: {
    name: 'Enigma Chimera (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON100.png',
    text:
      'Phantasm\xa0(If Enigma Chimera is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Enigma Chimera and close the combat chain.)',
  },
  MON101: {
    name: 'Spears of Surreality (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON101.png',
    text:
      'Phantasm\xa0(If Spears of Surreality is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Spears of Surreality and close the combat chain.)\n\nGo again (If Spears of Surreality is destroyed,\xa0go again does not resolve.)',
  },
  MON102: {
    name: 'Spears of Surreality (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON102.png',
    text:
      'Phantasm\xa0(If Spears of Surreality is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Spears of Surreality and close the combat chain.)\n\nGo again (If Spears of Surreality is destroyed,\xa0go again does not resolve.)',
  },
  MON103: {
    name: 'Spears of Surreality (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON103.png',
    text:
      'Phantasm\xa0(If Spears of Surreality is defended by a non-Illusionist\xa0attack action card with 6\xa0or more [Power], destroy Spears of Surreality and close the combat chain.)\n\nGo again (If Spears of Surreality is destroyed,\xa0go again does not resolve.)',
  },
  MON104: {
    name: 'Spectral Shield',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON104.png',
    text:
      '(Auras stay in the arena until they are destroyed.)\n\nIf your hero would be dealt damage, instead destroy Spectral Shield\xa0and prevent 1 damage that source would deal.',
  },
  MON105: {
    name: 'Hatchet of Body',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON105.png',
    text:
      'Once per Turn Action\xa0- [1 Resource]:\xa0Attack\n\nWhenever you attack with Hatchet of Body, if Hatchet of Mind was the last attack this turn, Hatchet of Body gains +1 [Power] until end of turn.',
  },
  MON106: {
    name: 'Hatchet of Mind',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON106.png',
    text:
      'Once per Turn Action\xa0- [1 Resource]:\xa0Attack\n\nWhenever you attack with Hatchet of Mind, if Hatchet of Body was the last attack this turn, Hatchet of Mind gains +1 [Power] until end of turn.',
  },
  MON107: {
    name: 'Valiant Dynamo',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON107-CF.png',
    text:
      'At the beginning of your end phase, if you have attacked 2 or more times with weapons this turn, you may remove a -1[Defense] counter from Valiant Dynamo.\n\nBattleworn\xa0(If you defend with Valiant Dynamo, put a -1[Defense] counter on it when the combat chain closes.)',
  },
  MON108: {
    name: 'Gallantry Gold',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON108.png',
    text:
      'Action\xa0- [1 Resource], destroy Gallantry Gold: Your weapon attacks gain\xa0+1 [Power] this turn. Go again\n\nBattleworn\xa0(If you defend with Gallantry Gold, put a -1[Defense] counter on it when the combat chain closes.)',
  },
  MON109: {
    name: 'Blood Spill (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON109.png',
    text:
      'Axes you control gain +2 [Power] and dominate\xa0until end of\xa0turn.\n\nGo again',
  },
  MON110: {
    name: 'Dusk Path Pilgrimage (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON110.png',
    text:
      'Your next weapon attack this turn gains +3 [Power] and "If this hits, you may attack an additional time with this\xa0weapon\xa0this turn."\xa0(You must have an action point to attack an additional time.)\n\nGo again',
  },
  MON111: {
    name: 'Dusk Path Pilgrimage (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON111.png',
    text:
      'Your next weapon attack this turn gains +2 [Power] and "If this hits, you may attack an additional time with this\xa0weapon\xa0this turn."\xa0(You must have an action point to attack an additional time.)\n\nGo again',
  },
  MON112: {
    name: 'Dusk Path Pilgrimage (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON112.png',
    text:
      'Your next weapon attack this turn gains +1 [Power] and "If this hits, you may attack an additional time with this\xa0weapon\xa0this turn."\xa0(You must have an action point to attack an additional time.)\n\nGo again',
  },
  MON113: {
    name: 'Plow Through (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON113.png',
    text:
      'Your next weapon attack this turn gains +3 [Power] and "If this weapon is defended by an attack action card, it gains +1 [Power] until end of turn".\n\nGo again\n\n',
  },
  MON114: {
    name: 'Plow Through (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON114.png',
    text:
      'Your next weapon attack this turn gains +2 [Power] and "If this weapon is defended by an attack action card, it gains +1 [Power] until end of turn".\n\nGo again\n\n',
  },
  MON115: {
    name: 'Plow Through (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON115.png',
    text:
      'Your next weapon attack this turn gains +1 [Power] and "If this weapon is defended by an attack action card, it gains +1 [Power] until end of turn".\n\nGo again\n\n',
  },
  MON116: {
    name: 'Second Swing (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON116.png',
    text:
      'If you have attacked with a weapon this turn, your next attack this turn gains +4 [Power].\n\nGo again',
  },
  MON117: {
    name: 'Second Swing (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON117.png',
    text:
      'If you have attacked with a weapon this turn, your next attack this turn gains +3 [Power].\n\nGo again',
  },
  MON118: {
    name: 'Second Swing (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON118.png',
    text:
      'If you have attacked with a weapon this turn, your next attack this turn gains +2 [Power].\n\nGo again',
  },
  MON119: {
    name: 'Levia, Shadowborn Abomination',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON119.png',
    text:
      'If a card with 6 or more [Power] has been\xa0put into your banished zone this turn, cards you own lose\xa0blood debt\xa0during the end\xa0phase.\n\n\n\n',
  },
  MON120: {
    name: 'Levia',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON120.png',
    text:
      'If a card with 6 or more [Power] has been\xa0put into your banished zone this turn, cards you own lose\xa0blood debt\xa0during the end\xa0phase.\n\n\n\n',
  },
  MON121: {
    name: 'Hexagore, the Death Hydra',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON121.png',
    text:
      'Once per Turn Action - [2 Resource]:\xa0Attack\n\nWhenever you attack with Hexagore, it deals\xa0damage to you equal to 6 minus the number of cards with blood debt\xa0in your banished zone.',
  },
  MON122: {
    name: 'Hooves of the Shadowbeast',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON122.png',
    text:
      "Whenever\xa0a card with 6 or more [Power] is put into your banished zone, you may destroy Hooves of the Shadowbeast. If you do, gain 1 action point.\xa0(When an equipment is destroyed, it's put into\xa0the graveyard.)\n\nBattleworn\xa0(If you defend with Hooves of the Shadowbeast, put a -1[Defense] counter on it when the combat chain closes.)",
  },
  MON123: {
    name: 'Deep Rooted Evil (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON123.png',
    text:
      'If a card with 6 or more [Power] has been put into your banished zone this turn, you may play Deep Rooted Evil from your banished zone.\n\nBlood Debt (At the beginning of your end phase, if Deep Rooted Evil is in your banished zone,\xa0lose 1[Life].)',
  },
  MON124: {
    name: 'Mark of the Beast (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON124.png',
    text:
      'If Mark of the Beast would be put into your graveyard from anywhere, instead banish it.\n\nBlood Debt (At the beginning of your end phase, if Mark of the Beast is in your banished zone,\xa0lose 1[Life].)',
  },
  MON125: {
    name: 'Shadow of Blasmophet (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON125.png',
    text:
      'Draw a card then discard a random card. If a card with 6 or more [Power] is discarded this way,\xa0search your deck for a card with blood debt, banish it, then shuffle your deck.\n\nBlood Debt (At the beginning of your end phase, if Shadow of Blasmophet is in your banished zone,\xa0lose 1[Life].)',
  },
  MON126: {
    name: 'Endless Maw (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON126.png',
    text:
      'As an additional cost to play Endless Maw, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way,\xa0Endless Maw gains +3 [Power].\n\nBlood Debt (At the beginning of your end phase, if Endless Maw is in your banished zone,\xa0lose 1[Life].)',
  },
  MON127: {
    name: 'Endless Maw (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON127.png',
    text:
      'As an additional cost to play Endless Maw, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way,\xa0Endless Maw gains +3 [Power].\n\nBlood Debt (At the beginning of your end phase, if Endless Maw is in your banished zone,\xa0lose 1[Life].)',
  },
  MON128: {
    name: 'Endless Maw (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON128.png',
    text:
      'As an additional cost to play Endless Maw, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way,\xa0Endless Maw gains +3 [Power].\n\nBlood Debt (At the beginning of your end phase, if Endless Maw is in your banished zone,\xa0lose 1[Life].)',
  },
  MON129: {
    name: 'Writhng Beast Hulk (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON129.png',
    text:
      "As an additional cost to play Writhing Beast Hulk, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way,\xa0Writhing Beast Hulk gains dominate.\xa0(The defending hero can't defend {name} with more than 1 card from their hand.)\n\nBlood Debt (At the beginning of your end phase, if Writhing Beast Hulk is in your banished zone, lose 1[Life].)",
  },
  MON130: {
    name: 'Writhng Beast Hulk (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON130.png',
    text:
      "As an additional cost to play Writhing Beast Hulk, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way,\xa0Writhing Beast Hulk gains dominate.\xa0(The defending hero can't defend {name} with more than 1 card from their hand.)\n\nBlood Debt (At the beginning of your end phase, if Writhing Beast Hulk is in your banished zone, lose 1[Life].)",
  },
  MON131: {
    name: 'Writhng Beast Hulk (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON131.png',
    text:
      "As an additional cost to play Writhing Beast Hulk, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way,\xa0Writhing Beast Hulk gains dominate.\xa0(The defending hero can't defend {name} with more than 1 card from their hand.)\n\nBlood Debt (At the beginning of your end phase, if Writhing Beast Hulk is in your banished zone, lose 1[Life].)",
  },
  MON132: {
    name: 'Convulsions from the Bellows of Hell (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON132.png',
    text:
      "As as additional cost to play Convulsions from the Bellows of Hell, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way, the next attack action card you play this turn gains +3 [Power] and dominate.\xa0(The defending hero can't defend the attack\xa0with more than 1 card from their hand.)\n\nGo again",
  },
  MON133: {
    name: 'Convulsions from the Bellows of Hell (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON133.png',
    text:
      "As as additional cost to play Convulsions from the Bellows of Hell, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way, the next attack action card you play this turn gains +2 [Power] and dominate.\xa0(The defending hero can't defend the attack\xa0with more than 1 card from their hand.)\n\nGo again",
  },
  MON134: {
    name: 'Convulsions from the Bellows of Hell (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON134.png',
    text:
      "As as additional cost to play Convulsions from the Bellows of Hell, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way, the next attack action card you play this turn gains +1 [Power] and dominate.\xa0(The defending hero can't defend the attack\xa0with more than 1 card from their hand.)\n\nGo again",
  },
  MON135: {
    name: 'Boneyard Marauder (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON135.png',
    text:
      'As an additional cost to play Boneyard Marauder, banish 3\xa0random cards from your graveyard.\n\nBlood Debt (At the beginning of your end phase, if Boneyard Marauder is in your banished zone,\xa0lose 1[Life].)',
  },
  MON136: {
    name: 'Boneyard Marauder (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON136.png',
    text:
      'As an additional cost to play Boneyard Marauder, banish 3\xa0random cards from your graveyard.\n\nBlood Debt (At the beginning of your end phase, if Boneyard Marauder is in your banished zone,\xa0lose 1[Life].)',
  },
  MON137: {
    name: 'Boneyard Marauder (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON137.png',
    text:
      'As an additional cost to play Boneyard Marauder, banish 3\xa0random cards from your graveyard.\n\nBlood Debt (At the beginning of your end phase, if Boneyard Marauder is in your banished zone,\xa0lose 1[Life].)',
  },
  MON138: {
    name: 'Deadwood Rumbler (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON138.png',
    text:
      'Draw a card then discard a random card. If a card with 6 or more [Power] is discarded this way, banish a card from a graveyard.\n\nBlood Debt (At the beginning of your end phase, if Deadwood Rumbler is in your banished zone, lose 1[Life].)',
  },
  MON139: {
    name: 'Deadwood Rumbler (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON139.png',
    text:
      'Draw a card then discard a random card. If a card with 6 or more [Power] is discarded this way, banish a card from a graveyard.\n\nBlood Debt (At the beginning of your end phase, if Deadwood Rumbler is in your banished zone, lose 1[Life].)',
  },
  MON140: {
    name: 'Deadwood Rumbler (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON140.png',
    text:
      'Draw a card then discard a random card. If a card with 6 or more [Power] is discarded this way, banish a card from a graveyard.\n\nBlood Debt (At the beginning of your end phase, if Deadwood Rumbler is in your banished zone, lose 1[Life].)',
  },
  MON141: {
    name: 'Dread Screamer (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON141.png',
    text:
      'As an additional cost to play Dread Screamer, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way, Dread Screamer gains\xa0go again.\n\nBlood Debt (At the beginning of your end phase, if Dread Screamer is in your banished zone,\xa0lose 1[Life].)',
  },
  MON142: {
    name: 'Dread Screamer (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON142.png',
    text:
      'As an additional cost to play Dread Screamer, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way, Dread Screamer gains\xa0go again.\n\nBlood Debt (At the beginning of your end phase, if Dread Screamer is in your banished zone,\xa0lose 1[Life].)',
  },
  MON143: {
    name: 'Dread Screamer (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON143.png',
    text:
      'As an additional cost to play Dread Screamer, banish 3\xa0random cards from your graveyard.\n\nIf a card with 6 or more [Power] is banished this way, Dread Screamer gains\xa0go again.\n\nBlood Debt (At the beginning of your end phase, if Dread Screamer is in your banished zone,\xa0lose 1[Life].)',
  },
  MON144: {
    name: 'Graveling Growl (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON144.png',
    text:
      'Play Graveling Growl only if a card with 6 or more [Power] has been put into your banished zone this turn.\n\nBlood Debt (At the beginning of your end phase, if Graveling Growl is in your banished zone,\xa0lose 1[Life].)',
  },
  MON145: {
    name: 'Graveling Growl (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON145.png',
    text:
      'Play Graveling Growl only if a card with 6 or more [Power] has been put into your banished zone this turn.\n\nBlood Debt (At the beginning of your end phase, if Graveling Growl is in your banished zone,\xa0lose 1[Life].)',
  },
  MON146: {
    name: 'Graveling Growl (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON146.png',
    text:
      'Play Graveling Growl only if a card with 6 or more [Power] has been put into your banished zone this turn.\n\nBlood Debt (At the beginning of your end phase, if Graveling Growl is in your banished zone,\xa0lose 1[Life].)',
  },
  MON147: {
    name: 'Hungering Slaughterbeast (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON147.png',
    text:
      'As an additional cost to play Hungering Slaughterbeast, banish 3\xa0random cards from your graveyard.\n\nBlood Debt (At the beginning of your end phase, if Hungering Slaughterbeast is in your banished zone,\xa0lose 1[Life].)',
  },
  MON148: {
    name: 'Hungering Slaughterbeast (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON148.png',
    text:
      'As an additional cost to play Hungering Slaughterbeast, banish 3\xa0random cards from your graveyard.\n\nBlood Debt (At the beginning of your end phase, if Hungering Slaughterbeast is in your banished zone,\xa0lose 1[Life].)',
  },
  MON149: {
    name: 'Hungering Slaughterbeast (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON149.png',
    text:
      'As an additional cost to play Hungering Slaughterbeast, banish 3\xa0random cards from your graveyard.\n\nBlood Debt (At the beginning of your end phase, if Hungering Slaughterbeast is in your banished zone,\xa0lose 1[Life].)',
  },
  MON150: {
    name: 'Unworldy Bellow (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON150.png',
    text:
      'As as additional cost to play Unworldly Bellow, banish 3\xa0random cards from your graveyard.\n\nThe next Brute or Shadow attack action card you play this turn\xa0gains\xa0+4 [Power].\n\nGo again',
  },
  MON151: {
    name: 'Unworldy Bellow (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON151.png',
    text:
      'As as additional cost to play Unworldly Bellow, banish 3\xa0random cards from your graveyard.\n\nThe next Brute or Shadow attack action card you play this turn\xa0gains\xa0+3 [Power].\n\nGo again',
  },
  MON152: {
    name: 'Unworldy Bellow (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON152.png',
    text:
      'As as additional cost to play Unworldly Bellow, banish 3\xa0random cards from your graveyard.\n\nThe next Brute or Shadow attack action card you play this turn\xa0gains\xa0+2 [Power].\n\nGo again',
  },
  MON153: {
    name: 'Chane, Bound by Shadow',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON153.png',
    text:
      'Once per Turn Action - Create a Soul Shackle token: Your next Runeblade or Shadow\xa0action this turn gains\xa0go again. Go again\xa0(It\'s an aura with "At the beginning of your action phase, banish the top card of your deck.")\n\n',
  },
  MON154: {
    name: 'Chane',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON154.png',
    text:
      'Once per Turn Action - Create a Soul Shackle token: Your next Runeblade or Shadow\xa0action this turn gains\xa0go again. Go again\xa0(It\'s an aura with "At the beginning of your action phase, banish the top card of your deck.")\n\n',
  },
  MON155: {
    name: 'Galaxxi Black',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON155.png',
    text:
      'Once per Turn Action - [1 Resource]: Attack\n\nIf you have played a card from your banished zone this turn, {name} gains +2 [Power] until end of turn.\n\nIf {name} hits a hero, deal\xa01 arcane damage to that hero.',
  },
  MON156: {
    name: 'Shadow of Ursur (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON156.png',
    text:
      'You may play Shadow of Ursur from your banished zone.\n\nAs an additional cost to play Shadow of Ursur, you may banish a card with blood debt\xa0from your hand. If you do, Shadow of Ursur gains go again.\n\nBlood Debt (At the beginning of your end phase, if Shadow of Ursur is in your banished zone,\xa0lose 1[Life].)',
  },
  MON157: {
    name: 'Dimenxxional Crossroads (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON157.png',
    text:
      "Go again\xa0\n\nWhenever you play an attack action card or a\xa0'non-attack' action card from the banished zone, if you haven't played another card of that type this turn, deal 1 arcane damage to target hero.\n\nIf you\xa0lose [Life] during your turn, destroy Dimenxxional Crossroads.\xa0(Damage causes loss of [Life].)",
  },
  MON158: {
    name: 'Invert Existence  (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON158.png',
    text:
      "You may play Invert Existence from your banished zone.\n\nBanish up to 2 cards in an opposing hero's graveyard. If an attack action card and a 'non-attack' action card are banished this way, deal 2 arcane damage to that hero.\n\nBlood Debt\xa0(At the beginning of your end phase, if Invert Existence is in your banished zone,\xa0lose 1[Life].)",
  },
  MON159: {
    name: 'Unhallowed Rites (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON159.png',
    text:
      "If you have played a 'non-attack' action card this turn, you may play Unhallowed Rites from your banished zone.\n\nYou may put a 'non-attack' action card with\xa0blood debt\xa0from your graveyard on the bottom of your deck.\n\nBlood Debt (At the beginning of your end phase, if Unhallowed Rites is in your banished zone,\xa0lose 1[Life].)",
  },
  MON160: {
    name: 'Unhallowed Rites (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON160.png',
    text:
      "If you have played a 'non-attack' action card this turn, you may play Unhallowed Rites from your banished zone.\n\nYou may put a 'non-attack' action card with\xa0blood debt\xa0from your graveyard on the bottom of your deck.\n\nBlood Debt (At the beginning of your end phase, if Unhallowed Rites is in your banished zone,\xa0lose 1[Life].)",
  },
  MON161: {
    name: 'Unhallowed Rites (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON161.png',
    text:
      "If you have played a 'non-attack' action card this turn, you may play Unhallowed Rites from your banished zone.\n\nYou may put a 'non-attack' action card with\xa0blood debt\xa0from your graveyard on the bottom of your deck.\n\nBlood Debt (At the beginning of your end phase, if Unhallowed Rites is in your banished zone,\xa0lose 1[Life].)",
  },
  MON162: {
    name: 'Dimenxxional Gateway (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON162.png',
    text:
      "Opt 3\xa0(Look at the top 3 cards of your deck. You may put them on the top and/or bottom in any order.)\n\nReveal the top card of your deck. If it's a Runeblade card, deal\xa01 arcane damage to each opposing hero. If it's a Shadow card, you may banish it.\n\nGo again",
  },
  MON163: {
    name: 'Dimenxxional Gateway (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON163.png',
    text:
      "Opt 2\xa0(Look at the top 2\xa0cards of your deck. You may put them on the top and/or bottom in any order.)\n\nReveal the top card of your deck. If it's a Runeblade card, deal\xa01 arcane damage to each opposing hero. If it's a Shadow card, you may banish it.\n\nGo again",
  },
  MON164: {
    name: 'Dimenxxional Gateway (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON164.png',
    text:
      "Opt 1\xa0(Look at the top card\xa0of your deck. You may put it on the bottom.)\n\nReveal the top card of your deck. If it's a Runeblade card, deal\xa01 arcane damage to each opposing hero. If it's a Shadow card, you may banish it.\n\nGo again",
  },
  MON165: {
    name: 'Seeping Shadows (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON165.png',
    text:
      'You may play Seeping Shadows\xa0from your banished zone.\n\nThe next attack action card with cost 2 or less\xa0you play this turn gains +1 [Power] and\xa0go again.\xa0\n\nGo again\n\nBlood Debt (At the beginning of your end phase, if Seeping Shadows is in your banished zone,\xa0lose 1[Life].)',
  },
  MON166: {
    name: 'Seeping Shadows (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON166.png',
    text:
      'You may play Seeping Shadows\xa0from your banished zone.\n\nThe next attack action card with cost 1 or less\xa0you play this turn gains +1 [Power] and\xa0go again.\xa0\n\nGo again\n\nBlood Debt (At the beginning of your end phase, if Seeping Shadows is in your banished zone,\xa0lose 1[Life].)',
  },
  MON167: {
    name: 'Seeping Shadows (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON167.png',
    text:
      'You may play Seeping Shadows\xa0from your banished zone.\n\nThe next attack action card with cost 0 you play this turn gains +1 [Power] and\xa0go again.\xa0\n\nGo again\n\nBlood Debt (At the beginning of your end phase, if Seeping Shadows is in your banished zone,\xa0lose 1[Life].)',
  },
  MON168: {
    name: 'Bounding Demigon (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON168.png',
    text:
      "If you have played a 'non-attack' action card this turn, you may play Bounding Demigon from your banished zone. If you do, it gains +1 [Power].\n\nBlood Debt (At the beginning of your end phase, if Bounding Demigon is in your banished zone,\xa0lose 1[Life].)",
  },
  MON169: {
    name: 'Bounding Demigon (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON169.png',
    text:
      "If you have played a 'non-attack' action card this turn, you may play Bounding Demigon from your banished zone. If you do, it gains +1 [Power].\n\nBlood Debt (At the beginning of your end phase, if Bounding Demigon is in your banished zone,\xa0lose 1[Life].)",
  },
  MON170: {
    name: 'Bounding Demigon (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON170.png',
    text:
      "If you have played a 'non-attack' action card this turn, you may play Bounding Demigon from your banished zone. If you do, it gains +1 [Power].\n\nBlood Debt (At the beginning of your end phase, if Bounding Demigon is in your banished zone,\xa0lose 1[Life].)",
  },
  MON171: {
    name: 'Piercing Shadow Vise (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON171.png',
    text:
      'You may play Piercing Shadow Vise from your banished zone.\n\nIf you have dealt arcane damage to an opposing hero this turn, Piercing Shadow Vise gains +2 [Power].\n\nBlood Debt (At the beginning of your end phase, if Piercing Shadow Vise is in your banished zone,\xa0lose 1[Life].)',
  },
  MON172: {
    name: 'Piercing Shadow Vise (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON172.png',
    text:
      'You may play Piercing Shadow Vise from your banished zone.\n\nIf you have dealt arcane damage to an opposing hero this turn, Piercing Shadow Vise gains +2 [Power].\n\nBlood Debt (At the beginning of your end phase, if Piercing Shadow Vise is in your banished zone,\xa0lose 1[Life].)',
  },
  MON173: {
    name: 'Piercing Shadow Vise (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON173.png',
    text:
      'You may play Piercing Shadow Vise from your banished zone.\n\nIf you have dealt arcane damage to an opposing hero this turn, Piercing Shadow Vise gains +2 [Power].\n\nBlood Debt (At the beginning of your end phase, if Piercing Shadow Vise is in your banished zone,\xa0lose 1[Life].)',
  },
  MON174: {
    name: 'Rift Bind (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON174.png',
    text:
      "You may play Rift Bind from your banished zone. If you do, it gains +X [Power], where X is the number of\xa0'non-attack' action cards you have played this turn.\n\nBlood Debt (At the beginning of your end phase, if Rift Bind is in your banished zone,\xa0lose 1[Life].)",
  },
  MON175: {
    name: 'Rift Bind (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON175.png',
    text:
      "You may play Rift Bind from your banished zone. If you do, it gains +X [Power], where X is the number of\xa0'non-attack' action cards you have played this turn.\n\nBlood Debt (At the beginning of your end phase, if Rift Bind is in your banished zone,\xa0lose 1[Life].)",
  },
  MON176: {
    name: 'Rift Bind (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON176.png',
    text:
      "You may play Rift Bind from your banished zone. If you do, it gains +X [Power], where X is the number of\xa0'non-attack' action cards you have played this turn.\n\nBlood Debt (At the beginning of your end phase, if Rift Bind is in your banished zone,\xa0lose 1[Life].)",
  },
  MON177: {
    name: 'Rifted Torment (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON177.png',
    text:
      'You may play Rifted Torment from your banished zone. If you do, deal 1 arcane damage to target hero.\n\nBlood Debt (At the beginning of your end phase, if Rifted Torment is in your banished zone,\xa0lose 1[Life].)',
  },
  MON178: {
    name: 'Rifted Torment (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON178.png',
    text:
      'You may play Rifted Torment from your banished zone. If you do, deal 1 arcane damage to target hero.\n\nBlood Debt (At the beginning of your end phase, if Rifted Torment is in your banished zone,\xa0lose 1[Life].)',
  },
  MON179: {
    name: 'Rifted Torment (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON179.png',
    text:
      'You may play Rifted Torment from your banished zone. If you do, deal 1 arcane damage to target hero.\n\nBlood Debt (At the beginning of your end phase, if Rifted Torment is in your banished zone,\xa0lose 1[Life].)',
  },
  MON180: {
    name: 'Rip Through Reality (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON180.png',
    text:
      'You may play Rip Through Reality from your banished zone.\n\nIf you have dealt arcane damage to an opposing hero this turn, Rip Through Reality gains\xa0go again.\n\nBlood Debt (At the beginning of your end phase, if Rip Through Reality is in your banished zone,\xa0lose 1[Life].)',
  },
  MON181: {
    name: 'Rip Through Reality (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON181.png',
    text:
      'You may play Rip Through Reality from your banished zone.\n\nIf you have dealt arcane damage to an opposing hero this turn, Rip Through Reality gains\xa0go again.\n\nBlood Debt (At the beginning of your end phase, if Rip Through Reality is in your banished zone,\xa0lose 1[Life].)',
  },
  MON182: {
    name: 'Rip Through Reality (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON182.png',
    text:
      'You may play Rip Through Reality from your banished zone.\n\nIf you have dealt arcane damage to an opposing hero this turn, Rip Through Reality gains\xa0go again.\n\nBlood Debt (At the beginning of your end phase, if Rip Through Reality is in your banished zone,\xa0lose 1[Life].)',
  },
  MON183: {
    name: 'Seeds of Agony (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON183.png',
    text:
      'You may play Seeds of Agony from your banished zone.\n\nThe next attack action card with cost 2 or less you play this turn gains "Deal 1 arcane damage to target hero."\n\nGo again\n\nBlood Debt (At the beginning of your end phase, if Seeds of Agony is in your banished zone,\xa0lose 1[Life].)',
  },
  MON184: {
    name: 'Seeds of Agony (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON184.png',
    text:
      'You may play Seeds of Agony from your banished zone.\n\nThe next attack action card with cost 1 or less you play this turn gains "Deal 1 arcane damage to target hero."\n\nGo again\n\nBlood Debt (At the beginning of your end phase, if Seeds of Agony is in your banished zone,\xa0lose 1[Life].)',
  },
  MON185: {
    name: 'Seeds of Agony (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON185.png',
    text:
      'You may play Seeds of Agony from your banished zone.\n\nThe next attack action card with cost 0 you play this turn gains "Deal 1 arcane damage to target hero."\n\nGo again\n\nBlood Debt (At the beginning of your end phase, if Seeds of Agony is in your banished zone,\xa0lose 1[Life].)',
  },
  MON186: {
    name: 'Soul Shackle',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON186.png',
    text:
      '(Auras stay in the arena.)\n\nAt the beginning of your action phase, banish the top card of your deck.',
  },
  MON187: {
    name: 'Carrion Husk',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON187-CF.png',
    text:
      'If you defend with Carrion Husk, banish it when the combat chain closes.\n\nAt the start of your turn, If you have 13 or less [Life], banish Carrion Husk.\n\nBlood Debt\xa0(At the beginning of your end phase, if Carrion Husk is in your banished zone,\xa0lose 1[Life].)',
  },
  MON188: {
    name: 'Ebon Fold',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON188.png',
    text:
      "Instant - [1 Resource], destroy Ebon Fold: Banish a card from your hand. If it's a Shadow card, draw a card.\n\nSpellvoid 2\xa0(If your hero would be dealt arcane damage, you may destroy Ebon Fold instead. If you do, prevent 2 arcane damage that source would deal.)",
  },
  MON189: {
    name: 'Doomsday',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON189-CF.png',
    text:
      'Legendary\xa0Levia Specialization\xa0(You may only have 1 Doomsday in your deck and only if your hero is Levia.)\n\nPlay Doomsday only if there are 6 or more cards\xa0with\xa0blood debt\xa0in your banished zone.\n\nCreate a\xa0Blasmophet, the Soul Harvester\xa0token.',
  },
  MON190: {
    name: 'Eclipse',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON190-CF.png',
    text:
      'Legendary\xa0Chane Specialization\xa0(You may only have 1 Eclipse in your deck and only if your hero is Chane.)\n\nPlay Eclipse only if you have played 6 or more cards with\xa0blood debt\xa0this turn. If you have, you may play Eclipse from your banished zone.\n\nCreate an Ursur, the Soul Reaper token.',
  },
  MON191: {
    name: 'Mutated Mass (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON191.png',
    text:
      "You may play Mutated Mass from your banished zone.\n\nMutated Mass's [Power] and [Defense] is equal to twice the\xa0number of cards in your pitch zone with different costs.\n\nBlood Debt (At the beginning of your end phase, if Mutated Mass is in your banished zone,\xa0lose 1[Life].)",
  },
  MON192: {
    name: 'Guardian of the Shadowrealm (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON192.png',
    text:
      'Action\xa0- [2 Resource]: Return Guardian of the Shadowrealm\xa0from your banished zone into your hand. Activate this ability on while Guardian of the Shadowrealm is in your banished zone.\n\nBlood Debt (At the beginning of your end phase, if Guardian Demon is in your banished zone,\xa0lose 1[Life].)',
  },
  MON193: {
    name: 'Shadow Puppetry (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON193.png',
    text:
      'The next attack action card you play this turn gains +1 [Power],\xa0go again\xa0and "If this attack\xa0hits, look at the top card of your deck. You may banish it."\n\nGo again',
  },
  MON194: {
    name: 'Tome of Torment (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON194.png',
    text:
      'You may play Tome of Torment from your banished zone.\n\nDraw a card.\n\nBlood Debt (At the beginning of your end phase, if Tome of Torment is in your banished zone,\xa0lose 1[Life].)',
  },
  MON195: {
    name: 'Consuming Aftermath (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON195.png',
    text:
      "As an additional cost to play Consuming Aftermath, you may banish a card from your hand. If\xa0a Shadow card is banished this way, Consuming Aftermath gains\xa0dominate.\xa0(The defending hero can't defend Consuming Aftermath with more than 1 card from their hand.)",
  },
  MON196: {
    name: 'Consuming Aftermath (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON196.png',
    text:
      "As an additional cost to play Consuming Aftermath, you may banish a card from your hand. If\xa0a Shadow card is banished this way, Consuming Aftermath gains\xa0dominate.\xa0(The defending hero can't defend Consuming Aftermath with more than 1 card from their hand.)",
  },
  MON197: {
    name: 'Consuming Aftermath (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON197.png',
    text:
      "As an additional cost to play Consuming Aftermath, you may banish a card from your hand. If\xa0a Shadow card is banished this way, Consuming Aftermath gains\xa0dominate.\xa0(The defending hero can't defend Consuming Aftermath with more than 1 card from their hand.)",
  },
  MON198: {
    name: 'Soul Harvest (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON198.png',
    text:
      'Legendary\xa0Levia Specialization\xa0(You may only have 1 Soul Harvest in your deck and only if your hero is Levia.)\n\nAs an additional cost to play Soul Harvest, banish 6 cards from your graveyard. It gains +1 [Power] for each card with blood debt\xa0banished this way.\n\nIf {name} hits a hero, banish all cards in their soul. They lose [Life] equal to the number of cards banished this way.',
  },
  MON199: {
    name: 'Soul Reaping (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON199.png',
    text:
      "Legendary\xa0Chane Specialization\xa0(You may only have 1 Soul Reaping in your deck and only if your hero is Chane.)\n\nYou may banish 1 or more cards from your hand rather than pay Soul Reaping's [Resource] cost. If you do, gain [1 Resource] for each card with blood debt\xa0banished this way.\n\nWhile Soul Reaping is attacking a hero with 1 or more cards in their soul, it has\xa0go again.",
  },
  MON200: {
    name: 'Howl from Beyond (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON200.png',
    text:
      'You may play Howl from Beyond from your banished zone.\n\nThe next attack\xa0action card you play this turn gains +3 [Power].\n\nGo again\n\nBlood Debt (At the beginning of your end phase, if Howl from Beyond is in your banished zone,\xa0lose 1[Life].)',
  },
  MON201: {
    name: 'Howl from Beyond (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON201.png',
    text:
      'You may play Howl from Beyond from your banished zone.\n\nThe next attack\xa0action card\xa0you play this turn gains +2 [Power].\n\nGo again\n\nBlood Debt (At the beginning of your end phase, if Howl from Beyond is in your banished zone,\xa0lose 1[Life].)',
  },
  MON202: {
    name: 'Howl from Beyond (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON202.png',
    text:
      'You may play Howl from Beyond from your banished zone.\n\nThe next attack\xa0action card\xa0you play this turn gains +1 [Power].\n\nGo again\n\nBlood Debt (At the beginning of your end phase, if Howl from Beyond is in your banished zone,\xa0lose 1[Life].)',
  },
  MON203: {
    name: 'Ghostly Visit (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON203.png',
    text:
      'You may play Ghostly Visit from your banished zone.\n\nBlood Debt (At the beginning of your end phase, if Ghostly Visit is in your banished zone,\xa0lose 1[Life].)',
  },
  MON204: {
    name: 'Ghostly Visit (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON204.png',
    text:
      'You may play Ghostly Visit from your banished zone.\n\nBlood Debt (At the beginning of your end phase, if Ghostly Visit is in your banished zone,\xa0lose 1[Life].)',
  },
  MON205: {
    name: 'Ghostly Visit (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON205.png',
    text:
      'You may play Ghostly Visit from your banished zone.\n\nBlood Debt (At the beginning of your end phase, if Ghostly Visit is in your banished zone,\xa0lose 1[Life].)',
  },
  MON206: {
    name: 'Lunartide Plunderer (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON206.png',
    text:
      'If Lunartide Plunderer hits a hero, banish it and up to 1 card from their soul.',
  },
  MON207: {
    name: 'Lunartide Plunderer (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON207.png',
    text:
      'If Lunartide Plunderer hits a hero, banish it and up to 1 card from their soul.',
  },
  MON208: {
    name: 'Lunartide Plunderer (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON208.png',
    text:
      'If Lunartide Plunderer hits a hero, banish it and up to 1 card from their soul.',
  },
  MON209: {
    name: 'Void Wraith (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON209.png',
    text:
      'You may play Void Wraith from your banished zone.\n\nBlood Debt (At the beginning of your end phase, if Void Wraith is in your banished zone,\xa0lose 1[Life].)',
  },
  MON210: {
    name: 'Void Wraith (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON210.png',
    text:
      'You may play Void Wraith from your banished zone.\n\nBlood Debt (At the beginning of your end phase, if Void Wraith is in your banished zone,\xa0lose 1[Life].)',
  },
  MON211: {
    name: 'Void Wraith (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON211.png',
    text:
      'You may play Void Wraith from your banished zone.\n\nBlood Debt (At the beginning of your end phase, if Void Wraith is in your banished zone,\xa0lose 1[Life].)',
  },
  MON212: {
    name: 'Spew Shadow (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON212.png',
    text:
      "While Exude Confidence isn't defended by a card with equal or greater [Power], the defending hero can't play or activate instants or defense reactions this combat chain.\n\nInstant -\xa0[3 Resource]: Exude Confidence gains +2 [Power]. Activate this ability only while Exude Confidence is attacking.",
  },
  MON213: {
    name: 'Spew Shadow (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON213.png',
    text:
      'Choose an attack action card with cost 1\xa0or less in your banished zone. You may play it this turn. If it attacks a Light hero, it\xa0gains +2 [Power].\n\nGo again',
  },
  MON214: {
    name: 'Spew Shadow (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON214.png',
    text:
      'Choose an attack action card with cost 0\xa0in your banished zone. You may play it this turn. If it attacks a Light hero, it\xa0gains +2 [Power].\n\nGo again',
  },
  MON215: {
    name: 'Blood Tribute (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON215.png',
    text:
      'Opt 3, then banish the top card of your deck.\xa0(Look at the top 3 cards of your deck. You may put them on the top and/or bottom in any order.)',
  },
  MON216: {
    name: 'Blood Tribute (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON216.png',
    text:
      'Opt 2, then banish the top card of your deck.\xa0(Look at the top 2\xa0cards of your deck. You may put them on the top and/or bottom in any order.)',
  },
  MON217: {
    name: 'Blood Tribute (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON217.png',
    text:
      'Opt 1, then banish the top card of your deck.\xa0(Look at the top cards of your deck. You may put it\xa0on the bottom.)',
  },
  MON218: {
    name: 'Eclipse Existence (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON218.png',
    text:
      'Whenever an attack you control hits a Light hero this turn, you may banish a card from\xa0their soul. If they do, they\xa0lose 1[Life].\n\nIf you have more [Life] than an opposing Light hero, you may banish an action card from\xa0your graveyard.',
  },
  MON219: {
    name: 'Blasmophet, the Soul Harvester',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON219.png',
    text:
      "(Allies can be attacked and can't be defended with [Defense]. They are destroyed when they have taken damage equal to their [Life]. At end of turn, heal all damage dealt to Blasmophet.)\n\nOnce per Turn Action - 0: Attack\n\nWhenever Blasmophet attacks, you may banish a Shadow card from yoru hand. If you do, you may banish a card from the defending hero's soul.",
  },
  MON220: {
    name: 'Ursur, the Soul Reaper',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON220.png',
    text:
      "(Allies can be attacked and can't be defended with [Defense]. They are destroyed when they have taken damage equal to their [Life]. At end of turn, heal all damage dealt to Ursur.)\n\nOnce per Turn Action - 0: Attack\n\nWhile Ursur\xa0is attacking a hero with 1 or more cards in their soul, the attack has\xa0go again.",
  },
  MON221: {
    name: 'Ravenous Meataxe',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON221.png',
    text:
      'Once per Turn Action\xa0- [2 Resource]:\xa0Attack\n\nWhenever you attack with Ravenous Meataxe, draw a card then discard a random card. If a card with 6 or more [Power] is discarded this way, Ravenous Meataxe gains +2 [Power] until end of turn.',
  },
  MON222: {
    name: 'Tear Limb from Limb (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON222.png',
    text:
      "Draw a card\xa0then discard a random card. If a card with 6 or more [Power] is discarded this way, the next Brute attack action card you play this turn gains +X [Power], where X is it's base [Power].\n\nGo again",
  },
  MON223: {
    name: 'Pulping (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON223.png',
    text:
      "Draw a card then discard a random card.\xa0If a card with 6 or more [Power] is discarded this way, Pulping gains dominate.\xa0(The defending hero can't defend Pulping with more than 1 card from their hand.)\n\nWhile Pulping is defended by less than 2 non-equipment cards, it has\xa0go again.",
  },
  MON224: {
    name: 'Pulping (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON224.png',
    text:
      "Draw a card then discard a random card.\xa0If a card with 6 or more [Power] is discarded this way, Pulping gains dominate.\xa0(The defending hero can't defend Pulping with more than 1 card from their hand.)\n\nWhile Pulping is defended by less than 2 non-equipment cards, it has\xa0go again.",
  },
  MON225: {
    name: 'Pulping (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON225.png',
    text:
      "Draw a card then discard a random card.\xa0If a card with 6 or more [Power] is discarded this way, Pulping gains dominate.\xa0(The defending hero can't defend Pulping with more than 1 card from their hand.)\n\nWhile Pulping is defended by less than 2 non-equipment cards, it has\xa0go again.",
  },
  MON226: {
    name: 'Smash with a Big Tree (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON226.png',
    text: 'None',
  },
  MON227: {
    name: 'Smash with a Big Tree (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON227.png',
    text: 'None',
  },
  MON228: {
    name: 'Smash with a Big Tree (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON228.png',
    text: 'None',
  },
  MON229: {
    name: 'Dread Scythe',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON229.png',
    text:
      "Once per Turn Action - [3 Resource]: Attack\n\nWhenever\xa0you attack with Dread Scythe, deal 1 arcane damage to the defending hero.\n\nA hero dealt damage by Dread Scythe can't gain [Life] during their next action phase.",
  },
  MON230: {
    name: 'Aether Ironweave',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON230.png',
    text:
      "Action\xa0- Destroy Aether Ironweave: Gain [2 Resource]. Activate this ability only if you have played an attack action card and a 'non-attack' action card\xa0this turn.\xa0Go again\n\nBattleworn\xa0(If you defend with Aether Ironweave, put a -1[Defense] counter on it when the combat chain closes.)",
  },
  MON231: {
    name: 'Sonata Arcanix (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON231.png',
    text:
      "Reveal the top X+3\xa0cards of your deck.\n\nFor each 'non-attack' action card revealed this way, you may put an attack action card revealed this way into your hand. Then deal arcane damage to target hero equal to the number of cards put into your hand this way.\n\nShuffle your deck. Banish Sonata Arcanix.\n\nGo again",
  },
  MON232: {
    name: 'Vexing Malice (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON232.png',
    text: 'Deal 2 arcane damage to target hero.',
  },
  MON233: {
    name: 'Vexing Malice (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON233.png',
    text: 'Deal 2 arcane damage to target hero.',
  },
  MON234: {
    name: 'Vexing Malice (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON234.png',
    text: 'Deal 2 arcane damage to target hero.',
  },
  MON235: {
    name: 'Arcanic Crackle (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON235.png',
    text: 'Deal 1 arcane damage to target hero.',
  },
  MON236: {
    name: 'Arcanic Crackle (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON236.png',
    text: 'Deal 1 arcane damage to target hero.',
  },
  MON237: {
    name: 'Arcanic Crackle (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON237.png',
    text: 'Deal 1 arcane damage to target hero.',
  },
  MON238: {
    name: 'Blood Drop Brocade',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON238.png',
    text:
      "Instant\xa0- Destroy Blood Drop Brocade: Gain [1 Resource]. Activate this ability\xa0only if you have dealt or been dealt [Power] damage this turn.\xa0(When an equipment is destroyed, it's put into\xa0the graveyard.)",
  },
  MON239: {
    name: 'Stubby Hammerers',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON239.png',
    text:
      "Action\xa0- Destroy Stubby Hammerers: Attack action cards with 3 or less base power gain +1 [Power] while attacking this turn.\xa0Go again\xa0(When an equipment is destroyed, it's put into\xa0the graveyard.)",
  },
  MON240: {
    name: 'Time Skippers',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON240.png',
    text:
      "Action\xa0- [3 Resource], destroy Time Skippers: Gain 2 action points.\xa0(When an equipment is destroyed, it's put into\xa0the graveyard.)",
  },
  MON241: {
    name: 'Ironhide Helm',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON241.png',
    text:
      "When you defend with Ironhide Helm, you may pay [1 Resource]. If you do, it\xa0gains +2[Defense] and destroy it when the combat chain closes.\xa0(When an equipment is destroyed, it's put into\xa0the graveyard.)",
  },
  MON242: {
    name: 'Ironhide Plate',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON242.png',
    text:
      "When you defend with Ironhide Plate, you may pay [1 Resource]. If you do, it\xa0gains +2[Defense] and destroy it when the combat chain closes.\xa0(When an equipment is destroyed, it's put into\xa0the graveyard.)",
  },
  MON243: {
    name: 'Ironhide Gauntlet',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON243.png',
    text:
      "When you defend with Ironhide Gauntle,t you may pay [1 Resource]. If you do, it\xa0gains +2[Defense] and destroy it when the combat chain closes.\xa0(When an equipment is destroyed, it's put into\xa0the graveyard.)",
  },
  MON244: {
    name: 'Ironhide Legs',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON244.png',
    text:
      "When you defend with Ironhide Legs, you may pay [1 Resource]. If you do, it\xa0gains +2[Defense] and destroy it when the combat chain closes.\xa0(When an equipment is destroyed, it's put into\xa0the graveyard.)",
  },
  MON245: {
    name: 'Exude Confidence (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON245.png',
    text:
      "While Exude Confidence isn't defended by a card with equal or greater [Power], the defending hero can't play or activate instants or defense reactions this combat chain.\n\nInstant -\xa0[3 Resource]: Exude Confidence gains +2 [Power]. Activate this ability only while Exude Confidence is attacking.",
  },
  MON246: {
    name: 'Nourishing Emptiness (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON246.png',
    text:
      'While there are no attack action cards in your graveyard, Nourishing Emptiness has\xa0dominate\xa0and "If this hits, your hero gains +1 [Intellect] until end of\xa0turn."',
  },
  MON247: {
    name: 'Rouse the Ancients (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON247.png',
    text:
      'As an additional cost to play Rouse the Ancients, you may reveal any number of attack action cards from your hand with 13\xa0or more total [Power]. If you do, Rouse the Ancients gains +7 [Power] and go again.',
  },
  MON248: {
    name: 'Out Muscle (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON248.png',
    text:
      "While Out Muscle isn't defended by a card with equal or greater [Power], it has go again.",
  },
  MON249: {
    name: 'Out Muscle (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON249.png',
    text:
      "While Out Muscle isn't defended by a card with equal or greater [Power], it has go again.",
  },
  MON250: {
    name: 'Out Muscle (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON250.png',
    text:
      "While Out Muscle isn't defended by a card with equal or greater [Power], it has go again.",
  },
  MON251: {
    name: 'Seek Horizon (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON251.png',
    text:
      'As an additional cost to play Seek Horizon, you may put a card from your hand on top of your deck. If you do, Seek Horizon gains go again.',
  },
  MON252: {
    name: 'Seek Horizon (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON252.png',
    text:
      'As an additional cost to play Seek Horizon, you may put a card from your hand on top of your deck. If you do, Seek Horizon gains go again.',
  },
  MON253: {
    name: 'Seek Horizon (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON253.png',
    text:
      'As an additional cost to play Seek Horizon, you may put a card from your hand on top of your deck. If you do, Seek Horizon gains go again.',
  },
  MON254: {
    name: 'Tremor of iArathael (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON254.png',
    text:
      'If a card has been put into your banished zone this turn, Tremor of iArathael gains +2 [Power].',
  },
  MON255: {
    name: 'Tremor of iArathael (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON255.png',
    text:
      'If a card has been put into your banished zone this turn, Tremor of iArathael gains +2 [Power].',
  },
  MON256: {
    name: 'Tremor of iArathael (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON256.png',
    text:
      'If a card has been put into your banished zone this turn, Tremor of iArathael gains +2 [Power].',
  },
  MON257: {
    name: 'Rise Above (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON257.png',
    text:
      "You may put a card from your hand on top of your deck rather than pay Rise Above's [Resource] cost.",
  },
  MON258: {
    name: 'Rise Above (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON258.png',
    text:
      "You may put a card from your hand on top of your deck rather than pay Rise Above's [Resource] cost.",
  },
  MON259: {
    name: 'Rise Above (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON259.png',
    text:
      "You may put a card from your hand on top of your deck rather than pay Rise Above's [Resource] cost.",
  },
  MON260: {
    name: "Captain's Call (1)",
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON260.png',
    text:
      'Choose 1;\n\nThe next attack action card with cost 2 or less you play this turn\xa0gains +2 [Power].\nThe next attack action card with cost 2 or less you play this turn gains go again.\n\nGo again',
  },
  MON261: {
    name: "Captain's Call (2)",
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON261.png',
    text:
      'Choose 1;\n\nThe next attack action card with cost 1\xa0or less you play this turn\xa0gains +2 [Power].\nThe next attack action card with cost 1\xa0or less you play this turn gains go again.\n\nGo again',
  },
  MON262: {
    name: "Captain's Call (3)",
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON262.png',
    text:
      'Choose 1;\n\nThe next attack action card with cost 0\xa0you play this turn\xa0gains +2 [Power].\nThe next attack action card with cost 0\xa0you play this turn gains go again.\n\nGo again',
  },
  MON263: {
    name: 'Adrenaline Rush (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON263.png',
    text:
      'When you play Adrenaline Rush, if you have less [Life] than an opposing hero, it gains +3 [Power].',
  },
  MON264: {
    name: 'Adrenaline Rush (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON264.png',
    text:
      'When you play Adrenaline Rush, if you have less [Life] than an opposing hero, it gains +3 [Power].',
  },
  MON265: {
    name: 'Adrenaline Rush (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON265.png',
    text:
      'When you play Adrenaline Rush, if you have less [Life] than an opposing hero, it gains +3 [Power].',
  },
  MON266: {
    name: 'Belittle (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON266.png',
    text:
      'As an additional cost to play Belittle, you may reveal an attack action card with 3 or less base [Power] from your hand. If you do, search your deck for a card named Minnowism, reveal it, put it into your hand, then shuffle your deck.\n\nGo again',
  },
  MON267: {
    name: 'Belittle (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON267.png',
    text:
      'As an additional cost to play Belittle, you may reveal an attack action card with 3 or less base [Power] from your hand. If you do, search your deck for a card named Minnowism, reveal it, put it into your hand, then shuffle your deck.\n\nGo again',
  },
  MON268: {
    name: 'Belittle (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON268.png',
    text:
      'As an additional cost to play Belittle, you may reveal an attack action card with 3 or less base [Power] from your hand. If you do, search your deck for a card named Minnowism, reveal it, put it into your hand, then shuffle your deck.\n\nGo again',
  },
  MON269: {
    name: 'Brandish (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON269.png',
    text:
      'If Brandish hits, your next weapon attack this turn gains +1 [Power].\n\nGo again',
  },
  MON270: {
    name: 'Brandish (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON270.png',
    text:
      'If Brandish hits, your next weapon attack this turn gains +1 [Power].\n\nGo again',
  },
  MON271: {
    name: 'Brandish (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON271.png',
    text:
      'If Brandish hits, your next weapon attack this turn gains +1 [Power].\n\nGo again',
  },
  MON272: {
    name: 'Frontline Scout (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON272.png',
    text:
      "You may look at the defending hero's hand.\n\nIf Frontline Scout is played from arsenal, it gains\xa0go again.",
  },
  MON273: {
    name: 'Frontline Scout (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON273.png',
    text:
      "You may look at the defending hero's hand.\n\nIf Frontline Scout is played from arsenal, it gains\xa0go again.",
  },
  MON274: {
    name: 'Frontline Scout (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON274.png',
    text:
      "You may look at the defending hero's hand.\n\nIf Frontline Scout is played from arsenal, it gains\xa0go again.",
  },
  MON275: {
    name: 'Overload (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON275.png',
    text:
      "Dominate\xa0(The defending hero can't defend Overload with more than 1 card from their hand.)\n\nIf Overload hits, it gains go again.",
  },
  MON276: {
    name: 'Overload (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON276.png',
    text:
      "Dominate\xa0(The defending hero can't defend Overload with more than 1 card from their hand.)\n\nIf Overload hits, it gains go again.",
  },
  MON277: {
    name: 'Overload (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON277.png',
    text:
      "Dominate\xa0(The defending hero can't defend Overload with more than 1 card from their hand.)\n\nIf Overload hits, it gains go again.",
  },
  MON278: {
    name: 'Pound for Pound (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON278.png',
    text:
      "When you play Pound for Pound, if you have less [Life] than an opposing hero, it gains dominate.\xa0(The defending hero can't defend Pound for Pound with more than 1 card from their hand.)",
  },
  MON279: {
    name: 'Pound for Pound (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON279.png',
    text:
      "When you play Pound for Pound, if you have less [Life] than an opposing hero, it gains dominate.\xa0(The defending hero can't defend Pound for Pound with more than 1 card from their hand.)",
  },
  MON280: {
    name: 'Pound for Pound (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON280.png',
    text:
      "When you play Pound for Pound, if you have less [Life] than an opposing hero, it gains dominate.\xa0(The defending hero can't defend Pound for Pound with more than 1 card from their hand.)",
  },
  MON281: {
    name: 'Rally the Rearguard (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON281.png',
    text:
      'Once per Turn Instant\xa0- Discard a card: Rally the Rearguard gains +3[Defense]. Activate this ability only while\xa0Rally the Rearguard is defending.',
  },
  MON282: {
    name: 'Rally the Rearguard (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON282.png',
    text:
      'Once per Turn Instant\xa0- Discard a card: Rally the Rearguard gains +3[Defense]. Activate this ability only while\xa0Rally the Rearguard is defending.',
  },
  MON283: {
    name: 'Rally the Rearguard (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON283.png',
    text:
      'Once per Turn Instant\xa0- Discard a card: Rally the Rearguard gains +3[Defense]. Activate this ability only while\xa0Rally the Rearguard is defending.',
  },
  MON284: {
    name: 'Stony Wootenhog (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON284.png',
    text:
      'While Stony Wootenhog is defended by less than 2 non-equipment cards, it has +1 [Power].',
  },
  MON285: {
    name: 'Stony Wootenhog (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON285.png',
    text:
      'While Stony Wootenhog is defended by less than 2 non-equipment cards, it has +1 [Power].',
  },
  MON286: {
    name: 'Stony Wootenhog (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON286.png',
    text:
      'While Stony Wootenhog is defended by less than 2 non-equipment cards, it has +1 [Power].',
  },
  MON287: {
    name: 'Surging Militia (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON287.png',
    text:
      'Surging Militia has +1 [Power] for each non-equipment card defending it.',
  },
  MON288: {
    name: 'Surging Militia (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON288.png',
    text:
      'Surging Militia has +1 [Power] for each non-equipment card defending it.',
  },
  MON289: {
    name: 'Surging Militia (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON289.png',
    text:
      'Surging Militia has +1 [Power] for each non-equipment card defending it.',
  },
  MON290: {
    name: 'Yinti Yanti (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON290.png',
    text:
      'While Yinti Yanti is attacking and you control an aura, it has\xa0+1 [Power].\n\nWhile Yinti Yanti is defending and you control an aura, it has\xa0+1[Defense].',
  },
  MON291: {
    name: 'Yinti Yanti (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON291.png',
    text:
      'While Yinti Yanti is attacking and you control an aura, it has\xa0+1 [Power].\n\nWhile Yinti Yanti is defending and you control an aura, it has\xa0+1[Defense].',
  },
  MON292: {
    name: 'Yinti Yanti (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON292.png',
    text:
      'While Yinti Yanti is attacking and you control an aura, it has\xa0+1 [Power].\n\nWhile Yinti Yanti is defending and you control an aura, it has\xa0+1[Defense].',
  },
  MON293: {
    name: 'Zealous Belting (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON293.png',
    text:
      "While there is a card in your pitch zone with [Power] greater than Zealous Belting's base [Power], Zealous Belting has go again.",
  },
  MON294: {
    name: 'Zealous Belting (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON294.png',
    text:
      "While there is a card in your pitch zone with [Power] greater than Zealous Belting's base [Power], Zealous Belting has go again.",
  },
  MON295: {
    name: 'Zealous Belting (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON295.png',
    text:
      "While there is a card in your pitch zone with [Power] greater than Zealous Belting's base [Power], Zealous Belting has go again.",
  },
  MON296: {
    name: 'Minnowism (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON296.png',
    text:
      'The next attack\xa0action card\xa0with 3 or less base [Power] you play this turn gains +3 [Power].\n\nGo again',
  },
  MON297: {
    name: 'Minnowism (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON297.png',
    text:
      'The next attack\xa0action card\xa0with 3 or less base [Power] you play this turn gains +2 [Power].\n\nGo again',
  },
  MON298: {
    name: 'Minnowism (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON298.png',
    text:
      'The next attack\xa0action card\xa0with 3 or less base [Power] you play this turn gains +1 [Power].\n\nGo again',
  },
  MON299: {
    name: 'Warmongers Recital (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON299.png',
    text:
      'The next attack action card you play this turn gains +3 [Power] and "If this hits, put it on the bottom of your deck."\n\nGo again',
  },
  MON300: {
    name: 'Warmongers Recital (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON300.png',
    text:
      'The next attack action card you play this turn gains +2 [Power] and "If this hits, put it on the bottom of your deck."\n\nGo again',
  },
  MON301: {
    name: 'Warmongers Recital (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON301.png',
    text:
      'The next attack action card you play this turn gains +1 [Power] and "If this hits, put it on the bottom of your deck."\n\nGo again',
  },
  MON302: {
    name: 'Talisman of Dousing (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON302.png',
    text:
      '(Items stay in the arena until they are destroyed.)\n\nGo again\n\nSpellvoid 1\xa0(If your hero would be dealt arcane damage, you may destroy Talisman of Dousing instead. If you do, prevent 1 arcane damage that source would deal.)',
  },
  MON303: {
    name: 'Memorial Ground (1)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON303.png',
    text:
      'Put target\xa0attack action card with cost 2 or less from your graveyard on top of your deck.\xa0',
  },
  MON304: {
    name: 'Memorial Ground (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON304.png',
    text:
      'Put target\xa0attack action card with cost 1\xa0or less from your graveyard on top of your deck.',
  },
  MON305: {
    name: 'Memorial Ground (3)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON305.png',
    text:
      'Put target\xa0attack action card with cost 0 from your graveyard on top of your deck.',
  },
  MON306: {
    name: 'Cracked Bauble (2)',
    image_url: 'https://fabdb2.imgix.net/cards/printings/MON306.png',
    text: 'None',
  },
};

export default monarchSet;

export const fabled = ['MON000'];
export const tokens = [
  'MON001',
  'MON002',
  'MON029',
  'MON030',
  'MON088',
  'MON104',
  'MON105',
  'MON106',
  'MON119',
  'MON120',
  'MON153',
  'MON154',
  'MON155',
  'MON186',
  'MON219',
  'MON220',
  'MON221',
  'MON306',
];

export const legendaries = [
  'MON060',
  'MON089',
  'MON107',
  'MON187',
  'MON189',
  'MON190',
];

export const majesticWeapons = [
  'MON003',
  'MON031',
  'MON121',
  'MON155',
  'MON229',
];

export const majestics = [
  'MON004',
  'MON005',
  'MON006',
  'MON032',
  'MON033',
  'MON034',
  'MON062',
  'MON063',
  'MON064',
  'MON065',
  'MON091',
  'MON109',
  'MON123',
  'MON124',
  'MON125',
  'MON156',
  'MON157',
  'MON158',
  'MON191',
  'MON192',
  'MON193',
  'MON194',
  'MON222',
  'MON231',
  'MON245',
  'MON246',
  'MON247',
];

export const rares = [
  'MON007',
  'MON008',
  'MON009',
  'MON010',
  'MON011',
  'MON012',
  'MON013',
  'MON035',
  'MON036',
  'MON037',
  'MON038',
  'MON039',
  'MON040',
  'MON041',
  'MON066',
  'MON067',
  'MON068',
  'MON069',
  'MON070',
  'MON071',
  'MON092',
  'MON093',
  'MON094',
  'MON095',
  'MON096',
  'MON097',
  'MON110',
  'MON111',
  'MON112',
  'MON113',
  'MON114',
  'MON115',
  'MON126',
  'MON127',
  'MON128',
  'MON129',
  'MON130',
  'MON131',
  'MON132',
  'MON133',
  'MON134',
  'MON159',
  'MON160',
  'MON161',
  'MON162',
  'MON163',
  'MON164',
  'MON165',
  'MON166',
  'MON167',
  'MON195',
  'MON196',
  'MON197',
  'MON198',
  'MON199',
  'MON200',
  'MON201',
  'MON202',
  'MON223',
  'MON224',
  'MON225',
  'MON232',
  'MON233',
  'MON234',
  'MON248',
  'MON249',
  'MON250',
  'MON251',
  'MON252',
  'MON253',
  'MON254',
  'MON255',
  'MON256',
  'MON257',
  'MON258',
  'MON259',
  'MON260',
  'MON261',
  'MON262',
];

export const commonEquipment = [
  'MON061',
  'MON090',
  'MON108',
  'MON122',
  'MON188',
  'MON230',
  'MON238',
  'MON239',
  'MON240',
  'MON241',
  'MON242',
  'MON243',
  'MON244',
];

export const commons = [
  'MON014',
  'MON015',
  'MON016',
  'MON017',
  'MON018',
  'MON019',
  'MON020',
  'MON021',
  'MON022',
  'MON023',
  'MON024',
  'MON025',
  'MON026',
  'MON027',
  'MON028',
  'MON042',
  'MON043',
  'MON044',
  'MON045',
  'MON046',
  'MON047',
  'MON048',
  'MON049',
  'MON050',
  'MON051',
  'MON052',
  'MON053',
  'MON054',
  'MON055',
  'MON056',
  'MON057',
  'MON058',
  'MON059',
  'MON061',
  'MON072',
  'MON073',
  'MON074',
  'MON075',
  'MON076',
  'MON077',
  'MON078',
  'MON079',
  'MON080',
  'MON081',
  'MON082',
  'MON083',
  'MON084',
  'MON085',
  'MON086',
  'MON087',
  'MON090',
  'MON098',
  'MON099',
  'MON100',
  'MON101',
  'MON102',
  'MON103',
  'MON108',
  'MON116',
  'MON117',
  'MON118',
  'MON122',
  'MON135',
  'MON136',
  'MON137',
  'MON138',
  'MON139',
  'MON140',
  'MON141',
  'MON142',
  'MON143',
  'MON144',
  'MON145',
  'MON146',
  'MON147',
  'MON148',
  'MON149',
  'MON150',
  'MON151',
  'MON152',
  'MON168',
  'MON169',
  'MON170',
  'MON171',
  'MON172',
  'MON173',
  'MON174',
  'MON175',
  'MON176',
  'MON177',
  'MON178',
  'MON179',
  'MON180',
  'MON181',
  'MON182',
  'MON183',
  'MON184',
  'MON185',
  'MON188',
  'MON203',
  'MON204',
  'MON205',
  'MON206',
  'MON207',
  'MON208',
  'MON209',
  'MON210',
  'MON211',
  'MON212',
  'MON213',
  'MON214',
  'MON215',
  'MON216',
  'MON217',
  'MON218',
  'MON226',
  'MON227',
  'MON228',
  'MON230',
  'MON235',
  'MON236',
  'MON237',
  'MON238',
  'MON239',
  'MON240',
  'MON241',
  'MON242',
  'MON243',
  'MON244',
  'MON263',
  'MON264',
  'MON265',
  'MON266',
  'MON267',
  'MON268',
  'MON269',
  'MON270',
  'MON271',
  'MON272',
  'MON273',
  'MON274',
  'MON275',
  'MON276',
  'MON277',
  'MON278',
  'MON279',
  'MON280',
  'MON281',
  'MON282',
  'MON283',
  'MON284',
  'MON285',
  'MON286',
  'MON287',
  'MON288',
  'MON289',
  'MON290',
  'MON291',
  'MON292',
  'MON293',
  'MON294',
  'MON295',
  'MON296',
  'MON297',
  'MON298',
  'MON299',
  'MON300',
  'MON301',
  'MON302',
  'MON303',
  'MON304',
  'MON305',
];
