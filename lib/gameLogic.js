const WebSocket = require('ws');

// Define constants
const PORT = process.env.PORT || 3000;

// Initialize WebSocket server
const wss = new WebSocket.Server({ port: PORT });


let gameState = {
  players: [],           // List of players
  pot: 0,                // Current pot amount
  currentTurn: 0,        // Index of player whose turn it is
  communityCards: [],    // Community cards
  deck: [],              // Deck of cards
  deckIndex: 0,          // Index to track current card dealing
  smallBlind: 10,        // Small blind amount
  bigBlind: 20,          // Big blind amount
  minBet: 20,            // Minimum bet amount
};


// Function to create a deck of cards 
function createDeck() {
  const ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
  const suits = ['hearts', 'diamonds', 'clubs', 'spades'];
  const deck = [];

  ranks.forEach(rank => {
    suits.forEach(suit => {
      deck.push({ rank, suit });
    });
  });

  return deck;
}

// Function to shuffle deck of cards 
function shuffleDeck(deck) {
  for (let i = deck.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [deck[i], deck[j]] = [deck[j], deck[i]];
  }
  return deck;
}

// Function to deal cards to players
function dealCards(deck, count) {
  const cards = [];
  for (let i = 0; i < count; i++) {
    cards.push(deck.pop());
  }
  return cards;
}

// Function to start a new round
function startNewRound() {
  gameState.communityCards = [];   // Clear community cards
  gameState.deck = createDeck();   // Create a new deck
  gameState.deck = shuffleDeck(gameState.deck);  // Shuffle the deck
  gameState.deckIndex = 0;          // Reset deck index

  // Deal cards to players
  gameState.players.forEach(player => {
    player.hand = dealCards(gameState.deck, 2);  // Deal 2 cards to each player
  });

  gameState.pot = 0;                // Reset pot for new round
  gameState.currentTurn = 0;        // Reset turn to first player
  gameState.minBet = gameState.bigBlind; // Set minimum bet to big blind

  // Notify clients about the new round and initial game state
  broadcastGameState();
}

// Function to handle player actions
function handlePlayerAction(playerId, action, amount) {
  const player = gameState.players.find(p => p.id === playerId);
  if (!player) return;

  switch (action) {
    case 'check':
      // Check logic (skip turn if bet is not equalized)
      if (amount !== gameState.minBet) {
        return; // Invalid check, skip turn
      }
      break;
    case 'fold':
      // Fold logic (remove player from active list)
      player.status = 'folded';
      break;
    case 'bet':
      // Bet logic (place bet amount into pot)
      if (amount < gameState.minBet) {
        return; // Bet amount less than minimum required
      }
      gameState.pot += amount;
      player.bet = amount;
      break;
    case 'raise':
      // Raise logic (increase current bet amount)
      if (amount <= player.bet) {
        return; // Raise amount should be higher than previous bet
      }
      gameState.pot += amount;
      gameState.minBet = amount;
      player.bet = amount;
      break;
    case 'call':
      // Call logic (match current bet amount)
      const currentBet = gameState.players[gameState.currentTurn].bet || 0;
      const callAmount = gameState.minBet - currentBet;
      if (player.chips < callAmount) {
        return; // Insufficient chips to call
      }
      gameState.pot += callAmount;
      player.chips -= callAmount;
      player.bet = gameState.minBet;
      break;
  }

  player.lastAction = action;
  advanceTurn();
}

// Function to advance turn to the next player
function advanceTurn() {
  gameState.currentTurn = (gameState.currentTurn + 1) % gameState.players.length;

  // Check if round is over (all players have acted)
  if (allPlayersActed() && gameState.communityCards.length < 5) {
    dealCommunityCard();
  } else if (allPlayersActed()) {
    endRound();
  } else {
    // Notify clients about the updated game state
    broadcastGameState();
  }
}

// Function to deal community card
function dealCommunityCard() {
  const nextCard = gameState.deck[gameState.deckIndex++];
  gameState.communityCards.push(nextCard);

  // Notify clients about the new community card and updated game state
  broadcastGameState();
}

// Function to check if all players have acted in the current round
function allPlayersActed() {
  return gameState.players.every(player => player.status === 'folded' ||
    (player.bet && player.bet >= gameState.minBet));
}

// Function to end the round and determine the winner
function endRound() {
  const { winner, bestHand } = evaluateHands();

  if (winner) {
    const winningPlayer = gameState.players.find(player => player.id === winner);
    if (winningPlayer) {
      winningPlayer.chips += gameState.pot;
    }
  }

  // Reset game state or prepare for next round
  startNewRound();
}

// Function to evaluate poker hand and determine winner
function evaluateHands() {
  // Initialize variables to track winner and best hand
  let winner = null;
  let bestHand = null;

  // Iterate through each player to evaluate their hand
  gameState.players.forEach(player => {
    // Combine player's hand with community cards
    const allCards = [...player.hand, ...gameState.communityCards];
    
    // Sort cards by rank
    allCards.sort((a, b) => rankValue(b.rank) - rankValue(a.rank));

    // Check for different hand types in decreasing order of strength
    let handType = checkStraightFlush(allCards) || checkFourOfAKind(allCards) || checkFullHouse(allCards) ||
      checkFlush(allCards) || checkStraight(allCards) || checkThreeOfAKind(allCards) ||
      checkTwoPair(allCards) || checkPair(allCards) || checkHighCard(allCards);

    // Compare hands to find the best one
    if (!bestHand || handType.rank > bestHand.rank || (handType.rank === bestHand.rank && handType.value > bestHand.value)) {
      bestHand = handType;
      winner = player.id;
    }
  });

  return { winner, bestHand };
}

// Helper function to assign numerical value to card ranks
function rankValue(rank) {
  const values = {
    '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
    '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14
  };
  return values[rank];
}

// Helper functions to check for different hand types

// Check for straight flush
function checkStraightFlush(cards) {
  if (checkFlush(cards) && checkStraight(cards)) {
    return { rank: 8, value: getHighCardValue(cards), name: 'Straight Flush' };
  }
  return null;
}

// Check for four of a kind
function checkFourOfAKind(cards) {
  const counts = getCardCounts(cards);
  const fourKind = Object.keys(counts).find(rank => counts[rank] === 4);
  if (fourKind) {
    return { rank: 7, value: rankValue(fourKind), name: `Four of a Kind, ${fourKind}s` };
  }
  return null;
}

// Check for full house
function checkFullHouse(cards) {
  const counts = getCardCounts(cards);
  const threeKind = Object.keys(counts).find(rank => counts[rank] === 3);
  if (threeKind) {
    const pair = Object.keys(counts).find(rank => counts[rank] >= 2 && rank !== threeKind);
    if (pair) {
      return { rank: 6, value: rankValue(threeKind), name: `Full House, ${threeKind}s over ${pair}s` };
    }
  }
  return null;
}

// Check for flush
function checkFlush(cards) {
  const suits = {};
  cards.forEach(card => {
    if (!suits[card.suit]) suits[card.suit] = [];
    suits[card.suit].push(card.rank);
  });
  const flushSuit = Object.keys(suits).find(suit => suits[suit].length >= 5);
  if (flushSuit) {
    const flushCards = cards.filter(card => card.suit === flushSuit).slice(0, 5);
    return { rank: 5, value: getHighCardValue(flushCards), name: `Flush, ${flushSuit}` };
  }
  return null;
}

// Check for straight
function checkStraight(cards) {
  let straightCards = [];
  for (let i = 0; i <= cards.length - 5; i++) {
    straightCards = [cards[i]];
    for (let j = i + 1; j < cards.length && straightCards.length < 5; j++) {
      if (rankValue(cards[j].rank) === rankValue(straightCards[straightCards.length - 1].rank) - 1) {
        straightCards.push(cards[j]);
      }
    }
    if (straightCards.length === 5) {
      return { rank: 4, value: getHighCardValue(straightCards), name: `Straight, ${straightCards[0].rank} high` };
    }
  }
  // Check special case for A-5 straight (wheel)
  const wheelStraight = cards.filter(card => card.rank === '5' || card.rank === '4' || card.rank === '3' || card.rank === '2' || card.rank === 'A');
  if (wheelStraight.length >= 5) {
    return { rank: 4, value: rankValue('5'), name: `Straight, 5 high` };
  }
  return null;
}

// Check for three of a kind
function checkThreeOfAKind(cards) {
  const counts = getCardCounts(cards);
  const threeKind = Object.keys(counts).find(rank => counts[rank] === 3);
  if (threeKind) {
    return { rank: 3, value: rankValue(threeKind), name: `Three of a Kind, ${threeKind}s` };
  }
  return null;
}

// Check for two pair
function checkTwoPair(cards) {
  const counts = getCardCounts(cards);
  const pairs = Object.keys(counts).filter(rank => counts[rank] === 2);
  if (pairs.length >= 2) {
    pairs.sort((a, b) => rankValue(b) - rankValue(a));
    return { rank: 2, value: rankValue(pairs[0]), name: `Two Pair, ${pairs[0]}s and ${pairs[1]}s` };
  }
  return null;
}

// Check for pair
function checkPair(cards) {
  const counts = getCardCounts(cards);
  const pair = Object.keys(counts).find(rank => counts[rank] === 2);
  if (pair) {
    return { rank: 1, value: rankValue(pair), name: `Pair of ${pair}s` };
  }
  return null;
}

// Get high card value for tie-breaking
function getHighCardValue(cards) {
  return cards.reduce((max, card) => Math.max(max, rankValue(card.rank)), 0);
}

// Check for high card
function checkHighCard(cards) {
  return { rank: 0, value: getHighCardValue(cards), name: `High Card, ${cards[0].rank} high` };
}

// Helper function to count occurrences of each card rank
function getCardCounts(cards) {
  const counts = {};
  cards.forEach(card => {
    if (!counts[card.rank]) counts[card.rank] = 0;
    counts[card.rank]++;
  });
  return counts;
}

// Function to evaluate poker hand and determine winner
function evaluateHands() {
  // Initialize variables to track winner and best hand
  let winner = null;
  let bestHand = null;

  // Iterate through each player to evaluate their hand
  gameState.players.forEach(player => {
    // Combine player's hand with community cards
    const allCards = [...player.hand, ...gameState.communityCards];

    // Sort cards by rank
    allCards.sort((a, b) => rankValue(b.rank) - rankValue(a.rank));

    // Check for different hand types in decreasing order of strength
    let handType = checkStraightFlush(allCards) || checkFourOfAKind(allCards) || checkFullHouse(allCards) ||
      checkFlush(allCards) || checkStraight(allCards) || checkThreeOfAKind(allCards) ||
      checkTwoPair(allCards) || checkPair(allCards) || checkHighCard(allCards);

    // Compare hands to find the best one
    if (!bestHand || handType.rank > bestHand.rank || (handType.rank === bestHand.rank && handType.value > bestHand.value)) {
      bestHand = handType;
      winner = player.id;
    }
  });

  return { winner, bestHand };
}

// Function to broadcast updated game state to all clients
function broadcastGameState() {
  const gameStateForClients = {
    players: gameState.players.map(player => ({
      id: player.id,
      name: player.name,
      chips: player.chips,
      hand: player.id === gameState.currentTurn ? player.hand : [], // Hide other players' hands
      bet: player.bet || 0,
      lastAction: player.lastAction,
      status: player.status
    })),
    pot: gameState.pot,
    communityCards: gameState.communityCards,
    currentTurn: gameState.currentTurn
  };

  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(gameStateForClients));
    }
  });
}

// WebSocket server logic
wss.on('connection', function connection(ws) {
  // Handle incoming messages from clients
  ws.on('message', function incoming(message) {
    const msg = JSON.parse(message);

    switch (msg.type) {
      case 'join':
        // Handle player joining the game
        const newPlayer = {
          id: msg.playerId,
          name: msg.playerName,
          chips: 1000,  // Initial chips
          hand: [],     // Player's current hand
          bet: 0,       // Amount player has bet in current round
          lastAction: '', // Last action performed by player
          status: 'active' // Player status (active, folded, etc.)
        };
        gameState.players.push(newPlayer);

        // Notify all clients about new player and updated game state
        broadcastGameState();
        break;
      case 'action':
        // Handle player action
        handlePlayerAction(msg.playerId, msg.action, msg.amount);
        break;
      default:
        console.log('Unknown message type:', msg.type);
    }
  });

  // Handle client disconnection
  ws.on('close', function close() {
    // Remove player from game
    gameState.players = gameState.players.filter(player => player.id !== ws.playerId);

    // Notify remaining clients about updated game state
    broadcastGameState();
  });

  // Function to send initial game state upon connection
  ws.send(JSON.stringify(gameState));
});

// Start WebSocket server
console.log(`WebSocket server running on port ${PORT}`);


evaluateHands();
startNewRound();

